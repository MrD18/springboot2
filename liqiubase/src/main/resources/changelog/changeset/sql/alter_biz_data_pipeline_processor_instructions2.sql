update biz_data_pipeline_processor_instructions set content_en = '



The component used to parse logs through regex matching, splitting log fields.

#### Field description:

Extract: the name of the field extracted from the data source to be split through grok.

Replace: the name of the replaced field.

Template: the common parsing template.

Variable: the common variable.

Mode: the rule based on which to extract data for splitting through grok.

#### Sample data:

```js
{"name":"myron","phone":"185","_cw_message":"192.168.1.1 Mon Apr 24 13:53:58 CST 2017 [DEBUG] service:com.abc.open.nlp.facade.NLPService"}
```

- Extracted field: _cw_message

#### Mode：

```js
%{HOSTNAME:host} %{DAY:week} %{WORD:month} %{MONTHDAY:day} %{TIME:time} %{TZ:biaozhun} %{YEAR:year} \\[%{WORD:level}\\] %{NOTSPACE:info}
```

#### Execution result：

```js
{"name":"myron",
"phone":"185",
"month":"Apr",
"level":"DEBUG",
"host":"192.168.1.1",
"time":"13:53:58",
"_cw_collect_time":1605751477313,
"info":"service:com.abc.open.nlp.facade.NLPService",
"_cw_raw_time":1605751477313,
"week":"Mon",
"_cw_message":"192.168.1.1 Mon Apr 24 13:53:58 CST 2017 [DEBUG] service:com.abc.open.nlp.facade.NLPService","biaozhun":"CST",
"day":"24",
"year":"2017"}
```

#### Grok expressions defined in Sawmill:

https://github.com/logzio/sawmill/tree/master/sawmill-core/src/main/resources/grok/patterns

#### Notes:

#### 1） Match or leave empty

- Expression: (?: Expression 1|Expression2) (?: ⧵"(?<upstreamTime>(\\[^⧵"\\]+))⧵"|)
- Description：Parse to decide whether a value is contained in \"\". If yes, the value is match with the upstreamTime field. Otherwise, no operation is performed.

#### 2）A field contains two small fields

- Expression：(?<cookie>((?<jsessionid>(\\[^⧵⧵?\\]+))⧵⧵? (?<JSESSIONID>\\[^ \\]+))))
- Description：The value of the cookie field contains values of the jsessionid and JSESSIONID fields.

#### 3）Greedy match

- Expression：%{GREEDYDATA:Custom field name}
- Description：Automatic matching is conducted based on the spelling format in the Grok splitting component.
- Shortcoming：Performance can be affected.

#### 4）Field type  Parse specified type

- Expression：%{INT:num1:int}
- Note：The int value matched under the INT mode can be parsed as the int type. Therefore, the Field type conversion component is not needed.

#### 5）Expressions in multiple types matched as the same field

- Expression：(?<dateTime>(%{DAY} %{MONTH} %{MONTHDAY} %{TIME} %{YEAR}]))
- Description：The previous expression is matched as the dateTime field based on the specified mode.

#### 6）Grok matches fields in array

- Operation: Define multiple fields with the same name in grok.

#### 7）Simple if-else operation

- Component：Add field (mustache template)
- {{#prop}}{{/prop}} Description: If exists, then (ignore the missing ones)
- {{^prop}}{{/prop}}Description: If does not exist, then (ignore the existed ones)
- If the xmlmessage field exits, the value of the field is the value corresponding to xmlmessage. If not, the value of this field is the value ecorresponding to example.
- Expression: {{#xmlmessage}}{{xmlmessage}}{{/xmlmessage}}{{^xmlmessage}}{{example}}{{/xmlmessage}}

#### 8）Hide part of the field value

- Component：Regex replacement
- Expression：{"field":"d","pattern":"(⧵⧵d{3})⧵⧵d+(⧵⧵d{4})","replacement":"$1*****$2"}
- Description：Replace the part between the third and the reciprocal third fields with *.

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\\\\\”) before the period (.).
' where id =1;
update biz_data_pipeline_processor_instructions set content_en = '

#### Component description:

The component used to obtain data of a specific key from Redis and add here.

#### Field description:

Primary key: specifies the key to be queried in Redis, supporting constants and templates

Redis instance number: the specified Redis instance

Wihitelist: the field to be extracted from Redis

Target field: the name of the field extracted from Redis

#### Sample data:

```js
{"name":"myron","phone":"185","message":"m1"}
```

#### redis data: hash type

| key    | hashkey | value |
| ------ | ------- | ----- |
| **m1** | role    | test1 |
|        | age     | test2 |
|        | show    | test3 |

#### Primary key: {{message}}

#### Redis instance number:  0

#### Whitelist: role,age

#### Execution result:

```js
{"name":"myron",
"phone":"185",
"message":"m1",
"role":"test1",
"age":"test2",
"_cw_collect_time":1605751477313,
"_cw_raw_time":1605751477313}
```

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\\\\\”) before the period (.).' where id =2;
update biz_data_pipeline_processor_instructions set content_en = '

#### Component description:

The component used to convert a JSON string into a JSON object or convert a JSON object to a JSON string.

#### Field description: the description of fields

field: the source field to be converted

the target field after conversion

theWay: the conversion method, including STRINGTOOBJECT and OBJECTFLATTEN. The previous one means to convert a string to a map, and the latter one means to flatten a map.

#### Sample data:

```js
{"name":"myron","phone":"185","message":"{\"a\":\"me\",\"b\":\"you\"}"}
```

#### Configuration:

```js
{"field":"message","targetField":"msg","theWay":"STRINGTOOBJECT"}
```

#### Conversion result:

```js
{"name":"myron",
"phone":"185",
"message":"{\"a\":\"me\",\"b\":\"you\"}",
"_cw_collect_time":1605756575809,
"_cw_raw_time":1605756575809,
"msg":{"a":"me","b":"you"}}
```

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\\\\\”) before the period (.).' where id =3;
update biz_data_pipeline_processor_instructions set content_en = '

#### Component description:

The component used to encapsulate multiple source fields into a string as the target field.

#### Field description: the description of fields

Target field: the JOSN-formatted string field.

Source field: the field to be converted.

#### Sample data:

```js
{"name":"myron","phone":"185","age":"12"}
```

#### Configuration:

Target field: user

Source field: name,phone

#### Conversion result:

```js
{"name":"myron",
"phone":"185",
"age":"12","_cw_collect_time":1605758417034,
"_cw_raw_time":1605758417034,
"user":"{\"phone\":\"185\",\"name\":\"myron\"}"}
```

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\\\\\”) before the period (.).
' where id =4;
update biz_data_pipeline_processor_instructions set content_en = '

