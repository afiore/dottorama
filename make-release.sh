#! /bin/sh

git status|grep "working directory clean" > /dev/null

if [ $? -eq 0 ] 
  then
    echo "Git index is clean, going ahead"
  else
    echo "You have uncommited changes; commit first, or you might loose data!"
    exit 1
fi

cd web
#cake build && cake minify
timestamp=`coffee -e 'console.info (+ new Date)'`
tmpdir="/tmp/${timestamp}-public"
releasename=`cake release-name`

echo "git add js/*.js"
echo "git commit -m 'built new release: ${releasename}'"
echo "git tag -a ${releasename}"
stasis

echo "copying tmpdir:${tmpdir}"
cp -r public $tmpdir
cd ..

git checkout gh-pages
rm -rf *
cp -r $tmpdir/* .
mv index-production.html index.html
# git commit -a -m "pushing new release: #{v}"
