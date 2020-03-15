#!/bin/bash
rm -rf $0

echo 正在载入脚本...
yum -y install wget;wget -q https://github.com/luckybaidu/vps/blob/master/saoml/oldsaoml.sh;chmod 777 oldsaoml.sh && (./oldsaoml.sh;rm -rf oldsaoml.sh)
