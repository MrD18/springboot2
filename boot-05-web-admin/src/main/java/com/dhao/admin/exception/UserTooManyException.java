package com.dhao.admin.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/** @ResponseStatus+自定义异常, 底层是ResponseStatusExceptionResolver,把
 * responsestatus注解的信息底层调用 response.sendError(statusCode, resolvedReason)；tomcat发送的/error
 * @author: duhao
 * @date: 2021/1/17 21:47
 */
@ResponseStatus(value = HttpStatus.FORBIDDEN,reason = "用户数量太多")
/*@ResponseStatus 用这个注解标注的,最后返回一个状态码*/
public class UserTooManyException extends RuntimeException {

    public  UserTooManyException(){
    }
    public  UserTooManyException(String message){
        super(message);
    }


}
