-- ----------------------------
--  1Table Alter for `biz_data_process_model`
-- ----------------------------
ALTER TABLE `biz_data_process_model` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_process_model` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_process_model` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_process_model` change column `parent_id` `parent_id` BIGINT(20) UNSIGNED NOT NULL comment '上级部门ID';
ALTER TABLE `biz_data_process_model` change column `type` `type` INT(10) UNSIGNED NOT NULL comment '类型';
ALTER TABLE `biz_data_process_model` change column `conf_json` `conf_json` LONGTEXT NOT NULL comment '配置信息';
ALTER TABLE `biz_data_process_model` change column `status` `status` INT(11) NOT NULL comment '状态';
ALTER TABLE `biz_data_process_model` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_data_process_model` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_process_model` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  2Table Alter for `biz_data_process_task`
-- ----------------------------
ALTER TABLE `biz_data_process_task` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_process_task` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_process_task` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_process_task` change column `type` `type` INT(10) UNSIGNED NOT NULL comment '类型';
ALTER TABLE `biz_data_process_task` change column `conf_json` `conf_json` LONGTEXT NOT NULL comment '配置信息';
ALTER TABLE `biz_data_process_task` change column `status` `status` INT(11) NOT NULL comment '状态';
ALTER TABLE `biz_data_process_task` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_data_process_task` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_process_task` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  3Table Alter for `biz_data_process_task_dispatch`
-- ----------------------------
ALTER TABLE `biz_data_process_task_dispatch` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_process_task_dispatch` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_process_task_dispatch` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_process_task_dispatch` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_process_task_dispatch` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  4Table Alter for `biz_data_process_worker`
-- ----------------------------
ALTER TABLE `biz_data_process_worker` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_process_worker` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_process_worker` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_process_worker` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_process_worker` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  5Table Alter for `biz_data_query_model`
-- ----------------------------
ALTER TABLE `biz_data_query_model` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_query_model` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_query_model` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_query_model` change column `name` `name` VARCHAR(100) NOT NULL DEFAULT '' comment '名称';
ALTER TABLE `biz_data_query_model` change column `path_id` `path_id` VARCHAR(100) NOT NULL DEFAULT '' comment '路径ID';
ALTER TABLE `biz_data_query_model` change column `type` `type` VARCHAR(20) NOT NULL DEFAULT '' comment '类型';
ALTER TABLE `biz_data_query_model` change column `conf_json` `conf_json` LONGTEXT NOT NULL comment '配置信息';
ALTER TABLE `biz_data_query_model` change column `status` `status` INT(11) NOT NULL comment '状态';
ALTER TABLE `biz_data_query_model` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_data_query_model` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_query_model` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_query_model` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_query_model` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  6Table Alter for `biz_data_ref_tag`
-- ----------------------------
ALTER TABLE `biz_data_ref_tag` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_ref_tag` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_ref_tag` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_ref_tag` change column `tag_id` `tag_id` BIGINT(20) UNSIGNED NOT NULL comment '标签ID';
ALTER TABLE `biz_data_ref_tag` change column `ref_id` `ref_id` BIGINT(20) UNSIGNED NOT NULL comment 'RefID';
ALTER TABLE `biz_data_ref_tag` change column `type` `type` VARCHAR(20) NOT NULL DEFAULT '' comment '类型';
ALTER TABLE `biz_data_ref_tag` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_ref_tag` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_ref_tag` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_ref_tag` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  7Table Alter for `biz_data_set`
-- ----------------------------
ALTER TABLE `biz_data_set` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_set` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_set` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_set` change column `parent_id` `parent_id` BIGINT(20) UNSIGNED NOT NULL comment '上级部门ID';
ALTER TABLE `biz_data_set` change column `type` `type` INT(10) UNSIGNED NOT NULL comment '类型';
ALTER TABLE `biz_data_set` change column `conf_json` `conf_json` LONGTEXT NOT NULL comment '配置信息';
ALTER TABLE `biz_data_set` change column `status` `status` INT(11) NOT NULL comment '状态';
ALTER TABLE `biz_data_set` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_data_set` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_set` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_set` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_set` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  8Table Alter for `biz_data_source`
-- ----------------------------
ALTER TABLE `biz_data_source` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_source` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_source` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_source` change column `name` `name` VARCHAR(100) NOT NULL DEFAULT '' comment '名称';
ALTER TABLE `biz_data_source` change column `code_name` `code_name` VARCHAR(100) DEFAULT '' comment '编码名称';
ALTER TABLE `biz_data_source` change column `description` `description` VARCHAR(200) DEFAULT NULL comment '描述';
ALTER TABLE `biz_data_source` change column `type` `type` VARCHAR(20) NOT NULL DEFAULT '' comment '类型';
ALTER TABLE `biz_data_source` change column `kafka_conf_json` `kafka_conf_json` TEXT comment 'Kafka配置信息';
ALTER TABLE `biz_data_source` change column `stream_path_uuid` `stream_path_uuid` VARCHAR(50) DEFAULT NULL comment '流数据唯一标识';
ALTER TABLE `biz_data_source` change column `status` `status` INT(11) NOT NULL comment '状态';
ALTER TABLE `biz_data_source` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_data_source` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_source` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_source` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_source` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `biz_data_source` change column `connect_conf_json` `connect_conf_json` LONGTEXT comment '连接配置信息';
ALTER TABLE `biz_data_source` change column `data_store_id` `data_store_id` BIGINT(20) DEFAULT NULL comment '数据表ID';

-- ----------------------------
--  9Table Alter for `biz_data_tag`
-- ----------------------------
ALTER TABLE `biz_data_tag` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_tag` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_tag` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_tag` change column `name` `name` VARCHAR(100) NOT NULL DEFAULT '' comment '名称';
ALTER TABLE `biz_data_tag` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_data_tag` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_tag` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_tag` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_tag` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  10Table Alter for `biz_samplereel`
-- ----------------------------
ALTER TABLE `biz_samplereel` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_samplereel` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_samplereel` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_samplereel` change column `name` `name` VARCHAR(100) NOT NULL DEFAULT '' comment '名称';
ALTER TABLE `biz_samplereel` change column `type` `type` INT(10) UNSIGNED NOT NULL DEFAULT '0' comment '类型';
ALTER TABLE `biz_samplereel` change column `cover` `cover` VARCHAR(200) DEFAULT NULL comment 'Cover';
ALTER TABLE `biz_samplereel` change column `conf_json` `conf_json` LONGTEXT comment '配置信息';
ALTER TABLE `biz_samplereel` change column `is_share` `is_share` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' comment '是否共享';
ALTER TABLE `biz_samplereel` change column `source` `source` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' comment '来源';
ALTER TABLE `biz_samplereel` change column `quote_url` `quote_url` VARCHAR(200) DEFAULT NULL comment '引用地址';
ALTER TABLE `biz_samplereel` change column `is_quote_cover` `is_quote_cover` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' comment '是否引用覆盖';
ALTER TABLE `biz_samplereel` change column `status` `status` INT(10) NOT NULL DEFAULT '1' comment '状态';
ALTER TABLE `biz_samplereel` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' comment '是否删除';
ALTER TABLE `biz_samplereel` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_samplereel` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_samplereel` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_samplereel` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  11Table Alter for `biz_samplereel_share`
-- ----------------------------
ALTER TABLE `biz_samplereel_share` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_samplereel_share` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_samplereel_share` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_samplereel_share` change column `type` `type` INT(10) UNSIGNED NOT NULL comment '类型';
ALTER TABLE `biz_samplereel_share` change column `status` `status` INT(11) NOT NULL comment '状态';
ALTER TABLE `biz_samplereel_share` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_samplereel_share` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_samplereel_share` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_samplereel_share` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_samplereel_share` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  12Table Alter for `biz_samplereel_template`
-- ----------------------------
ALTER TABLE `biz_samplereel_template` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_samplereel_template` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_samplereel_template` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_samplereel_template` change column `type` `type` INT(10) UNSIGNED NOT NULL comment '类型';
ALTER TABLE `biz_samplereel_template` change column `conf_json` `conf_json` LONGTEXT NOT NULL comment '配置信息';
ALTER TABLE `biz_samplereel_template` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_samplereel_template` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_samplereel_template` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_samplereel_template` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  13Table Alter for `sys_account`
-- ----------------------------
ALTER TABLE `sys_account` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_account` change column `account_id` `account_id` VARCHAR(40) NOT NULL comment '账户ID';
ALTER TABLE `sys_account` change column `company_name` `company_name` VARCHAR(100) DEFAULT NULL comment '企业名称';
ALTER TABLE `sys_account` change column `company_webset` `company_webset` VARCHAR(100) DEFAULT NULL comment '企业网址';
ALTER TABLE `sys_account` change column `company_phone` `company_phone` VARCHAR(50) DEFAULT NULL comment '企业电话';
ALTER TABLE `sys_account` change column `link_man` `link_man` VARCHAR(100) DEFAULT NULL comment '联络人';
ALTER TABLE `sys_account` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `sys_account` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';

