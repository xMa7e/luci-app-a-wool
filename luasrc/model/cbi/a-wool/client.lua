local jd = "a-wool"
local uci = luci.model.uci.cursor()
local sys = require "luci.sys"

m = Map(jd)
-- [[ 薅羊毛Docker版-基本设置 ]]--

s = m:section(TypedSection, "global",
              translate("Base Config"))
s.anonymous = true

o = s:option(DummyValue, "", "")
o.rawhtml = true
o.template = "a-wool/cookie_tools"

o =s:option(Value, "jd_dir", translate("项目目录"))
o.default = ""
o.rmempty = false
o.description = translate("<br/>目录结尾不要带'/'")

o =s:option(Value, "jd_cname", translate("容器名称"))
o.default = "jd_scripts"
o.rmempty = false
o.description = translate("<br/>定义生成的容器前缀，会根据cookie数量在后面增加数字区分")

o =s:option(Value, "cont_men", translate("容器内存"))
o.default = "256M"
o.rmempty = false
o.description = translate("<br/>限制容器内存,默认256M")

o = s:option(ListValue, "notify_enable", translate("通知形式"))
o.default = 1
o.rmempty = false
o:value(0, translate("简要通知"))
o:value(1, translate("原始通知"))
o.description = translate("<br/>关闭通知，请清空通知渠道参数")

o = s:option(ListValue, "cron_model", translate("运行模式"))
o.default = 0
o.rmempty = false
o:value(0, translate("追加模式"))
o:value(1, translate("覆盖模式"))
o.description = translate("<br/>追加模式：使用自定义任务追加到默认任务之后（推荐）<br/>覆盖模式：使用自定义任务覆盖默认任务<br/>自定义任务文件：my_crontab_list.sh<br/>模式切换最好初始化一下")

o= s:option(DynamicList, "cookiebkye", translate("cookies"))
o.rmempty = false
o.description = translate("<br/>必填项 不填初始化不了<br/>Cookie的具体形式：pt_key=xxxxxxxxxx;pt_pin=xxxx; <br/>由上到下第一个为cookie1<br/>注：cookies不要带有空格")

o= s:option(DynamicList, "nc_sharecode", translate("东东农场互助码"))
o.rmempty = false
o.description = translate("<br/>请到脚本根目录下的: log/jd_fruit 查看日志文件,可以找到你的助力码")

o= s:option(DynamicList, "zddd_sharecode", translate("种豆得豆互助码"))
o.rmempty = false
o.description = translate("<br/>请到脚本根目录下的: log/jd_plantBean 查看日志文件,可以找到你的助力码")

o= s:option(DynamicList, "pet_sharecode", translate("东东萌宠互助码"))
o.rmempty = false
o.description = translate("<br/>请到脚本根目录下的: log/jd_pet 查看日志文件,可以找到你的助力码")

o= s:option(DynamicList, "ddgc_sharecode", translate("东东工厂互助码"))
o.rmempty = false
o.description = translate("<br/>请到脚本根目录下的: log/jd_jdfactory 查看日志文件,可以找到你的助力码")

o= s:option(DynamicList, "jxgc_sharecode", translate("京喜工厂互助码"))
o.rmempty = false
o.description = translate("<br/>请到脚本根目录下的: log/jd_dreamFactory 查看日志文件,可以找到你的助力码")

o= s:option(DynamicList, "diyhz", translate("定义docker-compose参数"))
o.rmempty = false
o.description = translate("<br/>自定义docker-compose.yml各项参数<br/>比如：<br/>MARKET_COIN_TO_BEANS=1000<br/>MARKET_COIN_TO_BEANS=抽纸<br/>本人愚钝，所以参数内不能出现空格和特殊字符<br/>变量合集：https://github.com/lxk0301/jd_scripts/blob/master/githubAction.md")

o = s:option(Flag, "crondiy_enable", translate("覆盖模式追加自定义"))
o.rmempty = false
o.default = 0
o= s:option(DynamicList, "crondiy", translate("自定义任务时间"))
o.rmempty = false
o.description = translate("<br/>追加模式需要自定义任务的时候就必须在这里添加，手动更改则会被覆盖掉<br/>格式跟脚本格式一样，支持五位Cron（分时日月周）<br/>注：追加 模式下默认开启此功能，覆盖模式如需使用请勾选【覆盖模式追加自定义】<br/>参考：https://github.com/lxk0301/jd_scripts/blob/master/docker/crontab_list.sh")

o =s:option(Value, "beansignstop", translate("定义每日签到的延迟时间"))
o.default = "0"
o.rmempty = false
o.description = translate("<br/>默认每个签到接口并发无延迟，如需要依次进行每个接口，请自定义延迟时间<br/>单位为毫秒，延迟作用于每个签到接口, 如填入延迟则切换顺序签到(耗时较长)")

o = s:option(Value, "useragent", translate("定义User-Agent"))
o.rmempty = true
o.description = translate("<br/>自定义京东系列脚本的UserAgent，不懂不知不会UserAgent的请不要随意填写内容")

o = s:option(Flag, "sc_update", translate("定时上传互助码"))
o.rmempty = false
o = s:option(Value, "sc_updatetime", translate("定时上传互助码时间"))
o.rmempty = true
o.description = translate("<br/>定时上传互助码时间，支持五位Cron（分时日月周）其中 * 号请用 x 作为代替<br/>例：3 2 1,10,20 x x<br/>不要重复上传")

o = s:option(Flag, "sharecode_sc", translate("推送互助码上传状态"))
o.rmempty = false
o.description = translate("<br/>上传完成后会进行推送，看到success的字样代表上传成功（仅支持推送到 Server酱 或 Telegram）")

o = s:option(Value, "serverchan", translate("Server酱 SCKEY"))
o.rmempty = true
o.description = translate("<br/>微信推送，基于Server酱服务<br/>教程： http://sc.ftqq.com/ 绑定并获取 SCKEY")

o = s:option(Value, "igot", translate("iGot推送"))
o.rmempty = true
o.description = translate("<br/>iGot聚合推送，支持多方式推送，确保消息可达<br/>教程：https://wahao.github.io/Bark-MP-helper")

o = s:option(Value, "tg_token", translate("TG_BOT_TOKEN"))
o = s:option(Value, "tg_id", translate("TG_USER_ID"))
o.rmempty = true
o.description = translate("<br/>Telegram 推送，如需使用，TG_BOT_TOKEN和TG_USER_ID必须同时赋值<br/>教程：https://github.com/lxk0301/jd_scripts/blob/master/backUp/TG_PUSH.md")

o = s:option(DummyValue, "", "")
o.rawhtml = true
o.template = "a-wool/update_service"

return m
