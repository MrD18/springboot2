package com.dhao.enums;

/**
 * @Author: dhao
 * @Date: 2020/9/27 13:20
 */
public enum BusinessReturnEnum {

    OK (200,"success"),
    ERROR(500, "系统错误"),
    INVOKE_SELFORDER_SERVICE_FAIL(402001,"调用客户自助下单服务异常"),
    SELFORDER_SERVICE_RETURN_EXPMSG(402002,"客户自助下单服务返回了异常信息"),
    ORDER_PRODUCT_RELATION_NOTEXISTS(403003,"不存在该指令相关信息"),
    INVOKE_OA_SERVICE_FAIL(403001,"调用OA系统WebService接口异常"),
    LEGALFILE_NUM_EXCEED_LIMITED(403002,"法律文件个数超过限制"),
    ;

    private  int code;

    private  String  msg;

    BusinessReturnEnum(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }




    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }
}
