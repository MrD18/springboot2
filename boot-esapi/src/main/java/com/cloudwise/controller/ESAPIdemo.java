package com.cloudwise.controller;

import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;
import org.owasp.esapi.ESAPI;

import static jdk.nashorn.internal.runtime.regexp.joni.Config.log;

/**
 * @Author: dhao
 * @Date: 2021/6/17 1:50 下午
 */
public class ESAPIdemo {

    @SneakyThrows
    public static void main(String[] args) {
        StringBuilder filter = new StringBuilder();
        filter.append("columnName").append(" LIKE ");
        quoteStringLiteral(filter, "pattern");
        filter.append(" ESCAPE ");
        quoteStringLiteral(filter, SEARCH_STRING_ESCAPE);
        System.out.println("filter.toString()--->" + filter.toString());
        System.out.println("canonicalize-->" + ESAPI.encoder().canonicalize(filter.toString()));
        System.out.println("ForHTMLAttribute-->" + ESAPI.encoder().encodeForHTMLAttribute(filter.toString()));
        System.out.println("ForHTML-->" + ESAPI.encoder().encodeForHTML(filter.toString()));
        System.out.println("ForURL-->" + ESAPI.encoder().encodeForURL(filter.toString()));
        System.out.println("ForCSS-->" + ESAPI.encoder().encodeForCSS(filter.toString()));
        System.out.println("ForDN-->" + ESAPI.encoder().encodeForDN(filter.toString()));
        System.out.println("ForJavaScript-->" + ESAPI.encoder().encodeForJavaScript(filter.toString()));
        System.out.println("ForLDAP-->" + ESAPI.encoder().encodeForLDAP(filter.toString()));
        System.out.println("ForVBScript-->" + ESAPI.encoder().encodeForVBScript(filter.toString()));
        System.out.println("ForXML-->" + ESAPI.encoder().encodeForXML(filter.toString()));
        System.out.println("ForXPath-->" + ESAPI.encoder().encodeForXPath(filter.toString()));
        System.out.println("FromURL-->" + ESAPI.encoder().decodeFromURL(filter.toString()));

        // return filter.toString();
    }

    private static final String SEARCH_STRING_ESCAPE = "\\";

    private static void quoteStringLiteral(StringBuilder out, String value) {
        out.append('\'');
        for (int i = 0; i < value.length(); i++) {
            String canonicalizeValue = ESAPI.encoder().canonicalize(value);
           char c = canonicalizeValue.charAt(i);
             //   char c = value.charAt(i);
            out.append(c);
            if (c == '\'') {
                out.append('\'');
            }
        }
        out.append('\'');
    }
}
