update biz_data_pipeline_processor_instructions set content = '#### 组件说明：

实现JSON排序

#### 字段说明：

field：进行Json排序的源字段

targetField：目标字段（如果不填写则对源字段进行处理）

type：json数据类型，jsonObject/jsonString

sortType：排序方式

#### 样例数据：

JsonString:

```js
{"a":{"metric_tags": "{\\\"b\\\":2, \\\"a\\\":1}"}}
```

JsonObject:

```js
{"a":{"metric_tags": {"b":2,"a":2,"c":3}}}
```

#### 配置信息：

JsonString:

```js
{"config":[{"field":"a.metric_tags","targetField":"c","type":"jsonString","sortType":"asc"}]}
```

JsonObject:

```js
{"config":[{"field":"a.metric_tags","targetField":"","type":"jsonObject","sortType":"asc"}]}
```

 #### 转化结果：

JsonString:

```js
{"a": {"metric_tags": "{"b":2, "a":1}"},

"_cw_collect_time": 1622637449607,

"_cw_raw_time": 1622637449607,

"c": "{"a":1,"b":2}"
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

 注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\\\.”

', content_en = '#### Component description:

The component used to realize JSON sorting.

#### Field description:

field: the source field.

targetField: the target field (If this field is empty, the source field is used.)

type: the JSON data type, including jsonObject and jsonString.

sortType: the method of sorting.

#### Sample data:

JsonString:

```js
{"a":{"metric_tags": "{\\\"b\\\":2, \\\"a\\\":1}"}}
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
{"a": {"metric_tags": "{"b":2, "a":1}"},
"_cw_collect_time": 1622637449607,
"_cw_raw_time": 1622637449607,
"c": "{"a":1,"b":2}"
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

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\”) before the period (.).

' where id =5;
update biz_data_pipeline_processor_instructions set content_en = '#### Component description:

The component used to convert a JSON string into a JSON object or convert a JSON object to a JSON string.

#### Field description: the description of fields

field: the source field to be converted

the target field after conversion

theWay: the conversion method, including STRINGTOOBJECT and OBJECTFLATTEN. The previous one means to convert a string to a map, and the latter one means to flatten a map.

#### Sample data:

```js
{"name":"myron","phone":"185","message":"{\\\"a\\\":\\\"me\\\",\\\"b\\\":\\\"you\\\"}"}
```

#### Configuration:

```js
{"field":"message","targetField":"msg","theWay":"STRINGTOOBJECT"}
```

#### Conversion result:

```js
{"name":"myron",
"phone":"185",
"message":"{"a":"me","b":"you"}",
"_cw_collect_time":1605756575809,
"_cw_raw_time":1605756575809,
"msg":{"a":"me","b":"you"}}
```

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\\\\\”) before the period (.).', content = '#### 组件说明：

用于将jsonString转换为json对象或者将json对象转换为jsonString

#### 字段说明： 配置字段说明

field：要转化的源字段

targetField：转化到的目标字段

theWay：转换方式STRINGTOOBJECT或OBJECTFLATTEN，前者代表字符串转map，后者代表map拉平

#### 样例数据：

```js
{"name":"myron","phone":"185","message":"{\\\"a\\\":\\\"me\\\",\\\"b\\\":\\\"you\\\"}"}
```

#### 配置：

```js
{"field":"message","targetField":"msg","theWay":"STRINGTOOBJECT"}
```

#### 转化结果：

```js
{"name":"myron",

"phone":"185",

"message":"{"a":"me","b":"you"}",

"_cw_collect_time":1605756575809,

"_cw_raw_time":1605756575809,

"msg":{"a":"me","b":"you"}}
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\\\.”' where id =3;
update biz_data_pipeline_processor_instructions set content = '#### 组件说明：

用于将流程拆分成不同的处理流程，例如不同业务数据

#### 字段说明：

判断字段：要处理的字段

判断符：大于/大于等于/小于/小于等于/等于/不等于/正则匹配/包含/不包含/开始于

加号：可以进⾏添加多个判断条件并含AND/OR关系

逻辑处理：输出到不同的分支

#### 样例数据：

```js
{"_cw_biz":"a","value":10}
{"_cw_biz":"b","value":50}
```

#### 配置信息：

```js
配置分支1：_cw_biz 等于 a，分支2：_cw_biz 等于 b；
```

#### 转化结果：

```js
{"_cw_biz":"a","value":10} 输出到处理分支1，
{"_cw_biz":"b","value":50} 输出到处理分支2；
```

注：当字段名内含有“.”时，会识别为层级结构，如不想识别为层级结构，需要在“.”前加转义符为 “\\\\\\\\.”', content_en = '#### Component description:

The component used to split a pipeline into different pipelines based on elements such as different business data.

#### Field description:

Field: the field to be processed

Condition: greater than, greater than or equal to, smaller than, smaller than or equal to, unequal to, Regex match, include, exclude, and start from

Plus sign: the button used to add more conditions and specify the and/or relationships between the conditions.

Logic processing: delivers data to different branches

#### Sample data:

```js
{"_cw_biz":"a","value":10}
{"_cw_biz":"b","value":50}
```

#### Settings

```js
Branch 1：_cw_biz = a, Branch 2: _cw_biz = b；
```

#### Conversion result:

```js
{"_cw_biz":"a","value":10} delivered to Branch 1
{"_cw_biz":"b","value":50} delivered to Branch 2
```

Note: If a field name contains a period (.), the field is identified as a hierarchical structure. To prevent this, you must add an escape character (“\\\\\\\\”) before the period (.).' where id =8;
update biz_data_query_model_help_content set content_en = '# Machine Learning Functions

## evalMLMethod

Prediction using fitted regression models uses `evalMLMethod` function. See link in `linearRegression`.

## stochasticLinearRegression

The [stochasticLinearRegression] aggregate function implements stochastic gradient descent method using linear model and MSE loss function. Uses `evalMLMethod` to predict on new data.

## stochasticLogisticRegression

The [stochasticLogisticRegression] aggregate function implements stochastic gradient descent method for binary classification problem. Uses `evalMLMethod` to predict on new data.

## bayesAB

Compares test groups (variants) and calculates for each group the probability to be the best one. The first group is used as a control group.

**Syntax**

```
bayesAB(distribution_name, higher_is_better, variant_names, x, y)
```

**Arguments**

- `distribution_name` — Name of the probability distribution. String. Possible values:
  - `beta` for [Beta distribution]
  - `gamma` for [Gamma distribution]
- `higher_is_better` — Boolean flag. Boolean. Possible values:
  - `0` — lower values are considered to be better than higher
  - `1` — higher values are considered to be better than lower
- `variant_names` — Variant names. Array.
- `x` — Numbers of tests for the corresponding variants. Array.
- `y` — Numbers of successful tests for the corresponding variants. Array.

Note

All three arrays must have the same size. All `x` and `y` values must be non-negative constant numbers. `y` cannot be larger than `x`.

**Returned values**

For each variant the function calculates:

- `beats_control` — long-term probability to out-perform the first (control) variant
- `to_be_best` — long-term probability to out-perform all other variants

Type: JSON.

**Example**

Query:

```
SELECT bayesAB(beta, 1, [Control, A, B], [3000., 3000., 3000.], [100., 90., 110.]) FORMAT PrettySpace;
```

Result:

```
{
   "data":[
      {
         "variant_name":"Control",
         "x":3000,
         "y":100,
         "beats_control":0,
         "to_be_best":0.22619
      },
      {
         "variant_name":"A",
         "x":3000,
         "y":90,
         "beats_control":0.23469,
         "to_be_best":0.04671
      },
      {
         "variant_name":"B",
         "x":3000,
         "y":110,
         "beats_control":0.7580899999999999,
         "to_be_best":0.7271
      }
   ]
}
```

' where id=46;
update biz_data_query_model_help_content set content_en = '# Functions for Working with External Dictionaries

For information on connecting ad configuring external dictionaries, see [External dictionaries].

## dictGet, dictGetOrDefault, dictGetOrNull

Retrieves values from an external dictionary.

```
dictGet(dict_name, attr_names, id_expr)
dictGetOrDefault(dict_name, attr_names, id_expr, default_value_expr)
dictGetOrNull(dict_name, attr_name, id_expr)
```

**Arguments**

- `dict_name` — Name of the dictionary. [String literal].
- `attr_names` — Name of the column of the dictionary, [String literal], or tuple of column names, Tuple
- `id_expr` — Key value. [Expression] returning a [UInt64](or [Tuple]-type value depending on the dictionary configuration.
- `default_value_expr` — Values returned if the dictionary does not contain a row with the `id_expr` key. [Expression] or [Tuple]([Expression], returning the value (or values) in the data types configured for the `attr_names` attribute.

**Returned value**

- If ClickHouse parses the attribute successfully in the [attribute’s data type], functions return the value of the dictionary attribute that corresponds to `id_expr`.

- If there is no the key, corresponding to `id_expr`, in the dictionary, then:

  ```
  - `dictGet` returns the content of the `<null_value>` element specified for the attribute in the dictionary configuration.
  - `dictGetOrDefault` returns the value passed as the `default_value_expr` parameter.
  - `dictGetOrNull` returns `NULL` in case key was not found in dictionary.
  ```

ClickHouse throws an exception if it cannot parse the value of the attribute or the value does not match the attribute data type.

**Example for simple key dictionary**

Create a text file `ext-dict-test.csv` containing the following:

```
1,1
2,2
```

The first column is `id`, the second column is `c1`.

Configure the external dictionary:

```
<yandex>
    <dictionary>
        <name>ext-dict-test</name>
        <source>
            <file>
                <path>/path-to/ext-dict-test.csv</path>
                <format>CSV</format>
            </file>
        </source>
        <layout>
            <flat />
        </layout>
        <structure>
            <id>
                <name>id</name>
            </id>
            <attribute>
                <name>c1</name>
                <type>UInt32</type>
                <null_value></null_value>
            </attribute>
        </structure>
        <lifetime>0</lifetime>
    </dictionary>
</yandex>
```

Perform the query:

```
SELECT
    dictGetOrDefault(ext-dict-test, c1, number + 1, toUInt32(number * 10)) AS val,
    toTypeName(val) AS type
FROM system.numbers
LIMIT 3
┌─val─┬─type───┐
│   1 │ UInt32 │
│   2 │ UInt32 │
│  20 │ UInt32 │
└─────┴────────┘
```

**Example for complex key dictionary**

Create a text file `ext-dict-mult.csv` containing the following:

```
1,1,1
2,2,2
3,3,3
```

The first column is `id`, the second is `c1`, the third is `c2`.

Configure the external dictionary:

```
<yandex>
    <dictionary>
        <name>ext-dict-mult</name>
        <source>
            <file>
                <path>/path-to/ext-dict-mult.csv</path>
                <format>CSV</format>
            </file>
        </source>
        <layout>
            <flat />
        </layout>
        <structure>
            <id>
                <name>id</name>
            </id>
            <attribute>
                <name>c1</name>
                <type>UInt32</type>
                <null_value></null_value>
            </attribute>
            <attribute>
                <name>c2</name>
                <type>String</type>
                <null_value></null_value>
            </attribute>
        </structure>
        <lifetime>0</lifetime>
    </dictionary>
