package com.dhao.admin.mapper;
import com.dhao.admin.entity.Books;

import java.util.List;
/**
 * @author: duhao
 * @date: 2021/1/22 16:57
 */
public interface BookMapper {

    List<Books> findAll();

    void insert(Books book);
}
