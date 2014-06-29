#!/bin/bash -e

BASE_DIR=`dirname "$0"`
GMP_DIR="${BASE_DIR}"/gmusicprocurator
STATIC_DIR="${GMP_DIR}"/static
SCSS_DIR="${STATIC_DIR}"/scss
MAIN_OUT_CSS="${SCSS_DIR}"/main.out.css

set -x

if [[ -z "$NO_PYTHON" ]]; then
    flake8 "${GMP_DIR}"
    pep257 gmusicprocurator
    python setup.py check --metadata --restructuredtext --strict
fi

if [[ -z "$NO_FRONTEND" ]]; then
    coffeelint -f "${BASE_DIR}"/.coffeelint.json "${STATIC_DIR}"/cs
    scss-lint -e '*.css' "${SCSS_DIR}"
    scss --style expanded "${SCSS_DIR}"/main.scss "${MAIN_OUT_CSS}"
    csslint "${MAIN_OUT_CSS}"
    python -m gmusicprocurator assets build --no-cache
fi