</yandex>
```

Perform the query:

```
SELECT
    dictGet(ext-dict-mult, (c1,c2), number) AS val,
    toTypeName(val) AS type
FROM system.numbers
LIMIT 3;
┌─val─────┬─type──────────────────┐
│ (1,1) │ Tuple(UInt8, String)  │
│ (2,2) │ Tuple(UInt8, String)  │
│ (3,3) │ Tuple(UInt8, String)  │
└─────────┴───────────────────────┘
```

**Example for range key dictionary**

Input table:

```
CREATE TABLE range_key_dictionary_source_table(    key UInt64,    start_date Date,    end_date Date,    value String,    value_nullable Nullable(String))ENGINE = TinyLog();INSERT INTO range_key_dictionary_source_table VALUES(1, toDate(2019-05-20), toDate(2019-05-20), First, First);INSERT INTO range_key_dictionary_source_table VALUES(2, toDate(2019-05-20), toDate(2019-05-20), Second, NULL);INSERT INTO range_key_dictionary_source_table VALUES(3, toDate(2019-05-20), toDate(2019-05-20), Third, Third);
```

Create the external dictionary:

```
CREATE DICTIONARY range_key_dictionary(    key UInt64,    start_date Date,    end_date Date,    value String,    value_nullable Nullable(String))PRIMARY KEY keySOURCE(CLICKHOUSE(HOST localhost PORT tcpPort() TABLE range_key_dictionary_source_table))LIFETIME(MIN 1 MAX 1000)LAYOUT(RANGE_HASHED())RANGE(MIN start_date MAX end_date);
```

Perform the query:

```
SELECT    (number, toDate(2019-05-20)),    dictHas(range_key_dictionary, number, toDate(2019-05-20)),    dictGetOrNull(range_key_dictionary, value, number, toDate(2019-05-20)),    dictGetOrNull(range_key_dictionary, value_nullable, number, toDate(2019-05-20)),    dictGetOrNull(range_key_dictionary, (value, value_nullable), number, toDate(2019-05-20))FROM system.numbers LIMIT 5 FORMAT TabSeparated;
```

Result:

```
(0,2019-05-20)        0       N      N      (NULL,NULL)(1,2019-05-20)        1       First   First   (First,First)(2,2019-05-20)        0       N      N      (NULL,NULL)(3,2019-05-20)        0       N      N      (NULL,NULL)(4,2019-05-20)        0       N      N      (NULL,NULL)
```

**See Also**

- External Dictionaries

## dictHas

Checks whether a key is present in a dictionary.

```
dictHas(dict_name, id_expr)
```

**Arguments**

- `dict_name` — Name of the dictionary. String literal
- `id_expr` — Key value. Expression returning a UInt64 or Tuple value depending on the dictionary configuration.

**Returned value**

- 0, if there is no key.
- 1, if there is a key.

Type: `UInt8`.

## dictGetHierarchy

Creates an array, containing all the parents of a key in the hierarchical dictionary

**Syntax**

```
dictGetHierarchy(dict_name, key)
```

**Arguments**

- `dict_name` — Name of the dictionary. String literal.
- `key` — Key value. Expression returning a UInt64-type value.

**Returned value**

- Parents for the key.

Type: Array(UInt64).

## dictIsIn

Checks the ancestor of a key through the whole hierarchical chain in the dictionary.

```
dictIsIn(dict_name, child_id_expr, ancestor_id_expr)
```

**Arguments**

- `dict_name` — Name of the dictionary. String literal.
- `child_id_expr` — Key to be checked. Expression returning a UInt64-type value.
- `ancestor_id_expr` — Alleged ancestor of the `child_id_expr` key. Expression returning a UInt64-type value.

**Returned value**

- 0, if `child_id_expr` is not a child of `ancestor_id_expr`.
- 1, if `child_id_expr` is a child of `ancestor_id_expr` or if `child_id_expr` is an `ancestor_id_expr`.

Type: `UInt8`.

## dictGetChildren

Returns first-level children as an array of indexes. It is the inverse transformation for dictGetHierarchy.

**Syntax**

```
dictGetChildren(dict_name, key)
```

**Arguments**

- `dict_name` — Name of the dictionary. String literal.
- `key` — Key value. Expression returning a UInt64-type value.

**Returned values**

- First-level descendants for the key.

Type: Array(UInt64).

**Example**

Consider the hierarchic dictionary:

```
┌─id─┬─parent_id─┐
│  1 │         0 │
│  2 │         1 │
│  3 │         1 │
│  4 │         2 │
└────┴───────────┘
```

First-level children:

```
SELECT dictGetChildren(hierarchy_flat_dictionary, number) FROM system.numbers LIMIT 4;
```

```
┌─dictGetChildren(''hierarchy_flat_dictionary'', number)─┐
│ [1]                                                  │
│ [2,3]                                                │
│ [4]                                                  │
│ []                                                   │
└──────────────────────────────────────────────────────┘
```

## dictGetDescendant

Returns all descendants as if dictGetChildren function was applied `level` times recursively.

**Syntax**

```
dictGetDescendants(dict_name, key, level)
```

**Arguments**

- `dict_name` — Name of the dictionary. String literal.
- `key` — Key value. Expression returning a UInt64-type value.
- `level` — Hierarchy level. If `level = 0` returns all descendants to the end.UInt8.

**Returned values**

- Descendants for the key.

Type: Array(UInt64).

**Example**

Consider the hierarchic dictionary:

```
┌─id─┬─parent_id─┐
│  1 │         0 │
│  2 │         1 │
│  3 │         1 │
│  4 │         2 │
└────┴───────────┘
```

All descendants:

```
SELECT dictGetDescendants(hierarchy_flat_dictionary, number) FROM system.numbers LIMIT 4;
```

```
┌─dictGetDescendants(''hierarchy_flat_dictionary'', number)─┐
│ [1,2,3,4]                                               │
│ [2,3,4]                                                 │
│ [4]                                                     │
│ []                                                      │
└─────────────────────────────────────────────────────────┘
```

First-level descendants:

```
SELECT dictGetDescendants(hierarchy_flat_dictionary, number, 1) FROM system.numbers LIMIT 4;
```

```
┌─dictGetDescendants(''hierarchy_flat_dictionary'', number, 1)─┐
│ [1]                                                        │
│ [2,3]                                                      │
│ [4]                                                        │
│ []                                                         │
└────────────────────────────────────────────────────────────┘
```

## Other Functions

ClickHouse supports specialized functions that convert dictionary attribute values to a specific data type regardless of the dictionary configuration.

Functions:

- `dictGetInt8`, `dictGetInt16`, `dictGetInt32`, `dictGetInt64`
- `dictGetUInt8`, `dictGetUInt16`, `dictGetUInt32`, `dictGetUInt64`
- `dictGetFloat32`, `dictGetFloat64`
- `dictGetDate`
- `dictGetDateTime`
- `dictGetUUID`
- `dictGetString`

All these functions have the `OrDefault` modification. For example, `dictGetDateOrDefault`.

Syntax:

```
dictGet[Type](dict_name, attr_name, id_expr)
dictGet[Type]OrDefault(dict_name, attr_name, id_expr, default_value_expr)
```

**Arguments**

- `dict_name` — Name of the dictionary. String literal.
- `attr_name` — Name of the column of the dictionary. String literal
- `id_expr` — Key value. Expression returning a UInt64 or Tuple-type value depending on the dictionary configuration.
- `default_value_expr` — Value returned if the dictionary does not contain a row with the `id_expr` key. Expression returning the value in the data type configured for the `attr_name` attribute.

**Returned value**

- If ClickHouse parses the attribute successfully in the attribute’s data type, functions return the value of the dictionary attribute that corresponds to `id_expr`.

- If there is no requested `id_expr` in the dictionary then:

  ```
  - `dictGet[Type]` returns the content of the `<null_value>` element specified for the attribute in the dictionary configuration.- `dictGet[Type]OrDefault` returns the value passed as the `default_value_expr` parameter.
  ```

ClickHouse throws an exception if it cannot parse the value of the attribute or the value does not match the attribute data type.

' where id=38;
update biz_data_query_model_help_content set content_en = '# SHOW Statements

## SHOW CREATE TABLE

```
SHOW CREATE [TEMPORARY] [TABLE|DICTIONARY] [db.]table [INTO OUTFILE filename] [FORMAT format]
```

Returns a single `String`-type ‘statement’ column, which contains a single value – the `CREATE` query used for creating the specified object.

## SHOW DATABASES

Prints a list of all databases.

```
SHOW DATABASES [LIKE | ILIKE | NOT LIKE ''<pattern>''] [LIMIT <N>] [INTO OUTFILE filename] [FORMAT format]
```

This statement is identical to the query:

```
SELECT name FROM system.databases [WHERE name LIKE | ILIKE | NOT LIKE ''<pattern>''] [LIMIT <N>] [INTO OUTFILE filename] [FORMAT format]
```

### Examples

Getting database names, containing the symbols sequence ''de'' in their names:

```
SHOW DATABASES LIKE ''%de%''
```

Result:

```
┌─name────┐
│ default │
└─────────┘
```

Getting database names, containing symbols sequence ''de'' in their names, in the case insensitive manner:

```
SHOW DATABASES ILIKE ''%DE%''
```

Result:

```
┌─name────┐
│ default │
└─────────┘
```

Getting database names, not containing the symbols sequence ''de'' in their names:

```
SHOW DATABASES NOT LIKE ''%de%''
```

Result:

```
┌─name───────────────────────────┐
│ _temporary_and_external_tables │
│ system                         │
│ test                           │
│ tutorial                       │
└────────────────────────────────┘
```

Getting the first two rows from database names:

```
SHOW DATABASES LIMIT 2
```

Result:

```
┌─name───────────────────────────┐
│ _temporary_and_external_tables │
│ default                        │
└────────────────────────────────┘
```

## SHOW PROCESSLIST

```
SHOW PROCESSLIST [INTO OUTFILE filename] [FORMAT format]
```

Outputs the content of the system.processes table, that contains a list of queries that is being processed at the moment, excepting `SHOW PROCESSLIST` queries.

The `SELECT * FROM system.processes` query returns data about all the current queries.

Tip (execute in the console):

```
$ watch -n1 "clickhouse-client --query=''SHOW PROCESSLIST''"
```

## SHOW TABLES

Displays a list of tables.

```
SHOW [TEMPORARY] TABLES [{FROM | IN} <db>] [LIKE | ILIKE | NOT LIKE ''<pattern>''] [LIMIT <N>] [INTO OUTFILE <filename>] [FORMAT <format>]
```

If the `FROM` clause is not specified, the query returns the list of tables from the current database.

This statement is identical to the query:

```
SELECT name FROM system.tables [WHERE name LIKE | ILIKE | NOT LIKE ''<pattern>''] [LIMIT <N>] [INTO OUTFILE <filename>] [FORMAT <format>]
```

### Examples

Getting table names, containing the symbols sequence ''user'' in their names:

```
SHOW TABLES FROM system LIKE ''%user%''
```

Result:

```
┌─name─────────────┐
│ user_directories │
│ users            │
└──────────────────┘
```

Getting table names, containing sequence ''user'' in their names, in the case insensitive manner:

```
SHOW TABLES FROM system ILIKE ''%USER%''
```

Result:

```
┌─name─────────────┐
│ user_directories │
│ users            │
└──────────────────┘
```

Getting table names, not containing the symbol sequence ''s'' in their names:

```
SHOW TABLES FROM system NOT LIKE ''%s%''
```

Result:

```
┌─name─────────┐
│ metric_log   │
│ metric_log_0 │
│ metric_log_1 │
└──────────────┘
```

Getting the first two rows from table names:

```
SHOW TABLES FROM system LIMIT 2
```

Result:

```
┌─name───────────────────────────┐
│ aggregate_function_combinators │
│ asynchronous_metric_log        │
└────────────────────────────────┘
```

## SHOW DICTIONARIES

Displays a list of external dictionaries.

```
SHOW DICTIONARIES [FROM <db>] [LIKE ''<pattern>''] [LIMIT <N>] [INTO OUTFILE <filename>] [FORMAT <format>]
```

If the `FROM` clause is not specified, the query returns the list of dictionaries from the current database.

You can get the same results as the `SHOW DICTIONARIES` query in the following way:

```
SELECT name FROM system.dictionaries WHERE database = <db> [AND name LIKE <pattern>] [LIMIT <N>] [INTO OUTFILE <filename>] [FORMAT <format>]
```

**Example**

The following query selects the first two rows from the list of tables in the `system` database, whose names contain `reg`.

```
SHOW DICTIONARIES FROM db LIKE ''%reg%'' LIMIT 2
┌─name─────────┐
│ regions      │
│ region_names │
└──────────────┘
```

## SHOW GRANTS

Shows privileges for a user.

### Syntax

```
SHOW GRANTS [FOR user1 [, user2 ...]]
```

If user is not specified, the query returns privileges for the current user.

## SHOW CREATE USER

Shows parameters that were used at a user creation.

`SHOW CREATE USER` does not output user passwords.

### Syntax

```
SHOW CREATE USER [name1 [, name2 ...] | CURRENT_USER]
```

## SHOW CREATE ROLE

Shows parameters that were used at a role creation.

### Syntax

```
SHOW CREATE ROLE name1 [, name2 ...]
```

## SHOW CREATE ROW POLICY

Shows parameters that were used at a row policy creation.

### Syntax

```
SHOW CREATE [ROW] POLICY name ON [database1.]table1 [, [database2.]table2 ...]
```

## SHOW CREATE QUOTA

Shows parameters that were used at a quota creation.

### Syntax

```
SHOW CREATE QUOTA [name1 [, name2 ...] | CURRENT]
```

## SHOW CREATE SETTINGS PROFILE

Shows parameters that were used at a settings profile creation.

### Syntax

```
SHOW CREATE [SETTINGS] PROFILE name1 [, name2 ...]
```

## SHOW USERS

Returns a list of user account names. To view user accounts parameters, see the system table system.users.

### Syntax

```
SHOW USERS
```

## SHOW ROLES

Returns a list of roles. To view another parameters, see system tables [system.roles and system.role-grants.

### Syntax

```
SHOW [CURRENT|ENABLED] ROLES
```

## SHOW PROFILES

Returns a list of setting profiles. To view user accounts parameters, see the system table settings_profiles.

### Syntax

```
SHOW [SETTINGS] PROFILES
```

## SHOW POLICIES

Returns a list of row policies for the specified table. To view user accounts parameters, see the system table system.row_policies.

### Syntax

```
SHOW [ROW] POLICIES [ON [db.]table]
```

## SHOW QUOTAS

Returns a list of quotas. To view quotas parameters, see the system table system.quotas.

### Syntax

```
SHOW QUOTAS
```

## SHOW QUOTA

Returns a quota consumption for all users or for current user. To view another parameters, see system tables system.quotas_usage and system.quota_usage.

### Syntax

```
SHOW [CURRENT] QUOTA
```

## SHOW ACCESS

Shows all users, roles, profiles, etc. and all their grants.

### Syntax

```
SHOW ACCESS
```

## SHOW CLUSTER(s)

Returns a list of clusters. All available clusters are listed in the system.clusters table.

Note

`SHOW CLUSTER name` query displays the contents of system.clusters table for this cluster.

### Syntax

```
SHOW CLUSTER ''<name>''
SHOW CLUSTERS [LIKE|NOT LIKE ''<pattern>''] [LIMIT <N>]
```

### Examples

Query:

```
SHOW CLUSTERS;
```

Result:

```
┌─cluster──────────────────────────────────────┐
│ test_cluster_two_shards                      │
│ test_cluster_two_shards_internal_replication │
│ test_cluster_two_shards_localhost            │
│ test_shard_localhost                         │
│ test_shard_localhost_secure                  │
│ test_unavailable_shard                       │
└──────────────────────────────────────────────┘
```

Query:

```
SHOW CLUSTERS LIKE ''test%'' LIMIT 1;
```

Result:

```
┌─cluster─────────────────┐
│ test_cluster_two_shards │
└─────────────────────────┘
```

Query:

```
SHOW CLUSTER ''test_shard_localhost'' FORMAT Vertical;
```

Result:

```
Row 1:
──────
cluster:                 test_shard_localhost
shard_num:               1
shard_weight:            1
replica_num:             1
host_name:               localhost
host_address:            127.0.0.1
port:                    9000
is_local:                1
user:                    default
default_database:
errors_count:            0
estimated_recovery_time: 0
```

## SHOW SETTINGS

Returns a list of system settings and their values. Selects data from the system.settings table.

**Syntax**

```
SHOW [CHANGED] SETTINGS LIKE|ILIKE <name>
```

**Clauses**

`LIKE|ILIKE` allow to specify a matching pattern for the setting name. It can contain globs such as `%` or `_`. `LIKE` clause is case-sensitive, `ILIKE` — case insensitive.

When the `CHANGED` clause is used, the query returns only settings changed from their default values.

**Examples**

Query with the `LIKE` clause:

```
SHOW SETTINGS LIKE ''send_timeout'';
```

Result:

```
┌─name─────────┬─type────┬─value─┐
│ send_timeout │ Seconds │ 300   │
└──────────────┴─────────┴───────┘
```

Query with the `ILIKE` clause:

```
SHOW SETTINGS ILIKE ''%CONNECT_timeout%''
```

Result:

```
┌─name────────────────────────────────────┬─type─────────┬─value─┐
│ connect_timeout                         │ Seconds      │ 10    │
│ connect_timeout_with_failover_ms        │ Milliseconds │ 50    │
│ connect_timeout_with_failover_secure_ms │ Milliseconds │ 100   │
└─────────────────────────────────────────┴──────────────┴───────┘
```

Query with the `CHANGED` clause:

```
SHOW CHANGED SETTINGS ILIKE ''%MEMORY%''
```

Result:

```
┌─name─────────────┬─type───┬─value───────┐
│ max_memory_usage │ UInt64 │ 10000000000 │
└──────────────────┴────────┴─────────────┘
```

' where id = 12;
update biz_data_query_model_help_content set content_en = 'By default, the Data processing module executes ClickHouse pushdown queries through the ClickHouse SQL syntax. The non-pushdown queries are executed through the Presto SQL syntax.

DODB extends the SQL syntaxes through the Beetl model engine, allowing you to use variables when creating a model and supporting expressions and control through logics such as IF and For. When a query is being executed, the specified model is rendered through the Beetl model engine, and placeholders are replaced based on the request parameters to form an executable SQL statement. Then, the pushdown or non-pushdown query is executed based on the pushdown setting of the request.

```
// Sample code SELECT
SELECT
  "timestamp",
  "${metric}"
