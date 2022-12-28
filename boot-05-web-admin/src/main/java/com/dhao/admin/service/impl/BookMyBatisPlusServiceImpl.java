package com.dhao.admin.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.dhao.admin.entity.Books;
import com.dhao.admin.mapper.BookMyBatisPlusMapper;
import com.dhao.admin.service.BookMyBatisPlusService;
import org.springframework.stereotype.Service;

/** 继承ServiceImpl--->IService 实现类（ 泛型：M 是 要操作的mapper 对象，T 是实体 ）
 * Ctrl+F12  就可以看到很多的方法
 * @author: duhao
 * @date: 2021/1/23 9:39
 */
@Service
public class BookMyBatisPlusServiceImpl extends ServiceImpl<BookMyBatisPlusMapper, Books>
        implements BookMyBatisPlusService {
}
