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
			-t                      提取互助码
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

uci_set_by_type() {
	uci add_list $NAME.@$1[0].$2=$3 2>/dev/null
	uci commit $NAME
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
	men=$(uci_get_by_type global cont_men 256M)
	jd_cname=$(uci_get_by_type global jd_cname jd_scripts)
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
    $jd_cname$j:
      image: akyakya/jd_scripts
      deploy:
        resources:
          limits:
            memory: $men
      container_name: $jd_cname$j
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
        - CUSTOM_LIST_FILE=my_crontab_list.sh
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
#京喜工厂互助码提取
jxshare_code(){
	jd_dir2=$(uci_get_by_type global jd_dir)
	j=1
	for ck in $(uci_get_by_type global cookiebkye); do
		old=0
		if test ! -f "$jd_dir2/logs$j/jd_dreamFactory.log" ; then
			jxsc="京喜工厂日志文件不存在，请检查是否已经执行过对应脚本"
			echo "cookie$j京喜工厂互助码:"$jxsc >> $LOG_HTM 2>&1
		else
			jxsc=`sed -n '/分享码:.*/'p $jd_dir2/logs$j/jd_dreamFactory.log | awk '{print $5}' | sed -n '1p'`
			if test -n "$jxsc" ; then
				for sc in $(uci_get_by_type global jxgc_sharecode); do
					if test "$jxsc" == "$sc" ; then
						old=1
					fi
				done
				if test $old -eq 0 ; then
					uci_set_by_type global jxgc_sharecode $jxsc
				fi
				echo "cookie$j京喜工厂互助码:"$jxsc >> $LOG_HTM 2>&1
			fi
		fi
		let j++
	done

}
#农场互助码提取
ncshare_code(){
	jd_dir2=$(uci_get_by_type global jd_dir)
	j=1
	for ck in $(uci_get_by_type global cookiebkye); do
		old=0
		if test ! -f "$jd_dir2/logs$j/jd_fruit.log" ; then
			ncsc="农场日志文件不存在，请检查是否已经执行过对应脚本"
			echo "cookie$j农场互助码:"$ncsc >> $LOG_HTM 2>&1
		else
			ncsc=`sed -n '/ 【您的东东农场互助码shareCode】 .*/'p $jd_dir2/logs$j/jd_fruit.log | awk '{print $5}' | sed -n '1p'`
			if test -n "$ncsc" ; then
				for sc in $(uci_get_by_type global nc_sharecode); do
					if test "$ncsc" == "$sc" ; then
						old=1
					fi
				done
				if test $old -eq 0 ; then
					uci_set_by_type global nc_sharecode $ncsc
				fi
				echo "cookie$j农场互助码:"$ncsc >> $LOG_HTM 2>&1
			fi
		fi
		let j++
	done

}

#东东工厂互助码提取
ddshare_code(){
	jd_dir2=$(uci_get_by_type global jd_dir)
	j=1
	for ck in $(uci_get_by_type global cookiebkye); do
		old=0
		if test ! -f "$jd_dir2/logs$j/jd_jdfactory.log" ; then
			ddsc="东东工厂日志文件不存在，请检查是否已经执行过对应脚本"
			echo "cookie$j东东工厂互助码:"$ddsc >> $LOG_HTM 2>&1
		else
			ddsc=`sed -n '/您的东东工厂好友助力邀请码：.*/'p $jd_dir2/logs$j/jd_jdfactory.log | awk '{print $4}' | sed -e 's/您的东东工厂好友助力邀请码：//g' | sed -n '1p'`
			if test -n "$ddsc" ; then
				for sc in $(uci_get_by_type global ddgc_sharecode); do
					if test "$ddsc" == "$sc" ; then
						old=1
					fi
				done
				if test $old -eq 0 ; then
					uci_set_by_type global ddgc_sharecode $ddsc
				fi
				echo "cookie$j东东工厂互助码:"$ddsc >> $LOG_HTM 2>&1
			fi
		fi
		let j++
	done

}

#种豆得豆互助码提取
zdshare_code(){
	jd_dir2=$(uci_get_by_type global jd_dir)
	j=1
	for ck in $(uci_get_by_type global cookiebkye); do
		old=0
		if test ! -f "$jd_dir2/logs$j/jd_plantBean.log" ; then
			zdsc="种豆得豆日志文件不存在，请检查是否已经执行过对应脚本"
			echo "cookie$j种豆得豆互助码:"$zdsc >> $LOG_HTM 2>&1
		else
			zdsc=`sed -n '/ 【您的京东种豆得豆互助码】 .*/'p $jd_dir2/logs$j/jd_plantBean.log | awk '{print $5}' | sed -n '1p'`
			if test -n "$zdsc" ; then
				for sc in $(uci_get_by_type global zddd_sharecode); do
					if test "$zdsc" == "$sc" ; then
						old=1
					fi
				done
				if test $old -eq 0 ; then
					uci_set_by_type global zddd_sharecode $zdsc
				fi
				echo "cookie$j种豆得豆互助码:"$zdsc >> $LOG_HTM 2>&1
			fi
		fi
		let j++
	done

}

#东东萌宠互助码提取
petshare_code(){
	jd_dir2=$(uci_get_by_type global jd_dir)
	j=1
	for ck in $(uci_get_by_type global cookiebkye); do
		old=0
		if test ! -f "$jd_dir2/logs$j/jd_pet.log" ; then
			petsc="东东萌宠日志文件不存在，请检查是否已经执行过对应脚本"
			echo "cookie$j东东萌宠互助码:"$petsc >> $LOG_HTM 2>&1
		else
			petsc=`sed -n '/ 【您的东东萌宠互助码shareCode】 .*/'p $jd_dir2/logs$j/jd_pet.log | awk '{print $5}' | sed -n '1p'`
			if test -n "$petsc" ; then
				for sc in $(uci_get_by_type global pet_sharecode); do
					if test "$petsc" == "$sc" ; then
						old=1
					fi
				done
				if test $old -eq 0 ; then
					uci_set_by_type global pet_sharecode $petsc
				fi
				echo "cookie$j东东萌宠互助码:"$petsc >> $LOG_HTM 2>&1
			fi
		fi
		let j++
	done

}

# 查看商户运营报表
# h_run() {

# }

# 开始运营
w_run() {
    echo "启动容器..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose --compatibility up -d >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}

# 场地重新规划建设
x_run() {
    echo "更新镜像..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose --compatibility pull >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}
# 疫情爆发，躲起来
y_run() {
    echo "停止容器..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose --compatibility stop >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}

# 疫情过了，赶紧重新营业
z_run() {
    echo "重启容器..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose --compatibility restart >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}

system_time() {
time3=$(date "+%Y-%m-%d %H:%M:%S")
echo "系统时间：$time3" >$LOG_HTM 2>&1
}

	
while getopts ":abcdstxyzh" arg; do
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
	t)
	    echo "开始提取助力码" >$LOG_HTM 2>&1
		jxshare_code
		ncshare_code
		ddshare_code
		zdshare_code
		petshare_code
		echo "助力码提取完毕" >>$LOG_HTM 2>&1
        exit 0
        ;;
    #停止&删除
    w)
		system_time
        a_run
		echo "任务已完成" >>$LOG_HTM 2>&1
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
