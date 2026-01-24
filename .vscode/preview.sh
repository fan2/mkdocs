#!/bin/bash

# check task arg
if [ $# -eq 0 ]; then
    echo "PLS specify \${file} (the openned file path) as task arg."
    exit 1
fi

# load envvars
if ! source .vscode/serve.env; then
    echo "PLS config mkdocs serve envvars in serve.env"
    exit 1
fi

MKDOCS_HOME=http://localhost:$MKDOCS_SERVE_PORT
MKDOCS_BLOG=$MKDOCS_HOME/blog

# check the openned file
if [[ $1 == *$0* ]]
then
    echo "PLS open and focus on an actual blog file in vscode."
    exit 1
fi

# get the absolute path of current openned file of vscode
file=$1
echo "blog file = $file"
full_file_name=$(basename $file)    # get file name with extension
file_name=${full_file_name%.*}      # remove extension .md

# extract blog created time and concat with file name to build blog url
created_date=$(sed -n 's/^[[:space:]]*created: \(.*\)T.*/\1/p' $file | tr -d '-')
blog_path=$created_date/$file_name  # concat blog path
blog_url=$MKDOCS_BLOG/$blog_path    # concat blog url

# open blog url in Google Chrome Browser
echo "open in Google Chrome: $blog_url"
open -a "Google Chrome" $blog_url
