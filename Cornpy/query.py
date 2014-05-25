from TwitterAPI import TwitterAPI
import json
import time
from db import *
from py2neo import neo4j
graph_db = neo4j.GraphDatabaseService()

#update_hashtag("sjearthquakes",400)
#update_hashtag("sanjoseearthquakes",400)
#update_hashtag("san jose earthquakes",400)
#update_hashtag("c9",400)
#update_hashtag("obama",400)
#update_hashtag("taiwan stabbing",400)
#update_hashtag("news",400)
#print(return_sentiment("sjearthquakes"))
print(return_sentiment("obama"))
#print(return_sentiment("barack obama"))
#print(return_sentiment("taiwan stabbing"))
#print(return_sentiment("taiwan stabbing"))
#print(return_sentiment_hourly("obama"))