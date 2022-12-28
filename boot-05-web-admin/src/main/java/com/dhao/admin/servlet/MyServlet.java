package com.dhao.admin.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**自定义拦截器
 * @author: duhao
 * @date: 2021/1/20 16:29
 */
//@WebServlet(urlPatterns = {"/my","/my2"})
// 第一种方法配置: @WebServlet+@ServletComponentScan
public class MyServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
         resp.getWriter().write("6666");
         // 这样就获取到了Cookie
        System.out.println( req.getHeader("Cookie"));
    }
}
