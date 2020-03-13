#!/bin/sh
#==========================#
###### Author: CuteBi ######
#==========================#

option() {
    echo -n $echo_opt_e "1. 安装项目\n2. 卸载项目\n请输入选项(默认为1): "
    read install_opt
    echo "$install_opt"|grep -q '2' && task_type='uninstall' || task_type='install'
    echo -n $echo_opt_e "可选项目:
    \r1. squid
    \r2. TinyProxy
    \r3. cns
    \r4. SSR
    \r5. v2ray
    \r6. lamy
    \r请选择项目(多个用空格隔开): "
    read build_projects
    echo -n '后台运行吗?(输出保存在builds.out文件)[n]: '
    read daemon_run
}

getAbi() {
    abi=`uname -m`
    if echo "$abi"|grep -Eq 'i686|i386'; then
        abi="32"
    elif echo "$abi"|grep -Eq 'armv7|armv6'; then
        abi="arm"
    elif echo "$abi"|grep -Eq 'armv8|aarch64'; then
        abi="arm64"
    #mips使用le版本
    elif echo "$abi"|grep -q 'mips64'; then
        abi="mips64le"
    elif echo "$abi"|grep -q 'mips'; then
        abi="mipsle"
    else
        abi="64"
    fi
}

squid_set() {
    echo -n '请输入squid端口: '
    read squid_port
    echo -n "请输入squid代理头域(默认为 'Meng'): "
    read squid_proxyHeader
}

TinyProxy_set() {
    echo -n '请输入TinyProxy端口: '
    read TinyProxy_port
    echo -n "请输入TinyProxy代理头域(默认为 'Meng'): "
    read TinyProxy_proxyHeader
}

cns_set() {
    echo -n '请输入cns端口: '
    read cns_port
    echo -n '请输入cns加密密码(默认不加密): '
    read cns_encrypt_password
    echo -n "请输入cns的udp标识(默认: 'httpUDP'): "
    read cns_udp_flag
    echo -n "请输入cns代理头域(默认: 'Meng'): "
    read cns_proxy_key
    echo -n '请输入cns安装目录(默认/usr/local/cns): '
    read cns_install_directory
}

SSR_set() {
    echo -n '请输入SSR端口: '
    read SSR_port
    echo -n '请输入SSR加密模式(默认rc4-md5): '
    read SSR_encryption_method
    echo -n '请输入SSR加密协议(默认auth_sha1_v4): '
    read SSR_protocol
    echo -n '请输入SSR混淆(默认http_simple): '
    read SSR_obfs
    echo -n '请输入SSR密码: '
    read SSR_password
}

v2ray_set() {
    echo -n '请输入v2ray安装目录(默认/usr/local/v2ray): '
    read v2ray_install_directory
    echo -n '请输入v2ray http端口(留空不使用): '
    read v2ray_http_port
    echo -n '请输入v2ray webSocket端口(留空不使用): '
    read v2ray_ws_port
    echo -n '请输入v2ray mKCP端口(留空不使用): '
    read v2ray_mkcp_port
    if [ -n "$v2ray_ws_port" ]; then
        echo -n '请输入v2ray WebSocket请求头的Path(默认/): '
        read v2ray_ws_path
        echo -n '请输入v2ray WebSocket tls域名(留空不开启tls): '
        read v2ray_ws_tls_domain
    fi
    echo -n $echo_opt_e "0. github(官方源)
    \r1. coding(国内,压缩)
    \r2. tencent(国内,压缩)
    \r请输入v2ray下载源(默认为github): "
    read v2ray_source
}

lamy_set() {
    echo -n '请输入lamy监听端口: '
    read lamy_port
    echo -n '请输入lamy转发端口: '
    read lamy_forward_port
    echo -n '请输入lamy验证(默认mmb): '
    read lamy_secret
    echo -n '请输入安装目录(默认/usr/bin): '
    read lamy_dir
}

squid_task() {
    if $download_tool_cmd squid.sh https://raw.githubusercontent.com/mmmdbybyd/squid_cloud/master/squid.sh; then
        chmod 777 squid.sh
        sed -i "s~#!/bin/bash~#!$SHELL~" squid.sh
        echo $echo_opt_e "$squid_port\n$squid_proxyHeader"|./squid.sh $task_type && \
                echo 'squid任务成功' >>builds.log || \
                echo 'squid启动失败' >>builds.log
    else
        echo 'squid脚本下载失败' >>builds.log
    fi
    rm -f squid.sh
}

TinyProxy_task() {
    if $download_tool_cmd TinyProxy.sh https://coding.net/u/915445800/p/tinyproxy_cloud/git/raw/master/tinyproxy.sh; then
        chmod 777 TinyProxy.sh
        sed -i "s~#!/bin/bash~#!$SHELL~" TinyProxy.sh
        echo $echo_opt_e "$TinyProxy_port\n$TinyProxy_proxyHeader"|./TinyProxy.sh $task_type && \
                echo 'TinyProxy任务成功' >>builds.log || \
                echo 'TinyProxy启动失败' >>builds.log
    else
        echo 'TinyProxy脚本下载失败' >>builds.log
    fi
    rm -f TinyProxy.sh
}