FROM
  stream_kafka.bdp_store_kafka.nbd_console_log
WHERE
  host = \'${host}\'
LIMIT
  ${limitNumber}
```

When you request for model data, you can use custom parameters such as metric, host, and limitNumber. For more information, see the  Query settings dialog box. Custom parameters can make the use of models more flexible. For more information, see the examples of cURL calls through the Copy function in the model list.' where id = 1;
update biz_data_query_model_help_content set content_en = 'ClickHouse supports result sets in multiple formats such as JSON, CSV, and Pretty. You can export batch data in the specified format easily through the ClickHouse client. Example:

```
//Format:
clickhouse-client -h [Host IP address] -f [Result format] -q [SQL statement] > Target file
//Example:
clickhouse-client -h 127.0.0.1 -f CSV -q \'select * from bdp_store_kafka.zxy_test5 limit 10\' > test.csv
```

```
Note: You can copy the SQL statement in the current SQL editor as value of the -q parameter. However, DODB requires the catalog.schema.table structure for tables. Therefore, you must remove the catalog name in the copied SQL statement. For example, remove "stream_kafka" from stream_kafka.bdp_store_kafka.zxy_test5.
```

', content = 'clickHouse支持JSON、CSV、Pretty等多种格式的结果集。可以通过ClickHouse客户端工具快速、方便的导出大批量数据到指定格式文件。例如：

```
//格式:
clickhouse-client -h [主机地址] -f [结果格式] -q [sql语句] > 目标文件
//示例:
clickhouse-client -h 127.0.0.1 -f CSV -q ''select * from bdp_store_kafka.zxy_test5 limit 10'' > test.csv
```

```
注意：可复制当前SQL编辑器中的sql语句作为-q参数值，但数据平台指定表为catalog.schema.table三级结构，请将复制的SQL中的catalog名字去掉，例如将"stream_kafka"."bdp_store_kafka"."zxy_test5"中的"stream_kafka"去掉。
```

' where id = 2;
update biz_data_query_model_help_content set content_en = '# ARRAY JOIN Clause

It is a common operation for tables that contain an array column to produce a new table that has a column with each individual array element of that initial column, while values of other columns are duplicated. This is the basic case of what `ARRAY JOIN` clause does.

Its name comes from the fact that it can be looked at as executing `JOIN` with an array or nested data structure. The intent is similar to the [arrayJoin] function, but the clause functionality is broader.

Syntax:

```
SELECT <expr_list>
FROM <left_subquery>
[LEFT] ARRAY JOIN <array>
[WHERE|PREWHERE <expr>]
...
```

You can specify only one `ARRAY JOIN` clause in a `SELECT` query.

Supported types of `ARRAY JOIN` are listed below:

- `ARRAY JOIN` - In base case, empty arrays are not included in the result of `JOIN`.
- `LEFT ARRAY JOIN` - The result of `JOIN` contains rows with empty arrays. The value for an empty array is set to the default value for the array element type (usually 0, empty string or NULL).

## Basic ARRAY JOIN Examples

The examples below demonstrate the usage of the `ARRAY JOIN` and `LEFT ARRAY JOIN` clauses. Let’s create a table with an [Array] type column and insert values into it:

```
CREATE TABLE arrays_test
(
    s String,
    arr Array(UInt8)
) ENGINE = Memory;

