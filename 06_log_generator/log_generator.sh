#!/bin/bash

function get_ip {
	echo -n "$(( $RANDOM % 255 )).$(( $RANDOM % 255 )).$(( $RANDOM % 255 )).$(( $RANDOM % 255 )) "
}

function get_response_code {
	echo -n "$(shuf -n 1 -e 200 200 200 201 201 400 401 403 404 500 501 502 503) "
	# 200 - OK
	# 201 - Created
	# 400 - Bad request
	# 401 - Unauthorized
  # 403 - Forbidden
	# 404 - Not Found
	# 500 - Internal Server Error
	# 501 - Not Implemented
	# 502 - Bad Gateway
  # 503 - Service Unavailable
}

function get_method {
	echo -n "\"$(shuf -n 1 -e GET GET GET POST PUT PATCH DELETE)\" "
}

function get_request {
	echo -n "\"$(shuf -n 1 -e "https://wikipedia.org/wiki/Quantum_mechanics"\
														"https://edu.21-school.ru/projects/$RANDOM"\
														"https://www.youtube.com/watch?v=$RANDOM"\
														"https://www.pornhub.com/view_video.php?viewkey=$RANDOM"\
														"https://www.scientificamerican.com/article/how-to-build-a-time-machine"\
														"https://unsplash.com/s/photos/angry_hedgehoges"\
														"https://meatspin.com/"\
														"https://www.wikihow.com/Make-a-Water-Bottle-Bong"\
														"https://www.psychiatry.ru/stat/285"\
														"https://www.quora.com/Help-my-stepmom-is-stuck-in-washing-machine-what-should-I-do"\
														"https://www.lgbtqnation.com/2022/04/homophobic-test"\
														"https://www.shutterstock.com/search/small-white-kittens"\
														"https://kr-gazeta.ru/proisshestviya/v-tsentre-kopeyska-ukrali-dva-zheleznykh-garazha/")\" "
}

function get_agent {
	echo "\"$(shuf -n 1 -e "Mozilla" "Google Chrome" "Opera" "Safari"\
												 "Internet Explorer" "Microsoft Edge"\
												 "Crawler and bot" "Library and net tool")\""
}

for (( i=0; i<5; i++))
do
	date=$(date --date="-$i days" +"%d%m%y")
	num_of_logs=$(shuf -n 1 -i 100-1000)
	
	for (( j=0; j<$num_of_logs; j++))
	do
		get_ip
		echo -n "- "
		echo -n "- "
		echo -n "$(date --date="-$i day +$j minutes +$(($RANDOM % 59)) seconds 07:00:00" +"[%d/%b/%Y:%T %z]") "
		get_method
		get_response_code
		echo -n "$(($RANDOM)) "
		get_request
		get_agent
	done >> $date.log
done

