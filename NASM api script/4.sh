#!/bin/sh
rm -rf ./cookie*
rm -rf ./temp*
mkdir ./cookie
mkdir ./temp
ip="$(cat ./ip)"

curl -s -k -D ./cookie/apiuser_cookie https://apiuser:apiuser@$ip:8443/airframe/main/v1/login -w "%{http_code}" -o ./temp/res.txt > ./temp/sta.txt
sta="$(cat ./temp/sta.txt)"
if [ "$sta" = "200" ]; then
echo "200 GET apiuser_cookie PASS"
else
echo $sta
echo "NOT 200 GET apiuser_cookie FAIL"
exit 1
fi
sta=""

timestamp=`date +%s`
json={\"username\":\"Api$timestamp\",\"password\":\"Api\",\"userGroup\":\"admin\",\"enabled\":false}
curl -s -k -b ./cookie/apiuser_cookie -X POST https://$ip:8443/airframe/main/v1/user/create/local -d $json -H 'Content-Type: application/json' -w "%{http_code}" -o ./temp/res.txt > ./temp/sta.txt
sta="$(cat ./temp/sta.txt)"
res="$(cat ./temp/res.txt)"
if [ "$sta" = "200" ]; then
echo "200 POST /create/local PASS"
else
echo $sta
echo "NOT 200 POST /create/local FAIL"
exit 1
fi
sta=""

userId="$(cat ./temp/res.txt| jq .userId)"
echo userId=$userId

if [ "$userId" > "2" ]; then
echo "userId > 2 PASS"
else
echo "userId > 2 FAIL"
exit 1
fi
res=""
json=""


curl -s -k -b ./cookie/apiuser_cookie https://$ip:8443/airframe/main/v1/user/all -w "%{http_code}" -o ./temp/res.txt > ./temp/sta.txt
sta="$(cat ./temp/sta.txt)"
res="$(cat ./temp/res.txt)"
if [ "$sta" = "200" ]; then
echo "200 GET user/all PASS"
else
echo "NOT 200 GET user/all FAIL"
exit 1
fi
sta=""

let key=`echo $res | jq length`-1
if [ `echo $res | jq .[$key].userId` = $userId ]; then
echo "[$key].userId=$userId PASS"
else
echo "[$key].userId=$userId FAIL"
exit 1
fi
if [ `echo $res | jq .[$key].username` = \"Api$timestamp\" ]; then
echo "[$key].username=Api$timestamp PASS"
else
echo "[$key].username=Api$timestamp FAIL"
exit 1
fi
key=""

curl -s -k -b ./cookie/apiuser_cookie https://$ip:8443/airframe/main/v1/user/$userId -w "%{http_code}" -o ./temp/res.txt > ./temp/sta.txt
sta="$(cat ./temp/sta.txt)"
res="$(cat ./temp/res.txt)"
if [ "$sta" = "200" ]; then
echo "200 GET /user/$userId PASS"
else
echo $sta
echo "NOT 200 GET /user/$userId FAIL"
exit 1
fi
sta=""
if [ `echo $res | jq .userId` = $userId ]; then
echo ".userId=$userId PASS"
else
echo ".userId=$userId FAIL"
exit 1
fi
if [ `echo $res | jq .username` = \"Api$timestamp\" ]; then
echo ".username=Api$timestamp PASS"
else
echo ".username=Api$timestamp FAIL"
exit 1
fi
if [ `echo $res | jq .displayName` = \"Api$timestamp\" ]; then
echo ".displayName=Api$timestamp PASS"
else
echo ".displayName=Api$timestamp FAIL"
exit 1
fi
if [ `echo $res | jq .enabled` = "false" ]; then
echo ".enabled=false PASS"
else
echo ".enabled=false FAIL"
exit 1
fi

curl -s -k -D ./cookie/Api$timestamp\_cookie https://Api$timestamp:Api@$ip:8443/airframe/main/v1/login -w "%{http_code}" -o ./temp/res.txt > ./temp/sta.txt
sta="$(cat ./temp/sta.txt)"
if [ "$sta" = "403" ]; then
echo "403 GET Api$timestamp"_cookie" PASS"
else
echo $sta
echo "NOT 403 GET Api$timestamp"_cookie" FAIL"
exit 1
fi
sta=""

curl -s -k -b ./cookie/apiuser_cookie -X DELETE https://$ip:8443/airframe/main/v1/user/$userId -w "%{http_code}" -o ./temp/res.txt > ./temp/sta.txt
sta="$(cat ./temp/sta.txt)"
res="$(cat ./temp/res.txt)"
if [ "$sta" = "204" ]; then
echo "204 use apiuser_cookie DELETE /user/$userId PASS"
else
echo $sta
echo "NOT 204 use apiuser_cookie DELETE /user/$userId FAIL"
exit 1
fi
sta=""
timestamp=""
userId=""
