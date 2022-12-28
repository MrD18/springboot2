package com.dhao.admin.controller;

import com.dhao.admin.entity.Books;
import com.dhao.admin.mapper.BookMyBatisPlusMapper;
import com.dhao.admin.service.BookMyBatisPlusService;
import com.dhao.admin.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * @author: duhao
 * @date: 2021/1/22 16:59
 */
@RestController
public class bookController {

    @Autowired
    private BookService bookService;
    @Autowired
    private BookMyBatisPlusService bookMyBatisPlusService;

    @GetMapping("/findAll")
    public List<Books> findAll(){

        List<Books> bookList = bookService.findAll();
        return bookList;
    }

      @GetMapping("/findList")
     public List<Books> findList(){

          List<Books> list = bookMyBatisPlusService.list();
          return list;
      }

}
