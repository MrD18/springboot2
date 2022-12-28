package com.dhao.admin.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


/**
 * @author: duhao
 * @date: 2021/1/22 16:49
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Books {
    @TableField("bookID")
    private Integer bookId;
    @TableField("bookName")
    private String bookName;
    @TableField("bookCounts")
    private  Integer bookCounts;
    @TableField("detail")
    private String detail;
}
