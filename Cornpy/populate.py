from TwitterAPI import TwitterAPI
import json
import time
from db import *
from py2neo import neo4j
graph_db = neo4j.GraphDatabaseService()

for i in range(18,26):
	#query = "obama " + "until:2014-05-" + str(i)
	#print(query)
	update_hashtag("obama","2014-05-" + str(i),400)
	#query = "san jose earthquakes " + "until:2014-05-" + str(i)
	update_hashtag("san jose earthquakes","2014-05-" + str(i),400)
	#query = "sjearthquakes " + "until:2014-05-" + str(i)
	update_hashtag("sjearthquakes","2014-05-" + str(i),400)
	#query = "sanjoseearthquakes " + "until:2014-05-" + str(i)
	update_hashtag("sanjoseearthquakes","2014-05-" + str(i),400)
while 1:
	#update_hashtag("obama until:2014-05-20",400)
	update_hashtag("obama","",400)
	update_hashtag("sjearthquakes","",400)
	update_hashtag("sanjoseearthquakes","",400)
	update_hashtag("san jose earthquakes","",400)
	update_hashtag("taiwan stabbing","",400)
	update_hashtag("news","",400)
	time.sleep(60)