update biz_data_query_model_help_content set content = '#### 函数

ClickHouse中至少存在两种类型的函数 - 常规函数（它们称之为«函数»）和聚合函数。 常规函数的工作就像分别为每一行执行一次函数计算一样（对于每一行，函数的结果不依赖于其他行）。 聚合函数则从各行累积一组值（即函数的结果以来整个结果集）。

在本节中，我们将讨论常规函数。 有关聚合函数，请参阅«聚合函数»一节。

* \- ’arrayJoin’函数与表函数均属于第三种类型的函数。 *

#### 强类型

与标准SQL相比，ClickHouse具有强类型。 换句话说，它不会在类型之间进行隐式转换。 每个函数适用于特定的一组类型。 这意味着有时您需要使用类型转换函数。

#### 常见的子表达式消除

查询中具有相同AST（相同语句或语法分析结果相同）的所有表达式都被视为具有相同的值。 这样的表达式被连接并执行一次。 通过这种方式也可以消除相同的子查询。

#### 结果类型

所有函数都只能够返回一个返回值。 结果类型通常由参数的类型决定。 但tupleElement函数（a.N运算符）和toFixedString函数是例外的。

#### 常量

为了简单起见，某些函数的某些参数只能是常量。 例如，LIKE运算符的右参数必须是常量。
几乎所有函数都为常量参数返回常量。 除了用于生成随机数的函数。
’now’函数为在不同时间运行的查询返回不同的值，但结果被视为常量，因为常量在单个查询中很重要。
常量表达式也被视为常量（例如，LIKE运算符的右半部分可以由多个常量构造）。

对于常量和非常量参数，可以以不同方式实现函数（执行不同的代码）。 但是，对于包含相同数据的常量和非常量参数它们的结果应该是一致的。

#### NULL值处理

函数具有以下行为：

- 如果函数的参数至少一个是«NULL»，则函数结果也是«NULL»。
- 在每个函数的描述中单独指定的特殊行为。在ClickHouse源代码中，这些函数具有«UseDefaultImplementationForNulls = false»。

#### 不可变性

函数不能更改其参数的值 - 任何更改都将作为结果返回。因此，计算单独函数的结果不依赖于在查询中写入函数的顺序。

#### 错误处理

如果数据无效，某些函数可能会抛出异常。在这种情况下，将取消查询并将错误信息返回给客户端。对于分布式处理，当其中一个服务器发生异常时，其他服务器也会尝试中止查询。

#### 表达式参数的计算

在几乎所有编程语言中，某些函数可能无法预先计算其中一个参数。这通常是运算符`&&`，`||`和`? :`。
但是在ClickHouse中，函数（运算符）的参数总是被预先计算。这是因为一次评估列的整个部分，而不是分别计算每一行。

#### 执行分布式查询处理的功能

对于分布式查询处理，在远程服务器上执行尽可能多的查询处理阶段，并且在请求者服务器上执行其余阶段（合并中间结果和之后的所有内容）。

这意味着可以在不同的服务器上执行功能。
例如，在查询`SELECT f（sum（g（x）））FROM distributed_table GROUP BY h（y）中，`

- 如果`distributed_table`至少有两个分片，则在远程服务器上执行函数’g’和’h’，并在请求服务器上执行函数’f’。
- 如果`distributed_table`只有一个分片，则在该分片的服务器上执行所有’f’，’g’和’h’功能。

函数的结果通常不依赖于它在哪个服务器上执行。但是，有时这很重要。
例如，使用字典的函数时将使用运行它们的服务器上存在的字典。
另一个例子是`hostName`函数，它返回运行它的服务器的名称，以便在`SELECT`查询中对服务器进行`GROUP BY`。

如果查询中的函数在请求服务器上执行，但您需要在远程服务器上执行它，则可以将其包装在«any»聚合函数中，或将其添加到«GROUP BY»中。' where id= 18;
update biz_data_query_model_help_content set content = '#### 类型转换函数

#### 数值类型转换常见的问题

当你把一个值从一个类型转换为另外一个类型的时候，你需要注意的是这是一个不安全的操作，可能导致数据的丢失。数据丢失一般发生在你将一个大的数据类型转换为小的数据类型的时候，或者你把两个不同的数据类型相互转换的时候。

ClickHouse和C++有相同的类型转换行为。

#### toInt(8|16|32|64)

转换一个输入值为Int类型。这个函数包括：

- `toInt8(expr)` — 结果为`Int8`数据类型。
- `toInt16(expr)` — 结果为`Int16`数据类型。
- `toInt32(expr)` — 结果为`Int32`数据类型。
- `toInt64(expr)` — 结果为`Int64`数据类型。

**参数**

- `expr` — 表达式返回一个数字或者代表数值类型的字符串。不支持二进制、八进制、十六进制的数字形式，有效数字之前的0也会被忽略。

**返回值**

整形在`Int8`, `Int16`, `Int32`，或者 `Int64` 的数据类型。

