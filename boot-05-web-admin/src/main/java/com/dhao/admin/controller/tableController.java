package com.dhao.admin.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.dhao.admin.entity.Books;
import com.dhao.admin.entity.User;
import com.dhao.admin.exception.UserTooManyException;
import com.dhao.admin.service.BookMyBatisPlusService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Arrays;
import java.util.List;

/**
 * @author: duhao
 * @date: 2021/1/10 11:47
 */
@Controller
public class tableController {
     @Autowired
     private BookMyBatisPlusService bookMyBatisPlusService;


    @GetMapping("/basic_table")
    public String basicTable(){
        return "table/basic_table";
    }

  // 删除
    @GetMapping("/book/delete/{id}")
    public String delete(@PathVariable("id") Integer id,
                         @RequestParam(value = "pn",defaultValue = "1")Integer pn,
                         RedirectAttributes ra){
        bookMyBatisPlusService.removeById(id);
        ra.addAttribute("pn",pn);
        return "redirect:/dynamic_table";
    }

// 分页查询
    @GetMapping("/dynamic_table")
    public String dynamicTable(@RequestParam(value = "pn",defaultValue = "1")Integer pn, Model model){
/*         // 表单内容遍历
        List<User> users = Arrays.asList(new User("zhansan", "123456"),
                                         new User("lisi", "4444"),
                                         new User("wangwu", "55555"),
                                        new User("zhaoliu","66666"));
        model.addAttribute("users",users);
        if (users.size()>3){
            // 自定义的异常
            throw new UserTooManyException();
        }*/


          // 从数据库中查出来,进行展示
        List<Books> list = bookMyBatisPlusService.list();
      //  model.addAttribute("books",list);

        // 分页查询数据
        Page<Books> booksPage= new Page<>(pn, 2);
          bookMyBatisPlusService.page(booksPage,null);
           model.addAttribute("page",booksPage);
        return "table/dynamic_table";
    }

    @GetMapping("/responsive_table")
    public String responsiveTable(){
        return "table/responsive_table";
    }
    @GetMapping("/editable_table")
    public String editableTable(){
        return "table/editable_table";
    }
}
