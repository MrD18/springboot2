package com.dhao.entity;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * @author: duhao
 * @date: 2021/1/1 17:29
 */
@Data
//@Component
@ConfigurationProperties(prefix = "mycar")
//只有在容器中的组件，@ConfigurationProperties 这个注解才能生效
//所以要和@Component  搭配使用或者在config配置类中 @EnableConfigurationProperties(Car.class) 搭配使用
public class Car {
    private String brand;
    private Integer price;
}
