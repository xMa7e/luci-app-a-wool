#!/bin/bash
#
#本人比较懒，直接修改自 <jerrykuku@qq.com>的京东签到脚本，额，我更懒，改自ChongshengB之后的脚本
#

NAME=a-wool
TEMP_SCRIPT=/tmp/JD_DailyBonus.js
LOG_HTM=/www/a-wool.htm
usage() {
    cat <<-EOF
		Usage: app.sh [options]
		Valid options are:

		    -a                      初始化
		    -b                      更新参数			
		    -c                      更新任务 
		    -d                      查看助力码
		    -w                      停止&删除
		    -x                      更新
		    -y                      停止
		    -z                      重启
		    -h                      Help
EOF
    exit $1
}

# Common functions

uci_get_by_name() {
    local ret=$(uci get $NAME.$1.$2 2>/dev/null)
    echo ${ret:=$3}
}

uci_get_by_type() {
    local ret=$(uci get $NAME.@$1[0].$2 2>/dev/null)
    echo ${ret:=$3}
}

cancel() {
    if [ $# -gt 0 ]; then
        echo "$1"
    fi
    exit 1
}

# 收购铜锣湾
a_run() {
	jd_dir2=$(uci_get_by_type global jd_dir)
	if [ ! -d $jd_dir2 ]; then
	#场地没被收购 赶紧拿下
    echo "创建脚本目录..." >>$LOG_HTM 2>&1
    mkdir $jd_dir2
	chmod -R 777 $jd_dir2
    else
	echo "停止并删除容器..." >>$LOG_HTM 2>&1
	# 场地被卖了 管它的 抢就对了
	# 带上家伙去他地盘
	cd $jd_dir2
	# 宰了他们主事的
	docker-compose down >>$LOG_HTM 2>&1
	# 火烧了他的地盘
	rm -rf $jd_dir2
    echo "容器已停止并删除" >>$LOG_HTM 2>&1
    fi
}

# 开始建设铜锣湾
b_run() {
	notify_enable=$(uci_get_by_type global notify_enable)
    jd_dir2=$(uci_get_by_type global jd_dir)
	sckey=$(uci_get_by_type global serverchan)
    tg_token=$(uci_get_by_type global tg_token)
    tg_id=$(uci_get_by_type global tg_id)
    igot=$(uci_get_by_type global igot)
	ua=$(uci_get_by_type global useragent)
	wait=$(uci_get_by_type global beansignstop)
    echo "配置脚本参数..." >>$LOG_HTM 2>&1	
	if [ ! -d $jd_dir2 ]; then
	#场地没被收购 赶紧拿下
    mkdir $jd_dir2
	chmod -R 777 $jd_dir2
	fi
	cat <<-EOF > $jd_dir2/docker-compose.yml
version: "3.7"
services:
	EOF
	j=1
	for ck in $(uci_get_by_type global cookiebkye); do
		cat <<-EOF >> $jd_dir2/docker-compose.yml
    jd_scripts$j:
      image: akyakya/jd_scripts
      container_name: jd_scripts$j
      restart: always
      network_mode: "host"
      volumes:
        - ./my_crontab_list.sh:/scripts/docker/my_crontab_list.sh
        - ./logs$j:/scripts/logs
        -  /etc/localtime:/etc/localtime
      tty: true
      environment:
        # 注意环境变量填写值的时候一律不需要引号（""或者''）下面这些只是事例，根据自己的需求增加删除
        #jd cookies
        # 例: JD_COOKIE=pt_key=XXX;pt_pin=XXX;
        - JD_COOKIE=$ck
        #微信server酱通
        - PUSH_KEY=$sckey
        #iGot推送
        - IGOT_PUSH_KEY=$igot
        #telegram机器人通知
        - TG_BOT_TOKEN=$tg_token
        - TG_USER_ID=$tg_id
        #通知形式
        - JD_BEAN_SIGN_NOTIFY_SIMPLE=
        #自定义此库里京东系列脚本的UserAgent，不懂不知不会UserAgent的请不要随意填写内容。
        - JD_USER_AGENT=$ua
        #自定义签到延迟
        - JD_BEAN_STOP=$wait
        #如果使用自定义定时任务,取消下面一行的注释
        - CRONTAB_LIST_FILE=my_crontab_list.sh
        #自定义参数
		EOF
		let j++
	done
	j=`expr $j - 1`
	chmod -R 777 $jd_dir2
	if [ $notify_enable -eq 1 ]; then
    echo "设置通知形式为简要通知..." >>$LOG_HTM 2>&1
	sed -i  's/- JD_BEAN_SIGN_NOTIFY_SIMPLE=/&true/' $jd_dir2/docker-compose.yml
	fi
}

# 签约商户
c_run() {
    echo "增加自定义参数..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    grep "list diyhz" /etc/config/a-wool >$jd_dir2/diyhz.log
    sed -i "s/\'//g" $jd_dir2/diyhz.log
    sed -i "s/list diyhz//g" $jd_dir2/diyhz.log
    sed -i 's/^[ \t]*//g' $jd_dir2/diyhz.log
	sed -i 's/^/- &/g' $jd_dir2/diyhz.log
	while read linea
	do
    sed -i "/#自定义参数/a\'        $linea'" $jd_dir2/docker-compose.yml
	sed -i "s/\'//g" $jd_dir2/docker-compose.yml
	rm -rf $jd_dir2/diyhz.log
	done < $jd_dir2/diyhz.log
}

# 商户营业时间
d_run() {
    echo "追加自定义计划..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    grep "list crondiy" /etc/config/a-wool >$jd_dir2/my_crontab_list.sh
	chmod -R 777 $jd_dir2
    sed -i "s/\'//g" $jd_dir2/my_crontab_list.sh
    sed -i "s/list crondiy//g" $jd_dir2/my_crontab_list.sh
    sed -i 's/^[ \t]*//g' $jd_dir2/my_crontab_list.sh
}

# 外交部任务安排
e_run() {
    jd_dir2=$(uci_get_by_type global jd_dir)
	sc_update=$(uci_get_by_type global sc_update)
    if [ $sc_update -eq 1 ]; then
    echo "创建互助码上传计划..." >>$LOG_HTM 2>&1
	uptime=$(uci_get_by_type global sc_updatetime)
    uptime=${uptime//x/\*}
    sed -i '/a-wool\/create_share_codes/d' /etc/crontabs/root
	echo "$uptime /usr/share/a-wool/create_share_codes.sh" >>/etc/crontabs/root
    else
	sed -i '/a-wool\/create_share_codes/d' /etc/crontabs/root
	fi
}

# 查看商户运营报表
# h_run() {

# }

# 开始运营
w_run() {
    echo "启动容器..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose up -d >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}

# 场地重新规划建设
x_run() {
    echo "更新镜像..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose pull >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}
# 疫情爆发，躲起来
y_run() {
    echo "停止容器..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose stop >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}

# 疫情过了，赶紧重新营业
z_run() {
    echo "重启容器..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose restart >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}

system_time() {
time3=$(date "+%Y-%m-%d %H:%M:%S")
echo "系统时间：$time3" >$LOG_HTM 2>&1
}

	
while getopts ":abcdsxyzh" arg; do
    case "$arg" in
	#初始化
    a)
	    system_time
	    a_run
        b_run
		c_run
		d_run
		e_run
		w_run
        exit 0
        ;;
	#更新参数
    b)
	    system_time
        b_run
		c_run
		d_run
		e_run
		w_run
        exit 0
        ;;
	#更新任务
    c)
	    system_time
        d_run
		z_run
        exit 0
        ;;
	#查看助力码
    d)
	    system_time
        h_run
        exit 0
        ;;
	#助力码上传
    s)
	    system_time
        e_run
        exit 0
        ;;
    #停止&删除
    w)
	    system_time
        a_run
        exit 0
        ;;
	#更新
    x)
	    system_time
        x_run
        exit 0
        ;;
	#停止
    y)
	    system_time
        y_run
        exit 0
        ;;
	#重启	
    z)
	   system_time
	    z_run
        exit 0
        ;;
	#帮助
    h)
        usage 0
        ;;
    esac
done
