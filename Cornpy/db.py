from TwitterAPI import TwitterAPI
from textblob import TextBlob
import json
import datetime
import time
import calendar
from math import *
from py2neo import neo4j
graph_db = neo4j.GraphDatabaseService()

def cache_tweet(hashtag,tweet,user,timestamp,index,id,prop_node):
	nodes = index.get("id",id)
	if len(nodes) == 1:
		return 0
	elif nodes:
		raise LookupError("Multiple tweets found")
	else:
		wiki = TextBlob(tweet)
		if wiki.polarity > 0:
			rating = "positive"
			ratingvar = 0
		elif wiki.polarity < 0:
			rating = "negative"
			ratingvar = 2
		else:
			rating = "neutral"
			ratingvar = 1
		#positive,neutral,negative,relative
		node = graph_db.get_or_create_indexed_node(hashtag,"id", id, {"id": id, "tweet": tweet,"user": user,"timestamp": timestamp,"rating": rating})
		day = str(int(floor(int(timestamp)/86400)))
		#print(prop_node)
		if prop_node["day_" + day] == None:
			#print("day_" + day)
			prop_node["day_" + day] = [0,0,0]
		#positive,neutral,negative,relative
		temp = prop_node["day_" + day]
		temp[ratingvar] += 1
		prop_node.update_properties({"day_" + day : temp})
		#print(node["timestamp"])
		#print(prop_node["day_" + day])
		return node._id

def sentiment(tweet):
	return datum_box.twitter_sentiment_analysis(tweet)

def update_hashtag(hashtag,timerange,count):
	hashtag = hashtag.upper()
	hashtag = preprocess(hashtag)
	index = graph_db.get_or_create_index(neo4j.Node, hashtag)
	prop_node = graph_db.get_or_create_indexed_node(hashtag,"node", "properties")
	#statnode = graph_db.get_or_create_indexed_node(hashtag,"stat", "positive", rating_dict)
	#statnode = graph_db.get_or_create_indexed_node(hashtag,"stat", "neutral", rating_dict)
	#statnode = graph_db.get_or_create_indexed_node(hashtag,"stat", "negative", rating_dict)
	access_token_key = "1378990573-hZYtvwAORDCUqhQofYU8omkyLptgHWloLWe95Wd"
	access_token_secret = "dqGwoRDUgOdocVZoUxRvql4j4oQ92irCCcqNei9QqYYzt"
	consumer_key = "el3Br6Dl3eoBDuEVyKz1yogh0"
	consumer_secret = "hYw5LuZYq6oF6SYQsvEOJ0hZCOTs90tStxzIWhgINqXKXBlGo2"

	api = TwitterAPI(consumer_key, consumer_secret, access_token_key, access_token_secret)
	query = hashtag+'%20-RT'
	if timerange != "":
		query += " until:"
		query += timerange
	#print(query)
	
	r = api.request('search/tweets', {'q':query, 'count':count})
	for item in r.get_iterator():
		#print(json.dumps(item))
		#hashtags = item["entities"]["hashtags"]
		tweet = item["text"]
		id = item["id"]
		user = item["user"]["screen_name"]
		timestamp = item["created_at"]
		#print(timestamp)
		timestamp = timestamp.split(' ')
		#if timestamp[4] != "+0000":
			#print(timestamp)
		timestamp2 = timestamp[0]+" "+timestamp[1]+" "+timestamp[2]+" "+timestamp[3]+" "+timestamp[5]
		pattern = '%a %b %d %H:%M:%S %Y'
		epoch = str(int(time.mktime(time.strptime(timestamp2, pattern))))
		#print(epoch)
		node = cache_tweet(hashtag,tweet,user,epoch,index,id,prop_node)
		if node == 0:
			break

