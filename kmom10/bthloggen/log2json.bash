# Pattern for getting the ip-adresses.
IP='([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})'

# Pattern for getting the URLs.
URL='((http|HTTP|https|HTTPS)\:\/\/[a-zA-z.]+)'

# Pattern for getting the day.
DAY='([0-9]{1,2})'

# Pattern for getting the month.
MONTH='([A-Za-z]{3})'

# Pattern for getting the time.
TIME='([0-9:]{8})'

# Format to JSON style
IP_FORMAT='\n\t{\n\t\t\"ip\": \"\1\",'

# Format to JSON style
DAY_FORMAT='\n\t\t\"day\": \"\2\",'

# Format to JSON style
MONTH_FORMAT='\n\t\t\"month\": \"\3\",'

# Format to JSON style
TIME_FORMAT='\n\t\t\"time\": \"\4\",'

# Format to JSON style
URL_FORMAT='\n\t\t\"url\": \"\5\"'

# File to use.
FILE='../access-50k.log'

# File to write the result to.
OUTPUT='data/log.json'

# The regex result.
res=$(sed -En 's/'\
'^'"$IP"'.*\['"$DAY"'\/'"$MONTH"''\
'\/[0-9:]{5}'"$TIME"'.*'"$URL"'.*/'\
''"$IP_FORMAT"''\
''"$DAY_FORMAT"''\
''"$MONTH_FORMAT"''\
''"$TIME_FORMAT"''\
''"$URL_FORMAT"''\
"\n\t},/p" $FILE)

# Output the result, after a opening bracket [.
printf "[ %s" "$res" > $OUTPUT

# Remove last comma and replace it with a newline and closing bracket ].
sed -i '$ s/.$/\n]/' $OUTPUT
