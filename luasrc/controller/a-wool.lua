-- Copyright (C) 2020 jerrykuku <jerrykuku@gmail.com>
-- Licensed to the public under the GNU General Public License v3.
module("luci.controller.a-wool", package.seeall)
function index() 
    if not nixio.fs.access("/etc/config/a-wool") then 
        return 
    end
    
    entry({"admin", "services", "a-wool"}, alias("admin", "services", "a-wool", "client"), _("JD_Compose"), 10).dependent = true -- 首页
    entry({"admin", "services", "a-wool", "client"}, cbi("a-wool/client"),_("Client"), 10).leaf = true -- 基本设置
    entry({"admin", "services", "a-wool", "log"},form("a-wool/log"),_("Log"), 60).leaf = true -- 日志页面
    entry({"admin", "services", "a-wool", "script"},form("a-wool/script"),_("参数配置"), 20).leaf = true -- 直接配置脚本
	entry({"admin", "services", "a-wool", "script2"},form("a-wool/script2"),_("自定任务"), 30).leaf = true -- 直接配置脚本
	entry({"admin", "services", "a-wool", "script3"},form("a-wool/script3"),_("云端任务"), 40).leaf = true -- 直接配置脚本
	entry({"admin", "services", "a-wool", "script4"},form("a-wool/script4"),_("容器任务"), 50).leaf = true -- 直接配置脚本
    entry({"admin", "services", "a-wool", "run"}, call("run")) -- 执行程序
    entry({"admin", "services", "a-wool", "update"}, call("update")) -- 执行更新
    entry({"admin", "services", "a-wool", "check_update"}, call("check_update")) -- 检查更新
end


-- 执行程序

function run()
	local up_code = luci.http.formvalue("good")
	if up_code == "up_yml" then
		luci.sys.call("/usr/share/a-wool/newapp.sh -b &")
	elseif up_code == "up_cron" then
        luci.sys.call("/usr/share/a-wool/newapp.sh -c &")
	elseif up_code == "up_pull" then
        luci.sys.call("/usr/share/a-wool/newapp.sh -x &")
	elseif up_code == "sp_container" then
        luci.sys.call("/usr/share/a-wool/newapp.sh -y &")
	elseif up_code == "del_container" then
        luci.sys.call("/usr/share/a-wool/newapp.sh -w &")
	elseif up_code == "up_service" then
        luci.sys.call("/usr/share/a-wool/newapp.sh -a &")
	elseif up_code == "get_sc" then
        luci.sys.call("/usr/share/a-wool/newapp.sh -t &")
	elseif up_code == "update_lt" then
        luci.sys.call("/usr/share/a-wool/newapp.sh -d &")
	elseif up_code == "up_scode" then
        luci.sys.call("/usr/share/a-wool/create_share_codes.sh &")
	end
end
