#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk
PKG_NAME:=luci-app-a-wool
LUCI_PKGARCH:=all
PKG_VERSION:=bate7
PKG_RELEASE:=20201217

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-a-wool
 	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=Luci for JD Script 
	PKGARCH:=all
endef

define Build/Prepare
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/a-wool
endef

define Package/luci-app-a-wool/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/a-wool $(1)/etc/config/a-wool

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/* $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/* $(1)/etc/uci-defaults/

	$(INSTALL_DIR) $(1)/usr/share/a-wool
	$(INSTALL_BIN) ./root/usr/share/a-wool/*.sh $(1)/usr/share/a-wool/

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/* $(1)/usr/share/rpcd/acl.d

	$(INSTALL_DIR) $(1)/www/a-wool
	$(INSTALL_DATA) ./root//www/a-wool/* $(1)/www/a-wool

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/* $(1)/usr/lib/lua/luci/controller/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/a-wool
	$(INSTALL_DATA) ./luasrc/model/cbi/a-wool/* $(1)/usr/lib/lua/luci/model/cbi/a-wool/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/a-wool
	$(INSTALL_DATA) ./luasrc/view/a-wool/* $(1)/usr/lib/lua/luci/view/a-wool/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/a-wool.po $(1)/usr/lib/lua/luci/i18n/a-wool.zh-cn.lmo
endef

$(eval $(call BuildPackage,luci-app-a-wool))

# call BuildPackage - OpenWrt buildroot signature