函数使用rounding towards zero原则，这意味着会截断丢弃小数部分的数值。

NaN and Inf转换是不确定的。具体使用的时候，请参考数值类型转换常见的问题。

**例子**

```
SELECT toInt64(nan), toInt32(32), toInt16(''16''), toInt8(8.8)
┌─────────toInt64(nan)─┬─toInt32(32)─┬─toInt16(''16'')─┬─toInt8(8.8)─┐
│ -9223372036854775808 │          32 │            16 │           8 │
└──────────────────────┴─────────────┴───────────────┴─────────────┘
```

#### toInt(8|16|32|64)OrZero

这个函数需要一个字符类型的入参，然后尝试把它转为`Int (8 | 16 | 32 | 64)`，如果转换失败直接返回0。

**例子**

```
select toInt64OrZero(''123123''), toInt8OrZero(''123qwe123'')
┌─toInt64OrZero(''123123'')─┬─toInt8OrZero(''123qwe123'')─┐
│                  123123 │                         0 │
└─────────────────────────┴───────────────────────────┘
```

#### toInt(8|16|32|64)OrNull

这个函数需要一个字符类型的入参，然后尝试把它转为`Int (8 | 16 | 32 | 64)`，如果转换失败直接返回`NULL`。

**例子**

```
select toInt64OrNull(''123123''), toInt8OrNull(''123qwe123'')
┌─toInt64OrNull(''123123'')─┬─toInt8OrNull(''123qwe123'')─┐
│                  123123 │                      ᴺᵁᴸᴸ │
└─────────────────────────┴───────────────────────────┘
```

#### toUInt(8|16|32|64)

转换一个输入值到UInt类型。 这个函数包括：

- `toUInt8(expr)` — 结果为`UInt8`数据类型。
- `toUInt16(expr)` — 结果为`UInt16`数据类型。
- `toUInt32(expr)` — 结果为`UInt32`数据类型。
- `toUInt64(expr)` — 结果为`UInt64`数据类型。

**参数**

- `expr` — 表达式返回一个数字或者代表数值类型的字符串。不支持二进制、八进制、十六进制的数字形式，有效数字之前的0也会被忽略。

**返回值**

整形在`UInt8`, `UInt16`, `UInt32`，或者 `UInt64` 的数据类型。

函数使用rounding towards zero原则，这意味着会截断丢弃小数部分的数值。

对于负数和NaN and Inf来说转换的结果是不确定的。如果你传入一个负数，比如：-32，Clickhouse会抛出异常。具体使用的时候，请参考数值类型转换常见的问题。

**例子**

```
SELECT toUInt64(nan), toUInt32(-32), toUInt16(''16''), toUInt8(8.8)
┌───────toUInt64(nan)─┬─toUInt32(-32)─┬─toUInt16(''16'')─┬─toUInt8(8.8)─┐
│ 9223372036854775808 │    4294967264 │             16 │            8 │
└─────────────────────┴───────────────┴────────────────┴──────────────┘
```

#### toUInt(8|16|32|64)OrZero

#### toUInt(8|16|32|64)OrNull

#### toFloat(32|64)

#### toFloat(32|64)OrZero

#### toFloat(32|64)OrNull

#### toDate

#### toDateOrZero

#### toDateOrNull

#### toDateTime

#### toDateTimeOrZero

#### toDateTimeOrNull

#### toDecimal(32|64|128)

转换 `value` 到Decimal类型的值，其中精度为`S`。`value`可以是一个数字或者一个字符串。`S` 指定小数位的精度。

- `toDecimal32(value, S)`
- `toDecimal64(value, S)`
- `toDecimal128(value, S)`

#### toDecimal(32|64|128)OrNull

转换一个输入的字符到Nullable(Decimal(P,S))类型的数据。这个函数包括：

- `toDecimal32OrNull(expr, S)` — 结果为`Nullable(Decimal32(S))`数据类型。
- `toDecimal64OrNull(expr, S)` — 结果为`Nullable(Decimal64(S))`数据类型。
- `toDecimal128OrNull(expr, S)` — 结果为`Nullable(Decimal128(S))`数据类型。

如果在解析输入值发生错误的时候你希望得到一个`NULL`值而不是抛出异常，你可以使用该函数。

**参数**

- `expr` — 表达式类型的数据。 ClickHouse倾向于文本类型的表示带小数类型的数值，比如`''1.111''`。
- `S` — 小数位的精度。

**返回值**

`Nullable(Decimal(P,S))`类型的数据，包括：

- 如果有的话，小数位`S`。
- 如果解析错误或者输入的数字的小数位多于`S`,那结果为`NULL`。

**例子**

```
SELECT toDecimal32OrNull(toString(-1.111), 5) AS val, toTypeName(val)
┌──────val─┬─toTypeName(toDecimal32OrNull(toString(-1.111), 5))─┐
│ -1.11100 │ Nullable(Decimal(9, 5))                            │
└──────────┴────────────────────────────────────────────────────┘
SELECT toDecimal32OrNull(toString(-1.111), 2) AS val, toTypeName(val)
┌──val─┬─toTypeName(toDecimal32OrNull(toString(-1.111), 2))─┐
│ ᴺᵁᴸᴸ │ Nullable(Decimal(9, 2))                            │
└──────┴────────────────────────────────────────────────────┘
```

