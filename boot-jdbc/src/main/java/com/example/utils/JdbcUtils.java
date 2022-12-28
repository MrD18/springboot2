package com.example.utils;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.util.Properties;

/**
 * @Author: dhao
 * @Date: 2021/6/24 4:36 下午
 */
public class JdbcUtils {
    //加载驱动
    static{
        try {
            Class.forName("com.mysql.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
    //获取连接(自己决定，封装到方法中)
    //static静态，直接使用类名.方法名更方便
    public static Connection getconnection() throws Exception{
        String url="jdbc:mysql://localhost:3306/cloudwise1?userUnicode=true&characterEncoding=utf8";
        String user="root";
        String password="12345678";
        Connection conn=DriverManager.getConnection(url,user,password);
        return conn;
    }
    //释放资源
    public static void release(ResultSet rs, Statement st, Connection conn) throws Exception{
        if(rs!=null){
            rs.close();
        }
        if(st!=null){
            st.close();
        }
        if(conn!=null){
            conn.close();
        }
    }
}
