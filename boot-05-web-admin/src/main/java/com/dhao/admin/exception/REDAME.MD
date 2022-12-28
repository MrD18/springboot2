
# 系统默认异常解析器有3个
* ExceptionHandlerExceptionResolver
  * 方式一:  @ControllerAdvice+@ExceptionHandler处理的全局异常,底层就是上述的这个异常处理器
* ResponseStatusExceptionResolver
  * 方式二:  @ResponseStatus+自定义异常, 底层就是ResponseStatusExceptionResolver处理,把
     responsestatus注解的信息组装成ModelAndView返回, 底层调用的是response.sedError(statusCode,resolvedReason) 
     直接结束, tomcat发送的/error
* DefaultHandlerExceptionResolver

