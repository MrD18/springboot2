package com.dhao.exception;

import com.dhao.enums.BusinessReturnEnum;
import org.springframework.http.HttpStatus;

/**
 * @Author: dhao
 * @Date: 2020/9/29 10:37
 * @description Base异常
 */
public class BaseException extends RuntimeException {
    private int status = HttpStatus.OK.value();

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public BaseException() {
    }

    public BaseException(String message, int status) {
        super(message);
        this.status = status;
    }

    public BaseException(String message) {
        super(message);
    }

    public BaseException(BusinessReturnEnum returnEnum) {
        super(returnEnum.getMsg());
        this.status = returnEnum.getCode();
    }

    public BaseException(String message, Throwable cause) {
        super(message, cause);
    }

    public BaseException(Throwable cause) {
        super(cause);
    }

    public BaseException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }

}