INSERT INTO arrays_test
VALUES (''Hello'', [1,2]), (''World'', [3,4,5]), (''Goodbye'', []);
┌─s───────────┬─arr─────┐
│ Hello       │ [1,2]   │
│ World       │ [3,4,5] │
│ Goodbye     │ []      │
└─────────────┴─────────┘
```

The example below uses the `ARRAY JOIN` clause:

```
SELECT s, arr
FROM arrays_test
ARRAY JOIN arr;
┌─s─────┬─arr─┐
│ Hello │   1 │
│ Hello │   2 │
│ World │   3 │
│ World │   4 │
│ World │   5 │
└───────┴─────┘
```

The next example uses the `LEFT ARRAY JOIN` clause:

```
SELECT s, arr
FROM arrays_test
LEFT ARRAY JOIN arr;
┌─s───────────┬─arr─┐
│ Hello       │   1 │
│ Hello       │   2 │
│ World       │   3 │
│ World       │   4 │
│ World       │   5 │
│ Goodbye     │   0 │
└─────────────┴─────┘
```

## Using Aliases

An alias can be specified for an array in the `ARRAY JOIN` clause. In this case, an array item can be accessed by this alias, but the array itself is accessed by the original name. Example:

```
SELECT s, arr, a
FROM arrays_test
ARRAY JOIN arr AS a;
┌─s─────┬─arr─────┬─a─┐
│ Hello │ [1,2]   │ 1 │
│ Hello │ [1,2]   │ 2 │
│ World │ [3,4,5] │ 3 │
│ World │ [3,4,5] │ 4 │
│ World │ [3,4,5] │ 5 │
└───────┴─────────┴───┘
```

Using aliases, you can perform `ARRAY JOIN` with an external array. For example:

```
SELECT s, arr_external
FROM arrays_test
ARRAY JOIN [1, 2, 3] AS arr_external;
┌─s───────────┬─arr_external─┐
│ Hello       │            1 │
│ Hello       │            2 │
│ Hello       │            3 │
│ World       │            1 │
│ World       │            2 │
│ World       │            3 │
│ Goodbye     │            1 │
│ Goodbye     │            2 │
│ Goodbye     │            3 │
└─────────────┴──────────────┘
```

Multiple arrays can be comma-separated in the `ARRAY JOIN` clause. In this case, `JOIN` is performed with them simultaneously (the direct sum, not the cartesian product). Note that all the arrays must have the same size. Example:

```
SELECT s, arr, a, num, mapped
FROM arrays_test
ARRAY JOIN arr AS a, arrayEnumerate(arr) AS num, arrayMap(x -> x + 1, arr) AS mapped;
┌─s─────┬─arr─────┬─a─┬─num─┬─mapped─┐
│ Hello │ [1,2]   │ 1 │   1 │      2 │
│ Hello │ [1,2]   │ 2 │   2 │      3 │
│ World │ [3,4,5] │ 3 │   1 │      4 │
│ World │ [3,4,5] │ 4 │   2 │      5 │
│ World │ [3,4,5] │ 5 │   3 │      6 │
└───────┴─────────┴───┴─────┴────────┘
```

The example below uses the [arrayEnumerate] function:

```
SELECT s, arr, a, num, arrayEnumerate(arr)
FROM arrays_test
ARRAY JOIN arr AS a, arrayEnumerate(arr) AS num;
┌─s─────┬─arr─────┬─a─┬─num─┬─arrayEnumerate(arr)─┐
│ Hello │ [1,2]   │ 1 │   1 │ [1,2]               │
│ Hello │ [1,2]   │ 2 │   2 │ [1,2]               │
│ World │ [3,4,5] │ 3 │   1 │ [1,2,3]             │
│ World │ [3,4,5] │ 4 │   2 │ [1,2,3]             │
│ World │ [3,4,5] │ 5 │   3 │ [1,2,3]             │
└───────┴─────────┴───┴─────┴─────────────────────┘
```

## ARRAY JOIN with Nested Data Structure

`ARRAY JOIN` also works with [nested data structures]:

```
CREATE TABLE nested_test
(
    s String,
    nest Nested(
    x UInt8,
    y UInt32)
) ENGINE = Memory;

