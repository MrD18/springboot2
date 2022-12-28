-- ----------------------------
--  Table Alter for `biz_data_source`
-- ----------------------------
ALTER TABLE `biz_data_source` DROP `store_conf_json`;
ALTER TABLE `biz_data_source` DROP `schema_conf_json`;
ALTER TABLE `biz_data_source` ADD `connect_conf_json` longtext DEFAULT NULL;
ALTER TABLE `biz_data_source` ADD `data_store_id` bigint(20) DEFAULT NULL;