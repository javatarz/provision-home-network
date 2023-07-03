#!/bin/sh

set +e

env_name=$(cat .python-version)
target_version="3.10.12"

echo
echo "> Checking if python version $target_version is installed in pyenv"
2>/dev/null pyenv versions | grep $target_version 1>/dev/null
if [ $? -ne 0 ]; then
  echo ">> Installing $target_version in pyenv"
  pyenv install $target_version
fi

echo
echo "> Checking if virtualenv $env_name exists"
2>/dev/null pyenv virtualenvs | grep $env_name 1>/dev/null
if [ $? -ne 0 ]; then
  echo ">> Creating virtualenv $env_name with version $target_version"
  pyenv virtualenv $target_version $env_name
fi

echo
echo "> Installing dependencies"
pip install --upgrade pip -r ./scripts/requirements.txt 1>/dev/null

echo
echo "> Environment has been setup"