-- ----------------------------
--  14Table Alter for `sys_account_app`
-- ----------------------------
ALTER TABLE `sys_account_app` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_account_app` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `sys_account_app` change column `name` `name` VARCHAR(50) NOT NULL comment '名称';
ALTER TABLE `sys_account_app` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `sys_account_app` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  15Table Alter for `sys_audit_log`
-- ----------------------------
ALTER TABLE `sys_audit_log` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_audit_log` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `sys_audit_log` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `sys_audit_log` change column `user_id` `user_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `sys_audit_log` change column `content` `content` VARCHAR(500) NOT NULL comment '账户ID';
ALTER TABLE `sys_audit_log` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `sys_audit_log` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  16Table Alter for `sys_department`
-- ----------------------------
ALTER TABLE `sys_department` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_department` change column `name` `name` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL comment '名称';
ALTER TABLE `sys_department` change column `parent_id` `parent_id` BIGINT(20) NOT NULL DEFAULT '0' comment '上级部门ID';
ALTER TABLE `sys_department` change column `department_number` `department_number` VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '部门编号';
ALTER TABLE `sys_department` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `sys_department` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `sys_department` change column `account_id` `account_id` BIGINT(20) NOT NULL comment '账户ID';

-- ----------------------------
--  17Table Alter for `sys_premisson`
-- ----------------------------
ALTER TABLE `sys_premisson` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_premisson` change column `name` `name` VARCHAR(50) NOT NULL comment '名称';
ALTER TABLE `sys_premisson` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `sys_premisson` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  18Table Alter for `sys_role`
-- ----------------------------
ALTER TABLE `sys_role` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_role` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `sys_role` change column `name` `name` VARCHAR(50) NOT NULL comment '名称';
ALTER TABLE `sys_role` change column `modified_time` `modified_time` DATETIME(6) DEFAULT NULL comment '修改时间';
ALTER TABLE `sys_role` change column `creation_time` `creation_time` DATETIME(6) DEFAULT NULL comment '创建时间';
ALTER TABLE `sys_role` change column `modified_user_id` `modified_user_id` BIGINT(20) DEFAULT NULL comment '修改用户ID';
ALTER TABLE `sys_role` change column `creation_user_id` `creation_user_id` BIGINT(20) DEFAULT NULL comment '创建用户ID';
ALTER TABLE `sys_role` change column `modified_user_name` `modified_user_name` VARCHAR(50) DEFAULT NULL comment '修改用户名称';
ALTER TABLE `sys_role` change column `creation_user_name` `creation_user_name` CHAR(50) DEFAULT NULL comment '创建用户名称';