cns_task() {
    if $download_tool_cmd cns.sh http://pros.cutebi.xyz:666/cns/cns.sh; then
        chmod 777 cns.sh
        sed -i "s~#!/bin/bash~#!$SHELL~" cns.sh
        if [ "$task_type" != 'install' ]; then
            echo -n '请输cns安装目录(默认/usr/local/cns): '
            read cns_install_directory
        fi
        echo $echo_opt_e "$cns_port\n$cns_encrypt_password\n$cns_udp_flag\n$cns_proxy_key\n${cns_install_directory:-/usr/local/cns}"|./cns.sh $task_type && \
                echo 'cns任务成功' >>builds.log || \
                echo 'cns启动失败' >>builds.log
    else
        echo 'cns脚本下载失败' >>builds.log
    fi
    rm -f cns.sh
}

SSR_task() {
    if $download_tool_cmd SSR.sh https://raw.githubusercontent.com/mmmdbybyd/SSR_install/master/SSR.sh; then
        chmod 777 SSR.sh
        sed -i "s~#!/bin/bash~#!$SHELL~" SSR.sh
        echo $echo_opt_e "$SSR_encryption_method\n$SSR_protocol\n$SSR_obfs\n$SSR_port\n$SSR_password\ny"|./SSR.sh $task_type && \
            echo 'SSR任务成功' >>builds.log || \
            echo 'SSR任务失败' >>builds.log
    else
        echo 'SSR脚本下载失败' >>builds.log
    fi
    rm -f SSR.sh
}

v2ray_task() {
    if $download_tool_cmd v2ray.sh http://pros.cutebi.xyz:666/v2ray/v2ray.sh; then
        chmod 777 v2ray.sh
        sed -i "s~#!/bin/bash~#!$SHELL~" v2ray.sh
        if [ "$task_type" != 'install' ]; then
            echo -n '请输入v2ray安装目录(默认/usr/local/v2ray): '
            read v2ray_install_directory
        fi
        echo $echo_opt_e "${v2ray_source}\n${v2ray_install_directory:-/usr/local/v2ray}\n${v2ray_http_port}\n${v2ray_ws_port}\n${v2ray_mkcp_port}\n${v2ray_ws_path:-/}\n${v2ray_ws_tls_domain}\ny"|./v2ray.sh $task_type && \
            echo 'v2ray任务成功' >>builds.log || \
            echo 'v2ray任务失败' >>builds.log
    else
        echo 'v2ray脚本下载失败' >>builds.log
    fi
    rm -f v2ray.sh
}

lamy_task() {
    killall lamy
    lamyPath="${lamy_dir:=/usr/bin}/lamy"
    if [ "$task_type" != 'install' ]; then
        rm -f $lamyPath $lamy_dir/start_lamy
        echo 'lamy卸载成功' >>builds.log
    else
        echo '下载lamy中...'
        if $download_tool_cmd $lamyPath http://pros.cutebi.xyz:666/lamy/$abi; then
            chmod 777 $lamyPath
			lamy_start_cmd="($lamyPath -addr=:$lamy_port -raddr=127.0.0.1:$lamy_forward_port -secret=${lamy_secret:-mmb} >/dev/null &)"
            echo "$lamy_start_cmd" >$lamy_dir/start_lamy
			chmod 777 $cns_dir/start_lamy
            $lamy_start_cmd && \
                echo "lamy启动成功, 启动命令: $lamy_dir/start_lamy" >>builds.log || \
                echo 'lamy启动失败' >>builds.log
        else
            echo 'lamy下载失败' >>builds.log
        fi
    fi
}

server_set() {
    for opt in $*; do
        case $opt in
            1) squid_set;;
            2) TinyProxy_set;;
            3) cns_set;;
            4) SSR_set;;
            5) v2ray_set;;
            6) lamy_set;;
            *) exec echo "选项($opt)不正确，请输入正确的选项！";;
        esac
    done
}

start_task() {
    dnsip=`grep nameserver /etc/resolv.conf | grep -Eo '[1-9]{1,3}[0-9]{0,2}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1`
    getAbi
    for opt in $*; do
        case $opt in
            1) squid_task;;
            2) TinyProxy_task;;
            3) cns_task;;
            4) SSR_task;;
            5) v2ray_task;;
            6) lamy_task;;
        esac
        sleep 1
    done
    echo '所有任务完成' >>builds.log
    echo $echo_opt_e "\033[32m`cat builds.log 2>&-`\033[0m"
}

run_tasks() {
    [ "$task_type" != 'uninstall' ] && server_set $build_projects
    if echo "$daemon_run"|grep -qi 'y'; then
        (`start_task $build_projects &>builds.out` &)
        echo "正在后台运行中......"
    else
        start_task $build_projects
        rm -f builds.log
    fi
}

init() {
    emulate bash 2>/dev/null #zsh仿真模式
    echo -e '' | grep -q 'e' && echo_opt_e='' || echo_opt_e='-e' #dash的echo没有-e选项
    PM=`which apt-get || which yum`
    $PM -y install curl psmisc wget
    type curl && download_tool_cmd='curl -sko' || download_tool_cmd='wget --no-check-certificate -qO'
    rm -f builds.log builds.out
    clear
}

main() {
    init
    option
    run_tasks
}

main