INSERT INTO nested_test
VALUES (''Hello'', [1,2], [10,20]), (''World'', [3,4,5], [30,40,50]), (''Goodbye'', [], []);
┌─s───────┬─nest.x──┬─nest.y─────┐
│ Hello   │ [1,2]   │ [10,20]    │
│ World   │ [3,4,5] │ [30,40,50] │
│ Goodbye │ []      │ []         │
└─────────┴─────────┴────────────┘
SELECT s, `nest.x`, `nest.y`
FROM nested_test
ARRAY JOIN nest;
┌─s─────┬─nest.x─┬─nest.y─┐
│ Hello │      1 │     10 │
│ Hello │      2 │     20 │
│ World │      3 │     30 │
│ World │      4 │     40 │
│ World │      5 │     50 │
└───────┴────────┴────────┘
```

When specifying names of nested data structures in `ARRAY JOIN`, the meaning is the same as `ARRAY JOIN` with all the array elements that it consists of. Examples are listed below:

```
SELECT s, `nest.x`, `nest.y`
FROM nested_test
ARRAY JOIN `nest.x`, `nest.y`;
┌─s─────┬─nest.x─┬─nest.y─┐
│ Hello │      1 │     10 │
│ Hello │      2 │     20 │
│ World │      3 │     30 │
│ World │      4 │     40 │
│ World │      5 │     50 │
└───────┴────────┴────────┘
```

This variation also makes sense:

```
SELECT s, `nest.x`, `nest.y`
FROM nested_test
ARRAY JOIN `nest.x`;
┌─s─────┬─nest.x─┬─nest.y─────┐
│ Hello │      1 │ [10,20]    │
│ Hello │      2 │ [10,20]    │
│ World │      3 │ [30,40,50] │
│ World │      4 │ [30,40,50] │
│ World │      5 │ [30,40,50] │
└───────┴────────┴────────────┘
```

An alias may be used for a nested data structure, in order to select either the `JOIN` result or the source array. Example:

```
SELECT s, `n.x`, `n.y`, `nest.x`, `nest.y`
FROM nested_test
ARRAY JOIN nest AS n;
┌─s─────┬─n.x─┬─n.y─┬─nest.x──┬─nest.y─────┐
│ Hello │   1 │  10 │ [1,2]   │ [10,20]    │
│ Hello │   2 │  20 │ [1,2]   │ [10,20]    │
│ World │   3 │  30 │ [3,4,5] │ [30,40,50] │
│ World │   4 │  40 │ [3,4,5] │ [30,40,50] │
│ World │   5 │  50 │ [3,4,5] │ [30,40,50] │
└───────┴─────┴─────┴─────────┴────────────┘
```

Example of using the [arrayEnumerate] function:

```
SELECT s, `n.x`, `n.y`, `nest.x`, `nest.y`, num
FROM nested_test
ARRAY JOIN nest AS n, arrayEnumerate(`nest.x`) AS num;
┌─s─────┬─n.x─┬─n.y─┬─nest.x──┬─nest.y─────┬─num─┐
│ Hello │   1 │  10 │ [1,2]   │ [10,20]    │   1 │
│ Hello │   2 │  20 │ [1,2]   │ [10,20]    │   2 │
│ World │   3 │  30 │ [3,4,5] │ [30,40,50] │   1 │
│ World │   4 │  40 │ [3,4,5] │ [30,40,50] │   2 │
│ World │   5 │  50 │ [3,4,5] │ [30,40,50] │   3 │
└───────┴─────┴─────┴─────────┴────────────┴─────┘
```

## Implementation Details

The query execution order is optimized when running `ARRAY JOIN`. Although `ARRAY JOIN` must always be specified before the [WHERE]/[PREWHERE] clause in a query, technically they can be performed in any order, unless result of `ARRAY JOIN` is used for filtering. The processing order is controlled by the query optimizer.' where id = 57;
update biz_data_query_model_help_content set content_en = '# ORDER BY Clause

The `ORDER BY` clause contains a list of expressions, which can each be attributed with `DESC` (descending) or `ASC` (ascending) modifier which determine the sorting direction. If the direction is not specified, `ASC` is assumed, so it’s usually omitted. The sorting direction applies to a single expression, not to the entire list. Example: `ORDER BY Visits DESC, SearchPhrase`

Rows that have identical values for the list of sorting expressions are output in an arbitrary order, which can also be non-deterministic (different each time).
If the ORDER BY clause is omitted, the order of the rows is also undefined, and may be non-deterministic as well.

## Sorting of Special Values

There are two approaches to `NaN` and `NULL` sorting order:

- By default or with the `NULLS LAST` modifier: first the values, then `NaN`, then `NULL`.
- With the `NULLS FIRST` modifier: first `NULL`, then `NaN`, then other values.

### Example

For the table

```
┌─x─┬────y─┐
│ 1 │ ᴺᵁᴸᴸ │
│ 2 │    2 │
│ 1 │  nan │
│ 2 │    2 │
│ 3 │    4 │
│ 5 │    6 │
│ 6 │  nan │
│ 7 │ ᴺᵁᴸᴸ │
│ 6 │    7 │
│ 8 │    9 │
└───┴──────┘
```

Run the query `SELECT * FROM t_null_nan ORDER BY y NULLS FIRST` to get:

```
┌─x─┬────y─┐
│ 1 │ ᴺᵁᴸᴸ │
│ 7 │ ᴺᵁᴸᴸ │
│ 1 │  nan │
│ 6 │  nan │
│ 2 │    2 │
│ 2 │    2 │
│ 3 │    4 │
│ 5 │    6 │
│ 6 │    7 │
│ 8 │    9 │
└───┴──────┘
```

When floating point numbers are sorted, NaNs are separate from the other values. Regardless of the sorting order, NaNs come at the end. In other words, for ascending sorting they are placed as if they are larger than all the other numbers, while for descending sorting they are placed as if they are smaller than the rest.

## Collation Support

For sorting by [String] values, you can specify collation (comparison). Example: `ORDER BY SearchPhrase COLLATE tr` - for sorting by keyword in ascending order, using the Turkish alphabet, case insensitive, assuming that strings are UTF-8 encoded. `COLLATE` can be specified or not for each expression in ORDER BY independently. If `ASC` or `DESC` is specified, `COLLATE` is specified after it. When using `COLLATE`, sorting is always case-insensitive.

Collate is supported in [LowCardinality], [Nullable], [Array] and [Tuple].

We only recommend using `COLLATE` for final sorting of a small number of rows, since sorting with `COLLATE` is less efficient than normal sorting by bytes.

## Collation Examples

Example only with [String] values:

Input table:

```
┌─x─┬─s────┐
│ 1 │ bca  │
│ 2 │ ABC  │
│ 3 │ 123a │
│ 4 │ abc  │
│ 5 │ BCA  │
└───┴──────┘
```

Query:

```
SELECT * FROM collate_test ORDER BY s ASC COLLATE en;
```

Result:

```
┌─x─┬─s────┐
│ 3 │ 123a │
│ 4 │ abc  │
│ 2 │ ABC  │
│ 1 │ bca  │
│ 5 │ BCA  │
└───┴──────┘
```

Example with [Nullable]:

Input table:

```
┌─x─┬─s────┐
│ 1 │ bca  │
│ 2 │ ᴺᵁᴸᴸ │
│ 3 │ ABC  │
│ 4 │ 123a │
│ 5 │ abc  │
│ 6 │ ᴺᵁᴸᴸ │
│ 7 │ BCA  │
└───┴──────┘
```

Query:

```
SELECT * FROM collate_test ORDER BY s ASC COLLATE en;
```

Result:

```
┌─x─┬─s────┐
│ 4 │ 123a │
│ 5 │ abc  │
│ 3 │ ABC  │
│ 1 │ bca  │
│ 7 │ BCA  │
│ 6 │ ᴺᵁᴸᴸ │
│ 2 │ ᴺᵁᴸᴸ │
└───┴──────┘
```

Example with [Array]:

Input table:

```
┌─x─┬─s─────────────┐
│ 1 │ [Z]         │
│ 2 │ [z]         │
│ 3 │ [a]         │
│ 4 │ [A]         │
│ 5 │ [z,a]     │
│ 6 │ [z,a,a] │
│ 7 │ []          │
└───┴───────────────┘
```

Query:

```
SELECT * FROM collate_test ORDER BY s ASC COLLATE en;
```

Result:

```
┌─x─┬─s─────────────┐
│ 7 │ []          │
│ 3 │ [a]         │
│ 4 │ [A]         │
│ 2 │ [z]         │
│ 5 │ [z,a]     │
│ 6 │ [z,a,a] │
│ 1 │ [Z]         │
└───┴───────────────┘
```

Example with [LowCardinality] string:

Input table:

```
┌─x─┬─s───┐
│ 1 │ Z   │
│ 2 │ z   │
│ 3 │ a   │
│ 4 │ A   │
│ 5 │ za  │
│ 6 │ zaa │
│ 7 │     │
└───┴─────┘
```

Query:

```
SELECT * FROM collate_test ORDER BY s ASC COLLATE en;
```

Result:

```
┌─x─┬─s───┐
│ 7 │     │
│ 3 │ a   │
│ 4 │ A   │
│ 2 │ z   │
│ 1 │ Z   │
│ 5 │ za  │
│ 6 │ zaa │
└───┴─────┘
```

Example with [Tuple]:

```
┌─x─┬─s───────┐
│ 1 │ (1,Z) │
│ 2 │ (1,z) │
│ 3 │ (1,a) │
│ 4 │ (2,z) │
│ 5 │ (1,A) │
│ 6 │ (2,Z) │
│ 7 │ (2,A) │
└───┴─────────┘
```

Query:

```
SELECT * FROM collate_test ORDER BY s ASC COLLATE en;
```

Result:

```
┌─x─┬─s───────┐
│ 3 │ (1,a) │
│ 5 │ (1,A) │
│ 2 │ (1,z) │
│ 1 │ (1,Z) │
│ 7 │ (2,A) │
│ 4 │ (2,z) │
│ 6 │ (2,Z) │
└───┴─────────┘
```

## Implementation Details

Less RAM is used if a small enough [LIMIT] is specified in addition to `ORDER BY`. Otherwise, the amount of memory spent is proportional to the volume of data for sorting. For distributed query processing, if [GROUP BY] is omitted, sorting is partially done on remote servers, and the results are merged on the requestor server. This means that for distributed sorting, the volume of data to sort can be greater than the amount of memory on a single server.

If there is not enough RAM, it is possible to perform sorting in external memory (creating temporary files on a disk). Use the setting `max_bytes_before_external_sort` for this purpose. If it is set to 0 (the default), external sorting is disabled. If it is enabled, when the volume of data to sort reaches the specified number of bytes, the collected data is sorted and dumped into a temporary file. After all data is read, all the sorted files are merged and the results are output. Files are written to the `/var/lib/clickhouse/tmp/` directory in the config (by default, but you can use the `tmp_path` parameter to change this setting).

Running a query may use more memory than `max_bytes_before_external_sort`. For this reason, this setting must have a value significantly smaller than `max_memory_usage`. As an example, if your server has 128 GB of RAM and you need to run a single query, set `max_memory_usage` to 100 GB, and `max_bytes_before_external_sort` to 80 GB.

External sorting works much less effectively than sorting in RAM.

## Optimization of Data Reading

If `ORDER BY` expression has a prefix that coincides with the table sorting key, you can optimize the query by using the [optimize_read_in_order] setting.

When the `optimize_read_in_order` setting is enabled, the ClickHouse server uses the table index and reads the data in order of the `ORDER BY` key. This allows to avoid reading all data in case of specified [LIMIT]. So queries on big data with small limit are processed faster.

Optimization works with both `ASC` and `DESC` and does not work together with [GROUP BY] clause and [FINAL] modifier.

When the `optimize_read_in_order` setting is disabled, the ClickHouse server does not use the table index while processing `SELECT` queries.

Consider disabling `optimize_read_in_order` manually, when running queries that have `ORDER BY` clause, large `LIMIT` and [WHERE] condition that requires to read huge amount of records before queried data is found.

Optimization is supported in the following table engines:

- [MergeTree]
- [Merge], [Buffer], and [MaterializedView] table engines over `MergeTree`-engine tables

In `MaterializedView`-engine tables the optimization works with views like `SELECT ... FROM merge_tree_table ORDER BY pk`. But it is not supported in the queries like `SELECT ... FROM view ORDER BY pk` if the view query does not have the `ORDER BY` clause.

## ORDER BY Expr WITH FILL Modifier

This modifier also can be combined with [LIMIT … WITH TIES modifier].

`WITH FILL` modifier can be set after `ORDER BY expr` with optional `FROM expr`, `TO expr` and `STEP expr` parameters.
All missed values of `expr` column will be filled sequentially and other columns will be filled as defaults.

Use following syntax for filling multiple columns add `WITH FILL` modifier with optional parameters after each field name in `ORDER BY` section.

```
ORDER BY expr [WITH FILL] [FROM const_expr] [TO const_expr] [STEP const_numeric_expr], ... exprN [WITH FILL] [FROM expr] [TO expr] [STEP numeric_expr]
```

`WITH FILL` can be applied only for fields with Numeric (all kind of float, decimal, int) or Date/DateTime types.
When `FROM const_expr` not defined sequence of filling use minimal `expr` field value from `ORDER BY`.
When `TO const_expr` not defined sequence of filling use maximum `expr` field value from `ORDER BY`.
When `STEP const_numeric_expr` defined then `const_numeric_expr` interprets `as is` for numeric types as `days` for Date type and as `seconds` for DateTime type.
When `STEP const_numeric_expr` omitted then sequence of filling use `1.0` for numeric type, `1 day` for Date type and `1 second` for DateTime type.

For example, the following query

```
SELECT n, source FROM (
   SELECT toFloat32(number % 10) AS n, ''original'' AS source
   FROM numbers(10) WHERE number % 3 = 1
) ORDER BY n
```

returns

```
┌─n─┬─source───┐
│ 1 │ original │
│ 4 │ original │
│ 7 │ original │
└───┴──────────┘
```

but after apply `WITH FILL` modifier

```
SELECT n, source FROM (
   SELECT toFloat32(number % 10) AS n, original AS source
   FROM numbers(10) WHERE number % 3 = 1
) ORDER BY n WITH FILL FROM 0 TO 5.51 STEP 0.5
```

returns

```
┌───n─┬─source───┐
│   0 │          │
│ 0.5 │          │
│   1 │ original │
│ 1.5 │          │
│   2 │          │
│ 2.5 │          │
│   3 │          │
│ 3.5 │          │
│   4 │ original │
│ 4.5 │          │
│   5 │          │
│ 5.5 │          │
│   7 │ original │
└─────┴──────────┘
```

For the case when we have multiple fields `ORDER BY field2 WITH FILL, field1 WITH FILL` order of filling will follow the order of fields in `ORDER BY` clause.

Example:

```
SELECT
    toDate((number * 10) * 86400) AS d1,
    toDate(number * 86400) AS d2,
    ''original'' AS source
FROM numbers(10)
WHERE (number % 3) = 1
ORDER BY
    d2 WITH FILL,
    d1 WITH FILL STEP 5;
```

returns

```
┌───d1───────┬───d2───────┬─source───┐
│ 1970-01-11 │ 1970-01-02 │ original │
│ 1970-01-01 │ 1970-01-03 │          │
│ 1970-01-01 │ 1970-01-04 │          │
│ 1970-02-10 │ 1970-01-05 │ original │
│ 1970-01-01 │ 1970-01-06 │          │
│ 1970-01-01 │ 1970-01-07 │          │
│ 1970-03-12 │ 1970-01-08 │ original │
└────────────┴────────────┴──────────┘
```

Field `d1` does not fill and use default value cause we do not have repeated values for `d2` value, and sequence for `d1` can’t be properly calculated.

The following query with a changed field in `ORDER BY`

```
SELECT
    toDate((number * 10) * 86400) AS d1,
    toDate(number * 86400) AS d2,
    original AS source
FROM numbers(10)
WHERE (number % 3) = 1
ORDER BY
    d1 WITH FILL STEP 5,
    d2 WITH FILL;
