package com.dhao.utils;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.Arrays;
import java.util.Properties;

/**
 * @Description TODO
 * @Author: william.zhang
 * @Date: 2021-07-27 16:36
 **/
public class Consumer {
    public static void main(String[] args) {
        //配置信息
        Properties props = new Properties();
        //kafka服务器地址
        props.put("bootstrap.servers", "10.0.14.178:9092,10.0.14.184:9092");
        //必须指定消费者组
        props.put("group.id", "test");
        //设置数据key和value的序列化处理类
        props.put("key.deserializer", StringDeserializer.class);
        props.put("value.deserializer", StringDeserializer.class);
        //创建消息者实例
        KafkaConsumer<String,String> consumer = new KafkaConsumer<String,String>(props);
        //订阅topic1的消息
      //  consumer.subscribe(Arrays.asList("prometheus_dh3"));
        consumer.subscribe(Arrays.asList("ESB_1"));
        //到服务器中读取记录
        while (true){
            ConsumerRecords<String,String> records = consumer.poll(Duration.ofMillis(100));
            for(ConsumerRecord<String,String> record : records){
                System.out.println("key:" + record.key() + "" + ",value:" + record.value());
            }
        }
    }
}