-- ----------------------------
--  19Table Alter for `sys_role_premisson`
-- ----------------------------
ALTER TABLE `sys_role_premisson` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_role_premisson` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `sys_role_premisson` change column `roleid` `roleid` BIGINT(20) UNSIGNED NOT NULL comment '角色ID';
ALTER TABLE `sys_role_premisson` change column `premisson_id` `premisson_id` BIGINT(20) UNSIGNED NOT NULL comment '权限ID';
ALTER TABLE `sys_role_premisson` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `sys_role_premisson` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  20Table Alter for `sys_user`
-- ----------------------------
ALTER TABLE `sys_user` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_user` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `sys_user` change column `name` `name` VARCHAR(50) NOT NULL comment '名称';
ALTER TABLE `sys_user` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `sys_user` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `sys_user` change column `password` `password` VARCHAR(100) DEFAULT NULL comment '修改用户ID';
ALTER TABLE `sys_user` change column `cwop_user_id` `cwop_user_id` VARCHAR(40) DEFAULT NULL comment 'Cwop用户ID';
ALTER TABLE `sys_user` change column `cwop_account_id` `cwop_account_id` VARCHAR(40) DEFAULT NULL comment 'Cwop账户ID';
ALTER TABLE `sys_user` change column `status` `status` INT(11) NOT NULL comment '状态';
ALTER TABLE `sys_user` change column `delete_flag` `delete_flag` TINYINT(3) NOT NULL comment '是否删除';
ALTER TABLE `sys_user` change column `email` `email` VARCHAR(50) DEFAULT NULL comment '邮箱';
ALTER TABLE `sys_user` change column `mobile` `mobile` VARCHAR(255) DEFAULT NULL comment '联系方式';
ALTER TABLE `sys_user` change column `account` `account` VARCHAR(20) NOT NULL comment '账户';

-- ----------------------------
--  21Table Alter for `sys_user_department`
-- ----------------------------
ALTER TABLE `sys_user_department` change column `id` `id` BIGINT(20) NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_user_department` change column `user_id` `user_id` BIGINT(20) UNSIGNED DEFAULT NULL comment '用户ID';
ALTER TABLE `sys_user_department` change column `department_id` `department_id` BIGINT(20) UNSIGNED DEFAULT NULL comment '部门ID';

-- ----------------------------
--  22Table Alter for `sys_user_role`
-- ----------------------------
ALTER TABLE `sys_user_role` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_user_role` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `sys_user_role` change column `user_id` `user_id` BIGINT(20) UNSIGNED NOT NULL comment '用户ID';
ALTER TABLE `sys_user_role` change column `role_id` `role_id` BIGINT(20) UNSIGNED NOT NULL comment '角色ID';
ALTER TABLE `sys_user_role` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `sys_user_role` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `sys_user_role` change column `modified_user_id` `modified_user_id` BIGINT(20) DEFAULT NULL comment '修改用户ID';
ALTER TABLE `sys_user_role` change column `creation_user_id` `creation_user_id` BIGINT(20) DEFAULT NULL comment '创建用户ID';
ALTER TABLE `sys_user_role` change column `modified_user_name` `modified_user_name` VARCHAR(50) DEFAULT NULL comment '修改用户名称';
ALTER TABLE `sys_user_role` change column `creation_user_name` `creation_user_name` VARCHAR(50) DEFAULT NULL comment '创建用户名称';