#### toDecimal(32|64|128)OrZero

转换输入值为Decimal(P,S)类型数据。这个函数包括：

- `toDecimal32OrZero( expr, S)` — 结果为`Decimal32(S)` 数据类型。
- `toDecimal64OrZero( expr, S)` — 结果为`Decimal64(S)` 数据类型。
- `toDecimal128OrZero( expr, S)` — 结果为`Decimal128(S)` 数据类型。

当解析错误的时候，你不需要抛出异常而希望得到`0`值，你可以使用该函数。

**参数**

- `expr` — 表达式类型的数据。 ClickHouse倾向于文本类型的表示带小数类型的数值，比如`''1.111''`。
- `S` — 小数位的精度。

**返回值**

A value in the `Nullable(Decimal(P,S))` data type. The value contains:

- 如果有的话，小数位`S`。
- 如果解析错误或者输入的数字的小数位多于`S`,那结果为小数位精度为`S`的`0`。
  **例子**

```
SELECT toDecimal32OrZero(toString(-1.111), 5) AS val, toTypeName(val)
┌──────val─┬─toTypeName(toDecimal32OrZero(toString(-1.111), 5))─┐
│ -1.11100 │ Decimal(9, 5)                                      │
└──────────┴────────────────────────────────────────────────────┘
SELECT toDecimal32OrZero(toString(-1.111), 2) AS val, toTypeName(val)
┌──val─┬─toTypeName(toDecimal32OrZero(toString(-1.111), 2))─┐
│ 0.00 │ Decimal(9, 2)                                      │
└──────┴────────────────────────────────────────────────────┘
```

#### toString

这些函数用于在数字、字符串（不包含FixedString）、Date以及DateTime之间互相转换。
所有的函数都接受一个参数。

当将其他类型转换到字符串或从字符串转换到其他类型时，使用与TabSeparated格式相同的规则对字符串的值进行格式化或解析。如果无法解析字符串则抛出异常并取消查询。

当将Date转换为数字或反之，Date对应Unix时间戳的天数。
将DataTime转换为数字或反之，DateTime对应Unix时间戳的秒数。

toDate/toDateTime函数的日期和日期时间格式定义如下：

```
YYYY-MM-DD
YYYY-MM-DD hh:mm:ss
```

例外的是，如果将UInt32、Int32、UInt64或Int64类型的数值转换为Date类型，并且其对应的值大于等于65536，则该数值将被解析成unix时间戳（而不是对应的天数）。这意味着允许写入’toDate(unix_timestamp)‘这种常见情况，否则这将是错误的，并且需要便携更加繁琐的’toDate(toDateTime(unix_timestamp))’。

Date与DateTime之间的转换以更为自然的方式进行：通过添加空的time或删除time。

数值类型之间的转换与C++中不同数字类型之间的赋值相同的规则。

此外，DateTime参数的toString函数可以在第二个参数中包含时区名称。 例如：`Asia/Yekaterinburg`在这种情况下，时间根据指定的时区进行格式化。

```
SELECT
    now() AS now_local,
    toString(now(), ''Asia/Yekaterinburg'') AS now_yekat
┌───────────now_local─┬─now_yekat───────────┐
│ 2016-06-15 00:11:21 │ 2016-06-15 02:11:21 │
└─────────────────────┴─────────────────────┘
```

另请参阅`toUnixTimestamp`函数。

#### toFixedString(s,N)

将String类型的参数转换为FixedString(N)类型的值（具有固定长度N的字符串）。N必须是一个常量。
如果字符串的字节数少于N，则向右填充空字节。如果字符串的字节数多于N，则抛出异常。

#### toStringCutToZero(s)

接受String或FixedString参数。返回String，其内容在找到的第一个零字节处被截断。

示例:

```
SELECT toFixedString(''foo'', 8) AS s, toStringCutToZero(s) AS s_cut
┌─s──────────────────┬s_cut─┐
│ foo\\0\\0\\0\\0\\0      │ foo  │
└────────────────────┴──────┘
SELECT toFixedString(''foo\0bar'', 8) AS s, toStringCutToZero(s) AS s_cut
┌─s────────────┬s_cut──┐
│ foo\\0bar\\0   │ foo   │
└──────────────┴───────┘
```

#### reinterpretAsUInt(8|16|32|64)

#### reinterpretAsInt(8|16|32|64)

#### reinterpretAsFloat(32|64)

#### reinterpretAsDate

#### reinterpretAsDateTime

这些函数接受一个字符串，并将放在字符串开头的字节解释为主机顺序中的数字（little endian）。如果字符串不够长，则函数就像使用必要数量的空字节填充字符串一样。如果字符串比需要的长，则忽略额外的字节。Date被解释为Unix时间戳的天数，DateTime被解释为Unix时间戳。

