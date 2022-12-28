package com.dhao.admin.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;

/**文件上传测试
 * @author: duhao
 * @date: 2021/1/17 15:43
 */
@Controller
@Slf4j
public class FormTestController {

    @GetMapping("/form_layouts")
    public  String form_layouts(){

        return "form/form_layouts";
    }


    /**
     *
     * 文件上传自动配置类-MultipartAutoConfiguration-MultipartProperties
     * 包括文件的大小等限制
     *
     * MultipartFile 自动封装上传过来的文件
     * @param email
     * @param username
     * @param headerImg  MultipartFile   接受传过来文件 单个文件
     * @param photos  MultipartFile[] 接受传过来的文件, 多个文件
     * @return
     */
    @PostMapping("/upload")
    public  String  upload(@RequestParam("email")String email,
                           @RequestParam("username")String username, //参数类型注解
                           @RequestPart("headerImg")MultipartFile headerImg, // 文件上传注解, 有对应的参数解析器去解析R
                           @RequestPart("photos")MultipartFile[] photos) throws IOException {

       log.info("上传过来的文件信息: email={},username={},headerImg={},photos={}",
               email,username,headerImg,photos);
         // 对文件进行判断
        if (!headerImg.isEmpty()){ // 不等于空
            // 上传本地或者服务器
            String originalFilename = headerImg.getOriginalFilename();// 获取文件的原始名字
            headerImg.transferTo(new File("D:\\Data\\"+originalFilename));
        }
        //前端上传过来的是多个文件
        if (photos.length>0){
            for (MultipartFile photo : photos) {
                String originalFilename = photo.getOriginalFilename();
           /*transferTO()方法，地底层是一个copy方法, 它里面的很多其他方法都可以参考下
           * FileCopyUtils.copy()
           * */

                photo.transferTo(new File("D:\\Data\\"+originalFilename));
            }

        }
          return "main";

    }


}
