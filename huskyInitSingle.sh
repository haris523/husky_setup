#!/usr/bin/env bash

echo 'Creating husky files'

touch .lintstagedrc
echo '{
    "src/**/*{.tsx,.ts,.js,.jsx}": "eslint --fix --max-warnings=0"
}'> .lintstagedrc

if [ ! -d "./.husky" ] 
then
  # create folder .husky
  mkdir .husky
fi

# create file precommit
touch .husky/pre-commit
# add content to precommit
echo '#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

yarn run lint-staged
'> .husky/pre-commit
# in husky add folder _ 
cd .husky
if [ ! -d "./_" ] 
then
mkdir _
fi

touch _/husky.sh
touch _/.gitignore
echo "*">./_/.gitignore
echo '#!/usr/bin/env sh
if [ -z "$husky_skip_init" ]; then
  debug () {
    if [ "$HUSKY_DEBUG" = "1" ]; then
      echo "husky (debug) - $1"
    fi
  }

  readonly hook_name="$(basename -- "$0")"
  debug "starting $hook_name..."

  if [ "$HUSKY" = "0" ]; then
    debug "HUSKY env variable is set to 0, skipping hook"
    exit 0
  fi

  if [ -f ~/.huskyrc ]; then
    debug "sourcing ~/.huskyrc"
    . ~/.huskyrc
  fi

  readonly husky_skip_init=1
  export husky_skip_init
  sh -e "$0" "$@"
  exitCode="$?"

  if [ $exitCode != 0 ]; then
    echo "husky - $hook_name hook exited with code $exitCode (error)"
  fi

  if [ $exitCode = 127 ]; then
    echo "husky - command not found in PATH=$PATH"
  fi

  exit $exitCode
fi
'>./_/husky.sh

cd ..


echo 'Installing packages'
yarn add husky
yarn add lint-staged -D

echo 'Package installs done'

#!/usr/bin/env bash

echo 'Adding postinstall script'

input="./package.json"
postinstallExists=false
newPostinstallLine=""

while IFS= read -r line
do
if [[ $line == *"husky install"* ]]; then
echo 'Finished adding postinstall script'
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
