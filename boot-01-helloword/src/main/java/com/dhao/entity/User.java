package com.dhao.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * @author: duhao
 * @date: 2021/1/1 8:51
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class User {

    private String username;
    private Integer age;
}
