update biz_data_query_model_help_content set content_en = '# SELECT Query

`SELECT` queries perform data retrieval. By default, the requested data is returned to the client, while in conjunction with [INSERT INTO] it can be forwarded to a different table.

## Syntax

```
[WITH expr_list|(subquery)]
SELECT [DISTINCT] expr_list
[FROM [db.]table | (subquery) | table_function] [FINAL]
[SAMPLE sample_coeff]
[ARRAY JOIN ...]
[GLOBAL] [ANY|ALL|ASOF] [INNER|LEFT|RIGHT|FULL|CROSS] [OUTER|SEMI|ANTI] JOIN (subquery)|table (ON <expr_list>)|(USING <column_list>)
[PREWHERE expr]
[WHERE expr]
[GROUP BY expr_list] [WITH ROLLUP|WITH CUBE] [WITH TOTALS]
[HAVING expr]
[ORDER BY expr_list] [WITH FILL] [FROM expr] [TO expr] [STEP expr]
[LIMIT [offset_value, ]n BY columns]
[LIMIT [n, ]m] [WITH TIES]
[SETTINGS ...]
[UNION  ...]
[INTO OUTFILE filename]
[FORMAT format]
```

All clauses are optional, except for the required list of expressions immediately after `SELECT` which is covered in more detail [below].

Specifics of each optional clause are covered in separate sections, which are listed in the same order as they are executed:

- [WITH clause]
- [FROM clause]
- [SAMPLE clause]
- [JOIN clause]
- [PREWHERE clause]
- [WHERE clause]
- [GROUP BY clause]
- [LIMIT BY clause]
- [HAVING clause]
- [SELECT clause]
- [DISTINCT clause]
- [LIMIT clause]
- [OFFSET clause]
- [UNION clause]
- [INTO OUTFILE clause]
- [FORMAT clause]

## SELECT Clause

[Expressions] specified in the `SELECT` clause are calculated after all the operations in the clauses described above are finished. These expressions work as if they apply to separate rows in the result. If expressions in the `SELECT` clause contain aggregate functions, then ClickHouse processes aggregate functions and expressions used as their arguments during the [GROUP BY] aggregation.

If you want to include all columns in the result, use the asterisk (`*`) symbol. For example, `SELECT * FROM ...`.

### COLUMNS expression

To match some columns in the result with a [re2]) regular expression, you can use the `COLUMNS` expression.

```
COLUMNS(''regexp'')
```

For example, consider the table:

```
CREATE TABLE default.col_names (aa Int8, ab Int8, bc Int8) ENGINE = TinyLog
```

The following query selects data from all the columns containing the `a` symbol in their name.

```
SELECT COLUMNS(a) FROM col_names
┌─aa─┬─ab─┐
│  1 │  1 │
└────┴────┘
```

The selected columns are returned not in the alphabetical order.

You can use multiple `COLUMNS` expressions in a query and apply functions to them.

For example:

```
SELECT COLUMNS(''a''), COLUMNS(''c''), toTypeName(COLUMNS(''c'')) FROM col_names
┌─aa─┬─ab─┬─bc─┬─toTypeName(bc)─┐
│  1 │  1 │  1 │ Int8           │
└────┴────┴────┴────────────────┘
```

Each column returned by the `COLUMNS` expression is passed to the function as a separate argument. Also you can pass other arguments to the function if it supports them. Be careful when using functions. If a function does not support the number of arguments you have passed to it, ClickHouse throws an exception.

For example:

```
SELECT COLUMNS(''a'') + COLUMNS(''c'') FROM col_names
Received exception from server (version 19.14.1):
Code: 42. DB::Exception: Received from localhost:9000. DB::Exception: Number of arguments for function plus doesn''t match: passed 3, should be 2.
```

In this example,  `COLUMNS(''a'')` returns two columns: `aa` and  `ab`. `COLUMNS(''c'')` returns the `bc` column. The `+` operator can’t apply to 3 arguments, so ClickHouse throws an exception with the relevant message.

Columns that matched the `COLUMNS` expression can have different data types. If `COLUMNS` does not match any columns and is the only expression in `SELECT`, ClickHouse throws an exception.

### Asterisk

You can put an asterisk in any part of a query instead of an expression. When the query is analyzed, the asterisk is expanded to a list of all table columns (excluding the `MATERIALIZED` and `ALIAS` columns). There are only a few cases when using an asterisk is justified:

- When creating a table dump.
- For tables containing just a few columns, such as system tables.
- For getting information about what columns are in a table. In this case, set `LIMIT 1`. But it is better to use the `DESC TABLE` query.
- When there is strong filtration on a small number of columns using `PREWHERE`.
- In subqueries (since columns that aren’t needed for the external query are excluded from subqueries).

In all other cases, we do not recommend using the asterisk, since it only gives you the drawbacks of a columnar DBMS instead of the advantages. In other words using the asterisk is not recommended.

### Extreme Values

In addition to results, you can also get minimum and maximum values for the results columns. To do this, set the **extremes** setting to 1. Minimums and maximums are calculated for numeric types, dates, and dates with times. For other columns, the default values are output.

An extra two rows are calculated – the minimums and maximums, respectively. These extra two rows are output in `JSON*`, `TabSeparated*`, and `Pretty*` [formats], separate from the other rows. They are not output for other formats.

In `JSON*` formats, the extreme values are output in a separate ‘extremes’ field. In `TabSeparated*` formats, the row comes after the main result, and after ‘totals’ if present. It is preceded by an empty row (after the other data). In `Pretty*` formats, the row is output as a separate table after the main result, and after `totals` if present.

Extreme values are calculated for rows before `LIMIT`, but after `LIMIT BY`. However, when using `LIMIT offset, size`, the rows before `offset` are included in `extremes`. In stream requests, the result may also include a small number of rows that passed through `LIMIT`.

### Notes

You can use synonyms (`AS` aliases) in any part of a query.

The `GROUP BY` and `ORDER BY` clauses do not support positional arguments. This contradicts MySQL, but conforms to standard SQL. For example, `GROUP BY 1, 2` will be interpreted as grouping by constants (i.e. aggregation of all rows into one).

## Implementation Details

If the query omits the `DISTINCT`, `GROUP BY` and `ORDER BY` clauses and the `IN` and `JOIN` subqueries, the query will be completely stream processed, using O(1) amount of RAM. Otherwise, the query might consume a lot of RAM if the appropriate restrictions are not specified:

- `max_memory_usage`
- `max_rows_to_group_by`
- `max_rows_to_sort`
- `max_rows_in_distinct`
- `max_bytes_in_distinct`
- `max_rows_in_set`
- `max_bytes_in_set`
- `max_rows_in_join`
- `max_bytes_in_join`
- `max_bytes_before_external_sort`
- `max_bytes_before_external_group_by`

For more information, see the section “Settings”. It is possible to use external sorting (saving temporary tables to a disk) and external aggregation.

## SELECT modifiers

You can use the following modifiers in `SELECT` queries.

### APPLY

Allows you to invoke some function for each row returned by an outer table expression of a query.

**Syntax:**

```
SELECT <expr> APPLY( <func> ) FROM [db.]table_name
```

**Example:**

```
CREATE TABLE columns_transformers (i Int64, j Int16, k Int64) ENGINE = MergeTree ORDER by (i);
INSERT INTO columns_transformers VALUES (100, 10, 324), (120, 8, 23);
SELECT * APPLY(sum) FROM columns_transformers;
┌─sum(i)─┬─sum(j)─┬─sum(k)─┐
│    220 │     18 │    347 │
└────────┴────────┴────────┘
```

### EXCEPT

Specifies the names of one or more columns to exclude from the result. All matching column names are omitted from the output.

**Syntax:**

```
SELECT <expr> EXCEPT ( col_name1 [, col_name2, col_name3, ...] ) FROM [db.]table_name
```

**Example:**

```
SELECT * EXCEPT (i) from columns_transformers;┌──j─┬───k─┐│ 10 │ 324 ││  8 │  23 │└────┴─────┘
```

### REPLACE

Specifies one or more [expression aliases]. Each alias must match a column name from the `SELECT *` statement. In the output column list, the column that matches the alias is replaced by the expression in that `REPLACE`.

This modifier does not change the names or order of columns. However, it can change the value and the value type.

**Syntax:**

```
SELECT <expr> REPLACE( <expr> AS col_name) from [db.]table_name
```

**Example:**

```
SELECT * REPLACE(i + 1 AS i) from columns_transformers;┌───i─┬──j─┬───k─┐│ 101 │ 10 │ 324 ││ 121 │  8 │  23 │└─────┴────┴─────┘
```

### Modifier Combinations

You can use each modifier separately or combine them.

**Examples:**

Using the same modifier multiple times.

```
SELECT COLUMNS([jk]) APPLY(toString) APPLY(length) APPLY(max) from columns_transformers;┌─max(length(toString(j)))─┬─max(length(toString(k)))─┐│                        2 │                        3 │└──────────────────────────┴──────────────────────────┘
```

Using multiple modifiers in a single query.

```
SELECT * REPLACE(i + 1 AS i) EXCEPT (j) APPLY(sum) from columns_transformers;┌─sum(plus(i, 1))─┬─sum(k)─┐│             222 │    347 │└─────────────────┴────────┘
```

## SETTINGS in SELECT Query

You can specify the necessary settings right in the `SELECT` query. The setting value is applied only to this query and is reset to default or previous value after the query is executed.

Other ways to make settings see [here].

**Example**

```
SELECT * FROM some_table SETTINGS optimize_read_in_order=1, cast_keep_nullable=1;
```

' where id=55;
update biz_data_query_model_help_content set content_en = '# FORMAT Clause

ClickHouse supports a wide range of serialization formats that can be used on query results among other things. There are multiple ways to choose a format for `SELECT` output, one of them is to specify `FORMAT format` at the end of query to get resulting data in any specific format.

Specific format might be used either for convenience, integration with other systems or performance gain.

## Default Format

If the `FORMAT` clause is omitted, the default format is used, which depends on both the settings and the interface used for accessing the ClickHouse server. For the HTTP interface and the command-line client in batch mode, the default format is `TabSeparated`. For the command-line client in interactive mode, the default format is `PrettyCompact` (it produces compact human-readable tables).

## Implementation Details

When using the command-line client, data is always passed over the network in an internal efficient format (`Native`). The client independently interprets the `FORMAT` clause of the query and formats the data itself (thus relieving the network and the server from the extra load).

' where id=59;
update biz_data_query_model_help_content set content_en = '# CREATE DATABASE

Creates a new database.

```
CREATE DATABASE [IF NOT EXISTS] db_name [ON CLUSTER cluster] [ENGINE = engine(...)]
```

If the `db_name` database already exists, then ClickHouse does not create a new database and:

- Doesn’t throw an exception if clause is specified.
- Throws an exception if clause isn’t specified.

# CREATE TABLE

Creates a new table. This query can have various syntax forms depending on a use case.

By default, tables are created only on the current server. Distributed DDL queries are implemented as `ON CLUSTER` clause, which is described separately.

```
CREATE TABLE [IF NOT EXISTS] [db.]table_name [ON CLUSTER cluster]
(
    name1 [type1] [NULL|NOT NULL] [DEFAULT|MATERIALIZED|ALIAS expr1] [compression_codec] [TTL expr1],
    name2 [type2] [NULL|NOT NULL] [DEFAULT|MATERIALIZED|ALIAS expr2] [compression_codec] [TTL expr2],
    ...
) ENGINE = engine
```

Creates a table named `name` in the `db` database or the current database if `db` is not set, with the structure specified in brackets and the `engine` engine.
The structure of the table is a list of column descriptions, secondary indexes and constraints . If primary key is supported by the engine, it will be indicated as parameter for the table engine.

A column description is `name type` in the simplest case. Example: `RegionID UInt32`.

Expressions can also be defined for default values (see below).

If necessary, primary key can be specified, with one or more key expressions.

**With a Schema Similar to Other Table**

```
CREATE TABLE [IF NOT EXISTS] [db.]table_name AS [db2.]name2 [ENGINE = engine]
```

Creates a table with the same structure as another table. You can specify a different engine for the table. If the engine is not specified, the same engine will be used as for the `db2.name2` table.

From SELECT query

```
CREATE TABLE [IF NOT EXISTS] [db.]table_name[(name1 [type1], name2 [type2], ...)] ENGINE = engine AS SELECT ...
```

Creates a table with a structure like the result of the `SELECT` query, with the `engine` engine, and fills it with data from `SELECT`. Also you can explicitly specify columns description.