#### reinterpretAsString

此函数接受数字、Date或DateTime，并返回一个字符串，其中包含表示主机顺序（小端）的相应值的字节。从末尾删除空字节。例如，UInt32类型值255是一个字节长的字符串。

#### reinterpretAsFixedString

此函数接受数字、Date或DateTime，并返回包含表示主机顺序（小端）的相应值的字节的FixedString。从末尾删除空字节。例如，UInt32类型值255是一个长度为一个字节的FixedString。

#### CAST(x, T)

将’x’转换为’t’数据类型。还支持语法CAST（x AS t）

示例:

```
SELECT
    ''2016-06-15 23:00:00'' AS timestamp,
    CAST(timestamp AS DateTime) AS datetime,
    CAST(timestamp AS Date) AS date,
    CAST(timestamp, ''String'') AS string,
    CAST(timestamp, ''FixedString(22)'') AS fixed_string
┌─timestamp───────────┬────────────datetime─┬───────date─┬─string──────────────┬─fixed_string──────────────┐
│ 2016-06-15 23:00:00 │ 2016-06-15 23:00:00 │ 2016-06-15 │ 2016-06-15 23:00:00 │ 2016-06-15 23:00:00\0\0\0 │
└─────────────────────┴─────────────────────┴────────────┴─────────────────────┴───────────────────────────┘
```

将参数转换为FixedString(N)，仅适用于String或FixedString(N)类型的参数。

支持将数据转换为可为空。例如：

```
SELECT toTypeName(x) FROM t_null

┌─toTypeName(x)─┐
│ Int8          │
│ Int8          │
└───────────────┘

SELECT toTypeName(CAST(x, ''Nullable(UInt16)'')) FROM t_null

┌─toTypeName(CAST(x, ''Nullable(UInt16)''))─┐
│ Nullable(UInt16)                        │
│ Nullable(UInt16)                        │
└─────────────────────────────────────────┘
```

#### toInterval(Year|Quarter|Month|Week|Day|Hour|Minute|Second)

把一个数值类型的值转换为Interval类型的数据。

**语法**

```
toIntervalSecond(number)
toIntervalMinute(number)
toIntervalHour(number)
toIntervalDay(number)
toIntervalWeek(number)
toIntervalMonth(number)
toIntervalQuarter(number)
toIntervalYear(number)
```

**参数**

- `number` — 正整数，持续的时间。

**返回值**

- 时间的`Interval`值。

**例子**

```
WITH
    toDate(''2019-01-01'') AS date,
    INTERVAL 1 WEEK AS interval_week,
    toIntervalWeek(1) AS interval_to_week
SELECT
    date + interval_week,
    date + interval_to_week
┌─plus(date, interval_week)─┬─plus(date, interval_to_week)─┐
│                2019-01-08 │                   2019-01-08 │
└───────────────────────────┴──────────────────────────────┘
```

#### parseDateTimeBestEffort

把String数据类型的时间日期转换为DateTime数据类型。

该函数可以解析ISO 8601，RFC 1123 - 5.2.14 RFC-822 Date and Time Specification或者ClickHouse的一些别的时间日期格式。

**语法**

```
parseDateTimeBestEffort(time_string [, time_zone]);
```

**参数**

- `time_string` — 字符类型的时间和日期。
- `time_zone` — 字符类型的时区。

**非标准格式的支持**

- 9位或者10位的数字时间，unix timestamp.
- 时间和日期组成的字符串： `YYYYMMDDhhmmss`, `DD/MM/YYYY hh:mm:ss`, `DD-MM-YY hh:mm`, `YYYY-MM-DD hh:mm:ss`等。
- 只有日期的字符串： `YYYY`, `YYYYMM`, `YYYY*MM`, `DD/MM/YYYY`, `DD-MM-YY` 等。
- 只有天和时间： `DD`, `DD hh`, `DD hh:mm`。这种情况下 `YYYY-MM` 默认为 `2000-01`。
- 包含时间日期以及时区信息： `YYYY-MM-DD hh:mm:ss ±h:mm`等。例如： `2020-12-12 17:36:00 -5:00`。

对于所有的格式来说，这个函数通过全称或者第一个三个字符的月份名称来解析月份，比如：`24/DEC/18`, `24-Dec-18`, `01-September-2018`。

**返回值**

- `DateTime`类型数据。

**例子**

查询:

```
SELECT parseDateTimeBestEffort(''12/12/2020 12:12:57'')
AS parseDateTimeBestEffort;
```

结果:

```
┌─parseDateTimeBestEffort─┐
│     2020-12-12 12:12:57 │
└─────────────────────────┘
```

查询:

```
SELECT parseDateTimeBestEffort(''Sat, 18 Aug 2018 07:22:16 GMT'', ''Europe/Moscow'')
AS parseDateTimeBestEffort
```

结果:

