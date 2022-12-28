package com.dhao.admin.exception;

import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerExceptionResolver;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**自定义实现HandlerExceptionResolver 处理异常, 可以作为默认的全局异常处理规则
 * @author: duhao
 * @date: 2021/1/17 22:09
 */
//@Order(0) // 优先级,数字越小,优先级越高
@Order(value = Ordered.HIGHEST_PRECEDENCE) // 数字越小,优先级越高
@Component
public class CustomerHandlerExceptionResolver implements HandlerExceptionResolver {
    @Override
    public ModelAndView resolveException(HttpServletRequest httpServletRequest,
                                         HttpServletResponse httpServletResponse,
                                         Object o, Exception e) {
        try {
            httpServletResponse.sendError(512,"我自定义的异常");
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return new ModelAndView();
    }
}
