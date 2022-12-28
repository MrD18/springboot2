package com.dhao.config;

import ch.qos.logback.core.db.DBHelper;
import com.dhao.entity.Car;
import com.dhao.entity.Pet;
import com.dhao.entity.User;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.ImportResource;

/**
 * @author: duhao
 * @date: 2021/1/1 8:50
 * 1.配置类里面使用@Bean标注在方法上面给容器祖册组件,默认也是单实例的
 * 2. 配置类本身也是组件
 * 3.proxyBeanMethods:代理bean的方法
 *     默认 true: 保持组件单实例!!! springboot总会检查这个组件,如果有就不在创建,
 *         false: 多实例
 *  解决问题:组件依赖, 如果组件作用单一,别人也不依赖的话就将属性改为false,服务启动特别快
 *                  如果别的组件还要依赖该组件,那就得调成true,保持单实例
 * 4.@Import({User.class, DBHelper.class})-->可以导入第三方的jar包中的
 *    给容器中自动创建出这两个类型的组件,默认组件的名称就是全类名
 *
 */
@Import({User.class, DBHelper.class})
@Configuration(proxyBeanMethods =true)
//@ConditionalOnBean(name = "tom22")// 加在类上面,先判断容器中有没有tom22, 然后才会加载里面的bean
@ImportResource("classpath:beans.xml")
@EnableConfigurationProperties(Car.class)
public class MyConfig {

    @Bean(name = "user")
    public User getUser(){

        return new User("zhansan",2);
    }
  //  @ConditionalOnBean(name = "user") //加在bean上面, 容器中有user的时候,才会加载这个bean
    @Bean(name = "tom22")
    public Pet tomcatPet(){
        return new Pet("tomcat");
    }
}
