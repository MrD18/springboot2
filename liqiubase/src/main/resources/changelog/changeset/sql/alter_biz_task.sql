ALTER TABLE `biz_backup_plan` change column `data_store_id` `data_store_id` BIGINT NOT NULL comment '数据表ID';
ALTER TABLE `biz_backup_log` change column `data_store_id` `data_store_id` BIGINT NOT NULL comment '数据表ID';
ALTER TABLE `biz_restore_log` change column `data_store_id` `data_store_id` BIGINT NOT NULL comment '数据表ID';
ALTER TABLE `biz_restore_plan` change column `data_store_id` `data_store_id` BIGINT NOT NULL comment '数据表ID';