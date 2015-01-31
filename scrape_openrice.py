#!/usr/bin/env python

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


def scrape_url(url, export_type):
    '''Scrape one OpenRice URL and export data'''
    req = requests.get(url)
    if export_type == 'raw':
        print req.text
    elif export_type in ('csv', 'json'):

        # Switch between two different implementations of the `export_row`
        # function depending on whether it's json or csv
        if export_type == 'csv':
            csv_writer = DictWriter(
                sys.stdout,
                fieldnames=('restaurant_name', 'address'))
            export_row = csv_writer.writerow
            csv_writer.writeheader()
        elif export_type == 'json':
            def export_row(data):
                print json.dumps(data, ensure_ascii=False)


        soup = BeautifulSoup(req.text)
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
            export_row(data)


if __name__ == '__main__':
    main()
