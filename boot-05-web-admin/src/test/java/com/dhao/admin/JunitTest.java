package com.dhao.admin;

import com.alibaba.druid.sql.dialect.sqlserver.ast.SQLServerOutput;
import org.junit.jupiter.api.*;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.Duration;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

/**
 * @author: duhao
 * @date: 2021/1/23 22:15
 */
@SpringBootTest // 加上@SpringBootTest 注解才表示为spring的测试,里面就可以注入Bean来进行测试
@DisplayName("Junit5功能测试")
public class JunitTest {
   private final String envirment="DEV";

/** 前置条件测试:
 * 前置条件（assumptions【假设】）类似于断言，不同之处在于不满足的断言会使得测试方法失败，
 * 而不满足的前置条件只会使得测试方法的执行终止。前置条件可以看成是测试方法执行的前提，当该前提不满足时，
 * 就没有继续执行的必要。
 */
@DisplayName("前置条件")
@Test
public void assumeThenDo(){
     Assumptions.assumeTrue(Objects.equals(this.envirment,"DEV")); // 返回结果是true,就执行了
     Assumptions.assumeFalse(()->Objects.equals(this.envirment,"PROD"));  //返回结果是false,就执行了
}




    /**
     * 断言: 前面的断言失败,后面的断言就不会执行
     */
    @DisplayName("测试简单断言")
    @Test
    void testAssertions(){
        int cal = cal(2, 3);
        //1. assertEquals:判断返回来的值,是否与预期的值相同,其他方法都在Assertions这个包中
         assertEquals(5,cal);
        //不相等的话,可以设定异常信息
       // Assertions.assertEquals("5",cal,"业务逻辑返回数据异常");

       //2. 判断是否为同一个对象
        Object o = new Object();
        Object o1 = new Object();
        Assertions.assertSame(o,o1,"两个对象不一样");

    }

    int cal(int i,int j){
        return i+j;
    }

    /**
     * 3.通过 assertArrayEquals 方法来判断两个对象或原始类型的数组是否相等
     */
    @Test
    @DisplayName("测试数组断言")
    public void array() {
        assertArrayEquals(new int[]{1, 2}, new int[] {1, 2});
    }

    /**
     * 4.多个断言同时成立,才算成立
     */
    @Test
    @DisplayName("组合断言")
    public void all() {
        assertAll("Math",
                () -> assertEquals(2, 3 + 1,"如果异常测结果就不是2"),
                () -> assertTrue(1 > 0,"如果异常,则结果<0")
        );
    }

    /**
     *5.出现异常,才算正常,
     */
    @Test
    @DisplayName("异常断言测试")
    public void exceptionTest() {
        //断定业务逻辑一定会出现异常,出现异常就会正常执行, 没出现异常就会报错
         Assertions.assertThrows(ArithmeticException.class,()->{
             int i= 10/0;
             //扔出断言异常
         },"程序居然能正常运行?");
    }


    /**
     * 6. 断言测试超时
     */
    @Test
    @DisplayName("超时测试")
    public void timeoutTest() {
        //如果测试方法时间超过1s将会异常
        Assertions.assertTimeout(Duration.ofMillis(1000), () -> Thread.sleep(500));
    }

    /**
     * 7. 测试快速失败
     */
    @Test
    @DisplayName("断言测试快速失败")
    public void shouldFail() {
        // xxx各种业务代码,来一个条件,如果成立,就快速失败
        if(1==2){
            fail("测试失败");
        }

    }


    @DisplayName("测试dispayname注解")
    @Test
    void testDisplayName(){
        System.out.println(1);
    }

    @Disabled // 标注后表示此测试方法不执行
    @DisplayName("测试方法2")
    @Test
    void test2(){
        System.out.println(2);
    }


    @BeforeEach
    void testBeforEach(){
        System.out.println("@BeforeEach注解,每个方法运行前都要执行-->");
    }
    @AfterEach
    void testAfterEach(){
        System.out.println(" @AfterEach,每个方法运行后都要执行-->");
    }
    @BeforeAll
    static void testBeforeAll(){
        System.out.println("@BeforeAll,所有测试方法前都要执行-->");
    }
    @AfterAll
   static    void testAfterAll(){
    System.out.println("@AfterAll,所有方法执行后都要执行-->");

}

    /**
     *测试在规定的时间内完成, 超出后测试异常
     * @throws InterruptedException
     */
    @Timeout(value = 500,unit = TimeUnit.MILLISECONDS)
    @Test
   void testTimeOut() throws InterruptedException {
        Thread.sleep(600);
    }

    /**@RepeatedTest(5)
     * 重复测试
     */
   @RepeatedTest(5)
    @Test
    void test3(){
       System.out.println("@RepeatedTest(5)进行重复测试-->5次");
   }


}