-- ----------------------------
--  23Table Alter for `biz_access_token`
-- ----------------------------
ALTER TABLE `biz_access_token` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_access_token` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_access_token` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_access_token` change column `user_id` `user_id` BIGINT(20) UNSIGNED NOT NULL comment '用户ID';
ALTER TABLE `biz_access_token` change column `token` `token` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment 'Token';
ALTER TABLE `biz_access_token` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_access_token` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_access_token` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_access_token` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  24Table Alter for `biz_data_pipeline`
-- ----------------------------
ALTER TABLE `biz_data_pipeline` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_pipeline` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_pipeline` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_pipeline` change column `name` `name` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '名称';
ALTER TABLE `biz_data_pipeline` change column `conf_json` `conf_json` LONGTEXT COLLATE utf8mb4_unicode_ci NOT NULL comment '配置信息';
ALTER TABLE `biz_data_pipeline` change column `description` `description` VARCHAR(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '描述';
ALTER TABLE `biz_data_pipeline` change column `display_topology` `display_topology` LONGTEXT COLLATE utf8mb4_unicode_ci comment '结构显示';
ALTER TABLE `biz_data_pipeline` change column `test_data` `test_data` TEXT COLLATE utf8mb4_unicode_ci comment '测试数据';
ALTER TABLE `biz_data_pipeline` change column `status` `status` INT(11) NOT NULL comment '状态';
ALTER TABLE `biz_data_pipeline` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_data_pipeline` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_pipeline` change column `modified_time` `modified_time` DATETIME NOT NULL comment '修改时间';
ALTER TABLE `biz_data_pipeline` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_pipeline` change column `creation_time` `creation_time` DATETIME NOT NULL comment '创建时间';

-- ----------------------------
--  25Table Alter for `biz_data_pipenode`
-- ----------------------------
ALTER TABLE `biz_data_pipenode` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_pipenode` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_pipenode` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_pipenode` change column `name` `name` VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT '' comment '名称';
ALTER TABLE `biz_data_pipenode` change column `node_id` `node_id` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '节点ID';
ALTER TABLE `biz_data_pipenode` change column `parent_node_ids` `parent_node_ids` LONGTEXT COLLATE utf8mb4_unicode_ci comment '父节点ID';
ALTER TABLE `biz_data_pipenode` change column `type` `type` VARCHAR(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '类型';
ALTER TABLE `biz_data_pipenode` change column `config` `config` LONGTEXT COLLATE utf8mb4_unicode_ci comment '配置';
ALTER TABLE `biz_data_pipenode` change column `pipeline_id` `pipeline_id` BIGINT(20) NOT NULL comment 'PipelineID';
ALTER TABLE `biz_data_pipenode` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_pipenode` change column `modified_time` `modified_time` DATETIME NOT NULL comment '修改时间';
ALTER TABLE `biz_data_pipenode` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_pipenode` change column `creation_time` `creation_time` DATETIME NOT NULL comment '创建时间';

-- ----------------------------
--  26Table Alter for `biz_worker_node_conf`
-- ----------------------------
ALTER TABLE `biz_worker_node_conf` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_worker_node_conf` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_worker_node_conf` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_worker_node_conf` change column `worker_id` `worker_id` BIGINT(20) UNSIGNED NOT NULL comment 'WorkerID';
ALTER TABLE `biz_worker_node_conf` change column `type` `type` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL comment '类型';
ALTER TABLE `biz_worker_node_conf` change column `host` `host` VARCHAR(200) COLLATE utf8mb4_unicode_ci NOT NULL comment '主机号';
ALTER TABLE `biz_worker_node_conf` change column `port` `port` INT(11) NOT NULL comment '端口号';
ALTER TABLE `biz_worker_node_conf` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_worker_node_conf` change column `modified_time` `modified_time` DATETIME NOT NULL comment '修改时间';
ALTER TABLE `biz_worker_node_conf` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_worker_node_conf` change column `creation_time` `creation_time` DATETIME NOT NULL comment '创建时间';