```
┌─parseDateTimeBestEffort─┐
│     2018-08-18 10:22:16 │
└─────────────────────────┘
```

查询:

```
SELECT parseDateTimeBestEffort(''1284101485'')
AS parseDateTimeBestEffort
```

结果:

```
┌─parseDateTimeBestEffort─┐
│     2015-07-07 12:04:41 │
└─────────────────────────┘
```

查询:

```
SELECT parseDateTimeBestEffort(''2018-12-12 10:12:12'')
AS parseDateTimeBestEffort
```

结果:

```
┌─parseDateTimeBestEffort─┐
│     2018-12-12 10:12:12 │
└─────────────────────────┘
```

查询:

```
SELECT parseDateTimeBestEffort(''10 20:19'')
```

结果:

```
┌─parseDateTimeBestEffort(''10 20:19'')─┐
│                 2000-01-10 20:19:00 │
└─────────────────────────────────────┘
```

**除此之外**

- ISO 8601 announcement by @xkcd
- RFC 1123
- toDate
- toDateTime

#### parseDateTimeBestEffortOrNull

这个函数和parseDateTimeBestEffort基本一致，除了无法解析返回结果为`NULL`。

#### parseDateTimeBestEffortOrZero

这个函数和parseDateTimeBestEffort基本一致，除了无法解析返回结果为`0`。

#### toLowCardinality

把输入值转换为LowCardianlity的相同类型的数据。

如果要把`LowCardinality`类型的数据转换为其他类型，使用CAST函数。比如：`CAST(x as String)`。

**语法**

```
toLowCardinality(expr)
```

**参数**

- `expr` — 表达式的一种。

**返回值**

- `expr`的结果。

类型： `LowCardinality(expr_result_type)`

**例子**

查询:

```
SELECT toLowCardinality(''1'')
```

结果:

```
┌─toLowCardinality(''1'')─┐
│ 1                     │
└───────────────────────┘
```

#### toUnixTimestamp64Milli

#### toUnixTimestamp64Micro

#### toUnixTimestamp64Nano

把一个`DateTime64`类型的数据转换为`Int64`类型的数据，结果包含固定亚秒的精度。输入的值是变大还是变低依赖于输入的精度。需要注意的是输出的值是一个UTC的时间戳, 不是同一个时区的`DateTime64`值。

**语法**

```
toUnixTimestamp64Milli(value)
```

**参数**

- `value` — 任何精度的DateTime64类型的数据。

**返回值**

- `value` `Int64`类型数据。

**例子**

查询:

```
WITH toDateTime64(''2019-09-16 19:20:12.345678910'', 6) AS dt64
SELECT toUnixTimestamp64Milli(dt64)
```

结果:

```
┌─toUnixTimestamp64Milli(dt64)─┐
│                1568650812345 │
└──────────────────────────────┘
WITH toDateTime64(''2019-09-16 19:20:12.345678910'', 6) AS dt64
SELECT toUnixTimestamp64Nano(dt64)
```

结果:

```
┌─toUnixTimestamp64Nano(dt64)─┐
│         1568650812345678000 │
└─────────────────────────────┘
```

#### fromUnixTimestamp64Milli

#### fromUnixTimestamp64Micro

#### fromUnixTimestamp64Nano

把`Int64`类型的数据转换为`DateTime64`类型的数据，结果包含固定的亚秒精度和可选的时区。 输入的值是变大还是变低依赖于输入的精度。需要注意的是输入的值是一个UTC的时间戳, 不是一个包含时区的时间戳。

**语法**

```
fromUnixTimestamp64Milli(value [, ti])
```

**参数**

- `value` — `Int64`类型的数据，可以是任意精度。
- `timezone` — `String`类型的时区

**返回值**

- `value` DateTime64`类型的数据。

**例子**

```
WITH CAST(1234567891011, ''Int64'') AS i64
SELECT fromUnixTimestamp64Milli(i64, ''UTC'')
┌─fromUnixTimestamp64Milli(i64, ''UTC'')─┐
│              2009-02-13 23:31:31.011 │
└──────────────────────────────────────┘
```
' where id= 22;
update biz_data_query_model_help_content set content = '#### 参数聚合函数

一些聚合函数不仅可以接受参数列（用于压缩），也可以接收常量的初始化参数。这种语法是接受两个括号的参数，第一个数初始化参数，第二个是入参。

#### histogram

计算自适应直方图。 它不能保证精确的结果。

```
histogram(number_of_bins)(values)
```

该函数使用 流式并行决策树算法. 当新数据输入函数时，hist图分区的边界将被调整。 在通常情况下，箱的宽度不相等。

**参数**

`number_of_bins` — 直方图bin个数，这个函数会自动计算bin的数量，而且会尽量使用指定值，如果无法做到，那就使用更小的bin个数。

`values` — 表达式 输入值。

**返回值**

- Array的Tuples如下：

  ```
  ​```
  [(lower_1, upper_1, height_1), ... (lower_N, upper_N, height_N)]
  ​```

  - `lower` — bin的下边界。
  - `upper` — bin的上边界。
  - `height` — bin的计算权重。
  ```

**示例**

```
SELECT histogram(5)(number + 1)
FROM (
    SELECT *
    FROM system.numbers
    LIMIT 20
)
┌─histogram(5)(plus(number, 1))───────────────────────────────────────────┐
│ [(1,4.5,4),(4.5,8.5,4),(8.5,12.75,4.125),(12.75,17,4.625),(17,20,3.25)] │
└─────────────────────────────────────────────────────────────────────────┘
```

您可以使用 bar 功能，例如:

```
WITH histogram(5)(rand() % 100) AS hist
SELECT
    arrayJoin(hist).3 AS height,
    bar(height, 0, 6, 5) AS bar
