#!/bin/bash
db_host="localhost"
db_user="root"
db_pass="MySQLPass"
db_port="3306"

c=$(echo $username | grep -E "'|\"|;" | wc -l)

if [ $c != 0 ]; then
	exit 1
fi

c2=$(echo $password | grep -E "'|\"|;" | wc -l)

if [ $c2 != 0 ]; then
	exit 1
fi

c3=$(echo "$username" | grep " " | wc -l)

if [ $c3 != 0 ]; then
    exit 1
fi


str=$(mysql -h$db_host -P$db_port -uroot -p$db_pass -e "SELECT \`id\`,\`iuser\`,\`isent\`,\`irecv\`,\`maxll\`,\`pass\`,\`i\`,\`starttime\`,\`endtime\`,\`tian\`,\`online\` FROM ov.\`openvpn\` WHERE \`iuser\` = \"$username\" AND \`pass\` = \"$password\";" | tail -n 1)

if [ "$str" = "" ]; then

	mysql -h$db_host -P$db_port -uroot -p$db_pass -e "SET NAMES utf8;INSERT INTO ov.\`login_log\` (\`user\`,\`pass\`,\`info\`,\`time\`) VALUES (\"$username\",\"$password\",\"用户名或密码错误\",\"$(date +%s)\");"
	
	exit 1
	
else
	id=$(echo $str | awk {'print$1'})
	user=$(echo $str | awk {'print$2'})
	send=$(echo $str | awk {'print$3'})
	rec=$(echo $str | awk {'print$4'})
	max=$(echo $str | awk {'print$5'})
	pass=$(echo $str | awk {'print$6'})
	status=$(echo $str | awk {'print$7'})
	start=$(echo $str | awk {'print$8'})
	end=$(echo $str | awk {'print$9'})
	day=$(echo $str | awk {'print$10'})
	online=$(echo $str | awk {'print$11'})

	if [ $end = 0 ]; then
	
		mysql -h$db_host -P$db_port -uroot -p$db_pass -e "UPDATE ov.\`openvpn\` SET \`endtime\` = $day * 86400 + $(date +%s) WHERE \`id\` = $id;"
		
	fi
	
#	if [ $online = 1 ]; then
#	
#		mysql -h$db_host -P$db_port -uroot -p$db_pass -e "SET NAMES utf8;INSERT INTO ov.\`login_log\` (\`user\`,\`pass\`,\`info\`,\`time\`) VALUES (\"$username\",\"$password\",\"用户二次登陆，已禁止\",\"$(date +%s)\");"
#		exit 1
#		
#	fi
	
	if [ "$status" -eq "1" -a "$[$send + $rec]" -lt "$max" ]; then
	
			mysql -h$db_host -P$db_port -uroot -p$db_pass -e "SET NAMES utf8;INSERT INTO ov.\`login_log\` (\`user\`,\`pass\`,\`info\`,\`time\`) VALUES (\"$username\",\"$password\",\"登录成功\",\"$(date +%s)\");"
			
			mysql -h$db_host -P$db_port -uroot -p$db_pass -e "UPDATE ov.\`openvpn\` SET \`online\` = 1 WHERE \`id\` = $id;"
		
			exit 0
		
		else

			mysql -h$db_host -P$db_port -uroot -p$db_pass -e "SET NAMES utf8;INSERT INTO ov.\`login_log\` (\`user\`,\`pass\`,\`info\`,\`time\`) VALUES (\"$username\",\"$password\",\"账号已关闭或流量已用完\",\"$(date +%s)\");"
	
			exit 1
		
	fi
	
fi