#### Component description:

The component used to realize JSON sorting.

#### Field description:

field: the source field.

targetField: the target field (If this field is empty, the source field is used.)

type: the JSON data type, including jsonObject and jsonString.

sortType: the method of sorting.

#### Sample data:

JsonString:

```js
{"a":{"metric_tags": "{\"b\":2, \"a\":1}"}}
```

JsonObject:

```js
{"a":{"metric_tags": {"b":2,"a":2,"c":3}}}
```

#### Configuration:

JsonString:

```js
{"config":[{"field":"a.metric_tags","targetField":"c","type":"jsonString","sortType":"asc"}]}
```

JsonObject:

```js
{"config":[{"field":"a.metric_tags","targetField":"","type":"jsonObject","sortType":"asc"}]}
```

#### Conversion result:

JsonString:

```js
{"a": {"metric_tags": "{\"b\":2, \"a\":1}"},
"_cw_collect_time": 1622637449607,
"_cw_raw_time": 1622637449607,
"c": "{\"a\":1,\"b\":2}"
}
```

JsonObject:

```js
{
"a": {"metric_tags": {"a":2,"b":2,"c":3}},
"_cw_collect_time": 1622637449607,
"_cw_raw_time": 1622637449607
}
```

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\\\\\”) before the period (.).
' where id =5;
update biz_data_pipeline_processor_instructions set content_en = '

#### Component description:

The component used to extract fields from XML or convert an XML field to a JSON one.

#### Field description: the description of the fields.

field: the source field.

targetField: the target field.

storeXml: specifies whether to convert an XML field into a JSON one.

xpath: the value of xpath in XML saved into the specified field.

#### Sample data:

```js
{"name":"myron","phone":"185","xml":"<user><name>jack</name><age>15</age></user>"}
```

#### Configuration:

```js
{"field":"xml","targetField":"userXml","storeXml":"true","xpath":{"/user/name":"username"}}
```

#### Conversion result:

```js
{"name":"myron",
"phone":"185",
"xml":"<user><name>jack</name><age>15</age></user>",
"_cw_collect_time":1605770010581,
"_cw_raw_time":1605770010581,
"username":"jack",
"userXml":{
"user":{
"name":"jack",
"age":"15"
}}}
```

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\\\\\”) before the period (.).
' where id =6;
update biz_data_pipeline_processor_instructions set content_en = '

#### Component description:

The component used to add one or more fields.

#### Field description:

path: the path used to add a field

value: the value of the added field

#### Sample data:

```js
{"host":"127.0.0.1"}
```

#### Settings:

```js
{"config":[{"path":"message.name","value":"test"},{"path":"date","value":"2020.11.11"}]}
```

#### Conversion result:

```js
{"host":"127.0.0.1",
"_cw_collect_time":1605773876461,
"_cw_raw_time":1605773876461,
"message":{
"name":"test"
},
"date":"2020.11.11"}
```

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\\\\\”) before the period (.).' where id =10;
update biz_data_pipeline_processor_instructions set content_en = '

#### Component description:

The component used to extract the names or values of one or more columns of fields to specified fields.

#### Field description:

type: columnsToRows

fields: the fields whose data is to be extracted.

targetNameField: the field where the field names are populated.

targetValueField: the field where the field values are populated

#### Sample data:

```js
{"a":"aa","b":"bb","c":"cc","d":"dd"}
```

#### Configuration:

```js
{"type":"columnsToRows","fields":["a"],"targetNameField":"name","targetValueField":"value"}
```

#### Conversion result:

```js
{"b":"bb","c":"cc","d":"dd",
"_cw_collect_time":1605779824950,
"_cw_raw_time":1605779824950,
"name":"a","value":"aa"}
```

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\\\\\”) before the period (.).' where id =14;
update biz_data_pipeline_processor_instructions set content_en = '

#### Component description:

The component used to resolve IP addresses and deliver to the target field.

#### Field description:

field: the source field.

targetCountryField: the country field of the resolved IP address.

targetRegionField: the administrative region of the resolved IP address.

targetCityField: the city field of the resolved IP address.

targetOperField: the carrier field of the resolved IP address.

#### Sample data:

```js
{"name":"myron","ip":"220.181.38.148"}
```

#### Configuration:

```js
{"field": "ip", "targetCountryField": "ip_country", "targetRegionField": "ip_region", "targetCityField": "ip_city", "targetOperField": "ip_oper"}
```

#### Conversion result:

```js
{"name":"myron",
 "ip":"220.181.38.148",
 "ip_country":"中国",
 "ip_region":"北京",
 "ip_city":"北京市",
 "ip_oper":"电信",
 "_cw_collect_time":1605844499221,
 "_cw_raw_time":1605844499221}
```

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\\\\\”) before the period (.).' where id =26;
