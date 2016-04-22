#!/usr/bin/env python
from __future__ import print_function
import string
import sys
import scrape_openrice
import time


start_time=time.time()
#
# y='http://www.openrice.com/en/hongkong/restaurant/sr1.htm?tc=sr1quick&s=1&region=0&inputstrwhat=&inputstrwhere=&district_id='
y = 'http://www.openrice.com/en/hongkong/restaurant/sr1.htm?page='
z =	'&searchSort=31&region=0&district_id='
li=[]

for i in range (1, 33): #i would be the district id number
	for j in range(1,35): #j would be the page number of the current site. How do I find the max range to iterate through?
		k = (y, str(j), z + str(5001+i))
		li.append("".join(k))
		scrape_openrice.scrape_url("".join(k), 'csv')
		
		
elapsed_time=time.time() - start_time
#print(elapsed_time)
sys.stderr.write(str(elapsed_time))