-- ----------------------------
--  27Table Alter for `dpm_alert_receiver`
-- ----------------------------
ALTER TABLE `dpm_alert_receiver` change column `id` `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `dpm_alert_receiver` change column `account_id` `account_id` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL comment '账户ID';
ALTER TABLE `dpm_alert_receiver` change column `user_id` `user_id` INT(11) NOT NULL comment '用户ID';
ALTER TABLE `dpm_alert_receiver` change column `user_name` `user_name` VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '创建用户名称';
ALTER TABLE `dpm_alert_receiver` change column `rule_id` `rule_id` INT(11) NOT NULL comment '应用ID';
ALTER TABLE `dpm_alert_receiver` change column `receive_type` `receive_type` VARCHAR(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment 'sms-短信,email-邮件,voice-语音';
ALTER TABLE `dpm_alert_receiver` change column `dnd_times` `dnd_times` VARCHAR(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '免打扰时间段';
ALTER TABLE `dpm_alert_receiver` change column `deleted` `deleted` BIT(1) NOT NULL comment '删除';

-- ----------------------------
--  28Table Alter for `dpm_alert_rule`
-- ----------------------------
ALTER TABLE `dpm_alert_rule` change column `id` `id` INT(11) NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `dpm_alert_rule` change column `name` `name` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '名称';
ALTER TABLE `dpm_alert_rule` change column `account_id` `account_id` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '账户ID';
ALTER TABLE `dpm_alert_rule` change column `type` `type` TINYINT(3) NOT NULL comment '1-业务告警';
ALTER TABLE `dpm_alert_rule` change column `meta_name` `meta_name` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '元数据名称';
ALTER TABLE `dpm_alert_rule` change column `meta_name_alias` `meta_name_alias` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '元数据别名';
ALTER TABLE `dpm_alert_rule` change column `index_field` `index_field` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '指标名称';
ALTER TABLE `dpm_alert_rule` change column `index_field_alias` `index_field_alias` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '指标字段别名';
ALTER TABLE `dpm_alert_rule` change column `time_field` `time_field` VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '时间字段名称';
ALTER TABLE `dpm_alert_rule` change column `time_field_alias` `time_field_alias` VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '时间字段别名';
ALTER TABLE `dpm_alert_rule` change column `target_field` `target_field` VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '分组字段名称';
ALTER TABLE `dpm_alert_rule` change column `target_field_alias` `target_field_alias` VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '分组字段别名';
ALTER TABLE `dpm_alert_rule` change column `conditions` `conditions` TEXT COLLATE utf8mb4_unicode_ci comment '条件';
ALTER TABLE `dpm_alert_rule` change column `targets` `targets` TEXT COLLATE utf8mb4_unicode_ci comment '监控目标';
ALTER TABLE `dpm_alert_rule` change column `start_time` `start_time` VARCHAR(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '监控开始时段';
ALTER TABLE `dpm_alert_rule` change column `stop_time` `stop_time` VARCHAR(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '监控结束时段';
ALTER TABLE `dpm_alert_rule` change column `condition_type` `condition_type` TINYINT(3) NOT NULL comment '0-静态数值';
ALTER TABLE `dpm_alert_rule` change column `time_unit` `time_unit` INT(11) comment '时间单位：minute(0), second(1), hour(2), day(3)';
ALTER TABLE `dpm_alert_rule` change column `time_range` `time_range` INT(11) comment '时间段';
ALTER TABLE `dpm_alert_rule` change column `statistical_type` `statistical_type` TINYINT(3) NOT NULL comment 'AVG(0), MAX(1), MIN(2),MEDIAN中位数(3),COUNT(4), SUM(5), NONE(6)';
ALTER TABLE `dpm_alert_rule` change column `symbol` `symbol` VARCHAR(11) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '符号';
ALTER TABLE `dpm_alert_rule` change column `threshold_value` `threshold_value` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '阈值';
ALTER TABLE `dpm_alert_rule` change column `severity` `severity` VARCHAR(11) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '事件紧急程度';
ALTER TABLE `dpm_alert_rule` change column `interval_minutes` `interval_minutes` INT(11) NOT NULL comment '时间段';
ALTER TABLE `dpm_alert_rule` change column `recovered_alert` `recovered_alert` INT(11) NOT NULL comment '恢复通知';
ALTER TABLE `dpm_alert_rule` change column `status` `status` TINYINT(3) NOT NULL comment '0-禁用 1-启用';
ALTER TABLE `dpm_alert_rule` change column `deleted` `deleted` BIT(1) NOT NULL comment '删除';
ALTER TABLE `dpm_alert_rule` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `dpm_alert_rule` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';

-- ----------------------------
--  29Table Alter for `dpm_alert_template`
-- ----------------------------
ALTER TABLE `dpm_alert_template` change column `id` `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `dpm_alert_template` change column `account_id` `account_id` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL comment '账户ID';
ALTER TABLE `dpm_alert_template` change column `name` `name` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '名称';
ALTER TABLE `dpm_alert_template` change column `content` `content` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL comment '内容';
ALTER TABLE `dpm_alert_template` change column `is_recoverd` `is_recoverd` TINYINT(3) NOT NULL comment '0-未恢复 1-恢复';
ALTER TABLE `dpm_alert_template` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `dpm_alert_template` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';