FROM
(
    SELECT *
    FROM system.numbers
    LIMIT 20
)
┌─height─┬─bar───┐
│  2.125 │ █▋    │
│   3.25 │ ██▌   │
│  5.625 │ ████▏ │
│  5.625 │ ████▏ │
│  3.375 │ ██▌   │
└────────┴───────┘
```

在这种情况下，您应该记住您不知道直方图bin边界。

#### sequenceMatch(pattern)(timestamp, cond1, cond2, …)

检查序列是否包含与模式匹配的事件链。

```
sequenceMatch(pattern)(timestamp, cond1, cond2, ...)
```

警告

在同一秒钟发生的事件可能以未定义的顺序排列在序列中，影响结果。

**参数**

- `pattern` — 模式字符串。 参考 模式语法.
- `timestamp` — 包含时间的列。典型的时间类型是： `Date` 和 `DateTime`。您还可以使用任何支持的 UInt 数据类型。
- `cond1`, `cond2` — 事件链的约束条件。 数据类型是： `UInt8`。 最多可以传递32个条件参数。 该函数只考虑这些条件中描述的事件。 如果序列包含未在条件中描述的数据，则函数将跳过这些数据。

**返回值**

- 1，如果模式匹配。
- 0，如果模式不匹配。

类型: `UInt8`.


**模式语法**

- `(?N)` — 在位置`N`匹配条件参数。 条件在编号 `[1, 32]` 范围。 例如, `(?1)` 匹配传递给 `cond1` 参数。
- `.*` — 匹配任何事件的数字。 不需要条件参数来匹配这个模式。
- `(?t operator value)` — 分开两个事件的时间。 例如： `(?1)(?t>1800)(?2)` 匹配彼此发生超过1800秒的事件。 这些事件之间可以存在任意数量的任何事件。 您可以使用 `>=`, `>`, `<`, `<=` 运算符。

**例**

考虑在数据 `t` 表:

```
┌─time─┬─number─┐
│    1 │      1 │
│    2 │      3 │
│    3 │      2 │
└──────┴────────┘
```

执行查询:

```
SELECT sequenceMatch(''(?1)(?2)'')(time, number = 1, number = 2) FROM t
┌─sequenceMatch(''(?1)(?2)'')(time, equals(number, 1), equals(number, 2))─┐
│                                                                     1 │
└───────────────────────────────────────────────────────────────────────┘
```

该函数找到了数字2跟随数字1的事件链。 它跳过了它们之间的数字3，因为该数字没有被描述为事件。 如果我们想在搜索示例中给出的事件链时考虑这个数字，我们应该为它创建一个条件。

```
SELECT sequenceMatch(''(?1)(?2)'')(time, number = 1, number = 2, number = 3) FROM t
┌─sequenceMatch(''(?1)(?2)'')(time, equals(number, 1), equals(number, 2), equals(number, 3))─┐
│                                                                                        0 │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

在这种情况下，函数找不到与模式匹配的事件链，因为数字3的事件发生在1和2之间。 如果在相同的情况下，我们检查了数字4的条件，则序列将与模式匹配。

