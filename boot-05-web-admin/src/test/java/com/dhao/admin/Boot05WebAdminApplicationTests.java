package com.dhao.admin;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.dhao.admin.entity.Books;
import com.dhao.admin.mapper.BookMyBatisPlusMapper;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.cache.CacheProperties;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;

import java.util.List;

@SpringBootTest
@Slf4j
class Boot05WebAdminApplicationTests {
  @Autowired
  private  RedisTemplate redisTemplate;
  @Autowired
  private StringRedisTemplate stringRedisTemplate;
  @Autowired
    private BookMyBatisPlusMapper bookMyBatisPlusMapper;

    @Test
    void contextLoads() {
    }

    @Test
    public  void  testMybatisPuls(){
        LambdaQueryWrapper<Books> lambdaQuery = Wrappers.lambdaQuery();
        lambdaQuery.like(Books::getBookName,"java");
        List<Books> books = bookMyBatisPlusMapper.selectList(lambdaQuery);

        log.info("测试bookMyBatisPlusMapper查询到的数据:{}",books);
    }

 /*   如果你的数据是复杂的对象类型，而取出的时候又不想做任何的数据转换，直接从Redis里面取出一个对象，
    那么使用RedisTemplate是更好的选择*/
    @Test
    public void  testRedis(){
          redisTemplate.opsForValue().set("k11","v11");
        Object k11 = redisTemplate.opsForValue().get("k11");
        log.info("redis中k1:{}",k11);
    }


     /*当你的redis数据库里面本来存的是字符串数据或者你要存取的数据就是字符串类型数据*/
    @Test
    public void testStringRedis(){

        stringRedisTemplate.opsForValue().set("k111","v111");
        String k111 = stringRedisTemplate.opsForValue().get("k111");
        log.info("StringRedis,k111:{}",k111);
    }
}
