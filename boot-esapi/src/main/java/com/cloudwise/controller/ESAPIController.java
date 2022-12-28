package com.cloudwise.controller;

import org.owasp.esapi.ESAPI;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @Author: dhao
 * @Date: 2021/6/17 10:04 上午
 */
@RestController
public class ESAPIController {

    @GetMapping("esapi")
    public String esapi(){
        String str = "<div style=\"color:red;\">esapi</div><script>alert(\"esapi\")</script>";
        System.out.println("strbegin:---->"+str);
        str = ESAPI.encoder().encodeForHTML(str);
       System.out.println("strend:----->"+str);
        return str;
    }
}