-- ----------------------------
--  30Table Alter for `dpm_system_dictionary`
-- ----------------------------
ALTER TABLE `dpm_system_dictionary` change column `id` `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `dpm_system_dictionary` change column `name` `name` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL comment '名称';
ALTER TABLE `dpm_system_dictionary` change column `value` `value` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '值';
ALTER TABLE `dpm_system_dictionary` change column `type` `type` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' comment '类型';
ALTER TABLE `dpm_system_dictionary` change column `status` `status` TINYINT(3) NOT NULL comment '状态';
ALTER TABLE `dpm_system_dictionary` change column `sort` `sort` INT(11) DEFAULT NULL comment '排序';


-- ----------------------------
--  31Table Alter for `biz_anomaly_detect_template_repository`
-- ----------------------------
ALTER TABLE `biz_anomaly_detect_template_repository` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `name` `name` VARCHAR(100) NOT NULL DEFAULT '' comment '名称';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `description` `description` VARCHAR(200) DEFAULT NULL comment '描述';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `upload_file_path` `upload_file_path` VARCHAR(200) DEFAULT NULL comment '上传文件路径';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `file_name` `file_name` VARCHAR(200) DEFAULT NULL comment '文件名称';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `uuid` `uuid` VARCHAR(100) DEFAULT NULL comment 'UUID';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `datasource_id` `datasource_id` BIGINT(20) UNSIGNED DEFAULT NULL comment '数据源ID';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `datasource_name` `datasource_name` VARCHAR(200) DEFAULT NULL comment '数据源名称';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `param_string` `param_string` VARCHAR(200) DEFAULT NULL comment '参数';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `start_time` `start_time` BIGINT(20) UNSIGNED DEFAULT NULL comment '开始时间';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `end_time` `end_time` BIGINT(20) UNSIGNED DEFAULT NULL comment '结束时间';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `datasource_file_path` `datasource_file_path` VARCHAR(200) DEFAULT NULL comment '数据源上传路径';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `result_file_path` `result_file_path` VARCHAR(200) DEFAULT NULL comment 'Result文件路径';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `config` `config` VARCHAR(1500) DEFAULT NULL comment '配置';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `status` `status` VARCHAR(20) NOT NULL comment '状态';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `error_message` `error_message` VARCHAR(4000) DEFAULT NULL comment '错误信息';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_anomaly_detect_template_repository` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  32Table Alter for `biz_data_store`
-- ----------------------------
ALTER TABLE `biz_data_store` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_store` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_store` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_store` change column `name` `name` VARCHAR(100) NOT NULL DEFAULT '' comment '名称';
ALTER TABLE `biz_data_store` change column `description` `description` VARCHAR(200) DEFAULT NULL comment '描述';
ALTER TABLE `biz_data_store` change column `database_id` `database_id` BIGINT(20) NOT NULL comment '数据库ID';
ALTER TABLE `biz_data_store` change column `table_name` `table_name` VARCHAR(100) NOT NULL comment '表名';
ALTER TABLE `biz_data_store` change column `schema_conf_json` `schema_conf_json` LONGTEXT NOT NULL comment 'Schema配置信息';
ALTER TABLE `biz_data_store` change column `reserved_day` `reserved_day` INT(11) NOT NULL comment '保留时长';
ALTER TABLE `biz_data_store` change column `store_conf_json` `store_conf_json` TEXT NOT NULL comment '存储配置信息';
ALTER TABLE `biz_data_store` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_data_store` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_store` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_store` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_store` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `biz_data_store` change column `kafka_conf_json` `kafka_conf_json` TEXT comment 'Kafka配置信息';
ALTER TABLE `biz_data_store` change column `schema_version` `schema_version` VARCHAR(50) DEFAULT NULL comment 'Schema版本';
ALTER TABLE `biz_data_store` change column `store_type` `store_type` VARCHAR(20) NOT NULL comment '存储类型';

-- ----------------------------
--  33Table Alter for `biz_data_database`
-- ----------------------------
ALTER TABLE `biz_data_database` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_database` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_database` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_database` change column `name` `name` VARCHAR(100) NOT NULL comment '名称';
ALTER TABLE `biz_data_database` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_data_database` change column `modified_user_id` `modified_user_id` BIGINT(20) UNSIGNED NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_database` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_database` change column `creation_user_id` `creation_user_id` BIGINT(20) UNSIGNED NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_database` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  34Table Alter for `biz_data_source_store_transform`
-- ----------------------------
ALTER TABLE `biz_data_source_store_transform` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_source_store_transform` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_source_store_transform` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_source_store_transform` change column `field_name` `field_name` VARCHAR(100) NOT NULL comment 'Field名称';
ALTER TABLE `biz_data_source_store_transform` change column `transform_conf_json` `transform_conf_json` TEXT NOT NULL comment '配置信息';
ALTER TABLE `biz_data_source_store_transform` change column `data_source_id` `data_source_id` BIGINT(20) NOT NULL comment '数据源ID';
ALTER TABLE `biz_data_source_store_transform` change column `data_store_id` `data_store_id` BIGINT(20) NOT NULL comment '数据表ID';
ALTER TABLE `biz_data_source_store_transform` change column `modified_user_id` `modified_user_id` BIGINT(20) UNSIGNED NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_source_store_transform` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_source_store_transform` change column `creation_user_id` `creation_user_id` BIGINT(20) UNSIGNED NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_source_store_transform` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  35Table Alter for `biz_data_ref`
-- ----------------------------
ALTER TABLE `biz_data_ref` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_ref` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_ref` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_ref` change column `origin_id` `origin_id` BIGINT(20) UNSIGNED NOT NULL comment '原始ID';
ALTER TABLE `biz_data_ref` change column `origin_type` `origin_type` VARCHAR(20) NOT NULL DEFAULT '' comment '原始类型';
ALTER TABLE `biz_data_ref` change column `ref_id` `ref_id` BIGINT(20) UNSIGNED NOT NULL comment 'RefID';
ALTER TABLE `biz_data_ref` change column `ref_type` `ref_type` VARCHAR(20) NOT NULL DEFAULT '' comment 'Ref类型';
ALTER TABLE `biz_data_ref` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_ref` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_ref` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_ref` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  36Table Alter for `biz_data_cube`
-- ----------------------------
ALTER TABLE `biz_data_cube` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_cube` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_cube` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_cube` change column `name` `name` VARCHAR(100) NOT NULL DEFAULT '' comment '名称';
ALTER TABLE `biz_data_cube` change column `description` `description` VARCHAR(200) DEFAULT NULL comment '描述';
ALTER TABLE `biz_data_cube` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_cube` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_cube` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_cube` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  37Table Alter for `biz_data_cube_fields`
-- ----------------------------
ALTER TABLE `biz_data_cube_fields` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_cube_fields` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_cube_fields` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_cube_fields` change column `cube_id` `cube_id` BIGINT(20) UNSIGNED NOT NULL comment '数据立方ID';
ALTER TABLE `biz_data_cube_fields` change column `name` `name` VARCHAR(100) DEFAULT NULL comment '名称';
ALTER TABLE `biz_data_cube_fields` change column `expression` `expression` VARCHAR(200) DEFAULT NULL comment '表达式';
ALTER TABLE `biz_data_cube_fields` change column `type` `type` VARCHAR(20) NOT NULL DEFAULT '' comment '类型';
ALTER TABLE `biz_data_cube_fields` change column `is_enum` `is_enum` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' comment '是否枚举';
ALTER TABLE `biz_data_cube_fields` change column `tree_id` `tree_id` VARCHAR(100) DEFAULT NULL comment '树ID';
ALTER TABLE `biz_data_cube_fields` change column `parent_tree_id` `parent_tree_id` VARCHAR(100) DEFAULT '' comment '上级树ID';
ALTER TABLE `biz_data_cube_fields` change column `is_group` `is_group` TINYINT(3) UNSIGNED NOT NULL comment '是否分组';
ALTER TABLE `biz_data_cube_fields` change column `alias` `alias` VARCHAR(100) DEFAULT NULL comment '别名';
ALTER TABLE `biz_data_cube_fields` change column `unit` `unit` VARCHAR(100) DEFAULT NULL comment '单位';
ALTER TABLE `biz_data_cube_fields` change column `format` `format` VARCHAR(100) DEFAULT NULL comment '格式';
ALTER TABLE `biz_data_cube_fields` change column `description` `description` VARCHAR(200) DEFAULT NULL comment '描述';
ALTER TABLE `biz_data_cube_fields` change column `sort` `sort` BIGINT(20) UNSIGNED NOT NULL comment '排序';
ALTER TABLE `biz_data_cube_fields` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_cube_fields` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_cube_fields` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_cube_fields` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  38Table Alter for `biz_data_ref_cube`
-- ----------------------------
ALTER TABLE `biz_data_ref_cube` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_ref_cube` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `biz_data_ref_cube` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `biz_data_ref_cube` change column `cube_id` `cube_id` BIGINT(20) UNSIGNED NOT NULL comment '数据立方ID';
ALTER TABLE `biz_data_ref_cube` change column `ref_id` `ref_id` BIGINT(20) UNSIGNED NOT NULL comment 'RefID';
ALTER TABLE `biz_data_ref_cube` change column `ref_name` `ref_name` VARCHAR(100) NOT NULL comment 'Ref名称';
ALTER TABLE `biz_data_ref_cube` change column `type` `type` VARCHAR(20) NOT NULL DEFAULT '' comment '类型';
ALTER TABLE `biz_data_ref_cube` change column `modified_user_id` `modified_user_id` BIGINT(20) NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_ref_cube` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_ref_cube` change column `creation_user_id` `creation_user_id` BIGINT(20) NOT NULL comment '创建用户ID';
ALTER TABLE `biz_data_ref_cube` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';

-- ----------------------------
--  39Table Alter for `biz_data_store_schema_template`
-- ----------------------------
ALTER TABLE `biz_data_store_schema_template` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `biz_data_store_schema_template` change column `type` `type` VARCHAR(20) NOT NULL comment '类型';
ALTER TABLE `biz_data_store_schema_template` change column `schema_conf_json` `schema_conf_json` LONGTEXT NOT NULL comment 'Schema配置信息';
ALTER TABLE `biz_data_store_schema_template` change column `is_deleted` `is_deleted` TINYINT(3) UNSIGNED NOT NULL comment '是否删除';
ALTER TABLE `biz_data_store_schema_template` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `biz_data_store_schema_template` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `biz_data_store_schema_template` change column `modified_user_id` `modified_user_id` BIGINT(20) UNSIGNED NOT NULL comment '修改用户ID';
ALTER TABLE `biz_data_store_schema_template` change column `creation_user_id` `creation_user_id` BIGINT(20) UNSIGNED NOT NULL comment '创建用户ID';

-- ----------------------------
--  40Table Alter for `sys_permission`
-- ----------------------------
ALTER TABLE `sys_permission` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_permission` change column `app_id` `app_id` BIGINT(20) UNSIGNED NOT NULL comment '应用ID';
ALTER TABLE `sys_permission` change column `account_id` `account_id` BIGINT(20) UNSIGNED NOT NULL comment '账户ID';
ALTER TABLE `sys_permission` change column `name` `name` VARCHAR(50) NOT NULL comment '名称';
ALTER TABLE `sys_permission` change column `description` `description` VARCHAR(200) DEFAULT NULL comment '描述';
ALTER TABLE `sys_permission` change column `type` `type` VARCHAR(20) NOT NULL comment '类型';
ALTER TABLE `sys_permission` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `sys_permission` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `sys_permission` change column `modified_user_id` `modified_user_id` BIGINT(20) UNSIGNED NOT NULL comment '修改用户ID';
ALTER TABLE `sys_permission` change column `creation_user_id` `creation_user_id` BIGINT(20) UNSIGNED NOT NULL comment '创建用户ID';

