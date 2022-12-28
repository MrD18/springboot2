package com.dhao.controller;

import com.dhao.common.BaseRestResponse;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Map;

/**
 * @author: duhao
 * @date: 2021/1/3 14:47
 */
@Controller
public class AttributeController {


    /*正常情况下,直接将setAttribute 设置的值,跳转到前端页面进行显示
    *  现在是跳转到 /success 这个路径, 然后用注解取跳转过来的值或者用request 中取值*/
    @GetMapping("/goto")
    public String goToPage(HttpServletRequest request){
          request.setAttribute("msg","成功了...");
           request.setAttribute("code",200);
           return "forward:/success";   // 转发到 /success请求
    }

    @GetMapping("/success")
   @ResponseBody                                  /*required=false  非必传参数*/
    public BaseRestResponse<String> success(@RequestAttribute(value = "msg",required = false)String msg,
                                            @RequestAttribute(value = "code",required = false)Integer code,
                                            HttpServletRequest request){

        // 可以用request取
        Object msg1 = request.getAttribute("msg");
        Object hello = request.getAttribute("hello");
        Object hello2 = request.getAttribute("hello2");
        Object message = request.getAttribute("message");
        System.out.println("request取msg:"+msg1);
        // 也可以用注解取
        System.out.println("注解取msg:"+msg);
        Map<String, Object> map = new HashMap<>();
        map.put("reqMethod_msg",msg);
        map.put("annotation_msg",msg1);
        map.put("hello",hello);
        map.put("hello2",hello2);
        map.put("message",message);


        return BaseRestResponse.success().data(map);
    }

/*复杂参数:
* Map、Model（map、model里面的数据会被放在request的请求域  request.setAttribute）、  都是放在request的请求域中, 都能取到
* Errors/BindingResult、
* RedirectAttributes（ 重定向携带数据）
* ServletResponse（response）、
* SessionStatus、
* UriComponentsBuilder、
* ServletUriComponentsBuilder*/
@GetMapping("/params")
public String testParam(Map<String,Object> map,
                        Model model,
                        HttpServletRequest request,
                        HttpServletResponse response){
      map.put("hello","world666");
      model.addAttribute("hello2","world77777");
      request.setAttribute("message","HelloWorld");
    Cookie cookie = new Cookie("c1", "v1");
     response.addCookie(cookie);
      return "forward:/success";

}


}



