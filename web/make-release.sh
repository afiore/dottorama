#! /bin/sh

git status|grep "working directory clean" > /dev/null

if [ $? -eq 0 ] 
  then
    echo "Git index is clean, going ahead"
  else
    echo "You have uncommited changes; commit first, or you might loose data!"
    exit 1
fi


cake build && cake minify
timestamp=`coffee -e 'console.info (+ new Date)'`
tmpdir="/tmp/${timestamp}-public"
releasename=`cake release-name`

echo "git add js/*.js"
echo "git commit -m 'built new release: ${releasename}'"
echo "git tag -a ${releasename}"

cp -r public $tmpdir
git checkout gh-pages
cd .. 
pwd
cp -r $tmpdir/* .

mv index-production.html index.html
# git commit -a -m "pushing new release: #{v}"
