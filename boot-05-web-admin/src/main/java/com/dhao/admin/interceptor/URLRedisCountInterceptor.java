package com.dhao.admin.interceptor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**1.用Redis统计访问路径的次数,拦截器
 * 2. 将这个拦截器加入到webConfig中
 * @author: duhao
 * @date: 2021/1/23 16:13
 */
@Configuration
public class URLRedisCountInterceptor  implements HandlerInterceptor {

      @Autowired
      private StringRedisTemplate stringRedisTemplate;

   // 访问前拦截
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String uri = request.getRequestURI();
        // 每次访问都+1
        stringRedisTemplate.opsForValue().increment(uri);

        // 每次都放行
        return true;
    }
}
