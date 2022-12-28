package com.dhao.controller;

import com.dhao.entity.Car;
import com.dhao.entity.Person;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author: duhao
 * @date: 2020/12/31 10:01
 */
@RestController
public class HelloController {

    @GetMapping("/hello")
    public String handle01(){
        return "Hello,Sring Boot 2";
    }

  // 测试配置绑定
    @Autowired
    private Car car;

    @GetMapping("/car")
    public Car car(){
        return car;
    }

    // 测试配置文件注入的值到类中
    @Autowired
    private Person person;
    @GetMapping("/person")
    public Person person(){
        return person;
    }







}
