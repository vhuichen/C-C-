#!/usr/bin/env bash

# 2024-08-12 暂不支持 Python 3.11 版本

python3 -m pip install --upgrade pip wheel

# Get and build ta-lib
function install_ta_lib()
{
    export HOMEBREW_NO_AUTO_UPDATE=true
    brew install ta-lib
}
function ta_lib_exists()
{
    ta-lib-config --libs > /dev/null
}
ta_lib_exists || install_ta_lib

python3 -m pip install -r requirements.txt
