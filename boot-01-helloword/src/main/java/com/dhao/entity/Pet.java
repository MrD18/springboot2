package com.dhao.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * @author: duhao
 * @date: 2021/1/1 11:05
 */

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Pet {
    private String name;
    private Double weight;
    public Pet(String name) {
    }
}
