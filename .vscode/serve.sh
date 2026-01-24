#!/bin/bash

# load envvars
if ! source .vscode/serve.env; then
    echo "PLS config mkdocs serve envvars in serve.env"
    exit 1
fi

# main entrypoint
if lsof -i :$MKDOCS_SERVE_PORT; then
    echo "mkdocs server is already listening at $MKDOCS_SERVE_PORT!"
    exit 0
else  # start mkdocs server
    mkdocs serve -a $MKDOCS_SERVE_HOST --livereload --dirty
fi