If the table already exists and `IF NOT EXISTS` is specified, the query won’t do anything.

There can be other clauses after the `ENGINE` clause in the query. See detailed documentation on how to create tables in the descriptions of table engines.

## Default Values

The column description can specify an expression for a default value, in one of the following ways: `DEFAULT expr`, `MATERIALIZED expr`, `ALIAS expr`.

Example: `URLDomain String DEFAULT domain(URL)`.

If an expression for the default value is not defined, the default values will be set to zeros for numbers, empty strings for strings, empty arrays for arrays, and `1970-01-01` for dates or zero unix timestamp for DateTime, NULL for Nullable.

If the default expression is defined, the column type is optional. If there isn’t an explicitly defined type, the default expression type is used. Example: `EventDate DEFAULT toDate(EventTime)` – the ‘Date’ type will be used for the ‘EventDate’ column.

If the data type and default expression are defined explicitly, this expression will be cast to the specified type using type casting functions. Example: `Hits UInt32 DEFAULT 0` means the same thing as `Hits UInt32 DEFAULT toUInt32(0)`.

Default expressions may be defined as an arbitrary expression from table constants and columns. When creating and changing the table structure, it checks that expressions do not contain loops. For INSERT, it checks that expressions are resolvable – that all columns they can be calculated from have been passed.

## Constraints

Along with columns descriptions constraints could be defined:

```
CREATE TABLE [IF NOT EXISTS] [db.]table_name [ON CLUSTER cluster]
(
    name1 [type1] [DEFAULT|MATERIALIZED|ALIAS expr1] [compression_codec] [TTL expr1],
    ...
    CONSTRAINT constraint_name_1 CHECK boolean_expr_1,
    ...
) ENGINE = engine
```

`boolean_expr_1` could by any boolean expression. If constraints are defined for the table, each of them will be checked for every row in `INSERT` query. If any constraint is not satisfied — server will raise an exception with constraint name and checking expression.

Adding large amount of constraints can negatively affect performance of big `INSERT` queries.

## TTL Expression

Defines storage time for values. Can be specified only for MergeTree-family tables. For the detailed description, see TTL for columns and tables.

## Column Compression Codecs

By default, ClickHouse applies the `lz4` compression method. For `MergeTree`-engine family you can change the default compression method in the compression section of a server configuration.

You can also define the compression method for each individual column in the `CREATE TABLE` query.

```
CREATE TABLE codec_example
(
    dt Date CODEC(ZSTD),
    ts DateTime CODEC(LZ4HC),
    float_value Float32 CODEC(NONE),
    double_value Float64 CODEC(LZ4HC(9))
    value Float32 CODEC(Delta, ZSTD)
)
ENGINE = <Engine>
...
```

The `Default` codec can be specified to reference default compression which may depend on different settings (and properties of data) in runtime.
Example: `value UInt64 CODEC(Default)` — the same as lack of codec specification.

Also you can remove current CODEC from the column and use default compression from config.xml:

```
ALTER TABLE codec_example MODIFY COLUMN float_value CODEC(Default);
```

Codecs can be combined in a pipeline, for example, `CODEC(Delta, Default)`.

To select the best codec combination for you project, pass benchmarks similar to described in the Altinity New Encodings to Improve ClickHouse Efficiency article. One thing to note is that codec can''t be applied for ALIAS column type.

ClickHouse supports general purpose codecs and specialized codecs.

#### General Purpose Codecs

Codecs:

- `NONE` — No compression.
- `LZ4` — Lossless data compression algorithm used by default. Applies LZ4 fast compression.
- `LZ4HC[(level)]` — LZ4 HC (high compression) algorithm with configurable level. Default level: 9. Setting `level <= 0` applies the default level. Possible levels: [1, 12]. Recommended level range: [4, 9].
- `ZSTD[(level)]` — ZSTD compression algorithm with configurable `level`. Possible levels: [1, 22]. Default value: 1.

High compression levels are useful for asymmetric scenarios, like compress once, decompress repeatedly. Higher levels mean better compression and higher CPU usage.

#### Specialized Codecs

These codecs are designed to make compression more effective by using specific features of data. Some of these codecs do not compress data themself. Instead, they prepare the data for a common purpose codec, which compresses it better than without this preparation.

Specialized codecs:

- `Delta(delta_bytes)` — Compression approach in which raw values are replaced by the difference of two neighboring values, except for the first value that stays unchanged. Up to `delta_bytes` are used for storing delta values, so `delta_bytes` is the maximum size of raw values. Possible `delta_bytes` values: 1, 2, 4, 8. The default value for `delta_bytes` is `sizeof(type)` if equal to 1, 2, 4, or 8. In all other cases, it’s 1.
- `DoubleDelta` — Calculates delta of deltas and writes it in compact binary form. Optimal compression rates are achieved for monotonic sequences with a constant stride, such as time series data. Can be used with any fixed-width type. Implements the algorithm used in Gorilla TSDB, extending it to support 64-bit types. Uses 1 extra bit for 32-byte deltas: 5-bit prefixes instead of 4-bit prefixes. For additional information, see Compressing Time Stamps in Gorilla: A Fast, Scalable, In-Memory Time Series Database.
- `Gorilla` — Calculates XOR between current and previous value and writes it in compact binary form. Efficient when storing a series of floating point values that change slowly, because the best compression rate is achieved when neighboring values are binary equal. Implements the algorithm used in Gorilla TSDB, extending it to support 64-bit types. For additional information, see Compressing Values in Gorilla: A Fast, Scalable, In-Memory Time Series Database.
- `T64` — Compression approach that crops unused high bits of values in integer data types (including `Enum`, `Date` and `DateTime`). At each step of its algorithm, codec takes a block of 64 values, puts them into 64x64 bit matrix, transposes it, crops the unused bits of values and returns the rest as a sequence. Unused bits are the bits, that do not differ between maximum and minimum values in the whole data part for which the compression is used.

`DoubleDelta` and `Gorilla` codecs are used in Gorilla TSDB as the components of its compressing algorithm. Gorilla approach is effective in scenarios when there is a sequence of slowly changing values with their timestamps. Timestamps are effectively compressed by the `DoubleDelta` codec, and values are effectively compressed by the `Gorilla` codec. For example, to get an effectively stored table, you can create it in the following configuration:

```
CREATE TABLE codec_example
(
    timestamp DateTime CODEC(DoubleDelta),
    slow_values Float32 CODEC(Gorilla)
)
ENGINE = MergeTree()
```

## Temporary Tables

ClickHouse supports temporary tables which have the following characteristics:

- Temporary tables disappear when the session ends, including if the connection is lost.
- A temporary table uses the Memory engine only.
- The DB can’t be specified for a temporary table. It is created outside of databases.
- Impossible to create a temporary table with distributed DDL query on all cluster servers (by using `ON CLUSTER`): this table exists only in the current session.
- If a temporary table has the same name as another one and a query specifies the table name without specifying the DB, the temporary table will be used.
- For distributed query processing, temporary tables used in a query are passed to remote servers.

To create a temporary table, use the following syntax:

```
CREATE TEMPORARY TABLE [IF NOT EXISTS] table_name
(
    name1 [type1] [DEFAULT|MATERIALIZED|ALIAS expr1],
    name2 [type2] [DEFAULT|MATERIALIZED|ALIAS expr2],
    ...
)
```

In most cases, temporary tables are not created manually, but when using external data for a query, or for distributed `(GLOBAL) IN`. For more information, see the appropriate sections

It’s possible to use tables with ENGINE = Memory instead of temporary tables.

## Distributed DDL Queries (ON CLUSTER Clause)

By default the `CREATE`, `DROP`, `ALTER`, and `RENAME` queries affect only the current server where they are executed. In a cluster setup, it is possible to run such queries in a distributed manner with the `ON CLUSTER` clause.

For example, the following query creates the `all_hits` `Distributed` table on each host in `cluster`:

```
CREATE TABLE IF NOT EXISTS all_hits ON CLUSTER cluster (p Date, i Int32) ENGINE = Distributed(cluster, default, hits)
```

In order to run these queries correctly, each host must have the same cluster definition (to simplify syncing configs, you can use substitutions from ZooKeeper). They must also connect to the ZooKeeper servers.

The local version of the query will eventually be executed on each host in the cluster, even if some hosts are currently not available.

# CREATE VIEW

```
CREATE [OR REPLACE] VIEW [IF NOT EXISTS] [db.]table_name [ON CLUSTER] AS SELECT ...
```

Creates a new view. There are two types of views: normal and materialized.

Normal views do not store any data. They just perform a read from another table on each access. In other words, a normal view is nothing more than a saved query. When reading from a view, this saved query is used as a subquery in the FROM clause.

As an example, assume you’ve created a view:

```
CREATE VIEW view AS SELECT ...
```

and written a query:

```
SELECT a, b, c FROM view
```

This query is fully equivalent to using the subquery:

```
SELECT a, b, c FROM (SELECT ...)
```

**Materialized**

```
CREATE MATERIALIZED VIEW [IF NOT EXISTS] [db.]table_name [ON CLUSTER] [TO[db.]name] [ENGINE = engine] [POPULATE] AS SELECT ...
```

Materialized views store data transformed by the corresponding SELECT query.

When creating a materialized view without `TO [db].[table]`, you must specify `ENGINE` – the table engine for storing data.

When creating a materialized view with `TO [db].[table]`, you must not use `POPULATE`.

A materialized view is implemented as follows: when inserting data to the table specified in `SELECT`, part of the inserted data is converted by this `SELECT` query, and the result is inserted in the view.

# CREATE DICTIONARY

Creates a new external dictionary with given structure, source, layout and lifetime.

Syntax:

```
CREATE DICTIONARY [IF NOT EXISTS] [db.]dictionary_name [ON CLUSTER cluster]
(
    key1 type1  [DEFAULT|EXPRESSION expr1] [HIERARCHICAL|INJECTIVE|IS_OBJECT_ID],
    key2 type2  [DEFAULT|EXPRESSION expr2] [HIERARCHICAL|INJECTIVE|IS_OBJECT_ID],
    attr1 type2 [DEFAULT|EXPRESSION expr3],
    attr2 type2 [DEFAULT|EXPRESSION expr4]
)
PRIMARY KEY key1, key2
SOURCE(SOURCE_NAME([param1 value1 ... paramN valueN]))
LAYOUT(LAYOUT_NAME([param_name param_value]))
LIFETIME({MIN min_val MAX max_val | max_val})
```

' where id=16;
update biz_data_query_model_help_content set content_en = '# stochasticLinearRegression

