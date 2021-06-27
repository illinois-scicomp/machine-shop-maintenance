#! /bin/bash

# https://stackoverflow.com/a/35721111
docker images --no-trunc --format '{{.ID}} {{.CreatedSince}}' \
    | grep ' months' | awk '{ print $1 }' \
    | xargs --no-run-if-empty docker rmi
