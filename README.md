1. @Configuration(proxyBeanMethods =true) 配置类的改变 
 *  proxyBeanMethods:代理bean的方法
     *  true: 保持组件单实例!!! springboot总会检查这个组件,如果有就不在创建,
     *  false: 多实例
 *  解决问题:组件依赖, 
      *  如果组件作用单一,别人也不依赖的话就将属性改为false,服务启动特别快
      *  如果别的组件还要依赖该组件,那就得调成true,保持单实例

2.@Import({User.class, DBHelper.class})-->
 *  可以导入第三方的jar包中的
 *  给容器中自动创建出这两个类型的组件,默认组件的名称就是全类名
   ``` // 获取组件,也可以是jar包中的
               String[] beanNamesForType = run.getBeanNamesForType(User.class);
               System.out.println("=======");
               for (String s : beanNamesForType) {
                   System.out.println(s);
               }
              // 第三方导出的jar包中类
               DBHelper bean = run.getBean(DBHelper.class);
               System.out.println(bean); 
    
   ```
   ```
   输出名称:
   com.dhao.entity.User
   user
   ch.qos.logback.core.db.DBHelper@6a0094c9
   ``` 

3.条件装配：满足Conditional指定的条件，则进行组件注入, 有很多的条件
 * @ConditionalOnBean(name = "tom22") 加在类上面,先判断容器中有没有tom22, 然后才会加载里面的bean     
 * @ConditionalOnBean(name = "user")  加在bean上面, 容器中有user的时候,才会加载这个bean
 ```
@Import({User.class, DBHelper.class})
@Configuration(proxyBeanMethods =true)
//@ConditionalOnBean(name = "tom22")// 加在类上面,先判断容器中有没有tom22, 然后才会加载里面的bean
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
```
4.@ImportResource 原生配置文件导入
* 之前有些老的项目还在用xml方式注入bean,现在不想想之前那样,写一个config,然后@bean注入,太麻烦
直接中这个注解将xml配置的组件全部导入,当然前提是每个都有对应的实体类哈
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context https://www.springframework.org/schema/context/spring-context.xsd">

    <bean id="haha" class="com.dhao.entity.User">
        <property name="username" value="zhangsan"></property>
        <property name="age" value="18"></property>
    </bean>

    <bean id="hehe" class="com.dhao.entity.Pet">
        <property name="petName" value="tomcat"></property>
    </bean>
</beans>
```
```
@ImportResource("classpath:beans.xml")
public class MyConfig {
}

        // 配置文件中的bean导入
        System.out.println("=========测试beans.xml中的组件导入======");
        boolean haha = run.containsBean("haha");
        boolean hehe = run.containsBean("hehe");
        System.out.println("haha："+haha);//true
        System.out.println("hehe："+hehe);//true

```
5.参数绑定
@ConfigurationProperties(prefix = "mycar") 将配置文件中的参数绑定到这个类上面
```
@Data
//@Component
@ConfigurationProperties(prefix = "mycar")
//只有在容器中的组件，@ConfigurationProperties 这个注解才能生效
//所以要和@Component  搭配使用或者在config配置类中 @EnableConfigurationProperties(Car.class) 搭配使用
public class Car {
    private String brand;
    private Integer price;
}

```
```
@Import({User.class, DBHelper.class})
@Configuration(proxyBeanMethods =true)
//@ConditionalOnBean(name = "tom22")// 加在类上面,先判断容器中有没有tom22, 然后才会加载里面的bean
@ImportResource("classpath:beans.xml")
@EnableConfigurationProperties(Car.class)
public class MyConfig {
```
6.yaml文件注入属性:

```
person:
  userName: zhangsan
  boss: false
  birth: 2019/12/12 20:12:33
  age: 18
  pet:
    petName: tomcat
    weight: 23.4
  interests: [篮球,游泳]
  animal:
    - jerry
    - mario
  score:
    english:
      first: 30
      second: 40
      third: 50
    math: [131,140,148]
    chinese: {first: 128,second: 136}
  salarys: [3999,4999.98,5999.99]
  allPets:
    sick:
      - {name: tom}
      - {name: jerry,weight: 47}
    health: [{name: mario,weight: 47}]
```
```
package com.dhao.entity;

import lombok.Data;
import lombok.ToString;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @author: duhao
 * @date: 2021/1/2 13:30
 */
@Data
@ToString
@Component
@ConfigurationProperties(prefix = "person")

public class Person {
   // @Value("${person.userName}")
    private String userName;
 //   @Value("${person.boss}")
    private Boolean boss;
 //   @Value("${person.birth}")
    private Date birth;
 //   @Value("${person.age}")
    private Integer age;
 //   @Value("${person.pet}")
    private Pet pet;
 //   @Value("${person.interests}")
    private String[] interests;
  //  @Value("${person.animal}")
    private List<String> animal;
  //  @Value("${person.score}")
    private Map<String, Object> score;
  //  @Value("${person.salarys}")
    private Set<Double> salarys;
 //   @Value("${person.allPets}")
    private Map<String, List<Pet>> allPets;
}

```