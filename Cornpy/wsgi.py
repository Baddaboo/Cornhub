from py2neo import neo4j, node
import json, re
from cgi import parse_qs, escape
from db import *
import time
import threading

class MyThread(threading.Thread):
	def __init__(self):
		threading.Thread.__init__(self)
		#for i in range(18,26):
	        #	#query = "obama " + "until:2014-05-" + str(i)
	        #	#print(query)
	        #	update_hashtag("obama","2014-05-" + str(i),400)
	        #	#query = "san jose earthquakes " + "until:2014-05-" + str(i)
	        #	update_hashtag("san jose earthquakes","2014-05-" + str(i),400)
	        #	#query = "sjearthquakes " + "until:2014-05-" + str(i)
	        #	update_hashtag("sjearthquakes","2014-05-" + str(i),400)
	        #	#query = "sanjoseearthquakes " + "until:2014-05-" + str(i)
	        #	update_hashtag("sanjoseearthquakes","2014-05-" + str(i),400)

	def run(self):
		if len( hashTagCacheList ) == 0:
			time.sleep(10)
		else:
			for item in hashTagCacheList:
				update_hashtag(item,'',400,1)
			time.sleep(100)	

#thread = MyThread()
#thread.start()

def application(environ, start_response):

	#GET:
	request_body = environ['QUERY_STRING']
	data = parse_qs(request_body)
	keyword = escape(data.get("keyword", ['-_-'])[0])
	callback = escape(data.get("callback", ['-_-'])[0])
	option = escape(data.get("option", ['-_-'])[0]) #hourly, daily, tridaily

	if keyword != '-_-':
		update_hashtag(keyword,'',400) 
		if keyword not in hashTagCacheList:
			hashTagCacheList.append(keyword)
		
		if option == "tridaily":
			output = return_sentiment_tridaily(keyword)
		elif option == "hourly":
			output = return_sentiment_hourly(keyword)
		else:
			output = return_sentiment(keyword)
	else:
	        output = '{"error": "Argument Error"}'
    	
	#output = '{"error": "Argument Error"}'
	if callback != '-_-':
		output = callback + "(" + output + ");"
    
	response_headers = [('Content-type', 'application/javascript'),
				('Content-Length', str(len(output)))]
	start_response('200 OK', response_headers)
	return [ output ]

