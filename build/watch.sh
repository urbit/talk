#! /bin/echo "use 'npm run watch' to run this script"
mkdir -p desk/web/talk/; 
watchify -v -o desk/web/talk/main.js js/main.coffee & 
node-sass -w -o desk/web/talk/ css/main.scss main.css