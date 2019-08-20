#!/bin/sh

echo "Executing Racing app"
/app/racing

echo "Go to http://localhost/Racing.html to check the project documentation"
nginx -g 'daemon off;'