```
SELECT sequenceMatch(''(?1)(?2)'')(time, number = 1, number = 2, number = 4) FROM t
┌─sequenceMatch(''(?1)(?2)'')(time, equals(number, 1), equals(number, 2), equals(number, 4))─┐
│                                                                                        1 │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

**另请参阅**

- sequenceCount

#### sequenceCount(pattern)(time, cond1, cond2, …)

计算与模式匹配的事件链的数量。该函数搜索不重叠的事件链。当前链匹配后，它开始搜索下一个链。

警告

在同一秒钟发生的事件可能以未定义的顺序排列在序列中，影响结果。

```
sequenceCount(pattern)(timestamp, cond1, cond2, ...)
```

**参数**

- `pattern` — 模式字符串。 参考：模式语法.
- `timestamp` — 包含时间的列。典型的时间类型是： `Date` 和 `DateTime`。您还可以使用任何支持的 UInt 数据类型。
- `cond1`, `cond2` — 事件链的约束条件。 数据类型是： `UInt8`。 最多可以传递32个条件参数。该函数只考虑这些条件中描述的事件。 如果序列包含未在条件中描述的数据，则函数将跳过这些数据。

**返回值**

- 匹配的非重叠事件链数。

类型: `UInt64`.

**示例**

考虑在数据 `t` 表:

```
┌─time─┬─number─┐
│    1 │      1 │
│    2 │      3 │
│    3 │      2 │
│    4 │      1 │
│    5 │      3 │
│    6 │      2 │
└──────┴────────┘
```

计算数字2在数字1之后出现的次数以及它们之间的任何其他数字:

```
SELECT sequenceCount(''(?1).*(?2)'')(time, number = 1, number = 2) FROM t
┌─sequenceCount(''(?1).*(?2)'')(time, equals(number, 1), equals(number, 2))─┐
│                                                                       2 │
└─────────────────────────────────────────────────────────────────────────┘
```

**另请参阅**

- sequenceMatch

#### windowFunnel

搜索滑动时间窗中的事件链，并计算从链中发生的最大事件数。

该函数采用如下算法：

- 该函数搜索触发链中的第一个条件并将事件计数器设置为1。 这是滑动窗口启动的时刻。
- 如果来自链的事件在窗口内顺序发生，则计数器将递增。 如果事件序列中断，则计数器不会增加。
- 如果数据在不同的完成点具有多个事件链，则该函数将仅输出最长链的大小。

**语法**

```
windowFunnel(window, [mode])(timestamp, cond1, cond2, ..., condN)
```

**参数**

- `window` — 滑动窗户的大小，单位是秒。

- ```
  mode
  ```



  \- 这是一个可选的参数。

  - `''strict''` - 当 `''strict''` 设置时，windowFunnel()仅对唯一值应用匹配条件。

- `timestamp` — 包含时间的列。 数据类型支持： 日期, 日期时间 和其他无符号整数类型（请注意，即使时间戳支持 `UInt64` 类型，它的值不能超过Int64最大值，即2^63-1）。

- `cond` — 事件链的约束条件。 UInt8 类型。

**返回值**

滑动时间窗口内连续触发条件链的最大数目。
对选择中的所有链进行了分析。

类型: `Integer`.

**示例**

确定设定的时间段是否足以让用户选择手机并在在线商店中购买两次。

设置以下事件链:

1. 用户登录到其在应用商店中的帐户 (`eventID = 1003`).
2. 用户搜索手机 (`eventID = 1007, product = ''phone''`).
3. 用户下了订单 (`eventID = 1009`).
4. 用户再次下订单 (`eventID = 1010`).

输入表:

```
┌─event_date─┬─user_id─┬───────────timestamp─┬─eventID─┬─product─┐
│ 2019-01-28 │       1 │ 2019-01-29 10:00:00 │    1003 │ phone   │
└────────────┴─────────┴─────────────────────┴─────────┴─────────┘
┌─event_date─┬─user_id─┬───────────timestamp─┬─eventID─┬─product─┐
│ 2019-01-31 │       1 │ 2019-01-31 09:00:00 │    1007 │ phone   │
└────────────┴─────────┴─────────────────────┴─────────┴─────────┘
┌─event_date─┬─user_id─┬───────────timestamp─┬─eventID─┬─product─┐
│ 2019-01-30 │       1 │ 2019-01-30 08:00:00 │    1009 │ phone   │
└────────────┴─────────┴─────────────────────┴─────────┴─────────┘
┌─event_date─┬─user_id─┬───────────timestamp─┬─eventID─┬─product─┐
│ 2019-02-01 │       1 │ 2019-02-01 08:00:00 │    1010 │ phone   │
└────────────┴─────────┴─────────────────────┴─────────┴─────────┘
```

了解用户`user_id` 可以在2019的1-2月期间通过链条多远。

查询:

```
SELECT
    level,
    count() AS c
FROM
(
    SELECT
        user_id,
        windowFunnel(6048000000000000)(timestamp, eventID = 1003, eventID = 1009, eventID = 1007, eventID = 1010) AS level
    FROM trend
    WHERE (event_date >= ''2019-01-01'') AND (event_date <= ''2019-02-02'')
    GROUP BY user_id
)
GROUP BY level
ORDER BY level ASC
```

结果:

```
┌─level─┬─c─┐
│     4 │ 1 │
└───────┴───┘
```

#### Retention

该函数将一组条件作为参数，类型为1到32个 `UInt8` 类型的参数，用来表示事件是否满足特定条件。
任何条件都可以指定为参数（如 WHERE.

除了第一个以外，条件成对适用：如果第一个和第二个是真的，第二个结果将是真的，如果第一个和第三个是真的，第三个结果将是真的，等等。

**语法**

```
retention(cond1, cond2, ..., cond32);
```

**参数**

- `cond` — 返回 `UInt8` 结果（1或0）的表达式。

**返回值**

数组为1或0。

- 1 — 条件满足。
- 0 — 条件不满足。

类型: `UInt8`.

**示例**

让我们考虑使用 `retention` 功能的一个例子 ，以确定网站流量。

**1.** 举例说明，先创建一张表。

```
CREATE TABLE retention_test(date Date, uid Int32) ENGINE = Memory;

