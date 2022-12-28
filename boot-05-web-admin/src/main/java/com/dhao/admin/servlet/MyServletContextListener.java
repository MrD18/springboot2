package com.dhao.admin.servlet;


import lombok.extern.slf4j.Slf4j;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * @author: duhao
 * @date: 2021/1/20 16:49
 */
// @WebListener // 第一种方法配置: @WebListener+@ServletComponentScan
@Slf4j
public class MyServletContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        log.info("MyServletContextListener 监听到项目启动");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        log.info("MyServletContextListener 监听到项目销毁");

    }
}
