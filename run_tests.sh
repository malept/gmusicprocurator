#!/bin/bash

BASE_DIR=`dirname "$0"`

flake8 "${BASE_DIR}"/gmusicprocurator
coffeelint "${BASE_DIR}"/gmusicprocurator/static/cs
