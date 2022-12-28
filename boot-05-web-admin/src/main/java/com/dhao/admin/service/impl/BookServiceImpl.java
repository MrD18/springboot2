package com.dhao.admin.service.impl;


import com.dhao.admin.entity.Books;
import com.dhao.admin.mapper.BookMapper;
import com.dhao.admin.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author: duhao
 * @date: 2021/1/22 16:55
 */
@Service
public class BookServiceImpl implements BookService {

      @Autowired
      private BookMapper bookMapper;

    @Override
    public List<Books> findAll() {
        return  bookMapper.findAll();

    }


}
