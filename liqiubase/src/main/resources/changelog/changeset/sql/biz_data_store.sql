-- ----------------------------
--  Table Alter for `biz_data_store`
-- ----------------------------
ALTER TABLE `biz_data_store` ADD `SECURITY_LEVEL` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 comment '数据表用途。安全审计:1,其他类型:0';