-- ----------------------------
--  41Table Alter for `sys_permission_filter`
-- ----------------------------
ALTER TABLE `sys_permission_filter` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_permission_filter` change column `permission_id` `permission_id` BIGINT(20) UNSIGNED DEFAULT NULL comment '权限ID';
ALTER TABLE `sys_permission_filter` change column `name` `name` VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '名称';
ALTER TABLE `sys_permission_filter` change column `operator` `operator` VARCHAR(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL comment '操作符';
ALTER TABLE `sys_permission_filter` change column `values_json` `values_json` LONGTEXT COLLATE utf8mb4_unicode_ci comment '值';
ALTER TABLE `sys_permission_filter` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `sys_permission_filter` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `sys_permission_filter` change column `modified_user_id` `modified_user_id` BIGINT(20) UNSIGNED NOT NULL comment '修改用户ID';
ALTER TABLE `sys_permission_filter` change column `creation_user_id` `creation_user_id` BIGINT(20) UNSIGNED NOT NULL comment '创建用户ID';
ALTER TABLE `sys_permission_filter` change column `datastore_ids_json` `datastore_ids_json` LONGTEXT COLLATE utf8mb4_unicode_ci comment '数据表IDs';

-- ----------------------------
--  42Table Alter for `sys_group_permission`
-- ----------------------------
ALTER TABLE `sys_group_permission` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_group_permission` change column `group_id` `group_id` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL comment '分组ID';
ALTER TABLE `sys_group_permission` change column `permission_id` `permission_id` BIGINT(20) UNSIGNED NOT NULL comment '权限ID';
ALTER TABLE `sys_group_permission` change column `modified_time` `modified_time` DATETIME(6) NOT NULL comment '修改时间';
ALTER TABLE `sys_group_permission` change column `creation_time` `creation_time` DATETIME(6) NOT NULL comment '创建时间';
ALTER TABLE `sys_group_permission` change column `modified_user_id` `modified_user_id` BIGINT(20) UNSIGNED NOT NULL comment '修改用户ID';
ALTER TABLE `sys_group_permission` change column `creation_user_id` `creation_user_id` BIGINT(20) UNSIGNED NOT NULL comment '创建用户ID';