This function implements stochastic linear regression. It supports custom parameters for learning rate, L2 regularization coefficient, mini-batch size and has few methods for updating weights (Adam (used by default), simple SGD, Momentum, Nesterov.

### Parameters

There are 4 customizable parameters. They are passed to the function sequentially, but there is no need to pass all four - default values will be used, however good model required some parameter tuning.

```
stochasticLinearRegression(1.0, 1.0, 10, SGD)
```

1. `learning rate` is the coefficient on step length, when gradient descent step is performed. Too big learning rate may cause infinite weights of the model. Default is `0.1`.
2. `l2 regularization coefficient` which may help to prevent overfitting. Default is `0.1`.
3. `mini-batch size` sets the number of elements, which gradients will be computed and summed to perform one step of gradient descent. Pure stochastic descent uses one element, however having small batches(about 10 elements) make gradient steps more stable. Default is `15`.
4. `method for updating weights`, they are: `Adam` (by default), `SGD`, `Momentum`, `Nesterov`. `Momentum` and `Nesterov` require little bit more computations and memory, however they happen to be useful in terms of speed of convergance and stability of stochastic gradient methods.

### Usage

`stochasticLinearRegression` is used in two steps: fitting the model and predicting on new data. In order to fit the model and save its state for later usage we use `-State` combinator, which basically saves the state (model weights, etc).
To predict we use function evalMLMethod, which takes a state as an argument as well as features to predict on.



**1.** Fitting

Such query may be used.

```
CREATE TABLE IF NOT EXISTS train_data
(
    param1 Float64,
    param2 Float64,
    target Float64
) ENGINE = Memory;

CREATE TABLE your_model ENGINE = Memory AS SELECT
stochasticLinearRegressionState(0.1, 0.0, 5, SGD)(target, param1, param2)
AS state FROM train_data;
```

Here we also need to insert data into `train_data` table. The number of parameters is not fixed, it depends only on number of arguments, passed into `linearRegressionState`. They all must be numeric values.
Note that the column with target value(which we would like to learn to predict) is inserted as the first argument.

**2.** Predicting

After saving a state into the table, we may use it multiple times for prediction, or even merge with other states and create new even better models.

```
WITH (SELECT state FROM your_model) AS model SELECT
evalMLMethod(model, param1, param2) FROM test_data
```

The query will return a column of predicted values. Note that first argument of `evalMLMethod` is `AggregateFunctionState` object, next are columns of features.

`test_data` is a table like `train_data` but may not contain target value.

### Notes

1. To merge two models user may create such query:
   `sql SELECT state1 + state2 FROM your_models`
   where `your_models` table contains both models. This query will return new `AggregateFunctionState` object.
2. User may fetch weights of the created model for its own purposes without saving the model if no `-State` combinator is used.
   `sql SELECT stochasticLinearRegression(0.01)(target, param1, param2) FROM train_data`
   Such query will fit the model and return its weights - first are weights, which correspond to the parameters of the model, the last one is bias. So in the example above the query will return a column with 3 values.

' where id=131;
update biz_data_query_model_help_content set content_en = '# Parametric Aggregate Functions

Some aggregate functions can accept not only argument columns (used for compression), but a set of parameters – constants for initialization. The syntax is two pairs of brackets instead of one. The first is for parameters, and the second is for arguments.

## histogram

Calculates an adaptive histogram. It does not guarantee precise results.

```
histogram(number_of_bins)(values)
```

The functions uses A Streaming Parallel Decision Tree Algorithm. The borders of histogram bins are adjusted as new data enters a function. In common case, the widths of bins are not equal.

**Arguments**

`values` — [Expression] resulting in input values.

**Parameters**

`number_of_bins` — Upper limit for the number of bins in the histogram. The function automatically calculates the number of bins. It tries to reach the specified number of bins, but if it fails, it uses fewer bins.

**Returned values**

- Array of Tuples of the following format:

  ```
​```
[(lower_1, upper_1, height_1), ... (lower_N, upper_N, height_N)]
​```

- `lower` — Lower bound of the bin.
- `upper` — Upper bound of the bin.
- `height` — Calculated height of the bin.
  ```

**Example**

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

You can visualize a histogram with the [bar] function, for example:

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

In this case, you should remember that you do not know the histogram bin borders.

## sequenceMatch(pattern)(timestamp, cond1, cond2, …)

Checks whether the sequence contains an event chain that matches the pattern.

```
sequenceMatch(pattern)(timestamp, cond1, cond2, ...)
```

Warning

Events that occur at the same second may lay in the sequence in an undefined order affecting the result.

**Arguments**

- `timestamp` — Column considered to contain time data. Typical data types are `Date` and `DateTime`. You can also use any of the supported [UInt] data types.
- `cond1`, `cond2` — Conditions that describe the chain of events. Data type: `UInt8`. You can pass up to 32 condition arguments. The function takes only the events described in these conditions into account. If the sequence contains data that isn’t described in a condition, the function skips them.

**Parameters**

- `pattern` — Pattern string. See [Pattern syntax].

**Returned values**

- 1, if the pattern is matched.
- 0, if the pattern isn’t matched.

Type: `UInt8`.


**Pattern syntax**

- `(?N)` — Matches the condition argument at position `N`. Conditions are numbered in the `[1, 32]` range. For example, `(?1)` matches the argument passed to the `cond1` parameter.
- `.*` — Matches any number of events. You do not need conditional arguments to match this element of the pattern.
- `(?t operator value)` — Sets the time in seconds that should separate two events. For example, pattern `(?1)(?t>1800)(?2)` matches events that occur more than 1800 seconds from each other. An arbitrary number of any events can lay between these events. You can use the `>=`, `>`, `<`, `<=`, `==` operators.

**Examples**

Consider data in the `t` table:

```
┌─time─┬─number─┐
│    1 │      1 │
│    2 │      3 │
│    3 │      2 │
└──────┴────────┘
```

Perform the query:

```
SELECT sequenceMatch((?1)(?2))(time, number = 1, number = 2) FROM t
┌─sequenceMatch((?1)(?2))(time, equals(number, 1), equals(number, 2))─┐
│                                                                     1 │
└───────────────────────────────────────────────────────────────────────┘
```

The function found the event chain where number 2 follows number 1. It skipped number 3 between them, because the number is not described as an event. If we want to take this number into account when searching for the event chain given in the example, we should make a condition for it.

```
SELECT sequenceMatch((?1)(?2))(time, number = 1, number = 2, number = 3) FROM t┌─sequenceMatch((?1)(?2))(time, equals(number, 1), equals(number, 2), equals(number, 3))─┐│                                                                                        0 │└──────────────────────────────────────────────────────────────────────────────────────────┘
```

In this case, the function couldn’t find the event chain matching the pattern, because the event for number 3 occured between 1 and 2. If in the same case we checked the condition for number 4, the sequence would match the pattern.

```
SELECT sequenceMatch((?1)(?2))(time, number = 1, number = 2, number = 4) FROM t┌─sequenceMatch((?1)(?2))(time, equals(number, 1), equals(number, 2), equals(number, 4))─┐│                                                                                        1 │└──────────────────────────────────────────────────────────────────────────────────────────┘
```

**See Also**

- [sequenceCount]

## sequenceCount(pattern)(time, cond1, cond2, …)

Counts the number of event chains that matched the pattern. The function searches event chains that do not overlap. It starts to search for the next chain after the current chain is matched.

Warning

Events that occur at the same second may lay in the sequence in an undefined order affecting the result.

```
sequenceCount(pattern)(timestamp, cond1, cond2, ...)
```

**Arguments**

- `timestamp` — Column considered to contain time data. Typical data types are `Date` and `DateTime`. You can also use any of the supported [UInt] data types.
- `cond1`, `cond2` — Conditions that describe the chain of events. Data type: `UInt8`. You can pass up to 32 condition arguments. The function takes only the events described in these conditions into account. If the sequence contains data that isn’t described in a condition, the function skips them.

**Parameters**

- `pattern` — Pattern string. See [Pattern syntax].

**Returned values**

- Number of non-overlapping event chains that are matched.

Type: `UInt64`.

**Example**

Consider data in the `t` table:

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

Count how many times the number 2 occurs after the number 1 with any amount of other numbers between them:

```
SELECT sequenceCount(''(?1).*(?2)'')(time, number = 1, number = 2) FROM t
┌─sequenceCount(''(?1).*(?2)'')(time, equals(number, 1), equals(number, 2))─┐
│                                                                       2 │
└─────────────────────────────────────────────────────────────────────────┘
```

**See Also**

- sequenceMatch

## windowFunnel

Searches for event chains in a sliding time window and calculates the maximum number of events that occurred from the chain.

The function works according to the algorithm:

- The function searches for data that triggers the first condition in the chain and sets the event counter to 1. This is the moment when the sliding window starts.
- If events from the chain occur sequentially within the window, the counter is incremented. If the sequence of events is disrupted, the counter isn’t incremented.
- If the data has multiple event chains at varying points of completion, the function will only output the size of the longest chain.

**Syntax**

```
windowFunnel(window, [mode, [mode, ... ]])(timestamp, cond1, cond2, ..., condN)
```

**Arguments**

- `timestamp` — Name of the column containing the timestamp. Data types supported: [Date], [DateTime] and other unsigned integer types (note that even though timestamp supports the `UInt64` type, it’s value can’t exceed the Int64 maximum, which is 2^63 - 1).
- `cond` — Conditions or data describing the chain of events. [UInt8].

**Parameters**

- `window` — Length of the sliding window, it is the time interval between the first and the last condition. The unit of `window` depends on the `timestamp` itself and varies. Determined using the expression `timestamp of cond1 <= timestamp of cond2 <= ... <= timestamp of condN <= timestamp of cond1 + window`.

- ```
  mode
  ```



  — It is an optional argument. One or more modes can be set.

  - `strict` — If same condition holds for sequence of events then such non-unique events would be skipped.
  - `strict_order` — Dont allow interventions of other events. E.g. in the case of `A->B->D->C`, it stops finding `A->B->C` at the `D` and the max event level is 2.
  - `strict_increase` — Apply conditions only to events with strictly increasing timestamps.

**Returned value**

The maximum number of consecutive triggered conditions from the chain within the sliding time window.
All the chains in the selection are analyzed.

Type: `Integer`.

**Example**

Determine if a set period of time is enough for the user to select a phone and purchase it twice in the online store.

Set the following chain of events:

1. The user logged in to their account on the store (`eventID = 1003`).
2. The user searches for a phone (`eventID = 1007, product = phone`).
3. The user placed an order (`eventID = 1009`).
4. The user made the order again (`eventID = 1010`).

Input table:

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

Find out how far the user `user_id` could get through the chain in a period in January-February of 2019.

Query:

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

Result:

```
┌─level─┬─c─┐
│     4 │ 1 │
└───────┴───┘
```

## retention

The function takes as arguments a set of conditions from 1 to 32 arguments of type `UInt8` that indicate whether a certain condition was met for the event.
Any condition can be specified as an argument (as in [WHERE]).

The conditions, except the first, apply in pairs: the result of the second will be true if the first and second are true, of the third if the first and third are true, etc.

**Syntax**

```
retention(cond1, cond2, ..., cond32);
```

**Arguments**

- `cond` — An expression that returns a `UInt8` result (1 or 0).

**Returned value**

The array of 1 or 0.

- 1 — Condition was met for the event.
- 0 — Condition wasn’t met for the event.

Type: `UInt8`.

**Example**

Let’s consider an example of calculating the `retention` function to determine site traffic.

**1.** Сreate a table to illustrate an example.

```
CREATE TABLE retention_test(date Date, uid Int32) ENGINE = Memory;INSERT INTO retention_test SELECT 2020-01-01, number FROM numbers(5);INSERT INTO retention_test SELECT 2020-01-02, number FROM numbers(10);INSERT INTO retention_test SELECT 2020-01-03, number FROM numbers(15);
```

Input table:

Query:

```
SELECT * FROM retention_test
```

Result:

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

**2.** Group users by unique ID `uid` using the `retention` function.

Query:

```
SELECT
    uid,
    retention(date = ''2020-01-01'', date = ''2020-01-02'', date = ''2020-01-03'') AS r
FROM retention_test
WHERE date IN (''2020-01-01'', ''2020-01-02'', ''2020-01-03'')
GROUP BY uid
ORDER BY uid ASC
```

Result:

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

**3.** Calculate the total number of site visits per day.

Query:

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

Result:

```
┌─r1─┬─r2─┬─r3─┐
│  5 │  5 │  5 │
└────┴────┴────┘
```

Where:

- `r1`- the number of unique visitors who visited the site during 2020-01-01 (the `cond1` condition).
- `r2`- the number of unique visitors who visited the site during a specific time period between 2020-01-01 and 2020-01-02 (`cond1` and `cond2` conditions).
- `r3`- the number of unique visitors who visited the site during a specific time period between 2020-01-01 and 2020-01-03 (`cond1` and `cond3` conditions).

## uniqUpTo(N)(x)

Calculates the number of different argument values if it is less than or equal to N. If the number of different argument values is greater than N, it returns N + 1.

Recommended for use with small Ns, up to 10. The maximum value of N is 100.

For the state of an aggregate function, it uses the amount of memory equal to 1 + N * the size of one value of bytes.
For strings, it stores a non-cryptographic hash of 8 bytes. That is, the calculation is approximated for strings.

The function also works for several arguments.

It works as fast as possible, except for cases when a large N value is used and the number of unique values is slightly less than N.

Usage example:

```
Problem: Generate a report that shows only keywords that produced at least 5 unique users.Solution: Write in the GROUP BY query SearchPhrase HAVING uniqUpTo(4)(UserID) >= 5
```

## sumMapFiltered(keys_to_keep)(keys, values)

Same behavior as [sumMap] except that an array of keys is passed as a parameter. This can be especially useful when working with a high cardinality of keys.' where id=54;
update biz_data_query_model_help_content set content_en = '# Aggregate Function Combinators

The name of an aggregate function can have a suffix appended to it. This changes the way the aggregate function works.

## -If

The suffix -If can be appended to the name of any aggregate function. In this case, the aggregate function accepts an extra argument – a condition (Uint8 type). The aggregate function processes only the rows that trigger the condition. If the condition was not triggered even once, it returns a default value (usually zeros or empty strings).

Examples: `sumIf(column, cond)`, `countIf(cond)`, `avgIf(x, cond)`, `quantilesTimingIf(level1, level2)(x, cond)`, `argMinIf(arg, val, cond)` and so on.

With conditional aggregate functions, you can calculate aggregates for several conditions at once, without using subqueries and `JOIN`s. For example, in Yandex.Metrica, conditional aggregate functions are used to implement the segment comparison functionality.

## -Array

The -Array suffix can be appended to any aggregate function. In this case, the aggregate function takes arguments of the ‘Array(T)’ type (arrays) instead of ‘T’ type arguments. If the aggregate function accepts multiple arguments, this must be arrays of equal lengths. When processing arrays, the aggregate function works like the original aggregate function across all array elements.

Example 1: `sumArray(arr)` - Totals all the elements of all ‘arr’ arrays. In this example, it could have been written more simply: `sum(arraySum(arr))`.

Example 2: `uniqArray(arr)` – Counts the number of unique elements in all ‘arr’ arrays. This could be done an easier way: `uniq(arrayJoin(arr))`, but it’s not always possible to add ‘arrayJoin’ to a query.

-If and -Array can be combined. However, ‘Array’ must come first, then ‘If’. Examples: `uniqArrayIf(arr, cond)`, `quantilesTimingArrayIf(level1, level2)(arr, cond)`. Due to this order, the ‘cond’ argument won’t be an array.

## -SimpleState

If you apply this combinator, the aggregate function returns the same value but with a different type. This is a [SimpleAggregateFunction(...)] that can be stored in a table to work with [AggregatingMergeTree] tables.

**Syntax**

```
<aggFunction>SimpleState(x)
```

**Arguments**

- `x` — Aggregate function parameters.

**Returned values**

The value of an aggregate function with the `SimpleAggregateFunction(...)` type.

**Example**

Query:

```
WITH anySimpleState(number) AS c SELECT toTypeName(c), c FROM numbers(1);
```

Result:

```
┌─toTypeName(c)────────────────────────┬─c─┐
│ SimpleAggregateFunction(any, UInt64) │ 0 │
└──────────────────────────────────────┴───┘
```

## -State

If you apply this combinator, the aggregate function does not return the resulting value (such as the number of unique values for the [uniq] function), but an intermediate state of the aggregation (for `uniq`, this is the hash table for calculating the number of unique values). This is an `AggregateFunction(...)` that can be used for further processing or stored in a table to finish aggregating later.

To work with these states, use:

- [AggregatingMergeTree] table engine.
- [finalizeAggregation] function.
- [runningAccumulate] function.
- [-Merge] combinator.
- [-MergeState] combinator.

## -Merge

If you apply this combinator, the aggregate function takes the intermediate aggregation state as an argument, combines the states to finish aggregation, and returns the resulting value.

## -MergeState

Merges the intermediate aggregation states in the same way as the -Merge combinator. However, it does not return the resulting value, but an intermediate aggregation state, similar to the -State combinator.

## -ForEach

Converts an aggregate function for tables into an aggregate function for arrays that aggregates the corresponding array items and returns an array of results. For example, `sumForEach` for the arrays `[1, 2]`, `[3, 4, 5]`and`[6, 7]`returns the result `[10, 13, 5]` after adding together the corresponding array items.

## -Distinct

Every unique combination of arguments will be aggregated only once. Repeating values are ignored.
Examples: `sum(DISTINCT x)`, `groupArray(DISTINCT x)`, `corrStableDistinct(DISTINCT x, y)` and so on.

## -OrDefault

Changes behavior of an aggregate function.

If an aggregate function does not have input values, with this combinator it returns the default value for its return data type. Applies to the aggregate functions that can take empty input data.

`-OrDefault` can be used with other combinators.

**Syntax**

```
<aggFunction>OrDefault(x)
```

**Arguments**

- `x` — Aggregate function parameters.

**Returned values**

Returns the default value of an aggregate function’s return type if there is nothing to aggregate.

Type depends on the aggregate function used.

**Example**

Query:

```
SELECT avg(number), avgOrDefault(number) FROM numbers(0)
```

Result:

```
┌─avg(number)─┬─avgOrDefault(number)─┐
│         nan │                    0 │
└─────────────┴──────────────────────┘
```

Also `-OrDefault` can be used with another combinators. It is useful when the aggregate function does not accept the empty input.

Query:

```
SELECT avgOrDefaultIf(x, x > 10)
FROM
(
    SELECT toDecimal32(1.23, 2) AS x
)
```

Result:

```
┌─avgOrDefaultIf(x, greater(x, 10))─┐
│                              0.00 │
└───────────────────────────────────┘
```

## -OrNull

Changes behavior of an aggregate function.

This combinator converts a result of an aggregate function to the [Nullable] data type. If the aggregate function does not have values to calculate it returns [NULL].

`-OrNull` can be used with other combinators.

**Syntax**

```
<aggFunction>OrNull(x)
```

**Arguments**

- `x` — Aggregate function parameters.

**Returned values**

- The result of the aggregate function, converted to the `Nullable` data type.
- `NULL`, if there is nothing to aggregate.

Type: `Nullable(aggregate function return type)`.

**Example**

Add `-orNull` to the end of aggregate function.

Query:

```
SELECT sumOrNull(number), toTypeName(sumOrNull(number)) FROM numbers(10) WHERE number > 10
```

Result:

```
┌─sumOrNull(number)─┬─toTypeName(sumOrNull(number))─┐
│              ᴺᵁᴸᴸ │ Nullable(UInt64)              │
└───────────────────┴───────────────────────────────┘
```

Also `-OrNull` can be used with another combinators. It is useful when the aggregate function does not accept the empty input.

Query:

```
SELECT avgOrNullIf(x, x > 10)
FROM
(
    SELECT toDecimal32(1.23, 2) AS x
)
```

Result:

```
┌─avgOrNullIf(x, greater(x, 10))─┐
│                           ᴺᵁᴸᴸ │
└────────────────────────────────┘
```

## -Resample

Lets you divide data into groups, and then separately aggregates the data in those groups. Groups are created by splitting the values from one column into intervals.

```
<aggFunction>Resample(start, end, step)(<aggFunction_params>, resampling_key)
```

**Arguments**

- `start` — Starting value of the whole required interval for `resampling_key` values.
- `stop` — Ending value of the whole required interval for `resampling_key` values. The whole interval does not include the `stop` value `[start, stop)`.
- `step` — Step for separating the whole interval into subintervals. The `aggFunction` is executed over each of those subintervals independently.
- `resampling_key` — Column whose values are used for separating data into intervals.
- `aggFunction_params` — `aggFunction` parameters.

**Returned values**

- Array of `aggFunction` results for each subinterval.

**Example**

Consider the `people` table with the following data:

```
┌─name───┬─age─┬─wage─┐
│ John   │  16 │   10 │
│ Alice  │  30 │   15 │
│ Mary   │  35 │    8 │
│ Evelyn │  48 │ 11.5 │
│ David  │  62 │  9.9 │
│ Brian  │  60 │   16 │
└────────┴─────┴──────┘
```

Let’s get the names of the people whose age lies in the intervals of `[30,60)` and `[60,75)`. Since we use integer representation for age, we get ages in the `[30, 59]` and `[60,74]` intervals.

To aggregate names in an array, we use the [groupArray] aggregate function. It takes one argument. In our case, it’s the `name` column. The `groupArrayResample` function should use the `age` column to aggregate names by age. To define the required intervals, we pass the `30, 75, 30` arguments into the `groupArrayResample` function.

```
SELECT groupArrayResample(30, 75, 30)(name, age) FROM people
┌─groupArrayResample(30, 75, 30)(name, age)─────┐
│ [[''Alice'',''Mary'',''Evelyn''],[''David'',''Brian'']] │
└───────────────────────────────────────────────┘
```

Consider the results.

`Jonh` is out of the sample because he’s too young. Other people are distributed according to the specified age intervals.

Now let’s count the total number of people and their average wage in the specified age intervals.

```
SELECT
    countResample(30, 75, 30)(name, age) AS amount,
    avgResample(30, 75, 30)(wage, age) AS avg_wage
FROM people
┌─amount─┬─avg_wage──────────────────┐
│ [3,2]  │ [11.5,12.949999809265137] │
└────────┴───────────────────────────┘
```

' where id=53;
update biz_data_query_model_help_content set content_en = '# quantileExact Functions

## quantileExact

Exactly computes the [quantile] of a numeric data sequence.

To get exact value, all the passed values are combined into an array, which is then partially sorted. Therefore, the function consumes `O(n)` memory, where `n` is a number of values that were passed. However, for a small number of values, the function is very effective.

When using multiple `quantile*` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the [quantiles] function.

**Syntax**

```
quantileExact(level)(expr)
```

Alias: `medianExact`.

**Arguments**

- `level` — Level of quantile. Optional parameter. Constant floating-point number from 0 to 1. We recommend using a `level` value in the range of `[0.01, 0.99]`. Default value: 0.5. At `level=0.5` the function calculates [median].
- `expr` — Expression over the column values resulting in numeric [data types], [Date] or [DateTime].

**Returned value**

- Quantile of the specified level.

Type:

- [Float64] for numeric data type input.
- [Date] if input values have the `Date` type.
- [DateTime] if input values have the `DateTime` type.

**Example**

Query:

```
SELECT quantileExact(number) FROM numbers(10)
```

Result:

```
┌─quantileExact(number)─┐
│                     5 │
└───────────────────────┘
```

## quantileExactLow

Similar to `quantileExact`, this computes the exact [quantile] of a numeric data sequence.

To get the exact value, all the passed values are combined into an array, which is then fully sorted. The sorting [algorithms] complexity is `O(N·log(N))`, where `N = std::distance(first, last)` comparisons.

The return value depends on the quantile level and the number of elements in the selection, i.e. if the level is 0.5, then the function returns the lower median value for an even number of elements and the middle median value for an odd number of elements. Median is calculated similarly to the [median_low] implementation which is used in python.

For all other levels, the element at the index corresponding to the value of `level * size_of_array` is returned. For example:

```
SELECT quantileExactLow(0.1)(number) FROM numbers(10)

┌─quantileExactLow(0.1)(number)─┐
│                             1 │
└───────────────────────────────┘
```

When using multiple `quantile*` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the [quantiles] function.

**Syntax**

```
quantileExactLow(level)(expr)
```

Alias: `medianExactLow`.

**Arguments**

- `level` — Level of quantile. Optional parameter. Constant floating-point number from 0 to 1. We recommend using a `level` value in the range of `[0.01, 0.99]`. Default value: 0.5. At `level=0.5` the function calculates [median].
- `expr` — Expression over the column values resulting in numeric [data types], [Date] or [DateTime].

**Returned value**

- Quantile of the specified level.

Type:

- [Float64] for numeric data type input.
- [Date] if input values have the `Date` type.
- [DateTime] if input values have the `DateTime` type.

**Example**

Query:

```
SELECT quantileExactLow(number) FROM numbers(10)
```

Result:

```
┌─quantileExactLow(number)─┐
│                        4 │
└──────────────────────────┘
```

## quantileExactHigh

Similar to `quantileExact`, this computes the exact [quantile] of a numeric data sequence.

All the passed values are combined into an array, which is then fully sorted, to get the exact value. The sorting [algorithms] complexity is `O(N·log(N))`, where `N = std::distance(first, last)` comparisons.

The return value depends on the quantile level and the number of elements in the selection, i.e. if the level is 0.5, then the function returns the higher median value for an even number of elements and the middle median value for an odd number of elements. Median is calculated similarly to the [median_high] implementation which is used in python. For all other levels, the element at the index corresponding to the value of `level * size_of_array` is returned.

This implementation behaves exactly similar to the current `quantileExact` implementation.

When using multiple `quantile*` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the [quantiles] function.

**Syntax**

```
quantileExactHigh(level)(expr)
```

Alias: `medianExactHigh`.

**Arguments**

- `level` — Level of quantile. Optional parameter. Constant floating-point number from 0 to 1. We recommend using a `level` value in the range of `[0.01, 0.99]`. Default value: 0.5. At `level=0.5` the function calculates [median].
- `expr` — Expression over the column values resulting in numeric [data types], [Date] or [DateTime].

**Returned value**

- Quantile of the specified level.

Type:

- [Float64] for numeric data type input.
- [Date] if input values have the `Date` type.
- [DateTime] if input values have the `DateTime` type.

**Example**

Query:

```
SELECT quantileExactHigh(number) FROM numbers(10)
```

Result:

```
┌─quantileExactHigh(number)─┐
│                         5 │
└───────────────────────────┘
```

' where id=123;
update biz_data_query_model_help_content set content_en = '# SYSTEM Statements

The list of available `SYSTEM` statements:

-[RELOAD EMBEDDED DICTIONARIES]
-[RELOAD DICTIONARIES]
-[RELOAD DICTIONARY]
-[RELOAD MODELS]
-[RELOAD MODEL]
-[DROP DNSCACHE]
-[DROP MARKCACHE]
-[DROP UNCOMPRESSED CACHE]
-[DROP COMPILED EXPRESSION CACHE]
-[DROP REPLICA]
-[FLUSH LOGS]
-[RELOAD CONFIG]
-[SHUTDOWN]
-[KILL]
-[STOP DISTRIBUTED SENDS]
-[FLUSH DISTRIBUTED]
-[STOP MERGES]
-[START MERGES]
-[STOP TTL MERGES]
-[START TTL MERGES]
-[STOP MOVES]
-[START MOVES]
-[STOP FETCHES]
-[START FETCHES]
-[START REPLICATED SENDS]
-[STOP REPLICATION QUEUES]
-[SYNC REPLICA]
-[RESTART REPLICA]
-[RESTORE REPLICA]
-[RESTART REPLICAS]

##RELOAD EMBEDDEDD ICTIONARIES

Reload all [Internal dictionaries].
By default, internal dictionaries are disabled.
Always returns `Ok.` regardless of the result of the internal dictionary update.

##RELOADDICTIONARIES

Reloads all dictionaries that have been successfully loaded before.
By default, dictionaries are loaded lazily (see [dictionaries_lazy_load], so instead of being loaded automatically at startup, they are initialized on first access through dictGet function or SELECT from tables with ENGINE = Dictionary. The `SYSTEM RELOAD DICTIONARIES` query reloads such dictionaries (LOADED).
Always returns `Ok.` regardless of the result of the dictionary update.

##RELOADDICTIONARY

Completely reloads a dictionary `dictionary_name`, regardless of the state of the dictionary (LOADED / NOT_LOADED / FAILED).
Always returns `Ok.` regardless of the result of updating the dictionary.
The status of the dictionary can be checked by querying the `system.dictionaries` table.

```
SELECT name, status FROM system.dictionaries;
```

##RELOAD MODELS

Reloads all [CatBoost]models if the configuration was updated without restarting the server.

**Syntax**

```
SYSTEM RELOAD MODELS
```

##RELOAD MODEL

Completely reloads a CatBoost model `model_name` if the configuration was updated without restarting the server.

**Syntax**

```
SYSTEM RELOAD MODEL <model_name>
```

##DROP DNS CACHE

Resets ClickHouse’s internal DNS cache. Sometimes (for old ClickHouse versions) it is necessary to use this command when changing the infrastructure (changing the IP address of another ClickHouse server or the server used by dictionaries).

For more convenient (automatic) cache management, see disable_internal_dns_cache, dns_cache_update_period parameters.

##DROP MARK CACHE

Resets the mark cache. Used in development of ClickHouse and performance tests.

##DROP REPLICA

Dead replicas can be dropped using following syntax:

```
SYSTEM DROP REPLICA ''replica_name'' FROM TABLE database.table;
SYSTEM DROP REPLICA ''replica_name'' FROM DATABASE database;
SYSTEM DROP REPLICA ''replica_name'';
SYSTEM DROP REPLICA ''replica_name'' FROM ZKPATH ''/path/to/table/in/zk'';
```

Queries will remove the replica path in ZooKeeper. It is useful when the replica is dead and its metadata cannot be removed from ZooKeeper by `DROP TABLE` because there is no such table anymore. It will only drop the inactive/stale replica, and it cannot drop local replica, please use `DROP TABLE` for that. `DROP REPLICA` does not drop any tables and does not remove any data or metadata from disk.

The first one removes metadata of `''replica_name''` replica of `database.table` table.
The second one does the same for all replicated tables in the database.
The third one does the same for all replicated tables on the local server.
The fourth one is useful to remove metadata of dead replica when all other replicas of a table were dropped. It requires the table path to be specified explicitly. It must be the same path as was passed to the first argument of `ReplicatedMergeTree` engine on table creation.

##DROP UNCOMPRESSED CACHE

Reset the uncompressed data cache. Used in development of ClickHouse and performance tests.
For manage uncompressed data cache parameters use following server level settings [uncompressed_cache_size] and query/user/profile level settings [use_uncompressed_cache]

##DROP COMPILED EXPRESSION CACHE

Reset the compiled expression cache. Used in development of ClickHouse and performance tests.
Compiled expression cache used when query/user/profile enable option [

##FLUSH LOGS

Flushes buffers of log messages to system tables (e.g. system.query_log). Allows you to not wait 7.5 seconds when debugging.
This will also create system tables even if message queue is empty.

##RELOAD CONFIG

Reloads ClickHouse configuration. Used when configuration is stored in ZooKeeeper.

##SHUTDOWN

Normally shuts down ClickHouse (like `service clickhouse-server stop` / `kill {$pid_clickhouse-server}`)

##KILL

Aborts ClickHouse process (like `kill -9 {$ pid_clickhouse-server}`)

##Managing Distributed Tables

ClickHouse can manage tables. When a user inserts data into these tables, ClickHouse first creates a queue of the data that should be sent to cluster nodes, then asynchronously sends it. You can manage queue processing with the [STOP DISTRIBUTED SENDS], [FLUSH DISTRIBUTED], and [START DISTRIBUTED SENDS] queries. You can also synchronously insert distributed data with the [insert_distributed_sync] setting.

###STOP DISTRIBUTED SENDS

Disables background data distribution when inserting data into distributed tables.

```
SYSTEM STOP DISTRIBUTED SENDS [db.]<distributed_table_name>
```

###FLUSH DISTRIBUTED

Forces ClickHouse to send data to cluster nodes synchronously. If any nodes are unavailable, ClickHouse throws an exception and stops query execution. You can retry the query until it succeeds, which will happen when all nodes are back online.

```
SYSTEM FLUSH DISTRIBUTED [db.]<distributed_table_name>
```

###START DISTRIBUTED SENDS

Enables background data distribution when inserting data into distributed tables.

```
SYSTEM START DISTRIBUTED SENDS [db.]<distributed_table_name>
```

##Managing MergeTree Tables

ClickHouse can manage background processes in [MergeTree] tables.

###STOP MERGES

Provides possibility to stop background merges for tables in the MergeTree family:

```
SYSTEM STOP MERGES [ON VOLUME <volume_name> | [db.]merge_tree_family_table_name]
```

Note

`DETACH / ATTACH` table will start background merges for the table even in case when merges have been stopped for all MergeTree tables before.

###START MERGES

Provides possibility to start background merges for tables in the MergeTree family:

```
SYSTEM START MERGES [ON VOLUME <volume_name> | [db.]merge_tree_family_table_name]
```

###STOP TTL MERGES

Provides possibility to stop background delete old data according to [TTL expression]for tables in the MergeTree family:
Returns `Ok.` even if table does not exist or table has not MergeTree engine. Returns error when database does not exist:

```
SYSTEM STOP TTL MERGES [[db.]merge_tree_family_table_name]
```

###START TTL MERGES

Provides possibility to stop background delete old data according to [TTL expression] for tables in the MergeTree family:
Returns `Ok.` even if table does not exist or table has not MergeTree engine. Returns error when database does not exist:

```
SYSTEM START TTL MERGES [[db.]merge_tree_family_table_name]
```

###STOP MOVES

Provides possibility to stop background move data according to [TTL table expression with TO VOLUME or TO DISK clause] for tables in the MergeTree family:
Returns `Ok.` even if table does not exist. Returns error when database does not exist:

```
SYSTEM STOP MOVES [[db.]merge_tree_family_table_name]
```

###START MOVES

Provides possibility to start background move data according to [TTL table expression with TO VOLUME and TO DISK clause for tables in the MergeTree family:
Returns `Ok.` even if table does not exist. Returns error when database does not exist:

```
SYSTEM START MOVES [[db.]merge_tree_family_table_name]SYSTEMSTARTMOVES[[db.]merge_tree_family_table_name]
```

##Managing ReplicatedMergeTree Tables

ClickHouse can manage background replication related processes in [ReplicatedMergeTree] tables.

###STOP FETCHES

Provides possibility to stop background fetches for inserted parts for tables in the `ReplicatedMergeTree` family:
Always returns `Ok.` regardless of the table engine and even if table or database does not exist.

```
SYSTEM STOP FETCHES [[db.]replicated_merge_tree_family_table_name]
```

###START FETCHES

Provides possibility to start background fetches for inserted parts for tables in the `ReplicatedMergeTree` family:
Always returns `Ok.` regardless of the table engine and even if table or database does not exist.

```
SYSTEM START FETCHES [[db.]replicated_merge_tree_family_table_name]
```

###STOP REPLICATED SENDS

Provides possibility to stop background sends to other replicas in cluster for new inserted parts for tables in the `ReplicatedMergeTree` family:

```
SYSTEMSTOPREPLICATEDSENDS[[db.]replicated_merge_tree_family_table_name]
```

###START REPLICATED SENDS

Provides possibility to start background sends to other replicas in cluster for new inserted parts for tables in the `ReplicatedMergeTree` family:

```
SYSTEM STOP REPLICATED SENDS [[db.]replicated_merge_tree_family_table_name]
```

###STOP REPLICATION QUEUES

Provides possibility to stop background fetch tasks from replication queues which stored in Zookeeper for tables in the `ReplicatedMergeTree` family. Possible background tasks types - merges, fetches, mutation, DDL statements with ON CLUSTER clause::

```
SYSTEM STOP REPLICATION QUEUES [[db.]replicated_merge_tree_family_table_name]
```

###START REPLICATION QUEUES

Provides possibility to start background fetch tasks from replication queues which stored in Zookeeper for tables in the `ReplicatedMergeTree` family. Possible background tasks types - merges, fetches, mutation, DDL statements with ON CLUSTER clause:

```
SYSTEM START REPLICATION QUEUES [[db.]replicated_merge_tree_family_table_name]
```

###SYNC REPLICA

Wait until a `ReplicatedMergeTree` table will be synced with other replicas in a cluster. Will run until `receive_timeout` if fetches currently disabled for the table.

```
SYSTEM SYNC REPLICA [db.]replicated_merge_tree_family_table_name
```

After running this statement the `[db.]replicated_merge_tree_family_table_name` fetches commands from the common replicated log into its own replication queue, and then the query waits till the replica processes all of the fetched commands.

###RESTART REPLICA

Provides possibility to reinitialize Zookeeper sessions state for `ReplicatedMergeTree` table, will compare current state with Zookeeper as source of true and add tasks to Zookeeper queue if needed.
Initialization replication queue based on ZooKeeper date happens in the same way as `ATTACH TABLE` statement. For a short time the table will be unavailable for any operations.

```
SYSTEM RESTART REPLICA [db.]replicated_merge_tree_family_table_name
```

###RESTO REREPLICA

Restores a replica if data is [possibly] present but Zookeeper metadata is lost.

Works only on readonly `ReplicatedMergeTree` tables.

One may execute query after:

- ZooKeeper root `/` loss.
- Replicas path `/replicas` loss.
- Individual replica path `/replicas/replica_name/` loss.

Replica attaches locally found parts and sends info about them to Zookeeper.
Parts present on replica before metadata loss are not re-fetched from other replicas if not being outdated
(so replica restoration does not mean re-downloading all data over the network).

Caveat: parts in all states are moved to `detached/` folder. Parts active before data loss (Committed) are attached.

####Syntax

```
SYSTEM RESTORE REPLICA [db.]replicated_merge_tree_family_table_name [ON CLUSTER cluster_name]
```

Alternative syntax:

```
SYSTEM RESTORE REPLICA [ON CLUSTER cluster_name] [db.]replicated_merge_tree_family_table_name
```

####Example

```
-- Creating table on multiple servers

CREATE TABLE test(n UInt32)
ENGINE = ReplicatedMergeTree(''/clickhouse/tables/test/'', ''{replica}'')
ORDER BY n PARTITION BY n % 10;

INSERT INTO test SELECT * FROM numbers(1000);

-- zookeeper_delete_path("/clickhouse/tables/test", recursive=True) <- root loss.

SYSTEM RESTART REPLICA test; -- Table will attach as readonly as metadata is missing.
SYSTEM RESTORE REPLICA test; -- Need to execute on every replica, another way: RESTORE REPLICA test ON CLUSTER cluster
```

###RESTART REPLICAS

Provides possibility to reinitialize Zookeeper sessions state for all `ReplicatedMergeTree` tables, will compare current state with Zookeeper as source of true and add tasks to Zookeeper queue if needed

' where id=11;
update biz_data_query_model_help_content set content_en = '# GRANT Statement

- Grants [privileges] to ClickHouse user accounts or roles.
- Assigns roles to user accounts or to the other roles.

To revoke privileges, use the [REVOKE] statement. Also you can list granted privileges with the [SHOW GRANTS] statement.

## Granting Privilege Syntax

```
GRANT [ON CLUSTER cluster_name] privilege[(column_name [,...])] [,...] ON {db.table|db.*|*.*|table|*} TO {user | role | CURRENT_USER} [,...] [WITH GRANT OPTION]
```

- `privilege` — Type of privilege.
- `role` — ClickHouse user role.
- `user` — ClickHouse user account.

The `WITH GRANT OPTION` clause grants `user` or `role` with permission to execute the `GRANT` query. Users can grant privileges of the same scope they have and less.

## Assigning Role Syntax

```
GRANT [ON CLUSTER cluster_name] role [,...] TO {user | another_role | CURRENT_USER} [,...] [WITH ADMIN OPTION]
```

- `role` — ClickHouse user role.
- `user` — ClickHouse user account.

The `WITH ADMIN OPTION` clause grants [ADMIN OPTION] privilege to `user` or `role`.

## Usage

To use `GRANT`, your account must have the `GRANT OPTION` privilege. You can grant privileges only inside the scope of your account privileges.

For example, administrator has granted privileges to the `john` account by the query:

```
GRANT SELECT(x,y) ON db.table TO john WITH GRANT OPTION
```

It means that `john` has the permission to execute:

- `SELECT x,y FROM db.table`.
- `SELECT x FROM db.table`.
- `SELECT y FROM db.table`.

`john` can’t execute `SELECT z FROM db.table`. The `SELECT * FROM db.table` also is not available. Processing this query, ClickHouse does not return any data, even `x` and `y`. The only exception is if a table contains only `x` and `y` columns. In this case ClickHouse returns all the data.

Also `john` has the `GRANT OPTION` privilege, so it can grant other users with privileges of the same or smaller scope.

Specifying privileges you can use asterisk (`*`) instead of a table or a database name. For example, the `GRANT SELECT ON db.* TO john` query allows `john` to execute the `SELECT` query over all the tables in `db` database. Also, you can omit database name. In this case privileges are granted for current database. For example, `GRANT SELECT ON * TO john` grants the privilege on all the tables in the current database, `GRANT SELECT ON mytable TO john` grants the privilege on the `mytable` table in the current database.

Access to the `system` database is always allowed (since this database is used for processing queries).

You can grant multiple privileges to multiple accounts in one query. The query `GRANT SELECT, INSERT ON *.* TO john, robin` allows accounts `john` and `robin` to execute the `INSERT` and `SELECT` queries over all the tables in all the databases on the server.

## Privileges

Privilege is a permission to execute specific kind of queries.

Privileges have a hierarchical structure. A set of permitted queries depends on the privilege scope.

Hierarchy of privileges:

- [SELECT]

- [INSERT]

- ALTER

  - ```
    ALTER TABLE
    ```

    - `ALTER UPDATE`

    - `ALTER DELETE`

    - ```
      ALTER COLUMN
      ```

      - `ALTER ADD COLUMN`
      - `ALTER DROP COLUMN`
      - `ALTER MODIFY COLUMN`
      - `ALTER COMMENT COLUMN`
      - `ALTER CLEAR COLUMN`
      - `ALTER RENAME COLUMN`

    - ```
      ALTER INDEX
      ```

      - `ALTER ORDER BY`
      - `ALTER SAMPLE BY`
      - `ALTER ADD INDEX`
      - `ALTER DROP INDEX`
      - `ALTER MATERIALIZE INDEX`
      - `ALTER CLEAR INDEX`

    - ```
      ALTER CONSTRAINT
      ```

      - `ALTER ADD CONSTRAINT`
      - `ALTER DROP CONSTRAINT`

    - ```
      ALTER TTL
      ```

      - `ALTER MATERIALIZE TTL`

    - `ALTER SETTINGS`

    - `ALTER MOVE PARTITION`

    - `ALTER FETCH PARTITION`

    - `ALTER FREEZE PARTITION`

  - ```
    ALTER VIEW
    ```

    - `ALTER VIEW REFRESH`
    - `ALTER VIEW MODIFY QUERY`

- CREATE

  - `CREATE DATABASE`

  - ```
    CREATE TABLE
    ```

    - `CREATE TEMPORARY TABLE`

  - `CREATE VIEW`

  - `CREATE DICTIONARY`

- DROP

  - `DROP DATABASE`
  - `DROP TABLE`
  - `DROP VIEW`
  - `DROP DICTIONARY`

- [TRUNCATE]

- [OPTIMIZE]

- SHOW

  - `SHOW DATABASES`
  - `SHOW TABLES`
  - `SHOW COLUMNS`
  - `SHOW DICTIONARIES`

- [KILL QUERY]

- ACCESS MANAGEMENT

  - `CREATE USER`

  - `ALTER USER`

  - `DROP USER`

  - `CREATE ROLE`

  - `ALTER ROLE`

  - `DROP ROLE`

  - `CREATE ROW POLICY`

  - `ALTER ROW POLICY`

  - `DROP ROW POLICY`

  - `CREATE QUOTA`

  - `ALTER QUOTA`

  - `DROP QUOTA`

  - `CREATE SETTINGS PROFILE`

  - `ALTER SETTINGS PROFILE`

  - `DROP SETTINGS PROFILE`

  - ```
    SHOW ACCESS
    ```

    - `SHOW_USERS`
    - `SHOW_ROLES`
    - `SHOW_ROW_POLICIES`
    - `SHOW_QUOTAS`
    - `SHOW_SETTINGS_PROFILES`

  - `ROLE ADMIN`

- SYSTEM

  - `SYSTEM SHUTDOWN`

  - ```
    SYSTEM DROP CACHE
    ```

    - `SYSTEM DROP DNS CACHE`
    - `SYSTEM DROP MARK CACHE`
    - `SYSTEM DROP UNCOMPRESSED CACHE`

  - ```
    SYSTEM RELOAD
    ```

    - `SYSTEM RELOAD CONFIG`

    - ```
      SYSTEM RELOAD DICTIONARY
      ```

      - `SYSTEM RELOAD EMBEDDED DICTIONARIES`

  - `SYSTEM MERGES`

  - `SYSTEM TTL MERGES`

  - `SYSTEM FETCHES`

  - `SYSTEM MOVES`

  - ```
    SYSTEM SENDS
    ```

    - `SYSTEM DISTRIBUTED SENDS`
    - `SYSTEM REPLICATED SENDS`

  - `SYSTEM REPLICATION QUEUES`

  - `SYSTEM SYNC REPLICA`

  - `SYSTEM RESTART REPLICA`

  - ```
    SYSTEM FLUSH
    ```

    - `SYSTEM FLUSH DISTRIBUTED`
    - `SYSTEM FLUSH LOGS`

- INTROSPECTION

  - `addressToLine`
  - `addressToSymbol`
  - `demangle`

- SOURCES

  - `FILE`
  - `URL`
  - `REMOTE`
  - `YSQL`
  - `ODBC`
  - `JDBC`
  - `HDFS`
  - `S3`

- [dictGet]

Examples of how this hierarchy is treated:

- The `ALTER` privilege includes all other `ALTER*` privileges.
- `ALTER CONSTRAINT` includes `ALTER ADD CONSTRAINT` and `ALTER DROP CONSTRAINT` privileges.

Privileges are applied at different levels. Knowing of a level suggests syntax available for privilege.

Levels (from lower to higher):

- `COLUMN` — Privilege can be granted for column, table, database, or globally.
- `TABLE` — Privilege can be granted for table, database, or globally.
- `VIEW` — Privilege can be granted for view, database, or globally.
- `DICTIONARY` — Privilege can be granted for dictionary, database, or globally.
- `DATABASE` — Privilege can be granted for database or globally.
- `GLOBAL` — Privilege can be granted only globally.
- `GROUP` — Groups privileges of different levels. When `GROUP`-level privilege is granted, only that privileges from the group are granted which correspond to the used syntax.

Examples of allowed syntax:

- `GRANT SELECT(x) ON db.table TO user`
- `GRANT SELECT ON db.* TO user`

Examples of disallowed syntax:

- `GRANT CREATE USER(x) ON db.table TO user`
- `GRANT CREATE USER ON db.* TO user`

The special privilege [ALL] grants all the privileges to a user account or a role.

By default, a user account or a role has no privileges.

If a user or a role has no privileges, it is displayed as [NONE] privilege.

Some queries by their implementation require a set of privileges. For example, to execute the [RENAME] query you need the following privileges: `SELECT`, `CREATE TABLE`, `INSERT` and `DROP TABLE`.

### SELECT

Allows executing [SELECT] queries.

Privilege level: `COLUMN`.

**Description**

User granted with this privilege can execute `SELECT` queries over a specified list of columns in the specified table and database. If user includes other columns then specified a query returns no data.

Consider the following privilege:

```
GRANT SELECT(x,y) ON db.table TO john
```

This privilege allows `john` to execute any `SELECT` query that involves data from the `x` and/or `y` columns in `db.table`, for example, `SELECT x FROM db.table`. `john` can’t execute `SELECT z FROM db.table`. The `SELECT * FROM db.table` also is not available. Processing this query, ClickHouse does not return any data, even `x` and `y`. The only exception is if a table contains only `x` and `y` columns, in this case ClickHouse returns all the data.

### INSERT

Allows executing [INSERT] queries.

Privilege level: `COLUMN`.

**Description**

User granted with this privilege can execute `INSERT` queries over a specified list of columns in the specified table and database. If user includes other columns then specified a query does not insert any data.

**Example**

```
GRANT INSERT(x,y) ON db.table TO john
```

The granted privilege allows `john` to insert data to the `x` and/or `y` columns in `db.table`.

### ALTER

Allows executing [ALTER] queries according to the following hierarchy of privileges:

- ```
  ALTER
  ```

  . Level:



  ```
COLUMN
  ```

  .

  - ```
    ALTER TABLE
    ```

    . Level:



    ```
    GROUP
    ```

    - `ALTER UPDATE`. Level: `COLUMN`. Aliases: `UPDATE`

    - `ALTER DELETE`. Level: `COLUMN`. Aliases: `DELETE`

    - ```
      ALTER COLUMN
      ```

      . Level:



      ```
      GROUP
      ```

      - `ALTER ADD COLUMN`. Level: `COLUMN`. Aliases: `ADD COLUMN`
      - `ALTER DROP COLUMN`. Level: `COLUMN`. Aliases: `DROP COLUMN`
      - `ALTER MODIFY COLUMN`. Level: `COLUMN`. Aliases: `MODIFY COLUMN`
      - `ALTER COMMENT COLUMN`. Level: `COLUMN`. Aliases: `COMMENT COLUMN`
      - `ALTER CLEAR COLUMN`. Level: `COLUMN`. Aliases: `CLEAR COLUMN`
      - `ALTER RENAME COLUMN`. Level: `COLUMN`. Aliases: `RENAME COLUMN`

    - ```
      ALTER INDEX
      ```

      . Level:



      ```
      GROUP
      ```

      . Aliases:



      ```
      INDEX
      ```

      - `ALTER ORDER BY`. Level: `TABLE`. Aliases: `ALTER MODIFY ORDER BY`, `MODIFY ORDER BY`
      - `ALTER SAMPLE BY`. Level: `TABLE`. Aliases: `ALTER MODIFY SAMPLE BY`, `MODIFY SAMPLE BY`
      - `ALTER ADD INDEX`. Level: `TABLE`. Aliases: `ADD INDEX`
      - `ALTER DROP INDEX`. Level: `TABLE`. Aliases: `DROP INDEX`
      - `ALTER MATERIALIZE INDEX`. Level: `TABLE`. Aliases: `MATERIALIZE INDEX`
      - `ALTER CLEAR INDEX`. Level: `TABLE`. Aliases: `CLEAR INDEX`

    - ```
      ALTER CONSTRAINT
      ```

      . Level:



      ```
      GROUP
      ```

      . Aliases:



      ```
      CONSTRAINT
      ```

      - `ALTER ADD CONSTRAINT`. Level: `TABLE`. Aliases: `ADD CONSTRAINT`
      - `ALTER DROP CONSTRAINT`. Level: `TABLE`. Aliases: `DROP CONSTRAINT`

    - ```
      ALTER TTL
      ```

      . Level:



      ```
      TABLE
      ```

      . Aliases:



      ```
      ALTER MODIFY TTL
      ```

      ,



      ```
      MODIFY TTL
      ```

      - `ALTER MATERIALIZE TTL`. Level: `TABLE`. Aliases: `MATERIALIZE TTL`

    - `ALTER SETTINGS`. Level: `TABLE`. Aliases: `ALTER SETTING`, `ALTER MODIFY SETTING`, `MODIFY SETTING`

    - `ALTER MOVE PARTITION`. Level: `TABLE`. Aliases: `ALTER MOVE PART`, `MOVE PARTITION`, `MOVE PART`

    - `ALTER FETCH PARTITION`. Level: `TABLE`. Aliases: `ALTER FETCH PART`, `FETCH PARTITION`, `FETCH PART`

    - `ALTER FREEZE PARTITION`. Level: `TABLE`. Aliases: `FREEZE PARTITION`

  - ```
    ALTER VIEW
    ```



    Level:



    ```
    GROUP
    ```

    - `ALTER VIEW REFRESH`. Level: `VIEW`. Aliases: `ALTER LIVE VIEW REFRESH`, `REFRESH VIEW`
    - `ALTER VIEW MODIFY QUERY`. Level: `VIEW`. Aliases: `ALTER TABLE MODIFY QUERY`

Examples of how this hierarchy is treated:

- The `ALTER` privilege includes all other `ALTER*` privileges.
- `ALTER CONSTRAINT` includes `ALTER ADD CONSTRAINT` and `ALTER DROP CONSTRAINT` privileges.

**Notes**

- The `MODIFY SETTING` privilege allows modifying table engine settings. It does not affect settings or server configuration parameters.
- The `ATTACH` operation needs the [CREATE] privilege.
- The `DETACH` operation needs the [DROP] privilege.
- To stop mutation by the [KILL MUTATION] query, you need to have a privilege to start this mutation. For example, if you want to stop the `ALTER UPDATE` query, you need the `ALTER UPDATE`, `ALTER TABLE`, or `ALTER` privilege.

### CREATE

Allows executing [CREATE] and [ATTACH] DDL-queries according to the following hierarchy of privileges:

- ```
  CREATE
  ```

  . Level:



  ```
GROUP
  ```

  - `CREATE DATABASE`. Level: `DATABASE`

  - ```
    CREATE TABLE
    ```

    . Level:



    ```
    TABLE
    ```

    - `CREATE TEMPORARY TABLE`. Level: `GLOBAL`

  - `CREATE VIEW`. Level: `VIEW`

  - `CREATE DICTIONARY`. Level: `DICTIONARY`

**Notes**

- To delete the created table, a user needs [DROP].

### DROP

Allows executing [DROP] and [DETACH] queries according to the following hierarchy of privileges:

- ```
  DROP
  ```

  . Level:



  ```
GROUP
  ```

  - `DROP DATABASE`. Level: `DATABASE`
  - `DROP TABLE`. Level: `TABLE`
  - `DROP VIEW`. Level: `VIEW`
  - `DROP DICTIONARY`. Level: `DICTIONARY`

### TRUNCATE

Allows executing [TRUNCATE] queries.

Privilege level: `TABLE`.

### OPTIMIZE

Allows executing [OPTIMIZE TABLE] queries.

Privilege level: `TABLE`.

### SHOW

Allows executing `SHOW`, `DESCRIBE`, `USE`, and `EXISTS` queries according to the following hierarchy of privileges:

- ```
  SHOW
  ```

  . Level:



  ```
GROUP
  ```

  - `SHOW DATABASES`. Level: `DATABASE`. Allows to execute `SHOW DATABASES`, `SHOW CREATE DATABASE`, `USE <database>` queries.
  - `SHOW TABLES`. Level: `TABLE`. Allows to execute `SHOW TABLES`, `EXISTS <table>`, `CHECK <table>` queries.
  - `SHOW COLUMNS`. Level: `COLUMN`. Allows to execute `SHOW CREATE TABLE`, `DESCRIBE` queries.
  - `SHOW DICTIONARIES`. Level: `DICTIONARY`. Allows to execute `SHOW DICTIONARIES`, `SHOW CREATE DICTIONARY`, `EXISTS <dictionary>` queries.

**Notes**

A user has the `SHOW` privilege if it has any other privilege concerning the specified table, dictionary or database.

### KILL QUERY

Allows executing [KILL] queries according to the following hierarchy of privileges:

Privilege level: `GLOBAL`.

**Notes**

`KILL QUERY` privilege allows one user to kill queries of other users.

### ACCESS MANAGEMENT

Allows a user to execute queries that manage users, roles and row policies.

- ```
  ACCESS MANAGEMENT
  ```

  . Level:



  ```
GROUP
  ```

  - `CREATE USER`. Level: `GLOBAL`

  - `ALTER USER`. Level: `GLOBAL`

  - `DROP USER`. Level: `GLOBAL`

  - `CREATE ROLE`. Level: `GLOBAL`

  - `ALTER ROLE`. Level: `GLOBAL`

  - `DROP ROLE`. Level: `GLOBAL`

  - `ROLE ADMIN`. Level: `GLOBAL`

  - `CREATE ROW POLICY`. Level: `GLOBAL`. Aliases: `CREATE POLICY`

  - `ALTER ROW POLICY`. Level: `GLOBAL`. Aliases: `ALTER POLICY`

  - `DROP ROW POLICY`. Level: `GLOBAL`. Aliases: `DROP POLICY`

  - `CREATE QUOTA`. Level: `GLOBAL`

  - `ALTER QUOTA`. Level: `GLOBAL`

  - `DROP QUOTA`. Level: `GLOBAL`

  - `CREATE SETTINGS PROFILE`. Level: `GLOBAL`. Aliases: `CREATE PROFILE`

  - `ALTER SETTINGS PROFILE`. Level: `GLOBAL`. Aliases: `ALTER PROFILE`

  - `DROP SETTINGS PROFILE`. Level: `GLOBAL`. Aliases: `DROP PROFILE`

  - ```
    SHOW ACCESS
    ```

    . Level:



    ```
    GROUP
    ```

    - `SHOW_USERS`. Level: `GLOBAL`. Aliases: `SHOW CREATE USER`
    - `SHOW_ROLES`. Level: `GLOBAL`. Aliases: `SHOW CREATE ROLE`
    - `SHOW_ROW_POLICIES`. Level: `GLOBAL`. Aliases: `SHOW POLICIES`, `SHOW CREATE ROW POLICY`, `SHOW CREATE POLICY`
    - `SHOW_QUOTAS`. Level: `GLOBAL`. Aliases: `SHOW CREATE QUOTA`
    - `SHOW_SETTINGS_PROFILES`. Level: `GLOBAL`. Aliases: `SHOW PROFILES`, `SHOW CREATE SETTINGS PROFILE`, `SHOW CREATE PROFILE`

The `ROLE ADMIN` privilege allows a user to assign and revoke any roles including those which are not assigned to the user with the admin option.

### SYSTEM

Allows a user to execute [SYSTEM] queries according to the following hierarchy of privileges.

- ```
  SYSTEM
  ```

  . Level:



  ```
GROUP
  ```

  - `SYSTEM SHUTDOWN`. Level: `GLOBAL`. Aliases: `SYSTEM KILL`, `SHUTDOWN`

  - ```
    SYSTEM DROP CACHE
    ```

    . Aliases:



    ```
    DROP CACHE
    ```

    - `SYSTEM DROP DNS CACHE`. Level: `GLOBAL`. Aliases: `SYSTEM DROP DNS`, `DROP DNS CACHE`, `DROP DNS`
    - `SYSTEM DROP MARK CACHE`. Level: `GLOBAL`. Aliases: `SYSTEM DROP MARK`, `DROP MARK CACHE`, `DROP MARKS`
    - `SYSTEM DROP UNCOMPRESSED CACHE`. Level: `GLOBAL`. Aliases: `SYSTEM DROP UNCOMPRESSED`, `DROP UNCOMPRESSED CACHE`, `DROP UNCOMPRESSED`

  - ```
    SYSTEM RELOAD
    ```

    . Level:



    ```
    GROUP
    ```

    - `SYSTEM RELOAD CONFIG`. Level: `GLOBAL`. Aliases: `RELOAD CONFIG`

    - ```
      SYSTEM RELOAD DICTIONARY
      ```

      . Level:



      ```
      GLOBAL
      ```

      . Aliases:



      ```
      SYSTEM RELOAD DICTIONARIES
      ```

      ,



      ```
      RELOAD DICTIONARY
      ```

      ,



      ```
      RELOAD DICTIONARIES
      ```

      - `SYSTEM RELOAD EMBEDDED DICTIONARIES`. Level: `GLOBAL`. Aliases: `RELOAD EMBEDDED DICTIONARIES`

  - `SYSTEM MERGES`. Level: `TABLE`. Aliases: `SYSTEM STOP MERGES`, `SYSTEM START MERGES`, `STOP MERGES`, `START MERGES`

  - `SYSTEM TTL MERGES`. Level: `TABLE`. Aliases: `SYSTEM STOP TTL MERGES`, `SYSTEM START TTL MERGES`, `STOP TTL MERGES`, `START TTL MERGES`

  - `SYSTEM FETCHES`. Level: `TABLE`. Aliases: `SYSTEM STOP FETCHES`, `SYSTEM START FETCHES`, `STOP FETCHES`, `START FETCHES`

  - `SYSTEM MOVES`. Level: `TABLE`. Aliases: `SYSTEM STOP MOVES`, `SYSTEM START MOVES`, `STOP MOVES`, `START MOVES`

  - ```
    SYSTEM SENDS
    ```

    . Level:



    ```
    GROUP
    ```

    . Aliases:



    ```
    SYSTEM STOP SENDS
    ```

    ,



    ```
    SYSTEM START SENDS
    ```

    ,



    ```
    STOP SENDS
    ```

    ,



    ```
    START SENDS
    ```

    - `SYSTEM DISTRIBUTED SENDS`. Level: `TABLE`. Aliases: `SYSTEM STOP DISTRIBUTED SENDS`, `SYSTEM START DISTRIBUTED SENDS`, `STOP DISTRIBUTED SENDS`, `START DISTRIBUTED SENDS`
    - `SYSTEM REPLICATED SENDS`. Level: `TABLE`. Aliases: `SYSTEM STOP REPLICATED SENDS`, `SYSTEM START REPLICATED SENDS`, `STOP REPLICATED SENDS`, `START REPLICATED SENDS`

  - `SYSTEM REPLICATION QUEUES`. Level: `TABLE`. Aliases: `SYSTEM STOP REPLICATION QUEUES`, `SYSTEM START REPLICATION QUEUES`, `STOP REPLICATION QUEUES`, `START REPLICATION QUEUES`

  - `SYSTEM SYNC REPLICA`. Level: `TABLE`. Aliases: `SYNC REPLICA`

  - `SYSTEM RESTART REPLICA`. Level: `TABLE`. Aliases: `RESTART REPLICA`

  - ```
    SYSTEM FLUSH
    ```

    . Level:



    ```
    GROUP
    ```

    - `SYSTEM FLUSH DISTRIBUTED`. Level: `TABLE`. Aliases: `FLUSH DISTRIBUTED`
    - `SYSTEM FLUSH LOGS`. Level: `GLOBAL`. Aliases: `FLUSH LOGS`

The `SYSTEM RELOAD EMBEDDED DICTIONARIES` privilege implicitly granted by the `SYSTEM RELOAD DICTIONARY ON *.*` privilege.

### INTROSPECTION

Allows using [introspection] functions.

- ```
  INTROSPECTION
  ```

  . Level:



  ```
GROUP
  ```

  . Aliases:



  ```
INTROSPECTION FUNCTIONS
  ```

  - `addressToLine`. Level: `GLOBAL`
  - `addressToSymbol`. Level: `GLOBAL`
  - `demangle`. Level: `GLOBAL`

### SOURCES

Allows using external data sources. Applies to [table engines] and [table functions].

- ```
  SOURCES
  ```

  . Level:



  ```
GROUP
  ```

  - `FILE`. Level: `GLOBAL`
  - `URL`. Level: `GLOBAL`
  - `REMOTE`. Level: `GLOBAL`
  - `YSQL`. Level: `GLOBAL`
  - `ODBC`. Level: `GLOBAL`
  - `JDBC`. Level: `GLOBAL`
  - `HDFS`. Level: `GLOBAL`
  - `S3`. Level: `GLOBAL`

The `SOURCES` privilege enables use of all the sources. Also you can grant a privilege for each source individually. To use sources, you need additional privileges.

Examples:

- To create a table with the [MySQL table engine], you need `CREATE TABLE (ON db.table_name)` and `MYSQL` privileges.
- To use the [mysql table function], you need `CREATE TEMPORARY TABLE` and `MYSQL` privileges.

### dictGet

- `dictGet`. Aliases: `dictHas`, `dictGetHierarchy`, `dictIsIn`

Allows a user to execute [dictGet], [dictHas], [dictGetHierarchy], [dictIsIn] functions.

Privilege level: `DICTIONARY`.

**Examples**

- `GRANT dictGet ON mydb.mydictionary TO john`
- `GRANT dictGet ON mydictionary TO john`

### ALL

Grants all the privileges on regulated entity to a user account or a role.

### NONE

Doesn’t grant any privileges.

### ADMIN OPTION

The `ADMIN OPTION` privilege allows a user to grant their role to another user.

' where id=13;
update biz_data_query_model_help_content set content_en = '# REVOKE Statement

Revokes privileges from users or roles.

## Syntax

**Revoking privileges from users**

```
REVOKE [ON CLUSTER cluster_name] privilege[(column_name [,...])] [,...] ON {db.table|db.*|*.*|table|*} FROM {user | CURRENT_USER} [,...] | ALL | ALL EXCEPT {user | CURRENT_USER} [,...]
```

**Revoking roles from users**

```
REVOKE [ON CLUSTER cluster_name] [ADMIN OPTION FOR] role [,...] FROM {user | role | CURRENT_USER} [,...] | ALL | ALL EXCEPT {user_name | role_name | CURRENT_USER} [,...]
```

## Description

To revoke some privilege you can use a privilege of a wider scope than you plan to revoke. For example, if a user has the `SELECT (x,y)` privilege, administrator can execute `REVOKE SELECT(x,y) ...`, or `REVOKE SELECT * ...`, or even `REVOKE ALL PRIVILEGES ...` query to revoke this privilege.

### Partial Revokes

You can revoke a part of a privilege. For example, if a user has the `SELECT *.*` privilege you can revoke from it a privilege to read data from some table or a database.

## Examples

Grant the `john` user account with a privilege to select from all the databases, excepting the `accounts` one:

```
GRANT SELECT ON *.* TO john;
REVOKE SELECT ON accounts.* FROM john;
```

Grant the `mira` user account with a privilege to select from all the columns of the `accounts.staff` table, excepting the `wage` one.

```
GRANT SELECT ON accounts.staff TO mira;
REVOKE SELECT(wage) ON accounts.staff FROM mira;
```

'  where id=14;
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

- `distribution_name` — Name of the probability distribution. [String]. Possible values:
  - `beta` for [Beta distribution]
  - `gamma` for [Gamma distribution]
- `higher_is_better` — Boolean flag. [Boolean]. Possible values:
  - `0` — lower values are considered to be better than higher
  - `1` — higher values are considered to be better than lower
- `variant_names` — Variant names. [Array]([String]).
- `x` — Numbers of tests for the corresponding variants. [Array]([Float64]).
- `y` — Numbers of successful tests for the corresponding variants. [Array]([Float64]).

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
update biz_data_query_model_help_content set content_en = '# Functions for Working with UUID

The functions for working with UUID are listed below.

## generateUUIDv4

Generates the [UUID] of [version 4].

```
generateUUIDv4()
```

**Returned value**

The UUID type value.

**Usage example**

This example demonstrates creating a table with the UUID type column and inserting a value into the table.

```
CREATE TABLE t_uuid (x UUID) ENGINE=TinyLog

INSERT INTO t_uuid SELECT generateUUIDv4()

SELECT * FROM t_uuid
┌────────────────────────────────────x─┐
│ f4bf890f-f9dc-4332-ad5c-0c18e73f28e9 │
└──────────────────────────────────────┘
```

## toUUID (x)

Converts String type value to UUID type.

```
toUUID(String)
```

**Returned value**

The UUID type value.

**Usage example**

```
SELECT toUUID(''61f0c404-5cb3-11e7-907b-a6006ad3dba0'') AS uuid
┌─────────────────────────────────uuid─┐
│ 61f0c404-5cb3-11e7-907b-a6006ad3dba0 │
└──────────────────────────────────────┘
```

## toUUIDOrNull (x)

It takes an argument of type String and tries to parse it into UUID. If failed, returns NULL.

```
toUUIDOrNull(String)
```

**Returned value**

The Nullable(UUID) type value.

**Usage example**

```
SELECT toUUIDOrNull(''61f0c404-5cb3-11e7-907b-a6006ad3dba0T'') AS uuid
┌─uuid─┐
│ ᴺᵁᴸᴸ │
└──────┘
```

## toUUIDOrZero (x)

It takes an argument of type String and tries to parse it into UUID. If failed, returns zero UUID.

```
toUUIDOrZero(String)
```

**Returned value**

The UUID type value.

**Usage example**

```
SELECT toUUIDOrZero(''61f0c404-5cb3-11e7-907b-a6006ad3dba0T'') AS uuid
┌─────────────────────────────────uuid─┐
│ ---- │
└──────────────────────────────────────┘
```

## UUIDStringToNum

Accepts a string containing 36 characters in the format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`, and returns it as a set of bytes in a [FixedString(16)].

```
UUIDStringToNum(String)
```

**Returned value**

FixedString(16)

**Usage examples**

```
SELECT
    ''612f3c40-5d3b-217e-707b-6a546a3d7b29'' AS uuid,
    UUIDStringToNum(uuid) AS bytes
┌─uuid─────────────────────────────────┬─bytes────────────┐
│ 612f3c40-5d3b-217e-707b-6a546a3d7b29 │ a/<@];!~p{jTj={) │
└──────────────────────────────────────┴──────────────────┘
```

## UUIDNumToString

Accepts a [FixedString(16)] value, and returns a string containing 36 characters in text format.

```
UUIDNumToString(FixedString(16))
```

**Returned value**

String.

**Usage example**

```
SELECT
    ''a/<@];!~p{jTj={)'' AS bytes,
    UUIDNumToString(toFixedString(bytes, 16)) AS uuid
┌─bytes────────────┬─uuid─────────────────────────────────┐
│ a/<@];!~p{jTj={) │ 612f3c40-5d3b-217e-707b-6a546a3d7b29 │
└──────────────────┴──────────────────────────────────────┘
```

## See Also

- [dictGetUUID]' where id=31;
update biz_data_query_model_help_content set content_en = ' # Higher-order function

####->Operator,lambda(params,expr)Function

Used to describe a lambda function and pass it to a higher-order function. On the left-side of the arrow is a formal argument that is a tuple composed of one or more identifiers. On the right-side of the arrow is an expression, in which any identifier or column name of the formal argument table can be used.

Example: `x->2*x,str->str!=Referer.`

A higher-order function can only have lambda functions as its arguments.



A higher-order function can have multiple lambda functions as its arguments. In this case, the higher-order function must simultaneously pass multiple arrays in the same length. These arrays will be passed to the lambda functions.



Except for arrayMap and arrayFilter, all other functions can ignore the first argument (lambda function). In this case, the array element itself is returned by default.

####arrayMap(func,arr1,…)

Return the arrays obtained from the original application program of the func function to each element in the arr array for the elements to execute the function.

####arrayFilter(func,arr1,…)

Return an array named arr1 that contains only the following elements and execute the non-zero return value of func on elements of the arr1 array.

```
SELECTarrayFilter(x->xLIKE%World%,[Hello,abcWorld])ASres
┌─res───────────┐
│[abcWorld]│
└───────────────┘
SELECT
arrayFilter(
(i,x)->xLIKE%World%,
arrayEnumerate(arr),
[Hello,abcWorld]ASarr)
ASres
┌─res─┐
│[2]│
└─────┘
```

####arrayCount([func,]arr1,…)

Return the number of non-zero elements in the arr array. If func is specified, the return value of func is used to determine whether an element is a non-zero element.

####arrayExists([func,]arr1,…)

Return the total number of the arr arrays. If func is specified, the return value of func is used to determine the total number of the arrays.

####arrayAll([func,]arr1,…)

Return the first matched element. Use func to match all elements to find the first matched element.

####arraySum([func,]arr1,…)

Return the subscript of the first matched element. Use func to match all elements to find the first matched element..

####arrayFirst(func,arr1,…)

Return the first matched element. Use func to match all elements to find the first matched element.

####arrayFirstIndex(func,arr1,…)

Return the subscript of the first matched element. Use func to match all elements to find the first matched element.

####arrayCumSum([func,]arr1,…)

Return the total of the original arrays. If func is specified, use the return value of func to calculate the total.

示例:

```
SELECTarrayCumSum([1,1,1,1])ASres
┌─res──────────┐
│[1,2,3,4]│
└──────────────┘
```

####arrayCumSumNonNegative(arr)

Return the ascending order of arr1. If func is specified, the return value of func decides the sorting result.

The Schwartzian transform is used to improve the efficiency of sorting.

```
SELECTarrayCumSumNonNegative([1,1,-4,1])ASres
┌─res───────┐
│[1,2,0,1]│
└───────────┘
```

####arraySort([func,]arr1,…)

Return the ascending order of arr1. If func is specified, the return value of func decides the sorting result.

The Schwartzian transform is used to improve the efficiency of sorting.

Example:

示例:

```
SELECTarraySort((x,y)->y,[hello,world],[2,1]);
┌─res────────────────┐
│[world,hello]│
└────────────────────┘
```

Note: NULL and NaN are placed in the end with NaN locating in front of NULL. Example:

```
SELECTarraySort([1,nan,2,NULL,3,nan,4,NULL])
┌─arraySort([1,nan,2,NULL,3,nan,4,NULL])─┐
│[1,2,3,4,nan,nan,NULL,NULL]│
└───────────────────────────────────────────────┘
```

####arrayReverseSort([func,]arr1,…)

Return the descending order of arr1. If func is specified, the return value of func decides the sorting result.

Note: NULL and NaN are placed in the end with NaN locating in front of NULL. Example:

```
SELECTarrayReverseSort([1,nan,2,NULL,3,nan,4,NULL])
┌─arrayReverseSort([1,nan,2,NULL,3,nan,4,NULL])─┐
│[4,3,2,1,nan,nan,NULL,NULL]│
└──────────────────────────────────────────────────────┘
```

' where id=50;
update biz_data_query_model_help_content set content_en = '# AggregateFunctions

Aggregate functions work in the [normal]way as expected by database experts.

ClickHouse also supports:

- [Parametric aggregate functions], which accept other parameters in addition to columns.
- [Combinators], which change the behavior of aggregate functions.

##NULLProcessing[]

During aggregation, all `NULL`s are skipped.

**Examples:**

Consider this table:

```
┌─x─┬────y─┐
│1│2│
│2│ᴺᵁᴸᴸ│
│3│2│
│3│3│
│3│ᴺᵁᴸᴸ│
└───┴──────┘
```

Let’s say you need to total the values in the `y` column:

```
SELECTsum(y)FROMt_null_big
┌─sum(y)─┐
│7│
└────────┘
```

Now you can use the `groupArray` function to create an array from the `y` column:

```
SELECTgroupArray(y)FROMt_null_big
┌─groupArray(y)─┐
│[2,2,3]│
└───────────────┘
```

`groupArray` does not include `NULL` in the resulting array.' where id=51;
update biz_data_query_model_help_content set content_en = '# sum

Calculatesthesum.Onlyworksfornumbers.' where id=76;
update biz_data_query_model_help_content set content_en = '# min

Aggregate function that calculates the minimum across a group of values.

Example:

```
SELECT min(salary) FROM employees;
SELECT department, min(salary) FROM employees GROUP BY department;
```

If you need non-aggregate function to choose a minimum of two values, see `least`:

```
SELECT least(a, b) FROM table;
```

' where id=74;
update biz_data_query_model_help_content set content_en = '# stddevPop

The result is equal to the square root of [varPop]

Note

This function uses a numerically unstable algorithm. If you need [numerical stability]in calculations, use the `stddevPopStable` function. It works slower but provides a lower computational error.

' where id=79;
update biz_data_query_model_help_content set content_en = '# stddevSamp

The result is equal to the square root of [varSamp]

Note

This function uses a numerically unstable algorithm. If you need [numerical stability] in calculations, use the `stddevSampStable` function. It works slower but provides a lower computational error.

' where id=80;