package com.dhao.controller;

import com.dhao.utils.SpringContextUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author: duhao
 * @date: 2021/1/1 9:23
 */
@RestController
public class GetControllerBean {

   // 把controller当做一个bean,已经注入到了容器中,可以通过容器拿取到这个bean,并且调用其中的方法
    // 测试 需要同种方法类型,
    @PostMapping ("/testGetControllerBean")
    public String testGetControllerBean(){
        HelloController helloController = SpringContextUtils.getBean("helloController", HelloController.class);
        String s = helloController.handle01();
     return s;

    }
}
