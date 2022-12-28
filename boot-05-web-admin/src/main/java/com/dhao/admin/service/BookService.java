package com.dhao.admin.service;

import com.dhao.admin.entity.Books;

import java.util.List;

/**
 * @author: duhao
 * @date: 2021/1/22 16:52
 */
public interface BookService {
    List<Books> findAll();

}
