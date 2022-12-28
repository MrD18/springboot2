package com.dhao.admin.servlet;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.boot.web.servlet.ServletListenerRegistrationBean;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.servlet.ServletRegistration;
import java.util.Arrays;

/** 第二种配置方式, 以spring 配置文件的方式进行
 * @author: duhao
 * @date: 2021/1/20 17:05
 */
//(proxyBeanMethods = true): 保证依赖的组件始终是单实例的
@Configuration(proxyBeanMethods = true)
public class MyRegisConfig {

    @Bean
    public ServletRegistrationBean myServlet(){
        MyServlet myServlet = new MyServlet();
        return new ServletRegistrationBean(myServlet,"/my","/my02");
    }

    @Bean
    public FilterRegistrationBean myFilter(){
        MyFilter myFilter = new MyFilter();
     //   return  new FilterRegistrationBean(myFilter,myServlet()); 这是一种方式!
        FilterRegistrationBean filterRegistrationBean = new FilterRegistrationBean(myFilter);
         filterRegistrationBean.setUrlPatterns(Arrays.asList("/my","/css/*"));
        return filterRegistrationBean;
    }
    @Bean
    public ServletListenerRegistrationBean myListener(){
        MyServletContextListener myServletContextListener = new MyServletContextListener();
        return new ServletListenerRegistrationBean(myServletContextListener);

    }









}
