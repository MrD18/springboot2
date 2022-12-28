package com.dhao.controller;

import com.dhao.common.BaseRestResponse;
import com.dhao.entity.User;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author: duhao
 * @date: 2021/1/3 10:20
 */
@RestController
public class ParameterTestController {
  // http://localhost:8080/user/1/ower/zhangsan
    @GetMapping("/user/{id}/ower/{username}")
    public BaseRestResponse<String> getPathVariable(@PathVariable("id") Integer id,  // 获取路径上的参数
                                                    @PathVariable("username") String username, // 获取路径上的参数
                                                    @PathVariable Map<String,String> pv, // 获取路径上的所有参数,并封装在map中
                                                    @RequestHeader("User-Agent")String userAgent, //获取单个请求头
                                                    @RequestHeader Map<String,String> header){  //获取所有请求头

        Map<Object, Object> map = new HashMap<Object, Object>();
        map.put("id",id);
        map.put("username",username);
        map.put("pv",pv);
        map.put("userAgent",userAgent);
        map.put("headers",header);

        return BaseRestResponse.success().data(map);

    }
  //http://localhost:8080/car?age=18&username=zhansan&inters=basktball&inters=game
    @GetMapping("/car")
    public BaseRestResponse<String> getRequestParam(@RequestParam("age") Integer age,// 获取路径k-v 形式的参数
                                                    @RequestParam("username")String username, // 获取路径k-v 形式的参数
                                                    @RequestParam("inters")List<String> inters, // 获取路径k-v 形式的参数,是以List形式
                                                    @RequestParam Map<String,String> params
                                                 //  @CookieValue("_ga") String _ga   // 获取某一个cookie的值
                                                  //  @CookieValue Cookie cookie //  获取所有cookie的值
    ){

        Map<Object, Object> map = new HashMap<Object, Object>();
        map.put("age",age);
        map.put("username",username);
        map.put("inters",inters);
        map.put("params",params);
       //  map.put("_ga",_ga);
       // map.put("cookie",cookie);
     //   System.out.println(cookie.getName());

        return BaseRestResponse.success().data(map);
    }
     // Post 表单提交
    @PostMapping("/save")
    public BaseRestResponse<String> testRequestBody(@RequestBody User user ) {
        System.out.println(user);
        return BaseRestResponse.success().data(user);
    }
/*矩阵变量1:
* 1.语法: /cars/sell;low=34;brand=bdy,audi,yd
* 2. SpringBoot 默认是禁止了矩阵变量的功能
*     手动开启: 原理,对于路径的处理,UrlPathHelper 进行解析.
*      removeSemicolonContent(移除分号内容) 支持矩阵变量的
* 3. 矩阵变量必须有url路径变量才能被解析
* */
@GetMapping("/cars/{path}")
    public  BaseRestResponse<String> carsSell(@MatrixVariable("low") Integer low,
                                              @MatrixVariable("brand") List<String> brand,
                                              @PathVariable("path") String path){
    Map<Object, Object> map = new HashMap<Object, Object>();
    map.put("low",low);
    map.put("brand",brand);
    map.put("path",path);
    System.out.println(map);
    return BaseRestResponse.success().data(map);

}
    /*矩阵变量2: age 相同的变量名
     * 1.语法: /boss/1;age=20/2;age=10
     * 2. SpringBoot 默认是禁止了矩阵变量的功能
     *     手动开启: 原理,对于路径的处理,UrlPathHelper 进行解析.
     *      removeSemicolonContent(移除分号内容) 支持矩阵变量的
     * */
    @GetMapping("/boss/{bossId}/{empId}")
    public  Map boss(@MatrixVariable(value = "age",pathVar = "bossId") Integer bossAge,
                     @MatrixVariable(value = "age",pathVar = "empId") Integer empAge){
        Map<Object, Object> map = new HashMap<Object, Object>();
        map.put("bossAge",bossAge);
        map.put("empAge",empAge);
        return map;
    }
}
