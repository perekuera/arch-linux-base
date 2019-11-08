#!/bin/bash

read -p "Enter proxy host:port > " PROXY_HOST_PORT

read -p "Enter user:password > " USER_PASSWORD

if [ "$USER_PASSWORD" = ""]; then
	export http_proxy="http://$PROXY_HOST_PORT/"
	export https_proxy="http://$PROXY_HOST_PORT/"
	export ftp_proxy="http://$PROXY_HOST_PORT/"
else
	export http_proxy="http://$USER_PASSWORD@$PROXY_HOST_PORT/"
	export https_proxy="http://$USER_PASSWORD@$PROXY_HOST_PORT/"
	export ftp_proxy="http://$USER_PASSWORD@$PROXY_HOST_PORT/"
fi

echo $http_proxy
echo $https_proxy
echo $ftp_proxy