```

returns

```
┌───d1───────┬───d2───────┬─source───┐
│ 1970-01-11 │ 1970-01-02 │ original │
│ 1970-01-16 │ 1970-01-01 │          │
│ 1970-01-21 │ 1970-01-01 │          │
│ 1970-01-26 │ 1970-01-01 │          │
│ 1970-01-31 │ 1970-01-01 │          │
│ 1970-02-05 │ 1970-01-01 │          │
│ 1970-02-10 │ 1970-01-05 │ original │
│ 1970-02-15 │ 1970-01-01 │          │
│ 1970-02-20 │ 1970-01-01 │          │
│ 1970-02-25 │ 1970-01-01 │          │
│ 1970-03-02 │ 1970-01-01 │          │
│ 1970-03-07 │ 1970-01-01 │          │
│ 1970-03-12 │ 1970-01-08 │ original │
└────────────┴────────────┴──────────┘
```

' where id = 67;
update biz_data_query_model_help_content set content_en = '## ALTER

Most `ALTER` queries modify table settings or data:

- [COLUMN]
- [PARTITION]
- [DELETE]
- [UPDATE]
- [ORDER BY]
- [INDEX]
- [CONSTRAINT]
- [TTL]

Note

Most `ALTER` queries are supported only for [*MergeTree tables, as well as [Merge] and [Distributed].

While these `ALTER` settings modify entities related to role-based access control:

- [USER]
- [ROLE]
- [QUOTA]
- [ROW POLICY]
- [SETTINGS PROFILE]

## Mutations

`ALTER` queries that are intended to manipulate table data are implemented with a mechanism called “mutations”, most notably [ALTER TABLE … DELETE] and [ALTER TABLE … UPDATE]. They are asynchronous background processes similar to merges in [MergeTree] tables that to produce new “mutated” versions of parts.

For `*MergeTree` tables mutations execute by **rewriting whole data parts**. There is no atomicity - parts are substituted for mutated parts as soon as they are ready and a `SELECT` query that started executing during a mutation will see data from parts that have already been mutated along with data from parts that have not been mutated yet.

Mutations are totally ordered by their creation order and are applied to each part in that order. Mutations are also partially ordered with `INSERT INTO` queries: data that was inserted into the table before the mutation was submitted will be mutated and data that was inserted after that will not be mutated. Note that mutations do not block inserts in any way.

A mutation query returns immediately after the mutation entry is added (in case of replicated tables to ZooKeeper, for non-replicated tables - to the filesystem). The mutation itself executes asynchronously using the system profile settings. To track the progress of mutations you can use the [`system.mutations`] table. A mutation that was successfully submitted will continue to execute even if ClickHouse servers are restarted. There is no way to roll back the mutation once it is submitted, but if the mutation is stuck for some reason it can be cancelled with the [`KILL MUTATION`] query.

Entries for finished mutations are not deleted right away (the number of preserved entries is determined by the `finished_mutations_to_keep` storage engine parameter). Older mutation entries are deleted.

## Synchronicity of ALTER Queries

For non-replicated tables, all `ALTER` queries are performed synchronously. For replicated tables, the query just adds instructions for the appropriate actions to `ZooKeeper`, and the actions themselves are performed as soon as possible. However, the query can wait for these actions to be completed on all the replicas.

For `ALTER ... ATTACH|DETACH|DROP` queries, you can use the `replication_alter_partitions_sync` setting to set up waiting. Possible values: `0` – do not wait; `1` – only wait for own execution (default); `2` – wait for all.

For `ALTER TABLE ... UPDATE|DELETE` queries the synchronicity is defined by the [mutations_sync] setting.

# Column Manipulations

A set of queries that allow changing the table structure.

Syntax:

```
ALTER TABLE [db].name [ON CLUSTER cluster] ADD|DROP|CLEAR|COMMENT|MODIFY COLUMN ...
```

In the query, specify a list of one or more comma-separated actions.
Each action is an operation on a column.

The following actions are supported:

- [ADD COLUMN] — Adds a new column to the table.
- [DROP COLUMN]— Deletes the column.
- [RENAME COLUMN] — Renames the column.
- [CLEAR COLUMN]— Resets column values.
- [COMMENT COLUMN] — Adds a text comment to the column.
- [MODIFY COLUMN]— Changes column’s type, default expression and TTL.
- [MODIFY COLUMN REMOVE]— Removes one of the column properties.
- [RENAME COLUMN]— Renames an existing column.

These actions are described in detail below.

## ADD COLUMN[ ]

```
ADD COLUMN [IF NOT EXISTS] name [type] [default_expr] [codec] [AFTER name_after | FIRST]
```

Adds a new column to the table with the specified `name`, `type`, [`codec`] and `default_expr` (see the section [Default expressions]).

If the `IF NOT EXISTS` clause is included, the query won’t return an error if the column already exists. If you specify `AFTER name_after` (the name of another column), the column is added after the specified one in the list of table columns. If you want to add a column to the beginning of the table use the `FIRST` clause. Otherwise, the column is added to the end of the table. For a chain of actions, `name_after` can be the name of a column that is added in one of the previous actions.

Adding a column just changes the table structure, without performing any actions with data. The data does not appear on the disk after `ALTER`. If the data is missing for a column when reading from the table, it is filled in with default values (by performing the default expression if there is one, or using zeros or empty strings). The column appears on the disk after merging data parts (see [MergeTree]).

This approach allows us to complete the `ALTER` query instantly, without increasing the volume of old data.

Example:

```
ALTER TABLE alter_test ADD COLUMN Added1 UInt32 FIRST;
ALTER TABLE alter_test ADD COLUMN Added2 UInt32 AFTER NestedColumn;
ALTER TABLE alter_test ADD COLUMN Added3 UInt32 AFTER ToDrop;
DESC alter_test FORMAT TSV;
Added1  UInt32
CounterID       UInt32
StartDate       Date
UserID  UInt32
VisitID UInt32
NestedColumn.A  Array(UInt8)
NestedColumn.S  Array(String)
Added2  UInt32
ToDrop  UInt32
Added3  UInt32
```

## DROP COLUMN

```
DROP COLUMN [IF EXISTS] name
```

Deletes the column with the name `name`. If the `IF EXISTS` clause is specified, the query won’t return an error if the column does not exist.

Deletes data from the file system. Since this deletes entire files, the query is completed almost instantly.

Warning

You can’t delete a column if it is referenced by [materialized view]. Otherwise, it returns an error.

Example:

```
ALTER TABLE visits DROP COLUMN browser
```

## RENAME COLUMN[ ](https://clickhouse.tech/docs/en/sql-reference/statements/alter/column/#alter_rename-column)

```
RENAME COLUMN [IF EXISTS] name to new_name
```

Renames the column `name` to `new_name`. If the `IF EXISTS` clause is specified, the query won’t return an error if the column does not exist. Since renaming does not involve the underlying data, the query is completed almost instantly.

**NOTE**: Columns specified in the key expression of the table (either with `ORDER BY` or `PRIMARY KEY`) cannot be renamed. Trying to change these columns will produce `SQL Error [524]`.

Example:

```
ALTER TABLE visits RENAME COLUMN webBrowser TO browser
```

## CLEAR COLUMN

```
CLEAR COLUMN [IF EXISTS] name IN PARTITION partition_name
```

Resets all data in a column for a specified partition. Read more about setting the partition name in the section [How to specify the partition expression].

If the `IF EXISTS` clause is specified, the query won’t return an error if the column does not exist.

Example:

```
ALTER TABLE visits CLEAR COLUMN browser IN PARTITION tuple()
```

## COMMENT COLUMN

```
COMMENT COLUMN [IF EXISTS] name ''comment''
```

Adds a comment to the column. If the `IF EXISTS` clause is specified, the query won’t return an error if the column does not exist.

Each column can have one comment. If a comment already exists for the column, a new comment overwrites the previous comment.

Comments are stored in the `comment_expression` column returned by the [DESCRIBE TABLE] query.

Example:

```
ALTER TABLE visits COMMENT COLUMN browser ''The table shows the browser used for accessing the site.''
```

## MODIFY COLUMN

```
MODIFY COLUMN [IF EXISTS] name [type] [default_expr] [TTL] [AFTER name_after | FIRST]
```

This query changes the `name` column properties:

- Type
- Default expression
- TTL

For examples of columns TTL modifying, see [Column TTL].

If the `IF EXISTS` clause is specified, the query won’t return an error if the column does not exist.

The query also can change the order of the columns using `FIRST | AFTER` clause, see [ADD COLUMN] description.
 functions were applied to them. If only the default expression is changed, the query does not do anything complex, and is completed almost instantly.

Example:

```
ALTER TABLE visits MODIFY COLUMN browser Array(String)
```

Changing the column type is the only complex action – it changes the contents of files with data. For large tables, this may take a long time.

The `ALTER` query is atomic. For MergeTree tables it is also lock-free.

The `ALTER` query for changing columns is replicated. The instructions are saved in ZooKeeper, then each replica applies them. All `ALTER` queries are run in the same order. The query waits for the appropriate actions to be completed on the other replicas. However, a query to change columns in a replicated table can be interrupted, and all actions will be performed asynchronously.

## MODIFY COLUMN REMOVE

Removes one of the column properties: `DEFAULT`, `ALIAS`, `MATERIALIZED`, `CODEC`, `COMMENT`, `TTL`.

Syntax:

```
ALTER TABLE table_name MODIFY column_name REMOVE property;
```

**Example**

```
ALTER TABLE table_with_ttl MODIFY COLUMN column_ttl REMOVE TTL;
```

**See Also**

- [REMOVE TTL].

## RENAME COLUMN

Renames an existing column.

Syntax:

```
ALTER TABLE table_name RENAME COLUMN column_name TO new_column_name
```

**Example**

```
ALTER TABLE table_with_ttl RENAME COLUMN column_ttl TO column_ttl_new;
```

## Limitations

The `ALTER` query lets you create and delete separate elements (columns) in nested data structures, but not whole nested data structures. To add a nested data structure, you can add columns with a name like `name.nested_name` and the type `Array(T)`. A nested data structure is equivalent to multiple array columns with a name that has the same prefix before the dot.

There is no support for deleting columns in the primary key or the sampling key (columns that are used in the `ENGINE` expression). Changing the type for columns that are included in the primary key is only possible if this change does not cause the data to be modified (for example, you are allowed to add values to an Enum or to change a type from `DateTime` to `UInt32`).

If the `ALTER` query is not sufficient to make the table changes you need, you can create a new table, copy the data to it using the [INSERT SELECT] query, then switch the tables using the [RENAME]query and delete the old table. You can use the [clickhouse-copier] as an alternative to the `INSERT SELECT` query.

The `ALTER` query blocks all reads and writes for the table. In other words, if a long `SELECT` is running at the time of the `ALTER` query, the `ALTER` query will wait for it to complete. At the same time, all new queries to the same table will wait while this `ALTER` is running.

For tables that do not store data themselves (such as `Merge` and `Distributed`), `ALTER` just changes the table structure, and does not change the structure of subordinate tables. For example, when running ALTER for a `Distributed` table, you will also need to run `ALTER` for the tables on all remote servers.

# Manipulating Partitions and Parts

The following operations with [partitions] are available:

- [DETACH PARTITION] — Moves a partition to the `detached` directory and forget it.
- [DROP PARTITION] — Deletes a partition.
- [ATTACH PART|PARTITION] — Adds a part or partition from the `detached` directory to the table.
- [ATTACH PARTITION FROM] — Copies the data partition from one table to another and adds.
- [REPLACE PARTITION] — Copies the data partition from one table to another and replaces.
- [MOVE PARTITION TO TABLE] — Moves the data partition from one table to another.
- [CLEAR COLUMN IN PARTITION] — Resets the value of a specified column in a partition.
- [CLEAR INDEX IN PARTITION] — Resets the specified secondary index in a partition.
- [FREEZE PARTITION] — Creates a backup of a partition.
- [UNFREEZE PARTITION] — Removes a backup of a partition.
- [FETCH PARTITION|PART] — Downloads a part or partition from another server.
- [MOVE PARTITION|PART]— Move partition/data part to another disk or volume.
- [UPDATE IN PARTITION]— Update data inside the partition by condition.
- [DELETE IN PARTITION] — Delete data inside the partition by condition.

## DETACH PARTITION|PART

```
ALTER TABLE table_name DETACH PARTITION|PART partition_expr
```

Moves all data for the specified partition to the `detached` directory. The server forgets about the detached data partition as if it does not exist. The server will not know about this data until you make the [ATTACH] query.

Example:

```
ALTER TABLE mt DETACH PARTITION 2020-11-21;
ALTER TABLE mt DETACH PART all_2_2_0;
```

Read about setting the partition expression in a section [How to specify the partition expression].

After the query is executed, you can do whatever you want with the data in the `detached` directory — delete it from the file system, or just leave it.

This query is replicated – it moves the data to the `detached` directory on all replicas. Note that you can execute this query only on a leader replica. To find out if a replica is a leader, perform the `SELECT` query to the [system.replicas] table. Alternatively, it is easier to make a `DETACH` query on all replicas - all the replicas throw an exception, except the leader replicas (as multiple leaders are allowed).

## DROP PARTITION|PART

```
ALTER TABLE table_name DROP PARTITION|PART partition_expr
```

Deletes the specified partition from the table. This query tags the partition as inactive and deletes data completely, approximately in 10 minutes.

Read about setting the partition expression in a section [How to specify the partition expression]partition/#alter-how-to-specify-part-expr).

The query is replicated – it deletes data on all replicas.

Example:

```
ALTER TABLE mt DROP PARTITION 2020-11-21;
ALTER TABLE mt DROP PART all_4_4_0;
```

## DROP DETACHED PARTITION|PART

```
ALTER TABLE table_name DROP DETACHED PARTITION|PART partition_expr
```

Removes the specified part or all parts of the specified partition from `detached`.
Read more about setting the partition expression in a section [How to specify the partition expression].

## ATTACH PARTITION|PART

```
ALTER TABLE table_name ATTACH PARTITION|PART partition_expr
```

Adds data to the table from the `detached` directory. It is possible to add data for an entire partition or for a separate part. Examples:

```
ALTER TABLE visits ATTACH PARTITION 201901;
ALTER TABLE visits ATTACH PART 201901_2_2_0;
```

Read more about setting the partition expression in a section [How to specify the partition expression].

This query is replicated. The replica-initiator checks whether there is data in the `detached` directory.
If data exists, the query checks its integrity. If everything is correct, the query adds the data to the table.

If the non-initiator replica, receiving the attach command, finds the part with the correct checksums in its own `detached` folder, it attaches the data without fetching it from other replicas.
If there is no part with the correct checksums, the data is downloaded from any replica having the part.

You can put data to the `detached` directory on one replica and use the `ALTER ... ATTACH` query to add it to the table on all replicas.

## ATTACH PARTITION FROM

```
ALTER TABLE table2 ATTACH PARTITION partition_expr FROM table1
```

This query copies the data partition from `table1` to `table2`.
Note that data will be deleted neither from `table1` nor from `table2`.

For the query to run successfully, the following conditions must be met:

- Both tables must have the same structure.
- Both tables must have the same partition key.

## REPLACE PARTITION

```
ALTER TABLE table2 REPLACE PARTITION partition_expr FROM table1
```

This query copies the data partition from the `table1` to `table2` and replaces existing partition in the `table2`. Note that data won’t be deleted from `table1`.

For the query to run successfully, the following conditions must be met:

- Both tables must have the same structure.
- Both tables must have the same partition key.

## MOVE PARTITION TO TABLE

```
ALTER TABLE table_source MOVE PARTITION partition_expr TO TABLE table_dest
```

This query moves the data partition from the `table_source` to `table_dest` with deleting the data from `table_source`.

For the query to run successfully, the following conditions must be met:

- Both tables must have the same structure.
- Both tables must have the same partition key.
- Both tables must be the same engine family (replicated or non-replicated).
- Both tables must have the same storage policy.

## CLEAR COLUMN IN PARTITION

```
ALTER TABLE table_name CLEAR COLUMN column_name IN PARTITION partition_expr
```

Resets all values in the specified column in a partition. If the `DEFAULT` clause was determined when creating a table, this query sets the column value to a specified default value.

Example:

```
ALTER TABLE visits CLEAR COLUMN hour in PARTITION 201902
```

## FREEZE PARTITION

```
ALTER TABLE table_name FREEZE [PARTITION partition_expr]
```

This query creates a local backup of a specified partition. If the `PARTITION` clause is omitted, the query creates the backup of all partitions at once.

Note

The entire backup process is performed without stopping the server.

Note that for old-styled tables you can specify the prefix of the partition name (for example, `2019`) - then the query creates the backup for all the corresponding partitions. Read about setting the partition expression in a section [How to specify the partition expression].

At the time of execution, for a data snapshot, the query creates hardlinks to a table data. Hardlinks are placed in the directory `/var/lib/clickhouse/shadow/N/...`, where:

- `/var/lib/clickhouse/` is the working ClickHouse directory specified in the config.
- `N` is the incremental number of the backup.

Note

If you use [a set of disks for data storage in a table] the `shadow/N` directory appears on every disk, storing data parts that matched by the `PARTITION` expression.

The same structure of directories is created inside the backup as inside `/var/lib/clickhouse/`. The query performs `chmod` for all files, forbidding writing into them.

After creating the backup, you can copy the data from `/var/lib/clickhouse/shadow/` to the remote server and then delete it from the local server. Note that the `ALTER t FREEZE PARTITION` query is not replicated. It creates a local backup only on the local server.

The query creates backup almost instantly (but first it waits for the current queries to the corresponding table to finish running).

```
ALTER TABLE t FREEZE PARTITION` copies only the data, not table metadata. To make a backup of table metadata, copy the file `/var/lib/clickhouse/metadata/database/table.sql
```

To restore data from a backup, do the following:

1. Create the table if it does not exist. To view the query, use the .sql file (replace `ATTACH` in it with `CREATE`).
2. Copy the data from the `data/database/table/` directory inside the backup to the `/var/lib/clickhouse/data/database/table/detached/` directory.
3. Run `ALTER TABLE t ATTACH PARTITION` queries to add the data to a table.

Restoring from a backup does not require stopping the server.

For more information about backups and restoring data, see the [Data Backup] section.

## UNFREEZE PARTITION

```
ALTER TABLE table_name UNFREEZE [PARTITION part_expr] WITH NAME backup_name
```

Removes `freezed` partitions with the specified name from the disk. If the `PARTITION` clause is omitted, the query removes the backup of all partitions at once.

## CLEAR INDEX IN PARTITION

```
ALTER TABLE table_name CLEAR INDEX index_name IN PARTITION partition_expr
```

The query works similar to `CLEAR COLUMN`, but it resets an index instead of a column data.

## FETCH PARTITION|PART

```
ALTER TABLE table_name FETCH PARTITION|PART partition_expr FROM path-in-zookeeper
```

Downloads a partition from another server. This query only works for the replicated tables.

The query does the following:

1. Downloads the partition|part from the specified shard. In ‘path-in-zookeeper’ you must specify a path to the shard in ZooKeeper.
2. Then the query puts the downloaded data to the `detached` directory of the `table_name` table. Use the [ATTACH PARTITION|PART](https://clickhouse.tech/docs/en/sql-reference/statements/alter/partition/#alter_attach-partition) query to add the data to the table.

For example:

1. FETCH PARTITION

```
ALTER TABLE users FETCH PARTITION 201902 FROM /clickhouse/tables/01-01/visits;ALTER TABLE users ATTACH PARTITION 201902;
```

1. FETCH PART

```
ALTER TABLE users FETCH PART 201901_2_2_0 FROM /clickhouse/tables/01-01/visits;ALTER TABLE users ATTACH PART 201901_2_2_0;
```

Note that:

- The `ALTER ... FETCH PARTITION|PART` query isn’t replicated. It places the part or partition to the `detached` directory only on the local server.
- The `ALTER TABLE ... ATTACH` query is replicated. It adds the data to all replicas. The data is added to one of the replicas from the `detached` directory, and to the others - from neighboring replicas.

Before downloading, the system checks if the partition exists and the table structure matches. The most appropriate replica is selected automatically from the healthy replicas.

Although the query is called `ALTER TABLE`, it does not change the table structure and does not immediately change the data available in the table.

## MOVE PARTITION|PART

Moves partitions or data parts to another volume or disk for `MergeTree`-engine tables. See [Using Multiple Block Devices for Data Storage]

```
ALTER TABLE table_name MOVE PARTITION|PART partition_expr TO DISK|VOLUME disk_name
```

The `ALTER TABLE t MOVE` query:

- Not replicated, because different replicas can have different storage policies.
- Returns an error if the specified disk or volume is not configured. Query also returns an error if conditions of data moving, that specified in the storage policy, can’t be applied.
- Can return an error in the case, when data to be moved is already moved by a background process, concurrent `ALTER TABLE t MOVE` query or as a result of background data merging. A user shouldn’t perform any additional actions in this case.

Example:

```
ALTER TABLE hits MOVE PART 20190301_14343_16206_438 TO VOLUME slow
ALTER TABLE hits MOVE PARTITION 2019-09-01 TO DISK fast_ssd
```

## UPDATE IN PARTITION

Manipulates data in the specifies partition matching the specified filtering expression. Implemented as a [mutation].

Syntax:

```
ALTER TABLE [db.]table UPDATE column1 = expr1 [, ...] [IN PARTITION partition_id] WHERE filter_expr
```

### Example

```
ALTER TABLE mt UPDATE x = x + 1 IN PARTITION 2 WHERE p = 2;
```

### See Also

- [UPDATE]

## DELETE IN PARTITION

Deletes data in the specifies partition matching the specified filtering expression. Implemented as a [mutation].

Syntax:

```
ALTER TABLE [db.]table DELETE [IN PARTITION partition_id] WHERE filter_expr
```

### Example

```
ALTER TABLE mt DELETE IN PARTITION 2 WHERE p = 2;
```

### See Also

- [DELETE]

## How to Set Partition Expression

You can specify the partition expression in `ALTER ... PARTITION` queries in different ways:

- As a value from the `partition` column of the `system.parts` table. For example, `ALTER TABLE visits DETACH PARTITION 201901`.
- As a tuple of expressions or constants that matches (in types) the table partitioning keys tuple. In the case of a single element partitioning key, the expression should be wrapped in the `tuple (...)` function. For example, `ALTER TABLE visits DETACH PARTITION tuple(toYYYYMM(toDate(2019-01-25)))`.
- Using the partition ID. Partition ID is a string identifier of the partition (human-readable, if possible) that is used as the names of partitions in the file system and in ZooKeeper. The partition ID must be specified in the `PARTITION ID` clause, in a single quotes. For example, `ALTER TABLE visits DETACH PARTITION ID 201901`.
- In the [ALTER ATTACH PART] query, to specify the name of a part, use string literal with a value from the `name` column of the [system.detached_parts]table. For example, `ALTER TABLE visits ATTACH PART 201901_1_1_0`.

Usage of quotes when specifying the partition depends on the type of partition expression. For example, for the `String` type, you have to specify its name in quotes (``). For the `Date` and `Int*` types no quotes are needed.

All the rules above are also true for the [OPTIMIZE] query. If you need to specify the only partition when optimizing a non-partitioned table, set the expression `PARTITION tuple()`. For example:

```
OPTIMIZE TABLE table_not_partitioned PARTITION tuple() FINAL;
```

`IN PARTITION` specifies the partition to which the [UPDATE] or [DELETE]expressions are applied as a result of the `ALTER TABLE` query. New parts are created only from the specified partition. In this way, `IN PARTITION` helps to reduce the load when the table is divided into many partitions, and you only need to update the data point-by-point.

The examples of `ALTER ... PARTITION` queries are demonstrated in the tests [`00502_custom_partitioning_local`] and [`00502_custom_partitioning_replicated_zookeeper`].

# ALTER TABLE … DELETE Statement

```
ALTER TABLE [db.]table [ON CLUSTER cluster] DELETE WHERE filter_expr
```

Deletes data matching the specified filtering expression. Implemented as a [mutation]

Note

The `ALTER TABLE` prefix makes this syntax different from most other systems supporting SQL. It is intended to signify that unlike similar queries in OLTP databases this is a heavy operation not designed for frequent use.

The `filter_expr` must be of type `UInt8`. The query deletes rows in the table for which this expression takes a non-zero value.

One query can contain several commands separated by commas.

The synchronicity of the query processing is defined by the [mutations_sync] setting. By default, it is asynchronous.

**See also**

- [Mutations]

- [Synchronicity of ALTER Queries]

- [mutations_sync] setting


  ```
