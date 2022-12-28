package com.example;

import com.example.utils.JdbcUtils;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;


@SpringBootTest
class BootJdbcApplicationTests {

    @Test
    void contextLoads() {
    }
    @Autowired  /**注入jdbc操作模板*/
       private JdbcTemplate jdbcTemplate;


    @Test
    public void test1() throws Exception {
        Connection con = null;
        Statement st = null;
        try {
            con = JdbcUtils.getconnection();
            st = con.createStatement();
//            String sql1 = "create database batch_test";
//            String sql2 = "use batch_test";
//            String sql3 = "create table batch(id int primary key auto_increment,name varchar(20),password varchar(20))";
//            String sql4 = "insert into batch values(null,'zhangsan','123')";
//            String sql5 = "insert into batch values(null,'lisi','123')";
//            String sql6 = "insert into batch values(null,'wangwu','123')";
            String sql1 = "select * from batch_test.batch";
        /*    st.addBatch(sql1);
            st.addBatch(sql2);
            st.addBatch(sql3);
            st.addBatch(sql4);
            st.addBatch(sql5);
            st.addBatch(sql6);*/
            ResultSet resultSet = st.executeQuery(sql1);
            System.out.println(resultSet);
        } catch (Exception e) {
            e.printStackTrace();
        }finally{
            JdbcUtils.release(null,st,con);
        }
    }
}
