package com.dhao.admin.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

/**
 * @author: duhao
 * @date: 2021/1/10 10:48
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class User implements Serializable {
    private  String userName;
    private  String password;

}