ALTER TABLE [db.]table UPDATE column1 = expr1 [, ...] WHERE filter_expr
  ```

  Manipulates data matching the specified filtering expression. Implemented as a [mutation].

  Note

  The `ALTER TABLE` prefix makes this syntax different from most other systems supporting SQL. It is intended to signify that unlike similar queries in OLTP databases this is a heavy operation not designed for frequent use.

  The `filter_expr` must be of type `UInt8`. This query updates values of specified columns to the values of corresponding expressions in rows for which the `filter_expr` takes a non-zero value. Values are casted to the column type using the `CAST` operator. Updating columns that are used in the calculation of the primary or the partition key is not supported.

  One query can contain several commands separated by commas.

  The synchronicity of the query processing is defined by the [mutations_sync] setting. By default, it is asynchronous.

  **See also**

  - [Mutations]

  - [Synchronicity of ALTER Queries]

  - [mutations_sync] setting

    ```
    ALTER TABLE [db].name [ON CLUSTER cluster] MODIFY ORDER BY new_expression
    ```

    The command changes the [sorting key]of the table to `new_expression` (an expression or a tuple of expressions). Primary key remains the same.

    The command is lightweight in a sense that it only changes metadata. To keep the property that data part rows are ordered by the sorting key expression you cannot add expressions containing existing columns to the sorting key (only columns added by the `ADD COLUMN` command in the same `ALTER` query).

    # Manipulating Sampling-Key Expressions

    Syntax:

    ```
    ALTER TABLE [db].name [ON CLUSTER cluster] MODIFY SAMPLE BY new_expression
    ```

    The command changes the [sampling key]of the table to `new_expression` (an expression or a tuple of expressions).

    The command is lightweight in the sense that it only changes metadata. The primary key must contain the new sample key.

    # Manipulating Data Skipping Indices

    The following operations are available:

    - `ALTER TABLE [db].name ADD INDEX name expression TYPE type GRANULARITY value AFTER name [AFTER name2]` - Adds index description to tables metadata.
    - `ALTER TABLE [db].name DROP INDEX name` - Removes index description from tables metadata and deletes index files from disk.
    - `ALTER TABLE [db.]table MATERIALIZE INDEX name IN PARTITION partition_name` - The query rebuilds the secondary index `name` in the partition `partition_name`. Implemented as a [mutation]

    The first two commands are lightweight in a sense that they only change metadata or remove files.

    Also, they are replicated, syncing indices metadata via ZooKeeper.' where id = 10;
update biz_data_query_model_help_content set content = '#### IP函数

#### IPv4NumToString(num)

接受一个UInt32（大端）表示的IPv4的地址，返回相应IPv4的字符串表现形式，格式为A.B.C.D（以点分割的十进制数字）。

#### IPv4StringToNum(s)

与IPv4NumToString函数相反。如果IPv4地址格式无效，则返回0。

#### IPv4NumToStringClassC(num)

与IPv4NumToString类似，但使用xxx替换最后一个字节。

示例:

```
SELECT
    IPv4NumToStringClassC(ClientIP) AS k,
    count() AS c
