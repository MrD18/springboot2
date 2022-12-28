package com.cloudwise.controller;

import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.owasp.esapi.ESAPI;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Enumeration;

/**
 * @Author: dhao
 * @Date: 2021/6/17 2:59 下午
 */
public class ESAPIdemo2 {
    public static void main(String[] args) {
        HttpServletRequest request = null;
        HttpServletResponse response=null;
        String host="127.0.0.1";
        String port="10086";
        String uri = "http://10.0.9.42:18080/#/dodb/analysis/explore/93";
        String queryString ="queryString";
        String url = "/api/v1" + uri.substring("/dodp/api/v1/metrics".length());
        System.out.println("url-->"+url);
        url = "http://" + host + ":" + port + url + "?" + queryString;
        System.out.println("拼接后URL：-->"+url);
        String canonicalizeURL = ESAPI.encoder().canonicalize(url);
        System.out.println("canonicalizeURL-->"+canonicalizeURL);

        HttpHeaders headersMap = new HttpHeaders();

                headersMap.set("header1", "value1");


        HttpEntity<String> entity = new HttpEntity<String>("body", headersMap);

        CloseableHttpClient httpClient = HttpClientUtils.getHttpClient();
        HttpGet httpGet = new HttpGet(url);
        System.out.println("httpGet：-->"+httpGet);
        HttpGet  ESAPIhttpGet = new HttpGet(canonicalizeURL);
        System.out.println("ESAPIhttpGet-->"+ESAPIhttpGet);
        CloseableHttpResponse response1 = null;
    /*    try {
            // 配置信息
            RequestConfig requestConfig = RequestConfig.custom()
                    // 设置连接超时时间(单位毫秒)
                    .setConnectTimeout(5000)
                    // 设置请求超时时间(单位毫秒)
                    .setConnectionRequestTimeout(5000)
                    // socket读写超时时间(单位毫秒)
                    .setSocketTimeout(5000)
                    // 设置是否允许重定向(默认为true)
                    .setRedirectsEnabled(true).build();

            // 将上面的配置信息 运用到这个Get请求里
            httpGet.setConfig(requestConfig);

            // 由客户端执行(发送)Get请求
            response1 = httpClient.execute(httpGet);
            // 从响应模型中获取响应实体
            response1.getEntity().writeTo(response.getOutputStream());
        } catch (ClientProtocolException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (response1 != null) {
                    response1.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }*/
    }
}