def return_sentiment(hashtag):
	orig = hashtag
	hashtag = hashtag.upper()
	hashtag = preprocess(hashtag)

	results_positive = {"total":0}
	for i in range(0,7):
		results_positive[str(i)] = 0

	results_neutral = {"total":0}
	for i in range(0,7):
		results_neutral[str(i)] = 0

	results_negative = {"total":0}
	for i in range(0,7):
		results_negative[str(i)] = 0

	results_relative = {"total":0}
	for i in range(0,7):
		results_relative[str(i)] = 0

	index = graph_db.get_or_create_index(neo4j.Node, hashtag)
	nodes = index.query("node:*")
	today = int(time.time()) + 4 * 3600

	for item in nodes:
		for i in range(0,7):
			day = int(floor((int(today)-86400*i)/86400))
			res = item["day_"+str(day)]
			if res == None:
				res = [0,0,0]
			results_positive[str(i)] = res[0]
			results_negative[str(i)] = res[2]
			results_neutral[str(i)] = res[1]
			results_relative[str(i)] = res[0] - res[2]

			results_positive["total"] += results_positive[str(i)]
			results_negative["total"] += results_negative[str(i)]
			results_neutral["total"] += results_neutral[str(i)]
			results_relative["total"] += results_relative[str(i)]

	total_stats = {"positive": results_positive["total"],"negative": results_negative["total"],"neutral": results_neutral["total"],"relative": results_relative["total"]}
	#total_stats[0] = {"positive": results_positive["total"]}
	#total_stats[1] = {"negative": results_negative["total"]}
	#total_stats[2] = {"neutral": results_neutral["total"]}
	#total_stats[3] = {"relative": results_relative["total"]}

	data = dict()
	for i in range(0,7):
		#date = datetime.datetime.fromtimestamp(today-86400*i).strftime('%m-%d-%Y')
		date = int(floor((int(today)-86400*i)/86400) * 86400)
		data[i] = {"date":date, "positive":results_positive[str(i)], "neutral":results_neutral[str(i)], "negative":results_negative[str(i)], "relative": results_relative[str(i)]}

	results = {"success": True, "keyword": orig, "statistics":total_stats, "data":data}
	return json.dumps(results)

def return_sentiment_hourly(hashtag):
	orig = hashtag
	hashtag = hashtag.upper()
	hashtag = preprocess(hashtag)

	results_positive = {"total":0}
	for i in range(0,24):
		results_positive[str(i)] = 0

	results_neutral = {"total":0}
	for i in range(0,24):
		results_neutral[str(i)] = 0

	results_negative = {"total":0}
	for i in range(0,24):
		results_negative[str(i)] = 0

	results_relative = {"total":0}
	for i in range(0,24):
		results_relative[str(i)] = 0

	index = graph_db.get_or_create_index(neo4j.Node, hashtag)
	nodes = index.query("id:*")
	today = int(time.time()) + 4 * 3600
	#print(today)

	for item in nodes:
		time2 = item["timestamp"]
		hour = int(floor(int(today)/3600 - floor(int(time2)/3600)))
		#print(hour)
		if item["rating"] == "positive":
			results_positive["total"] += 1
			results_relative["total"] += 1
			if hour < 24:
				results_positive[str(hour)] += 1
				results_relative[str(hour)] += 1
		elif item["rating"] == "negative":
			results_negative["total"] += 1
			results_relative["total"] -= 1
			if hour < 24:
				results_negative[str(hour)] += 1
				results_relative[str(hour)] -= 1
		else:
			results_neutral["total"] += 1
			if hour < 24:
				results_neutral[str(hour)] += 1
	total_stats = {"positive": results_positive["total"],"negative": results_negative["total"],"neutral": results_neutral["total"],"relative": results_relative["total"]}
	#total_stats[0] = {"positive": results_positive["total"]}
	#total_stats[1] = {"negative": results_negative["total"]}
	#total_stats[2] = {"neutral": results_neutral["total"]}
	#total_stats[3] = {"relative": results_relative["total"]}

	data = dict()
	for i in range(0,24):
		#date = datetime.datetime.fromtimestamp(today-3600*i).strftime('%m-%d-%Y %H')
		#hour = int(floor(int(today)/3600 - floor(int(time2)/3600)))
		date = int(floor((int(today)-3600*i)/3600) * 3600)
		data[i] = {"date":date, "positive":results_positive[str(i)], "neutral":results_neutral[str(i)], "negative":results_negative[str(i)], "relative": results_relative[str(i)]}

	results = {"success": True, "keyword": orig, "statistics":total_stats, "data":data}
	return json.dumps(results)

def preprocess(text):
	text = text.split(' ')
	search = text[0]
	j = 0
	for i in text:
		if j > 0:
			search += "&"
			search += i
		j += 1
	return search