FROM test.hits
GROUP BY k
ORDER BY c DESC
LIMIT 10
┌─k──────────────┬─────c─┐
│ 83.149.9.xxx   │ 26238 │
│ 217.118.81.xxx │ 26074 │
│ 213.87.129.xxx │ 25481 │
│ 83.149.8.xxx   │ 24984 │
│ 217.118.83.xxx │ 22797 │
│ 78.25.120.xxx  │ 22354 │
│ 213.87.131.xxx │ 21285 │
│ 78.25.121.xxx  │ 20887 │
│ 188.162.65.xxx │ 19694 │
│ 83.149.48.xxx  │ 17406 │
└────────────────┴───────┘
```

由于使用’xxx’是不规范的，因此将来可能会更改。我们建议您不要依赖此格式。

#### IPv6NumToString(x)

接受FixedString(16)类型的二进制格式的IPv6地址。以文本格式返回此地址的字符串。
IPv6映射的IPv4地址以::ffff:111.222.33。例如：

```
SELECT IPv6NumToString(toFixedString(unhex(''2A0206B8000000000000000000000011''), 16)) AS addr
┌─addr─────────┐
│ 2a02:6b8::11 │
└──────────────┘
SELECT
    IPv6NumToString(ClientIP6 AS k),
    count() AS c
FROM hits_all
WHERE EventDate = today() AND substring(ClientIP6, 1, 12) != unhex(''00000000000000000000FFFF'')
GROUP BY k
ORDER BY c DESC
LIMIT 10
┌─IPv6NumToString(ClientIP6)──────────────┬─────c─┐
│ 2a02:2168:aaa:bbbb::2                   │ 24695 │
│ 2a02:2698:abcd:abcd:abcd:abcd:8888:5555 │ 22408 │
│ 2a02:6b8:0:fff::ff                      │ 16389 │
│ 2a01:4f8:111:6666::2                    │ 16016 │
│ 2a02:2168:888:222::1                    │ 15896 │
│ 2a01:7e00::ffff:ffff:ffff:222           │ 14774 │
│ 2a02:8109:eee:ee:eeee:eeee:eeee:eeee    │ 14443 │
│ 2a02:810b:8888:888:8888:8888:8888:8888  │ 14345 │
│ 2a02:6b8:0:444:4444:4444:4444:4444      │ 14279 │
│ 2a01:7e00::ffff:ffff:ffff:ffff          │ 13880 │
└─────────────────────────────────────────┴───────┘
SELECT
    IPv6NumToString(ClientIP6 AS k),
    count() AS c
FROM hits_all
WHERE EventDate = today()
GROUP BY k
ORDER BY c DESC
LIMIT 10
┌─IPv6NumToString(ClientIP6)─┬──────c─┐
│ ::ffff:94.26.111.111       │ 747440 │
│ ::ffff:37.143.222.4        │ 529483 │
│ ::ffff:5.166.111.99        │ 317707 │
│ ::ffff:46.38.11.77         │ 263086 │
│ ::ffff:79.105.111.111      │ 186611 │
│ ::ffff:93.92.111.88        │ 176773 │
│ ::ffff:84.53.111.33        │ 158709 │
│ ::ffff:217.118.11.22       │ 154004 │
│ ::ffff:217.118.11.33       │ 148449 │
│ ::ffff:217.118.11.44       │ 148243 │
└────────────────────────────┴────────┘
```

#### IPv6StringToNum(s)

与IPv6NumToString的相反。如果IPv6地址格式无效，则返回空字节字符串。
十六进制可以是大写的或小写的。

#### IPv4ToIPv6(x)

接受一个UInt32类型的IPv4地址，返回FixedString(16)类型的IPv6地址。例如：

```
SELECT IPv6NumToString(IPv4ToIPv6(IPv4StringToNum(''192.168.0.1''))) AS addr
┌─addr───────────────┐
│ ::ffff:192.168.0.1 │
└────────────────────┘
```

#### cutIPv6(x,bitsToCutForIPv6,bitsToCutForIPv4)

接受一个FixedString(16)类型的IPv6地址，返回一个String，这个String中包含了删除指定位之后的地址的文本格式。例如：

```
WITH
    IPv6StringToNum(''2001:0DB8:AC10:FE01:FEED:BABE:CAFE:F00D'') AS ipv6,
    IPv4ToIPv6(IPv4StringToNum(''192.168.0.1'')) AS ipv4
SELECT
    cutIPv6(ipv6, 2, 0),
    cutIPv6(ipv4, 0, 2)
┌─cutIPv6(ipv6, 2, 0)─────────────────┬─cutIPv6(ipv4, 0, 2)─┐
│ 2001:db8:ac10:fe01:feed:babe:cafe:0 │ ::ffff:192.168.0.0  │
└─────────────────────────────────────┴─────────────────────┘
```

#### IPv4CIDRToRange(ipv4, Cidr),

接受一个IPv4地址以及一个UInt8类型的CIDR。返回包含子网最低范围以及最高范围的元组。

```
SELECT IPv4CIDRToRange(toIPv4(''192.168.5.2''), 16)
┌─IPv4CIDRToRange(toIPv4(''192.168.5.2''), 16)─┐
│ (''192.168.0.0'',''192.168.255.255'')          │
└────────────────────────────────────────────┘
```

#### IPv6CIDRToRange(ipv6, Cidr),

接受一个IPv6地址以及一个UInt8类型的CIDR。返回包含子网最低范围以及最高范围的元组。

```
SELECT IPv6CIDRToRange(toIPv6(''2001:0db8:0000:85a3:0000:0000:ac1f:8001''), 32);
┌─IPv6CIDRToRange(toIPv6(''2001:0db8:0000:85a3:0000:0000:ac1f:8001''), 32)─┐
│ (''2001:db8::'',''2001:db8:ffff:ffff:ffff:ffff:ffff:ffff'')                │
└────────────────────────────────────────────────────────────────────────┘
```

#### toIPv4(字符串)

`IPv4StringToNum()`的别名，它采用字符串形式的IPv4地址并返回IPv4`返回的值。

```
WITH
    ''171.225.130.45'' as IPv4_string
SELECT
    toTypeName(IPv4StringToNum(IPv4_string)),
    toTypeName(toIPv4(IPv4_string))
┌─toTypeName(IPv4StringToNum(IPv4_string))─┬─toTypeName(toIPv4(IPv4_string))─┐
│ UInt32                                   │ IPv4                            │
└──────────────────────────────────────────┴─────────────────────────────────┘
WITH
    ''171.225.130.45'' as IPv4_string
SELECT
    hex(IPv4StringToNum(IPv4_string)),
    hex(toIPv4(IPv4_string))
┌─hex(IPv4StringToNum(IPv4_string))─┬─hex(toIPv4(IPv4_string))─┐
│ ABE1822D                          │ ABE1822D                 │
└───────────────────────────────────┴──────────────────────────┘
```

#### toIPv6(字符串)

`IPv6StringToNum()`的别名，它采用字符串形式的IPv6地址并返回IPv6`返回的值。

```
WITH
    ''2001:438:ffff::407d:1bc1'' as IPv6_string
SELECT
    toTypeName(IPv6StringToNum(IPv6_string)),
    toTypeName(toIPv6(IPv6_string))
┌─toTypeName(IPv6StringToNum(IPv6_string))─┬─toTypeName(toIPv6(IPv6_string))─┐
│ FixedString(16)                          │ IPv6                            │
└──────────────────────────────────────────┴─────────────────────────────────┘
WITH
    ''2001:438:ffff::407d:1bc1'' as IPv6_string
SELECT
    hex(IPv6StringToNum(IPv6_string)),
    hex(toIPv6(IPv6_string))
┌─hex(IPv6StringToNum(IPv6_string))─┬─hex(toIPv6(IPv6_string))─────────┐
│ 20010438FFFF000000000000407D1BC1  │ 20010438FFFF000000000000407D1BC1 │
└───────────────────────────────────┴──────────────────────────────────┘
```

' where id = 27;