#!/bin/bash

DIR=$(dirname $0)

exec "$DIR"/venv/bin/python3 "$DIR"/param_tool.py $@

