package com.dhao.admin.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

/**处理整个web controller的异常, 这是一种方法
 *@ControllerAdvice+@ExceptionHandler处理全局异常；底层是
 * ExceptionHandlerExceptionResolver 支持的
 * @author: duhao
 * @date: 2021/1/17 20:12
 */
@Slf4j
@ControllerAdvice
public class GlobalExceptionHandler {
    // 处理数字运算异常, 处理空指针异常
    @ExceptionHandler({ArithmeticException.class,NullPointerException.class}) // 处理异常的类, 里面可以写很多异常的类
    public  String handleArithException(Exception e){
           log.info("异常是:{}",e);
        return "login";   // 接受异常后,返回的视图地址

    }
}
