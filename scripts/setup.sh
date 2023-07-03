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
echo "> Installing ansible modules"
ansible-galaxy collection install $(cat ./scripts/ansible-modules.txt)

remote_host="jetblade.local"
echo
echo "> Setting up SSH key for $remote_host"
remote_port="22"
remote_username="debian"
local_ssh_key_path="$HOME/.ssh/keys/jetblade.rsa"

if [[ -f "$local_ssh_key_path" ]]; then
  echo ">> SSH key already exists locally and thus will not be installed remotely"
else
  echo ">> SSH key does not exist locally. Generating a new SSH key pair..."
  ssh-keygen -t rsa -N '' -f "$local_ssh_key_path"
  echo ">> SSH key pair generated."

  ssh -p "$remote_port" "$remote_username"@"$remote_host" \
  "mkdir -p ~/.ssh && \
  echo \$(cat >> ~/.ssh/authorized_keys) && \
  chmod 700 ~/.ssh && chmod 600 ~/.ssh/*" < "$local_ssh_key_path.pub"

  echo ">> SSH key installed on the remote machine."
fi
echo ">> Writing fresh jetblade.config"
rm ~/.ssh/envs/jetblade.config
echo "Host jetblade.local\n  HostName jetblade.local\n  User debian\n  IdentityFile ~/.ssh/keys/jetblade.rsa" >> ~/.ssh/envs/jetblade.config

echo
echo "> Environment has been setup"
