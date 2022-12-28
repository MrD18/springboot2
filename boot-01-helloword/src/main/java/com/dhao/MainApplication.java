package com.dhao;

import ch.qos.logback.core.db.DBHelper;
import com.dhao.entity.User;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;

/**
 * @author: duhao
 * @date: 2020/12/31 9:59
 */
@SpringBootApplication
public class MainApplication {

    public static void main(String[] args) {
  ApplicationContext run = SpringApplication.run(MainApplication.class, args);

      //获取所有的bean
        String[] beanNames = run.getBeanDefinitionNames();
        for (String beanName : beanNames) {
            System.out.println(beanName);
        }
        //通过容器拿对象
      /*User user = run.getBean("user", User.class);
        System.out.println(user)*/;

       // 获取组件,也可以是jar包中的
        String[] beanNamesForType = run.getBeanNamesForType(User.class);
        System.out.println("=======");
        for (String s : beanNamesForType) {
            System.out.println(s);
        }
       // 第三方导出的jar包中类
    /*    DBHelper bean = run.getBean(DBHelper.class);
        System.out.println(bean);*/

        // 条件装配
        System.out.println("=========测试条件装配======");
        boolean tom22 = run.containsBean("tom22");
        System.out.println("容器中的Tom22组件:"+tom22);
        boolean user1 = run.containsBean("user");
        System.out.println("容器中的user组件:"+user1);

        // 配置文件中的bean导入
        System.out.println("=========测试beans.xml中的组件导入======");
        boolean haha = run.containsBean("haha");
        boolean hehe = run.containsBean("hehe");
        System.out.println("haha："+haha);//true
        System.out.println("hehe："+hehe);//true
    }
}
