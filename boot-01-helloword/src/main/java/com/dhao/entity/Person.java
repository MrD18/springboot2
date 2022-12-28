package com.dhao.entity;

import lombok.Data;
import lombok.ToString;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @author: duhao
 * @date: 2021/1/2 13:30
 */
@Data
@ToString
@Component
@ConfigurationProperties(prefix = "person")

public class Person {
   // @Value("${person.userName}")
    private String userName;
 //   @Value("${person.boss}")
    private Boolean boss;
 //   @Value("${person.birth}")
    private Date birth;
 //   @Value("${person.age}")
    private Integer age;
 //   @Value("${person.pet}")
    private Pet pet;
 //   @Value("${person.interests}")
    private String[] interests;
  //  @Value("${person.animal}")
    private List<String> animal;
  //  @Value("${person.score}")
    private Map<String, Object> score;
  //  @Value("${person.salarys}")
    private Set<Double> salarys;
 //   @Value("${person.allPets}")
    private Map<String, List<Pet>> allPets;


}
