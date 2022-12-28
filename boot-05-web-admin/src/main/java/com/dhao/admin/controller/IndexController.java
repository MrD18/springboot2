package com.dhao.admin.controller;

import com.dhao.admin.entity.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

import javax.servlet.http.HttpSession;

/**
 * @author: duhao
 * @date: 2021/1/10 9:43
 */
@Controller
@Slf4j
public class IndexController {


    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    /**来登录页
     * @return
     */
    @GetMapping(value = {"/","/login"})
    public  String loginPage(){
        return "login";
    }


    /**
     * 表单提交
     * @return
     */
    @PostMapping("/login")
    public String main(User user, HttpSession session, Model model){
        log.info("接受前端数据->username:{},passwprd:{}",user.getUserName(),user.getPassword());
         //数据校验  //!StringUtils.isEmpty(user.getUserName())&&StringUtils.hasLength(user.getPassword())
        if (!StringUtils.isEmpty(user.getUserName())&&"123456".equals(user.getPassword())){
            // 数据session中保存一份
            session.setAttribute("loginUser",user);
            // 登录成功后重定向到main.html,避免重复提交表单
            return "redirect:/main.html";
        }else {
            // 错误数据页面返回
            model.addAttribute("msg","账号密码错误");
            //返回登录页面
            return "login";
        }
    }

    /**
     * 去main页面
     * @return
     */
    @GetMapping("/main.html")
    public String mainPage(HttpSession session,Model model){
        log.info("当前方法是:{}","mainPage");

        // 判断是否登录, 拦截器,过滤器---> 已经在拦截器中做了, 直接return "main"
   /*     Object loginUser = session.getAttribute("loginUser");
        if (loginUser!=null){
            return "main";
        }else {
            //回到登录页面
            model.addAttribute("msg","请重新登录");
            return "login";
        }*/

     /*从Redis中获取,想用的URL统计*/
        String s = stringRedisTemplate.opsForValue().get("/main.html");
        String s1 = stringRedisTemplate.opsForValue().get("/dynamic_table");

     model.addAttribute("mainCount",s);
     model.addAttribute("dynamicCount",s1);


        return "main";
    }
}
