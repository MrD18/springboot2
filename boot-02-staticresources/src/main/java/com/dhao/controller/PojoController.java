package com.dhao.controller;

import com.dhao.common.BaseRestResponse;
import com.dhao.entity.Person;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.text.SimpleDateFormat;

/**
 * @author: duhao
 * @date: 2021/1/7 19:28
 */
@RestController
public class PojoController {


    @PostMapping("/saveUser")
    public BaseRestResponse<Person> saveUser( @RequestBody Person person){
      //  ObjectMapper mapper = new ObjectMapper();
        //自定义日期格式对象
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        System.out.println(sdf.format(person.getBirth()));
        return BaseRestResponse.success().data(person);


    }
}
