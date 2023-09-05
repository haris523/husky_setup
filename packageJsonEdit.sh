#!/usr/bin/env bash

echo 'Adding postinstall script'

input="./package.json"
postinstallExists=false
newPostinstallLine=""

while IFS= read -r line
do
if [[ $line == *"husky install"* ]]; then
echo 'Finished adding postinstall script'
yarn
exit
fi
done < "$input"
while IFS= read -r line
do
if [[ $line == *"postinstall"* ]]; then
        postinstallExists=true
        newPostinstallLine="${line:0:20}"
        newPostinstallLine+='husky install && '
        newPostinstallLine+="${line:20}"
        newPostinstallLine+="12345"
fi


done < "$input"


echo $newPostinstallLine
mojstr=""
while IFS= read -r line
do
if [[ $line == *"postinstall"* ]]; then
echo "postinstall exists"
        mojstr+=$newPostinstallLine
        else
mojstr+="$line"
mojstr+="12345"
fi

if [[ $line == *"scripts"* ]]; then
        #echo "line  $line"
        if($postinstallExists); then
                echo "postinstall exists"
        else
                 mojstr+='"postinstall": "husky install",'
        #jump a line
        mojstr+="12345"
        fi
fi
done < "$input"

echo 'Finished adding postinstall script'

touch package2.json
echo $mojstr>package2.json
touch package3.json
sed 's/12345/\n/g' package2.json > package3.json
rm package2.json
mv package3.json package.json