INSERT INTO retention_test SELECT ''2020-01-01'', number FROM numbers(5);
INSERT INTO retention_test SELECT ''2020-01-02'', number FROM numbers(10);
INSERT INTO retention_test SELECT ''2020-01-03'', number FROM numbers(15);
```

输入表:

查询:

```
SELECT * FROM retention_test
```

结果:

```
┌───────date─┬─uid─┐
│ 2020-01-01 │   0 │
│ 2020-01-01 │   1 │
│ 2020-01-01 │   2 │
│ 2020-01-01 │   3 │
│ 2020-01-01 │   4 │
└────────────┴─────┘
┌───────date─┬─uid─┐
│ 2020-01-02 │   0 │
│ 2020-01-02 │   1 │
│ 2020-01-02 │   2 │
│ 2020-01-02 │   3 │
│ 2020-01-02 │   4 │
│ 2020-01-02 │   5 │
│ 2020-01-02 │   6 │
│ 2020-01-02 │   7 │
│ 2020-01-02 │   8 │
│ 2020-01-02 │   9 │
└────────────┴─────┘
┌───────date─┬─uid─┐
│ 2020-01-03 │   0 │
│ 2020-01-03 │   1 │
│ 2020-01-03 │   2 │
│ 2020-01-03 │   3 │
│ 2020-01-03 │   4 │
│ 2020-01-03 │   5 │
│ 2020-01-03 │   6 │
│ 2020-01-03 │   7 │
│ 2020-01-03 │   8 │
│ 2020-01-03 │   9 │
│ 2020-01-03 │  10 │
│ 2020-01-03 │  11 │
│ 2020-01-03 │  12 │
│ 2020-01-03 │  13 │
│ 2020-01-03 │  14 │
└────────────┴─────┘
```

**2.** 按唯一ID `uid` 对用户进行分组，使用 `retention` 功能。

查询:

```
SELECT
    uid,
    retention(date = ''2020-01-01'', date = ''2020-01-02'', date = ''2020-01-03'') AS r
FROM retention_test
WHERE date IN (''2020-01-01'', ''2020-01-02'', ''2020-01-03'')
GROUP BY uid
ORDER BY uid ASC
```

结果:

```
┌─uid─┬─r───────┐
│   0 │ [1,1,1] │
│   1 │ [1,1,1] │
│   2 │ [1,1,1] │
│   3 │ [1,1,1] │
│   4 │ [1,1,1] │
│   5 │ [0,0,0] │
│   6 │ [0,0,0] │
│   7 │ [0,0,0] │
│   8 │ [0,0,0] │
│   9 │ [0,0,0] │
│  10 │ [0,0,0] │
│  11 │ [0,0,0] │
│  12 │ [0,0,0] │
│  13 │ [0,0,0] │
│  14 │ [0,0,0] │
└─────┴─────────┘
```

**3.** 计算每天的现场访问总数。

查询:

```
SELECT
    sum(r[1]) AS r1,
    sum(r[2]) AS r2,
    sum(r[3]) AS r3
FROM
(
    SELECT
        uid,
        retention(date = ''2020-01-01'', date = ''2020-01-02'', date = ''2020-01-03'') AS r
    FROM retention_test
    WHERE date IN (''2020-01-01'', ''2020-01-02'', ''2020-01-03'')
    GROUP BY uid
)
```

结果:

```
┌─r1─┬─r2─┬─r3─┐
│  5 │  5 │  5 │
└────┴────┴────┘
```

条件:

- `r1`-2020-01-01期间访问该网站的独立访问者数量（ `cond1` 条件）。
- `r2`-在2020-01-01和2020-01-02之间的特定时间段内访问该网站的唯一访问者的数量 (`cond1` 和 `cond2` 条件）。
- `r3`-在2020-01-01和2020-01-03之间的特定时间段内访问该网站的唯一访问者的数量 (`cond1` 和 `cond3` 条件）。

#### uniqUpTo(N)(x)

计算小于或者等于N的不同参数的个数。如果结果大于N，那返回N+1。

建议使用较小的Ns，比如：10。N的最大值为100。

对于聚合函数的状态，它使用的内存量等于1+N*一个字节值的大小。
对于字符串，它存储8个字节的非加密哈希。 也就是说，计算是近似的字符串。

该函数也适用于多个参数。

它的工作速度尽可能快，除了使用较大的N值并且唯一值的数量略小于N的情况。

用法示例:

```
问题：产出一个不少于五个唯一用户的关键字报告
解决方案： 写group by查询语句 HAVING uniqUpTo(4)(UserID) >= 5
```

#### sumMapFiltered(keys_to_keep)(keys, values)

和 sumMap 基本一致， 除了一个键数组作为参数传递。这在使用高基数key时尤其有用。
' where id= 54;