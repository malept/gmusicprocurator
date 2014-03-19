#!/bin/bash

BASE_DIR=`dirname "$0"`
GMP_DIR="${BASE_DIR}"/gmusicprocurator
STATIC_DIR="${GMP_DIR}"/static
SCSS_DIR="${STATIC_DIR}"/scss
MAIN_OUT_CSS="${SCSS_DIR}"/main.out.css

flake8 --exclude=static "${GMP_DIR}"
coffeelint "${STATIC_DIR}"/cs
scss --style expanded "${SCSS_DIR}"/main.scss "${MAIN_OUT_CSS}"
csslint "${MAIN_OUT_CSS}"
