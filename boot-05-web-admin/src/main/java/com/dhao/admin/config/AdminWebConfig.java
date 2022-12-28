package com.dhao.admin.config;

import com.dhao.admin.interceptor.LoginInterceptor;
import com.dhao.admin.interceptor.URLRedisCountInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**配置拦截器
 * 1.编写一个拦截器实现HandlerInterCeptor接口
 * 2. 拦截器注册到容器中（实现WebMvcConfigurer的addInterceptors）
 * 3. 指定拦截规则【如果是拦截所有，静态资源也会被拦截】
 *
 * filter, Interceptor 几乎拥有同样的功能?
 * a: Fileter是Servler定义的原生组件, 好处,脱离Spring应用也能使用
 * b: Interceptor 是Spring定义的接口,可以使用Spring的自动装配等功能
 *
 * @author: duhao
 * @date: 2021/1/13 22:43
 */
//@EnableWebMvc //全面接管springMVC, 之前的静态资源? 视图解析器? 欢迎页...全部失效, 需要自己配置--->慎用
@Configuration
public class AdminWebConfig implements WebMvcConfigurer {

    /**定义静态资源行为
     * 如果使用了@EnableWebMvc注解,就需要自己进行配置
     * @param registry
     */
    /*@Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
         // 访问 /aa/** 所有请求都去 calsspath:/static/ 下面进行匹配---> 不建议这么使用,用配置文件进行配置多好!!!
         registry.addResourceHandler("/aa/**")
                 .addResourceLocations("classpath:/static/");
    }
*/
      @Autowired
      private URLRedisCountInterceptor urlRedisCountInterceptor;
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
  registry.addInterceptor(new LoginInterceptor())
          .addPathPatterns("/**") // 拦截所有请求
          .excludePathPatterns("/","/login","/css/**","/fonts/**","/images/**","/js/**","/findAll","/insert"); //放行的请求

        /* 添加URLRedis拦截器, 不能new URLRedisCountInterceptor, 因为里面注入的redisTemplaet就会用不了,
        * 可以从容器中直接获取 URLRedisCountInterceptor,因为已经注入到容器了
        * */

     registry.addInterceptor(urlRedisCountInterceptor)
             .addPathPatterns("/**")
             .excludePathPatterns("/","/login","/css/**","/fonts/**","/images/**","/js/**","/findAll","/insert");
    }
}
