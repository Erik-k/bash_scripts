#!/bin/sh
# Created by: 	Kenneth Finnegan, 2012
# 		kennethfinnegan.blogspot.com
# Adapted by:	Connor Levens, 2013
#		thejumpseat.tumblr.com
# Further adapted by:   Erik Knechtel, 2014
#
# NewsAggregateMatrix
# Given the Twitter handles of various users (in this case, news agencies)
# and an ASCII printer (in particular, a dot matrix printer),
# this script can check for new tweets from those users and print them to the printer.
# Expected usage is to spin off data into the background (e.g. /dev/usb/lp0)
# or on a detachable screen to monitor current Twitter activity.

# User/users to monitor
# To monitor the activity of multiple users, Twitter's search API supports
# the following notation: from%3A---USER---+OR+
# where ---USER--- is the user's Twitter handle (without the @ symbol)
USEROFINTEREST="from%3Acnnbrk+OR+from%3ABreakingNews+OR+from%3ABBCBreaking+OR+from%3AWSJbreakingnews+OR+from%3ANBCNews+OR+from%3ACBSNews+OR+from%3AReuters+OR+from%3AAP"

# File paths
# Staging is needed since Twitter's search API deliver tweets in chronological
# order (newest -> oldest). To accurately depict the tweets on our output device,
# we use the "tac (cat backwards)" command to fix that.
# NOTE: OUTPUT_FILE is the device we're interested in outputting the tweets to
LATESTTWEET="/var/tmp/newsaggregatematrix.latest"
STAGING_FILE="/var/tmp/newsaggregatematrix.staging.$$"
OUTPUT_FILE="/dev/usb/lp0"

# Requests to Twitter's search API are made progressively slower as users make
# fewer updates to their timeline. INTERVAL is the number of seconds between
# requests. This means Twitter search API requests are really made at
# INTERVAL * REQUEST_LIMIT seconds
LATESTUSER=""
INTERVAL="10"
INTERVAL_LOW="10"
INTERVAL_HIGH="150"
REQUEST_LIMIT="5"

# Check to see if this is the first time this/theses user's/users's timeline/timelines
# has/have been monitored and preload the state file to monitor timeline progress
if [ ! -f $LATESTTWEET ]; then 
	echo 	"Generating new database to store news from eight (8) major news agencies:\n
1) AP\n
2) BBC Breaking News\n
3) Breaking News\n
4) CBS News\n
5) CNN Breaking News\n
6) NBC News\n
7) Reuters\n
8) WSJ Breaking News\n"
	curl -s "http://search.twitter.com/search.json?q=$USEROFINTEREST&rpp=$REQUEST_LIMIT&include_entries=true&result_type=recent" |
	grep -e "\"max_id_str\":\"[^\"]*\"" |
	awk -F'\"' '{print $4}' >$LATESTTWEET
else
	echo "The last event recorded was `cat $LATESTTWEET`"
fi

# Loop forever checking for tweets, printing them, and then sleeping
while true; do
	echo "Scanning for breaking news in ${INTERVAL}s intervals..."
	touch $STAGING_FILE
	# Form the twitter request
	curl -s "http://search.twitter.com/search.json?q=$USEROFINTEREST&rpp=$REQUEST_LIMIT&include_entries=true&result_type=recent&since_id=`cat $LATESTTWEET`" |
	sed 's/\\\"/#/g' | 
	sed 's/\`/#/g' | 
	sed 's/\\/#/g' | 
	tee /var/tmp/newsaggregatematrix.debug.$$ |
	# Parse out the user names, their tweets, and the latest id number
	grep -o 	-e "\"text\":\"[^\"]*\"" \
			-e "\"from_user\":\"[^\"]*\"" \
			-e "\"created_at\":\"[^\"]*\"" \
			-e "\"max_id_str\":\"[^\"]*\"" |
	# loop through the set of found items and handle them
	while read LINE; do
		FIELD="`echo $LINE | awk -F'\"' '{print $2}'`"
		VALUE="`echo $LINE | awk -F'\"' '{print $4}'`"
		
		if [ $FIELD = "from_user" ]; then
			# We know who sent the next tweet we see; save this
			LATESTUSER="$VALUE"
		elif [ $FIELD = "created_at" ]; then
			DATETIME="$VALUE"
		elif [ $FIELD = "text" ]; then
			# We've found a tweet; stage this with cooresponding username
			echo 	"\n$DATETIME: $VALUE\n
				SOURCE: $LATESTUSER\n
				=================================BREAKING NEWS==================================" >>$STAGING_FILE
			echo 	"$DATETIME: Breaking news found!"
		elif [ $FIELD = "max_id_str" ]; then
			# Save the highwater mark from this request so we can pick up
			# where we left off later.
			echo "$VALUE" >$LATESTTWEET
			echo "The latest breaking news event is now $VALUE\n========================================================"
		fi
	done

	# Count how many tweets we ended up with, print them, then update
	# the desired interval rate and sleep out the remainder of this
	# interval if we didn't happen to get a complete REQUEST_LIMIT of tweets
	TWEETSFOUND="`wc -l <$STAGING_FILE`"
	if [ $TWEETSFOUND = 0 ]; then	
		echo "Breaking news events found: $TWEETSFOUND"
	else
		echo "========================================================\nBreaking news events found: $TWEETSFOUND"
	fi

	# Reverse tweets into cronological order, and print them one by one
	tac $STAGING_FILE |
	while read LINE; do
		echo "$LINE" >$OUTPUT_FILE
		# Spread out printings so I can feel more popular and it seems less bursty
		# sleep "$INTERVAL"
	done
	rm $STAGING_FILE

	# Check to see if the request returned any breaking news
	# If not, slow down the requests
	if [ $TWEETSFOUND = "0" ]; then
		echo "Slowing down requests..."
		INTERVAL="$(($INTERVAL + 1))"
		if [ "$INTERVAL" -gt "$INTERVAL_HIGH" ]; then
			INTERVAL="$INTERVAL_HIGH"
		fi
	# If so, speed up the requests
	else
		echo "Speeding up requests..."
		INTERVAL="$(( $(( $INTERVAL / 2 )) + $(( INTERVAL_LOW / 2 )) ))"
	fi

	TIME_LEFT="$(( $(( $REQUEST_LIMIT - $TWEETSFOUND )) * $INTERVAL ))"

	# To avoid errors with Linux's sleep command, we retreive the absolute value
	# of $TIME_LEFT by multiplying $TIME_LEFT by itself, then square the product
	SLEEP="$( echo "sqrt ( $TIME_LEFT * $TIME_LEFT )" | bc -l )"

	sleep "$SLEEP"
done