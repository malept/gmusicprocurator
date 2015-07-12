#!/bin/bash -e

BASE_DIR=`dirname "$0"`
GMP_DIR="${BASE_DIR}"/gmusicprocurator
STATIC_DIR="${GMP_DIR}"/static
SCSS_DIR="${STATIC_DIR}"/scss
MAIN_OUT_CSS="${SCSS_DIR}"/main.out.css
CFG_DIR="$HOME/.config/gmusicapi"
CFG_PATH="$CFG_DIR"/gmusicprocurator.cfg
NODE_BIN_DIR="${BASE_DIR}/node_modules/.bin"

set -x

if [[ -z "$NO_PYTHON" ]]; then
    flake8 "${GMP_DIR}"
    pep257 gmusicprocurator
    python setup.py check --metadata --restructuredtext --strict
fi

if [[ -z "$NO_FRONTEND" ]]; then
    "$NODE_BIN_DIR"/coffeelint -f "${BASE_DIR}"/.coffeelint.json "${STATIC_DIR}"/cs
    scss-lint -e '*.css' "${SCSS_DIR}"
    scss --style expanded "${SCSS_DIR}"/main.scss "${MAIN_OUT_CSS}"
    "$NODE_BIN_DIR"/csslint "${MAIN_OUT_CSS}"
    if [[ ! -f "$CFG_PATH" ]]; then
        mkdir -p "$CFG_DIR"
        echo 'GMP_OFFLINE_MODE = True' > "$CFG_PATH"
    fi
    GMP_OFFLINE_MODE=1 python -m gmusicprocurator assets build --no-cache
fi
