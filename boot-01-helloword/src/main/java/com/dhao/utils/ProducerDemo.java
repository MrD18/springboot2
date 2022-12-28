package com.dhao.utils;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.util.Properties;

/**
 * @Description kafka消息生产者
 * @Author: william.zhang
 * @Date: 2021-07-26 14:15
 **/
public class ProducerDemo {
    private final KafkaProducer<String, String> producer;
   //ESB_1  HOST_INFO
    public final static String TOPIC = "ESB_1";


    private ProducerDemo() {
        Properties props = new Properties();
        //10.2.3.42:9092,10.2.3.43:9092,10.2.3.44:9092   10.0.12.214:18108
        // 10.2.3.199:18108,10.2.3.200:18108,10.2.3.202:18108
        // 10.0.12.212:18108   10.0.12.212:18108
        props.put("bootstrap.servers", "10.0.14.178:9092,10.0.14.184:9092");//xxx服务器ip
        props.put("acks", "all");//所有follower都响应了才认为消息提交成功，即"committed"
        props.put("retries", 0);//retries = MAX 无限重试，直到你意识到出现了问题:)
        props.put("batch.size", 16384);//producer将试图批处理消息记录，以减少请求次数.默认的批量处理消息字节数
        //batch.size当批量的数据大小达到设定值后，就会立即发送，不顾下面的linger.ms
        props.put("linger.ms", 1);//延迟1ms发送，这项设置将通过增加小的延迟来完成--即，不是立即发送一条记录，producer将会等待给定的延迟时间以允许其他消息记录发送，这些消息记录可以批量处理
        props.put("buffer.memory", 33554432);//producer可以用来缓存数据的内存大小。
        props.put("key.serializer",
                "org.apache.kafka.common.serialization.IntegerSerializer");
        props.put("value.serializer",
                "org.apache.kafka.common.serialization.StringSerializer");

        producer = new KafkaProducer<String, String>(props);
    }

    public void produce() {
        int messageNo = 1;
        final int COUNT = 300;

        while(messageNo < COUNT) {
            String key = String.valueOf(messageNo);
            //ervice\"}");
         //  String data = String.format("{\"_cw_message\":1634268488000,\"_cw_biz\":\"fff\"\"}");
           String data = String.format("{\"_cw_message\":\"2022-02-18 15:50:54,358 INFO  [NoticeExecutor-5 ] esb.log.ESBLogPacket                     93    0156202202182574051875                                                                                                :<soap:Envelope xmlns:soap=\\\"http://schemas.xmlsoap.org/soap/envelope/\\\"><soap:Header><ns3:SysHeaderRes xmlns:ns3=\\\"http://esb.beeb.com.cn/SysHead\\\" xmlns:ns2=\\\"http://esb.beeb.com.cn/product/amitFraud/notification/AllChnlAmitFraudTxnRsltNtcService\\\" xmlns=\\\"http://esb.beeb.com.cn/AppHead\\\"><ns3:ServiceCode>0200500701</ns3:ServiceCode><ns3:Version>1.0.0.1</ns3:Version><ns3:Operation>AllChnlAmitFraudTxnRsltNtc</ns3:Operation><ns3:ConsumerId>0156</ns3:ConsumerId><ns3:ProviderId>0116</ns3:ProviderId><ns3:TranSeqNo>0156202202182574051875</ns3:TranSeqNo><ns3:RespDate>20220218</ns3:RespDate><ns3:RespTime>155054</ns3:RespTime><ns3:RetCodeSysId>0116</ns3:RetCodeSysId><ns3:RetCode>000000</ns3:RetCode><ns3:RetMsg>成功</ns3:RetMsg><ns3:Ext></ns3:Ext></ns3:SysHeaderRes></soap:Header><soap:Body><ns2:AllChnlAmitFraudTxnRsltNtcRes xmlns=\\\"http://esb.beeb.com.cn/AppHead\\\"}");
          // String data = String.format("{\"_cw_hostname\":\"logminer2.localdomain\",\"_cw_host_ip\":\"172.168.100.32\",\"_cw_collect_id\":\"test\",\"_cw_collect_type\":\"CDC\",\"_cw_message\":\"<6>Nov 16 15:27:21 autosys kernel: NET: Unregistered protocol family 36\",\"_cw_collect_time\":\"1605511643525\",\"_cw_log_path\":\"172.168.100.79:58189\"}");
            try {
                producer.send(new ProducerRecord<String, String>(TOPIC, data));
            } catch (Exception e) {
                e.printStackTrace();
            }

            messageNo++;
        }

        producer.close();
    }

    public static void main(String[] args) {
        new ProducerDemo().produce();
    }
}
