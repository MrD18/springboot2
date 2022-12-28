INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (1, 'grok', '

按照正则匹配解析日志，用于日志的字段拆分

#### 字段说明：

提取：从数据源提取出来进行grok拆分的字段名

替换：处理完源字段的替换字段名

模板：常用解析模版

变量：常用变量

模式：提取数据grok拆分的规则

#### 样例数据：

```js
{"name":"myron","phone":"185","_cw_message":"192.168.1.1 Mon Apr 24 13:53:58 CST 2017 [DEBUG] service:com.abc.open.nlp.facade.NLPService"}
```

- 提取字段：_cw_message

#### 模式：

```js
%{HOSTNAME:host} %{DAY:week} %{WORD:month} %{MONTHDAY:day} %{TIME:time} %{TZ:biaozhun} %{YEAR:year} [%{WORD:level}] %{NOTSPACE:info}
```

#### 执行结果：

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

#### sawmill定义好的grok表达式：

https://github.com/logzio/sawmill/tree/master/sawmill-core/src/main/resources/grok/patterns

#### 一些特殊用法：

#### 1）有则匹配，没有为空

- 表达式：(?: 表达式1|表达式2) (?: ⧵"(?<upstreamTime>([^⧵"](http://10.0.6.84:18080/)+))⧵"|)
- 含义：解析“”中有没有值，有的话value匹配upstreamTime字段，没有的话就不作处理；

#### 2）一个大字段中有包含两个小字段

- 表达式：(?<cookie>((?<jsessionid>([^⧵⧵?](http://10.0.6.84:18080/)+))⧵⧵? (?<JSESSIONID>([^ ](http://10.0.6.84:18080/)+))))
- 含义：字段cookie的value中 包含了字段jsessionid、JSESSIONID的值

#### 3）贪婪匹配

- 表达式：%{GREEDYDATA:自定义的字段名}
- 含义：根据你在grok组件中的拼写格式，自动匹配
- 缺点：影响性能

#### 4）字段类型 解析定义指定的类型

- 表达式：%{INT:num1:int}
- 含义：将INT模式匹配的int值 解析为int类型，省去了“字段类型转换”的组件

#### 5）用多种类型模式 共同匹配为一个字段

- 表达式：(?<dateTime>(%{DAY} %{MONTH} %{MONTHDAY} %{TIME} %{YEAR}]))
- 含义：按照定义的模式 匹配为dataTime的字段

#### 6）grok匹配 成数组类型的字段

- 操作：在grok中 定义多个相同的字段名 就可以了

#### 7）简单的if-else操作

- 组件：添加字段 （mustache模版）
- {{#prop}}{{/prop}} 语意：如果存在就（不管不存在的）
- {{^prop}}{{/prop}}标签 语意：如果不存在就（不管存在的）
- 如果xmlmessage字段存在，这个字段的值为xmlmessage对应的value，若不存在，这个字段的值就是example对应的值
- 表达式 {{#xmlmessage}}{{xmlmessage}}{{/xmlmessage}}{{^xmlmessage}}{{example}}{{/xmlmessage}}

#### 8）将某个字段value中间几个隐藏

- 组件：正则替换
- 表达式：{"field":"d","pattern":"(⧵⧵d{3})⧵⧵d+(⧵⧵d{4})","replacement":"$1*****$2"}
- 含义：将value第三位之后 和 倒数第三位之前 置为“*”

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\.”

', '



The component used to parse logs through regex matching, splitting log fields.

#### Field description:：

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
%{HOSTNAME:host} %{DAY:week} %{WORD:month} %{MONTHDAY:day} %{TIME:time} %{TZ:biaozhun} %{YEAR:year} [%{WORD:level}] %{NOTSPACE:info}
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

- Expression: (?: Expression 1|Expression2) (?: ⧵"(?<upstreamTime>([^⧵"](http://10.0.6.84:18080/)+))⧵"|)
- Description：Parse to decide whether a value is contained in \"\". If yes, the value is match with the upstreamTime field. Otherwise, no operation is performed.

#### 2）A field contains two small fields

- Expression：(?<cookie>((?<jsessionid>([^⧵⧵?](http://10.0.6.84:18080/)+))⧵⧵? (?<JSESSIONID>([^ ](http://10.0.6.84:18080/)+))))
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
- 含义：Replace the part between the third and the reciprocal third fields with *.

', 0, 1, '2021-06-21 11:15:26', 1, '2021-06-21 11:15:30');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (2, 'redisDictionary', '

#### 组件说明：

redis字典是从redis中查出指定key的数据添加进来

#### 字段说明：

主键：指定去redis查询的key字段，支持常数与模版

redis实例号：指定redis实例

白名单：需要从redis提取的字段

目标字段：提取出来的字段设置的字段名称

#### 样例数据：

```js
{"name":"myron","phone":"185","message":"m1"}
```

#### redis数据： hash类型

| key  | hashkey | value |
| ---- | ------- | ----- |
| m1   | role    | test1 |
|      | age     | test2 |
|      | show    | test3 |

#### 主键： {{message}}

#### redis实例号： 0

#### 白名单： role,age

#### 执行结果：

```js
{"name":"myron",
"phone":"185",
"message":"m1",
"role":"test1",
"age":"test2",
"_cw_collect_time":1605751477313,
"_cw_raw_time":1605751477313}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

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

#### Primary key： {{message}}

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
```', 0, 1, '2021-06-21 17:35:49', 1, '2021-06-21 17:35:54');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (3, 'json', '
组件说明：
用于将jsonString转换为json对象或者将json对象转换为jsonString

字段说明： 配置字段说明
field：要转化的源字段

targetField：转化到的目标字段

theWay：转换方式STRINGTOOBJECT或OBJECTFLATTEN，前者代表字符串转map，后者代表map拉平

样例数据：
{"name":"myron","phone":"185","message":"{\"a\":\"me\",\"b\":\"you\"}"}
配置：
{"field":"message","targetField":"msg","theWay":"STRINGTOOBJECT"}
转化结果：
{"name":"myron",
"phone":"185",
"message":"{\"a\":\"me\",\"b\":\"you\"}",
"_cw_collect_time":1605756575809,
"_cw_raw_time":1605756575809,
"msg":{"a":"me","b":"you"}}
注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description：

The component used to convert a JSON string into a JSON object or convert a JSON object to a JSON string.

#### Field description： the description of fields

field：the source field to be converted

the target field after conversion

theWay：the conversion method, including STRINGTOOBJECT and OBJECTFLATTEN. The previous one means to convert a string to a map, and the latter one means to flatten a map.

#### Sample data:

```js
{"name":"myron","phone":"185","message":"{\"a\":\"me\",\"b\":\"you\"}"}
```

#### Configuration：

```js
{"field":"message","targetField":"msg","theWay":"STRINGTOOBJECT"}
```

#### Conversion result：

```js
{"name":"myron",
"phone":"185",
"message":"{\"a\":\"me\",\"b\":\"you\"}",
"_cw_collect_time":1605756575809,
"_cw_raw_time":1605756575809,
"msg":{"a":"me","b":"you"}}
```', 0, 1, '2021-06-21 17:37:07', 1, '2021-06-21 17:37:11');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (4, 'columnsToJSONString', '

#### 组件说明：

将几个源字段封装为一个jsonString输出到目标字段

#### 字段说明： 配置字段说明

目标字段：输出jsonString的字段

源字段：转化为jsonString的字段，多个以逗号分隔

#### 样例数据：

```js
{"name":"myron","phone":"185","age":"12"}
```

#### 配置：

目标字段：user 源字段：name,phone

#### 转化结果：

```js
{"name":"myron",
"phone":"185",
"age":"12","_cw_collect_time":1605758417034,
"_cw_raw_time":1605758417034,
"user":"{\"phone\":\"185\",\"name\":\"myron\"}"}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description：

The component used to encapsulate multiple source fields into a string as the target field.

#### Field description： the description of fields

Target field: the JOSN-formatted string field.

Source field: the field to be converted.

#### Sample data:

```js
{"name":"myron","phone":"185","age":"12"}
```

#### Configuration:

Target field：user

Source field：name,phone

#### Conversion result：

```js
{"name":"myron",
"phone":"185",
"age":"12","_cw_collect_time":1605758417034,
"_cw_raw_time":1605758417034,
"user":"{\"phone\":\"185\",\"name\":\"myron\"}"}
```

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (\\\\) before the period (.).

', 0, 1, '2021-06-21 17:38:30', 1, '2021-06-21 17:38:33');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (5, 'jsonSort', '
组件说明：
实现JSON排序

字段说明：
field：进行Json排序的源字段

targetField：目标字段（如果不填写则对源字段进行处理）

type：json数据类型，jsonObject/jsonString

sortType：排序方式

样例数据：
JsonString:

{"a":{"metric_tags": "{\"b\":2, \"a\":1}"}}
JsonObject:

{"a":{"metric_tags": {"b":2,"a":2,"c":3}}}
配置信息：
JsonString:

{"config":[{"field":"a.metric_tags","targetField":"c","type":"jsonString","sortType":"asc"}]}
JsonObject:

{"config":[{"field":"a.metric_tags","targetField":"","type":"jsonObject","sortType":"asc"}]}
转化结果：
JsonString:

{"a": {"metric_tags": "{\"b\":2, \"a\":1}"},
"_cw_collect_time": 1622637449607,
"_cw_raw_time": 1622637449607,
"c": "{\"a\":1,\"b\":2}"
}
JsonObject:

{
"a": {"metric_tags": {"a":2,"b":2,"c":3}},
"_cw_collect_time": 1622637449607,
"_cw_raw_time": 1622637449607
}
注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to realize JSON sorting.

#### Field description:

field：the source field.

targetField：the target field (If this field is empty, the source field is used.)

type：the JSON data type, including jsonObject and jsonString.

sortType：the method of sorting.

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

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (\\\\) before the period (.).

', 0, 1, '2021-06-21 17:39:35', 1, '2021-06-21 17:39:39');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (6, 'xml', '

#### 组件说明：

提取xml中字段或将xml转化为json

#### 字段说明： 配置字段说明

field：源字段

targetField：输出字段

storeXml：是否将xml转储为json

xpath：将xml中xpth对应的值存入配置的字段中

#### 样例数据：

```js
{"name":"myron","phone":"185","xml":"<user><name>jack</name><age>15</age></user>"}
```

#### 配置信息：

```js
{"field":"xml","targetField":"userXml","storeXml":"true","xpath":{"/user/name":"username"}}
```

#### 转化结果：

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

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to extract fields from XML or convert an XML field to a JSON one.

#### Field description: the description of the fields.

field：the source field.

targetField: the target field.

storeXml：specifies whether to convert an XML field into a JSON one.

xpath： the value of xpath in XML saved into the specified field.

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

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (\\\\) before the period (.).

', 0, 1, '2021-06-21 17:40:36', 1, '2021-06-21 17:40:39');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (7, 'csv', '

#### 组件说明：

根据拆分规则将数据拆分成不同的列

#### 字段说明： 配置字段说明

field：源字段

separator：拆分字段

columns：拆分成的列

skipEmptyColumns：是否跳过空的字段

autoGenerateColumnNames：是否自动生成列名

#### 样例数据：

```js
{"message":"192.168.1.1,Mon Apr 24 13:53:58 CST 2017,[DEBUG],service:com.abc.open.nlp.facade.NLPService"}
```

#### 配置信息：

```js
{"field":"message","separator":",","columns":["ip","date","level","info"],
"skipEmptyColumns":"false","autoGenerateColumnNames":false}
```

#### 转化结果：

```js
{"message":"192.168.1.1,Apr.24.13:53:58.CST.2017,[DEBUG],service:com.abc.open.nlp.facade.NLPService",
"_cw_collect_time":1605771378184,
"_cw_raw_time":1605771378184,
"date":"Apr.24.13:53:58.CST.2017",
"level":"[DEBUG]",
"ip":"192.168.1.1",
"info":"service:com.abc.open.nlp.facade.NLPService"}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to split data into different columns based on splitting rules.

#### Field description: the description of fields.

field: the source field.

separator: the splitting field.

columns: the split columns.

skipEmptyColumns: specifies whether to ignore null fields.

autoGenerateColumnNames: specifies whether to generate names for the columns automatically.

#### Sample data:

```js
{"message":"192.168.1.1,Mon Apr 24 13:53:58 CST 2017,[DEBUG],service:com.abc.open.nlp.facade.NLPService"}
```

#### Configuration:

```js
{"field":"message","separator":",","columns":["ip","date","level","info"],
"skipEmptyColumns":"false","autoGenerateColumnNames":false}
```

#### Conversion result:

```js
{"message":"192.168.1.1,Apr.24.13:53:58.CST.2017,[DEBUG],service:com.abc.open.nlp.facade.NLPService",
"_cw_collect_time":1605771378184,
"_cw_raw_time":1605771378184,
"date":"Apr.24.13:53:58.CST.2017",
"level":"[DEBUG]",
"ip":"192.168.1.1",
"info":"service:com.abc.open.nlp.facade.NLPService"}
```

', 0, 1, '2021-06-21 17:41:40', 1, '2021-06-21 17:41:44');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (8, 'if', '

#### 组件说明：

用于将流程拆分成不同的处理流程，例如不同业务数据

#### 字段说明：

判断字段：要处理的字段

判断符：大于/大于等于/小于/小于等于/等于/不等于/正则匹配/包含/不包含/开始于

加号：可以进⾏添加多个判断条件并含AND/OR关系

逻辑处理：输出到不同的分支

#### 样例数据：

```js
{"_cw_biz":a,"value":10}
{"_cw_biz":b,","value":50}
```

#### 配置信息：

```js
配置分支1：_cw_biz 等于 a，分支2：_cw_biz 等于 b；
```

#### 转化结果：

```js
{"_cw_biz":a,"value":10} 输出到处理分支1，
{"_cw_biz":b,","value":50} 输出到处理分支2；
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to split a pipeline into different pipelines based on elements such as different business data.

#### Field description:

Field: the field to be processed

Condition: greater than, greater than or equal to, smaller than, smaller than or equal to, unequal to, Regex match, include, exclude, and start from

Plus sign: the button used to add more conditions and specify the and/or relationships between the conditions.

Logic processing: delivers data to different branches

#### Sample data:

```js
{"_cw_biz":a,"value":10}
{"_cw_biz":b,","value":50}
```

#### Settings

```js
Branch 1：_cw_biz = a, Branch 2: _cw_biz = b；
```

#### Conversion result:

```js
{"_cw_biz":a,"value":10} delivered to Branch 1
{"_cw_biz":b,","value":50} delivered to Branch 2
```

',0, 1, '2021-06-21 17:42:39', 1, '2021-06-21 17:42:43');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (9, 'split', '

#### 组件说明：

将一个字段拆分成多个

#### 字段说明： 配置字段说明

field：需要拆分的字段

separator：拆分依据，例如按照“,”拆分

#### 样例数据：

```js
{"data":"hi take care of yourself"}
```

#### 配置信息：

```js
{"field":"data","separator":" "}
```

#### 转化结果：

```js
{"data":["hi","take","care","of","yourself"],
"_cw_collect_time":1605773216758,
"_cw_raw_time":1605773216758}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to split a field into multiple ones.

#### Field description: the description of the fields

field: the field to be split

separator: the accordance of splitting, such as splitting fields based on commas (,)

#### Sample data:

```js
{"data":"hi take care of yourself"}
```

#### Settings:

```js
{"field":"data","separator":" "}
```

#### Conversion result:

```js
{"data":["hi","take","care","of","yourself"],
"_cw_collect_time":1605773216758,
"_cw_raw_time":1605773216758}
```

', 0, 1, '2021-06-21 17:43:35', 1, '2021-06-21 17:43:38');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (10, 'addField', '

#### 组件说明：

添加一个或多个字段

#### 字段说明：

path：添加字段的路径

value：添加字段的值

#### 样例数据：

```js
{"host":"127.0.0.1"}
```

#### 配置信息：

```js
{"config":[{"path":"message.name","value":"test"},{"path":"date","value":"2020.11.11"}]}
```

#### 转化结果：

```js
{"host":"127.0.0.1",
"_cw_collect_time":1605773876461,
"_cw_raw_time":1605773876461,
"message":{
"name":"test"
},
"date":"2020.11.11"}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to add one or more fields.

#### Field description:

path：the path used to add a field

value： the value of the added field

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
```',0, 1, '2021-06-21 17:44:37', 1, '2021-06-21 17:44:41');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (11, 'rename', '

#### 组件说明：

重命名一个或多个字段

#### 字段说明：

from：源字段名

to：修改后的字段名

#### 样例数据：

```js
{"name":"tom","age":"13"}
```

#### 配置信息：

```js
{"config":[{"from":"name","to":"username"},{"from":"age","to":"userage"}]}
```

#### 转化结果：

```js
{"_cw_collect_time":1605774821907,
"_cw_raw_time":1605774821907,
"username":"tom",
"userage":"13"}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to rename one or more fields.

#### Field description:

from: the original field name

to: the modified field name

#### Sample data:

```js
{"name":"tom","age":"13"}
```

#### Settings:

```js
{"config":[{"from":"name","to":"username"},{"from":"age","to":"userage"}]}
```

#### Conversion result:

```js
{"_cw_collect_time":1605774821907,
"_cw_raw_time":1605774821907,
"username":"tom",
"userage":"13"}
```

',0, 1, '2021-06-21 17:45:34', 1, '2021-06-21 17:45:37');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (12, 'removeField', '

#### 组件说明：

删除一个或多个字段

#### 字段说明：

fields：要删除的字段名

#### 样例数据：

```js
{"name":"tom","age":"13","phone":"185115"}
```

#### 配置信息：

```js
{"fields":["name","age"]}
```

#### 转化结果：

```js
{"phone":"185115",
"_cw_collect_time":160577521453,
"_cw_raw_time":160577521453}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to delete one or more fields.

#### Field description:

fields: the name of the field to be deleted.

#### Sample data:

```js
{"name":"tom","age":"13","phone":"185115"}
```

#### Configuration:

```js
{"fields":["name","age"]}
```

#### Conversion result:

```js
{"phone":"185115",
"_cw_collect_time":160577521453,
"_cw_raw_time":160577521453}
```',0, 1, '2021-06-21 17:46:34', 1, '2021-06-21 17:46:36');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (13, 'convert', '

#### 组件说明：

对字段的类型进行转换，如将string转换为int类型

#### 字段说明：

path：要转换的字段路径

type：要转换为的字段类型

#### 样例数据：

```js
{"name":"tom","message":{"head":"127.0.01","length":"8"}}
```

#### 配置信息：

```js
{"path":"message.length","type":"int"}
```

#### 转化结果：

```js
{"name":"tom",
"message":{"head":"127.0.01","length":8},
"_cw_collect_time":1605776395330,
"_cw_raw_time":1605776395330}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to convert field types, such as converting a string to an integer.

#### Field description:

path: the path of the field whose type is to be converted.

type: the target field type.

#### Sample data:

```js
{"name":"tom","message":{"head":"127.0.01","length":"8"}}
```

#### Configuration:

```js
{"path":"message.length","type":"int"}
```

#### Conversion result:

```js
{"name":"tom",
"message":{"head":"127.0.01","length":8},
"_cw_collect_time":1605776395330,
"_cw_raw_time":1605776395330}
```

',0, 1, '2021-06-21 17:47:22', 1, '2021-06-21 17:47:25');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (14, 'transpose', '

#### 组件说明：

将某一列或几列的字段名、字段值提取到指定字段

#### 字段说明：

type：类型columnsToRows

fields：要转化的字段名

targetNameField：字段名赋值的字段

targetValueField：字段值赋值的字段

#### 样例数据：

```js
{"a":"aa","b":"bb","c":"cc","d":"dd"}
```

#### 配置信息：

```js
{"type":"columnsToRows","fields":["a"],"targetNameField":"name","targetValueField":"value"}
```

#### 转化结果：

```js
{"b":"bb","c":"cc","d":"dd",
"_cw_collect_time":1605779824950,
"_cw_raw_time":1605779824950,
"name":"a","value":"aa"}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to extract the names or values of one or more columns of fields to specified fields.

#### Field description:

type：columnsToRows

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
```',0, 1, '2021-06-21 17:48:21', 1, '2021-06-21 17:48:25');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (15, 'substring', '

#### 组件说明：

将字段截取一段替换原来的字段

#### 字段说明：

field：要截取的字段名称

begin：截取开始位置

end：截取结束位置

#### 样例数据：

```js
{"name":"marry zhang","age":"11"}
```

#### 配置信息：

```js
{"field":"name","begin":0,"end":5}
```

#### 转化结果：

```js
{"name":"marry",
"age":"11",
"_cw_collect_time":1605781218889,
"_cw_raw_time":1605781218889}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to extract partial field and replace.

#### Field description:

field: the name of the field to be extracted.

begin: the start point of the partial field.

end: the end point of the partial field.

#### Sample data:

```js
{"name":"marry zhang","age":"11"}
```

#### Configuration:

```js
{"field":"name","begin":0,"end":5}
```

#### Conversion result:

```js
{"name":"marry",
"age":"11",
"_cw_collect_time":1605781218889,
"_cw_raw_time":1605781218889}
```

',0, 1, '2021-06-21 17:49:17', 1, '2021-06-21 17:49:21');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (16, 'gsub', '

#### 组件说明：

利用正则表达式将匹配到的内容替换成指定字符

#### 字段说明：

field：被替换的字段

pattern：正则表达式

replacement：指定字符

#### 样例数据：

```js
{"name":"marry","phone":"13500358989"}
```

#### 配置信息：

```js
{"field":"phone","pattern":"(?<=^[0-9]{3})[0-9]{4}","replacement":" **** "}
```

#### 转化结果：

```js
{"name":"marry",
"phone":"135 **** 8989",
"_cw_collect_time":1605781909440,
"_cw_raw_time":1605781909440}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to replace matched content with specific character through regular expressions.

#### Field description:

field: the field to be replaced.

pattern: the regular expression.

replacement: the specified character.

#### Sample data:

```js
{"name":"marry","phone":"13500358989"}
```

#### Configuration:

```js
{"field":"phone","pattern":"(?<=^[0-9]{3})[0-9]{4}","replacement":" **** "}
```

#### Conversion result:

```js
{"name":"marry",
"phone":"135 **** 8989",
"_cw_collect_time":1605781909440,
"_cw_raw_time":1605781909440}
```

',0, 1, '2021-06-21 17:50:20', 1, '2021-06-21 17:50:24');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (17, 'lowerCase', '

#### 组件说明：

将指定字段全部转为小写

#### 字段说明：

#### 样例数据：

```js
{"name":"Marry","phone":"13500358989"}
```

#### 配置信息：

```js
{"field":"name"}
```

#### 转化结果：

```js
{"name":"marry",
"phone":"13500358989",
"_cw_collect_time":1605782422409,
"_cw_raw_time":1605782422409}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to convert specified field into a lowercase one.

#### Field description:

#### Sample data:

```js
{"name":"Marry","phone":"13500358989"}
```

#### Configuration:

```js
{"field":"name"}
```

#### Conversion result:

```js
{"name":"marry",
"phone":"13500358989",
"_cw_collect_time":1605782422409,
"_cw_raw_time":1605782422409}
```

',0, 1, '2021-06-21 17:51:10', 1, '2021-06-21 17:51:14');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (18, 'upperCase', '

#### 组件说明：

将指定字段全部转为大写

#### 字段说明：

field：要转化的字段

#### 样例数据：

```js
{"name":"Marry","phone":"13500358989"}
```

#### 配置信息：

```js
{"fields":["name"]}
```

#### 转化结果：

```js
{"name":"MARRY",
"phone":"13500358989",
"_cw_collect_time":1605782422409,
"_cw_raw_time":1605782422409}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to convert the specified field into an uppercase one.

#### Field description:

field: the field to be converted.

#### Sample data:

```js
{"name":"Marry","phone":"13500358989"}
```

#### Configuration:

```js
{"fields":["name"]}
```

#### Conversion result:

```js
{"name":"MARRY",
"phone":"13500358989",
"_cw_collect_time":1605782422409,
"_cw_raw_time":1605782422409}
```

',0, 1, '2021-06-21 17:52:02', 1, '2021-06-21 17:52:05');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (19, 'strip', '

#### 组件说明：

去除字段前后端的空白

#### 字段说明：

field：要去除空白的字段

#### 样例数据：

```js
{"name":"   Marry","phone":"13500358989   "}
```

#### 配置信息：

```js
{"fields":["name","phone"]}
```

#### 转化结果：

```js
{"name":"Marry",
"phone":"13500358989",
"_cw_collect_time":1605782422409,
"_cw_raw_time":1605782422409}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to remove space from the frontend and backend of a field.

#### Field description:

field: the field to be processed.

#### Sample data:

```js
{"name":"   Marry","phone":"13500358989   "}
```

#### Configuration:

```js
{"fields":["name","phone"]}
```

#### Conversion result:

```js
{"name":"Marry",
"phone":"13500358989",
"_cw_collect_time":1605782422409,
"_cw_raw_time":1605782422409}
```

',0, 1, '2021-06-21 17:52:52', 1, '2021-06-21 17:52:56');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (20, 'drop', '

#### 组件说明：

按百分率随机丢弃数据

#### 字段说明：

percentage：丢弃数据的百分比

#### 样例数据：

```js
{"name":"Marry","phone":"13500358989"}
```

#### 配置信息：

```js
{"percentage":"50"}
```

#### 转化结果：

【上述配置信息表示本条数据有50%几率被丢弃 所以结果是】 （空） 或

```js
{"name":"Marry",
"phone":"13500358989",
"_cw_collect_time":1605782422409,
"_cw_raw_time":1605782422409}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to discard data based on the specific percentage.

#### Field description:

percentage: the percentage of data to be discarded.

#### Sample data:

```js
{"name":"Marry","phone":"13500358989"}
```

#### Configuration:

```js
{"percentage":"50"}
```

#### Conversion result:

[The preceding configuration indicates that the discarding percentage of this piece of data is 50%. Therefore, the result is]  (null) or

```js
{"name":"Marry",
"phone":"13500358989",
"_cw_collect_time":1605782422409,
"_cw_raw_time":1605782422409}
```

',0, 1, '2021-06-21 17:54:07', 1, '2021-06-21 17:54:10');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (21, 'translate', '

#### 组件说明：

配置一个数据字典，从字典对应的key获取相应的value赋值到目标字段

#### 字段说明：

field：源字段

targetField：转化的目标字段

dictionary：字典

#### 样例数据：

```js
{"name":"Marry","pc_id":"2"}
```

#### 配置信息：

```js
{"field":"pc_id","targetField":"pc_name",
"dictionary":{"0":"Unknown","1":"Windows","2":"Mac"}}
```

#### 转化结果：

```js
{"name":"Marry",
"pc_id":"2",
"pc_name":"Mac",
"_cw_collect_time":1605784056224,
"_cw_raw_time":1605784056224}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to configure a data dictionary by obtaining the value corresponding to a key of the dictionary and assigning the value to the target field.

#### Field description:

field: the source field.

targetField: the target field.

dictionary: the dictionary.

#### Sample data:

```js
{"name":"Marry","pc_id":"2"}
```

#### Configuration:

```js
{"field":"pc_id","targetField":"pc_name",
"dictionary":{"0":"Unknown","1":"Windows","2":"Mac"}}
```

#### Conversion result:

```js
{"name":"Marry",
"pc_id":"2",
"pc_name":"Mac",
"_cw_collect_time":1605784056224,
"_cw_raw_time":1605784056224}
```

',0, 1, '2021-06-21 17:55:00', 1, '2021-06-21 17:55:04');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (22, 'appendList', '

#### 组件说明：

指定路径增加一个json列表字段，并将指定的值填充到列表

#### 字段说明：

path：增加列表字段的路径

value：要填充列表的值

#### 样例数据：

```js
{"name":"Marry","age":"25"}
```

#### 配置信息：

```js
{"path":"a.b","values":["{{name}}","{{age}}"]}
```

#### 转化结果：

```js
{"name":"Marry",
 "age":"25",
 "a":{"b":["Marry","25"]},
 "_cw_collect_time":1605784304534,
 "_cw_raw_time":1605784304534}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to add a JSON list field to a specific path and populate the value to the list.

#### Description:

path: the path to which to add the list field.

value: the value to be populated.

#### Sample data:

```js
{"name":"Marry","age":"25"}
```

#### Configuration:

```js
{"path":"a.b","values":["{{name}}","{{age}}"]}
```

#### Conversion result:

```js
{"name":"Marry",
 "age":"25",
 "a":{"b":["Marry","25"]},
 "_cw_collect_time":1605784304534,
 "_cw_raw_time":1605784304534}
```

',0, 1, '2021-06-21 17:57:16', 1, '2021-06-21 17:57:20');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (23, 'kv', '

#### 组件说明：

将源字段的不规则key value 值提取到目标字段

#### 字段说明：

field：源字段

targetField：目标字段

fieldSplit：多个kv之间的切分字段

valueSplit：Key value之间的切分字段

trim：value前后端要去除的字符

#### 样例数据：

```js
{"name":"myron","data":"phone=_181_00157094_&age=_22"}
```

#### 配置信息：

```js
{"field":"data","targetField":"message","fieldSplit":"&","valueSplit":"=","trim":"_"}
```

#### 转化结果：

```js
{"name":"myron",
 "data":"phone=_181_00157094_&age=_22",
 "_cw_collect_time":1605785957433,
 "_cw_raw_time":1605785957433,
 "message":{"phone":"181_00157094","age":"22"} }
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component descriptions:

The component used to extract the invalid key-values (KVs) to destination fields.

#### Field description:

field: the source field.

targetField: the target field.

fieldSplit: the splitting field between KVs.

valueSplit: the splitting field between a KV.

trim: the characters to be removed at the frontend and bankend of he values.

#### Sample data:

```js
{"name":"myron","data":"phone=_181_00157094_&age=_22"}
```

#### Configuration:

```js
{"field":"data","targetField":"message","fieldSplit":"&","valueSplit":"=","trim":"_"}
```

#### Conversion result:

```js
{"name":"myron",
 "data":"phone=_181_00157094_&age=_22",
 "_cw_collect_time":1605785957433,
 "_cw_raw_time":1605785957433,
 "message":{"phone":"181_00157094","age":"22"} }
```',0, 1, '2021-06-21 17:58:09', 1, '2021-06-21 17:58:14');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (24, 'date', '

#### 组件说明：

将固定格式的日期字段转换为时间戳格式

#### 字段说明：

field：源字段

targetField：目标字段

timeZone：时区

formats：源字段的日期格式

#### **常用日期转换格式示例**：

```js
yyyy-MM-dd''T''HH:mm:ssXXX         2019-09-19T08:01:34+00:00
yyyy-MM-dd HH:mm:ss.SSS          2019-09-20 15:17:33.436
yyyy-MM-dd HH:mm:ss.SSSZ         2019-09-20 15:18:36.937+0800
yy/MM/dd HH:mm:ss.SSSZ           19/09/20 15:19:38.396+0800
EEE, dd MMM yyyy HH:mm:ss Z      Fri, 20 Sep 2019 15:20:37 +0800
dd MMM yy HH:mm Z                20 Sep 19 15:21 +0800
yyyy-MM-dd''T''HH:mm:ssXXX         2019-05-21T23:14:27+08:00
dd/MMM/yyyy:HH:mm:ss Z           16/Oct/2020:16:55:44 +0800
MMM dd,yyyy K:mm:ss a            Oct 13,2020 11:46:39 AM
```

#### 样例数据：

```js
{"name":"myron","timestamp":"2020.12.21 13:04:11"}
```

#### 配置信息：

```js
{"field":"timestamp","targetField":"@timestamp","timeZone":"Asia/Shanghai","formats":["yyyy.MM.dd HH:mm:ss"]}
```

#### 转化结果：

```js
{"name":"myron",
 "timestamp":"2020.12.21 13:04:11",
 "@timestamp":1608527051000,
 "_cw_collect_time":1605841054517,
 "_cw_raw_time":1605841054517}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to convert date fields to the timestamp format.

#### Field description:

field: the source field.

targetField: the target field.

timeZone: the time zone.

formats: the date format of the source field.

#### Common examples:

```js
yyyy-MM-dd''T''HH:mm:ssXXX         2019-09-19T08:01:34+00:00
yyyy-MM-dd HH:mm:ss.SSS          2019-09-20 15:17:33.436
yyyy-MM-dd HH:mm:ss.SSSZ         2019-09-20 15:18:36.937+0800
yy/MM/dd HH:mm:ss.SSSZ           19/09/20 15:19:38.396+0800
EEE, dd MMM yyyy HH:mm:ss Z      Fri, 20 Sep 2019 15:20:37 +0800
dd MMM yy HH:mm Z                20 Sep 19 15:21 +0800
yyyy-MM-dd''T''HH:mm:ssXXX         2019-05-21T23:14:27+08:00
dd/MMM/yyyy:HH:mm:ss Z           16/Oct/2020:16:55:44 +0800
MMM dd,yyyy K:mm:ss a            Oct 13,2020 11:46:39 AM
```

#### Sample data:

```js
{"name":"myron","timestamp":"2020.12.21 13:04:11"}
```

#### Configuration:

```js
{"field":"timestamp","targetField":"@timestamp","timeZone":"Asia/Shanghai","formats":["yyyy.MM.dd HH:mm:ss"]}
```

#### Conversion result:

```js
{"name":"myron",
 "timestamp":"2020.12.21 13:04:11",
 "@timestamp":1608527051000,
 "_cw_collect_time":1605841054517,
 "_cw_raw_time":1605841054517}
```

',0, 1, '2021-06-21 17:59:01', 1, '2021-06-21 17:59:47');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (25, 'geoIp', '

#### 组件说明：

解析IP位置，输出到目标字段

#### 字段说明：

sourceField：源字段

targetField：目标字段

tagsOnSuccess：查询成功的标记

#### 样例数据：

```js
{"name":"myron","ip":"220.181.38.148"}
```

#### 配置信息：

```js
{"sourceField":"ip","targetField":"geoip","tagsOnSuccess":["geo-ip"]}
```

#### 转化结果：

```js
{"name":"myron",
"ip":"220.181.38.148",
"_cw_collect_time":1619097691610,
"_cw_raw_time":1619097691610,
"geoip":{"timezone":"Asia/Shanghai",
"ip":"220.181.38.148",
"latitude":39.9289,
"country_name":"China",
"country_code2":"CN",
"continent_code":"AS",
"region_name":"BJ",
"location":[116.3883,39.9289],
"real_region_name":"Beijing",
"longitude":116.3883},
"tags":["geo-ip"]}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to resolve IP addresses and deliver to the target field.

#### Field description:

sourceField: the source field.

targetField: the target field.

tagsOnSuccess: the label of success query.

#### Sample data:

```js
{"name":"myron","ip":"220.181.38.148"}
```

#### Configurations:

```js
{"sourceField":"ip","targetField":"geoip","tagsOnSuccess":["geo-ip"]}
```

#### Conversion result:

```js
{"name":"myron",
"ip":"220.181.38.148",
"_cw_collect_time":1619097691610,
"_cw_raw_time":1619097691610,
"geoip":{"timezone":"Asia/Shanghai",
"ip":"220.181.38.148",
"latitude":39.9289,
"country_name":"China",
"country_code2":"CN",
"continent_code":"AS",
"region_name":"BJ",
"location":[116.3883,39.9289],
"real_region_name":"Beijing",
"longitude":116.3883},
"tags":["geo-ip"]}
```

',0, 1, '2021-06-21 18:00:32', 1, '2021-06-21 18:00:35');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (26, 'geoIpCN', '

#### 组件说明：

解析IP所在的详细信息，输出到目标字段

#### 字段说明：

field：源字段

targetCountryField：所在国家输出字段

targetRegionField：所在行政区输出字段

targetCityField：所在城市输出字段

targetOperField：运营商输出字段

#### 样例数据：

```js
{"name":"myron","ip":"220.181.38.148"}
```

#### 配置信息：

```js
{"field": "ip", "targetCountryField": "ip_country", "targetRegionField": "ip_region", "targetCityField": "ip_city", "targetOperField": "ip_oper"}
```

#### 转化结果：

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

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

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
 "ip_country":"China",
 "ip_region":"Beijing",
 "ip_city":"Beijing",
 "ip_oper":"China Telecom",
 "_cw_collect_time":1605844499221,
 "_cw_raw_time":1605844499221}
```

',0, 1, '2021-06-21 18:01:35', 1, '2021-06-21 18:01:38');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (27, 'urldecode', '

#### 组件说明：

将url中被转码的信息解码出来

#### 字段说明：

field：源字段

targetField：目标字段

#### 样例数据：

```js
{"url":"http://www.sohu.net/search?query=C%E8%AF%AD%E8%A8%80"}
```

#### 配置信息：

```js
{"field": "url", "targetField": "decodedUrl"}
```

#### 转化结果：

```js
{"url":"http://www.sohu.net/search?query=C%E8%AF%AD%E8%A8%80",
 "_cw_collect_time":1605853715199,
 "_cw_raw_time":1605853715199,
 "decodedUrl":"http://www.sohu.net/search?query=C语言"}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to decode the encoded information in a URL.

#### Field description:

field: the source field.

targetField: the target field.

#### Sample code:

```js
{"url":"http://www.sohu.net/search?query=C%E8%AF%AD%E8%A8%80"}
```

#### Configuration:

```js
{"field": "url", "targetField": "decodedUrl"}
```

#### Conversion result:

```js
{"url":"http://www.sohu.net/search?query=C%E8%AF%AD%E8%A8%80",
 "_cw_collect_time":1605853715199,
 "_cw_raw_time":1605853715199,
 "decodedUrl":"http://www.sohu.net/search?query=C language"}
```

',0, 1, '2021-06-21 18:02:22', 1, '2021-06-21 18:02:25');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (28, 'math', '

#### 组件说明：

将指定字段的数值作数据运算输出到目标字段

#### 字段说明：

targetField：目标字段

expression：运算规则

#### 样例数据：

```js
{"a":15,"b":3}
```

#### 配置信息：

```js
{"targetField":"result","expression":"{{a}}/{{b}}"}
```

#### 转化结果：

```js
{"a":15,
 "b":3,
 "result":5,
 "_cw_collect_time":1605853926863,
 "_cw_raw_time":1605853926863}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to conduct arithmetical operations on values of specific fields and delivered to target fields.

#### Field description:

targetField: the target field.

expression: the arithmetical rule.

#### Sample data:

```js
{"a":15,"b":3}
```

#### Configuration:

```js
{"targetField":"result","expression":"{{a}}/{{b}}"}
```

#### Conversion result:

```js
{"a":15,
 "b":3,
 "result":5,
 "_cw_collect_time":1605853926863,
 "_cw_raw_time":1605853926863}
```

',0, 1, '2021-06-21 18:03:07', 1, '2021-06-21 18:03:11');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (29, 'anonymize', '

#### 组件说明：

用于将某些敏感字段进行加密处理

#### 字段说明：

fields：需脱敏的字段列表

algorithm：脱敏算法

key：算法用到的key

#### 样例数据：

```js
{"username":"jack","password":"123456"}
```

#### 配置信息：

```js
{"fields":["username","password"],"algorithm":"MD5","key":"abc"}
```

#### 转化结果：

```js
{"username":"4ff9fc6e4e5d5f590c4f2134a8cc96d1",
 "password":"e10adc3949ba59abbe56e057f20f883e",
 "_cw_collect_time":1605854876777,
 "_cw_raw_time":1605854876777}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to encrypt specific sensitive data.

#### Field descriptions:

fields: the list of fields to be desensitized.

algorithm: the algorithm used to desensitize data.

key: the key used in the algorithm.

#### Sample data:

```js
{"username":"jack","password":"123456"}
```

#### Configuration:

```js
{"fields":["username","password"],"algorithm":"MD5","key":"abc"}
```

#### Conversion result:

```js
{"username":"4ff9fc6e4e5d5f590c4f2134a8cc96d1",
 "password":"e10adc3949ba59abbe56e057f20f883e",
 "_cw_collect_time":1605854876777,
 "_cw_raw_time":1605854876777}
```

',0, 1, '2021-06-21 18:11:03', 1, '2021-06-21 18:11:07');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (30, 'userAgent', '

#### 组件说明：

解析指定字段的user agent信息

#### 字段说明：

field：源字段

prefix：输出字段的前缀

#### 样例数据：

```js
{"userAgent":"Mozilla/5.0 (Windows NT 10.0; Win64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3100.0 Safari/537.36"}
```

#### 配置信息：

```js
{"field":"userAgent","prefix":"UA-"}
```

#### 转化结果：

```js
{"userAgent":"Mozilla/5.0 (Windows NT 10.0; Win64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3100.0 Safari/537.36",
"_cw_collect_time":1619091510435,
"_cw_raw_time":1619091510435,
"UA-patch":"3100",
"UA-major":"60",
"UA-minor":"0",
"UA-os":"Windows 10",
"UA-name":"Chrome",
"UA-os_name":"Windows 10",
"UA-device":"Other"}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to parse user agent information of specific fields.

#### Field description:

field: the source field.

prefix: the prefix of the delivered field.

#### Sample data:

```js
{"userAgent":"Mozilla/5.0 (Windows NT 10.0; Win64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3100.0 Safari/537.36"}
```

#### Configuration:

```js
{"field":"userAgent","prefix":"UA-"}
```

#### Conversion result:

```js
{"userAgent":"Mozilla/5.0 (Windows NT 10.0; Win64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3100.0 Safari/537.36",
"_cw_collect_time":1619091510435,
"_cw_raw_time":1619091510435,
"UA-patch":"3100",
"UA-major":"60",
"UA-minor":"0",
"UA-os":"Windows 10",
"UA-name":"Chrome",
"UA-os_name":"Windows 10",
"UA-device":"Other"}
```

',0, 1, '2021-06-21 18:11:57', 1, '2021-06-21 18:12:00');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (31, 'addUUID', '

#### 组件说明：

添加一个uuid字段

#### 字段说明：

targetField：目标字段

#### 样例数据：

```js
{"name":"jack"}
```

#### 配置信息：

```js
{"targetField":"uuid"}
```

#### 转化结果：

```js
{"name":"jack",
 "uuid":"4c0ca340-ebb7-4fb1-9eed-04803bac02b2",
 "_cw_collect_time":1605857991844,
 "_cw_raw_time":1605857991844}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to add a UUID.

#### Field description:

targetField: the target field.

#### Sample data:

```js
{"name":"jack"}
```

#### Configuration:

```js
{"targetField":"uuid"}
```

#### Conversion result:

```js
{"name":"jack",
 "uuid":"4c0ca340-ebb7-4fb1-9eed-04803bac02b2",
 "_cw_collect_time":1605857991844,
 "_cw_raw_time":1605857991844}
```

',0, 1, '2021-06-21 18:12:47', 1, '2021-06-21 18:12:50');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (32, 'addTag', '

#### 组件说明：

添加一个或多个标签

#### 字段说明：

tags：添加的标签信息

#### 样例数据：

```js
{"name":"jack"}
```

#### 配置信息：

```js
{"tags":["type1","type2"]}
```

#### 转化结果：

```js
{"name":"jack",
 "tags":["type1","type2"],
 "_cw_collect_time":1605858088288,
 "_cw_raw_time":1605858088288}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to add one or more tags.

#### Field component:

tags: the tags to be added.

#### Sample data:

```js
{"name":"jack"}
```

#### Configuration:

```js
{"tags":["type1","type2"]}
```

#### Conversion result:

```js
{"name":"jack",
 "tags":["type1","type2"],
 "_cw_collect_time":1605858088288,
 "_cw_raw_time":1605858088288}
```

',0, 1, '2021-06-21 18:13:31', 1, '2021-06-21 18:13:34');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (33, 'removeTag', '

#### 组件说明：

删除一个或多个标签

#### 字段说明：

tags：要删除的标签信息

#### 样例数据：

```js
{"name":"jack","tags":["type1","type2"]}
```

#### 配置信息：

```js
{"tags":["type1","type2"]}
```

#### 转化结果：

```js
{"name":"jack",
 "tags":[],
 "_cw_collect_time":1605858584545,
 "_cw_raw_time":1605858584545}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to delete one or more tags.

#### Field description:

tags: the tags to be deleted.

#### Sample data:

```js
{"name":"jack","tags":["type1","type2"]}
```

#### Configuration:

```js
{"tags":["type1","type2"]}
```

#### Conversion result:

```js
{"name":"jack",
 "tags":[],
 "_cw_collect_time":1605858584545,
 "_cw_raw_time":1605858584545}
```

',0, 1, '2021-06-21 18:14:23', 1, '2021-06-21 18:14:26');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (34, 'ahoCorasick', '

#### 组件说明：

定义一个匹配数组，将源字段中匹配到的信息提取到目标数组中

#### 字段说明：

field：源字段

targetField：目标字段

inputWords：匹配数组

#### 样例数据：

```js
{"message":"i like you, i like you to"}
```

#### 配置信息：

```js
{"field":"message","targetField":"after","inputWords":["like","you"]}
```

#### 转化结果：

```js
{"message":"i like you, i like you to",
 "after":["like","you","like","you"],
 "_cw_collect_time":1605859085541,
 "_cw_raw_time":1605859085541}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to extract matched information from the source field to the target array

#### Field description:

field: the source field.

targetField: the destination field.

inputWords: the matched array.

#### Sample data:

```js
{"message":"i like you, i like you to"}
```

#### Configuration:

```js
{"field":"message","targetField":"after","inputWords":["like","you"]}
```

#### Conversion result:

```js
{"message":"i like you, i like you to",
 "after":["like","you","like","you"],
 "_cw_collect_time":1605859085541,
 "_cw_raw_time":1605859085541}
```

',0, 1, '2021-06-21 18:15:14', 1, '2021-06-21 18:15:17');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (35, 'numberExchange', '

#### 组件说明：

将指定字段的数值转换为不同进制的数值

#### 字段说明：

fields：要转换的源字段

in_radix：源字段的进制

out_radix：转换后的进制

#### 样例数据：

```js
{"a":1000,"b":100}
```

#### 配置信息：

```js
{"fields":["a", "b"], "in_radix":2, "out_radix":10}
```

#### 转化结果：

```js
{"a":8,
 "b":4,
 "_cw_collect_time":1605860025892,
 "_cw_raw_time":1605860025892}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to convert the value of a specific field into a value in another number system.

#### Field description:

fields: the source field whose value is to be converted.

in_radix: the number system of the source field value.

out_radix: the converted number system.

#### Sample data:

```js
{"a":1000,"b":100}
```

#### Configuration:

```js
{"fields":["a", "b"], "in_radix":2, "out_radix":10}
```

#### Conversion result:

```js
{"a":8,
 "b":4,
 "_cw_collect_time":1605860025892,
 "_cw_raw_time":1605860025892}
```

',0, 1, '2021-06-21 18:16:29', 1, '2021-06-21 18:16:33');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (36, 'compareAndSet', '

#### 组件说明：

给字段赋值（可开启逻辑判断）

#### 字段说明：

#### 逻辑判断关闭：

赋值的字段：赋值字段

字段值：value

字段类型：string/number

#### 调试举例：

#### 样例数据：

```js
{"a":1}
```

#### 配置信息：

赋值字段：b， 字段值：2， 字段类型：number

#### 转化结果：

```js
{"a":1,"b":2}
```

#### 逻辑判断开启：

#### (1）判断条件

**判断字段** 赋值字段

**操作符** ⼤于/⼤于等于/⼩于/⼩于等于/等于/不等于/正则匹配/包含/不包含/开始于

**判断值** value

#### （2）逻辑处理

|                |               |
| -------------- | ------------- |
| **赋值的字段** | 赋值字段      |
| **字段值**     | value         |
| **字段类型**   | string/nember |

#### 调试举例：

#### 配置信息：

**If条件：** 赋值字段：a， 操作符：等于， 字段值：1

赋值字段：b， 字段值：1， 字段类型：number

**else条件：**赋值字段：b， 字段值：2， 字段类型：number

> if条件:

#### 样例数据：

```js
{"a":1}
```

#### 转化结果：

```js
{"a":1, "b":1}
```

> else条件:

#### 样例数据：

```js
{"a":2}
```

#### 转化结果：

```js
{"a":2, "b":2}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”

', '

#### Component description:

The component used to assign values for fields.

#### Field description:

#### Disable logical evaluation:

Target field: the field to which the value is assigned.

Value: value.

Field type: string/number.

#### Debugging example:

#### Sample data:

```js
{"a":1}
```

#### Configuration:

Target field: b， Value: 2， Field type: number

#### Conversion result:

```js
{"a":1,"b":2}
```

#### Enable logical evaluation:

#### (1）Condition

Field  The field to which the value is assigned.

Condition  Greater than, greater than or equal to, smaller than, smaller than or equal to, equal to, unequal to, regex match, include, exclude, and start from.

#### （2） Logical processing

|            |                                           |
| ---------- | ----------------------------------------- |
| Field      | The field to which the value is assigned. |
| Value      | value                                     |
| Field type | string/nember                             |

#### Debugging example

#### Configuration:

If: Field: a, Condition: equal to,  Value: 1

Field: b, Value: 1,  Field type: number

else: Field: b,  Condition: 2, Field type: number

> if：

#### Sample data:

```js
{"a":1}
```

#### Conversion result:

```js
{"a":1, "b":1}
```

Enable logical evaluation:

#### Sample data:

```js
{"a":2}
```

#### Conversion result:

```js
{"a":2, "b":2}
```',0, 1, '2021-06-21 18:17:19', 1, '2021-06-21 18:17:21');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (37, 'dataFilter', '

#### 组件说明：

用于过滤部分不必要的数据

#### 字段说明：

要判断的字段：要判断的字段

判断符：大于/大于等于/小于/小于等于/等于/不等于/正则匹配/包含/不包含/开始于

要⽐较的值：value

加号：可以进⾏添加多个判断条件并含AND/OR关系

逻辑处理：丢弃数据/保留数据

#### 样例数据：

```js
{"_cw_biz":"a","value":10}
```

#### 配置信息：

```js
配置增加逻辑判断_cw_biz 等于 a，丢弃数据；反之，保留数据
```

#### 转化结果：

```js
将{"_cw_biz":a,"value":10} 丢弃
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to filter unnecessary data.

#### Field description:

Field: the field whose value is to be evaluated.

Condition: greater than, greater than or equal to, smaller than, smaller than or equal to, equal to, unequal to, regex match, include, exclude, and start from.

Value: value.

Plus sign: the button used to add multiple conditions with the and/or relationship.

Logical processing: discards or retains data.

#### Sample data:

```js
{"_cw_biz":"a","value":10}
```

#### Configuration:

```js
Add an evaluation logic that if _cw_biz is equal to a, discard the data. Otherwise, retain the data.
```

#### Conversion result:

```js
Discard {"_cw_biz":a,"value":10}.
```

',0, 1, '2021-06-21 18:18:10', 1, '2021-06-21 18:18:13');
INSERT INTO  `biz_data_pipeline_processor_instructions`(`id`, `type`, `content`, `content_en`, `is_deleted`, `modified_user_id`, `modified_time`, `creation_user_id`, `creation_time`) VALUES (38, 'zabbixDataAccess', '

#### 组件说明：

解析zabbix表达式，方便解析zabbix类型的采集数据

#### 字段说明： 配置字段说明

path：zabbix的监控项配置,例如(vfs.fs.size[{#FSNAME},free])

valueField：监控项。就是这条监控记录对应的监控指标的名称

parentKey：解析结果的父节点

#### 样例数据：

```js
{"host": "182.180.80.45",
  "metric_name": "vfs.fs.size[/home,free]",
  "metric_value": "18927218688",
  "metric_time": "1598343777",
  "metric_tags": {
    "metric_key": "vfs.fs.size[{#FSNAME},free]",
    "model": "AIX"}}
```

#### 配置信息：

```js
{"path":"metric_tags.metric_key","valueField":"metric_name","parentKey":"metric_tags"}
```

#### 转化结果：

```js
{"host":"182.180.80.45",
"metric_name":"vfs.fs.size[/home,free]",
"metric_value":"18927218688",
"metric_time":"1598343777",
"metric_tags":{
    "metric_key":"vfs.fs.size[{#FSNAME},free]",
    "model":"AIX",
    "FSNAME":"/home"
},
"_cw_collect_time":1607479882330,
"_cw_raw_time":1607479882330}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\.”', '

#### Component description:

The component used to parse Zabbix expressions to ease the analysis of Zabbix collection data.

#### Field description: the descriptions of the fields

path: the configuration of the monitoring item in Zabbix, such as (vfs.fs.size[{#FSNAME},free]).

valueField: the monitoring item, which is the name of the monitoring metric involved in this monitoring record.

parentKey: the parent node involved in the parsing process.

#### Sample data:

```js
{"host": "182.180.80.45",
  "metric_name": "vfs.fs.size[/home,free]",
  "metric_value": "18927218688",
  "metric_time": "1598343777",
  "metric_tags": {
    "metric_key": "vfs.fs.size[{#FSNAME},free]",
    "model": "AIX"}}
```

#### Configuration:

```js
{"path":"metric_tags.metric_key","valueField":"metric_name","parentKey":"metric_tags"}
```

#### Conversion result:

```js
{"host":"182.180.80.45",
"metric_name":"vfs.fs.size[/home,free]",
"metric_value":"18927218688",
"metric_time":"1598343777",
"metric_tags":{
    "metric_key":"vfs.fs.size[{#FSNAME},free]",
    "model":"AIX",
    "FSNAME":"/home"
},
"_cw_collect_time":1607479882330,
"_cw_raw_time":1607479882330}
```',0, 1, '2021-06-21 18:18:58', 1, '2021-06-21 18:19:02');