-- ----------------------------
--  45Table Alter for `sys_role_permission`
-- ----------------------------
ALTER TABLE `sys_role_permission` change column `id` `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT comment '唯一标识';
ALTER TABLE `sys_role_permission` change column `role_id` `role_id` BIGINT(20) UNSIGNED NOT NULL comment '角色ID';
ALTER TABLE `sys_role_permission` change column `premisson_id` `premisson_id` BIGINT(20) UNSIGNED NOT NULL comment '权限ID';
ALTER TABLE `sys_role_permission` change column `type` `type` VARCHAR(20) NOT NULL comment '类型';
ALTER TABLE `sys_role_permission` change column `account_id` `account_id` BIGINT(20) DEFAULT NULL comment '账户ID';
ALTER TABLE `sys_role_permission` change column `modified_time` `modified_time` DATETIME(6) DEFAULT NULL comment '修改时间';
ALTER TABLE `sys_role_permission` change column `creation_time` `creation_time` DATETIME(6) DEFAULT NULL comment '创建时间';
ALTER TABLE `sys_role_permission` change column `modified_user_id` `modified_user_id` BIGINT(20) DEFAULT NULL comment '修改用户ID';
ALTER TABLE `sys_role_permission` change column `creation_user_id` `creation_user_id` BIGINT(20) DEFAULT NULL comment '创建用户ID';
ALTER TABLE `sys_role_permission` change column `modified_user_name` `modified_user_name` varchar(50) DEFAULT NULL comment '修改用户名称';
ALTER TABLE `sys_role_permission` change column `creation_user_name` `creation_user_name` varchar(50) DEFAULT NULL comment '创建用户名称';












