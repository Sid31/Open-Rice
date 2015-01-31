#!/usr/bin/env python

from __future__ import print_function

import argparse
from csv import DictWriter
import json
import sys

from bs4 import BeautifulSoup
import requests


def main():
    # Set up parsing of command-line arguments
    parser = argparse.ArgumentParser('Export search results from openrice')
    parser.add_argument('--export_type', help='Export type',
                        choices=('json', 'csv', 'raw'),
                        default='csv')
    parser.add_argument('url', help='Openrice URL to scrape')

    args = parser.parse_args()

    scrape_url(args.url, args.export_type)


def clean_string(s):
    return unicode(s).strip().encode('utf-8')


class RawExporter(object):
    """Exporter that just prints the raw HTML response"""
    def __init__(self, file):
        self.file = file

    def export(self, response):
        print(response.text, file=self.file)


class BaseParsingExporter(object):
    """Base class for exporters that parse the HTML"""
    def __init__(self, file):
        self.file = file

    def export(self, response):
        self.export_header()

        soup = BeautifulSoup(response.text)
        poi_blocks = soup.find_all(class_='normal_poiblock')
        for poi_block in poi_blocks:
            # Pull out all text contained within the first 'a' tag with the
            # class 'poi_link'
            restaurant_name = clean_string(
                poi_block.find('a', class_='poi_link').get_text())

            # Pull out all text contained within the first 'div' tag with the
            # class 'sr1_info_item'
            address = clean_string(
                poi_block.find('div', class_='sr1_info_item').get_text())

            data = dict(
                restaurant_name=restaurant_name,
                address=address,
            )
            self.export_row(data)

        self.export_footer()

    def export_header(self):
        pass

    def export_footer(self):
        pass

    def export_row(self, data):
        pass


class CsvExporter(BaseParsingExporter):
    """Exporter that exports to CSV"""
    def __init__(self, file):
        super(CsvExporter, self).__init__(file)
        self._csv_writer = DictWriter(
            self.file,
            fieldnames=('restaurant_name', 'address'))

    def export_header(self):
        self._csv_writer.writeheader()

    def export_row(self, data):
        self._csv_writer.writerow(data)


class JsonExporter(BaseParsingExporter):
    """Exporter that exports to JSON"""
    def export_header(self):
        print('[', file=self.file)

    def export_row(self, data):
        print(json.dumps(data, ensure_ascii=False), ',', sep='', file=self.file)

    def export_footer(self):
        print(']', file=self.file)


def scrape_url(url, export_type):
    '''Scrape one OpenRice URL and export data'''
    exporter = None
    output = sys.stdout
    if export_type == 'raw':
        exporter = RawExporter(output)
    elif export_type == 'csv':
        exporter = CsvExporter(output)
    elif export_type == 'json':
        exporter = JsonExporter(output)

    exporter.export(requests.get(url))


if __name__ == '__main__':
    main()
