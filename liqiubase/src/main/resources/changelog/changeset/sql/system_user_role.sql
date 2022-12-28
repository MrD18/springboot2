-- ----------------------------
--  Table structure for `sys_role`
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  `modified_time` datetime(6) DEFAULT NULL,
  `creation_time` datetime(6) DEFAULT NULL,
  `modified_user_id` bigint(20) DEFAULT NULL,
  `creation_user_id` bigint(20) DEFAULT NULL,
  `modified_user_name` varchar(50) DEFAULT NULL,
  `creation_user_name` char(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
--  Records of `sys_role`
-- ----------------------------
BEGIN;
INSERT INTO `sys_role` VALUES ('1', '1', '管理员', null, null, null, null, null, null), ('2', '1', '高级用户', null, null, null, null, null, null), ('3', '1', '普通用户', null, null, null, null, null, null);
COMMIT;

-- ----------------------------
--  Table structure for `sys_user_role`
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `role_id` bigint(20) unsigned NOT NULL,
  `modified_time` datetime(6) NOT NULL,
  `creation_time` datetime(6) NOT NULL,
  `modified_user_id` bigint(20) DEFAULT NULL,
  `creation_user_id` bigint(20) DEFAULT NULL,
  `modified_user_name` varchar(50) DEFAULT NULL,
  `creation_user_name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
--  Table structure for `sys_user`
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  `modified_time` datetime(6) NOT NULL,
  `creation_time` datetime(6) NOT NULL,
  `password` varchar(100) DEFAULT NULL,
  `cwop_user_id` varchar(40) DEFAULT NULL,
  `cwop_account_id` varchar(40) DEFAULT NULL,
  `status` int(11) NOT NULL,
  `delete_flag` tinyint(3) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `mobile` varchar(255) DEFAULT NULL,
  `account` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4;

BEGIN;
insert into `sys_user` ( `email`, `name`, `account_id`, `mobile`, `modified_time`, `delete_flag`, `password`, `cwop_account_id`, `account`, `creation_time`, `status`, `cwop_user_id`) values ( null, 'admin', '1', null, '2018-11-29 02:39:29.487000', '0', '202cb962ac59075b964b07152d234b70', null, 'admin', '2018-09-21 07:13:12.865000', '1', null);
COMMIT;

-- ----------------------------
--  Table structure for `sys_role_permission`
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `role_id` bigint(20) unsigned NOT NULL,
  `premisson_id` bigint(20) unsigned NOT NULL,
  `type` varchar(20) NOT NULL,
  `account_id` bigint(20) DEFAULT NULL,
  `modified_time` datetime(6) DEFAULT NULL,
  `creation_time` datetime(6) DEFAULT NULL,
  `modified_user_id` bigint(20) DEFAULT NULL,
  `creation_user_id` bigint(20) DEFAULT NULL,
  `modified_user_name` varchar(50) DEFAULT NULL,
  `creation_user_name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4;



BEGIN;
insert into `sys_user` ( `id`, `email`, `name`, `account_id`, `mobile`, `modified_time`, `delete_flag`, `password`, `cwop_account_id`, `account`, `creation_time`, `status`, `cwop_user_id`) values ( 2, 'user1@cloudwise.com', 'user1', '1', null, '2018-11-29 02:39:29.487000', '0', '202cb962ac59075b964b07152d234b70', null, 'user1', '2018-09-21 07:13:12.865000', '1', null);
insert into `sys_user` ( `id`, `email`, `name`, `account_id`, `mobile`, `modified_time`, `delete_flag`, `password`, `cwop_account_id`, `account`, `creation_time`, `status`, `cwop_user_id`) values ( 3, 'user2@cloudwise.com', 'user2', '1', null, '2018-11-29 02:39:29.487000', '0', '202cb962ac59075b964b07152d234b70', null, 'user2', '2018-09-21 07:13:12.865000', '1', null);
COMMIT;