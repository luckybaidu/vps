#!/bin/bash
db_host="localhost"
db_user="root"
db_pass="MySQLPass"
db_port="3306"

username=$common_name
str=$(mysql -h$db_host -P$db_port -uroot -p$db_pass -e "SELECT \`id\`,\`iuser\`,\`isent\`,\`irecv\`,\`pass\` FROM ov.\`openvpn\` WHERE \`iuser\` = \"$username\";" | tail -n 1)

id=$(echo $str | awk {'print$1'})
user=$(echo $str | awk {'print$2'})
send=$(echo $str | awk {'print$3'})
rec=$(echo $str | awk {'print$4'})
pass=$(echo $str | awk {'print$5'})

userecv=$[$rec+$bytes_sent]
usesend=$[$send+$bytes_received]

mysql -h$db_host -P$db_port -uroot -p$db_pass -e "UPDATE ov.\`openvpn\` SET \`irecv\` = \"$userecv\", \`isent\` = \"$usesend\" WHERE \`id\` = \"$id\";"
mysql -h$db_host -P$db_port -uroot -p$db_pass -e "UPDATE ov.\`openvpn\` SET \`online\` = 0 WHERE \`id\` = \"$id\";"
mysql -h$db_host -P$db_port -uroot -p$db_pass -e "SET NAMES utf8;INSERT INTO ov.\`login_log\` (\`user\`,\`pass\`,\`info\`,\`time\`) VALUES (\"$username\",\"$pass\",\"用户退出\",\"$(date +%s)\");"
	

	

