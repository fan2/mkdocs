#!/bin/bash

# check task args
if [ $# -eq 0 ]; then
    echo "PLS specify \${file} (the openned file path) as task arg."
    exit 1
fi

# load envvars
if ! source .vscode/serve.env; then
    echo "PLS config mkdocs serve envvars in serve.env"
    exit 1
fi

# access via localhost or specific IP address
MKDOCS_BLOG=http://$MKDOCS_PREVIEW_ADDR/blog

script=$0   # sh relative to .vscode
file=$1     # absolute path of current open file
echo "current_open_file=$file"

# avoid current sh
if [[ $file == *$script ]]
then
    echo "$script does not support previewing."
    exit 1
fi

# check path & suffix extension
blog_posts_path=/docs/blog/posts/
if [[ ! $file =~ $blog_posts_path ]]; then
    echo "Only support preview blog under $blog_posts_path"
    exit 1
elif [[ $file != *.md ]]; then
    echo "Only support preview blog suffixed with md"
    exit 1
fi

blog_post=${file#*"$blog_posts_path"}
echo "blog_post=$blog_post"
full_file_name=$(basename "$file")  # get file name with extension
file_name=${full_file_name%.*}      # remove extension .md

# extract blog created time and concat with file name to build blog url
# consider two date formats: complete ISO datetime and simple date
created_date=$(awk '/^[[:space:]]+created:/ {gsub(/-/, "", $2); gsub(/T.*/, "", $2); print $2}' "$file")
# created_date=$(sed -n -E 's/^[[:space:]]+created:[[:space:]]*//p' "$file" | sed 's/T.*//' | tr -d '-')
blog_path=$created_date/$file_name  # concat blog path
blog_url=$MKDOCS_BLOG/$blog_path    # concat blog url

# open blog url in Google Chrome Browser under macOS
echo "preview in Google Chrome: $blog_url"
open -a "Google Chrome" "$blog_url"
