package com.dhao.common;


import com.dhao.enums.BusinessReturnEnum;

import com.dhao.exception.BaseException;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * @Author: dhao
 * @Date: 2020/9/27 13:16
 */
@Data
@NoArgsConstructor
//@ApiModel("Base响应对象")
public class BaseRestResponse<T> {

   // @ApiModelProperty("状态码")
    private int status;

    //@ApiModelProperty("响应信息")
    private String message;

   // @ApiModelProperty("接口响应数据")
    private T data;


    public static BaseRestResponse success() {

        BaseRestResponse<Object> response = new BaseRestResponse<>();
        response.setStatus(BusinessReturnEnum.OK.getCode());
        response.setMessage(BusinessReturnEnum.OK.getMsg());
        return response;
    }


    public static BaseRestResponse failure() {
        BaseRestResponse<Object> response = new BaseRestResponse<>();
        response.setStatus(BusinessReturnEnum.ERROR.getCode());
        response.setMessage(BusinessReturnEnum.ERROR.getMsg());
        return response;
    }

    public static BaseRestResponse failure(int status, Throwable e) {
        BaseRestResponse<Object> response = new BaseRestResponse<>();
        response.setStatus(status);
        response.setMessage(e.getMessage());
        return response;
    }

    public static BaseRestResponse failure(BaseException e) {
        BaseRestResponse<Object> response = new BaseRestResponse<>();
        response.setStatus(e.getStatus());
        response.setMessage(e.getMessage());
        return response;
    }

    public BaseRestResponse<T> data(T data) {
        this.setData(data);
        return this;
    }
}

