package com.dhao.admin.servlet;

import lombok.extern.slf4j.Slf4j;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import java.io.IOException;

/** 自定义过滤器
 * @author: duhao
 * @date: 2021/1/20 16:40
 */
@Slf4j
//@WebFilter(urlPatterns = {"/css/*","/images/*"})//这里面放的是过滤的路径
// 第一种方法配置: @WebListener+@ServletComponentScan
public class MyFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
   log.info("MyFilter初始化完成");
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
      log.info("MyFilter 工作了");
        filterChain.doFilter(servletRequest,servletResponse);
    }

    @Override
    public void destroy() {
  log.info("MyFilter 销毁了");
    }
}
