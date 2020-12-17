# luci-app-a-wool

协同 chongshengB 改的薅羊毛Docker1版 

半吊子一个，代码基本靠百度，所以我写的代码看起来是那么的杂乱，那么的白。（惭愧

# 介绍

用于管理openwrt下docker1版京东签到脚本

适配Docker1：

https://github.com/lxk0301/jd_scripts

# 安装

需要 docker-compose 需要 docker-compose 需要 docker-compose 重要的事情说三遍

免docker-compose版本：（已停更）

https://github.com/XiaYi1002/luci-app-x-wool

因本人只有ARM设备，所以只在V Plus（aarch64）运行，理论上N1之类的ARM设备都可以运行，前提是要有docker-compose，当然也要有足够的空间，其他版本可自行编译（插件这玩意我也不懂，自行测试）

# 功能

便于管理

多开并发

设定容器内存

相关变量自定义

互助码自动上传

两种任务计划运行模式
追加模式：追加自定义任务到默认任务
覆盖模式：使用自定义覆盖默认任务

![image](https://github.com/XiaYi1002/luci-app-a-wool/blob/master/img/main.png)


# 非常感谢


chongshengB

https://github.com/chongshengB

jerrykuku

https://github.com/jerrykuku/luci-app-jd-dailybonus

lxk0301

https://github.com/lxk0301/jd_scripts


