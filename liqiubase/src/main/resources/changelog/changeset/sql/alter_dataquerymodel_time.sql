ALTER TABLE `biz_data_query_model_history` change column `modified_time` `modified_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间';
ALTER TABLE `biz_data_query_model_history` change column `creation_time` `creation_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间';
