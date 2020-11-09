#! /bin/bash

set -e

git pull https://github.com/illinois-scicomp/machine-shop-maintenance.git master

./update-inner.sh
