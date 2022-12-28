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
  host = ${host}
LIMIT
  ${limitNumber}
```

When you request for model data, you can use custom parameters such as metric, host, and limitNumber. For more information, see the  Query settings dialog box. Custom parameters can make the use of models more flexible. For more information, see the examples of cURL calls through the Copy function in the model list.' where id=1;
update biz_data_query_model_help_content set content_en = 'ClickHouse supports result sets in multiple formats such as JSON, CSV, and Pretty. You can export batch data in the specified format easily through the ClickHouse client. Example:

```
//Format:
clickhouse-client -h [Host IP address] -f [Result format] -q [SQL statement] > Target file
//Example:
clickhouse-client -h 127.0.0.1 -f CSV -q select * from bdp_store_kafka.zxy_test5 limit 10 > test.csv
```

```
Note: You can copy the SQL statement in the current SQL editor as value of the -q parameter. However, DODB requires the catalog.schema.table structure for tables. Therefore, you must remove the catalog name in the copied SQL statement. For example, remove "stream_kafka" from stream_kafka.bdp_store_kafka.zxy_test5.
```

' where id=2;
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
COMMENT COLUMN [IF EXISTS] name comment
```

Adds a comment to the column. If the `IF EXISTS` clause is specified, the query won’t return an error if the column does not exist.

Each column can have one comment. If a comment already exists for the column, a new comment overwrites the previous comment.

Comments are stored in the `comment_expression` column returned by the [DESCRIBE TABLE] query.

Example:

```
ALTER TABLE visits COMMENT COLUMN browser The table shows the browser used for accessing the site.
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
ALTER TABLE users FETCH PARTITION 201902 FROM /clickhouse/tables/01-01/visits;
ALTER TABLE users ATTACH PARTITION 201902;
```

1. FETCH PART

```
ALTER TABLE users FETCH PART 201901_2_2_0 FROM /clickhouse/tables/01-01/visits;
ALTER TABLE users ATTACH PART 201901_2_2_0;
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

    Also, they are replicated, syncing indices metadata via ZooKeeper.

    ' where id=10;
update biz_data_query_model_help_content set content_en = '#SYSTEMStatements

Thelistofavailable`SYSTEM`statements:

-[RELOADEMBEDDEDDICTIONARIES]
-[RELOADDICTIONARIES]
-[RELOADDICTIONARY]
-[RELOADMODELS]
-[RELOADMODEL]
-[DROPDNSCACHE]
-[DROPMARKCACHE]
-[DROPUNCOMPRESSEDCACHE]
-[DROPCOMPILEDEXPRESSIONCACHE]
-[DROPREPLICA]
-[FLUSHLOGS]
-[RELOADCONFIG]
-[SHUTDOWN]
-[KILL]
-[STOPDISTRIBUTEDSENDS]
-[FLUSHDISTRIBUTED]
-[STOPMERGES]
-[STARTMERGES]
-[STOPTTLMERGES]
-[STARTTTLMERGES]
-[STOPMOVES]
-[STARTMOVES]
-[STOPFETCHES]
-[STARTFETCHES]
-[STARTREPLICATEDSENDS]
-[STOPREPLICATIONQUEUES]
-[SYNCREPLICA]
-[RESTARTREPLICA]
-[RESTOREREPLICA]
-[RESTARTREPLICAS]

##RELOADEMBEDDEDDICTIONARIES

Reloadall[Internaldictionaries].
Bydefault,internaldictionariesaredisabled.
Alwaysreturns`Ok.`regardlessoftheresultoftheinternaldictionaryupdate.

##RELOADDICTIONARIES

Reloadsalldictionariesthathavebeensuccessfullyloadedbefore.
Bydefault,dictionariesareloadedlazily(see[dictionaries_lazy_load]),soinsteadofbeingloadedautomaticallyatstartup,theyareinitializedonfirstaccessthroughdictGetfunctionorSELECTfromtableswithENGINE=Dictionary.The`SYSTEMRELOADDICTIONARIES`queryreloadssuchdictionaries(LOADED).
Alwaysreturns`Ok.`regardlessoftheresultofthedictionaryupdate.

##RELOADDICTIONARY

Completelyreloadsadictionary`dictionary_name`,regardlessofthestateofthedictionary(LOADED/NOT_LOADED/FAILED).
Alwaysreturns`Ok.`regardlessoftheresultofupdatingthedictionary.
Thestatusofthedictionarycanbecheckedbyqueryingthe`system.dictionaries`table.

```
SELECTname,statusFROMsystem.dictionaries;
```

##RELOADMODELS

Reloadsall[CatBoost]modelsiftheconfigurationwasupdatedwithoutrestartingtheserver.

**Syntax**

```
SYSTEMRELOADMODELS
```

##RELOADMODEL

CompletelyreloadsaCatBoostmodel`model_name`iftheconfigurationwasupdatedwithoutrestartingtheserver.

**Syntax**

```
SYSTEMRELOADMODEL<model_name>
```

##DROPDNSCACHE

ResetsClickHouse’sinternalDNScache.Sometimes(foroldClickHouseversions)itisnecessarytousethiscommandwhenchangingtheinfrastructure(changingtheIPaddressofanotherClickHouseserverortheserverusedbydictionaries).

Formoreconvenient(automatic)cachemanagement,seedisable_internal_dns_cache,dns_cache_update_periodparameters.

##DROPMARKCACHE

Resetsthemarkcache.UsedindevelopmentofClickHouseandperformancetests.

##DROPREPLICA

Deadreplicascanbedroppedusingfollowingsyntax:

```
SYSTEMDROPREPLICAreplica_nameFROMTABLEdatabase.table;
SYSTEMDROPREPLICAreplica_nameFROMDATABASEdatabase;
SYSTEMDROPREPLICAreplica_name;
SYSTEMDROPREPLICAreplica_nameFROMZKPATH/path/to/table/in/zk;
```

QuerieswillremovethereplicapathinZooKeeper.ItisusefulwhenthereplicaisdeadanditsmetadatacannotberemovedfromZooKeeperby`DROPTABLE`becausethereisnosuchtableanymore.Itwillonlydroptheinactive/stalereplica,anditcannotdroplocalreplica,pleaseuse`DROPTABLE`forthat.`DROPREPLICA`doesnotdropanytablesanddoesnotremoveanydataormetadatafromdisk.

Thefirstoneremovesmetadataof`replica_name`replicaof`database.table`table.
Thesecondonedoesthesameforallreplicatedtablesinthedatabase.
Thethirdonedoesthesameforallreplicatedtablesonthelocalserver.
Thefourthoneisusefultoremovemetadataofdeadreplicawhenallotherreplicasofatableweredropped.Itrequiresthetablepathtobespecifiedexplicitly.Itmustbethesamepathaswaspassedtothefirstargumentof`ReplicatedMergeTree`engineontablecreation.

##DROPUNCOMPRESSEDCACHE

Resettheuncompresseddatacache.UsedindevelopmentofClickHouseandperformancetests.
Formanageuncompresseddatacacheparametersusefollowingserverlevelsettings[uncompressed_cache_size]andquery/user/profilelevelsettings[use_uncompressed_cache]

##DROPCOMPILEDEXPRESSIONCACHE

Resetthecompiledexpressioncache.UsedindevelopmentofClickHouseandperformancetests.
Compliedexpressioncacheusedwhenquery/user/profileenableoption[compile]

##FLUSHLOGS

Flushesbuffersoflogmessagestosystemtables(e.g.system.query_log).Allowsyoutonotwait7.5secondswhendebugging.
Thiswillalsocreatesystemtablesevenifmessagequeueisempty.

##RELOADCONFIG

ReloadsClickHouseconfiguration.UsedwhenconfigurationisstoredinZooKeeeper.

##SHUTDOWN

NormallyshutsdownClickHouse(like`serviceclickhouse-serverstop`/`kill{$pid_clickhouse-server}`)

##KILL

AbortsClickHouseprocess(like`kill-9{$pid_clickhouse-server}`)

##ManagingDistributedTables

ClickHousecanmanage[distributed]tables.Whenauserinsertsdataintothesetables,ClickHousefirstcreatesaqueueofthedatathatshouldbesenttoclusternodes,thenasynchronouslysendsit.Youcanmanagequeueprocessingwiththe[STOPDISTRIBUTEDSENDS],[FLUSHDISTRIBUTED],and[STARTDISTRIBUTEDSENDS]queries.Youcanalsosynchronouslyinsertdistributeddatawiththe[insert_distributed_sync]setting.

###STOPDISTRIBUTEDSENDS

Disablesbackgrounddatadistributionwheninsertingdataintodistributedtables.

```
SYSTEMSTOPDISTRIBUTEDSENDS[db.]<distributed_table_name>
```

###FLUSHDISTRIBUTED

ForcesClickHousetosenddatatoclusternodessynchronously.Ifanynodesareunavailable,ClickHousethrowsanexceptionandstopsqueryexecution.Youcanretrythequeryuntilitsucceeds,whichwillhappenwhenallnodesarebackonline.

```
SYSTEMFLUSHDISTRIBUTED[db.]<distributed_table_name>
```

###STARTDISTRIBUTEDSENDS

Enablesbackgrounddatadistributionwheninsertingdataintodistributedtables.

```
SYSTEMSTARTDISTRIBUTEDSENDS[db.]<distributed_table_name>
```

##ManagingMergeTreeTables

ClickHousecanmanagebackgroundprocessesin[MergeTree]tables.

###STOPMERGES

ProvidespossibilitytostopbackgroundmergesfortablesintheMergeTreefamily:

```
SYSTEMSTOPMERGES[ONVOLUME<volume_name>|[db.]merge_tree_family_table_name]
```

Note

`DETACH/ATTACH`tablewillstartbackgroundmergesforthetableevenincasewhenmergeshavebeenstoppedforallMergeTreetablesbefore.

###STARTMERGES

ProvidespossibilitytostartbackgroundmergesfortablesintheMergeTreefamily:

```
SYSTEMSTARTMERGES[ONVOLUME<volume_name>|[db.]merge_tree_family_table_name]
```

###STOPTTLMERGES

Providespossibilitytostopbackgrounddeleteolddataaccordingto[TTLexpression]fortablesintheMergeTreefamily:
Returns`Ok.`eveniftabledoesnotexistortablehasnotMergeTreeengine.Returnserrorwhendatabasedoesnotexist:

```
SYSTEMSTOPTTLMERGES[[db.]merge_tree_family_table_name]
```

###STARTTTLMERGES

Providespossibilitytostartbackgrounddeleteolddataaccordingto[TTLexpression]fortablesintheMergeTreefamily:
Returns`Ok.`eveniftabledoesnotexist.Returnserrorwhendatabasedoesnotexist:

```
SYSTEMSTARTTTLMERGES[[db.]merge_tree_family_table_name]
```

###STOPMOVES

Providespossibilitytostopbackgroundmovedataaccordingto[TTLtableexpressionwithTOVOLUMEorTODISKclause]fortablesintheMergeTreefamily:
Returns`Ok.`eveniftabledoesnotexist.Returnserrorwhendatabasedoesnotexist:

```
SYSTEMSTOPMOVES[[db.]merge_tree_family_table_name]
```

###STARTMOVES

Providespossibilitytostartbackgroundmovedataaccordingto[TTLtableexpressionwithTOVOLUMEandTODISKclause]fortablesintheMergeTreefamily:
Returns`Ok.`eveniftabledoesnotexist.Returnserrorwhendatabasedoesnotexist:

```
SYSTEMSTARTMOVES[[db.]merge_tree_family_table_name]
```

##ManagingReplicatedMergeTreeTables

ClickHousecanmanagebackgroundreplicationrelatedprocessesin[ReplicatedMergeTree]tables.

###STOPFETCHES

Providespossibilitytostopbackgroundfetchesforinsertedpartsfortablesinthe`ReplicatedMergeTree`family:
Alwaysreturns`Ok.`regardlessofthetableengineandeveniftableordatabasedoesnotexist.

```
SYSTEMSTOPFETCHES[[db.]replicated_merge_tree_family_table_name]
```

###STARTFETCHES

Providespossibilitytostartbackgroundfetchesforinsertedpartsfortablesinthe`ReplicatedMergeTree`family:
Alwaysreturns`Ok.`regardlessofthetableengineandeveniftableordatabasedoesnotexist.

```
SYSTEMSTARTFETCHES[[db.]replicated_merge_tree_family_table_name]
```

###STOPREPLICATEDSENDS

Providespossibilitytostopbackgroundsendstootherreplicasinclusterfornewinsertedpartsfortablesinthe`ReplicatedMergeTree`family:

```
SYSTEMSTOPREPLICATEDSENDS[[db.]replicated_merge_tree_family_table_name]
```

###STARTREPLICATEDSENDS

Providespossibilitytostartbackgroundsendstootherreplicasinclusterfornewinsertedpartsfortablesinthe`ReplicatedMergeTree`family:

```
SYSTEMSTARTREPLICATEDSENDS[[db.]replicated_merge_tree_family_table_name]
```

###STOPREPLICATIONQUEUES

ProvidespossibilitytostopbackgroundfetchtasksfromreplicationqueueswhichstoredinZookeeperfortablesinthe`ReplicatedMergeTree`family.Possiblebackgroundtaskstypes-merges,fetches,mutation,DDLstatementswithONCLUSTERclause:

```
SYSTEMSTOPREPLICATIONQUEUES[[db.]replicated_merge_tree_family_table_name]
```

###STARTREPLICATIONQUEUES

ProvidespossibilitytostartbackgroundfetchtasksfromreplicationqueueswhichstoredinZookeeperfortablesinthe`ReplicatedMergeTree`family.Possiblebackgroundtaskstypes-merges,fetches,mutation,DDLstatementswithONCLUSTERclause:

```
SYSTEMSTARTREPLICATIONQUEUES[[db.]replicated_merge_tree_family_table_name]
```

###SYNCREPLICA

Waituntila`ReplicatedMergeTree`tablewillbesyncedwithotherreplicasinacluster.Willrununtil`receive_timeout`iffetchescurrentlydisabledforthetable.

```
SYSTEMSYNCREPLICA[db.]replicated_merge_tree_family_table_name
```

Afterrunningthisstatementthe`[db.]replicated_merge_tree_family_table_name`fetchescommandsfromthecommonreplicatedlogintoitsownreplicationqueue,andthenthequerywaitstillthereplicaprocessesallofthefetchedcommands.

###RESTARTREPLICA

ProvidespossibilitytoreinitializeZookeepersessionsstatefor`ReplicatedMergeTree`table,willcomparecurrentstatewithZookeeperassourceoftrueandaddtaskstoZookeeperqueueifneeded.
InitializationreplicationqueuebasedonZooKeeperdatehappensinthesamewayas`ATTACHTABLE`statement.Forashorttimethetablewillbeunavailableforanyoperations.

```
SYSTEMRESTARTREPLICA[db.]replicated_merge_tree_family_table_name
```

###RESTOREREPLICA

Restoresareplicaifdatais[possibly]presentbutZookeepermetadataislost.

Worksonlyonreadonly`ReplicatedMergeTree`tables.

Onemayexecutequeryafter:

-ZooKeeperroot`/`loss.
-Replicaspath`/replicas`loss.
-Individualreplicapath`/replicas/replica_name/`loss.

ReplicaattacheslocallyfoundpartsandsendsinfoaboutthemtoZookeeper.
Partspresentonreplicabeforemetadatalossarenotre-fetchedfromotherreplicasifnotbeingoutdated
(soreplicarestorationdoesnotmeanre-downloadingalldataoverthenetwork).

Caveat:partsinallstatesaremovedto`detached/`folder.Partsactivebeforedataloss(Committed)areattached.

####Syntax

```
SYSTEMRESTOREREPLICA[db.]replicated_merge_tree_family_table_name[ONCLUSTERcluster_name]
```

Alternativesyntax:

```
SYSTEMRESTOREREPLICA[ONCLUSTERcluster_name][db.]replicated_merge_tree_family_table_name
```

####Example

```
--Creatingtableonmultipleservers

CREATETABLEtest(nUInt32)
ENGINE=ReplicatedMergeTree(/clickhouse/tables/test/,{replica})
ORDERBYnPARTITIONBYn%10;

INSERTINTOtestSELECT*FROMnumbers(1000);

--zookeeper_delete_path("/clickhouse/tables/test",recursive=True)<-rootloss.

SYSTEMRESTARTREPLICAtest;--Tablewillattachasreadonlyasmetadataismissing.
SYSTEMRESTOREREPLICAtest;--Needtoexecuteoneveryreplica,anotherway:RESTOREREPLICAtestONCLUSTERcluster
```

###RESTARTREPLICAS

ProvidespossibilitytoreinitializeZookeepersessionsstateforall`ReplicatedMergeTree`tables,willcomparecurrentstatewithZookeeperassourceoftrueandaddtaskstoZookeeperqueueifneeded' where id=11;
update biz_data_query_model_help_content set content_en = '#SHOWStatements

##SHOWCREATETABLE

```
SHOWCREATE[TEMPORARY][TABLE|DICTIONARY][db.]table[INTOOUTFILEfilename][FORMATformat]
```

Returnsasingle`String`-type‘statement’column,whichcontainsasinglevalue–the`CREATE`queryusedforcreatingthespecifiedobject.

##SHOWDATABASES

Printsalistofalldatabases.

```
SHOWDATABASES[LIKE|ILIKE|NOTLIKE<pattern>][LIMIT<N>][INTOOUTFILEfilename][FORMATformat]
```

Thisstatementisidenticaltothequery:

```
SELECTnameFROMsystem.databases[WHEREnameLIKE|ILIKE|NOTLIKE<pattern>][LIMIT<N>][INTOOUTFILEfilename][FORMATformat]
```

###Examples

Gettingdatabasenames,containingthesymbolssequencedeintheirnames:

```
SHOWDATABASESLIKE%de%
```

Result:

```
┌─name────┐
│default│
└─────────┘
```

Gettingdatabasenames,containingsymbolssequencedeintheirnames,inthecaseinsensitivemanner:

```
SHOWDATABASESILIKE%DE%
```

Result:

```
┌─name────┐
│default│
└─────────┘
```

Gettingdatabasenames,notcontainingthesymbolssequencedeintheirnames:

```
SHOWDATABASESNOTLIKE%de%
```

Result:

```
┌─name───────────────────────────┐│_temporary_and_external_tables││system││test││tutorial│└────────────────────────────────┘
```

Gettingthefirsttworowsfromdatabasenames:

```
SHOWDATABASESLIMIT2
```

Result:

```
┌─name───────────────────────────┐│_temporary_and_external_tables││default│└────────────────────────────────┘
```

###SeeAlso

-[CREATEDATABASE]

##SHOWPROCESSLIST

```
SHOWPROCESSLIST[INTOOUTFILEfilename][FORMATformat]
```

Outputsthecontentofthe[system.processes]table,thatcontainsalistofqueriesthatisbeingprocessedatthemoment,excepting`SHOWPROCESSLIST`queries.

The`SELECT*FROMsystem.processes`queryreturnsdataaboutallthecurrentqueries.

Tip(executeintheconsole):

```
$watch-n1"clickhouse-client--query=SHOWPROCESSLIST"
```

##SHOWTABLES

Displaysalistoftables.

```
SHOW[TEMPORARY]TABLES[{FROM|IN}<db>][LIKE|ILIKE|NOTLIKE<pattern>][LIMIT<N>][INTOOUTFILE<filename>][FORMAT<format>]
```

Ifthe`FROM`clauseisnotspecified,thequeryreturnsthelistoftablesfromthecurrentdatabase.

Thisstatementisidenticaltothequery:

```
SELECTnameFROMsystem.tables[WHEREnameLIKE|ILIKE|NOTLIKE<pattern>][LIMIT<N>][INTOOUTFILE<filename>][FORMAT<format>]
```

###Examples

Gettingtablenames,containingthesymbolssequenceuserintheirnames:

```
SHOWTABLESFROMsystemLIKE%user%
```

Result:

```
┌─name─────────────┐│user_directories││users│└──────────────────┘
```

Gettingtablenames,containingsequenceuserintheirnames,inthecaseinsensitivemanner:

```
SHOWTABLESFROMsystemILIKE%USER%
```

Result:

```
┌─name─────────────┐│user_directories││users│└──────────────────┘
```

Gettingtablenames,notcontainingthesymbolsequencesintheirnames:

```
SHOWTABLESFROMsystemNOTLIKE%s%
```

Result:

```
┌─name─────────┐│metric_log││metric_log_0││metric_log_1│└──────────────┘
```

Gettingthefirsttworowsfromtablenames:

```
SHOWTABLESFROMsystemLIMIT2
```

Result:

```
┌─name───────────────────────────┐│aggregate_function_combinators││asynchronous_metric_log│└────────────────────────────────┘
```

###SeeAlso

-[CreateTables
-[SHOWCREATETABLE]

##SHOWDICTIONARIES

Displaysalistof[externaldictionaries]。

```
SHOWDICTIONARIES[FROM<db>][LIKE<pattern>][LIMIT<N>][INTOOUTFILE<filename>][FORMAT<format>]
```

Ifthe`FROM`clauseisnotspecified,thequeryreturnsthelistofdictionariesfromthecurrentdatabase.

Youcangetthesameresultsasthe`SHOWDICTIONARIES`queryinthefollowingway:

```
SELECTnameFROMsystem.dictionariesWHEREdatabase=<db>[ANDnameLIKE<pattern>][LIMIT<N>][INTOOUTFILE<filename>][FORMAT<format>]
```

**Example**

Thefollowingqueryselectsthefirsttworowsfromthelistoftablesinthe`system`database,whosenamescontain`reg`.

```
SHOWDICTIONARIESFROMdbLIKE%reg%LIMIT2┌─name─────────┐│regions││region_names│└──────────────┘
```

##SHOWGRANTS

Showsprivilegesforauser.

###Syntax

```
SHOWGRANTS[FORuser1[,user2...]]
```

Ifuserisnotspecified,thequeryreturnsprivilegesforthecurrentuser.


Showsparametersthatwereusedata[usercreation

`SHOWCREATEUSER`doesnotoutputuserpasswords.

###Syntax

```
SHOWCREATEUSER[name1[,name2...]|CURRENT_USER]
```

##SHOWCREATEROLE

Showsparametersthatwereusedata[rolecreation].

###Syntax

```
SHOWCREATEROLEname1[,name2...]
```

##SHOWCREATEROWPOLICY

Showsparametersthatwereusedata[rowpolicycreation]).

###Syntax

```
SHOWCREATE[ROW]POLICYnameON[database1.]table1[,[database2.]table2...]
```

##SHOWCREATEQUOTA

Showsparametersthatwereusedata[quotacreation].

###Syntax

```
SHOWCREATEQUOTA[name1[,name2...]|CURRENT]
```

##SHOWCREATESETTINGSPROFILE

Showsparametersthatwereusedata[settingsprofilecreation].

###Syntax

```
SHOWCREATE[SETTINGS]PROFILEname1[,name2...]
```

##SHOWUSERS

Returnsalistof[useraccount]names.Toviewuseraccountsparameters,seethesystemtable[system.users].

###Syntax

```
SHOWUSERS
```

##SHOWROLES.Toviewanotherparameters,seesystemtables[system.roles]and[system.role-grants].

###Syntax

```
SHOW[CURRENT|ENABLED]ROLES
```

##SHOWPROFILES

Returnsalistof[settingprofiles].Toviewuseraccountsparameters,seethesystemtable[settings_profiles](.

###Syntax

```
SHOW[SETTINGS]PROFILES
```

##SHOWPOLICIES[]

Returnsalistof[rowpolicies]forthespecifiedtable.Toviewuseraccountsparameters,seethesystemtable[system.row_policies].

###Syntax

```
SHOW[ROW]POLICIES[ON[db.]table]
```

##SHOWQUOTAS

Returnsalistof[quotas].Toviewquotasparameters,seethesystemtable[system.quotas].

###Syntax

```
SHOWQUOTAS
```

##SHOWQUOTA[

Returnsa[quota]consumptionforallusersorforcurrentuser.Toviewanotherparameters,seesystemtables[system.quotas_usage]and[system.quota_usage].

###Syntax[]

```
SHOW[CURRENT]QUOTA
```

##SHOWACCESS

Showsall[users],[roles],[profiles],etc.andalltheir[grants].

###Syntax

```
SHOWACCESS
```

##SHOWCLUSTER(s)

Returnsalistofclusters.Allavailableclustersarelistedinthe[system.clusters]table.

Note

`SHOWCLUSTERname`querydisplaysthecontentsofsystem.clusterstableforthiscluster.

###Syntax

```
SHOWCLUSTER<name>SHOWCLUSTERS[LIKE|NOTLIKE<pattern>][LIMIT<N>]
```

###Examples

Query:

```
SHOWCLUSTERS;
```

Result:

```
┌─cluster──────────────────────────────────────┐│test_cluster_two_shards││test_cluster_two_shards_internal_replication││test_cluster_two_shards_localhost││test_shard_localhost││test_shard_localhost_secure││test_unavailable_shard│└──────────────────────────────────────────────┘
```

Query:

```
SHOWCLUSTERSLIKEtest%LIMIT1;
```

Result:

```
┌─cluster─────────────────┐│test_cluster_two_shards│└─────────────────────────┘
```

Query:

```
SHOWCLUSTERtest_shard_localhostFORMATVertical;
```

Result:

```
Row1:──────cluster:test_shard_localhostshard_num:1shard_weight:1replica_num:1host_name:localhosthost_address:127.0.0.1port:9000is_local:1user:defaultdefault_database:errors_count:0estimated_recovery_time:0
```

##SHOWSETTINGS

Returnsalistofsystemsettingsandtheirvalues.Selectsdatafromthe[system.settings]table.

**Syntax**

```
SHOW[CHANGED]SETTINGSLIKE|ILIKE<name>
```

**Clauses**

`LIKE|ILIKE`allowtospecifyamatchingpatternforthesettingname.Itcancontainglobssuchas`%`or`_`.`LIKE`clauseiscase-sensitive,`ILIKE`—caseinsensitive.

Whenthe`CHANGED`clauseisused,thequeryreturnsonlysettingschangedfromtheirdefaultvalues.

**Examples**

Querywiththe`LIKE`clause:

```
SHOWSETTINGSLIKEsend_timeout;
```

Result:

```
┌─name─────────┬─type────┬─value─┐
│send_timeout│Seconds│300│
└──────────────┴─────────┴───────┘
```

Querywiththe`ILIKE`clause:

```
SHOWSETTINGSILIKE%CONNECT_timeout%
```

Result:

```
┌─name────────────────────────────────────┬─type─────────┬─value─┐
│connect_timeout│Seconds│10│
│connect_timeout_with_failover_ms│Milliseconds│50│
│connect_timeout_with_failover_secure_ms│Milliseconds│100│
└─────────────────────────────────────────┴──────────────┴───────┘
```

Querywiththe`CHANGED`clause:

```
SHOWCHANGEDSETTINGSILIKE%MEMORY%
```

Result:

```
┌─name─────────────┬─type───┬─value───────┐
│max_memory_usage│UInt64│10000000000│
└──────────────────┴────────┴─────────────┘
```

' where id=12;
update biz_data_query_model_help_content set content_en = '#REVOKEStatement

Revokesprivilegesfromusersorroles.

##Syntax

**Revokingprivilegesfromusers**

```
REVOKE[ONCLUSTERcluster_name]privilege[(column_name[,...])][,...]ON{db.table|db.*|*.*|table|*}FROM{user|CURRENT_USER}[,...]|ALL|ALLEXCEPT{user|CURRENT_USER}[,...]
```

**Revokingrolesfromusers**

```
REVOKE[ONCLUSTERcluster_name][ADMINOPTIONFOR]role[,...]FROM{user|role|CURRENT_USER}[,...]|ALL|ALLEXCEPT{user_name|role_name|CURRENT_USER}[,...]
```

##Description

Torevokesomeprivilegeyoucanuseaprivilegeofawiderscopethanyouplantorevoke.Forexample,ifauserhasthe`SELECT(x,y)`privilege,administratorcanexecute`REVOKESELECT(x,y)...`,or`REVOKESELECT*...`,oreven`REVOKEALLPRIVILEGES...`querytorevokethisprivilege.

###PartialRevokes

Youcanrevokeapartofaprivilege.Forexample,ifauserhasthe`SELECT*.*`privilegeyoucanrevokefromitaprivilegetoreaddatafromsometableoradatabase.

##Examples

Grantthe`john`useraccountwithaprivilegetoselectfromallthedatabases,exceptingthe`accounts`one:

```
GRANTSELECTON*.*TOjohn;
REVOKESELECTONaccounts.*FROMjohn;
```

Grantthe`mira`useraccountwithaprivilegetoselectfromallthecolumnsofthe`accounts.staff`table,exceptingthe`wage`one.

```
GRANTSELECTONaccounts.staffTOmira;
REVOKESELECT(wage)ONaccounts.staffFROMmira;
```' where id=13;
update biz_data_query_model_help_content set content_en = 'REVOKE Statement
Revokes privileges from users or roles.

Syntax
Revoking privileges from users

CopyREVOKE [ON CLUSTER cluster_name] privilege[(column_name [,...])] [,...] ON {db.table|db.*|*.*|table|*} FROM {user | CURRENT_USER} [,...] | ALL | ALL EXCEPT {user | CURRENT_USER} [,...]
Revoking roles from users

CopyREVOKE [ON CLUSTER cluster_name] [ADMIN OPTION FOR] role [,...] FROM {user | role | CURRENT_USER} [,...] | ALL | ALL EXCEPT {user_name | role_name | CURRENT_USER} [,...]
Description
To revoke some privilege you can use a privilege of a wider scope than you plan to revoke. For example, if a user has the SELECT (x,y) privilege, administrator can execute REVOKE SELECT(x,y) ..., or REVOKE SELECT * ..., or even REVOKE ALL PRIVILEGES ... query to revoke this privilege.

Partial Revokes
You can revoke a part of a privilege. For example, if a user has the SELECT *.* privilege you can revoke from it a privilege to read data from some table or a database.

Examples
Grant the john user account with a privilege to select from all the databases, excepting the accounts one:

CopyGRANT SELECT ON *.* TO john;
REVOKE SELECT ON accounts.* FROM john;
Grant the mira user account with a privilege to select from all the columns of the accounts.staff table, excepting the wage one.

CopyGRANT SELECT ON accounts.staff TO mira;
REVOKE SELECT(wage) ON accounts.staff FROM mira;' where id=14;
update biz_data_query_model_help_content set content_en = '# Miscellaneous Statements

- [ATTACH]

# ATTACH Statement

Attaches the table, for example, when moving a database to another server.

The query does not create data on the disk, but assumes that data is already in the appropriate places, and just adds information about the table to the server. After executing an `ATTACH` query, the server will know about the existence of the table.

If the table was previously detached ([DETACH]) query, meaning that its structure is known, you can use shorthand without defining the structure.

## Syntax Forms

### Attach Existing Table

```
ATTACH TABLE [IF NOT EXISTS] [db.]name [ON CLUSTER cluster]
```

This query is used when starting the server. The server stores table metadata as files with `ATTACH` queries, which it simply runs at launch (with the exception of some system tables, which are explicitly created on the server).

If the table was detached permanently, it wont be reattached at the server start, so you need to use `ATTACH` query explicitly.

### Сreate New Table And Attach Data

**With specify path to table data**

```
ATTACH TABLE name FROM path/to/data/ (col1 Type1, ...)
```

It creates new table with provided structure and attaches table data from provided directory in `user_files`.

**Example**

Query:

```
DROP TABLE IF EXISTS test;
INSERT INTO TABLE FUNCTION file(01188_attach/test/data.TSV, TSV, s String, n UInt8) VALUES (test, 42);
ATTACH TABLE test FROM 01188_attach/test (s String, n UInt8) ENGINE = File(TSV);
SELECT * FROM test;
```

Result:

```
┌─s────┬──n─┐
│ test │ 42 │
└──────┴────┘
```

**With specify table UUID** (Only for `Atomic` database)

```
ATTACH TABLE name UUID <uuid> (col1 Type1, ...)
```

It creates new table with provided structure and attaches data from table with the specified UUID.

- [CHECK TABLE]

# CHECK TABLE Statement

Checks if the data in the table is corrupted.

```
CHECK TABLE [db.]name
```

The `CHECK TABLE` query compares actual file sizes with the expected values which are stored on the server. If the file sizes do not match the stored values, it means the data is corrupted. This can be caused, for example, by a system crash during query execution.

The query response contains the `result` column with a single row. The row has a value of
[Boolean] type:

- 0 - The data in the table is corrupted.
- 1 - The data maintains integrity.

The `CHECK TABLE` query supports the following table engines:

- [Log]
- [TinyLog]
- [StripeLog]
- [MergeTree family]

Performed over the tables with another table engines causes an exception.

Engines from the `*Log` family do not provide automatic data recovery on failure. Use the `CHECK TABLE` query to track data loss in a timely manner.

## Checking the MergeTree Family Tables

For `MergeTree` family engines, if [check_query_single_value_result] = 0, the `CHECK TABLE` query shows a check status for every individual data part of a table on the local server.

```
SET check_query_single_value_result = 0;
CHECK TABLE test_table;
┌─part_path─┬─is_passed─┬─message─┐
│ all_1_4_1 │         1 │         │
│ all_1_4_2 │         1 │         │
└───────────┴───────────┴─────────┘
```

If `check_query_single_value_result` = 0, the `CHECK TABLE` query shows the general table check status.

```
SET check_query_single_value_result = 1;
CHECK TABLE test_table;
┌─result─┐
│      1 │
└────────┘
```

## If the Data Is Corrupted

If the table is corrupted, you can copy the non-corrupted data to another table. To do this:

1. Create a new table with the same structure as damaged table. To do this execute the query `CREATE TABLE <new_table_name> AS <damaged_table_name>`.
2. Set the [max_threads] value to 1 to process the next query in a single thread. To do this run the query `SET max_threads = 1`.
3. Execute the query `INSERT INTO <new_table_name> SELECT * FROM <damaged_table_name>`. This request copies the non-corrupted data from the damaged table to another table. Only the data before the corrupted part will be copied.
4. Restart the `clickhouse-client` to reset the `max_threads` value.

- [DESCRIBE TABLE]

# DESCRIBE TABLE Statement

```
DESC|DESCRIBE TABLE [db.]table [INTO OUTFILE filename] [FORMAT format]
```

Returns the following `String` type columns:

- `name` — Column name.
- `type`— Column type.
- `default_type` — Clause that is used in [default expression] (`DEFAULT`, `MATERIALIZED` or `ALIAS`). Column contains an empty string, if the default expression isn’t specified.
- `default_expression` — Value specified in the `DEFAULT` clause.
- `comment_expression` — Comment text.

Nested data structures are output in “expanded” format. Each column is shown separately, with the name after a dot.

- [DETACH]

# DETACH Statement

Makes the server "forget" about the existence of the table or materialized view.

Syntax:

```
DETACH TABLE|VIEW [IF EXISTS] [db.]name [ON CLUSTER cluster] [PERMANENTLY]
```

Detaching does not delete the data or metadata for the table or materialized view. If the table or view was not detached `PERMANENTLY`, on the next server launch the server will read the metadata and recall the table/view again. If the table or view was detached `PERMANENTLY`, there will be no automatic recall.

Whether the table was detached permanently or not, in both cases you can reattach it using the [ATTACH]. System log tables can be also attached back (e.g. `query_log`, `text_log`, etc). Other system tables cant be reattached. On the next server launch the server will recall those tables again.

`ATTACH MATERIALIZED VIEW` does not work with short syntax (without `SELECT`), but you can attach it using the `ATTACH TABLE` query.

Note that you can not detach permanently the table which is already detached (temporary). But you can attach it back and then detach permanently again.

Also you can not [DROP] the detached table, or [CREATE TABLE] with the same name as detached permanently, or replace it with the other table with [RENAME TABLE] query.

**Example**

Creating a table:

Query:

```
CREATE TABLE test ENGINE = Log AS SELECT * FROM numbers(10);
SELECT * FROM test;
```

Result:

```
┌─number─┐
│      0 │
│      1 │
│      2 │
│      3 │
│      4 │
│      5 │
│      6 │
│      7 │
│      8 │
│      9 │
└────────┘
```

Detaching the table:

Query:

```
DETACH TABLE test;
SELECT * FROM test;
```

Result:

```
Received exception from server (version 21.4.1):
Code: 60. DB::Exception: Received from localhost:9000. DB::Exception: Table default.test does not exist.
```

- [DROP]

# DROP Statements

Deletes existing entity. If the `IF EXISTS` clause is specified, these queries do not return an error if the entity does not exist.

## DROP DATABASE

Deletes all tables inside the `db` database, then deletes the `db` database itself.

Syntax:

```
DROP DATABASE [IF EXISTS] db [ON CLUSTER cluster]
```

## DROP TABLE

Deletes the table.

Syntax:

```
DROP [TEMPORARY] TABLE [IF EXISTS] [db.]name [ON CLUSTER cluster]
```

## DROP DICTIONARY

Deletes the dictionary.

Syntax:

```
DROP DICTIONARY [IF EXISTS] [db.]name
```

## DROP USER

Deletes a user.

Syntax:

```
DROP USER [IF EXISTS] name [,...] [ON CLUSTER cluster_name]
```

## DROP ROLE

Deletes a role. The deleted role is revoked from all the entities where it was assigned.

Syntax:

```
DROP ROLE [IF EXISTS] name [,...] [ON CLUSTER cluster_name]
```

## DROP ROW POLICY

Deletes a row policy. Deleted row policy is revoked from all the entities where it was assigned.

Syntax:

```
DROP [ROW] POLICY [IF EXISTS] name [,...] ON [database.]table [,...] [ON CLUSTER cluster_name]
```

## DROP QUOTA

Deletes a quota. The deleted quota is revoked from all the entities where it was assigned.

Syntax:

```
DROP QUOTA [IF EXISTS] name [,...] [ON CLUSTER cluster_name]
```

## DROP SETTINGS PROFILE

Deletes a settings profile. The deleted settings profile is revoked from all the entities where it was assigned.

Syntax:

```
DROP [SETTINGS] PROFILE [IF EXISTS] name [,...] [ON CLUSTER cluster_name]
```

## DROP VIEW

Deletes a view. Views can be deleted by a `DROP TABLE` command as well but `DROP VIEW` checks that `[db.]name` is a view.

Syntax:

```
DROP VIEW [IF EXISTS] [db.]name [ON CLUSTER cluster]
```

- [EXISTS]

# EXISTS Statement

```
EXISTS [TEMPORARY] [TABLE|DICTIONARY] [db.]name [INTO OUTFILE filename] [FORMAT format]
```

Returns a single `UInt8`-type column, which contains the single value `0` if the table or database does not exist, or `1` if the table exists in the specified database.

Rating: 1.4 - 33 votes

- [KILL

  # KILL Statements

  There are two kinds of kill statements: to kill a query and to kill a mutation

  ## KILL QUERY

  ```
  KILL QUERY [ON CLUSTER cluster]
    WHERE <where expression to SELECT FROM system.processes query>
    [SYNC|ASYNC|TEST]
    [FORMAT format]
  ```

  Attempts to forcibly terminate the currently running queries.
  The queries to terminate are selected from the system.processes table using the criteria defined in the `WHERE` clause of the `KILL` query.

  Examples:

  ```
  -- Forcibly terminates all queries with the specified query_id:
  KILL QUERY WHERE query_id=2-857d-4a57-9ee0-327da5d60a90

  -- Synchronously terminates all queries run by username:
  KILL QUERY WHERE user=username SYNC
  ```

  Read-only users can only stop their own queries.

  By default, the asynchronous version of queries is used (`ASYNC`), which does not wait for confirmation that queries have stopped.

  The synchronous version (`SYNC`) waits for all queries to stop and displays information about each process as it stops.
  The response contains the `kill_status` column, which can take the following values:

  1. `finished` – The query was terminated successfully.
  2. `waiting` – Waiting for the query to end after sending it a signal to terminate.
  3. The other values explain why the query can’t be stopped.

  A test query (`TEST`) only checks the user’s rights and displays a list of queries to stop.

  ## KILL MUTATION

  ```
  KILL MUTATION [ON CLUSTER cluster]
    WHERE <where expression to SELECT FROM system.mutations query>
    [TEST]
    [FORMAT format]
  ```

  Tries to cancel and remove [mutations] that are currently executing. Mutations to cancel are selected from the [`system.mutations`] table using the filter specified by the `WHERE` clause of the `KILL` query.

  A test query (`TEST`) only checks the user’s rights and displays a list of mutations to stop.

  Examples:

  ```
  -- Cancel and remove all mutations of the single table:
  KILL MUTATION WHERE database = default AND table = table

  -- Cancel the specific mutation:
  KILL MUTATION WHERE database = default AND table = table AND mutation_id = mutation_3.txt
  ```

  The query is useful when a mutation is stuck and cannot finish (e.g. if some function in the mutation query throws an exception when applied to the data contained in the table).

  Changes already made by the mutation are not rolled back.

- [OPTIMIZE]

# OPTIMIZE Statement

This query tries to initialize an unscheduled merge of data parts for tables.

Warning

`OPTIMIZE` can’t fix the `Too many parts` error.

**Syntax**

```
OPTIMIZE TABLE [db.]name [ON CLUSTER cluster] [PARTITION partition | PARTITION ID partition_id] [FINAL] [DEDUPLICATE [BY expression]]
```

The `OPTMIZE` query is supported for [MergeTree] family, the [MaterializedView] and the [Buffer] engines. Other table engines aren’t supported.

When `OPTIMIZE` is used with the [ReplicatedMergeTree] family of table engines, ClickHouse creates a task for merging and waits for execution on all nodes (if the `replication_alter_partitions_sync` setting is enabled).

- If `OPTIMIZE` does not perform a merge for any reason, it does not notify the client. To enable notifications, use the [optimize_throw_if_noop] setting.
- If you specify a `PARTITION`, only the specified partition is optimized. [How to set partition expression].
- If you specify `FINAL`, optimization is performed even when all the data is already in one part. Also merge is forced even if concurrent merges are performed.
- If you specify `DEDUPLICATE`, then completely identical rows (unless by-clause is specified) will be deduplicated (all columns are compared), it makes sense only for the MergeTree engine.

## BY expression

If you want to perform deduplication on custom set of columns rather than on all, you can specify list of columns explicitly or use any combination of [`*`], [`COLUMNS`] or [`EXCEPT`] expressions. The explictly written or implicitly expanded list of columns must include all columns specified in row ordering expression (both primary and sorting keys) and partitioning expression (partitioning key).

Note

Notice that `*` behaves just like in `SELECT`: [MATERIALIZED] and [ALIAS] columns are not used for expansion.
Also, it is an error to specify empty list of columns, or write an expression that results in an empty list of columns, or deduplicate by an `ALIAS` column.

**Syntax**

```
OPTIMIZE TABLE table DEDUPLICATE; -- all columns
OPTIMIZE TABLE table DEDUPLICATE BY *; -- excludes MATERIALIZED and ALIAS columns
OPTIMIZE TABLE table DEDUPLICATE BY colX,colY,colZ;
OPTIMIZE TABLE table DEDUPLICATE BY * EXCEPT colX;
OPTIMIZE TABLE table DEDUPLICATE BY * EXCEPT (colX, colY);
OPTIMIZE TABLE table DEDUPLICATE BY COLUMNS(column-matched-by-regex);
OPTIMIZE TABLE table DEDUPLICATE BY COLUMNS(column-matched-by-regex) EXCEPT colX;
OPTIMIZE TABLE table DEDUPLICATE BY COLUMNS(column-matched-by-regex) EXCEPT (colX, colY);
```

**Examples**

Consider the table:

```
CREATE TABLE example (
    primary_key Int32,
    secondary_key Int32,
    value UInt32,
    partition_key UInt32,
    materialized_value UInt32 MATERIALIZED 12345,
    aliased_value UInt32 ALIAS 2,
    PRIMARY KEY primary_key
) ENGINE=MergeTree
PARTITION BY partition_key
ORDER BY (primary_key, secondary_key);
INSERT INTO example (primary_key, secondary_key, value, partition_key)
VALUES (0, 0, 0, 0), (0, 0, 0, 0), (1, 1, 2, 2), (1, 1, 2, 3), (1, 1, 3, 3);
SELECT * FROM example;
```

Result:

```
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           0 │             0 │     0 │             0 │
│           0 │             0 │     0 │             0 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             2 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             3 │
│           1 │             1 │     3 │             3 │
└─────────────┴───────────────┴───────┴───────────────┘
```

When columns for deduplication are not specified, all of them are taken into account. Row is removed only if all values in all columns are equal to corresponding values in previous row:

```
OPTIMIZE TABLE example FINAL DEDUPLICATE;
SELECT * FROM example;
```

Result:

```
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             2 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           0 │             0 │     0 │             0 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             3 │
│           1 │             1 │     3 │             3 │
└─────────────┴───────────────┴───────┴───────────────┘
```

When columns are specified implicitly, the table is deduplicated by all columns that are not `ALIAS` or `MATERIALIZED`. Considering the table above, these are `primary_key`, `secondary_key`, `value`, and `partition_key` columns:

```
OPTIMIZE TABLE example FINAL DEDUPLICATE BY *;
SELECT * FROM example;
```

Result:

```
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             2 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           0 │             0 │     0 │             0 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             3 │
│           1 │             1 │     3 │             3 │
└─────────────┴───────────────┴───────┴───────────────┘
```

Deduplicate by all columns that are not `ALIAS` or `MATERIALIZED` and explicitly not `value`: `primary_key`, `secondary_key`, and `partition_key` columns.

```
OPTIMIZE TABLE example FINAL DEDUPLICATE BY * EXCEPT value;
SELECT * FROM example;
```

Result:

```
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             2 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           0 │             0 │     0 │             0 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             3 │
└─────────────┴───────────────┴───────┴───────────────┘
```

Deduplicate explicitly by `primary_key`, `secondary_key`, and `partition_key` columns:

```
OPTIMIZE TABLE example FINAL DEDUPLICATE BY primary_key, secondary_key, partition_key;
SELECT * FROM example;
```

Result:

```
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             2 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           0 │             0 │     0 │             0 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             3 │
└─────────────┴───────────────┴───────┴───────────────┘
```

Deduplicate by any column matching a regex: `primary_key`, `secondary_key`, and `partition_key` columns:

```
OPTIMIZE TABLE example FINAL DEDUPLICATE BY COLUMNS(.*_key);
SELECT * FROM example;
```

Result:

```
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           0 │             0 │     0 │             0 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             2 │
└─────────────┴───────────────┴───────┴───────────────┘
┌─primary_key─┬─secondary_key─┬─value─┬─partition_key─┐
│           1 │             1 │     2 │             3 │
└─────────────┴───────────────┴───────┴───────────────┘
```

- RENAME

# RENAME Statement

## RENAME DATABASE

Renames database, it is supported only for Atomic database engine.

```
RENAME DATABASE atomic_database1 TO atomic_database2 [ON CLUSTER cluster]
```

## RENAME TABLE

Renames one or more tables.

```
RENAME TABLE [db11.]name11 TO [db12.]name12, [db21.]name21 TO [db22.]name22, ... [ON CLUSTER cluster]
```

Renaming tables is a light operation. If you indicated another database after `TO`, the table will be moved to this database. However, the directories with databases must reside in the same file system (otherwise, an error is returned). If you rename multiple tables in one query, this is a non-atomic operation, it may be partially executed, queries in other sessions may receive the error `Table ... does not exist ..`.

- [SET]

# SET Statement

```
SET param = value
```

Assigns `value` to the `param` [setting] for the current session. You cannot change [server settings] this way.

You can also set all the values from the specified settings profile in a single query.

```
SET profile = profile-name-from-the-settings-file
```

For more information, see [Settings].

- [SET ROLE]

# SET ROLE Statement

Activates roles for the current user.

```
SET ROLE {DEFAULT | NONE | role [,...] | ALL | ALL EXCEPT role [,...]}
```

## SET DEFAULT ROLE

Sets default roles to a user.

Default roles are automatically activated at user login. You can set as default only the previously granted roles. If the role isn’t granted to a user, ClickHouse throws an exception.

```
SET DEFAULT ROLE {NONE | role [,...] | ALL | ALL EXCEPT role [,...]} TO {user|CURRENT_USER} [,...]
```

## Examples

Set multiple default roles to a user:

```
SET DEFAULT ROLE role1, role2, ... TO user
```

Set all the granted roles as default to a user:

```
SET DEFAULT ROLE ALL TO user
```

Purge default roles from a user:

```
SET DEFAULT ROLE NONE TO user
```

Set all the granted roles as default excepting some of them:

```
SET DEFAULT ROLE ALL EXCEPT role1, role2 TO user
```

- [TRUNCATE]

# TRUNCATE Statement

```
TRUNCATE TABLE [IF EXISTS] [db.]name [ON CLUSTER cluster]
```

Removes all data from a table. When the clause `IF EXISTS` is omitted, the query returns an error if the table does not exist.

The `TRUNCATE` query is not supported for [View], [File], [URL], [Buffer] and [Null] table engines.

- USE

# USE Statement

```
USE db
```

Lets you set the current database for the session.

The current database is used for searching for tables if the database is not explicitly defined in the query with a dot before the table name.

This query can’t be made when using the HTTP protocol, since there is no concept of a session.

' where id=15;
update biz_data_query_model_help_content set content_en = '# CREATE DATABASE

Creates a new database.

```
CREATE DATABASE [IF NOT EXISTS] db_name [ON CLUSTER cluster] [ENGINE = engine(...)]
```

## Clauses

### IF NOT EXISTS

If the `db_name` database already exists, then ClickHouse does not create a new database and:

- Doesn’t throw an exception if clause is specified.
- Throws an exception if clause isn’t specified.

### ON CLUSTER

ClickHouse creates the `db_name` database on all the servers of a specified cluster. More details in a Distributed DDL article.

### ENGINE

MySQL allows you to retrieve data from the remote MySQL server. By default, ClickHouse uses its own database engine. There’s also a lazy engine.' where id=16;
update biz_data_query_model_help_content set content_en = '## INSERT INTO Statement

Adding data.

Basic query format:

```
INSERT INTO [db.]table [(c1, c2, c3)] VALUES (v11, v12, v13), (v21, v22, v23), ...
```

You can specify a list of columns to insert using the `(c1, c2, c3)`. You can also use an expression with column [matcher] such as `*` and/or [modifiers] such as [APPLY], [EXCEPT], [REPLACE].

For example, consider the table:

```
SHOW CREATE insert_select_testtable;
CREATE TABLE insert_select_testtable
(
    `a` Int8,
    `b` String,
    `c` Int8
)
ENGINE = MergeTree()
ORDER BY a
INSERT INTO insert_select_testtable (*) VALUES (1, a, 1) ;
```

If you want to insert data in all the columns, except b, you need to pass so many values how many columns you chose in parenthesis then:

```
INSERT INTO insert_select_testtable (* EXCEPT(b)) Values (2, 2);
SELECT * FROM insert_select_testtable;
┌─a─┬─b─┬─c─┐
│ 2 │   │ 2 │
└───┴───┴───┘
┌─a─┬─b─┬─c─┐
│ 1 │ a │ 1 │
└───┴───┴───┘
```

In this example, we see that the second inserted row has `a` and `c` columns filled by the passed values, and `b` filled with value by default.

If a list of columns does not include all existing columns, the rest of the columns are filled with:

- The values calculated from the `DEFAULT` expressions specified in the table definition.
- Zeros and empty strings, if `DEFAULT` expressions are not defined.

Data can be passed to the INSERT in any [format] supported by ClickHouse. The format must be specified explicitly in the query:

```
INSERT INTO [db.]table [(c1, c2, c3)] FORMAT format_name data_set
```

For example, the following query format is identical to the basic version of INSERT … VALUES:

```
INSERT INTO [db.]table [(c1, c2, c3)] FORMAT Values (v11, v12, v13), (v21, v22, v23), ...
```

ClickHouse removes all spaces and one line feed (if there is one) before the data. When forming a query, we recommend putting the data on a new line after the query operators (this is important if the data begins with spaces).

Example:

```
INSERT INTO t FORMAT TabSeparated
11  Hello, world!
22  Qwerty
```

You can insert data separately from the query by using the command-line client or the HTTP interface. For more information, see the section “Interfaces”.

### Constraints

If table has constraints, their expressions will be checked for each row of inserted data. If any of those constraints is not satisfied — server will raise an exception containing constraint name and expression, the query will be stopped.

### Inserting the Results of `SELECT`

```
INSERT INTO [db.]table [(c1, c2, c3)] SELECT ...
```

Columns are mapped according to their position in the SELECT clause. However, their names in the SELECT expression and the table for INSERT may differ. If necessary, type casting is performed.

None of the data formats except Values allow setting values to expressions such as `now()`, `1 + 2`, and so on. The Values format allows limited use of expressions, but this is not recommended, because in this case inefficient code is used for their execution.

Other queries for modifying data parts are not supported: `UPDATE`, `DELETE`, `REPLACE`, `MERGE`, `UPSERT`, `INSERT UPDATE`.
However, you can delete old data using `ALTER TABLE ... DROP PARTITION`.

`FORMAT` clause must be specified in the end of query if `SELECT` clause contains table function [input()].

To insert a default value instead of `NULL` into a column with not nullable data type, enable [insert_null_as_default] setting.

### Performance Considerations

`INSERT` sorts the input data by primary key and splits them into partitions by a partition key. If you insert data into several partitions at once, it can significantly reduce the performance of the `INSERT` query. To avoid this:

- Add data in fairly large batches, such as 100,000 rows at a time.
- Group data by a partition key before uploading it to ClickHouse.

Performance will not decrease if:

- Data is added in real time.
- You upload data that is usually sorted by time.' where id=17;
update biz_data_query_model_help_content set content_en = '# Functions

There are at least* two types of functions - regular functions (they are just called “functions”) and aggregate functions. These are completely different concepts. Regular functions work as if they are applied to each row separately (for each row, the result of the function does not depend on the other rows). Aggregate functions accumulate a set of values from various rows (i.e. they depend on the entire set of rows).

In this section we discuss regular functions. For aggregate functions, see the section “Aggregate functions”.

\* - There is a third type of function that the ‘arrayJoin’ function belongs to; table functions can also be mentioned separately.*

## Strong Typing

In contrast to standard SQL, ClickHouse has strong typing. In other words, it does not make implicit conversions between types. Each function works for a specific set of types. This means that sometimes you need to use type conversion functions.

## Common Subexpression Elimination

All expressions in a query that have the same AST (the same record or same result of syntactic parsing) are considered to have identical values. Such expressions are concatenated and executed once. Identical subqueries are also eliminated this way.

## Types of Results

All functions return a single return as the result (not several values, and not zero values). The type of result is usually defined only by the types of arguments, not by the values. Exceptions are the tupleElement function (the a.N operator), and the toFixedString function.

## Constants

For simplicity, certain functions can only work with constants for some arguments. For example, the right argument of the LIKE operator must be a constant.
Almost all functions return a constant for constant arguments. The exception is functions that generate random numbers.
The ‘now’ function returns different values for queries that were run at different times, but the result is considered a constant, since constancy is only important within a single query.
A constant expression is also considered a constant (for example, the right half of the LIKE operator can be constructed from multiple constants).

Functions can be implemented in different ways for constant and non-constant arguments (different code is executed). But the results for a constant and for a true column containing only the same value should match each other.

## NULL Processing

Functions have the following behaviors:

- If at least one of the arguments of the function is `NULL`, the function result is also `NULL`.
- Special behavior that is specified individually in the description of each function. In the ClickHouse source code, these functions have `UseDefaultImplementationForNulls=false`.

## Constancy

Functions can’t change the values of their arguments – any changes are returned as the result. Thus, the result of calculating separate functions does not depend on the order in which the functions are written in the query.

## Higher-order functions, `->` operator and lambda(params, expr) function

Higher-order functions can only accept lambda functions as their functional argument. To pass a lambda function to a higher-order function use `->` operator. The left side of the arrow has a formal parameter, which is any ID, or multiple formal parameters – any IDs in a tuple. The right side of the arrow has an expression that can use these formal parameters, as well as any table columns.

Examples:

```
x -> 2 * x
str -> str != Referer
```

A lambda function that accepts multiple arguments can also be passed to a higher-order function. In this case, the higher-order function is passed several arrays of identical length that these arguments will correspond to.

For some functions the first argument (the lambda function) can be omitted. In this case, identical mapping is assumed.

## Error Handling

Some functions might throw an exception if the data is invalid. In this case, the query is canceled and an error text is returned to the client. For distributed processing, when an exception occurs on one of the servers, the other servers also attempt to abort the query.

## Evaluation of Argument Expressions

In almost all programming languages, one of the arguments might not be evaluated for certain operators. This is usually the operators `&&`, `||`, and `?:`.
But in ClickHouse, arguments of functions (operators) are always evaluated. This is because entire parts of columns are evaluated at once, instead of calculating each row separately.

## Performing Functions for Distributed Query Processing

For distributed query processing, as many stages of query processing as possible are performed on remote servers, and the rest of the stages (merging intermediate results and everything after that) are performed on the requestor server.

This means that functions can be performed on different servers.
For example, in the query `SELECT f(sum(g(x))) FROM distributed_table GROUP BY h(y),`

- if a `distributed_table` has at least two shards, the functions ‘g’ and ‘h’ are performed on remote servers, and the function ‘f’ is performed on the requestor server.
- if a `distributed_table` has only one shard, all the ‘f’, ‘g’, and ‘h’ functions are performed on this shard’s server.

The result of a function usually does not depend on which server it is performed on. However, sometimes this is important.
For example, functions that work with dictionaries use the dictionary that exists on the server they are running on.
Another example is the `hostName` function, which returns the name of the server it is running on in order to make `GROUP BY` by servers in a `SELECT` query.

If a function in a query is performed on the requestor server, but you need to perform it on remote servers, you can wrap it in an ‘any’ aggregate function or add it to a key in `GROUP BY`.' where id=18;
update biz_data_query_model_help_content set content_en = '# Arithmetic Functions

For all arithmetic functions, the result type is calculated as the smallest number type that the result fits in, if there is such a type. The minimum is taken simultaneously based on the number of bits, whether it is signed, and whether it floats. If there are not enough bits, the highest bit type is taken.

Example:

```
SELECT toTypeName(0), toTypeName(0 + 0), toTypeName(0 + 0 + 0), toTypeName(0 + 0 + 0 + 0)
```

```
┌─toTypeName(0)─┬─toTypeName(plus(0, 0))─┬─toTypeName(plus(plus(0, 0), 0))─┬─toTypeName(plus(plus(plus(0, 0), 0), 0))─┐
│ UInt8         │ UInt16                 │ UInt32                          │ UInt64                                   │
└───────────────┴────────────────────────┴─────────────────────────────────┴──────────────────────────────────────────┘
```

Arithmetic functions work for any pair of types from UInt8, UInt16, UInt32, UInt64, Int8, Int16, Int32, Int64, Float32, or Float64.

Overflow is produced the same way as in C++.

## plus(a, b), a + b operator

Calculates the sum of the numbers.
You can also add integer numbers with a date or date and time. In the case of a date, adding an integer means adding the corresponding number of days. For a date with time, it means adding the corresponding number of seconds.

## minus(a, b), a - b operator

Calculates the difference. The result is always signed.

You can also calculate integer numbers from a date or date with time. The idea is the same – see above for ‘plus’.

## multiply(a, b), a * b operator

Calculates the product of the numbers.

## divide(a, b), a / b operator

Calculates the quotient of the numbers. The result type is always a floating-point type.
It is not integer division. For integer division, use the ‘intDiv’ function.
When dividing by zero you get ‘inf’, ‘-inf’, or ‘nan’.

## intDiv(a, b)

Calculates the quotient of the numbers. Divides into integers, rounding down (by the absolute value).
An exception is thrown when dividing by zero or when dividing a minimal negative number by minus one.

## intDivOrZero(a, b)

Differs from ‘intDiv’ in that it returns zero when dividing by zero or when dividing a minimal negative number by minus one.

## modulo(a, b), a % b operator

Calculates the remainder after division.
If arguments are floating-point numbers, they are pre-converted to integers by dropping the decimal portion.
The remainder is taken in the same sense as in C++. Truncated division is used for negative numbers.
An exception is thrown when dividing by zero or when dividing a minimal negative number by minus one.

## moduloOrZero(a, b)

Differs from [modulo](https://clickhouse.tech/docs/en/sql-reference/functions/arithmetic-functions/#modulo) in that it returns zero when the divisor is zero.

## negate(a), -a operator

Calculates a number with the reverse sign. The result is always signed.

## abs(a)

Calculates the absolute value of the number (a). That is, if a \< 0, it returns -a. For unsigned types it does not do anything. For signed integer types, it returns an unsigned number.

## gcd(a, b)

Returns the greatest common divisor of the numbers.
An exception is thrown when dividing by zero or when dividing a minimal negative number by minus one.

## lcm(a, b)

Returns the least common multiple of the numbers.
An exception is thrown when dividing by zero or when dividing a minimal negative number by minus one.' where id=19;
update biz_data_query_model_help_content set content_en = '# Comparison Functions

Comparison functions always return 0 or 1 (Uint8).

The following types can be compared:

- numbers
- strings and fixed strings
- dates
- dates with times

within each group, but not between different groups.

For example, you can’t compare a date with a string. You have to use a function to convert the string to a date, or vice versa.

Strings are compared by bytes. A shorter string is smaller than all strings that start with it and that contain at least one more character.

## equals, a = b and a == b operator

## notEquals, a != b and a \<> b operator

## less, \< operator

## greater, > operator

## lessOrEquals, \<= operator

## greaterOrEquals, >= operator' where id=20;
update biz_data_query_model_help_content set content_en = '# Logical Functions

Logical functions accept any numeric types, but return a UInt8 number equal to 0 or 1.

Zero as an argument is considered “false,” while any non-zero value is considered “true”.

## and, AND operator

## or, OR operator

## not, NOT operator

## xor

' where id=21;
update biz_data_query_model_help_content set content_en = '# Type Conversion Functions

## Common Issues of Numeric Conversions

When you convert a value from one to another data type, you should remember that in common case, it is an unsafe operation that can lead to a data loss. A data loss can occur if you try to fit value from a larger data type to a smaller data type, or if you convert values between different data types.

ClickHouse has the same behavior as C++ programs.

## toInt(8|16|32|64|128|256)

Converts an input value to the [Int] data type. This function family includes:

- `toInt8(expr)` — Results in the `Int8` data type.
- `toInt16(expr)` — Results in the `Int16` data type.
- `toInt32(expr)` — Results in the `Int32` data type.
- `toInt64(expr)` — Results in the `Int64` data type.
- `toInt128(expr)` — Results in the `Int128` data type.
- `toInt256(expr)` — Results in the `Int256` data type.

**Arguments**

- `expr` — Expression returning a number or a string with the decimal representation of a number. Binary, octal, and hexadecimal representations of numbers are not supported. Leading zeroes are stripped.

**Returned value**

Integer value in the `Int8`, `Int16`, `Int32`, `Int64`, `Int128` or `Int256` data type.

Functions use rounding towards zero, meaning they truncate fractional digits of numbers.

The behavior of functions for the NaN and Inf arguments is undefined. Remember about numeric convertions issues, when using the functions.

**Example**

Query:

```
SELECT toInt64(nan), toInt32(32), toInt16(16), toInt8(8.8);
```

Result:

```
┌─────────toInt64(nan)─┬─toInt32(32)─┬─toInt16(16)─┬─toInt8(8.8)─┐
│ -9223372036854775808 │          32 │            16 │           8 │
└──────────────────────┴─────────────┴───────────────┴─────────────┘
```

## toInt(8|16|32|64|128|256)OrZero

It takes an argument of type String and tries to parse it into Int (8 | 16 | 32 | 64 | 128 | 256). If failed, returns 0.

**Example**

Query:

```
SELECT toInt64OrZero(123123), toInt8OrZero(123qwe123);
```

Result:

```
┌─toInt64OrZero(123123)─┬─toInt8OrZero(123qwe123)─┐
│                  123123 │                         0 │
└─────────────────────────┴───────────────────────────┘
```

## toInt(8|16|32|64|128|256)OrNull

It takes an argument of type String and tries to parse it into Int (8 | 16 | 32 | 64 | 128 | 256). If failed, returns NULL.

**Example**

Query:

```
SELECT toInt64OrNull(123123), toInt8OrNull(123qwe123);
```

Result:

```
┌─toInt64OrNull(123123)─┬─toInt8OrNull(123qwe123)─┐
│                  123123 │                      ᴺᵁᴸᴸ │
└─────────────────────────┴───────────────────────────┘
```

## toUInt(8|16|32|64|256)

Converts an input value to the [UInt](https://clickhouse.tech/docs/en/sql-reference/data-types/int-uint/) data type. This function family includes:

- `toUInt8(expr)` — Results in the `UInt8` data type.
- `toUInt16(expr)` — Results in the `UInt16` data type.
- `toUInt32(expr)` — Results in the `UInt32` data type.
- `toUInt64(expr)` — Results in the `UInt64` data type.
- `toUInt256(expr)` — Results in the `UInt256` data type.

**Arguments**

- `expr` — [Expression](https://clickhouse.tech/docs/en/sql-reference/syntax/#syntax-expressions) returning a number or a string with the decimal representation of a number. Binary, octal, and hexadecimal representations of numbers are not supported. Leading zeroes are stripped.

**Returned value**

Integer value in the `UInt8`, `UInt16`, `UInt32`, `UInt64` or `UInt256` data type.

Functions use [rounding towards zero](https://en.wikipedia.org/wiki/Rounding#Rounding_towards_zero), meaning they truncate fractional digits of numbers.

The behavior of functions for negative agruments and for the [NaN and Inf](https://clickhouse.tech/docs/en/sql-reference/data-types/float/#data_type-float-nan-inf) arguments is undefined. If you pass a string with a negative number, for example `-32`, ClickHouse raises an exception. Remember about [numeric convertions issues](https://clickhouse.tech/docs/en/sql-reference/functions/type-conversion-functions/#numeric-conversion-issues), when using the functions.

**Example**

Query:

```
SELECT toUInt64(nan), toUInt32(-32), toUInt16(16), toUInt8(8.8);
```

Result:

```
┌───────toUInt64(nan)─┬─toUInt32(-32)─┬─toUInt16(16)─┬─toUInt8(8.8)─┐
│ 9223372036854775808 │    4294967264 │             16 │            8 │
└─────────────────────┴───────────────┴────────────────┴──────────────┘
```

## toUInt(8|16|32|64|256)OrZero

## toUInt(8|16|32|64|256)OrNull

## toFloat(32|64)

## toFloat(32|64)OrZero

## toFloat(32|64)OrNull

## toDate

Alias: `DATE`.

## toDateOrZero

## toDateOrNull

## toDateTime

## toDateTimeOrZero

## toDateTimeOrNull

## toDecimal(32|64|128|256)

Converts `value` to the Decimal data type with precision of `S`. The `value` can be a number or a string. The `S` (scale) parameter specifies the number of decimal places.

- `toDecimal32(value, S)`
- `toDecimal64(value, S)`
- `toDecimal128(value, S)`
- `toDecimal256(value, S)`

## toDecimal(32|64|128|256)OrNull[ ](https://clickhouse.tech/docs/en/sql-reference/functions/type-conversion-functions/#todecimal3264128256ornull)

Converts an input string to a Nullable(Decimal(P,S)) data type value. This family of functions include:

- `toDecimal32OrNull(expr, S)` — Results in `Nullable(Decimal32(S))` data type.
- `toDecimal64OrNull(expr, S)` — Results in `Nullable(Decimal64(S))` data type.
- `toDecimal128OrNull(expr, S)` — Results in `Nullable(Decimal128(S))` data type.
- `toDecimal256OrNull(expr, S)` — Results in `Nullable(Decimal256(S))` data type.

These functions should be used instead of `toDecimal*()` functions, if you prefer to get a `NULL` value instead of an exception in the event of an input value parsing error.

**Arguments**

- `expr` — Expression, returns a value in the String data type. ClickHouse expects the textual representation of the decimal number. For example, `1.111`.
- `S` — Scale, the number of decimal places in the resulting value.

**Returned value**

A value in the `Nullable(Decimal(P,S))` data type. The value contains:

- Number with `S` decimal places, if ClickHouse interprets the input string as a number.
- `NULL`, if ClickHouse can’t interpret the input string as a number or if the input number contains more than `S` decimal places.

**Examples**

Query:

```
SELECT toDecimal32OrNull(toString(-1.111), 5) AS val, toTypeName(val);
```

Result:

```
┌──────val─┬─toTypeName(toDecimal32OrNull(toString(-1.111), 5))─┐
│ -1.11100 │ Nullable(Decimal(9, 5))                            │
└──────────┴────────────────────────────────────────────────────┘
```

Query:

```
SELECT toDecimal32OrNull(toString(-1.111), 2) AS val, toTypeName(val);
```

Result:

```
┌──val─┬─toTypeName(toDecimal32OrNull(toString(-1.111), 2))─┐
│ ᴺᵁᴸᴸ │ Nullable(Decimal(9, 2))                            │
└──────┴────────────────────────────────────────────────────┘
```

## toDecimal(32|64|128|256)OrZero[ ](https://clickhouse.tech/docs/en/sql-reference/functions/type-conversion-functions/#todecimal3264128256orzero)

Converts an input value to the Decimal(P,S) data type. This family of functions include:

- `toDecimal32OrZero( expr, S)` — Results in `Decimal32(S)` data type.
- `toDecimal64OrZero( expr, S)` — Results in `Decimal64(S)` data type.
- `toDecimal128OrZero( expr, S)` — Results in `Decimal128(S)` data type.
- `toDecimal256OrZero( expr, S)` — Results in `Decimal256(S)` data type.

These functions should be used instead of `toDecimal*()` functions, if you prefer to get a `0` value instead of an exception in the event of an input value parsing error.

**Arguments**

- `expr` — Expression, returns a value in the String data type. ClickHouse expects the textual representation of the decimal number. For example, `1.111`.
- `S` — Scale, the number of decimal places in the resulting value.

**Returned value**

A value in the `Nullable(Decimal(P,S))` data type. The value contains:

- Number with `S` decimal places, if ClickHouse interprets the input string as a number.
- 0 with `S` decimal places, if ClickHouse can’t interpret the input string as a number or if the input number contains more than `S` decimal places.

**Example**

Query:

```
SELECT toDecimal32OrZero(toString(-1.111), 5) AS val, toTypeName(val);
```

Result:

```
┌──────val─┬─toTypeName(toDecimal32OrZero(toString(-1.111), 5))─┐
│ -1.11100 │ Decimal(9, 5)                                      │
└──────────┴────────────────────────────────────────────────────┘
```

Query:

```
SELECT toDecimal32OrZero(toString(-1.111), 2) AS val, toTypeName(val);
```

Result:

```
┌──val─┬─toTypeName(toDecimal32OrZero(toString(-1.111), 2))─┐
│ 0.00 │ Decimal(9, 2)                                      │
└──────┴────────────────────────────────────────────────────┘
```

## toString[ ](https://clickhouse.tech/docs/en/sql-reference/functions/type-conversion-functions/#tostring)

Functions for converting between numbers, strings (but not fixed strings), dates, and dates with times.
All these functions accept one argument.

When converting to or from a string, the value is formatted or parsed using the same rules as for the TabSeparated format (and almost all other text formats). If the string can’t be parsed, an exception is thrown and the request is canceled.

When converting dates to numbers or vice versa, the date corresponds to the number of days since the beginning of the Unix epoch.
When converting dates with times to numbers or vice versa, the date with time corresponds to the number of seconds since the beginning of the Unix epoch.

The date and date-with-time formats for the toDate/toDateTime functions are defined as follows:

```
YYYY-MM-DD
YYYY-MM-DD hh:mm:ss
```

As an exception, if converting from UInt32, Int32, UInt64, or Int64 numeric types to Date, and if the number is greater than or equal to 65536, the number is interpreted as a Unix timestamp (and not as the number of days) and is rounded to the date. This allows support for the common occurrence of writing ‘toDate(unix_timestamp)’, which otherwise would be an error and would require writing the more cumbersome ‘toDate(toDateTime(unix_timestamp))’.

Conversion between a date and date with time is performed the natural way: by adding a null time or dropping the time.

Conversion between numeric types uses the same rules as assignments between different numeric types in C++.

Additionally, the toString function of the DateTime argument can take a second String argument containing the name of the time zone. Example: `Asia/Yekaterinburg` In this case, the time is formatted according to the specified time zone.

**Example**

Query:

```
SELECT
    now() AS now_local,
    toString(now(), Asia/Yekaterinburg) AS now_yekat;
```

Result:

```
┌───────────now_local─┬─now_yekat───────────┐
│ 2016-06-15 00:11:21 │ 2016-06-15 02:11:21 │
└─────────────────────┴─────────────────────┘
```

Also see the `toUnixTimestamp` function.

## toFixedString(s, N)

Converts a String type argument to a FixedString(N) type (a string with fixed length N). N must be a constant.
If the string has fewer bytes than N, it is padded with null bytes to the right. If the string has more bytes than N, an exception is thrown.

## toStringCutToZero(s)

Accepts a String or FixedString argument. Returns the String with the content truncated at the first zero byte found.

**Example**

Query:

```
SELECT toFixedString(foo, 8) AS s, toStringCutToZero(s) AS s_cut;
```

Result:

```
┌─s─────────────┬─s_cut─┐
│ foo\0\0\0\0\0 │ foo   │
└───────────────┴───────┘
```

Query:

```
SELECT toFixedString(foo\0bar, 8) AS s, toStringCutToZero(s) AS s_cut;
```

Result:

```
┌─s──────────┬─s_cut─┐
│ foo\0bar\0 │ foo   │
└────────────┴───────┘
```

## reinterpretAsUInt(8|16|32|64)

## reinterpretAsInt(8|16|32|64)

## reinterpretAsFloat(32|64)

## reinterpretAsDate

## reinterpretAsDateTime

These functions accept a string and interpret the bytes placed at the beginning of the string as a number in host order (little endian). If the string isn’t long enough, the functions work as if the string is padded with the necessary number of null bytes. If the string is longer than needed, the extra bytes are ignored. A date is interpreted as the number of days since the beginning of the Unix Epoch, and a date with time is interpreted as the number of seconds since the beginning of the Unix Epoch.

## reinterpretAsString

This function accepts a number or date or date with time, and returns a string containing bytes representing the corresponding value in host order (little endian). Null bytes are dropped from the end. For example, a UInt32 type value of 255 is a string that is one byte long.

## reinterpretAsFixedString

This function accepts a number or date or date with time, and returns a FixedString containing bytes representing the corresponding value in host order (little endian). Null bytes are dropped from the end. For example, a UInt32 type value of 255 is a FixedString that is one byte long.

## reinterpretAsUUID

Accepts 16 bytes string and returns UUID containing bytes representing the corresponding value in network byte order (big-endian). If the string isnt long enough, the function works as if the string is padded with the necessary number of null bytes to the end. If the string longer than 16 bytes, the extra bytes at the end are ignored.

**Syntax**

```
reinterpretAsUUID(fixed_string)
```

**Arguments**

- `fixed_string` — Big-endian byte string. FixedString.

**Returned value**

- The UUID type value. UUID.

**Examples**

String to UUID.

Query:

```
SELECT reinterpretAsUUID(reverse(unhex(000102030405060708090a0b0c0d0e0f)));
```

Result:

```
┌─reinterpretAsUUID(reverse(unhex(000102030405060708090a0b0c0d0e0f)))─┐
│                                  08090a0b-0c0d-0e0f-0001-020304050607 │
└───────────────────────────────────────────────────────────────────────┘
```

Going back and forth from String to UUID.

Query:

```
WITH
    generateUUIDv4() AS uuid,
    identity(lower(hex(reverse(reinterpretAsString(uuid))))) AS str,
    reinterpretAsUUID(reverse(unhex(str))) AS uuid2
SELECT uuid = uuid2;
```

Result:

```
┌─equals(uuid, uuid2)─┐
│                   1 │
└─────────────────────┘
```

## reinterpret(x, T)

Uses the same source in-memory bytes sequence for `x` value and reinterprets it to destination type.

**Syntax**

```
reinterpret(x, type)
```

**Arguments**

- `x` — Any type.
- `type` — Destination type. String.

**Returned value**

- Destination type value.

**Examples**

Query:

```
SELECT reinterpret(toInt8(-1), UInt8) as int_to_uint,
    reinterpret(toInt8(1), Float32) as int_to_float,
    reinterpret(1, UInt32) as string_to_int;
```

Result:

```
┌─int_to_uint─┬─int_to_float─┬─string_to_int─┐
│         255 │        1e-45 │            49 │
└─────────────┴──────────────┴───────────────┘
```

## CAST(x, T)

Converts input value `x` to the `T` data type. Unlike to `reinterpret` function, type conversion is performed in a natural way.

The syntax `CAST(x AS t)` is also supported.

Note

If value `x` does not fit the bounds of type `T`, the function overflows. For example, `CAST(-1, UInt8)` returns `255`.

**Syntax**

```
CAST(x, T)
```

**Arguments**

- `x` — Any type.
- `T` — Destination type. String.

**Returned value**

- Destination type value.

**Examples**

Query:

```
SELECT
    CAST(toInt8(-1), UInt8) AS cast_int_to_uint,
    CAST(toInt8(1), Float32) AS cast_int_to_float,
    CAST(1, UInt32) AS cast_string_to_int;
```

Result:

```
┌─cast_int_to_uint─┬─cast_int_to_float─┬─cast_string_to_int─┐
│              255 │                 1 │                  1 │
└──────────────────┴───────────────────┴────────────────────┘
```

Query:

```
SELECT
    2016-06-15 23:00:00 AS timestamp,
    CAST(timestamp AS DateTime) AS datetime,
    CAST(timestamp AS Date) AS date,
    CAST(timestamp, String) AS string,
    CAST(timestamp, FixedString(22)) AS fixed_string;
```

Result:

```
┌─timestamp───────────┬────────────datetime─┬───────date─┬─string──────────────┬─fixed_string──────────────┐
│ 2016-06-15 23:00:00 │ 2016-06-15 23:00:00 │ 2016-06-15 │ 2016-06-15 23:00:00 │ 2016-06-15 23:00:00\0\0\0 │
└─────────────────────┴─────────────────────┴────────────┴─────────────────────┴───────────────────────────┘
```

Conversion to FixedString(N) only works for arguments of type String or FixedString.

Type conversion to Nullable and back is supported.

**Example**

Query:

```
SELECT toTypeName(x) FROM t_null;
```

Result:

```
┌─toTypeName(x)─┐
│ Int8          │
│ Int8          │
└───────────────┘
```

Query:

```
SELECT toTypeName(CAST(x, Nullable(UInt16))) FROM t_null;
```

Result:

```
┌─toTypeName(CAST(x, Nullable(UInt16)))─┐
│ Nullable(UInt16)                        │
│ Nullable(UInt16)                        │
└─────────────────────────────────────────┘
```

**See also**

- cast_keep_nullable setting

## accurateCast(x, T)

Converts `x` to the `T` data type.

The difference from cast(x, T) is that `accurateCast` does not allow overflow of numeric types during cast if type value `x` does not fit the bounds of type `T`. For example, `accurateCast(-1, UInt8)` throws an exception.

**Example**

Query:

```
SELECT cast(-1, UInt8) as uint8;
```

Result:

```
┌─uint8─┐
│   255 │
└───────┘
```

Query:

```
SELECT accurateCast(-1, UInt8) as uint8;
```

Result:

```
Code: 70. DB::Exception: Received from localhost:9000. DB::Exception: Value in column Int8 cannot be safely converted into type UInt8: While processing accurateCast(-1, UInt8) AS uint8.
```

## accurateCastOrNull(x, T)

Converts input value `x` to the specified data type `T`. Always returns [Nullable] type and returns [NULL] if the casted value is not representable in the target type.

**Syntax**

```
accurateCastOrNull(x, T)
```

**Parameters**

- `x` — Input value.
- `T` — The name of the returned data type.

**Returned value**

- The value, converted to the specified data type `T`.

**Example**

Query:

```
SELECT toTypeName(accurateCastOrNull(5, UInt8));
```

Result:

```
┌─toTypeName(accurateCastOrNull(5, UInt8))─┐
│ Nullable(UInt8)                            │
└────────────────────────────────────────────┘
```

Query:

```
SELECT
    accurateCastOrNull(-1, UInt8) as uint8,
    accurateCastOrNull(128, Int8) as int8,
    accurateCastOrNull(Test, FixedString(2)) as fixed_string;
```

Result:

```
┌─uint8─┬─int8─┬─fixed_string─┐
│  ᴺᵁᴸᴸ │ ᴺᵁᴸᴸ │ ᴺᵁᴸᴸ         │
└───────┴──────┴──────────────┘
```

## toInterval(Year|Quarter|Month|Week|Day|Hour|Minute|Second)

Converts a Number type argument to an [Interval] data type.

**Syntax**

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

**Arguments**

- `number` — Duration of interval. Positive integer number.

**Returned values**

- The value in `Interval` data type.

**Example**

Query:

```
WITH
    toDate(2019-01-01) AS date,
    INTERVAL 1 WEEK AS interval_week,
    toIntervalWeek(1) AS interval_to_week
SELECT
    date + interval_week,
    date + interval_to_week;
```

Result:

```
┌─plus(date, interval_week)─┬─plus(date, interval_to_week)─┐
│                2019-01-08 │                   2019-01-08 │
└───────────────────────────┴──────────────────────────────┘
```

## parseDateTimeBestEffort

## parseDateTime32BestEffort

Converts a date and time in the String representation to DateTime data type.

The function parses ISO 8601,RFC 1123 - 5.2.14 RFC-822 Date and Time Specification, ClickHouse’s and some other date and time formats.

**Syntax**

```
parseDateTimeBestEffort(time_string [, time_zone])
```

**Arguments**

- `time_string` — String containing a date and time to convert. String.
- `time_zone` — Time zone. The function parses `time_string` according to the time zone. String.

**Supported non-standard formats**

- A string containing 9..10 digit unix timestamp.
- A string with a date and a time component: `YYYYMMDDhhmmss`, `DD/MM/YYYY hh:mm:ss`, `DD-MM-YY hh:mm`, `YYYY-MM-DD hh:mm:ss`, etc.
- A string with a date, but no time component: `YYYY`, `YYYYMM`, `YYYY*MM`, `DD/MM/YYYY`, `DD-MM-YY` etc.
- A string with a day and time: `DD`, `DD hh`, `DD hh:mm`. In this case `YYYY-MM` are substituted as `2000-01`.
- A string that includes the date and time along with time zone offset information: `YYYY-MM-DD hh:mm:ss ±h:mm`, etc. For example, `2020-12-12 17:36:00 -5:00`.

For all of the formats with separator the function parses months names expressed by their full name or by the first three letters of a month name. Examples: `24/DEC/18`, `24-Dec-18`, `01-September-2018`.

**Returned value**

- `time_string` converted to the `DateTime` data type.

**Examples**

Query:

```
SELECT parseDateTimeBestEffort(12/12/2020 12:12:57)
AS parseDateTimeBestEffort;
```

Result:

```
┌─parseDateTimeBestEffort─┐
│     2020-12-12 12:12:57 │
└─────────────────────────┘
```

Query:

```
SELECT parseDateTimeBestEffort(Sat, 18 Aug 2018 07:22:16 GMT, Europe/Moscow)
AS parseDateTimeBestEffort;
```

Result:

```
┌─parseDateTimeBestEffort─┐
│     2018-08-18 10:22:16 │
└─────────────────────────┘
```

Query:

```
SELECT parseDateTimeBestEffort(1284101485)
AS parseDateTimeBestEffort;
```

Result:

```
┌─parseDateTimeBestEffort─┐
│     2015-07-07 12:04:41 │
└─────────────────────────┘
```

Query:

```
SELECT parseDateTimeBestEffort(2018-12-12 10:12:12)
AS parseDateTimeBestEffort;
```

Result:

```
┌─parseDateTimeBestEffort─┐
│     2018-12-12 10:12:12 │
└─────────────────────────┘
```

Query:

```
SELECT parseDateTimeBestEffort(10 20:19);
```

Result:

```
┌─parseDateTimeBestEffort(10 20:19)─┐
│                 2000-01-10 20:19:00 │
└─────────────────────────────────────┘
```

**See Also**

- ISO 8601 announcement by @xkcd
- RFC 1123
- toDate
- toDateTime

## parseDateTimeBestEffortUS

This function is similar to parseDateTimeBestEffort, the only difference is that this function prefers US date format (`MM/DD/YYYY` etc.) in case of ambiguity.

**Syntax**

```
parseDateTimeBestEffortUS(time_string [, time_zone])
```

**Arguments**

- `time_string` — String containing a date and time to convert.String.
- `time_zone` — Time zone. The function parses `time_string` according to the time zone.String.

**Supported non-standard formats**

- A string containing 9..10 digit unix timestamp.
- A string with a date and a time component: `YYYYMMDDhhmmss`, `MM/DD/YYYY hh:mm:ss`, `MM-DD-YY hh:mm`, `YYYY-MM-DD hh:mm:ss`, etc.
- A string with a date, but no time component: `YYYY`, `YYYYMM`, `YYYY*MM`, `MM/DD/YYYY`, `MM-DD-YY` etc.
- A string with a day and time: `DD`, `DD hh`, `DD hh:mm`. In this case, `YYYY-MM` are substituted as `2000-01`.
- A string that includes the date and time along with time zone offset information: `YYYY-MM-DD hh:mm:ss ±h:mm`, etc. For example, `2020-12-12 17:36:00 -5:00`.

**Returned value**

- `time_string` converted to the `DateTime` data type.

**Examples**

Query:

```
SELECT parseDateTimeBestEffortUS(09/12/2020 12:12:57)
AS parseDateTimeBestEffortUS;
```

Result:

```
┌─parseDateTimeBestEffortUS─┐
│     2020-09-12 12:12:57   │
└─────────────────────────——┘
```

Query:

```
SELECT parseDateTimeBestEffortUS(09-12-2020 12:12:57)
AS parseDateTimeBestEffortUS;
```

Result:

```
┌─parseDateTimeBestEffortUS─┐
│     2020-09-12 12:12:57   │
└─────────────────────────——┘
```

Query:

```
SELECT parseDateTimeBestEffortUS(09.12.2020 12:12:57)
AS parseDateTimeBestEffortUS;
```

Result:

```
┌─parseDateTimeBestEffortUS─┐
│     2020-09-12 12:12:57   │
└─────────────────────────——┘
```

## parseDateTimeBestEffortOrNull

## parseDateTime32BestEffortOrNull

Same as for parseDateTimeBestEffort except that it returns `NULL` when it encounters a date format that cannot be processed.

## parseDateTimeBestEffortOrZero

## parseDateTime32BestEffortOrZero

Same as for parseDateTimeBestEffort except that it returns zero date or zero date time when it encounters a date format that cannot be processed.

## parseDateTimeBestEffortUSOrNull

Same as parseDateTimeBestEffortUS function except that it returns `NULL` when it encounters a date format that cannot be processed.

**Syntax**

```
parseDateTimeBestEffortUSOrNull(time_string[, time_zone])
```

**Parameters**

- `time_string` — String containing a date or date with time to convert. The date must be in the US date format (`MM/DD/YYYY`, etc). String.
- `time_zone` — Timezone. The function parses `time_string` according to the timezone. Optional. String.

**Supported non-standard formats**

- A string containing 9..10 digit unix timestamp
- A string with a date and a time components: `YYYYMMDDhhmmss`, `MM/DD/YYYY hh:mm:ss`, `MM-DD-YY hh:mm`, `YYYY-MM-DD hh:mm:ss`, etc.
- A string with a date, but no time component: `YYYY`, `YYYYMM`, `YYYY*MM`, `MM/DD/YYYY`, `MM-DD-YY`, etc.
- A string with a day and time: `DD`, `DD hh`, `DD hh:mm`. In this case, `YYYY-MM` are substituted with `2000-01`.
- A string that includes date and time along with timezone offset information: `YYYY-MM-DD hh:mm:ss ±h:mm`, etc. For example, `2020-12-12 17:36:00 -5:00`.

**Returned values**

- `time_string` converted to theDateTime data type.
- `NULL` if the input string cannot be converted to the `DateTime` data type.

**Examples**

Query:

```
SELECT parseDateTimeBestEffortUSOrNull(02/10/2021 21:12:57) AS parseDateTimeBestEffortUSOrNull;
```

Result:

```
┌─parseDateTimeBestEffortUSOrNull─┐
│             2021-02-10 21:12:57 │
└─────────────────────────────────┘
```

Query:

```
SELECT parseDateTimeBestEffortUSOrNull(02-10-2021 21:12:57 GMT, Europe/Moscow) AS parseDateTimeBestEffortUSOrNull;
```

Result:

```
┌─parseDateTimeBestEffortUSOrNull─┐
│             2021-02-11 00:12:57 │
└─────────────────────────────────┘
```

Query:

```
SELECT parseDateTimeBestEffortUSOrNull(02.10.2021) AS parseDateTimeBestEffortUSOrNull;
```

Result:

```
┌─parseDateTimeBestEffortUSOrNull─┐
│             2021-02-10 00:00:00 │
└─────────────────────────────────┘
```

Query:

```
SELECT parseDateTimeBestEffortUSOrNull(10.2021) AS parseDateTimeBestEffortUSOrNull;
```

Result:

```
┌─parseDateTimeBestEffortUSOrNull─┐
│                            ᴺᵁᴸᴸ │
└─────────────────────────────────┘
```

## parseDateTimeBestEffortUSOrZero

Same as parseDateTimeBestEffortUS function except that it returns zero date (`1970-01-01`) or zero date with time (`1970-01-01 00:00:00`) when it encounters a date format that cannot be processed.

**Syntax**

```
parseDateTimeBestEffortUSOrZero(time_string[, time_zone])
```

**Parameters**

- `time_string` — String containing a date or date with time to convert. The date must be in the US date format (`MM/DD/YYYY`, etc). String.
- `time_zone` — Timezone. The function parses `time_string` according to the timezone. Optional. String.

**Supported non-standard formats**

- A string containing 9..10 digit unix timestamp
- A string with a date and a time components: `YYYYMMDDhhmmss`, `MM/DD/YYYY hh:mm:ss`, `MM-DD-YY hh:mm`, `YYYY-MM-DD hh:mm:ss`, etc.
- A string with a date, but no time component: `YYYY`, `YYYYMM`, `YYYY*MM`, `MM/DD/YYYY`, `MM-DD-YY`, etc.
- A string with a day and time: `DD`, `DD hh`, `DD hh:mm`. In this case, `YYYY-MM` are substituted with `2000-01`.
- A string that includes date and time along with timezone offset information: `YYYY-MM-DD hh:mm:ss ±h:mm`, etc. For example, `2020-12-12 17:36:00 -5:00`.

**Returned values**

- `time_string` converted to the DateTime data type.
- Zero date or zero date with time if the input string cannot be converted to the `DateTime` data type.

**Examples**

Query:

```
SELECT parseDateTimeBestEffortUSOrZero(02/10/2021 21:12:57) AS parseDateTimeBestEffortUSOrZero;
```

Result:

```
┌─parseDateTimeBestEffortUSOrZero─┐
│             2021-02-10 21:12:57 │
└─────────────────────────────────┘
```

Query:

```
SELECT parseDateTimeBestEffortUSOrZero(02-10-2021 21:12:57 GMT, Europe/Moscow) AS parseDateTimeBestEffortUSOrZero;
```

Result:

```
┌─parseDateTimeBestEffortUSOrZero─┐
│             2021-02-11 00:12:57 │
└─────────────────────────────────┘
```

Query:

```
SELECT parseDateTimeBestEffortUSOrZero(02.10.2021) AS parseDateTimeBestEffortUSOrZero;
```

Result:

```
┌─parseDateTimeBestEffortUSOrZero─┐
│             2021-02-10 00:00:00 │
└─────────────────────────────────┘
```

Query:

```
SELECT parseDateTimeBestEffortUSOrZero(02.2021) AS parseDateTimeBestEffortUSOrZero;
```

Result:

```
┌─parseDateTimeBestEffortUSOrZero─┐
│             1970-01-01 00:00:00 │
└─────────────────────────────────┘
```

## parseDateTime64BestEffort

Same as parseDateTimeBestEffort function but also parse milliseconds and microseconds and returns DateTime data type.

**Syntax**

```
parseDateTime64BestEffort(time_string [, precision [, time_zone]])
```

**Parameters**

- `time_string` — String containing a date or date with time to convert. String.
- `precision` — Required precision. `3` — for milliseconds, `6` — for microseconds. Default — `3`. Optional. UInt8.
- `time_zone` — Timezone. The function parses `time_string` according to the timezone. Optional. String.

**Returned value**

- `time_string` converted to the DateTime data type.

**Examples**

Query:

```
SELECT parseDateTime64BestEffort(2021-01-01) AS a, toTypeName(a) AS t
UNION ALL
SELECT parseDateTime64BestEffort(2021-01-01 01:01:00.12346) AS a, toTypeName(a) AS t
UNION ALL
SELECT parseDateTime64BestEffort(2021-01-01 01:01:00.12346,6) AS a, toTypeName(a) AS t
UNION ALL
SELECT parseDateTime64BestEffort(2021-01-01 01:01:00.12346,3,Europe/Moscow) AS a, toTypeName(a) AS t
FORMAT PrettyCompactMonoBlock;
```

Result:

```
┌──────────────────────────a─┬─t──────────────────────────────┐
│ 2021-01-01 01:01:00.123000 │ DateTime64(3)                  │
│ 2021-01-01 00:00:00.000000 │ DateTime64(3)                  │
│ 2021-01-01 01:01:00.123460 │ DateTime64(6)                  │
│ 2020-12-31 22:01:00.123000 │ DateTime64(3, Europe/Moscow) │
└────────────────────────────┴────────────────────────────────┘
```

## parseDateTime64BestEffortOrNull

Same as for parseDateTime64BestEffort except that it returns `NULL` when it encounters a date format that cannot be processed.

## parseDateTime64BestEffortOrZero

Same as for parseDateTime64BestEffort except that it returns zero date or zero date time when it encounters a date format that cannot be processed.

## toLowCardinality[ ](https://clickhouse.tech/docs/en/sql-reference/functions/type-conversion-functions/#tolowcardinality)

Converts input parameter to the LowCardianlity version of same data type.

To convert data from the `LowCardinality` data type use the CAST function. For example, `CAST(x as String)`.

**Syntax**

```
toLowCardinality(expr)
```

**Arguments**

- `expr` — Expression resulting in one of the supported data types.

**Returned values**

- Result of `expr`.

Type: `LowCardinality(expr_result_type)`

**Example**

Query:

```
SELECT toLowCardinality(1);
```

Result:

```
┌─toLowCardinality(1)─┐
│ 1                     │
└───────────────────────┘
```

## toUnixTimestamp64Milli

## toUnixTimestamp64Micro

## toUnixTimestamp64Nano

Converts a `DateTime64` to a `Int64` value with fixed sub-second precision. Input value is scaled up or down appropriately depending on it precision.

Note

The output value is a timestamp in UTC, not in the timezone of `DateTime64`.

**Syntax**

```
toUnixTimestamp64Milli(value)
```

**Arguments**

- `value` — DateTime64 value with any precision.

**Returned value**

- `value` converted to the `Int64` data type.

**Examples**

Query:

```
WITH toDateTime64(2019-09-16 19:20:12.345678910, 6) AS dt64
SELECT toUnixTimestamp64Milli(dt64);
```

Result:

```
┌─toUnixTimestamp64Milli(dt64)─┐
│                1568650812345 │
└──────────────────────────────┘
```

Query:

```
WITH toDateTime64(2019-09-16 19:20:12.345678910, 6) AS dt64
SELECT toUnixTimestamp64Nano(dt64);
```

Result:

```
┌─toUnixTimestamp64Nano(dt64)─┐
│         1568650812345678000 │
└─────────────────────────────┘
```

## fromUnixTimestamp64Milli

## fromUnixTimestamp64Micro

## fromUnixTimestamp64Nano

Converts an `Int64` to a `DateTime64` value with fixed sub-second precision and optional timezone. Input value is scaled up or down appropriately depending on it’s precision. Please note that input value is treated as UTC timestamp, not timestamp at given (or implicit) timezone.

**Syntax**

```
fromUnixTimestamp64Milli(value [, ti])
```

**Arguments**

- `value` — `Int64` value with any precision.
- `timezone` — `String` (optional) timezone name of the result.

**Returned value**

- `value` converted to the `DateTime64` data type.

**Example**

Query:

```
WITH CAST(1234567891011, Int64) AS i64
SELECT fromUnixTimestamp64Milli(i64, UTC);
```

Result:

```
┌─fromUnixTimestamp64Milli(i64, UTC)─┐
│              2009-02-13 23:31:31.011 │
└──────────────────────────────────────┘
```

## formatRow

Converts arbitrary expressions into a string via given format.

**Syntax**

```
formatRow(format, x, y, ...)
```

**Arguments**

- `format` — Text format. For example, CSV,TSV.
- `x`,`y`, ... — Expressions.

**Returned value**

- A formatted string (for text formats its usually terminated with the new line character).

**Example**

Query:

```
SELECT formatRow(CSV, number, good)
FROM numbers(3);
```

Result:

```
┌─formatRow(CSV, number, good)─┐
│ 0,"good"
                         │
│ 1,"good"
                         │
│ 2,"good"
                         │
└──────────────────────────────────┘
```

## formatRowNoNewline

Converts arbitrary expressions into a string via given format. The function trims the last `\n` if any.

**Syntax**

```
formatRowNoNewline(format, x, y, ...)
```

**Arguments**

- `format` — Text format. For example, [CSV], [TSV].
- `x`,`y`, ... — Expressions.

**Returned value**

- A formatted string.

**Example**

Query:

```
SELECT formatRowNoNewline(CSV, number, good)
FROM numbers(3);
```

Result:

```
┌─formatRowNoNewline(CSV, number, good)─┐
│ 0,"good"                                  │
│ 1,"good"                                  │
│ 2,"good"                                  │
└───────────────────────────────────────────┘
```

' where id=22;
update biz_data_query_model_help_content set content_en = '# IN Operators

The `IN`, `NOT IN`, `GLOBAL IN`, and `GLOBAL NOT IN` operators are covered separately, since their functionality is quite rich.

The left side of the operator is either a single column or a tuple.

Examples:

```
SELECT UserID IN (123, 456) FROM ...
SELECT (CounterID, UserID) IN ((34, 123), (101500, 456)) FROM ...
```

If the left side is a single column that is in the index, and the right side is a set of constants, the system uses the index for processing the query.

Don’t list too many values explicitly (i.e. millions). If a data set is large, put it in a temporary table (for example, see the section External data for query processing), then use a subquery.

The right side of the operator can be a set of constant expressions, a set of tuples with constant expressions (shown in the examples above), or the name of a database table or SELECT subquery in brackets.

ClickHouse allows types to differ in the left and the right parts of `IN` subquery. In this case it converts the left side value to the type of the right side, as if the accurateCastOrNull function is applied. That means, that the data type becomes Nullable, and if the conversion cannot be performed, it returns NULL.

**Example**

Query:

```
SELECT 1 IN (SELECT 1);
```

Result:

```
┌─in(1, _subquery49)─┐
│                    1 │
└──────────────────────┘
```

If the right side of the operator is the name of a table (for example, `UserID IN users`), this is equivalent to the subquery `UserID IN (SELECT * FROM users)`. Use this when working with external data that is sent along with the query. For example, the query can be sent together with a set of user IDs loaded to the ‘users’ temporary table, which should be filtered.

If the right side of the operator is a table name that has the Set engine (a prepared data set that is always in RAM), the data set will not be created over again for each query.

The subquery may specify more than one column for filtering tuples.
Example:

```
SELECT (CounterID, UserID) IN (SELECT CounterID, UserID FROM ...) FROM ...
```

The columns to the left and right of the IN operator should have the same type.

The IN operator and subquery may occur in any part of the query, including in aggregate functions and lambda functions.
Example:

```
SELECT
    EventDate,
    avg(UserID IN
    (
        SELECT UserID
        FROM test.hits
        WHERE EventDate = toDate(2014-03-17)
    )) AS ratio
FROM test.hits
GROUP BY EventDate
ORDER BY EventDate ASC
┌──EventDate─┬────ratio─┐
│ 2014-03-17 │        1 │
│ 2014-03-18 │ 0.807696 │
│ 2014-03-19 │ 0.755406 │
│ 2014-03-20 │ 0.723218 │
│ 2014-03-21 │ 0.697021 │
│ 2014-03-22 │ 0.647851 │
│ 2014-03-23 │ 0.648416 │
└────────────┴──────────┘
```

For each day after March 17th, count the percentage of pageviews made by users who visited the site on March 17th.
A subquery in the IN clause is always run just one time on a single server. There are no dependent subqueries.

## NULL Processing

During request processing, the `IN` operator assumes that the result of an operation with NULL always equals `0`, regardless of whether `NULL` is on the right or left side of the operator. `NULL` values are not included in any dataset, do not correspond to each other and cannot be compared if transform_null_in = 0.

Here is an example with the `t_null` table:

```
┌─x─┬────y─┐
│ 1 │ ᴺᵁᴸᴸ │
│ 2 │    3 │
└───┴──────┘
```

Running the query `SELECT x FROM t_null WHERE y IN (NULL,3)` gives you the following result:

```
┌─x─┐
│ 2 │
└───┘
```

You can see that the row in which `y = NULL` is thrown out of the query results. This is because ClickHouse can’t decide whether `NULL` is included in the `(NULL,3)` set, returns `0` as the result of the operation, and `SELECT` excludes this row from the final output.

```
SELECT y IN (NULL, 3)
FROM t_null
┌─in(y, tuple(NULL, 3))─┐
│                     0 │
│                     1 │
└───────────────────────┘
```

## Distributed Subqueries[ ](https://clickhouse.tech/docs/en/sql-reference/operators/in/#select-distributed-subqueries)

There are two options for IN-s with subqueries (similar to JOINs): normal `IN` / `JOIN` and `GLOBAL IN` / `GLOBAL JOIN`. They differ in how they are run for distributed query processing.

Attention

Remember that the algorithms described below may work differently depending on the settings `distributed_product_mode` setting.

When using the regular IN, the query is sent to remote servers, and each of them runs the subqueries in the `IN` or `JOIN` clause.

When using `GLOBAL IN` / `GLOBAL JOINs`, first all the subqueries are run for `GLOBAL IN` / `GLOBAL JOINs`, and the results are collected in temporary tables. Then the temporary tables are sent to each remote server, where the queries are run using this temporary data.

For a non-distributed query, use the regular `IN` / `JOIN`.

Be careful when using subqueries in the `IN` / `JOIN` clauses for distributed query processing.

Let’s look at some examples. Assume that each server in the cluster has a normal **local_table**. Each server also has a **distributed_table** table with the **Distributed** type, which looks at all the servers in the cluster.

For a query to the **distributed_table**, the query will be sent to all the remote servers and run on them using the **local_table**.

For example, the query

```
SELECT uniq(UserID) FROM distributed_table
```

will be sent to all remote servers as

```
SELECT uniq(UserID) FROM local_table
```

and run on each of them in parallel, until it reaches the stage where intermediate results can be combined. Then the intermediate results will be returned to the requestor server and merged on it, and the final result will be sent to the client.

Now let’s examine a query with IN:

```
SELECT uniq(UserID) FROM distributed_table WHERE CounterID = 101500 AND UserID IN (SELECT UserID FROM local_table WHERE CounterID = 34)
```

- Calculation of the intersection of audiences of two sites.

This query will be sent to all remote servers as

```
SELECT uniq(UserID) FROM local_table WHERE CounterID = 101500 AND UserID IN (SELECT UserID FROM local_table WHERE CounterID = 34)
```

In other words, the data set in the IN clause will be collected on each server independently, only across the data that is stored locally on each of the servers.

This will work correctly and optimally if you are prepared for this case and have spread data across the cluster servers such that the data for a single UserID resides entirely on a single server. In this case, all the necessary data will be available locally on each server. Otherwise, the result will be inaccurate. We refer to this variation of the query as “local IN”.

To correct how the query works when data is spread randomly across the cluster servers, you could specify **distributed_table** inside a subquery. The query would look like this:

```
SELECT uniq(UserID) FROM distributed_table WHERE CounterID = 101500 AND UserID IN (SELECT UserID FROM distributed_table WHERE CounterID = 34)
```

This query will be sent to all remote servers as

```
SELECT uniq(UserID) FROM local_table WHERE CounterID = 101500 AND UserID IN (SELECT UserID FROM distributed_table WHERE CounterID = 34)
```

The subquery will begin running on each remote server. Since the subquery uses a distributed table, the subquery that is on each remote server will be resent to every remote server as

```
SELECT UserID FROM local_table WHERE CounterID = 34
```

For example, if you have a cluster of 100 servers, executing the entire query will require 10,000 elementary requests, which is generally considered unacceptable.

In such cases, you should always use GLOBAL IN instead of IN. Let’s look at how it works for the query

```
SELECT uniq(UserID) FROM distributed_table WHERE CounterID = 101500 AND UserID GLOBAL IN (SELECT UserID FROM distributed_table WHERE CounterID = 34)
```

The requestor server will run the subquery

```
SELECT UserID FROM distributed_table WHERE CounterID = 34
```

and the result will be put in a temporary table in RAM. Then the request will be sent to each remote server as

```
SELECT uniq(UserID) FROM local_table WHERE CounterID = 101500 AND UserID GLOBAL IN _data1
```

and the temporary table `_data1` will be sent to every remote server with the query (the name of the temporary table is implementation-defined).

This is more optimal than using the normal IN. However, keep the following points in mind:

1. When creating a temporary table, data is not made unique. To reduce the volume of data transmitted over the network, specify DISTINCT in the subquery. (You do not need to do this for a normal IN.)
2. The temporary table will be sent to all the remote servers. Transmission does not account for network topology. For example, if 10 remote servers reside in a datacenter that is very remote in relation to the requestor server, the data will be sent 10 times over the channel to the remote datacenter. Try to avoid large data sets when using GLOBAL IN.
3. When transmitting data to remote servers, restrictions on network bandwidth are not configurable. You might overload the network.
4. Try to distribute data across servers so that you do not need to use GLOBAL IN on a regular basis.
5. If you need to use GLOBAL IN often, plan the location of the ClickHouse cluster so that a single group of replicas resides in no more than one data center with a fast network between them, so that a query can be processed entirely within a single data center.

It also makes sense to specify a local table in the `GLOBAL IN` clause, in case this local table is only available on the requestor server and you want to use data from it on remote servers.

### Distributed Subqueries and max_parallel_replicas[ ](https://clickhouse.tech/docs/en/sql-reference/operators/in/#max_parallel_replica-subqueries)

When max_parallel_replicas is greater than 1, distributed queries are further transformed. For example, the following:

```
SELECT CounterID, count() FROM distributed_table_1 WHERE UserID IN (SELECT UserID FROM local_table_2 WHERE CounterID < 100)
SETTINGS max_parallel_replicas=3
```

is transformed on each server into

```
SELECT CounterID, count() FROM local_table_1 WHERE UserID IN (SELECT UserID FROM local_table_2 WHERE CounterID < 100)
SETTINGS parallel_replicas_count=3, parallel_replicas_offset=M
```

where M is between 1 and 3 depending on which replica the local query is executing on. These settings affect every MergeTree-family table in the query and have the same effect as applying `SAMPLE 1/3 OFFSET (M-1)/3` on each table.

Therefore adding the max_parallel_replicas setting will only produce correct results if both tables have the same replication scheme and are sampled by UserID or a subkey of it. In particular, if local_table_2 does not have a sampling key, incorrect results will be produced. The same rule applies to JOIN.

One workaround if local_table_2 does not meet the requirements, is to use `GLOBAL IN` or `GLOBAL JOIN`.' where id=23;
update biz_data_query_model_help_content set content_en = '# Introspection Functions

You can use functions described in this chapter to introspect ELF and DWARF for query profiling.

Warning

These functions are slow and may impose security considerations.

For proper operation of introspection functions:

- Install the `clickhouse-common-static-dbg` package.

- Set the allow_introspection_functions setting to 1.

  ```
  For security reasons introspection functions are disabled by default.
  ```

ClickHouse saves profiler reports to the trace_log system table. Make sure the table and profiler are configured properly.

## addressToLine

Converts virtual memory address inside ClickHouse server process to the filename and the line number in ClickHouse source code.

If you use official ClickHouse packages, you need to install the `clickhouse-common-static-dbg` package.

**Syntax**

```
addressToLine(address_of_binary_instruction)
```

**Arguments**

- `address_of_binary_instruction` (UInt64) — Address of instruction in a running process.

**Returned value**

- Source code filename and the line number in this file delimited by colon.

  ```
  For example, `/build/obj-x86_64-linux-gnu/../src/Common/ThreadPool.cpp:199`, where `199` is a line number.
  ```

- Name of a binary, if the function couldn’t find the debug information.

- Empty string, if the address is not valid.

Type:String.

**Example**

Enabling introspection functions:

```
SET allow_introspection_functions=1;
```

Selecting the first string from the `trace_log` system table:

```
SELECT * FROM system.trace_log LIMIT 1 \G;
Row 1:
──────
event_date:              2019-11-19
event_time:              2019-11-19 18:57:23
revision:                54429
timer_type:              Real
thread_number:           48
query_id:                421b6855-1858-45a5-8f37-f383409d6d72
trace:                   [140658411141617,94784174532828,94784076370703,94784076372094,94784076361020,94784175007680,140658411116251,140658403895439]
```

The `trace` field contains the stack trace at the moment of sampling.

Getting the source code filename and the line number for a single address:

```
SELECT addressToLine(94784076370703) \G;
Row 1:
──────
addressToLine(94784076370703): /build/obj-x86_64-linux-gnu/../src/Common/ThreadPool.cpp:199
```

Applying the function to the whole stack trace:

```
SELECT
    arrayStringConcat(arrayMap(x -> addressToLine(x), trace), \n) AS trace_source_code_lines
FROM system.trace_log
LIMIT 1
\G
```

The arrayMap function allows to process each individual element of the `trace` array by the `addressToLine` function. The result of this processing you see in the `trace_source_code_lines` column of output.

```
Row 1:
──────
trace_source_code_lines: /lib/x86_64-linux-gnu/libpthread-2.27.so
/usr/lib/debug/usr/bin/clickhouse
/build/obj-x86_64-linux-gnu/../src/Common/ThreadPool.cpp:199
/build/obj-x86_64-linux-gnu/../src/Common/ThreadPool.h:155
/usr/include/c++/9/bits/atomic_base.h:551
/usr/lib/debug/usr/bin/clickhouse
/lib/x86_64-linux-gnu/libpthread-2.27.so
/build/glibc-OTsEL5/glibc-2.27/misc/../sysdeps/unix/sysv/linux/x86_64/clone.S:97
```

## addressToSymbol

Converts virtual memory address inside ClickHouse server process to the symbol from ClickHouse object files.

**Syntax**

```
addressToSymbol(address_of_binary_instruction)
```

**Arguments**

- `address_of_binary_instruction` (UInt64) — Address of instruction in a running process.

**Returned value**

- Symbol from ClickHouse object files.
- Empty string, if the address is not valid.

Type: String.

**Example**

Enabling introspection functions:

```
SET allow_introspection_functions=1;
```

Selecting the first string from the `trace_log` system table:

```
SELECT * FROM system.trace_log LIMIT 1 \G;
Row 1:
──────
event_date:    2019-11-20
event_time:    2019-11-20 16:57:59
revision:      54429
timer_type:    Real
thread_number: 48
query_id:      724028bf-f550-45aa-910d-2af6212b94ac
trace:         [94138803686098,94138815010911,94138815096522,94138815101224,94138815102091,94138814222988,94138806823642,94138814457211,94138806823642,94138814457211,94138806823642,94138806795179,94138806796144,94138753770094,94138753771646,94138753760572,94138852407232,140399185266395,140399178045583]
```

The `trace` field contains the stack trace at the moment of sampling.

Getting a symbol for a single address:

```
SELECT addressToSymbol(94138803686098) \G;
Row 1:
──────
addressToSymbol(94138803686098): _ZNK2DB24IAggregateFunctionHelperINS_20AggregateFunctionSumImmNS_24AggregateFunctionSumDataImEEEEE19addBatchSinglePlaceEmPcPPKNS_7IColumnEPNS_5ArenaE
```

Applying the function to the whole stack trace:

```
SELECT
    arrayStringConcat(arrayMap(x -> addressToSymbol(x), trace), \n) AS trace_symbols
FROM system.trace_log
LIMIT 1
\G
```

The arrayMap function allows to process each individual element of the `trace` array by the `addressToSymbols` function. The result of this processing you see in the `trace_symbols` column of output.

```
Row 1:
──────
trace_symbols: _ZNK2DB24IAggregateFunctionHelperINS_20AggregateFunctionSumImmNS_24AggregateFunctionSumDataImEEEEE19addBatchSinglePlaceEmPcPPKNS_7IColumnEPNS_5ArenaE
_ZNK2DB10Aggregator21executeWithoutKeyImplERPcmPNS0_28AggregateFunctionInstructionEPNS_5ArenaE
_ZN2DB10Aggregator14executeOnBlockESt6vectorIN3COWINS_7IColumnEE13immutable_ptrIS3_EESaIS6_EEmRNS_22AggregatedDataVariantsERS1_IPKS3_SaISC_EERS1_ISE_SaISE_EERb
_ZN2DB10Aggregator14executeOnBlockERKNS_5BlockERNS_22AggregatedDataVariantsERSt6vectorIPKNS_7IColumnESaIS9_EERS6_ISB_SaISB_EERb
_ZN2DB10Aggregator7executeERKSt10shared_ptrINS_17IBlockInputStreamEERNS_22AggregatedDataVariantsE
_ZN2DB27AggregatingBlockInputStream8readImplEv
_ZN2DB17IBlockInputStream4readEv
_ZN2DB26ExpressionBlockInputStream8readImplEv
_ZN2DB17IBlockInputStream4readEv
_ZN2DB26ExpressionBlockInputStream8readImplEv
_ZN2DB17IBlockInputStream4readEv
_ZN2DB28AsynchronousBlockInputStream9calculateEv
_ZNSt17_Function_handlerIFvvEZN2DB28AsynchronousBlockInputStream4nextEvEUlvE_E9_M_invokeERKSt9_Any_data
_ZN14ThreadPoolImplI20ThreadFromGlobalPoolE6workerESt14_List_iteratorIS0_E
_ZZN20ThreadFromGlobalPoolC4IZN14ThreadPoolImplIS_E12scheduleImplIvEET_St8functionIFvvEEiSt8optionalImEEUlvE1_JEEEOS4_DpOT0_ENKUlvE_clEv
_ZN14ThreadPoolImplISt6threadE6workerESt14_List_iteratorIS0_E
execute_native_thread_routine
start_thread
clone
```

## demangle

Converts a symbol that you can get using the addressToSymbol function to the C++ function name.

**Syntax**

```
demangle(symbol)
```

**Arguments**

- `symbol`(String) — Symbol from an object file.

**Returned value**

- Name of the C++ function.
- Empty string if a symbol is not valid.

Type: String

**Example**

Enabling introspection functions:

```
SET allow_introspection_functions=1;
```

Selecting the first string from the `trace_log` system table:

```
SELECT * FROM system.trace_log LIMIT 1 \G;
Row 1:
──────
event_date:    2019-11-20
event_time:    2019-11-20 16:57:59
revision:      54429
timer_type:    Real
thread_number: 48
query_id:      724028bf-f550-45aa-910d-2af6212b94ac
trace:         [94138803686098,94138815010911,94138815096522,94138815101224,94138815102091,94138814222988,94138806823642,94138814457211,94138806823642,94138814457211,94138806823642,94138806795179,94138806796144,94138753770094,94138753771646,94138753760572,94138852407232,140399185266395,140399178045583]
```

The `trace` field contains the stack trace at the moment of sampling.

Getting a function name for a single address:

```
SELECT demangle(addressToSymbol(94138803686098)) \G;
Row 1:
──────
demangle(addressToSymbol(94138803686098)): DB::IAggregateFunctionHelper<DB::AggregateFunctionSum<unsigned long, unsigned long, DB::AggregateFunctionSumData<unsigned long> > >::addBatchSinglePlace(unsigned long, char*, DB::IColumn const**, DB::Arena*) const
```

Applying the function to the whole stack trace:

```
SELECT
    arrayStringConcat(arrayMap(x -> demangle(addressToSymbol(x)), trace), \n) AS trace_functions
FROM system.trace_log
LIMIT 1
\G
```

The arrayMap function allows to process each individual element of the `trace` array by the `demangle` function. The result of this processing you see in the `trace_functions` column of output.

```
Row 1:
──────
trace_functions: DB::IAggregateFunctionHelper<DB::AggregateFunctionSum<unsigned long, unsigned long, DB::AggregateFunctionSumData<unsigned long> > >::addBatchSinglePlace(unsigned long, char*, DB::IColumn const**, DB::Arena*) const
DB::Aggregator::executeWithoutKeyImpl(char*&, unsigned long, DB::Aggregator::AggregateFunctionInstruction*, DB::Arena*) const
DB::Aggregator::executeOnBlock(std::vector<COW<DB::IColumn>::immutable_ptr<DB::IColumn>, std::allocator<COW<DB::IColumn>::immutable_ptr<DB::IColumn> > >, unsigned long, DB::AggregatedDataVariants&, std::vector<DB::IColumn const*, std::allocator<DB::IColumn const*> >&, std::vector<std::vector<DB::IColumn const*, std::allocator<DB::IColumn const*> >, std::allocator<std::vector<DB::IColumn const*, std::allocator<DB::IColumn const*> > > >&, bool&)
DB::Aggregator::executeOnBlock(DB::Block const&, DB::AggregatedDataVariants&, std::vector<DB::IColumn const*, std::allocator<DB::IColumn const*> >&, std::vector<std::vector<DB::IColumn const*, std::allocator<DB::IColumn const*> >, std::allocator<std::vector<DB::IColumn const*, std::allocator<DB::IColumn const*> > > >&, bool&)
DB::Aggregator::execute(std::shared_ptr<DB::IBlockInputStream> const&, DB::AggregatedDataVariants&)
DB::AggregatingBlockInputStream::readImpl()
DB::IBlockInputStream::read()
DB::ExpressionBlockInputStream::readImpl()
DB::IBlockInputStream::read()
DB::ExpressionBlockInputStream::readImpl()
DB::IBlockInputStream::read()
DB::AsynchronousBlockInputStream::calculate()
std::_Function_handler<void (), DB::AsynchronousBlockInputStream::next()::{lambda()#1}>::_M_invoke(std::_Any_data const&)
ThreadPoolImpl<ThreadFromGlobalPool>::worker(std::_List_iterator<ThreadFromGlobalPool>)
ThreadFromGlobalPool::ThreadFromGlobalPool<ThreadPoolImpl<ThreadFromGlobalPool>::scheduleImpl<void>(std::function<void ()>, int, std::optional<unsigned long>)::{lambda()#3}>(ThreadPoolImpl<ThreadFromGlobalPool>::scheduleImpl<void>(std::function<void ()>, int, std::optional<unsigned long>)::{lambda()#3}&&)::{lambda()#1}::operator()() const
ThreadPoolImpl<std::thread>::worker(std::_List_iterator<std::thread>)
execute_native_thread_routine
start_thread
clone
```

## tid

Returns id of the thread, in which current Block is processed.

**Syntax**

```
tid()
```

**Returned value**

- Current thread id. Uint64.

**Example**

Query:

```
SELECT tid();
```

Result:

```
┌─tid()─┐
│  3878 │
└───────┘
```

## logTrace

Emits trace log message to server log for each Block.

**Syntax**

```
logTrace(message)
```

**Arguments**

- `message` — Message that is emitted to server log. String.

**Returned value**

- Always returns 0.

**Example**

Query:

```
SELECT logTrace(logTrace message);
```

Result:

```
┌─logTrace(logTrace message)─┐
│                            0 │
└──────────────────────────────┘
```

' where id=24;
update biz_data_query_model_help_content set content_en = '# Functions for Working with Geographical Coordinates

## greatCircleDistance

Calculates the distance between two points on the Earth’s surface using the great-circle formula.

```
greatCircleDistance(lon1Deg, lat1Deg, lon2Deg, lat2Deg)
```

**Input parameters**

- `lon1Deg` — Longitude of the first point in degrees. Range: `[-180°, 180°]`.
- `lat1Deg` — Latitude of the first point in degrees. Range: `[-90°, 90°]`.
- `lon2Deg` — Longitude of the second point in degrees. Range: `[-180°, 180°]`.
- `lat2Deg` — Latitude of the second point in degrees. Range: `[-90°, 90°]`.

Positive values correspond to North latitude and East longitude, and negative values correspond to South latitude and West longitude.

**Returned value**

The distance between two points on the Earth’s surface, in meters.

Generates an exception when the input parameter values fall outside of the range.

**Example**

```
SELECT greatCircleDistance(55.755831, 37.617673, -55.755831, -37.617673)
┌─greatCircleDistance(55.755831, 37.617673, -55.755831, -37.617673)─┐
│                                                14132374.194975413 │
└───────────────────────────────────────────────────────────────────┘
```

## greatCircleAngle

Calculates the central angle between two points on the Earth’s surface using the great-circle formula.

```
greatCircleAngle(lon1Deg, lat1Deg, lon2Deg, lat2Deg)
```

**Input parameters**

- `lon1Deg` — Longitude of the first point in degrees.
- `lat1Deg` — Latitude of the first point in degrees.
- `lon2Deg` — Longitude of the second point in degrees.
- `lat2Deg` — Latitude of the second point in degrees.

**Returned value**

The central angle between two points in degrees.

**Example**

```
SELECT greatCircleAngle(0, 0, 45, 0) AS arc
┌─arc─┐
│  45 │
└─────┘
```

## pointInEllipses[ ](https://clickhouse.tech/docs/en/sql-reference/functions/geo/coordinates/#pointinellipses)

Checks whether the point belongs to at least one of the ellipses.
Coordinates are geometric in the Cartesian coordinate system.

```
pointInEllipses(x, y, x₀, y₀, a₀, b₀,...,xₙ, yₙ, aₙ, bₙ)
```

**Input parameters**

- `x, y` — Coordinates of a point on the plane.
- `xᵢ, yᵢ` — Coordinates of the center of the `i`-th ellipsis.
- `aᵢ, bᵢ` — Axes of the `i`-th ellipsis in units of x, y coordinates.

The input parameters must be `2+4⋅n`, where `n` is the number of ellipses.

**Returned values**

`1` if the point is inside at least one of the ellipses; `0`if it is not.

**Example**

```
SELECT pointInEllipses(10., 10., 10., 9.1, 1., 0.9999)
┌─pointInEllipses(10., 10., 10., 9.1, 1., 0.9999)─┐
│                                               1 │
└─────────────────────────────────────────────────┘
```

## pointInPolygon[ ](https://clickhouse.tech/docs/en/sql-reference/functions/geo/coordinates/#pointinpolygon)

Checks whether the point belongs to the polygon on the plane.

```
pointInPolygon((x, y), [(a, b), (c, d) ...], ...)
```

**Input values**

- `(x, y)` — Coordinates of a point on the plane. Data type — [Tuple — A tuple of two numbers.
- `[(a, b), (c, d) ...]` — Polygon vertices. Data type — Array. Each vertex is represented by a pair of coordinates `(a, b)`. Vertices should be specified in a clockwise or counterclockwise order. The minimum number of vertices is 3. The polygon must be constant.
- The function also supports polygons with holes (cut out sections). In this case, add polygons that define the cut out sections using additional arguments of the function. The function does not support non-simply-connected polygons.

**Returned values**

`1` if the point is inside the polygon, `0` if it is not.
If the point is on the polygon boundary, the function may return either 0 or 1.

**Example**

```
SELECT pointInPolygon((3., 3.), [(6, 0), (8, 4), (5, 8), (0, 2)]) AS res
┌─res─┐
│   1 │
└─────┘
```

' where id=25;
update biz_data_query_model_help_content set content_en = '# Hash Functions

Hash functions can be used for the deterministic pseudo-random shuffling of elements.

Simhash is a hash function, which returns close hash values for close (similar) arguments.

## halfMD5

Interprets all the input parameters as strings and calculates the MD5 hash value for each of them. Then combines hashes, takes the first 8 bytes of the hash of the resulting string, and interprets them as `UInt64` in big-endian byte order.

```
halfMD5(par1, ...)
```

The function is relatively slow (5 million short strings per second per processor core).
Consider using the sipHash64 function instead.

**Arguments**

The function takes a variable number of input parameters. Arguments can be any of the supported data types.

**Returned Value**

A UInt64 data type hash value.

**Example**

```
SELECT halfMD5(array(e,x,a), mple, 10, toDateTime(2019-06-15 23:00:00)) AS halfMD5hash, toTypeName(halfMD5hash) AS type;
┌────────halfMD5hash─┬─type───┐
│ 186182704141653334 │ UInt64 │
└────────────────────┴────────┘
```

## MD5

Calculates the MD5 from a string and returns the resulting set of bytes as FixedString(16).
If you do not need MD5 in particular, but you need a decent cryptographic 128-bit hash, use the ‘sipHash128’ function instead.
If you want to get the same result as output by the md5sum utility, use lower(hex(MD5(s))).

## sipHash64

Produces a 64-bit SipHash hash value.

```
sipHash64(par1,...)
```

This is a cryptographic hash function. It works at least three times faster than the MD5 function.

Function interprets all the input parameters as strings and calculates the hash value for each of them. Then combines hashes by the following algorithm:

1. After hashing all the input parameters, the function gets the array of hashes.
2. Function takes the first and the second elements and calculates a hash for the array of them.
3. Then the function takes the hash value, calculated at the previous step, and the third element of the initial hash array, and calculates a hash for the array of them.
4. The previous step is repeated for all the remaining elements of the initial hash array.

**Arguments**

The function takes a variable number of input parameters. Arguments can be any of the supported data types.

**Returned Value**

A UInt64 data type hash value.

**Example**

```
SELECT sipHash64(array(e,x,a), mple, 10, toDateTime(2019-06-15 23:00:00)) AS SipHash, toTypeName(SipHash) AS type;
┌──────────────SipHash─┬─type───┐
│ 13726873534472839665 │ UInt64 │
└──────────────────────┴────────┘
```

## sipHash128

Calculates SipHash from a string.
Accepts a String-type argument. Returns FixedString(16).
Differs from sipHash64 in that the final xor-folding state is only done up to 128 bits.

## cityHash64

Produces a 64-bit CityHash hash value.

```
cityHash64(par1,...)
```

This is a fast non-cryptographic hash function. It uses the CityHash algorithm for string parameters and implementation-specific fast non-cryptographic hash function for parameters with other data types. The function uses the CityHash combinator to get the final results.

**Arguments**

The function takes a variable number of input parameters. Arguments can be any of the supported data types.

**Returned Value**

A UInt64 data type hash value.

**Examples**

Call example:

```
SELECT cityHash64(array(e,x,a), mple, 10, toDateTime(2019-06-15 23:00:00)) AS CityHash, toTypeName(CityHash) AS type;
┌─────────────CityHash─┬─type───┐
│ 12072650598913549138 │ UInt64 │
└──────────────────────┴────────┘
```

The following example shows how to compute the checksum of the entire table with accuracy up to the row order:

```
SELECT groupBitXor(cityHash64(*)) FROM table
```

## intHash32

Calculates a 32-bit hash code from any type of integer.
This is a relatively fast non-cryptographic hash function of average quality for numbers.

## intHash64

Calculates a 64-bit hash code from any type of integer.
It works faster than intHash32. Average quality.

## SHA1

## SHA224

## SHA256

Calculates SHA-1, SHA-224, or SHA-256 from a string and returns the resulting set of bytes as FixedString(20), FixedString(28), or FixedString(32).
The function works fairly slowly (SHA-1 processes about 5 million short strings per second per processor core, while SHA-224 and SHA-256 process about 2.2 million).
We recommend using this function only in cases when you need a specific hash function and you can’t select it.
Even in these cases, we recommend applying the function offline and pre-calculating values when inserting them into the table, instead of applying it in SELECTS.

## URLHash(url[, N])

A fast, decent-quality non-cryptographic hash function for a string obtained from a URL using some type of normalization.
`URLHash(s)` – Calculates a hash from a string without one of the trailing symbols `/`,`?` or `#` at the end, if present.
`URLHash(s, N)` – Calculates a hash from a string up to the N level in the URL hierarchy, without one of the trailing symbols `/`,`?` or `#` at the end, if present.
Levels are the same as in URLHierarchy. This function is specific to Yandex.Metrica.

## farmFingerprint64

## farmHash64

Produces a 64-bit FarmHash or Fingerprint value. `farmFingerprint64` is preferred for a stable and portable value.

```
farmFingerprint64(par1, ...)
farmHash64(par1, ...)
```

These functions use the `Fingerprint64` and `Hash64` methods respectively from all available methods.

**Arguments**

The function takes a variable number of input parameters. Arguments can be any of the supported data types.

**Returned Value**

A UInt64 data type hash value.

**Example**

```
SELECT farmHash64(array(e,x,a), mple, 10, toDateTime(2019-06-15 23:00:00)) AS FarmHash, toTypeName(FarmHash) AS type;
┌─────────────FarmHash─┬─type───┐
│ 17790458267262532859 │ UInt64 │
└──────────────────────┴────────┘
```

## javaHash

Calculates JavaHash from a string. This hash function is neither fast nor having a good quality. The only reason to use it is when this algorithm is already used in another system and you have to calculate exactly the same result.

**Syntax**

```
SELECT javaHash()
```

**Returned value**

A `Int32` data type hash value.

**Example**

Query:

```
SELECT javaHash(Hello, world!);
```

Result:

```
┌─javaHash(Hello, world!)─┐
│               -1880044555 │
└───────────────────────────┘
```

## javaHashUTF16LE

Calculates JavaHash from a string, assuming it contains bytes representing a string in UTF-16LE encoding.

**Syntax**

```
javaHashUTF16LE(stringUtf16le)
```

**Arguments**

- `stringUtf16le` — a string in UTF-16LE encoding.

**Returned value**

A `Int32` data type hash value.

**Example**

Correct query with UTF-16LE encoded string.

Query:

```
SELECT javaHashUTF16LE(convertCharset(test, utf-8, utf-16le));
```

Result:

```
┌─javaHashUTF16LE(convertCharset(test, utf-8, utf-16le))─┐
│                                                      3556498 │
└──────────────────────────────────────────────────────────────┘
```

## hiveHash

Calculates `HiveHash` from a string.

```
SELECT hiveHash()
```

This is just JavaHash with zeroed out sign bit. This function is used in Apache Hive for versions before 3.0. This hash function is neither fast nor having a good quality. The only reason to use it is when this algorithm is already used in another system and you have to calculate exactly the same result.

**Returned value**

A `Int32` data type hash value.

Type: `hiveHash`.

**Example**

Query:

```
SELECT hiveHash(Hello, world!);
```

Result:

```
┌─hiveHash(Hello, world!)─┐
│                 267439093 │
└───────────────────────────┘
```

## metroHash64

Produces a 64-bit MetroHash hash value.

```
metroHash64(par1, ...)
```

**Arguments**

The function takes a variable number of input parameters. Arguments can be any of the supported data types.

**Returned Value**

A UInt64 data type hash value.

**Example**

```
SELECT metroHash64(array(e,x,a), mple, 10, toDateTime(2019-06-15 23:00:00)) AS MetroHash, toTypeName(MetroHash) AS type;
┌────────────MetroHash─┬─type───┐
│ 14235658766382344533 │ UInt64 │
└──────────────────────┴────────┘
```

## jumpConsistentHash

Calculates JumpConsistentHash form a UInt64.
Accepts two arguments: a UInt64-type key and the number of buckets. Returns Int32.
For more information, see the link: JumpConsistentHash

## murmurHash2_32, murmurHash2_64

Produces a MurmurHash2 hash value.

```
murmurHash2_32(par1, ...)
murmurHash2_64(par1, ...)
```

**Arguments**

Both functions take a variable number of input parameters. Arguments can be any of the supported data types

**Returned Value**

- The `murmurHash2_32` function returns hash value having the UInt32 data type.
- The `murmurHash2_64` function returns hash value having theUInt64 data type.

**Example**

```
SELECT murmurHash2_64(array(e,x,a), mple, 10, toDateTime(2019-06-15 23:00:00)) AS MurmurHash2, toTypeName(MurmurHash2) AS type;
┌──────────MurmurHash2─┬─type───┐
│ 11832096901709403633 │ UInt64 │
└──────────────────────┴────────┘
```

## gccMurmurHash

Calculates a 64-bit MurmurHash2 hash value using the same hash seed as gcc. It is portable between CLang and GCC builds.

**Syntax**

```
gccMurmurHash(par1, ...)
```

**Arguments**

- `par1, ...` — A variable number of parameters that can be any of the supported data types.

**Returned value**

- Calculated hash value.

Type: UInt4.

**Example**

Query:

```
SELECT
    gccMurmurHash(1, 2, 3) AS res1,
    gccMurmurHash((a, [1, 2, 3], 4, (4, [foo, bar], 1, (1, 2)))) AS res2
```

Result:

```
┌─────────────────res1─┬────────────────res2─┐
│ 12384823029245979431 │ 1188926775431157506 │
└──────────────────────┴─────────────────────┘
```

## murmurHash3_32, murmurHash3_64

Produces a MurmurHash3 hash value.

```
murmurHash3_32(par1, ...)
murmurHash3_64(par1, ...)
```

**Arguments**

Both functions take a variable number of input parameters. Arguments can be any of the [supported data types].

**Returned Value**

- The `murmurHash3_32` function returns a [UInt32] data type hash value.
- The `murmurHash3_64` function returns a [UInt64] data type hash value.

**Example**

```
SELECT murmurHash3_32(array(e,x,a), mple, 10, toDateTime(2019-06-15 23:00:00)) AS MurmurHash3, toTypeName(MurmurHash3) AS type;
┌─MurmurHash3─┬─type───┐
│     2152717 │ UInt32 │
└─────────────┴────────┘
```

## murmurHash3_128

Produces a 128-bit MurmurHash3 hash value.

```
murmurHash3_128( expr )
```

**Arguments**

- `expr` — Expressions returning a String-type value.

**Returned Value**

A FixedString(16) data type hash value.

**Example**

```
SELECT hex(murmurHash3_128(example_string)) AS MurmurHash3, toTypeName(MurmurHash3) AS type;
┌─MurmurHash3──────────────────────┬─type───┐
│ 368A1A311CB7342253354B548E7E7E71 │ String │
└──────────────────────────────────┴────────┘
```

## xxHash32, xxHash64

Calculates `xxHash` from a string. It is proposed in two flavors, 32 and 64 bits.

```
SELECT xxHash32()

OR

SELECT xxHash64()
```

**Returned value**

A `Uint32` or `Uint64` data type hash value.

Type: `xxHash`.

**Example**

Query:

```
SELECT xxHash32(Hello, world!);
```

Result:

```
┌─xxHash32(Hello, world!)─┐
│                 834093149 │
└───────────────────────────┘
```

**See Also**

- xxHash.

## ngramSimHash[ ](https://clickhouse.tech/docs/en/sql-reference/functions/hash-functions/#ngramsimhash)

Splits a ASCII string into n-grams of `ngramsize` symbols and returns the n-gram `simhash`. Is case sensitive.

Can be used for detection of semi-duplicate strings with bitHammingDistance. The smaller is the Hamming Distance of the calculated `simhashes` of two strings, the more likely these strings are the same.

**Syntax**

```
ngramSimHash(string[, ngramsize])
```

**Arguments**

- `string` — String. String.
- `ngramsize` — The size of an n-gram. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.

**Returned value**

- Hash value.

Type: UInt64.

**Example**

Query:

```
SELECT ngramSimHash(ClickHouse) AS Hash;
```

Result:

```
┌───────Hash─┐
│ 1627567969 │
└────────────┘
```

## ngramSimHashCaseInsensitive

Splits a ASCII string into n-grams of `ngramsize` symbols and returns the n-gram `simhash`. Is case insensitive.

Can be used for detection of semi-duplicate strings with bitHammingDistance. The smaller is the Hamming Distance of the calculated `simhashes` of two strings, the more likely these strings are the same.

**Syntax**

```
ngramSimHashCaseInsensitive(string[, ngramsize])
```

**Arguments**

- `string` — String. String.
- `ngramsize` — The size of an n-gram. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.

**Returned value**

- Hash value.

Type: UInt64.

**Example**

Query:

```
SELECT ngramSimHashCaseInsensitive(ClickHouse) AS Hash;
```

Result:

```
┌──────Hash─┐
│ 562180645 │
└───────────┘
```

## ngramSimHashUTF8[ ](https://clickhouse.tech/docs/en/sql-reference/functions/hash-functions/#ngramsimhashutf8)

Splits a UTF-8 string into n-grams of `ngramsize` symbols and returns the n-gram `simhash`. Is case sensitive.

Can be used for detection of semi-duplicate strings with bitHammingDistance. The smaller is the Hamming Distance of the calculated `simhashes` of two strings, the more likely these strings are the same.

**Syntax**

```
ngramSimHashUTF8(string[, ngramsize])
```

**Arguments**

- `string` — String. String.
- `ngramsize` — The size of an n-gram. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.

**Returned value**

- Hash value.

Type: UInt64.

**Example**

Query:

```
SELECT ngramSimHashUTF8(ClickHouse) AS Hash;
```

Result:

```
┌───────Hash─┐
│ 1628157797 │
└────────────┘
```

## ngramSimHashCaseInsensitiveUTF8

Splits a UTF-8 string into n-grams of `ngramsize` symbols and returns the n-gram `simhash`. Is case insensitive.

Can be used for detection of semi-duplicate strings with bitHammingDistance. The smaller is the Hamming Distance of the calculated `simhashes` of two strings, the more likely these strings are the same.

**Syntax**

```
ngramSimHashCaseInsensitiveUTF8(string[, ngramsize])
```

**Arguments**

- `string` — String. String.
- `ngramsize` — The size of an n-gram. Optional.UInt8.

**Returned value**

- Hash value.

Type: UInt64.

**Example**

Query:

```
SELECT ngramSimHashCaseInsensitiveUTF8(ClickHouse) AS Hash;
```

Result:

```
┌───────Hash─┐
│ 1636742693 │
└────────────┘
```

## wordShingleSimHash

Splits a ASCII string into parts (shingles) of `shinglesize` words and returns the word shingle `simhash`. Is case sensitive.

Can be used for detection of semi-duplicate strings with bitHammingDistance. The smaller is the Hamming Distance of the calculated `simhashes` of two strings, the more likely these strings are the same.

**Syntax**

```
wordShingleSimHash(string[, shinglesize])
```

**Arguments**

- `string` — String. String.
- `shinglesize` — The size of a word shingle. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.

**Returned value**

- Hash value.

Type: UInt64.

**Example**

Query:

```
SELECT wordShingleSimHash(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP).) AS Hash;
```

Result:

```
┌───────Hash─┐
│ 2328277067 │
└────────────┘
```

## wordShingleSimHashCaseInsensitive

Splits a ASCII string into parts (shingles) of `shinglesize` words and returns the word shingle `simhash`. Is case insensitive.

Can be used for detection of semi-duplicate strings with bitHammingDistance). The smaller is theHamming Distance of the calculated `simhashes` of two strings, the more likely these strings are the same.

**Syntax**

```
wordShingleSimHashCaseInsensitive(string[, shinglesize])
```

**Arguments**

- `string` — String. String.
- `shinglesize` — The size of a word shingle. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.

**Returned value**

- Hash value.

Type: UINt64.

**Example**

Query:

```
SELECT wordShingleSimHashCaseInsensitive(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP).) AS Hash;
```

Result:

```
┌───────Hash─┐
│ 2194812424 │
└────────────┘
```

## wordShingleSimHashUTF8

Splits a UTF-8 string into parts (shingles) of `shinglesize` words and returns the word shingle `simhash`. Is case sensitive.

Can be used for detection of semi-duplicate strings with bitHammingDistance. The smaller is the Hamming Distance of the calculated `simhashes` of two strings, the more likely these strings are the same.

**Syntax**

```
wordShingleSimHashUTF8(string[, shinglesize])
```

**Arguments**

- `string` — String. String.
- `shinglesize` — The size of a word shingle. Optinal. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.

**Returned value**

- Hash value.

Type: UInt64.

**Example**

Query:

```
SELECT wordShingleSimHashUTF8(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP).) AS Hash;
```

Result:

```
┌───────Hash─┐
│ 2328277067 │
└────────────┘
```

## wordShingleSimHashCaseInsensitiveUTF8

Splits a UTF-8 string into parts (shingles) of `shinglesize` words and returns the word shingle `simhash`. Is case insensitive.

Can be used for detection of semi-duplicate strings with bitHammingDistance. The smaller is the Hamming Distance of the calculated `simhashes` of two strings, the more likely these strings are the same.

**Syntax**

```
wordShingleSimHashCaseInsensitiveUTF8(string[, shinglesize])
```

**Arguments**

- `string` — String.String.
- `shinglesize` — The size of a word shingle. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.

**Returned value**

- Hash value.

Type: UInt64.

**Example**

Query:

```
SELECT wordShingleSimHashCaseInsensitiveUTF8(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP).) AS Hash;
```

Result:

```
┌───────Hash─┐
│ 2194812424 │
└────────────┘
```

## ngramMinHash

Splits a ASCII string into n-grams of `ngramsize` symbols and calculates hash values for each n-gram. Uses `hashnum` minimum hashes to calculate the minimum hash and `hashnum` maximum hashes to calculate the maximum hash. Returns a tuple with these hashes. Is case sensitive.

Can be used for detection of semi-duplicate strings with tupleHammingDistance. For two strings: if one of the returned hashes is the same for both strings, we think that those strings are the same.

**Syntax**

```
ngramMinHash(string[, ngramsize, hashnum])
```

**Arguments**

- `string` — String. String.
- `ngramsize` — The size of an n-gram. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`. UInt8.

**Returned value**

- Tuple with two hashes — the minimum and the maximum.

Type: Tuple(UInt64,UInt64).



**Example**

Query:

```
SELECT ngramMinHash(ClickHouse) AS Tuple;
```

Result:

```
┌─Tuple──────────────────────────────────────┐
│ (18333312859352735453,9054248444481805918) │
└────────────────────────────────────────────┘
```

## ngramMinHashCaseInsensitive

Splits a ASCII string into n-grams of `ngramsize` symbols and calculates hash values for each n-gram. Uses `hashnum` minimum hashes to calculate the minimum hash and `hashnum` maximum hashes to calculate the maximum hash. Returns a tuple with these hashes. Is case insensitive.

Can be used for detection of semi-duplicate strings with tupleHammingDistance. For two strings: if one of the returned hashes is the same for both strings, we think that those strings are the same.

**Syntax**

```
ngramMinHashCaseInsensitive(string[, ngramsize, hashnum])
```

**Arguments**

- `string` — String. String.
- `ngramsize` — The size of an n-gram. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`. UInt8.

**Returned value**

- Tuple with two hashes — the minimum and the maximum.

Type:Tuple(UInt64,UInt64).

**Example**

Query:

```
SELECT ngramMinHashCaseInsensitive(ClickHouse) AS Tuple;
```

Result:

```
┌─Tuple──────────────────────────────────────┐
│ (2106263556442004574,13203602793651726206) │
└────────────────────────────────────────────┘
```

## ngramMinHashUTF8

Splits a UTF-8 string into n-grams of `ngramsize` symbols and calculates hash values for each n-gram. Uses `hashnum` minimum hashes to calculate the minimum hash and `hashnum` maximum hashes to calculate the maximum hash. Returns a tuple with these hashes. Is case sensitive.

Can be used for detection of semi-duplicate strings with tupleHammingDistance. For two strings: if one of the returned hashes is the same for both strings, we think that those strings are the same.

**Syntax**

```
ngramMinHashUTF8(string[, ngramsize, hashnum])
```

**Arguments**

- `string` — String. String
- `ngramsize` — The size of an n-gram. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`.UInt8.

**Returned value**

- Tuple with two hashes — the minimum and the maximum.

Type: Tuple(UInt64,UInt64).

**Example**

Query:

```
SELECT ngramMinHashUTF8(ClickHouse) AS Tuple;
```

Result:

```
┌─Tuple──────────────────────────────────────┐
│ (18333312859352735453,6742163577938632877) │
└────────────────────────────────────────────┘
```

## ngramMinHashCaseInsensitiveUTF8

Splits a UTF-8 string into n-grams of `ngramsize` symbols and calculates hash values for each n-gram. Uses `hashnum` minimum hashes to calculate the minimum hash and `hashnum` maximum hashes to calculate the maximum hash. Returns a tuple with these hashes. Is case insensitive.

Can be used for detection of semi-duplicate strings with tupleHammingDistance]. For two strings: if one of the returned hashes is the same for both strings, we think that those strings are the same.

**Syntax**

```
ngramMinHashCaseInsensitiveUTF8(string [, ngramsize, hashnum])
```

**Arguments**

- `string` — String. String.
- `ngramsize` — The size of an n-gram. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`.UInt8.

**Returned value**

- Tuple with two hashes — the minimum and the maximum.

Type: Tuple(UInt64,UInt64).

**Example**

Query:

```
SELECT ngramMinHashCaseInsensitiveUTF8(ClickHouse) AS Tuple;
```

Result:

```
┌─Tuple───────────────────────────────────────┐
│ (12493625717655877135,13203602793651726206) │
└─────────────────────────────────────────────┘
```

## ngramMinHashArg

Splits a ASCII string into n-grams of `ngramsize` symbols and returns the n-grams with minimum and maximum hashes, calculated by the ngramMinHash function with the same input. Is case sensitive.

**Syntax**

```
ngramMinHashArg(string[, ngramsize, hashnum])
```

**Arguments**

- `string` — String. String.
- `ngramsize` — The size of an n-gram. Optional. Possible values: any number from `1` to `25`. Default value: `3`.UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`.UInt8.

**Returned value**

- Tuple with two tuples with `hashnum` n-grams each.

Type: Tuple(Tuple(String),Tuple(String)).



**Example**

Query:

```
SELECT ngramMinHashArg(ClickHouse) AS Tuple;
```

Result:

```
┌─Tuple─────────────────────────────────────────────────────────────────────────┐
│ ((ous,ick,lic,Hou,kHo,use),(Hou,lic,ick,ous,ckH,Cli)) │
└───────────────────────────────────────────────────────────────────────────────┘
```

## ngramMinHashArgCaseInsensitive

Splits a ASCII string into n-grams of `ngramsize` symbols and returns the n-grams with minimum and maximum hashes, calculated by the ngramMinHashCaseInsensitive function with the same input. Is case insensitive.

**Syntax**

```
ngramMinHashArgCaseInsensitive(string[, ngramsize, hashnum])
```

**Arguments**

- `string` — String. String.
- `ngramsize` — The size of an n-gram. Optional. Possible values: any number from `1` to `25`. Default value: `3`.UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`. UInt8.

**Returned value**

- Tuple with two tuples with `hashnum` n-grams each.

Type:Tuple(Tuple(String),Tuple(String)).

**Example**

Query:

```
SELECT ngramMinHashArgCaseInsensitive(ClickHouse) AS Tuple;
```

Result:

```
┌─Tuple─────────────────────────────────────────────────────────────────────────┐
│ ((ous,ick,lic,kHo,use,Cli),(kHo,lic,ick,ous,ckH,Hou)) │
└───────────────────────────────────────────────────────────────────────────────┘
```

## ngramMinHashArgUTF8

Splits a UTF-8 string into n-grams of `ngramsize` symbols and returns the n-grams with minimum and maximum hashes, calculated by the ngramMinHashUTF8 function with the same input. Is case sensitive.

**Syntax**

```
ngramMinHashArgUTF8(string[, ngramsize, hashnum])
```

**Arguments**

- `string` — String.String.
- `ngramsize` — The size of an n-gram. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`. UInt8.

**Returned value**

- Tuple with two tuples with `hashnum` n-grams each.

Type: Tuple(Tuple(String),Tuple(String)).

**Example**

Query:

```
SELECT ngramMinHashArgUTF8(ClickHouse) AS Tuple;
```

Result:

```
┌─Tuple─────────────────────────────────────────────────────────────────────────┐
│ ((ous,ick,lic,Hou,kHo,use),(kHo,Hou,lic,ick,ous,ckH)) │
└───────────────────────────────────────────────────────────────────────────────┘
```

## ngramMinHashArgCaseInsensitiveUTF8

Splits a UTF-8 string into n-grams of `ngramsize` symbols and returns the n-grams with minimum and maximum hashes, calculated by the ngramMinHashCaseInsensitiveUTF8 function with the same input. Is case insensitive.

**Syntax**

```
ngramMinHashArgCaseInsensitiveUTF8(string[, ngramsize, hashnum])
```

**Arguments**

- `string` — String. String
- `ngramsize` — The size of an n-gram. Optional. Possible values: any number from `1` to `25`. Default value: `3`.UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`. UInt8.

**Returned value**

- Tuple with two tuples with `hashnum` n-grams each.

Type:Tuple(Tuple(String),Tuple(String)).

**Example**

Query:

```
SELECT ngramMinHashArgCaseInsensitiveUTF8(ClickHouse) AS Tuple;
```

Result:

```
┌─Tuple─────────────────────────────────────────────────────────────────────────┐
│ ((ckH,ous,ick,lic,kHo,use),(kHo,lic,ick,ous,ckH,Hou)) │
└───────────────────────────────────────────────────────────────────────────────┘
```

## wordShingleMinHash

Splits a ASCII string into parts (shingles) of `shinglesize` words and calculates hash values for each word shingle. Uses `hashnum` minimum hashes to calculate the minimum hash and `hashnum` maximum hashes to calculate the maximum hash. Returns a tuple with these hashes. Is case sensitive.

Can be used for detection of semi-duplicate strings with tupleHammingDistance. For two strings: if one of the returned hashes is the same for both strings, we think that those strings are the same.

**Syntax**

```
wordShingleMinHash(string[, shinglesize, hashnum])
```

**Arguments**

- `string` — String. String
- `shinglesize` — The size of a word shingle. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`.UInt8

**Returned value**

- Tuple with two hashes — the minimum and the maximum.

Type: Tuple(UInt64,UInt64).

**Example**

Query:

```
SELECT wordShingleMinHash(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP).) AS Tuple;
```

Result:

```
┌─Tuple──────────────────────────────────────┐
│ (16452112859864147620,5844417301642981317) │
└────────────────────────────────────────────┘
```

## wordShingleMinHashCaseInsensitive

Splits a ASCII string into parts (shingles) of `shinglesize` words and calculates hash values for each word shingle. Uses `hashnum` minimum hashes to calculate the minimum hash and `hashnum` maximum hashes to calculate the maximum hash. Returns a tuple with these hashes. Is case insensitive.

Can be used for detection of semi-duplicate strings with tupleHammingDistance. For two strings: if one of the returned hashes is the same for both strings, we think that those strings are the same.

**Syntax**

```
wordShingleMinHashCaseInsensitive(string[, shinglesize, hashnum])
```

**Arguments**

- `string` — String. String.
- `shinglesize` — The size of a word shingle. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`.UInt8.

**Returned value**

- Tuple with two hashes — the minimum and the maximum.

Type: Tuple(UInt64,UInt64)

**Example**

Query:

```
SELECT wordShingleMinHashCaseInsensitive(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP).) AS Tuple;
```

Result:

```
┌─Tuple─────────────────────────────────────┐
│ (3065874883688416519,1634050779997673240) │
└───────────────────────────────────────────┘
```

## wordShingleMinHashUTF8

Splits a UTF-8 string into parts (shingles) of `shinglesize` words and calculates hash values for each word shingle. Uses `hashnum` minimum hashes to calculate the minimum hash and `hashnum` maximum hashes to calculate the maximum hash. Returns a tuple with these hashes. Is case sensitive.

Can be used for detection of semi-duplicate strings with [tupleHammingDistance. For two strings: if one of the returned hashes is the same for both strings, we think that those strings are the same.

**Syntax**

```
wordShingleMinHashUTF8(string[, shinglesize, hashnum])
```

**Arguments**

- `string` — String. String
- `shinglesize` — The size of a word shingle. Optional. Possible values: any number from `1` to `25`. Default value: `3`.UInt8
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`. UInt8

**Returned value**

- Tuple with two hashes — the minimum and the maximum.

Type: Tuple(UInt64,UInt64)

**Example**

Query:

```
SELECT wordShingleMinHashUTF8(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP).) AS Tuple;
```

Result:

```
┌─Tuple──────────────────────────────────────┐
│ (16452112859864147620,5844417301642981317) │
└────────────────────────────────────────────┘
```

## wordShingleMinHashCaseInsensitiveUTF8

Splits a UTF-8 string into parts (shingles) of `shinglesize` words and calculates hash values for each word shingle. Uses `hashnum` minimum hashes to calculate the minimum hash and `hashnum` maximum hashes to calculate the maximum hash. Returns a tuple with these hashes. Is case insensitive.

Can be used for detection of semi-duplicate strings with tupleHammingDistance. For two strings: if one of the returned hashes is the same for both strings, we think that those strings are the same.

**Syntax**

```
wordShingleMinHashCaseInsensitiveUTF8(string[, shinglesize, hashnum])
```

**Arguments**

- `string` — String. String.
- `shinglesize` — The size of a word shingle. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`. UInt8.

**Returned value**

- Tuple with two hashes — the minimum and the maximum.

Type: Tuple(UInt64, UInt64).

**Example**

Query:

```
SELECT wordShingleMinHashCaseInsensitiveUTF8(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP).) AS Tuple;
```

Result:

```
┌─Tuple─────────────────────────────────────┐
│ (3065874883688416519,1634050779997673240) │
└───────────────────────────────────────────┘
```

## wordShingleMinHashArg

Splits a ASCII string into parts (shingles) of `shinglesize` words each and returns the shingles with minimum and maximum word hashes, calculated by the wordshingleMinHash function with the same input. Is case sensitive.

**Syntax**

```
wordShingleMinHashArg(string[, shinglesize, hashnum])
```

**Arguments**

- `string` — String. String.
- `shinglesize` — The size of a word shingle. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`. UInt8.

**Returned value**

- Tuple with two tuples with `hashnum` word shingles each.

Type: Tuple(Tuple(String), Tuple(String)).

**Example**

Query:

```
SELECT wordShingleMinHashArg(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP)., 1, 3) AS Tuple;
```

Result:

```
┌─Tuple─────────────────────────────────────────────────────────────────┐
│ ((OLAP,database,analytical),(online,oriented,processing)) │
└───────────────────────────────────────────────────────────────────────┘
```

## wordShingleMinHashArgCaseInsensitive

Splits a ASCII string into parts (shingles) of `shinglesize` words each and returns the shingles with minimum and maximum word hashes, calculated by the wordShingleMinHashCaseInsensitive function with the same input. Is case insensitive.

**Syntax**

```
wordShingleMinHashArgCaseInsensitive(string[, shinglesize, hashnum])
```

**Arguments**

- `string` — String. String.
- `shinglesize` — The size of a word shingle. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8.
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`.UInt8.

**Returned value**

- Tuple with two tuples with `hashnum` word shingles each.

Type: Tuple(Tuple, Tuple(String)).

**Example**

Query:

```
SELECT wordShingleMinHashArgCaseInsensitive(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP)., 1, 3) AS Tuple;
```

Result:

```
┌─Tuple──────────────────────────────────────────────────────────────────┐
│ ((queries,database,analytical),(oriented,processing,DBMS)) │
└────────────────────────────────────────────────────────────────────────┘
```

## wordShingleMinHashArgUTF8

Splits a UTF-8 string into parts (shingles) of `shinglesize` words each and returns the shingles with minimum and maximum word hashes, calculated by the wordShingleMinHashUTF8  function with the same input. Is case sensitive.

**Syntax**

```
wordShingleMinHashArgUTF8(string[, shinglesize, hashnum])
```

**Arguments**

- `string` — String. String.
- `shinglesize` — The size of a word shingle. Optional. Possible values: any number from `1` to `25`. Default value: `3`.UInt8
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`. UInt8.

**Returned value**

- Tuple with two tuples with `hashnum` word shingles each.

Type:Tuple(Tuple, Tuple(String)).

**Example**

Query:

```
SELECT wordShingleMinHashArgUTF8(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP)., 1, 3) AS Tuple;
```

Result:

```
┌─Tuple─────────────────────────────────────────────────────────────────┐
│ ((OLAP,database,analytical),(online,oriented,processing)) │
└───────────────────────────────────────────────────────────────────────┘
```

## wordShingleMinHashArgCaseInsensitiveUTF8

Splits a UTF-8 string into parts (shingles) of `shinglesize` words each and returns the shingles with minimum and maximum word hashes, calculated by the wordShingleMinHashCaseInsensitiveUTF8 function with the same input. Is case insensitive.

**Syntax**

```
wordShingleMinHashArgCaseInsensitiveUTF8(string[, shinglesize, hashnum])
```

**Arguments**

- `string` — String. String
- `shinglesize` — The size of a word shingle. Optional. Possible values: any number from `1` to `25`. Default value: `3`. UInt8
- `hashnum` — The number of minimum and maximum hashes used to calculate the result. Optional. Possible values: any number from `1` to `25`. Default value: `6`. UInt8

**Returned value**

- Tuple with two tuples with `hashnum` word shingles each.

Type: Tuple(Tuple, Tuple(String)).

**Example**

Query:

```
SELECT wordShingleMinHashArgCaseInsensitiveUTF8(ClickHouse® is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP)., 1, 3) AS Tuple;
```

Result:

```
┌─Tuple──────────────────────────────────────────────────────────────────┐
│ ((queries,database,analytical),(oriented,processing,DBMS)) │
└────────────────────────────────────────────────────────────────────────┘
```

' where id=26;
update biz_data_query_model_help_content set content_en = '# Functions for Working with IPv4 and IPv6 Addresses

## IPv4NumToString(num)

Takes a UInt32 number. Interprets it as an IPv4 address in big endian. Returns a string containing the corresponding IPv4 address in the format A.B.C.d (dot-separated numbers in decimal form).

Alias: `INET_NTOA`.

## IPv4StringToNum(s)

The reverse function of IPv4NumToString. If the IPv4 address has an invalid format, it returns 0.

Alias: `INET_ATON`.

## IPv4NumToStringClassC(num)

Similar to IPv4NumToString, but using xxx instead of the last octet.

Example:

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

Since using ‘xxx’ is highly unusual, this may be changed in the future. We recommend that you do not rely on the exact format of this fragment.

### IPv6NumToString(x)

Accepts a FixedString(16) value containing the IPv6 address in binary format. Returns a string containing this address in text format.
IPv6-mapped IPv4 addresses are output in the format ::ffff:111.222.33.44.

Alias: `INET6_NTOA`.

Examples:

```
SELECT IPv6NumToString(toFixedString(unhex(2A0206B8000000000000000000000011), 16)) AS addr;
┌─addr─────────┐
│ 2a02:6b8::11 │
└──────────────┘
SELECT
    IPv6NumToString(ClientIP6 AS k),
    count() AS c
FROM hits_all
WHERE EventDate = today() AND substring(ClientIP6, 1, 12) != unhex(00000000000000000000FFFF)
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

## IPv6StringToNum[ ](https://clickhouse.tech/docs/en/sql-reference/functions/ip-address-functions/#ipv6stringtonums)

The reverse function of IPv6NumToString. If the IPv6 address has an invalid format, it returns a string of null bytes.

If the input string contains a valid IPv4 address, returns its IPv6 equivalent.
HEX can be uppercase or lowercase.

Alias: `INET6_ATON`.

**Syntax**

```
IPv6StringToNum(string)
```

**Argument**

- `string` — IP address. String.

**Returned value**

- IPv6 address in binary format.

Type: [FixedString(16)

**Example**

Query:

```
SELECT addr, cutIPv6(IPv6StringToNum(addr), 0, 0) FROM (SELECT [notaddress, 127.0.0.1, 1111::ffff] AS addr) ARRAY JOIN addr;
```

Result:

```
┌─addr───────┬─cutIPv6(IPv6StringToNum(addr), 0, 0)─┐
│ notaddress │ ::                                   │
│ 127.0.0.1  │ ::ffff:127.0.0.1                     │
│ 1111::ffff │ 1111::ffff                           │
└────────────┴──────────────────────────────────────┘
```

**See Also**

- [cutIPv6].

## IPv4ToIPv6(x)

Takes a `UInt32` number. Interprets it as an IPv4 address in [big endian. Returns a `FixedString(16)` value containing the IPv6 address in binary format. Examples:

```
SELECT IPv6NumToString(IPv4ToIPv6(IPv4StringToNum(192.168.0.1))) AS addr;
┌─addr───────────────┐
│ ::ffff:192.168.0.1 │
└────────────────────┘
```

## cutIPv6(x, bytesToCutForIPv6, bytesToCutForIPv4)

Accepts a FixedString(16) value containing the IPv6 address in binary format. Returns a string containing the address of the specified number of bytes removed in text format. For example:

```
WITH
    IPv6StringToNum(2001:0DB8:AC10:FE01:FEED:BABE:CAFE:F00D) AS ipv6,
    IPv4ToIPv6(IPv4StringToNum(192.168.0.1)) AS ipv4
SELECT
    cutIPv6(ipv6, 2, 0),
    cutIPv6(ipv4, 0, 2)
┌─cutIPv6(ipv6, 2, 0)─────────────────┬─cutIPv6(ipv4, 0, 2)─┐
│ 2001:db8:ac10:fe01:feed:babe:cafe:0 │ ::ffff:192.168.0.0  │
└─────────────────────────────────────┴─────────────────────┘
```

## IPv4CIDRToRange(ipv4, Cidr),

Accepts an IPv4 and an UInt8 value containing the CIDR. Return a tuple with two IPv4 containing the lower range and the higher range of the subnet.

```
SELECT IPv4CIDRToRange(toIPv4(192.168.5.2), 16);
┌─IPv4CIDRToRange(toIPv4(192.168.5.2), 16)─┐
│ (192.168.0.0,192.168.255.255)          │
└────────────────────────────────────────────┘
```

## IPv6CIDRToRange(ipv6, Cidr),

Accepts an IPv6 and an UInt8 value containing the CIDR. Return a tuple with two IPv6 containing the lower range and the higher range of the subnet.

```
SELECT IPv6CIDRToRange(toIPv6(2001:0db8:0000:85a3:0000:0000:ac1f:8001), 32);
┌─IPv6CIDRToRange(toIPv6(2001:0db8:0000:85a3:0000:0000:ac1f:8001), 32)─┐
│ (2001:db8::,2001:db8:ffff:ffff:ffff:ffff:ffff:ffff)                │
└────────────────────────────────────────────────────────────────────────┘
```

## toIPv4(string)

An alias to `IPv4StringToNum()` that takes a string form of IPv4 address and returns value of IPV4 type, which is binary equal to value returned by `IPv4StringToNum()`.

```
WITH
    171.225.130.45 as IPv4_string
SELECT
    toTypeName(IPv4StringToNum(IPv4_string)),
    toTypeName(toIPv4(IPv4_string))
┌─toTypeName(IPv4StringToNum(IPv4_string))─┬─toTypeName(toIPv4(IPv4_string))─┐
│ UInt32                                   │ IPv4                            │
└──────────────────────────────────────────┴─────────────────────────────────┘
WITH
    171.225.130.45 as IPv4_string
SELECT
    hex(IPv4StringToNum(IPv4_string)),
    hex(toIPv4(IPv4_string))
┌─hex(IPv4StringToNum(IPv4_string))─┬─hex(toIPv4(IPv4_string))─┐
│ ABE1822D                          │ ABE1822D                 │
└───────────────────────────────────┴──────────────────────────┘
```

## toIPv6

Converts a string form of IPv6 address to IPV6 type. If the IPv6 address has an invalid format, returns an empty value.
Similar to [IPv6StringToNum] function, which converts IPv6 address to binary format.

If the input string contains a valid IPv4 address, then the IPv6 equivalent of the IPv4 address is returned.

**Syntax**

```
toIPv6(string)
```

**Argument**

- `string` — IP address.String

**Returned value**

- IP address.

Type: IPv6

**Examples**

Query:

```
WITH 2001:438:ffff::407d:1bc1 AS IPv6_string
SELECT
    hex(IPv6StringToNum(IPv6_string)),
    hex(toIPv6(IPv6_string));
```

Result:

```
┌─hex(IPv6StringToNum(IPv6_string))─┬─hex(toIPv6(IPv6_string))─────────┐
│ 20010438FFFF000000000000407D1BC1  │ 20010438FFFF000000000000407D1BC1 │
└───────────────────────────────────┴──────────────────────────────────┘
```

Query:

```
SELECT toIPv6(127.0.0.1);
```

Result:

```
┌─toIPv6(127.0.0.1)─┐
│ ::ffff:127.0.0.1    │
└─────────────────────┘
```

## isIPv4String

Determines whether the input string is an IPv4 address or not. If `string` is IPv6 address returns `0`.

**Syntax**

```
isIPv4String(string)
```

**Arguments**

- `string` — IP address. String.

**Returned value**

- `1` if `string` is IPv4 address, `0` otherwise.

Type: UInt8.

**Examples**

Query:

```
SELECT addr, isIPv4String(addr) FROM ( SELECT [0.0.0.0, 127.0.0.1, ::ffff:127.0.0.1] AS addr ) ARRAY JOIN addr;
```

Result:

```
┌─addr─────────────┬─isIPv4String(addr)─┐
│ 0.0.0.0          │                  1 │
│ 127.0.0.1        │                  1 │
│ ::ffff:127.0.0.1 │                  0 │
└──────────────────┴────────────────────┘
```

## isIPv6String

Determines whether the input string is an IPv6 address or not. If `string` is IPv4 address returns `0`.

**Syntax**

```
isIPv6String(string)
```

**Arguments**

- `string` — IP address. String.

**Returned value**

- `1` if `string` is IPv6 address, `0` otherwise.

Type: UInt8.

**Examples**

Query:

```
SELECT addr, isIPv6String(addr) FROM ( SELECT [::, 1111::ffff, ::ffff:127.0.0.1, 127.0.0.1] AS addr ) ARRAY JOIN addr;
```

Result:

```
┌─addr─────────────┬─isIPv6String(addr)─┐
│ ::               │                  1 │
│ 1111::ffff       │                  1 │
│ ::ffff:127.0.0.1 │                  1 │
│ 127.0.0.1        │                  0 │
└──────────────────┴────────────────────┘
```

## isIPAddressInRange

Determines if an IP address is contained in a network represented in the CIDR notation. Returns `1` if true, or `0` otherwise.

**Syntax**

```
isIPAddressInRange(address, prefix)
```

This function accepts both IPv4 and IPv6 addresses (and networks) represented as strings. It returns `0` if the IP version of the address and the CIDR dont match.

**Arguments**

- `address` — An IPv4 or IPv6 address.String
- `prefix` — An IPv4 or IPv6 network prefix in CIDR. String

**Returned value**

- `1` or `0`.

Type: UInt8.

**Example**

Query:

```
SELECT isIPAddressInRange(127.0.0.1, 127.0.0.0/8);
```

Result:

```
┌─isIPAddressInRange(127.0.0.1, 127.0.0.0/8)─┐
│                                              1 │
└────────────────────────────────────────────────┘
```

Query:

```
SELECT isIPAddressInRange(127.0.0.1, ffff::/16);
```

Result:

```
┌─isIPAddressInRange(127.0.0.1, ffff::/16)─┐
│                                            0 │
└──────────────────────────────────────────────┘
```

' where id=27;
update biz_data_query_model_help_content set content_en = '# Functions for Working with JSON

In Yandex.Metrica, JSON is transmitted by users as session parameters. There are some special functions for working with this JSON. (Although in most of the cases, the JSONs are additionally pre-processed, and the resulting values are put in separate columns in their processed format.) All these functions are based on strong assumptions about what the JSON can be, but they try to do as little as possible to get the job done.

The following assumptions are made:

1. The field name (function argument) must be a constant.
2. The field name is somehow canonically encoded in JSON. For example: `visitParamHas({"abc":"def"}, abc) = 1`, but `visitParamHas({"\\u0061\\u0062\\u0063":"def"}, abc) = 0`
3. Fields are searched for on any nesting level, indiscriminately. If there are multiple matching fields, the first occurrence is used.
4. The JSON does not have space characters outside of string literals.

## visitParamHas(params, name)

Checks whether there is a field with the `name` name.

Alias: `simpleJSONHas`.

## visitParamExtractUInt(params, name)

Parses UInt64 from the value of the field named `name`. If this is a string field, it tries to parse a number from the beginning of the string. If the field does not exist, or it exists but does not contain a number, it returns 0.

Alias: `simpleJSONExtractUInt`.

## visitParamExtractInt(params, name)

The same as for Int64.

Alias: `simpleJSONExtractInt`.

## visitParamExtractFloat(params, name)

The same as for Float64.

Alias: `simpleJSONExtractFloat`.

## visitParamExtractBool(params, name)

Parses a true/false value. The result is UInt8.

Alias: `simpleJSONExtractBool`.

## visitParamExtractRaw(params, name)

Returns the value of a field, including separators.

Alias: `simpleJSONExtractRaw`.

Examples:

```
visitParamExtractRaw({"abc":"\\n\\u"}, abc) = "\\n\\u";
visitParamExtractRaw({"abc":{"def":[1,2,3]}}, abc) = {"def":[1,2,3]};
```

## visitParamExtractString(params, name)

Parses the string in double quotes. The value is unescaped. If unescaping failed, it returns an empty string.

Alias: `simpleJSONExtractString`.

Examples:

```
visitParamExtractString({"abc":"\\n\\u"}, abc) = \n\0;
visitParamExtractString({"abc":"\\u263a"}, abc) = ☺;
visitParamExtractString({"abc":"\\u263"}, abc) = ;
visitParamExtractString({"abc":"hello}, abc) = ;
```

There is currently no support for code points in the format `\uXXXX\uYYYY` that are not from the basic multilingual plane (they are converted to CESU-8 instead of UTF-8).

The following functions are based on simdjson designed for more complex JSON parsing requirements. The assumption 2 mentioned above still applies.

## isValidJSON(json)

Checks that passed string is a valid json.

Examples:

```
SELECT isValidJSON({"a": "hello", "b": [-100, 200.0, 300]}) = 1
SELECT isValidJSON(not a json) = 0
```

## JSONHas(json[, indices_or_keys]…)

If the value exists in the JSON document, `1` will be returned.

If the value does not exist, `0` will be returned.

Examples:

```
SELECT JSONHas({"a": "hello", "b": [-100, 200.0, 300]}, b) = 1
SELECT JSONHas({"a": "hello", "b": [-100, 200.0, 300]}, b, 4) = 0
```

`indices_or_keys` is a list of zero or more arguments each of them can be either string or integer.

- String = access object member by key.
- Positive integer = access the n-th member/key from the beginning.
- Negative integer = access the n-th member/key from the end.

Minimum index of the element is 1. Thus the element 0 does not exist.

You may use integers to access both JSON arrays and JSON objects.

So, for example:

```
SELECT JSONExtractKey({"a": "hello", "b": [-100, 200.0, 300]}, 1) = a
SELECT JSONExtractKey({"a": "hello", "b": [-100, 200.0, 300]}, 2) = b
SELECT JSONExtractKey({"a": "hello", "b": [-100, 200.0, 300]}, -1) = b
SELECT JSONExtractKey({"a": "hello", "b": [-100, 200.0, 300]}, -2) = a
SELECT JSONExtractString({"a": "hello", "b": [-100, 200.0, 300]}, 1) = hello
```

## JSONLength(json[, indices_or_keys]…)

Return the length of a JSON array or a JSON object.

If the value does not exist or has a wrong type, `0` will be returned.

Examples:

```
SELECT JSONLength({"a": "hello", "b": [-100, 200.0, 300]}, b) = 3
SELECT JSONLength({"a": "hello", "b": [-100, 200.0, 300]}) = 2
```

## JSONType(json[, indices_or_keys]…)

Return the type of a JSON value.

If the value does not exist, `Null` will be returned.

Examples:

```
SELECT JSONType({"a": "hello", "b": [-100, 200.0, 300]}) = Object
SELECT JSONType({"a": "hello", "b": [-100, 200.0, 300]}, a) = String
SELECT JSONType({"a": "hello", "b": [-100, 200.0, 300]}, b) = Array
```

## JSONExtractUInt(json[, indices_or_keys]…)

## JSONExtractInt(json[, indices_or_keys]…)

## JSONExtractFloat(json[, indices_or_keys]…)

## JSONExtractBool(json[, indices_or_keys]…)

Parses a JSON and extract a value. These functions are similar to `visitParam` functions.

If the value does not exist or has a wrong type, `0` will be returned.

Examples:

```
SELECT JSONExtractInt({"a": "hello", "b": [-100, 200.0, 300]}, b, 1) = -100
SELECT JSONExtractFloat({"a": "hello", "b": [-100, 200.0, 300]}, b, 2) = 200.0
SELECT JSONExtractUInt({"a": "hello", "b": [-100, 200.0, 300]}, b, -1) = 300
```

## JSONExtractString(json[, indices_or_keys]…)

Parses a JSON and extract a string. This function is similar to `visitParamExtractString` functions.

If the value does not exist or has a wrong type, an empty string will be returned.

The value is unescaped. If unescaping failed, it returns an empty string.

Examples:

```
SELECT JSONExtractString({"a": "hello", "b": [-100, 200.0, 300]}, a) = hello
SELECT JSONExtractString({"abc":"\\n\\u"}, abc) = \n\0
SELECT JSONExtractString({"abc":"\\u263a"}, abc) = ☺
SELECT JSONExtractString({"abc":"\\u263"}, abc) = 
SELECT JSONExtractString({"abc":"hello}, abc) = 
```

## JSONExtract(json[, indices_or_keys…], Return_type)

Parses a JSON and extract a value of the given ClickHouse data type.

This is a generalization of the previous `JSONExtract<type>` functions.
This means
`JSONExtract(..., String)` returns exactly the same as `JSONExtractString()`,
`JSONExtract(..., Float64)` returns exactly the same as `JSONExtractFloat()`.

Examples:

```
SELECT JSONExtract({"a": "hello", "b": [-100, 200.0, 300]}, Tuple(String, Array(Float64))) = (hello,[-100,200,300])
SELECT JSONExtract({"a": "hello", "b": [-100, 200.0, 300]}, Tuple(b Array(Float64), a String)) = ([-100,200,300],hello)
SELECT JSONExtract({"a": "hello", "b": [-100, 200.0, 300]}, b, Array(Nullable(Int8))) = [-100, NULL, NULL]
SELECT JSONExtract({"a": "hello", "b": [-100, 200.0, 300]}, b, 4, Nullable(Int64)) = NULL
SELECT JSONExtract({"passed": true}, passed, UInt8) = 1
SELECT JSONExtract({"day": "Thursday"}, day, Enum8(\Sunday\ = 0, \Monday\ = 1, \Tuesday\ = 2, \Wednesday\ = 3, \Thursday\ = 4, \Friday\ = 5, \Saturday\ = 6)) = Thursday
SELECT JSONExtract({"day": 5}, day, Enum8(\Sunday\ = 0, \Monday\ = 1, \Tuesday\ = 2, \Wednesday\ = 3, \Thursday\ = 4, \Friday\ = 5, \Saturday\ = 6)) = Friday
```

## JSONExtractKeysAndValues(json[, indices_or_keys…], Value_type)

Parses key-value pairs from a JSON where the values are of the given ClickHouse data type.

Example:

```
SELECT JSONExtractKeysAndValues({"x": {"a": 5, "b": 7, "c": 11}}, x, Int8) = [(a,5),(b,7),(c,11)];
```

## JSONExtractRaw(json[, indices_or_keys]…)

Returns a part of JSON as unparsed string.

If the part does not exist or has a wrong type, an empty string will be returned.

Example:

```
SELECT JSONExtractRaw({"a": "hello", "b": [-100, 200.0, 300]}, b) = [-100, 200.0, 300];
```

## JSONExtractArrayRaw(json[, indices_or_keys…])

Returns an array with elements of JSON array, each represented as unparsed string.

If the part does not exist or isn’t array, an empty array will be returned.

Example:

```
SELECT JSONExtractArrayRaw({"a": "hello", "b": [-100, 200.0, "hello"]}, b) = [-100, 200.0, "hello"];
```

## JSONExtractKeysAndValuesRaw

Extracts raw data from a JSON object.

**Syntax**

```
JSONExtractKeysAndValuesRaw(json[, p, a, t, h])
```

**Arguments**

- `json` — String with valid JSON.
- `p, a, t, h` — Comma-separated indices or keys that specify the path to the inner field in a nested JSON object. Each argument can be either a string to get the field by the key or an integer to get the N-th field (indexed from 1, negative integers count from the end). If not set, the whole JSON is parsed as the top-level object. Optional parameter.

**Returned values**

- Array with `(key, value)` tuples. Both tuple members are strings.
- Empty array if the requested object does not exist, or input JSON is invalid.

Type: Array(Tuple(String,String))

**Examples**

Query:

```
SELECT JSONExtractKeysAndValuesRaw({"a": [-100, 200.0], "b":{"c": {"d": "hello", "f": "world"}}});
```

Result:

```
┌─JSONExtractKeysAndValuesRaw({"a": [-100, 200.0], "b":{"c": {"d": "hello", "f": "world"}}})─┐
│ [(a,[-100,200]),(b,{"c":{"d":"hello","f":"world"}})]                                 │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

Query:

```
SELECT JSONExtractKeysAndValuesRaw({"a": [-100, 200.0], "b":{"c": {"d": "hello", "f": "world"}}}, b);
```

Result:

```
┌─JSONExtractKeysAndValuesRaw({"a": [-100, 200.0], "b":{"c": {"d": "hello", "f": "world"}}}, b)─┐
│ [(c,{"d":"hello","f":"world"})]                                                               │
└───────────────────────────────────────────────────────────────────────────────────────────────────┘
```

Query:

```
SELECT JSONExtractKeysAndValuesRaw({"a": [-100, 200.0], "b":{"c": {"d": "hello", "f": "world"}}}, -1, c);
```

Result:

```
┌─JSONExtractKeysAndValuesRaw({"a": [-100, 200.0], "b":{"c": {"d": "hello", "f": "world"}}}, -1, c)─┐
│ [(d,"hello"),(f,"world")]                                                                     │
└───────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

' where id=28;
update biz_data_query_model_help_content set content_en = '# Functions for Working with Nullable Values[ ](https://clickhouse.tech/docs/en/sql-reference/functions/functions-for-nulls/#functions-for-working-with-nullable-aggregates)

## isNull

Checks whether the argument is Null

```
isNull(x)
```

Alias: `ISNULL`.

**Arguments**

- `x` — A value with a non-compound data type.

**Returned value**

- `1` if `x` is `NULL`.
- `0` if `x` is not `NULL`.

**Example**

Input table

```
┌─x─┬────y─┐
│ 1 │ ᴺᵁᴸᴸ │
│ 2 │    3 │
└───┴──────┘
```

Query

```
SELECT x FROM t_null WHERE isNull(y);
┌─x─┐
│ 1 │
└───┘
```

## isNotNull

Checks whether the argument is NULL

```
isNotNull(x)
```

**Arguments:**

- `x` — A value with a non-compound data type.

**Returned value**

- `0` if `x` is `NULL`.
- `1` if `x` is not `NULL`.

**Example**

Input table

```
┌─x─┬────y─┐
│ 1 │ ᴺᵁᴸᴸ │
│ 2 │    3 │
└───┴──────┘
```

Query

```
SELECT x FROM t_null WHERE isNotNull(y);
┌─x─┐
│ 2 │
└───┘
```

## coalesce

Checks from left to right whether `NULL` arguments were passed and returns the first non-`NULL` argument.

```
coalesce(x,...)
```

**Arguments:**

- Any number of parameters of a non-compound type. All parameters must be compatible by data type.

**Returned values**

- The first non-`NULL` argument.
- `NULL`, if all arguments are `NULL`.

**Example**

Consider a list of contacts that may specify multiple ways to contact a customer.

```
┌─name─────┬─mail─┬─phone─────┬──icq─┐
│ client 1 │ ᴺᵁᴸᴸ │ 123-45-67 │  123 │
│ client 2 │ ᴺᵁᴸᴸ │ ᴺᵁᴸᴸ      │ ᴺᵁᴸᴸ │
└──────────┴──────┴───────────┴──────┘
```

The `mail` and `phone` fields are of type String, but the `icq` field is `UInt32`, so it needs to be converted to `String`.

Get the first available contact method for the customer from the contact list:

```
SELECT coalesce(mail, phone, CAST(icq,Nullable(String))) FROM aBook;
┌─name─────┬─coalesce(mail, phone, CAST(icq, Nullable(String)))─┐
│ client 1 │ 123-45-67                                            │
│ client 2 │ ᴺᵁᴸᴸ                                                 │
└──────────┴──────────────────────────────────────────────────────┘
```

## ifNull

Returns an alternative value if the main argument is `NULL`.

```
ifNull(x,alt)
```

**Arguments:**

- `x` — The value to check for `NULL`.
- `alt` — The value that the function returns if `x` is `NULL`.

**Returned values**

- The value `x`, if `x` is not `NULL`.
- The value `alt`, if `x` is `NULL`.

**Example**

```
SELECT ifNull(a, b);
┌─ifNull(a, b)─┐
│ a                │
└──────────────────┘
SELECT ifNull(NULL, b);
┌─ifNull(NULL, b)─┐
│ b                 │
└───────────────────┘
```

## nullIf

Returns `NULL` if the arguments are equal.

```
nullIf(x, y)
```

**Arguments:**

`x`, `y` — Values for comparison. They must be compatible types, or ClickHouse will generate an exception.

**Returned values**

- `NULL`, if the arguments are equal.
- The `x` value, if the arguments are not equal.

**Example**

```
SELECT nullIf(1, 1);
┌─nullIf(1, 1)─┐
│         ᴺᵁᴸᴸ │
└──────────────┘
SELECT nullIf(1, 2);
┌─nullIf(1, 2)─┐
│            1 │
└──────────────┘
```

## assumeNotNull

Results in a value of type Nullable for a non- `Nullable`, if the value is not `NULL`.

```
assumeNotNull(x)
```

**Arguments:**

- `x` — The original value.

**Returned values**

- The original value from the non-`Nullable` type, if it is not `NULL`.
- Implementation specific result if the original value was `NULL`.

**Example**

Consider the `t_null` table.

```
SHOW CREATE TABLE t_null;
┌─statement─────────────────────────────────────────────────────────────────┐
│ CREATE TABLE default.t_null ( x Int8,  y Nullable(Int8)) ENGINE = TinyLog │
└───────────────────────────────────────────────────────────────────────────┘
┌─x─┬────y─┐
│ 1 │ ᴺᵁᴸᴸ │
│ 2 │    3 │
└───┴──────┘
```

Apply the `assumeNotNull` function to the `y` column.

```
SELECT assumeNotNull(y) FROM t_null;
┌─assumeNotNull(y)─┐
│                0 │
│                3 │
└──────────────────┘
SELECT toTypeName(assumeNotNull(y)) FROM t_null;
┌─toTypeName(assumeNotNull(y))─┐
│ Int8                         │
│ Int8                         │
└──────────────────────────────┘
```

## toNullable

Converts the argument type to `Nullable`.

```
toNullable(x)
```

**Arguments:**

- `x` — The value of any non-compound type.

**Returned value**

- The input value with a `Nullable` type.

**Example**

```
SELECT toTypeName(10);
┌─toTypeName(10)─┐
│ UInt8          │
└────────────────┘
SELECT toTypeName(toNullable(10));
┌─toTypeName(toNullable(10))─┐
│ Nullable(UInt8)            │
└────────────────────────────┘
```

' where id=29;
update biz_data_query_model_help_content set content_en = '# Functions for Working with URLs

All these functions do not follow the RFC. They are maximally simplified for improved performance.

## Functions that Extract Parts of a URL

If the relevant part isn’t present in a URL, an empty string is returned.

### protocol

Extracts the protocol from a URL.

Examples of typical returned values: http, https, ftp, mailto, tel, magnet…

### domain

Extracts the hostname from a URL.

```
domain(url)
```

**Arguments**

- `url` — URL. Type: String.

The URL can be specified with or without a scheme. Examples:

```
svn+ssh://some.svn-hosting.com:80/repo/trunk
some.svn-hosting.com:80/repo/trunk
https://yandex.com/time/
```

For these examples, the `domain` function returns the following results:

```
some.svn-hosting.com
some.svn-hosting.com
yandex.com
```

**Returned values**

- Host name. If ClickHouse can parse the input string as a URL.
- Empty string. If ClickHouse can’t parse the input string as a URL.

Type: `String`.

**Example**

```
SELECT domain(svn+ssh://some.svn-hosting.com:80/repo/trunk);
┌─domain(svn+ssh://some.svn-hosting.com:80/repo/trunk)─┐
│ some.svn-hosting.com                                   │
└────────────────────────────────────────────────────────┘
```

### domainWithoutWWW

Returns the domain and removes no more than one ‘www.’ from the beginning of it, if present.

### topLevelDomain

Extracts the the top-level domain from a URL.

```
topLevelDomain(url)
```

**Arguments**

- `url` — URL. Type: String.

The URL can be specified with or without a scheme. Examples:

```
svn+ssh://some.svn-hosting.com:80/repo/trunk
some.svn-hosting.com:80/repo/trunk
https://yandex.com/time/
```

**Returned values**

- Domain name. If ClickHouse can parse the input string as a URL.
- Empty string. If ClickHouse cannot parse the input string as a URL.

Type: `String`.

**Example**

```
SELECT topLevelDomain(svn+ssh://www.some.svn-hosting.com:80/repo/trunk);
┌─topLevelDomain(svn+ssh://www.some.svn-hosting.com:80/repo/trunk)─┐
│ com                                                                │
└────────────────────────────────────────────────────────────────────┘
```

### firstSignificantSubdomain

Returns the “first significant subdomain”. This is a non-standard concept specific to Yandex.Metrica. The first significant subdomain is a second-level domain if it is ‘com’, ‘net’, ‘org’, or ‘co’. Otherwise, it is a third-level domain. For example, `firstSignificantSubdomain (‘https://news.yandex.ru/’) = ‘yandex’, firstSignificantSubdomain (‘https://news.yandex.com.tr/’) = ‘yandex’`. The list of “insignificant” second-level domains and other implementation details may change in the future.

### cutToFirstSignificantSubdomain

Returns the part of the domain that includes top-level subdomains up to the “first significant subdomain” (see the explanation above).

For example:

- `cutToFirstSignificantSubdomain(https://news.yandex.com.tr/) = yandex.com.tr`.
- `cutToFirstSignificantSubdomain(www.tr) = tr`.
- `cutToFirstSignificantSubdomain(tr) = `.

### cutToFirstSignificantSubdomainWithWWW

Returns the part of the domain that includes top-level subdomains up to the “first significant subdomain”, without stripping "www".

For example:

- `cutToFirstSignificantSubdomain(https://news.yandex.com.tr/) = yandex.com.tr`.
- `cutToFirstSignificantSubdomain(www.tr) = www.tr`.
- `cutToFirstSignificantSubdomain(tr) = `.

### cutToFirstSignificantSubdomainCustom

Returns the part of the domain that includes top-level subdomains up to the first significant subdomain. Accepts custom TLD list name.

Can be useful if you need fresh TLD list or you have custom.

Configuration example:

```
<!-- <top_level_domains_path>/var/lib/clickhouse/top_level_domains/</top_level_domains_path> -->
<top_level_domains_lists>
    <!-- https://publicsuffix.org/list/public_suffix_list.dat -->
    <public_suffix_list>public_suffix_list.dat</public_suffix_list>
    <!-- NOTE: path is under top_level_domains_path -->
</top_level_domains_lists>
```

**Syntax**

```
cutToFirstSignificantSubdomain(URL, TLD)
```

**Parameters**

- `URL` — URL. String
- `TLD` — Custom TLD list name. String

**Returned value**

- Part of the domain that includes top-level subdomains up to the first significant subdomain.

Type: String

**Example**

Query:

```
SELECT cutToFirstSignificantSubdomainCustom(bar.foo.there-is-no-such-domain, public_suffix_list);
```

Result:

```
┌─cutToFirstSignificantSubdomainCustom(bar.foo.there-is-no-such-domain, public_suffix_list)─┐
│ foo.there-is-no-such-domain                                                                   │
└───────────────────────────────────────────────────────────────────────────────────────────────┘
```

**See Also**

- [firstSignificantSubdomain.

### cutToFirstSignificantSubdomainCustomWithWWW

Returns the part of the domain that includes top-level subdomains up to the first significant subdomain without stripping `www`. Accepts custom TLD list name.

Can be useful if you need fresh TLD list or you have custom.

Configuration example:

```
<!-- <top_level_domains_path>/var/lib/clickhouse/top_level_domains/</top_level_domains_path> -->
<top_level_domains_lists>
    <!-- https://publicsuffix.org/list/public_suffix_list.dat -->
    <public_suffix_list>public_suffix_list.dat</public_suffix_list>
    <!-- NOTE: path is under top_level_domains_path -->
</top_level_domains_lists>
```

**Syntax**

```
cutToFirstSignificantSubdomainCustomWithWWW(URL, TLD)
```

**Parameters**

- `URL` — URL. String
- `TLD` — Custom TLD list name. String

**Returned value**

- Part of the domain that includes top-level subdomains up to the first significant subdomain without stripping `www`.

Type: String

**Example**

Query:

```
SELECT cutToFirstSignificantSubdomainCustomWithWWW(www.foo, public_suffix_list);
```

Result:

```
┌─cutToFirstSignificantSubdomainCustomWithWWW(www.foo, public_suffix_list)─┐
│ www.foo                                                                      │
└──────────────────────────────────────────────────────────────────────────────┘
```

**See Also**

- firstSignificantSubdomain.

### firstSignificantSubdomainCustom

Returns the first significant subdomain. Accepts customs TLD list name.

Can be useful if you need fresh TLD list or you have custom.

Configuration example:

```
<!-- <top_level_domains_path>/var/lib/clickhouse/top_level_domains/</top_level_domains_path> -->
<top_level_domains_lists>
    <!-- https://publicsuffix.org/list/public_suffix_list.dat -->
    <public_suffix_list>public_suffix_list.dat</public_suffix_list>
    <!-- NOTE: path is under top_level_domains_path -->
</top_level_domains_lists>
```

**Syntax**

```
firstSignificantSubdomainCustom(URL, TLD)
```

**Parameters**

- `URL` — URL. String
- `TLD` — Custom TLD list name. String

**Returned value**

- First significant subdomain.

Type: String

**Example**

Query:

```
SELECT firstSignificantSubdomainCustom(bar.foo.there-is-no-such-domain, public_suffix_list);
```

Result:

```
┌─firstSignificantSubdomainCustom(bar.foo.there-is-no-such-domain, public_suffix_list)─┐
│ foo                                                                                      │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

**See Also**

- [firstSignificantSubdomain

### port(URL[, default_port = 0])

Returns the port or `default_port` if there is no port in the URL (or in case of validation error).

### path

Returns the path. Example: `/top/news.html` The path does not include the query string.

### pathFull

The same as above, but including query string and fragment. Example: /top/news.html?page=2#comments

### queryString

Returns the query string. Example: page=1&lr=213. query-string does not include the initial question mark, as well as # and everything after #.

### fragment

Returns the fragment identifier. fragment does not include the initial hash symbol.

### queryStringAndFragment

Returns the query string and fragment identifier. Example: page=1#29390.

### extractURLParameter(URL, name)

Returns the value of the ‘name’ parameter in the URL, if present. Otherwise, an empty string. If there are many parameters with this name, it returns the first occurrence. This function works under the assumption that the parameter name is encoded in the URL exactly the same way as in the passed argument.

### extractURLParameters(URL)

Returns an array of name=value strings corresponding to the URL parameters. The values are not decoded in any way.

### extractURLParameterNames(URL)

Returns an array of name strings corresponding to the names of URL parameters. The values are not decoded in any way.

### URLHierarchy(URL)

Returns an array containing the URL, truncated at the end by the symbols /,? in the path and query-string. Consecutive separator characters are counted as one. The cut is made in the position after all the consecutive separator characters.

### URLPathHierarchy(URL)

The same as above, but without the protocol and host in the result. The / element (root) is not included. Example: the function is used to implement tree reports the URL in Yandex. Metric.

```
URLPathHierarchy(https://example.com/browse/CONV-6788) =
[
    /browse/,
    /browse/CONV-6788
]
```

### decodeURLComponent(URL)

Returns the decoded URL.
Example:

```
SELECT decodeURLComponent(http://127.0.0.1:8123/?query=SELECT%201%3B) AS DecodedURL;
┌─DecodedURL─────────────────────────────┐
│ http://127.0.0.1:8123/?query=SELECT 1; │
└────────────────────────────────────────┘
```

### netloc[ ](https://clickhouse.tech/docs/en/sql-reference/functions/url-functions/#netloc)

Extracts network locality (`username:password@host:port`) from a URL.

**Syntax**

```
netloc(URL)
```

**Arguments**

- `url` — URL. String.

**Returned value**

- `username:password@host:port`.

Type: `String`.

**Example**

Query:

```
SELECT netloc(http://paul@www.example.com:80/);
```

Result:

```
┌─netloc(http://paul@www.example.com:80/)─┐
│ paul@www.example.com:80                   │
└───────────────────────────────────────────┘
```

## Functions that Remove Part of a URL

If the URL does not have anything similar, the URL remains unchanged.

### cutWWW

Removes no more than one ‘www.’ from the beginning of the URL’s domain, if present.

### cutQueryString

Removes query string. The question mark is also removed.

### cutFragment

Removes the fragment identifier. The number sign is also removed.

### cutQueryStringAndFragment

Removes the query string and fragment identifier. The question mark and number sign are also removed.

### cutURLParameter(URL, name)

Removes the ‘name’ URL parameter, if present. This function works under the assumption that the parameter name is encoded in the URL exactly the same way as in the passed argument.

' where id=30;

update biz_data_query_model_help_content set content_en = '# Functions for Working with UUID

The functions for working with UUID are listed below.

## generateUUIDv4

Generates the UUID of version4.

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
SELECT toUUID(61f0c404-5cb3-11e7-907b-a6006ad3dba0) AS uuid
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
SELECT toUUIDOrNull(61f0c404-5cb3-11e7-907b-a6006ad3dba0T) AS uuid
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
SELECT toUUIDOrZero(61f0c404-5cb3-11e7-907b-a6006ad3dba0T) AS uuid
┌─────────────────────────────────uuid─┐
│ ---- │
└──────────────────────────────────────┘
```

## UUIDStringToNum

Accepts a string containing 36 characters in the format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`, and returns it as a set of bytes in a FixedString(16)

```
UUIDStringToNum(String)
```

**Returned value**

FixedString(16)

**Usage examples**

```
SELECT
    612f3c40-5d3b-217e-707b-6a546a3d7b29 AS uuid,
    UUIDStringToNum(uuid) AS bytes
┌─uuid─────────────────────────────────┬─bytes────────────┐
│ 612f3c40-5d3b-217e-707b-6a546a3d7b29 │ a/<@];!~p{jTj={) │
└──────────────────────────────────────┴──────────────────┘
```

## UUIDNumToString

Accepts a FixedString(16) value, and returns a string containing 36 characters in text format.

```
UUIDNumToString(FixedString(16))
```

**Returned value**

String.

**Usage example**

```
SELECT
    a/<@];!~p{jTj={) AS bytes,
    UUIDNumToString(toFixedString(bytes, 16)) AS uuid
┌─bytes────────────┬─uuid─────────────────────────────────┐
│ a/<@];!~p{jTj={) │ 612f3c40-5d3b-217e-707b-6a546a3d7b29 │
└──────────────────┴──────────────────────────────────────┘
```

' where id=31;
update biz_data_query_model_help_content set content_en = '# Array Functions

## empty

Returns 1 for an empty array, or 0 for a non-empty array.
The result type is UInt8.
The function also works for strings.

Can be optimized by enabling the optimize_functions_to_subcolumns setting. With `optimize_functions_to_subcolumns = 1` the function reads only size0subcolumn instead of reading and processing the whole array column. The query `SELECT empty(arr) FROM table` transforms to `SELECT arr.size0 = 0 FROM TABLE`.

## notEmpty

Returns 0 for an empty array, or 1 for a non-empty array.
The result type is UInt8.
The function also works for strings.

Can be optimized by enabling the optimize_functions_to_subcolumns setting. With `optimize_functions_to_subcolumns = 1` the function reads only size0 subcolumn instead of reading and processing the whole array column. The query `SELECT notEmpty(arr) FROM table` transforms to `SELECT arr.size0 != 0 FROM TABLE`.

## length

Returns the number of items in the array.
The result type is UInt64.
The function also works for strings.

Can be optimized by enabling the [optimize_functions_to_subcolumns setting. With `optimize_functions_to_subcolumns = 1` the function reads only size0 subcolumn instead of reading and processing the whole array column. The query `SELECT length(arr) FROM table` transforms to `SELECT arr.size0 FROM TABLE`.

## emptyArrayUInt8, emptyArrayUInt16, emptyArrayUInt32, emptyArrayUInt64

## emptyArrayInt8, emptyArrayInt16, emptyArrayInt32, emptyArrayInt64

## emptyArrayFloat32, emptyArrayFloat64

## emptyArrayDate, emptyArrayDateTime

## emptyArrayString

Accepts zero arguments and returns an empty array of the appropriate type.

## emptyArrayToSingle

Accepts an empty array and returns a one-element array that is equal to the default value.

## range(end), range([start, ] end [, step])

Returns an array of `UInt` numbers from `start` to `end - 1` by `step`.

**Syntax**

```
range([start, ] end [, step])
```

**Arguments**

- `start` — The first element of the array. Optional, required if `step` is used. Default value: 0. UInt
- `end` — The number before which the array is constructed. Required. UInt
- `step` — Determines the incremental step between each element in the array. Optional. Default value: 1. Uint

**Returned value**

- Array of `UInt` numbers from `start` to `end - 1` by `step`.

**Implementation details**

- All arguments must be positive values: `start`, `end`, `step` are `UInt` data types, as well as elements of the returned array.
- An exception is thrown if query results in arrays with a total length of more than 100,000,000 elements.

**Examples**

Query:

```
SELECT range(5), range(1, 5), range(1, 5, 2);
```

Result:

```
┌─range(5)────┬─range(1, 5)─┬─range(1, 5, 2)─┐
│ [0,1,2,3,4] │ [1,2,3,4]   │ [1,3]          │
└─────────────┴─────────────┴────────────────┘
```

## array(x1, …), operator x1, …

Creates an array from the function arguments.
The arguments must be constants and have types that have the smallest common type. At least one argument must be passed, because otherwise it isn’t clear which type of array to create. That is, you can’t use this function to create an empty array (to do that, use the ‘emptyArray*’ function described above).
Returns an ‘Array(T)’ type result, where ‘T’ is the smallest common type out of the passed arguments.

## arrayConcat

Combines arrays passed as arguments.

```
arrayConcat(arrays)
```

**Arguments**

- `arrays` – Arbitrary number of arguments of Array type.
  **Example**

```
SELECT arrayConcat([1, 2], [3, 4], [5, 6]) AS res
┌─res───────────┐
│ [1,2,3,4,5,6] │
└───────────────┘
```

## arrayElement(arr, n), operator arrn

Get the element with the index `n` from the array `arr`. `n` must be any integer type.
Indexes in an array begin from one.
Negative indexes are supported. In this case, it selects the corresponding element numbered from the end. For example, `arr[-1]` is the last item in the array.

If the index falls outside of the bounds of an array, it returns some default value (0 for numbers, an empty string for strings, etc.), except for the case with a non-constant array and a constant index 0 (in this case there will be an error `Array indices are 1-based`).

## has(arr, elem)

Checks whether the ‘arr’ array has the ‘elem’ element.
Returns 0 if the element is not in the array, or 1 if it is.

`NULL` is processed as a value.

```
SELECT has([1, 2, NULL], NULL)
┌─has([1, 2, NULL], NULL)─┐
│                       1 │
└─────────────────────────┘
```

## hasAll

Checks whether one array is a subset of another.

```
hasAll(set, subset)
```

**Arguments**

- `set` – Array of any type with a set of elements.
- `subset` – Array of any type with elements that should be tested to be a subset of `set`.

**Return values**

- `1`, if `set` contains all of the elements from `subset`.
- `0`, otherwise.

**Peculiar properties**

- An empty array is a subset of any array.
- `Null` processed as a value.
- Order of values in both of arrays does not matter.

**Examples**

`SELECT hasAll([], [])` returns 1.

`SELECT hasAll([1, Null], [Null])` returns 1.

`SELECT hasAll([1.0, 2, 3, 4], [1, 3])` returns 1.

`SELECT hasAll([a, b], [a])` returns 1.

`SELECT hasAll([1], [a])` returns 0.

`SELECT hasAll([[1, 2], [3, 4]], [[1, 2], [3, 5]])` returns 0.

## hasAny

Checks whether two arrays have intersection by some elements.

```
hasAny(array1, array2)
```

**Arguments**

- `array1` – Array of any type with a set of elements.
- `array2` – Array of any type with a set of elements.

**Return values**

- `1`, if `array1` and `array2` have one similar element at least.
- `0`, otherwise.

**Peculiar properties**

- `Null` processed as a value.
- Order of values in both of arrays does not matter.

**Examples**

`SELECT hasAny([1], [])` returns `0`.

`SELECT hasAny([Null], [Null, 1])` returns `1`.

`SELECT hasAny([-128, 1., 512], [1])` returns `1`.

`SELECT hasAny([[1, 2], [3, 4]], [a, c])` returns `0`.

`SELECT hasAll([[1, 2], [3, 4]], [[1, 2], [1, 2]])` returns `1`.

## hasSubstr

Checks whether all the elements of array2 appear in array1 in the same exact order. Therefore, the function will return 1, if and only if `array1 = prefix + array2 + suffix`.

```
hasSubstr(array1, array2)
```

In other words, the functions will check whether all the elements of `array2` are contained in `array1` like
the `hasAll` function. In addition, it will check that the elements are observed in the same order in both `array1` and `array2`.

For Example:
\- `hasSubstr([1,2,3,4], [2,3])` returns 1. However, `hasSubstr([1,2,3,4], [3,2])` will return `0`.
\- `hasSubstr([1,2,3,4], [1,2,3])` returns 1. However, `hasSubstr([1,2,3,4], [1,2,4])` will return `0`.

**Arguments**

- `array1` – Array of any type with a set of elements.
- `array2` – Array of any type with a set of elements.

**Return values**

- `1`, if `array1` contains `array2`.
- `0`, otherwise.

**Peculiar properties**

- The function will return `1` if `array2` is empty.
- `Null` processed as a value. In other words `hasSubstr([1, 2, NULL, 3, 4], [2,3])` will return `0`. However, `hasSubstr([1, 2, NULL, 3, 4], [2,NULL,3])` will return `1`
- Order of values in both of arrays does matter.

**Examples**

`SELECT hasSubstr([], [])` returns 1.

`SELECT hasSubstr([1, Null], [Null])` returns 1.

`SELECT hasSubstr([1.0, 2, 3, 4], [1, 3])` returns 0.

`SELECT hasSubstr([a, b], [a])` returns 1.

`SELECT hasSubstr([a, b , c], [a, b])` returns 1.

`SELECT hasSubstr([a, b , c], [a, c])` returns 0.

`SELECT hasSubstr([[1, 2], [3, 4], [5, 6]], [[1, 2], [3, 4]])` returns 1.

## indexOf(arr, x)

Returns the index of the first ‘x’ element (starting from 1) if it is in the array, or 0 if it is not.

Example:

```
SELECT indexOf([1, 3, NULL, NULL], NULL)
┌─indexOf([1, 3, NULL, NULL], NULL)─┐
│                                 3 │
└───────────────────────────────────┘
```

Elements set to `NULL` are handled as normal values.

## arrayCount([func,] arr1, …)

Returns the number of elements in the arr array for which func returns something other than 0. If ‘func’ is not specified, it returns the number of non-zero elements in the array.

Note that the `arrayCount` is a [higher-order function](https://clickhouse.tech/docs/en/sql-reference/functions/#higher-order-functions). You can pass a lambda function to it as the first argument.

## countEqual(arr, x)

Returns the number of elements in the array equal to x. Equivalent to arrayCount (elem -> elem = x, arr).

`NULL` elements are handled as separate values.

Example:

```
SELECT countEqual([1, 2, NULL, NULL], NULL)
┌─countEqual([1, 2, NULL, NULL], NULL)─┐
│                                    2 │
└──────────────────────────────────────┘
```

## arrayEnumerate(arr)

Returns the array [1, 2, 3, …, length (arr) ]

This function is normally used with ARRAY JOIN. It allows counting something just once for each array after applying ARRAY JOIN. Example:

```
SELECT
    count() AS Reaches,
    countIf(num = 1) AS Hits
FROM test.hits
ARRAY JOIN
    GoalsReached,
    arrayEnumerate(GoalsReached) AS num
WHERE CounterID = 160656
LIMIT 10
┌─Reaches─┬──Hits─┐
│   95606 │ 31406 │
└─────────┴───────┘
```

In this example, Reaches is the number of conversions (the strings received after applying ARRAY JOIN), and Hits is the number of pageviews (strings before ARRAY JOIN). In this particular case, you can get the same result in an easier way:

```
SELECT
    sum(length(GoalsReached)) AS Reaches,
    count() AS Hits
FROM test.hits
WHERE (CounterID = 160656) AND notEmpty(GoalsReached)
┌─Reaches─┬──Hits─┐
│   95606 │ 31406 │
└─────────┴───────┘
```

This function can also be used in higher-order functions. For example, you can use it to get array indexes for elements that match a condition.

## arrayEnumerateUniq(arr, …)

Returns an array the same size as the source array, indicating for each element what its position is among elements with the same value.
For example: arrayEnumerateUniq([10, 20, 10, 30]) = [1, 1, 2, 1].

This function is useful when using ARRAY JOIN and aggregation of array elements.
Example:

```
SELECT
    Goals.ID AS GoalID,
    sum(Sign) AS Reaches,
    sumIf(Sign, num = 1) AS Visits
FROM test.visits
ARRAY JOIN
    Goals,
    arrayEnumerateUniq(Goals.ID) AS num
WHERE CounterID = 160656
GROUP BY GoalID
ORDER BY Reaches DESC
LIMIT 10
┌──GoalID─┬─Reaches─┬─Visits─┐
│   53225 │    3214 │   1097 │
│ 2825062 │    3188 │   1097 │
│   56600 │    2803 │    488 │
│ 1989037 │    2401 │    365 │
│ 2830064 │    2396 │    910 │
│ 1113562 │    2372 │    373 │
│ 3270895 │    2262 │    812 │
│ 1084657 │    2262 │    345 │
│   56599 │    2260 │    799 │
│ 3271094 │    2256 │    812 │
└─────────┴─────────┴────────┘
```

In this example, each goal ID has a calculation of the number of conversions (each element in the Goals nested data structure is a goal that was reached, which we refer to as a conversion) and the number of sessions. Without ARRAY JOIN, we would have counted the number of sessions as sum(Sign). But in this particular case, the rows were multiplied by the nested Goals structure, so in order to count each session one time after this, we apply a condition to the value of the arrayEnumerateUniq(Goals.ID) function.

The arrayEnumerateUniq function can take multiple arrays of the same size as arguments. In this case, uniqueness is considered for tuples of elements in the same positions in all the arrays.

```
SELECT arrayEnumerateUniq([1, 1, 1, 2, 2, 2], [1, 1, 2, 1, 1, 2]) AS res
┌─res───────────┐
│ [1,2,1,1,2,1] │
└───────────────┘
```

This is necessary when using ARRAY JOIN with a nested data structure and further aggregation across multiple elements in this structure.

## arrayPopBack

Removes the last item from the array.

```
arrayPopBack(array)
```

**Arguments**

- `array` – Array.

**Example**

```
SELECT arrayPopBack([1, 2, 3]) AS res;
┌─res───┐
│ [1,2] │
└───────┘
```

## arrayPopFront

Removes the first item from the array.

```
arrayPopFront(array)
```

**Arguments**

- `array` – Array.

**Example**

```
SELECT arrayPopFront([1, 2, 3]) AS res;
┌─res───┐
│ [2,3] │
└───────┘
```

## arrayPushBack

Adds one item to the end of the array.

```
arrayPushBack(array, single_value)
```

**Arguments**

- `array` – Array.
- `single_value` – A single value. Only numbers can be added to an array with numbers, and only strings can be added to an array of strings. When adding numbers, ClickHouse automatically sets the `single_value` type for the data type of the array. For more information about the types of data in ClickHouse, see “[Data types”. Can be `NULL`. The function adds a `NULL` element to an array, and the type of array elements converts to `Nullable`.

**Example**

```
SELECT arrayPushBack([a], b) AS res;
┌─res───────┐
│ [a,b] │
└───────────┘
```

## arrayPushFront

Adds one element to the beginning of the array.

```
arrayPushFront(array, single_value)
```

**Arguments**

- `array` – Array.
- `single_value` – A single value. Only numbers can be added to an array with numbers, and only strings can be added to an array of strings. When adding numbers, ClickHouse automatically sets the `single_value` type for the data type of the array. For more information about the types of data in ClickHouse, see “Data types”. Can be `NULL`. The function adds a `NULL` element to an array, and the type of array elements converts to `Nullable`.

**Example**

```
SELECT arrayPushFront([b], a) AS res;
┌─res───────┐
│ [a,b] │
└───────────┘
```

## arrayResize

Changes the length of the array.

```
arrayResize(array, size[, extender])
```

**Arguments:**

- `array` — Array.

- ```
  size
  ```



  — Required length of the array.

  - If `size` is less than the original size of the array, the array is truncated from the right.

- If `size` is larger than the initial size of the array, the array is extended to the right with `extender` values or default values for the data type of the array items.

- `extender` — Value for extending an array. Can be `NULL`.

**Returned value:**

An array of length `size`.

**Examples of calls**

```
SELECT arrayResize([1], 3);
┌─arrayResize([1], 3)─┐
│ [1,0,0]             │
└─────────────────────┘
SELECT arrayResize([1], 3, NULL);
┌─arrayResize([1], 3, NULL)─┐
│ [1,NULL,NULL]             │
└───────────────────────────┘
```

## arraySlice

Returns a slice of the array.

```
arraySlice(array, offset[, length])
```

**Arguments**

- `array` – Array of data.
- `offset` – Indent from the edge of the array. A positive value indicates an offset on the left, and a negative value is an indent on the right. Numbering of the array items begins with 1.
- `length` – The length of the required slice. If you specify a negative value, the function returns an open slice `[offset, array_length - length)`. If you omit the value, the function returns the slice `[offset, the_end_of_array]`.

**Example**

```
SELECT arraySlice([1, 2, NULL, 4, 5], 2, 3) AS res;
┌─res────────┐
│ [2,NULL,4] │
└────────────┘
```

Array elements set to `NULL` are handled as normal values.

## arraySort([func,] arr, …)

Sorts the elements of the `arr` array in ascending order. If the `func` function is specified, sorting order is determined by the result of the `func` function applied to the elements of the array. If `func` accepts multiple arguments, the `arraySort` function is passed several arrays that the arguments of `func` will correspond to. Detailed examples are shown at the end of `arraySort` description.

Example of integer values sorting:

```
SELECT arraySort([1, 3, 3, 0]);
┌─arraySort([1, 3, 3, 0])─┐
│ [0,1,3,3]               │
└─────────────────────────┘
```

Example of string values sorting:

```
SELECT arraySort([hello, world, !]);
┌─arraySort([hello, world, !])─┐
│ [!,hello,world]              │
└────────────────────────────────────┘
```

Consider the following sorting order for the `NULL`, `NaN` and `Inf` values:

```
SELECT arraySort([1, nan, 2, NULL, 3, nan, -4, NULL, inf, -inf]);
┌─arraySort([1, nan, 2, NULL, 3, nan, -4, NULL, inf, -inf])─┐
│ [-inf,-4,1,2,3,inf,nan,nan,NULL,NULL]                     │
└───────────────────────────────────────────────────────────┘
```

- `-Inf` values are first in the array.
- `NULL` values are last in the array.
- `NaN` values are right before `NULL`.
- `Inf` values are right before `NaN`.

Note that `arraySort` is a [higher-order function You can pass a lambda function to it as the first argument. In this case, sorting order is determined by the result of the lambda function applied to the elements of the array.

Let’s consider the following example:

```
SELECT arraySort((x) -> -x, [1, 2, 3]) as res;
┌─res─────┐
│ [3,2,1] │
└─────────┘
```

For each element of the source array, the lambda function returns the sorting key, that is, [1 –> -1, 2 –> -2, 3 –> -3]. Since the `arraySort` function sorts the keys in ascending order, the result is [3, 2, 1]. Thus, the `(x) –> -x` lambda function sets the [descending order in a sorting.

The lambda function can accept multiple arguments. In this case, you need to pass the `arraySort` function several arrays of identical length that the arguments of lambda function will correspond to. The resulting array will consist of elements from the first input array; elements from the next input array(s) specify the sorting keys. For example:

```
SELECT arraySort((x, y) -> y, [hello, world], [2, 1]) as res;
┌─res────────────────┐
│ [world, hello] │
└────────────────────┘
```

Here, the elements that are passed in the second array ([2, 1]) define a sorting key for the corresponding element from the source array ([‘hello’, ‘world’]), that is, [‘hello’ –> 2, ‘world’ –> 1]. Since the lambda function does not use `x`, actual values of the source array do not affect the order in the result. So, ‘hello’ will be the second element in the result, and ‘world’ will be the first.

Other examples are shown below.

```
SELECT arraySort((x, y) -> y, [0, 1, 2], [c, b, a]) as res;
┌─res─────┐
│ [2,1,0] │
└─────────┘
SELECT arraySort((x, y) -> -y, [0, 1, 2], [1, 2, 3]) as res;
┌─res─────┐
│ [2,1,0] │
└─────────┘
```

Note

To improve sorting efficiency, the Schwartzian transform is used.

## arrayReverseSort([func,] arr, …)

Sorts the elements of the `arr` array in descending order. If the `func` function is specified, `arr` is sorted according to the result of the `func` function applied to the elements of the array, and then the sorted array is reversed. If `func` accepts multiple arguments, the `arrayReverseSort` function is passed several arrays that the arguments of `func` will correspond to. Detailed examples are shown at the end of `arrayReverseSort` description.

Example of integer values sorting:

```
SELECT arrayReverseSort([1, 3, 3, 0]);
┌─arrayReverseSort([1, 3, 3, 0])─┐
│ [3,3,1,0]                      │
└────────────────────────────────┘
```

Example of string values sorting:

```
SELECT arrayReverseSort([hello, world, !]);
┌─arrayReverseSort([hello, world, !])─┐
│ [world,hello,!]                     │
└───────────────────────────────────────────┘
```

Consider the following sorting order for the `NULL`, `NaN` and `Inf` values:

```
SELECT arrayReverseSort([1, nan, 2, NULL, 3, nan, -4, NULL, inf, -inf]) as res;
┌─res───────────────────────────────────┐
│ [inf,3,2,1,-4,-inf,nan,nan,NULL,NULL] │
└───────────────────────────────────────┘
```

- `Inf` values are first in the array.
- `NULL` values are last in the array.
- `NaN` values are right before `NULL`.
- `-Inf` values are right before `NaN`.

Note that the `arrayReverseSort` is a higher-order function. You can pass a lambda function to it as the first argument. Example is shown below.

```
SELECT arrayReverseSort((x) -> -x, [1, 2, 3]) as res;
┌─res─────┐
│ [1,2,3] │
└─────────┘
```

The array is sorted in the following way:

1. At first, the source array ([1, 2, 3]) is sorted according to the result of the lambda function applied to the elements of the array. The result is an array [3, 2, 1].
2. Array that is obtained on the previous step, is reversed. So, the final result is [1, 2, 3].

The lambda function can accept multiple arguments. In this case, you need to pass the `arrayReverseSort` function several arrays of identical length that the arguments of lambda function will correspond to. The resulting array will consist of elements from the first input array; elements from the next input array(s) specify the sorting keys. For example:

```
SELECT arrayReverseSort((x, y) -> y, [hello, world], [2, 1]) as res;
┌─res───────────────┐
│ [hello,world] │
└───────────────────┘
```

In this example, the array is sorted in the following way:

1. At first, the source array ([‘hello’, ‘world’]) is sorted according to the result of the lambda function applied to the elements of the arrays. The elements that are passed in the second array ([2, 1]), define the sorting keys for corresponding elements from the source array. The result is an array [‘world’, ‘hello’].
2. Array that was sorted on the previous step, is reversed. So, the final result is [‘hello’, ‘world’].

Other examples are shown below.

```
SELECT arrayReverseSort((x, y) -> y, [4, 3, 5], [a, b, c]) AS res;
┌─res─────┐
│ [5,3,4] │
└─────────┘
SELECT arrayReverseSort((x, y) -> -y, [4, 3, 5], [1, 2, 3]) AS res;
┌─res─────┐
│ [4,3,5] │
└─────────┘
```

## arrayUniq(arr, …)

If one argument is passed, it counts the number of different elements in the array.
If multiple arguments are passed, it counts the number of different tuples of elements at corresponding positions in multiple arrays.

If you want to get a list of unique items in an array, you can use arrayReduce(‘groupUniqArray’, arr).

## arrayJoin(arr)

A special function. See the section “ArrayJoin function”.

## arrayDifference

Calculates the difference between adjacent array elements. Returns an array where the first element will be 0, the second is the difference between `a[1] - a[0]`, etc. The type of elements in the resulting array is determined by the type inference rules for subtraction (e.g. `UInt8` - `UInt8` = `Int16`).

**Syntax**

```
arrayDifference(array)
```

**Arguments**

- `array` – Array.

**Returned values**

Returns an array of differences between adjacent elements.

**Example**

Query:

```
SELECT arrayDifference([1, 2, 3, 4]);
```

Result:

```
┌─arrayDifference([1, 2, 3, 4])─┐
│ [0,1,1,1]                     │
└───────────────────────────────┘
```

Example of the overflow due to result type Int64:

Query:

```
SELECT arrayDifference([0, 1000]);
```

Result:

```
┌─arrayDifference([0, 1000])─┐
│ [0,-8446744073709551616]                   │
└────────────────────────────────────────────┘
```

## arrayDistinct

Takes an array, returns an array containing the distinct elements only.

**Syntax**

```
arrayDistinct(array)
```

**Arguments**

- `array` – Ar ray.

**Returned values**

Returns an array containing the distinct elements.

**Example**

Query:

```
SELECT arrayDistinct([1, 2, 2, 3, 1]);
```

Result:

```
┌─arrayDistinct([1, 2, 2, 3, 1])─┐
│ [1,2,3]                        │
└────────────────────────────────┘
```

## arrayEnumerateDense(arr)

Returns an array of the same size as the source array, indicating where each element first appears in the source array.

Example:

```
SELECT arrayEnumerateDense([10, 20, 10, 30])
┌─arrayEnumerateDense([10, 20, 10, 30])─┐
│ [1,2,1,3]                             │
└───────────────────────────────────────┘
```

## arrayIntersect(arr)

Takes multiple arrays, returns an array with elements that are present in all source arrays. Elements order in the resulting array is the same as in the first array.

Example:

```
SELECT
    arrayIntersect([1, 2], [1, 3], [2, 3]) AS no_intersect,
    arrayIntersect([1, 2], [1, 3], [1, 4]) AS intersect
┌─no_intersect─┬─intersect─┐
│ []           │ [1]       │
└──────────────┴───────────┘
```

## arrayReduce

Applies an aggregate function to array elements and returns its result. The name of the aggregation function is passed as a string in single quotes `max`, `sum`. When using parametric aggregate functions, the parameter is indicated after the function name in parentheses `uniqUpTo(6)`.

**Syntax**

```
arrayReduce(agg_func, arr1, arr2, ..., arrN)
```

**Arguments**

- `agg_func` — The name of an aggregate function which should be a constant string.
- `arr` — Any number of Array type columns as the parameters of the aggregation function.

**Returned value**

**Example**

Query:

```
SELECT arrayReduce(max, [1, 2, 3]);
```

Result:

```
┌─arrayReduce(max, [1, 2, 3])─┐
│                             3 │
└───────────────────────────────┘
```

If an aggregate function takes multiple arguments, then this function must be applied to multiple arrays of the same size.

Query:

```
SELECT arrayReduce(maxIf, [3, 5], [1, 0]);
```

Result:

```
┌─arrayReduce(maxIf, [3, 5], [1, 0])─┐
│                                    3 │
└──────────────────────────────────────┘
```

Example with a parametric aggregate function:

Query:

```
SELECT arrayReduce(uniqUpTo(3), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
```

Result:

```
┌─arrayReduce(uniqUpTo(3), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])─┐
│                                                           4 │
└─────────────────────────────────────────────────────────────┘
```

## arrayReduceInRanges

Applies an aggregate function to array elements in given ranges and returns an array containing the result corresponding to each range. The function will return the same result as multiple `arrayReduce(agg_func, arraySlice(arr1, index, length), ...)`.

**Syntax**

```
arrayReduceInRanges(agg_func, ranges, arr1, arr2, ..., arrN)
```

**Arguments**

- `agg_func` — The name of an aggregate function which should be a constant string.
- `ranges` — The ranges to aggretate which should be an [array of tuples which containing the index and the length of each range.
- `arr` — Any number of Array type columns as the parameters of the aggregation function.

**Returned value**

- Array containing results of the aggregate function over specified ranges.

Type: Array

**Example**

Query:

```
SELECT arrayReduceInRanges(
    sum,
    [(1, 5), (2, 3), (3, 4), (4, 4)],
    [100, 20, 3, 4000, 500, 60, 7]
) AS res
```

Result:

```
┌─res─────────────────────────┐
│ [1234500,234000,34560,4567] │
└─────────────────────────────┘
```

## arrayReverse(arr)

Returns an array of the same size as the original array containing the elements in reverse order.

Example:

```
SELECT arrayReverse([1, 2, 3])
┌─arrayReverse([1, 2, 3])─┐
│ [3,2,1]                 │
└─────────────────────────┘
```

## reverse(arr)

Synonym for [“arrayReverse”

## arrayFlatten

Converts an array of arrays to a flat array.

Function:

- Applies to any depth of nested arrays.
- Does not change arrays that are already flat.

The flattened array contains all the elements from all source arrays.

**Syntax**

```
flatten(array_of_arrays)
```

Alias: `flatten`.

**Arguments**

- `array_of_arrays` — Array of arrays. For example, `[[1,2,3], [4,5]]`.

**Examples**

```
SELECT flatten([[[1]], [[2], [3]]]);
┌─flatten(array(array([1]), array([2], [3])))─┐
│ [1,2,3]                                     │
└─────────────────────────────────────────────┘
```

## arrayCompact

Removes consecutive duplicate elements from an array. The order of result values is determined by the order in the source array.

**Syntax**

```
arrayCompact(arr)
```

**Arguments**

`arr` — The  array to inspect.

**Returned value**

The array without duplicate.

Type: `Array`.

**Example**

Query:

```
SELECT arrayCompact([1, 1, nan, nan, 2, 3, 3, 3]);
```

Result:

```
┌─arrayCompact([1, 1, nan, nan, 2, 3, 3, 3])─┐
│ [1,nan,nan,2,3]                            │
└────────────────────────────────────────────┘
```

## arrayZip

Combines multiple arrays into a single array. The resulting array contains the corresponding elements of the source arrays grouped into tuples in the listed order of arguments.

**Syntax**

```
arrayZip(arr1, arr2, ..., arrN)
```

**Arguments**

- `arrN` — Array

The function can take any number of arrays of different types. All the input arrays must be of equal size.

**Returned value**

- Array with elements from the source arrays grouped into tuples. Data types in the tuple are the same as types of the input arrays and in the same order as arrays are passed.

Type: Array

**Example**

Query:

```
SELECT arrayZip([a, b, c], [5, 2, 1]);
```

Result:

```
┌─arrayZip([a, b, c], [5, 2, 1])─┐
│ [(a,5),(b,2),(c,1)]            │
└──────────────────────────────────────┘
```

## arrayAUC[ ](https://clickhouse.tech/docs/en/sql-reference/functions/array-functions/#arrayauc)

Calculate AUC (Area Under the Curve, which is a concept in machine learning, see more details:

**Syntax**

```
arrayAUC(arr_scores, arr_labels)
```

**Arguments**

- `arr_scores` — scores prediction model gives.
- `arr_labels` — labels of samples, usually 1 for positive sample and 0 for negtive sample.

**Returned value**

Returns AUC value with type Float64.

**Example**

Query:

```
select arrayAUC([0.1, 0.4, 0.35, 0.8], [0, 0, 1, 1]);
```

Result:

```
┌─arrayAUC([0.1, 0.4, 0.35, 0.8], [0, 0, 1, 1])─┐
│                                          0.75 │
└───────────────────────────────────────────────┘
```

## arrayMap(func, arr1, …)

Returns an array obtained from the original application of the `func` function to each element in the `arr` array.

Examples:

```
SELECT arrayMap(x -> (x + 2), [1, 2, 3]) as res;
┌─res─────┐
│ [3,4,5] │
└─────────┘
```

The following example shows how to create a tuple of elements from different arrays:

```
SELECT arrayMap((x, y) -> (x, y), [1, 2, 3], [4, 5, 6]) AS res
┌─res─────────────────┐
│ [(1,4),(2,5),(3,6)] │
└─────────────────────┘
```

Note that the `arrayMap` is a higher-order function. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayFilter(func, arr1, …)

Returns an array containing only the elements in `arr1` for which `func` returns something other than 0.

Examples:

```
SELECT arrayFilter(x -> x LIKE %World%, [Hello, abc World]) AS res
┌─res───────────┐
│ [abc World] │
└───────────────┘
SELECT
    arrayFilter(
        (i, x) -> x LIKE %World%,
        arrayEnumerate(arr),
        [Hello, abc World] AS arr)
    AS res
┌─res─┐
│ [2] │
└─────┘
```

Note that the `arrayFilter` is a higher-order function You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayFill(func, arr1, …)

Scan through `arr1` from the first element to the last element and replace `arr1[i]` by `arr1[i - 1]` if `func` returns 0. The first element of `arr1` will not be replaced.

Examples:

```
SELECT arrayFill(x -> not isNull(x), [1, null, 3, 11, 12, null, null, 5, 6, 14, null, null]) AS res
┌─res──────────────────────────────┐
│ [1,1,3,11,12,12,12,5,6,14,14,14] │
└──────────────────────────────────┘
```

Note that the `arrayFill` is a higher-order function. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayReverseFill(func, arr1, …)

Scan through `arr1` from the last element to the first element and replace `arr1[i]` by `arr1[i + 1]` if `func` returns 0. The last element of `arr1` will not be replaced.

Examples:

```
SELECT arrayReverseFill(x -> not isNull(x), [1, null, 3, 11, 12, null, null, 5, 6, 14, null, null]) AS res
┌─res────────────────────────────────┐
│ [1,3,3,11,12,5,5,5,6,14,NULL,NULL] │
└────────────────────────────────────┘
```

Note that the `arrayReverseFill` is a higher-order function. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arraySplit(func, arr1, …)

Split `arr1` into multiple arrays. When `func` returns something other than 0, the array will be split on the left hand side of the element. The array will not be split before the first element.

Examples:

```
SELECT arraySplit((x, y) -> y, [1, 2, 3, 4, 5], [1, 0, 0, 1, 0]) AS res
┌─res─────────────┐
│ [[1,2,3],[4,5]] │
└─────────────────┘
```

Note that the `arraySplit` is a higher-order function. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayReverseSplit(func, arr1, …)

Split `arr1` into multiple arrays. When `func` returns something other than 0, the array will be split on the right hand side of the element. The array will not be split after the last element.

Examples:

```
SELECT arrayReverseSplit((x, y) -> y, [1, 2, 3, 4, 5], [1, 0, 0, 1, 0]) AS res
┌─res───────────────┐
│ [[1],[2,3,4],[5]] │
└───────────────────┘
```

Note that the `arrayReverseSplit` is a higher-order function. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayExists([func,] arr1, …)

Returns 1 if there is at least one element in `arr` for which `func` returns something other than 0. Otherwise, it returns 0.

Note that the `arrayExists` is a higher-order function. You can pass a lambda function to it as the first argument.

## arrayAll([func,] arr1, …)

Returns 1 if `func` returns something other than 0 for all the elements in `arr`. Otherwise, it returns 0.

Note that the `arrayAll` is a higher-order function. You can pass a lambda function to it as the first argument.

## arrayFirst(func, arr1, …)

Returns the first element in the `arr1` array for which `func` returns something other than 0.

Note that the `arrayFirst` is a higher-order function. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayFirstIndex(func, arr1, …)

Returns the index of the first element in the `arr1` array for which `func` returns something other than 0.

Note that the `arrayFirstIndex` is a higher-order function. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayMin

Returns the minimum of elements in the source array.

If the `func` function is specified, returns the mininum of elements converted by this function.

Note that the `arrayMin` is a higher-order function. You can pass a lambda function to it as the first argument.

**Syntax**

```
arrayMin([func,] arr)
```

**Arguments**

- `func` — Function. Expression.
- `arr` — Array. Array.

**Returned value**

- The minimum of function values (or the array minimum).

Type: if `func` is specified, matches `func` return value type, else matches the array elements type.

**Examples**

Query:

```
SELECT arrayMin([1, 2, 4]) AS res;
```

Result:

```
┌─res─┐
│   1 │
└─────┘
```

Query:

```
SELECT arrayMin(x -> (-x), [1, 2, 4]) AS res;
```

Result:

```
┌─res─┐
│  -4 │
└─────┘
```

## arrayMax

Returns the maximum of elements in the source array.

If the `func` function is specified, returns the maximum of elements converted by this function.

Note that the `arrayMax` is a higher-order function. You can pass a lambda function to it as the first argument.

**Syntax**

```
arrayMax([func,] arr)
```

**Arguments**

- `func` — Function. Expression.
- `arr` — Array. Array.

**Returned value**

- The maximum of function values (or the array maximum).

Type: if `func` is specified, matches `func` return value type, else matches the array elements type.

**Examples**

Query:

```
SELECT arrayMax([1, 2, 4]) AS res;
```

Result:

```
┌─res─┐
│   4 │
└─────┘
```

Query:

```
SELECT arrayMax(x -> (-x), [1, 2, 4]) AS res;
```

Result:

```
┌─res─┐
│  -1 │
└─────┘
```

## arraySum

Returns the sum of elements in the source array.

If the `func` function is specified, returns the sum of elements converted by this function.

Note that the `arraySum` is a higher-order function. You can pass a lambda function to it as the first argument.

**Syntax**

```
arraySum([func,] arr)
```

**Arguments**

- `func` — Function. Expression
- `arr` — Array. Array

**Returned value**

- The sum of the function values (or the array sum).

Type: for decimal numbers in source array (or for converted values, if `func` is specified) — Decimal128, for floating point numbers — Float64, for numeric unsigned — UInt64, and for numeric signed — Int64.

**Examples**

Query:

```
SELECT arraySum([2, 3]) AS res;
```

Result:

```
┌─res─┐
│   5 │
└─────┘
```

Query:

```
SELECT arraySum(x -> x*x, [2, 3]) AS res;
```

Result:

```
┌─res─┐
│  13 │
└─────┘
```

## arrayAvg

Returns the average of elements in the source array.

If the `func` function is specified, returns the average of elements converted by this function.

Note that the `arrayAvg` is a higher-order function. You can pass a lambda function to it as the first argument.

**Syntax**

```
arrayAvg([func,] arr)
```

**Arguments**

- `func` — Function. Expression
- `arr` — Array. Array

**Returned value**

- The average of function values (or the array average).

Type: Float64

**Examples**

Query:

```
SELECT arrayAvg([1, 2, 4]) AS res;
```

Result:

```
┌────────────────res─┐
│ 2.3333333333333335 │
└────────────────────┘
```

Query:

```
SELECT arrayAvg(x -> (x * x), [2, 4]) AS res;
```

Result:

```
┌─res─┐
│  10 │
└─────┘
```

## arrayCumSum([func,] arr1, …)

Returns an array of partial sums of elements in the source array (a running sum). If the `func` function is specified, then the values of the array elements are converted by this function before summing.

Example:

```
SELECT arrayCumSum([1, 1, 1, 1]) AS res
┌─res──────────┐
│ [1, 2, 3, 4] │
└──────────────┘
```

Note that the `arrayCumSum` is a higher-order function. You can pass a lambda function to it as the first argument.

## arrayCumSumNonNegative(arr)

Same as `arrayCumSum`, returns an array of partial sums of elements in the source array (a running sum). Different `arrayCumSum`, when then returned value contains a value less than zero, the value is replace with zero and the subsequent calculation is performed with zero parameters. For example:

```
SELECT arrayCumSumNonNegative([1, 1, -4, 1]) AS res
┌─res───────┐
│ [1,2,0,1] │
└───────────┘
```

Note that the `arraySumNonNegative` is a higher-order function. You can pass a lambda function to it as the first argument.

## arrayProduct

Multiplies elements of an array

**Syntax**

```
arrayProduct(arr)
```

**Arguments**

- `arr` — Array of numeric values.

**Returned value**

- A product of arrays elements.

Type: Float64.

**Examples**

Query:

```
SELECT arrayProduct([1,2,3,4,5,6]) as res;
```

Result:

```
┌─res───┐
│ 720   │
└───────┘
```

Query:

```
SELECT arrayProduct([toDecimal64(1,8), toDecimal64(2,8), toDecimal64(3,8)]) as res, toTypeName(res);
```

Return value type is always [Float64]. Result:

```
┌─res─┬─toTypeName(arrayProduct(array(toDecimal64(1, 8), toDecimal64(2, 8), toDecimal64(3, 8))))─┐
│ 6   │ Float64                                                                                  │
└─────┴──────────────────────────────────────────────────────────────────────────────────────────┘
```

' where id=32;
update biz_data_query_model_help_content set content_en = '# Bitmap Functions

Bitmap functions work for two bitmaps Object value calculation, it is to return new bitmap or cardinality while using formula calculation, such as and, or, xor, and not, etc.

There are 2 kinds of construction methods for Bitmap Object. One is to be constructed by aggregation function groupBitmap with -State, the other is to be constructed by Array Object. It is also to convert Bitmap Object to Array Object.

RoaringBitmap is wrapped into a data structure while actual storage of Bitmap objects. When the cardinality is less than or equal to 32, it uses Set objet. When the cardinality is greater than 32, it uses RoaringBitmap object. That is why storage of low cardinality set is faster.

For more information on RoaringBitmap, see: CRoaring.

## bitmapBuild

Build a bitmap from unsigned integer array.

```
bitmapBuild(array)
```

**Arguments**

- `array` – Unsigned integer array.

**Example**

```
SELECT bitmapBuild([1, 2, 3, 4, 5]) AS res, toTypeName(res);
┌─res─┬─toTypeName(bitmapBuild([1, 2, 3, 4, 5]))─────┐
│     │ AggregateFunction(groupBitmap, UInt8)        │
└─────┴──────────────────────────────────────────────┘
```

## bitmapToArray

Convert bitmap to integer array.

```
bitmapToArray(bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapToArray(bitmapBuild([1, 2, 3, 4, 5])) AS res;
┌─res─────────┐
│ [1,2,3,4,5] │
└─────────────┘
```

## bitmapSubsetInRange

Return subset in specified range (not include the range_end).

```
bitmapSubsetInRange(bitmap, range_start, range_end)
```

**Arguments**

- `bitmap` – Bitmap object.
- `range_start` – Range start point. Type: UInt32
- `range_end` – Range end point (excluded). Type:UInt32

**Example**

```
SELECT bitmapToArray(bitmapSubsetInRange(bitmapBuild([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,100,200,500]), toUInt32(30), toUInt32(200))) AS res;
┌─res───────────────┐
│ [30,31,32,33,100] │
└───────────────────┘
```

## bitmapSubsetLimit

Creates a subset of bitmap with n elements taken between `range_start` and `cardinality_limit`.

**Syntax**

```
bitmapSubsetLimit(bitmap, range_start, cardinality_limit)
```

**Arguments**

- `bitmap` – [Bitmap object
- `range_start` – The subset starting point. Type: UInt32
- `cardinality_limit` – The subset cardinality upper limit. Type: UInt32

**Returned value**

The subset.

Type: `Bitmap object`.

**Example**

Query:

```
SELECT bitmapToArray(bitmapSubsetLimit(bitmapBuild([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,100,200,500]), toUInt32(30), toUInt32(200))) AS res;
```

Result:

```
┌─res───────────────────────┐
│ [30,31,32,33,100,200,500] │
└───────────────────────────┘
```

## bitmapContains

Checks whether the bitmap contains an element.

```
bitmapContains(haystack, needle)
```

**Arguments**

- `haystack` – Bitmap object, where the function searches.
- `needle` – Value that the function searches. Type: UInt32.

**Returned values**

- 0 — If `haystack` does not contain `needle`.
- 1 — If `haystack` contains `needle`.

Type: `UInt8`.

**Example**

```
SELECT bitmapContains(bitmapBuild([1,5,7,9]), toUInt32(9)) AS res;
┌─res─┐
│  1  │
└─────┘
```

## bitmapHasAny

Checks whether two bitmaps have intersection by some elements.

```
bitmapHasAny(bitmap1, bitmap2)
```

If you are sure that `bitmap2` contains strictly one element, consider using the bitmapContains  function. It works more efficiently.

**Arguments**

- `bitmap*` – Bitmap object.

**Return values**

- `1`, if `bitmap1` and `bitmap2` have one similar element at least.
- `0`, otherwise.

**Example**

```
SELECT bitmapHasAny(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res;
┌─res─┐
│  1  │
└─────┘
```

## bitmapHasAll

Analogous to `hasAll(array, array)` returns 1 if the first bitmap contains all the elements of the second one, 0 otherwise.
If the second argument is an empty bitmap then returns 1.

```
bitmapHasAll(bitmap,bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapHasAll(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res;
┌─res─┐
│  0  │
└─────┘
```

## bitmapCardinality

Retrun bitmap cardinality of type UInt64.

```
bitmapCardinality(bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapCardinality(bitmapBuild([1, 2, 3, 4, 5])) AS res;
┌─res─┐
│   5 │
└─────┘
```

## bitmapMin

Retrun the smallest value of type UInt64 in the set, UINT32_MAX if the set is empty.

```
bitmapMin(bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapMin(bitmapBuild([1, 2, 3, 4, 5])) AS res;
 ┌─res─┐
 │   1 │
 └─────┘
```

## bitmapMax

Retrun the greatest value of type UInt64 in the set, 0 if the set is empty.

```
bitmapMax(bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapMax(bitmapBuild([1, 2, 3, 4, 5])) AS res;
 ┌─res─┐
 │   5 │
 └─────┘
```

## bitmapTransform

Transform an array of values in a bitmap to another array of values, the result is a new bitmap.

```
bitmapTransform(bitmap, from_array, to_array)
```

**Arguments**

- `bitmap` – Bitmap object.
- `from_array` – UInt32 array. For idx in range [0, from_array.size()), if bitmap contains from_array[idx], then replace it with to_array[idx]. Note that the result depends on array ordering if there are common elements between from_array and to_array.
- `to_array` – UInt32 array, its size shall be the same to from_array.

**Example**

```
SELECT bitmapToArray(bitmapTransform(bitmapBuild([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]), cast([5,999,2] as Array(UInt32)), cast([2,888,20] as Array(UInt32)))) AS res;
 ┌─res───────────────────┐
 │ [1,3,4,6,7,8,9,10,20] │
 └───────────────────────┘
```

## bitmapAnd

Two bitmap and calculation, the result is a new bitmap.

```
bitmapAnd(bitmap,bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapToArray(bitmapAnd(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]))) AS res;
┌─res─┐
│ [3] │
└─────┘
```

## bitmapOr

Two bitmap or calculation, the result is a new bitmap.

```
bitmapOr(bitmap,bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapToArray(bitmapOr(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]))) AS res;
┌─res─────────┐
│ [1,2,3,4,5] │
└─────────────┘
```

## bitmapXor

Two bitmap xor calculation, the result is a new bitmap.

```
bitmapXor(bitmap,bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapToArray(bitmapXor(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]))) AS res;
┌─res───────┐
│ [1,2,4,5] │
└───────────┘
```

## bitmapAndnot

Two bitmap andnot calculation, the result is a new bitmap.

```
bitmapAndnot(bitmap,bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapToArray(bitmapAndnot(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]))) AS res;
┌─res───┐
│ [1,2] │
└───────┘
```

## bitmapAndCardinality

Two bitmap and calculation, return cardinality of type UInt64.

```
bitmapAndCardinality(bitmap,bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapAndCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res;
┌─res─┐
│   1 │
└─────┘
```

## bitmapOrCardinality

Two bitmap or calculation, return cardinality of type UInt64.

```
bitmapOrCardinality(bitmap,bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapOrCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res;
┌─res─┐
│   5 │
└─────┘
```

## bitmapXorCardinality

Two bitmap xor calculation, return cardinality of type UInt64.

```
bitmapXorCardinality(bitmap,bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapXorCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res;
┌─res─┐
│   4 │
└─────┘
```

## bitmapAndnotCardinality

Two bitmap andnot calculation, return cardinality of type UInt64.

```
bitmapAndnotCardinality(bitmap,bitmap)
```

**Arguments**

- `bitmap` – Bitmap object.

**Example**

```
SELECT bitmapAndnotCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res;
┌─res─┐
│   2 │
└─────┘
```

' where id=33;
update biz_data_query_model_help_content set content_en = '# Bit Functions

Bit functions work for any pair of types from UInt8, UInt16, UInt32, UInt64, Int8, Int16, Int32, Int64, Float32, or Float64.

The result type is an integer with bits equal to the maximum bits of its arguments. If at least one of the arguments is signed, the result is a signed number. If an argument is a floating-point number, it is cast to Int64.

## bitAnd(a, b)

## bitOr(a, b)

## bitXor(a, b)

## bitNot(a)

## bitShiftLeft(a, b)

## bitShiftRight(a, b)

## bitRotateLeft(a, b)

## bitRotateRight(a, b)

## bitTest

Takes any integer and converts it into binary form, returns the value of a bit at specified position. The countdown starts from 0 from the right to the left.

**Syntax**

```
SELECT bitTest(number, index)
```

**Arguments**

- `number` – Integer number.
- `index` – Position of bit.

**Returned values**

Returns a value of bit at specified position.

Type: `UInt8`.

**Example**

For example, the number 43 in base-2 (binary) numeral system is 101011.

Query:

```
SELECT bitTest(43, 1);
```

Result:

```
┌─bitTest(43, 1)─┐
│              1 │
└────────────────┘
```

Another example:

Query:

```
SELECT bitTest(43, 2);
```

Result:

```
┌─bitTest(43, 2)─┐
│              0 │
└────────────────┘
```

## bitTestAll

Returns result of logical conjuction (AND operator) of all bits at given positions. The countdown starts from 0 from the right to the left.

The conjuction for bitwise operations:

0 AND 0 = 0

0 AND 1 = 0

1 AND 0 = 0

1 AND 1 = 1

**Syntax**

```
SELECT bitTestAll(number, index1, index2, index3, index4, ...)
```

**Arguments**

- `number` – Integer number.
- `index1`, `index2`, `index3`, `index4` – Positions of bit. For example, for set of positions (`index1`, `index2`, `index3`, `index4`) is true if and only if all of its positions are true (`index1` ⋀ `index2`, ⋀ `index3` ⋀ `index4`).

**Returned values**

Returns result of logical conjuction.

Type: `UInt8`.

**Example**

For example, the number 43 in base-2 (binary) numeral system is 101011.

Query:

```
SELECT bitTestAll(43, 0, 1, 3, 5);
```

Result:

```
┌─bitTestAll(43, 0, 1, 3, 5)─┐
│                          1 │
└────────────────────────────┘
```

Another example:

Query:

```
SELECT bitTestAll(43, 0, 1, 3, 5, 2);
```

Result:

```
┌─bitTestAll(43, 0, 1, 3, 5, 2)─┐
│                             0 │
└───────────────────────────────┘
```

## bitTestAny

Returns result of logical disjunction (OR operator) of all bits at given positions. The countdown starts from 0 from the right to the left.

The disjunction for bitwise operations:

0 OR 0 = 0

0 OR 1 = 1

1 OR 0 = 1

1 OR 1 = 1

**Syntax**

```
SELECT bitTestAny(number, index1, index2, index3, index4, ...)
```

**Arguments**

- `number` – Integer number.
- `index1`, `index2`, `index3`, `index4` – Positions of bit.

**Returned values**

Returns result of logical disjuction.

Type: `UInt8`.

**Example**

For example, the number 43 in base-2 (binary) numeral system is 101011.

Query:

```
SELECT bitTestAny(43, 0, 2);
```

Result:

```
┌─bitTestAny(43, 0, 2)─┐
│                    1 │
└──────────────────────┘
```

Another example:

Query:

```
SELECT bitTestAny(43, 4, 2);
```

Result:

```
┌─bitTestAny(43, 4, 2)─┐
│                    0 │
└──────────────────────┘
```

## bitCount

Calculates the number of bits set to one in the binary representation of a number.

**Syntax**

```
bitCount(x)
```

**Arguments**

- `x` — Integer or floating-point number. The function uses the value representation in memory. It allows supporting floating-point numbers.

**Returned value**

- Number of bits set to one in the input number.

The function does not convert input value to a larger type (sign extension). So, for example, `bitCount(toUInt8(-1)) = 8`.

Type: `UInt8`.

**Example**

Take for example the number 333. Its binary representation: 000101001101.

Query:

```
SELECT bitCount(333);
```

Result:

```
┌─bitCount(333)─┐
│             5 │
└───────────────┘
```

## bitHammingDistance

Returns the Hamming Distance between the bit representations of two integer values. Can be used with SimHash functions for detection of semi-duplicate strings. The smaller is the distance, the more likely those strings are the same.

**Syntax**

```
bitHammingDistance(int1, int2)
```

**Arguments**

- `int1` — First integer value. Int64.
- `int2` — Second integer value. Int64.

**Returned value**

- The Hamming distance.

Type: UInt8.

**Examples**

Query:

```
SELECT bitHammingDistance(111, 121);
```

Result:

```
┌─bitHammingDistance(111, 121)─┐
│                            3 │
└──────────────────────────────┘
```

With SimHash

```
SELECT bitHammingDistance(ngramSimHash(cat ate rat), ngramSimHash(rat ate cat));
```

Result:

```
┌─bitHammingDistance(ngramSimHash(cat ate rat), ngramSimHash(rat ate cat))─┐
│                                                                            5 │
└──────────────────────────────────────────────────────────────────────────────┘
```

' where id=34;

update biz_data_query_model_help_content set content_en = '# Other Functions

## hostName()

Returns a string with the name of the host that this function was performed on. For distributed processing, this is the name of the remote server host, if the function is performed on a remote server.

## getMacro

Gets a named value from the macors section of the server configuration.

**Syntax**

```
getMacro(name);
```

**Arguments**

- `name` — Name to retrieve from the `macros` section. String

**Returned value**

- Value of the specified macro.

Type: String

**Example**

The example `macros` section in the server configuration file:

```
<macros>
    <test>Value</test>
</macros>
```

Query:

```
SELECT getMacro(test);
```

Result:

```
┌─getMacro(test)─┐
│ Value            │
└──────────────────┘
```

An alternative way to get the same value:

```
SELECT * FROM system.macros
WHERE macro = test;
┌─macro─┬─substitution─┐
│ test  │ Value        │
└───────┴──────────────┘
```

## FQDN

Returns the fully qualified domain name.

**Syntax**

```
fqdn();
```

This function is case-insensitive.

**Returned value**

- String with the fully qualified domain name.

Type: `String`.

**Example**

Query:

```
SELECT FQDN();
```

Result:

```
┌─FQDN()──────────────────────────┐
│ clickhouse.ru-central1.internal │
└─────────────────────────────────┘
```

## basename

Extracts the trailing part of a string after the last slash or backslash. This function if often used to extract the filename from a path.

```
basename( expr )
```

**Arguments**

- `expr` — Expression resulting in a String type value. All the backslashes must be escaped in the resulting value.

**Returned Value**

A string that contains:

- The trailing part of a string after the last slash or backslash.

  ```
  If the input string contains a path ending with slash or backslash, for example, `/` or `c:\`, the function returns an empty string.
  ```

- The original string if there are no slashes or backslashes.

**Example**

```
SELECT some/long/path/to/file AS a, basename(a)
┌─a──────────────────────┬─basename(some\\long\\path\\to\\file)─┐
│ some\long\path\to\file │ file                                   │
└────────────────────────┴────────────────────────────────────────┘
SELECT some\\long\\path\\to\\file AS a, basename(a)
┌─a──────────────────────┬─basename(some\\long\\path\\to\\file)─┐
│ some\long\path\to\file │ file                                   │
└────────────────────────┴────────────────────────────────────────┘
SELECT some-file-name AS a, basename(a)
┌─a──────────────┬─basename(some-file-name)─┐
│ some-file-name │ some-file-name             │
└────────────────┴────────────────────────────┘
```

## visibleWidth(x)

Calculates the approximate width when outputting values to the console in text format (tab-separated).
This function is used by the system for implementing Pretty formats.

`NULL` is represented as a string corresponding to `NULL` in `Pretty` formats.

```
SELECT visibleWidth(NULL)
┌─visibleWidth(NULL)─┐
│                  4 │
└────────────────────┘
```

## toTypeName(x)

Returns a string containing the type name of the passed argument.

If `NULL` is passed to the function as input, then it returns the `Nullable(Nothing)` type, which corresponds to an internal `NULL` representation in ClickHouse.

## blockSize()

Gets the size of the block.
In ClickHouse, queries are always run on blocks (sets of column parts). This function allows getting the size of the block that you called it for.

## byteSize

Returns estimation of uncompressed byte size of its arguments in memory.

**Syntax**

```
byteSize(argument [, ...])
```

**Arguments**

- `argument` — Value.

**Returned value**

- Estimation of byte size of the arguments in memory.

Type: UInt64.

**Examples**

For String arguments the funtion returns the string length + 9 (terminating zero + length).

Query:

```
SELECT byteSize(string);
```

Result:

```
┌─byteSize(string)─┐
│                 15 │
└────────────────────┘
```

Query:

```
CREATE TABLE test
(
    `key` Int32,
    `u8` UInt8,
    `u16` UInt16,
    `u32` UInt32,
    `u64` UInt64,
    `i8` Int8,
    `i16` Int16,
    `i32` Int32,
    `i64` Int64,
    `f32` Float32,
    `f64` Float64
)
ENGINE = MergeTree
ORDER BY key;

INSERT INTO test VALUES(1, 8, 16, 32, 64,  -8, -16, -32, -64, 32.32, 64.64);

SELECT key, byteSize(u8) AS `byteSize(UInt8)`, byteSize(u16) AS `byteSize(UInt16)`, byteSize(u32) AS `byteSize(UInt32)`, byteSize(u64) AS `byteSize(UInt64)`, byteSize(i8) AS `byteSize(Int8)`, byteSize(i16) AS `byteSize(Int16)`, byteSize(i32) AS `byteSize(Int32)`, byteSize(i64) AS `byteSize(Int64)`, byteSize(f32) AS `byteSize(Float32)`, byteSize(f64) AS `byteSize(Float64)` FROM test ORDER BY key ASC FORMAT Vertical;
```

Result:

```
Row 1:
──────
key:               1
byteSize(UInt8):   1
byteSize(UInt16):  2
byteSize(UInt32):  4
byteSize(UInt64):  8
byteSize(Int8):    1
byteSize(Int16):   2
byteSize(Int32):   4
byteSize(Int64):   8
byteSize(Float32): 4
byteSize(Float64): 8
```

If the function takes multiple arguments, it returns their combined byte size.

Query:

```
SELECT byteSize(NULL, 1, 0.3, );
```

Result:

```
┌─byteSize(NULL, 1, 0.3, )─┐
│                         19 │
└────────────────────────────┘
```

## materialize(x)

Turns a constant into a full column containing just one value.
In ClickHouse, full columns and constants are represented differently in memory. Functions work differently for constant arguments and normal arguments (different code is executed), although the result is almost always the same. This function is for debugging this behavior.

## ignore(…)

Accepts any arguments, including `NULL`. Always returns 0.
However, the argument is still evaluated. This can be used for benchmarks.

## sleep(seconds)

Sleeps ‘seconds’ seconds on each data block. You can specify an integer or a floating-point number.

## sleepEachRow(seconds)

Sleeps ‘seconds’ seconds on each row. You can specify an integer or a floating-point number.

## currentDatabase()

Returns the name of the current database.
You can use this function in table engine parameters in a CREATE TABLE query where you need to specify the database.

## currentUser()

Returns the login of current user. Login of user, that initiated query, will be returned in case distibuted query.

```
SELECT currentUser();
```

Alias: `user()`, `USER()`.

**Returned values**

- Login of current user.
- Login of user that initiated query in case of disributed query.

Type: `String`.

**Example**

Query:

```
SELECT currentUser();
```

Result:

```
┌─currentUser()─┐
│ default       │
└───────────────┘
```

## isConstant

Checks whether the argument is a constant expression.

A constant expression means an expression whose resulting value is known at the query analysis (i.e. before execution). For example, expressions over literals  are constant expressions.

The function is intended for development, debugging and demonstration.

**Syntax**

```
isConstant(x)
```

**Arguments**

- `x` — Expression to check.

**Returned values**

- `1` — `x` is constant.
- `0` — `x` is non-constant.

Type: UInt8.

**Examples**

Query:

```
SELECT isConstant(x + 1) FROM (SELECT 43 AS x)
```

Result:

```
┌─isConstant(plus(x, 1))─┐
│                      1 │
└────────────────────────┘
```

Query:

```
WITH 3.14 AS pi SELECT isConstant(cos(pi))
```

Result:

```
┌─isConstant(cos(pi))─┐
│                   1 │
└─────────────────────┘
```

Query:

```
SELECT isConstant(number) FROM numbers(1)
```

Result:

```
┌─isConstant(number)─┐
│                  0 │
└────────────────────┘
```

## isFinite(x)

Accepts Float32 and Float64 and returns UInt8 equal to 1 if the argument is not infinite and not a NaN, otherwise 0.

## isInfinite(x)

Accepts Float32 and Float64 and returns UInt8 equal to 1 if the argument is infinite, otherwise 0. Note that 0 is returned for a NaN.

## ifNotFinite

Checks whether floating point value is finite.

**Syntax**

```
ifNotFinite(x,y)
```

**Arguments**

- `x` — Value to be checked for infinity. Type: Float*
- `y` — Fallback value. Type: Float*

**Returned value**

- `x` if `x` is finite.
- `y` if `x` is not finite.

**Example**

Query:

```
SELECT 1/0 as infimum, ifNotFinite(infimum,42)
```

Result:

```
┌─infimum─┬─ifNotFinite(divide(1, 0), 42)─┐
│     inf │                            42 │
└─────────┴───────────────────────────────┘
```

You can get similar result by using ternary operator: `isFinite(x) ? x : y`.

## isNaN(x)

Accepts Float32 and Float64 and returns UInt8 equal to 1 if the argument is a NaN, otherwise 0.

## hasColumnInTable([‘hostname’[, ‘username’[, ‘password’]],] ‘database’, ‘table’, ‘column’)

Accepts constant strings: database name, table name, and column name. Returns a UInt8 constant expression equal to 1 if there is a column, otherwise 0. If the hostname parameter is set, the test will run on a remote server.
The function throws an exception if the table does not exist.
For elements in a nested data structure, the function checks for the existence of a column. For the nested data structure itself, the function returns 0.

## bar

Allows building a unicode-art diagram.

`bar(x, min, max, width)` draws a band with a width proportional to `(x - min)` and equal to `width` characters when `x = max`.

**Arguments**

- `x` — Size to display.
- `min, max` — Integer constants. The value must fit in `Int64`.
- `width` — Constant, positive integer, can be fractional.

The band is drawn with accuracy to one eighth of a symbol.

Example:

```
SELECT
    toHour(EventTime) AS h,
    count() AS c,
    bar(c, 0, 60, 20) AS bar
FROM test.hits
GROUP BY h
ORDER BY h ASC
┌──h─┬──────c─┬─bar────────────────┐
│  0 │ 292907 │ █████████▋         │
│  1 │ 180563 │ ██████             │
│  2 │ 114861 │ ███▋               │
│  3 │  85069 │ ██▋                │
│  4 │  68543 │ ██▎                │
│  5 │  78116 │ ██▌                │
│  6 │ 113474 │ ███▋               │
│  7 │ 170678 │ █████▋             │
│  8 │ 278380 │ █████████▎         │
│  9 │ 391053 │ █████████████      │
│ 10 │ 457681 │ ███████████████▎   │
│ 11 │ 493667 │ ████████████████▍  │
│ 12 │ 509641 │ ████████████████▊  │
│ 13 │ 522947 │ █████████████████▍ │
│ 14 │ 539954 │ █████████████████▊ │
│ 15 │ 528460 │ █████████████████▌ │
│ 16 │ 539201 │ █████████████████▊ │
│ 17 │ 523539 │ █████████████████▍ │
│ 18 │ 506467 │ ████████████████▊  │
│ 19 │ 520915 │ █████████████████▎ │
│ 20 │ 521665 │ █████████████████▍ │
│ 21 │ 542078 │ ██████████████████ │
│ 22 │ 493642 │ ████████████████▍  │
│ 23 │ 400397 │ █████████████▎     │
└────┴────────┴────────────────────┘
```

## transform

Transforms a value according to the explicitly defined mapping of some elements to other ones.
There are two variations of this function:

### transform(x, array_from, array_to, default)

`x` – What to transform.

`array_from` – Constant array of values for converting.

`array_to` – Constant array of values to convert the values in ‘from’ to.

`default` – Which value to use if ‘x’ is not equal to any of the values in ‘from’.

`array_from` and `array_to` – Arrays of the same size.

Types:

```
transform(T, Array(T), Array(U), U) -> U
```

`T` and `U` can be numeric, string, or Date or DateTime types.
Where the same letter is indicated (T or U), for numeric types these might not be matching types, but types that have a common type.
For example, the first argument can have the Int64 type, while the second has the Array(UInt16) type.

If the ‘x’ value is equal to one of the elements in the ‘array_from’ array, it returns the existing element (that is numbered the same) from the ‘array_to’ array. Otherwise, it returns ‘default’. If there are multiple matching elements in ‘array_from’, it returns one of the matches.

Example:

```
SELECT
    transform(SearchEngineID, [2, 3], [Yandex, Google], Other) AS title,
    count() AS c
FROM test.hits
WHERE SearchEngineID != 0
GROUP BY title
ORDER BY c DESC
┌─title─────┬──────c─┐
│ Yandex    │ 498635 │
│ Google    │ 229872 │
│ Other     │ 104472 │
└───────────┴────────┘
```

### transform(x, array_from, array_to)

Differs from the first variation in that the ‘default’ argument is omitted.
If the ‘x’ value is equal to one of the elements in the ‘array_from’ array, it returns the matching element (that is numbered the same) from the ‘array_to’ array. Otherwise, it returns ‘x’.

Types:

```
transform(T, Array(T), Array(T)) -> T
```

Example:

```
SELECT
    transform(domain(Referer), [yandex.ru, google.ru, vk.com], [www.yandex, example.com]) AS s,
    count() AS c
FROM test.hits
GROUP BY domain(Referer)
ORDER BY count() DESC
LIMIT 10
┌─s──────────────┬───────c─┐
│                │ 2906259 │
│ www.yandex     │  867767 │
│ ███████.ru     │  313599 │
│ mail.yandex.ru │  107147 │
│ ██████.ru      │  100355 │
│ █████████.ru   │   65040 │
│ news.yandex.ru │   64515 │
│ ██████.net     │   59141 │
│ example.com    │   57316 │
└────────────────┴─────────┘
```

## formatReadableSize(x)

Accepts the size (number of bytes). Returns a rounded size with a suffix (KiB, MiB, etc.) as a string.

Example:

```
SELECT
    arrayJoin([1, 1024, 1024*1024, 192851925]) AS filesize_bytes,
    formatReadableSize(filesize_bytes) AS filesize
┌─filesize_bytes─┬─filesize───┐
│              1 │ 1.00 B     │
│           1024 │ 1.00 KiB   │
│        1048576 │ 1.00 MiB   │
│      192851925 │ 183.92 MiB │
└────────────────┴────────────┘
```

## formatReadableQuantity(x)

Accepts the number. Returns a rounded number with a suffix (thousand, million, billion, etc.) as a string.

It is useful for reading big numbers by human.

Example:

```
SELECT
    arrayJoin([1024, 1234 * 1000, (4567 * 1000) * 1000, 98765432101234]) AS number,
    formatReadableQuantity(number) AS number_for_humans
┌─────────number─┬─number_for_humans─┐
│           1024 │ 1.02 thousand     │
│        1234000 │ 1.23 million      │
│     456700 │ 4.57 billion      │
│ 98765432101234 │ 98.77 trillion    │
└────────────────┴───────────────────┘
```

## formatReadableTimeDelta

Accepts the time delta in seconds. Returns a time delta with (year, month, day, hour, minute, second) as a string.

**Syntax**

```
formatReadableTimeDelta(column[, maximum_unit])
```

**Arguments**

- `column` — A column with numeric time delta.
- `maximum_unit` — Optional. Maximum unit to show. Acceptable values seconds, minutes, hours, days, months, years.

Example:

```
SELECT
    arrayJoin([100, 12345, 432546534]) AS elapsed,
    formatReadableTimeDelta(elapsed) AS time_delta
┌────elapsed─┬─time_delta ─────────────────────────────────────────────────────┐
│        100 │ 1 minute and 40 seconds                                         │
│      12345 │ 3 hours, 25 minutes and 45 seconds                              │
│  432546534 │ 13 years, 8 months, 17 days, 7 hours, 48 minutes and 54 seconds │
└────────────┴─────────────────────────────────────────────────────────────────┘
SELECT
    arrayJoin([100, 12345, 432546534]) AS elapsed,
    formatReadableTimeDelta(elapsed, minutes) AS time_delta
┌────elapsed─┬─time_delta ─────────────────────────────────────────────────────┐
│        100 │ 1 minute and 40 seconds                                         │
│      12345 │ 205 minutes and 45 seconds                                      │
│  432546534 │ 7209108 minutes and 54 seconds                                  │
└────────────┴─────────────────────────────────────────────────────────────────┘
```

## least(a, b)

Returns the smallest value from a and b.

## greatest(a, b)

Returns the largest value of a and b.

## uptime()

Returns the server’s uptime in seconds.

## version()

Returns the version of the server as a string.

## blockNumber

Returns the sequence number of the data block where the row is located.

## rowNumberInBlock

Returns the ordinal number of the row in the data block. Different data blocks are always recalculated.

## rowNumberInAllBlocks()

Returns the ordinal number of the row in the data block. This function only considers the affected data blocks.

## neighbor

The window function that provides access to a row at a specified offset which comes before or after the current row of a given column.

**Syntax**

```
neighbor(column, offset[, default_value])
```

The result of the function depends on the affected data blocks and the order of data in the block.

Warning

It can reach the neighbor rows only inside the currently processed data block.

The rows order used during the calculation of `neighbor` can differ from the order of rows returned to the user.
To prevent that you can make a subquery with ODER-BY and call the function from outside the subquery.

**Arguments**

- `column` — A column name or scalar expression.
- `offset` — The number of rows forwards or backwards from the current row of `column`. Int64
- `default_value` — Optional. The value to be returned if offset goes beyond the scope of the block. Type of data blocks affected.

**Returned values**

- Value for `column` in `offset` distance from current row if `offset` value is not outside block bounds.
- Default value for `column` if `offset` value is outside block bounds. If `default_value` is given, then it will be used.

Type: type of data blocks affected or default value type.

**Example**

Query:

```
SELECT number, neighbor(number, 2) FROM system.numbers LIMIT 10;
```

Result:

```
┌─number─┬─neighbor(number, 2)─┐
│      0 │                   2 │
│      1 │                   3 │
│      2 │                   4 │
│      3 │                   5 │
│      4 │                   6 │
│      5 │                   7 │
│      6 │                   8 │
│      7 │                   9 │
│      8 │                   0 │
│      9 │                   0 │
└────────┴─────────────────────┘
```

Query:

```
SELECT number, neighbor(number, 2, 999) FROM system.numbers LIMIT 10;
```

Result:

```
┌─number─┬─neighbor(number, 2, 999)─┐
│      0 │                        2 │
│      1 │                        3 │
│      2 │                        4 │
│      3 │                        5 │
│      4 │                        6 │
│      5 │                        7 │
│      6 │                        8 │
│      7 │                        9 │
│      8 │                      999 │
│      9 │                      999 │
└────────┴──────────────────────────┘
```

This function can be used to compute year-over-year metric value:

Query:

```
WITH toDate(2018-01-01) AS start_date
SELECT
    toStartOfMonth(start_date + (number * 32)) AS month,
    toInt32(month) % 100 AS money,
    neighbor(money, -12) AS prev_year,
    round(prev_year / money, 2) AS year_over_year
FROM numbers(16)
```

Result:

```
┌──────month─┬─money─┬─prev_year─┬─year_over_year─┐
│ 2018-01-01 │    32 │         0 │              0 │
│ 2018-02-01 │    63 │         0 │              0 │
│ 2018-03-01 │    91 │         0 │              0 │
│ 2018-04-01 │    22 │         0 │              0 │
│ 2018-05-01 │    52 │         0 │              0 │
│ 2018-06-01 │    83 │         0 │              0 │
│ 2018-07-01 │    13 │         0 │              0 │
│ 2018-08-01 │    44 │         0 │              0 │
│ 2018-09-01 │    75 │         0 │              0 │
│ 2018-10-01 │     5 │         0 │              0 │
│ 2018-11-01 │    36 │         0 │              0 │
│ 2018-12-01 │    66 │         0 │              0 │
│ 2019-01-01 │    97 │        32 │           0.33 │
│ 2019-02-01 │    28 │        63 │           2.25 │
│ 2019-03-01 │    56 │        91 │           1.62 │
│ 2019-04-01 │    87 │        22 │           0.25 │
└────────────┴───────┴───────────┴────────────────┘
```

## runningDifference(x)

Calculates the difference between successive row values in the data block.
Returns 0 for the first row and the difference from the previous row for each subsequent row.

Warning

It can reach the previous row only inside the currently processed data block.

The result of the function depends on the affected data blocks and the order of data in the block.

The rows order used during the calculation of `runningDifference` can differ from the order of rows returned to the user.
To prevent that you can make a subquery with ORDER BY and call the function from outside the subquery.

Example:

```
SELECT
    EventID,
    EventTime,
    runningDifference(EventTime) AS delta
FROM
(
    SELECT
        EventID,
        EventTime
    FROM events
    WHERE EventDate = 2016-11-24
    ORDER BY EventTime ASC
    LIMIT 5
)
┌─EventID─┬───────────EventTime─┬─delta─┐
│    1106 │ 2016-11-24 00:00:04 │     0 │
│    1107 │ 2016-11-24 00:00:05 │     1 │
│    1108 │ 2016-11-24 00:00:05 │     0 │
│    1109 │ 2016-11-24 00:00:09 │     4 │
│    1110 │ 2016-11-24 00:00:10 │     1 │
└─────────┴─────────────────────┴───────┘
```

Please note - block size affects the result. With each new block, the `runningDifference` state is reset.

```
SELECT
    number,
    runningDifference(number + 1) AS diff
FROM numbers(10)
WHERE diff != 1
┌─number─┬─diff─┐
│      0 │    0 │
└────────┴──────┘
┌─number─┬─diff─┐
│  65536 │    0 │
└────────┴──────┘
set max_block_size=10 -- default value is 65536!

SELECT
    number,
    runningDifference(number + 1) AS diff
FROM numbers(10)
WHERE diff != 1
┌─number─┬─diff─┐
│      0 │    0 │
└────────┴──────┘
```

## runningDifferenceStartingWithFirstValue

Same as for runningDifference, the difference is the value of the first row, returned the value of the first row, and each subsequent row returns the difference from the previous row.

## runningConcurrency

Calculates the number of concurrent events.
Each event has a start time and an end time. The start time is included in the event, while the end time is excluded. Columns with a start time and an end time must be of the same data type.
The function calculates the total number of active (concurrent) events for each event start time.

Warning

Events must be ordered by the start time in ascending order. If this requirement is violated the function raises an exception.
Every data block is processed separately. If events from different data blocks overlap then they can not be processed correctly.

**Syntax**

```
runningConcurrency(start, end)
```

**Arguments**

- `start` — A column with the start time of events. Date, DateTime, or DateTime64.
- `end` — A column with the end time of events. Date, DateTime, or DateTime64.

**Returned values**

- The number of concurrent events at each event start time.

Type: UInt32

**Example**

Consider the table:

```
┌──────start─┬────────end─┐
│ 2021-03-03 │ 2021-03-11 │
│ 2021-03-06 │ 2021-03-12 │
│ 2021-03-07 │ 2021-03-08 │
│ 2021-03-11 │ 2021-03-12 │
└────────────┴────────────┘
```

Query:

```
SELECT start, runningConcurrency(start, end) FROM example_table;
```

Result:

```
┌──────start─┬─runningConcurrency(start, end)─┐
│ 2021-03-03 │                              1 │
│ 2021-03-06 │                              2 │
│ 2021-03-07 │                              3 │
│ 2021-03-11 │                              2 │
└────────────┴────────────────────────────────┘
```

## MACNumToString(num)

Accepts a UInt64 number. Interprets it as a MAC address in big endian. Returns a string containing the corresponding MAC address in the format AA:BB:CC:DD:EE:FF (colon-separated numbers in hexadecimal form).

## MACStringToNum(s)

The inverse function of MACNumToString. If the MAC address has an invalid format, it returns 0.

## MACStringToOUI(s)

Accepts a MAC address in the format AA:BB:CC:DD:EE:FF (colon-separated numbers in hexadecimal form). Returns the first three octets as a UInt64 number. If the MAC address has an invalid format, it returns 0.

## getSizeOfEnumType

Returns the number of fields in [Enum

```
getSizeOfEnumType(value)
```

**Arguments:**

- `value` — Value of type `Enum`.

**Returned values**

- The number of fields with `Enum` input values.
- An exception is thrown if the type is not `Enum`.

**Example**

```
SELECT getSizeOfEnumType( CAST(a AS Enum8(a = 1, b = 2) ) ) AS x
┌─x─┐
│ 2 │
└───┘
```

## blockSerializedSize

Returns size on disk (without taking into account compression).

```
blockSerializedSize(value[, value[, ...]])
```

**Arguments**

- `value` — Any value.

**Returned values**

- The number of bytes that will be written to disk for block of values (without compression).

**Example**

Query:

```
SELECT blockSerializedSize(maxState(1)) as x
```

Result:

```
┌─x─┐
│ 2 │
└───┘
```

## toColumnTypeName

Returns the name of the class that represents the data type of the column in RAM.

```
toColumnTypeName(value)
```

**Arguments:**

- `value` — Any type of value.

**Returned values**

- A string with the name of the class that is used for representing the `value` data type in RAM.

**Example of the difference between`toTypeName  and  toColumnTypeName`**

```
SELECT toTypeName(CAST(2018-01-01 01:02:03 AS DateTime))
┌─toTypeName(CAST(2018-01-01 01:02:03, DateTime))─┐
│ DateTime                                            │
└─────────────────────────────────────────────────────┘
SELECT toColumnTypeName(CAST(2018-01-01 01:02:03 AS DateTime))
┌─toColumnTypeName(CAST(2018-01-01 01:02:03, DateTime))─┐
│ Const(UInt32)                                             │
└───────────────────────────────────────────────────────────┘
```

The example shows that the `DateTime` data type is stored in memory as `Const(UInt32)`.

## dumpColumnStructure

Outputs a detailed description of data structures in RAM

```
dumpColumnStructure(value)
```

**Arguments:**

- `value` — Any type of value.

**Returned values**

- A string describing the structure that is used for representing the `value` data type in RAM.

**Example**

```
SELECT dumpColumnStructure(CAST(2018-01-01 01:02:03, DateTime))
┌─dumpColumnStructure(CAST(2018-01-01 01:02:03, DateTime))─┐
│ DateTime, Const(size = 1, UInt32(size = 1))                  │
└──────────────────────────────────────────────────────────────┘
```

## defaultValueOfArgumentType)

Outputs the default value for the data type.

Does not include default values for custom columns set by the user.

```
defaultValueOfArgumentType(expression)
```

**Arguments:**

- `expression` — Arbitrary type of value or an expression that results in a value of an arbitrary type.

**Returned values**

- `0` for numbers.
- Empty string for strings.
- `ᴺᵁᴸᴸ` for Nullable

**Example**

```
SELECT defaultValueOfArgumentType( CAST(1 AS Int8) )
┌─defaultValueOfArgumentType(CAST(1, Int8))─┐
│                                           0 │
└─────────────────────────────────────────────┘
SELECT defaultValueOfArgumentType( CAST(1 AS Nullable(Int8) ) )
┌─defaultValueOfArgumentType(CAST(1, Nullable(Int8)))─┐
│                                                  ᴺᵁᴸᴸ │
└───────────────────────────────────────────────────────┘
```

## defaultValueOfTypeName

Outputs the default value for given type name.

Does not include default values for custom columns set by the user.

```
defaultValueOfTypeName(type)
```

**Arguments:**

- `type` — A string representing a type name.

**Returned values**

- `0` for numbers.
- Empty string for strings.
- `ᴺᵁᴸᴸ` for Nullable.

**Example**

```
SELECT defaultValueOfTypeName(Int8)
┌─defaultValueOfTypeName(Int8)─┐
│                              0 │
└────────────────────────────────┘
SELECT defaultValueOfTypeName(Nullable(Int8))
┌─defaultValueOfTypeName(Nullable(Int8))─┐
│                                     ᴺᵁᴸᴸ │
└──────────────────────────────────────────┘
```

## indexHint

The function is intended for debugging and introspection purposes. The function ignores its argument and always returns 1. Arguments are not even evaluated.

But for the purpose of index analysis, the argument of this function is analyzed as if it was present directly without being wrapped inside `indexHint` function. This allows to select data in index ranges by the corresponding condition but without further filtering by this condition. The index in ClickHouse is sparse and using `indexHint` will yield more data than specifying the same condition directly.

**Syntax**

```
SELECT * FROM table WHERE indexHint(<expression>)
```

**Returned value**

1. Type: Uint8.

**Example**

Here is the example of test data from the table ontime.

Input table:

```
SELECT count() FROM ontime
┌─count()─┐
│ 4276457 │
└─────────┘
```

The table has indexes on the fields `(FlightDate, (Year, FlightDate))`.

Create a query, where the index is not used.

Query:

```
SELECT FlightDate AS k, count() FROM ontime GROUP BY k ORDER BY k
```

ClickHouse processed the entire table (`Processed 4.28 million rows`).

Result:

```
┌──────────k─┬─count()─┐
│ 2017-01-01 │   13970 │
│ 2017-01-02 │   15882 │
........................
│ 2017-09-28 │   16411 │
│ 2017-09-29 │   16384 │
│ 2017-09-30 │   12520 │
└────────────┴─────────┘
```

To apply the index, select a specific date.

Query:

```
SELECT FlightDate AS k, count() FROM ontime WHERE k = 2017-09-15 GROUP BY k ORDER BY k
```

By using the index, ClickHouse processed a significantly smaller number of rows (`Processed 32.74 thousand rows`).

Result:

```
┌──────────k─┬─count()─┐
│ 2017-09-15 │   16428 │
└────────────┴─────────┘
```

Now wrap the expression `k = 2017-09-15` into `indexHint` function.

Query:

```
SELECT
    FlightDate AS k,
    count()
FROM ontime
WHERE indexHint(k = 2017-09-15)
GROUP BY k
ORDER BY k ASC
```

ClickHouse used the index in the same way as the previous time (`Processed 32.74 thousand rows`).
The expression `k = 2017-09-15` was not used when generating the result.
In examle the `indexHint` function allows to see adjacent dates.

Result:

```
┌──────────k─┬─count()─┐
│ 2017-09-14 │    7071 │
│ 2017-09-15 │   16428 │
│ 2017-09-16 │    1077 │
│ 2017-09-30 │    8167 │
└────────────┴─────────┘
```

## replicate

Creates an array with a single value.

Used for internal implementation of arrayJoin

```
SELECT replicate(x, arr);
```

**Arguments:**

- `arr` — Original array. ClickHouse creates a new array of the same length as the original and fills it with the value `x`.
- `x` — The value that the resulting array will be filled with.

**Returned value**

An array filled with the value `x`.

Type: `Array`.

**Example**

Query:

```
SELECT replicate(1, [a, b, c])
```

Result:

```
┌─replicate(1, [a, b, c])─┐
│ [1,1,1]                       │
└───────────────────────────────┘
```

## filesystemAvailable

Returns amount of remaining space on the filesystem where the files of the databases located. It is always smaller than total free space (filesystemFree because some space is reserved for OS.

**Syntax**

```
filesystemAvailable()
```

**Returned value**

- The amount of remaining space available in bytes.

Type: UInt64

**Example**

Query:

```
SELECT formatReadableSize(filesystemAvailable()) AS "Available space", toTypeName(filesystemAvailable()) AS "Type";
```

Result:

```
┌─Available space─┬─Type───┐
│ 30.75 GiB       │ UInt64 │
└─────────────────┴────────┘
```

## filesystemFree

Returns total amount of the free space on the filesystem where the files of the databases located. See also `filesystemAvailable`

**Syntax**

```
filesystemFree()
```

**Returned value**

- Amount of free space in bytes.

Type:Uint64

**Example**

Query:

```
SELECT formatReadableSize(filesystemFree()) AS "Free space", toTypeName(filesystemFree()) AS "Type";
```

Result:

```
┌─Free space─┬─Type───┐
│ 32.39 GiB  │ UInt64 │
└────────────┴────────┘
```

## filesystemCapacity

Returns the capacity of the filesystem in bytes. For evaluation, the path to the data directory must be configured.

**Syntax**

```
filesystemCapacity()
```

**Returned value**

- Capacity information of the filesystem in bytes.

Type: UInt64.

**Example**

Query:

```
SELECT formatReadableSize(filesystemCapacity()) AS "Capacity", toTypeName(filesystemCapacity()) AS "Type"
```

Result:

```
┌─Capacity──┬─Type───┐
│ 39.32 GiB │ UInt64 │
└───────────┴────────┘
```

## initializeAggregation

Calculates result of aggregate function based on single value. It is intended to use this function to initialize aggregate functions with combinator -State. You can create states of aggregate functions and insert them to columns of type AggregateFunction or use initialized aggregates as default values.

**Syntax**

```
initializeAggregation (aggregate_function, arg1, arg2, ..., argN)
```

**Arguments**

- `aggregate_function` — Name of the aggregation function to initialize. String.
- `arg` — Arguments of aggregate function.

**Returned value(s)**

- Result of aggregation for every row passed to the function.

The return type is the same as the return type of function, that `initializeAgregation` takes as first argument.

**Example**

Query:

```
SELECT uniqMerge(state) FROM (SELECT initializeAggregation(uniqState, number % 3) AS state FROM numbers(1));
```

Result:

```
┌─uniqMerge(state)─┐
│                3 │
└──────────────────┘
```

Query:

```
SELECT finalizeAggregation(state), toTypeName(state) FROM (SELECT initializeAggregation(sumState, number % 3) AS state FROM numbers(5));
```

Result:

```
┌─finalizeAggregation(state)─┬─toTypeName(state)─────────────┐
│                          0 │ AggregateFunction(sum, UInt8) │
│                          1 │ AggregateFunction(sum, UInt8) │
│                          2 │ AggregateFunction(sum, UInt8) │
│                          0 │ AggregateFunction(sum, UInt8) │
│                          1 │ AggregateFunction(sum, UInt8) │
└────────────────────────────┴───────────────────────────────┘
```

Example with `AggregatingMergeTree` table engine and `AggregateFunction` column:

```
CREATE TABLE metrics
(
    key UInt64,
    value AggregateFunction(sum, UInt64) DEFAULT initializeAggregation(sumState, toUInt64(0))
)
ENGINE = AggregatingMergeTree
ORDER BY key
INSERT INTO metrics VALUES (0, initializeAggregation(sumState, toUInt64(42)))
```

**See Also**
\- arrayReduce

## finalizeAggregation

Takes state of aggregate function. Returns result of aggregation (or finalized state when using-State combinator).

**Syntax**

```
finalizeAggregation(state)
```

**Arguments**

- `state` — State of aggregation. AggregateFunction

**Returned value(s)**

- Value/values that was aggregated.

Type: Value of any types that was aggregated.

**Examples**

Query:

```
SELECT finalizeAggregation(( SELECT countState(number) FROM numbers(10)));
```

Result:

```
┌─finalizeAggregation(_subquery16)─┐
│                               10 │
└──────────────────────────────────┘
```

Query:

```
SELECT finalizeAggregation(( SELECT sumState(number) FROM numbers(10)));
```

Result:

```
┌─finalizeAggregation(_subquery20)─┐
│                               45 │
└──────────────────────────────────┘
```

Note that `NULL` values are ignored.

Query:

```
SELECT finalizeAggregation(arrayReduce(anyState, [NULL, 2, 3]));
```

Result:

```
┌─finalizeAggregation(arrayReduce(anyState, [NULL, 2, 3]))─┐
│                                                          2 │
└────────────────────────────────────────────────────────────┘
```

Combined example:

Query:

```
WITH initializeAggregation(sumState, number) AS one_row_sum_state
SELECT
    number,
    finalizeAggregation(one_row_sum_state) AS one_row_sum,
    runningAccumulate(one_row_sum_state) AS cumulative_sum
FROM numbers(10);
```

Result:

```
┌─number─┬─one_row_sum─┬─cumulative_sum─┐
│      0 │           0 │              0 │
│      1 │           1 │              1 │
│      2 │           2 │              3 │
│      3 │           3 │              6 │
│      4 │           4 │             10 │
│      5 │           5 │             15 │
│      6 │           6 │             21 │
│      7 │           7 │             28 │
│      8 │           8 │             36 │
│      9 │           9 │             45 │
└────────┴─────────────┴────────────────┘
```

**See Also**
\- arrayReduce
\- initializeAggregation

## runningAccumulate

Accumulates states of an aggregate function for each row of a data block.

Warning

The state is reset for each new data block.

**Syntax**

```
runningAccumulate(agg_state[, grouping]);
```

**Arguments**

- `agg_state` — State of the aggregate function. AggregateFunction
- `grouping` — Grouping key. Optional. The state of the function is reset if the `grouping` value is changed. It can be any of the supported data types for which the equality operator is defined.

**Returned value**

- Each resulting row contains a result of the aggregate function, accumulated for all the input rows from 0 to the current position. `runningAccumulate` resets states for each new data block or when the `grouping` value changes.

Type depends on the aggregate function used.

**Examples**

Consider how you can use `runningAccumulate` to find the cumulative sum of numbers without and with grouping.

Query:

```
SELECT k, runningAccumulate(sum_k) AS res FROM (SELECT number as k, sumState(k) AS sum_k FROM numbers(10) GROUP BY k ORDER BY k);
```

Result:

```
┌─k─┬─res─┐
│ 0 │   0 │
│ 1 │   1 │
│ 2 │   3 │
│ 3 │   6 │
│ 4 │  10 │
│ 5 │  15 │
│ 6 │  21 │
│ 7 │  28 │
│ 8 │  36 │
│ 9 │  45 │
└───┴─────┘
```

The subquery generates `sumState` for every number from `0` to `9`. `sumState` returns the state of the [sum](https://clickhouse.tech/docs/en/sql-reference/aggregate-functions/reference/sum/) function that contains the sum of a single number.

The whole query does the following:

1. For the first row, `runningAccumulate` takes `sumState(0)` and returns `0`.
2. For the second row, the function merges `sumState(0)` and `sumState(1)` resulting in `sumState(0 + 1)`, and returns `1` as a result.
3. For the third row, the function merges `sumState(0 + 1)` and `sumState(2)` resulting in `sumState(0 + 1 + 2)`, and returns `3` as a result.
4. The actions are repeated until the block ends.

The following example shows the `groupping` parameter usage:

Query:

```
SELECT
    grouping,
    item,
    runningAccumulate(state, grouping) AS res
FROM
(
    SELECT
        toInt8(number / 4) AS grouping,
        number AS item,
        sumState(number) AS state
    FROM numbers(15)
    GROUP BY item
    ORDER BY item ASC
);
```

Result:

```
┌─grouping─┬─item─┬─res─┐
│        0 │    0 │   0 │
│        0 │    1 │   1 │
│        0 │    2 │   3 │
│        0 │    3 │   6 │
│        1 │    4 │   4 │
│        1 │    5 │   9 │
│        1 │    6 │  15 │
│        1 │    7 │  22 │
│        2 │    8 │   8 │
│        2 │    9 │  17 │
│        2 │   10 │  27 │
│        2 │   11 │  38 │
│        3 │   12 │  12 │
│        3 │   13 │  25 │
│        3 │   14 │  39 │
└──────────┴──────┴─────┘
```

As you can see, `runningAccumulate` merges states for each group of rows separately.

## joinGet

The function lets you extract data from the table the same way as from a dictionary.

Gets data from Join tables using the specified join key.

Only supports tables created with the `ENGINE = Join(ANY, LEFT, <join_keys>)` statement.

**Syntax**

```
joinGet(join_storage_table_name, `value_column`, join_keys)
```

**Arguments**

- `join_storage_table_name` — an identifier indicates where search is performed. The identifier is searched in the default database (see parameter `default_database` in the config file). To override the default database, use the `USE db_name` or specify the database and the table through the separator `db_name.db_table`, see the example.
- `value_column` — name of the column of the table that contains required data.
- `join_keys` — list of keys.

**Returned value**

Returns list of values corresponded to list of keys.

If certain does not exist in source table then `0` or `null` will be returned based on [join_use_nulls setting.

More info about `join_use_nulls` in Join operation.

**Example**

Input table:

```
CREATE DATABASE db_test
CREATE TABLE db_test.id_val(`id` UInt32, `val` UInt32) ENGINE = Join(ANY, LEFT, id) SETTINGS join_use_nulls = 1
INSERT INTO db_test.id_val VALUES (1,11)(2,12)(4,13)
┌─id─┬─val─┐
│  4 │  13 │
│  2 │  12 │
│  1 │  11 │
└────┴─────┘
```

Query:

```
SELECT joinGet(db_test.id_val,val,toUInt32(number)) from numbers(4) SETTINGS join_use_nulls = 1
```

Result:

```
┌─joinGet(db_test.id_val, val, toUInt32(number))─┐
│                                                0 │
│                                               11 │
│                                               12 │
│                                                0 │
└──────────────────────────────────────────────────┘
```

## modelEvaluate(model_name, …)

Evaluate external model.
Accepts a model name and model arguments. Returns Float64.

## throwIf(x[, custom_message])

Throw an exception if the argument is non zero.
custom_message - is an optional parameter: a constant string, provides an error message

```
SELECT throwIf(number = 3, Too many) FROM numbers(10);
↙ Progress: 0.00 rows, 0.00 B (0.00 rows/s., 0.00 B/s.) Received exception from server (version 19.14.1):
Code: 395. DB::Exception: Received from localhost:9000. DB::Exception: Too many.
```

## identity

Returns the same value that was used as its argument. Used for debugging and testing, allows to cancel using index, and get the query performance of a full scan. When query is analyzed for possible use of index, the analyzer does not look inside `identity` functions. Also constant folding is not applied too.

**Syntax**

```
identity(x)
```

**Example**

Query:

```
SELECT identity(42)
```

Result:

```
┌─identity(42)─┐
│           42 │
└──────────────┘
```

## randomPrintableASCII

Generates a string with a random set of ASCII printable characters.

**Syntax**

```
randomPrintableASCII(length)
```

**Arguments**

- ```
  length
  ```



  — Resulting string length. Positive integer.

  ```
  If you pass `length < 0`, behavior of the function is undefined.
  ```

**Returned value**

- String with a random set of ASCII] printable characters.

Type: String

**Example**

```
SELECT number, randomPrintableASCII(30) as str, length(str) FROM system.numbers LIMIT 3
┌─number─┬─str────────────────────────────┬─length(randomPrintableASCII(30))─┐
│      0 │ SuiCOSTvC0csfABSw=UcSzp2.`rv8x │                               30 │
│      1 │ 1Ag NlJ &RCN:*>HVPG;PE-nO"SUFD │                               30 │
│      2 │ /"+<"wUTh:=LjJ Vm!c&hI*m#XTfzz │                               30 │
└────────┴────────────────────────────────┴──────────────────────────────────┘
```

## randomString

Generates a binary string of the specified length filled with random bytes (including zero bytes).

**Syntax**

```
randomString(length)
```

**Arguments**

- `length` — String length. Positive integer.

**Returned value**

- String filled with random bytes.

Type: String.

**Example**

Query:

```
SELECT randomString(30) AS str, length(str) AS len FROM numbers(2) FORMAT Vertical;
```

Result:

```
Row 1:
──────

str: 3 G  :   pT ?w тi  k aV f6
len: 30

Row 2:
──────
str: 9 ,]    ^   )  ]??  8
len: 30
```

**See Also**

- generateRandom

  randomPrintableASCII

## randomFixedString[ ](https://clickhouse.tech/docs/en/sql-reference/functions/other-functions/#randomfixedstring)

Generates a binary string of the specified length filled with random bytes (including zero bytes).

**Syntax**

```
randomFixedString(length);
```

**Arguments**

- `length` — String length in bytes.UInt64.

**Returned value(s)**

- String filled with random bytes.

Type: FixedString

**Example**

Query:

```
SELECT randomFixedString(13) as rnd, toTypeName(rnd)
```

Result:

```
┌─rnd──────┬─toTypeName(randomFixedString(13))─┐
│ j▒h㋖HɨZ▒ │ FixedString(13)                 │
└──────────┴───────────────────────────────────┘
```

## randomStringUTF8

Generates a random string of a specified length. Result string contains valid UTF-8 code points. The value of code points may be outside of the range of assigned Unicode.

**Syntax**

```
randomStringUTF8(length);
```

**Arguments**

- `length` — Required length of the resulting string in code points. UInt64

**Returned value(s)**

- UTF-8 random string.

Type:string

**Example**

Query:

```
SELECT randomStringUTF8(13)
```

Result:

```
┌─randomStringUTF8(13)─┐
│ д兠庇   │
└──────────────────────┘
```

## getSetting

Returns the current value of a custom String

**Syntax**

```
getSetting(custom_setting);
```

**Parameter**

- `custom_setting` — The setting name. String

**Returned value**

- The setting current value.

**Example**

```
SET custom_a = 123;
SELECT getSetting(custom_a);
```

**Result**

```
123
```

**See Also**

- Custom Settings

## isDecimalOverflow

Checks whether the Decimal value is out of its (or specified) precision.

**Syntax**

```
isDecimalOverflow(d, [p])
```

**Arguments**

- `d` — value. Decimal
- `p` — precision. Optional. If omitted, the initial precision of the first argument is used. Using of this paratemer could be helpful for data extraction to another DBMS or file.UInt8.

**Returned values**

- `1` — Decimal value has more digits then its precision allow,
- `0` — Decimal value satisfies the specified precision.

**Example**

Query:

```
SELECT isDecimalOverflow(toDecimal32(10, 0), 9),
       isDecimalOverflow(toDecimal32(10, 0)),
       isDecimalOverflow(toDecimal32(-10, 0), 9),
       isDecimalOverflow(toDecimal32(-10, 0));
```

Result:

```
1   1   1   1
```

## countDigits

Returns number of decimal digits you need to represent the value.

**Syntax**

```
countDigits(x)
```

**Arguments**

- `x` — Int or Decimal value.

**Returned value**

Number of digits.

Type: UInt8.

!!! note "Note"
For `Decimal` values takes into account their scales: calculates result over underlying integer type which is `(value * scale)`. For example: `countDigits(42) = 2`, `countDigits(42.000) = 5`, `countDigits(0.04200) = 4`. I.e. you may check decimal overflow for `Decimal64` with `countDecimal(x) > 18`. Its a slow variant of isDecimalOverflow.

**Example**

Query:

```
SELECT countDigits(toDecimal32(1, 9)), countDigits(toDecimal32(-1, 9)),
       countDigits(toDecimal64(1, 18)), countDigits(toDecimal64(-1, 18)),
       countDigits(toDecimal128(1, 38)), countDigits(toDecimal128(-1, 38));
```

Result:

```
10  10  19  19  39  39
```

## errorCodeToName

**Returned value**

- Variable name for the error code.

Type: LowCardinality(String).

**Syntax**

```
errorCodeToName(1)
```

Result:

```
UNSUPPORTED_METHOD
```

## tcpPort[ ](https://clickhouse.tech/docs/en/sql-reference/functions/other-functions/#tcpPort)

Returns native interface TCP port number listened by this server.

**Syntax**

```
tcpPort()
```

**Arguments**

- None.

**Returned value**

- The TCP port number.

Type: UInt16

**Example**

Query:

```
SELECT tcpPort();
```

Result:

```
┌─tcpPort()─┐
│      9000 │
└───────────┘
```

' where id=35;


update biz_data_query_model_help_content set content_en = '# Functions for Working with Yandex.Metrica Dictionaries

In order for the functions below to work, the server config must specify the paths and addresses for getting all the Yandex.Metrica dictionaries. The dictionaries are loaded at the first call of any of these functions. If the reference lists can’t be loaded, an exception is thrown.

For information about creating reference lists, see the section “Dictionaries”.

## Multiple Geobases

ClickHouse supports working with multiple alternative geobases (regional hierarchies) simultaneously, in order to support various perspectives on which countries certain regions belong to.

The ‘clickhouse-server’ config specifies the file with the regional hierarchy::`<path_to_regions_hierarchy_file>/opt/geo/regions_hierarchy.txt</path_to_regions_hierarchy_file>`

Besides this file, it also searches for files nearby that have the _ symbol and any suffix appended to the name (before the file extension).
For example, it will also find the file `/opt/geo/regions_hierarchy_ua.txt`, if present.

`ua` is called the dictionary key. For a dictionary without a suffix, the key is an empty string.

All the dictionaries are re-loaded in runtime (once every certain number of seconds, as defined in the builtin_dictionaries_reload_interval config parameter, or once an hour by default). However, the list of available dictionaries is defined one time, when the server starts.

All functions for working with regions have an optional argument at the end – the dictionary key. It is referred to as the geobase.
Example:

```
regionToCountry(RegionID) – Uses the default dictionary: /opt/geo/regions_hierarchy.txt
regionToCountry(RegionID, ) – Uses the default dictionary: /opt/geo/regions_hierarchy.txt
regionToCountry(RegionID, ua) – Uses the dictionary for the ua key: /opt/geo/regions_hierarchy_ua.txt
```

### regionToCity(id[, geobase])

Accepts a UInt32 number – the region ID from the Yandex geobase. If this region is a city or part of a city, it returns the region ID for the appropriate city. Otherwise, returns 0.

### regionToArea(id[, geobase])

Converts a region to an area (type 5 in the geobase). In every other way, this function is the same as ‘regionToCity’.

```
SELECT DISTINCT regionToName(regionToArea(toUInt32(number), ua))
FROM system.numbers
LIMIT 15
┌─regionToName(regionToArea(toUInt32(number), \ua\))─┐
│                                                      │
│ Moscow and Moscow region                             │
│ St. Petersburg and Leningrad region                  │
│ Belgorod region                                      │
│ Ivanovsk region                                      │
│ Kaluga region                                        │
│ Kostroma region                                      │
│ Kursk region                                         │
│ Lipetsk region                                       │
│ Orlov region                                         │
│ Ryazan region                                        │
│ Smolensk region                                      │
│ Tambov region                                        │
│ Tver region                                          │
│ Tula region                                          │
└──────────────────────────────────────────────────────┘
```

### regionToDistrict(id[, geobase])[ ](https://clickhouse.tech/docs/en/sql-reference/functions/ym-dict-functions/#regiontodistrictid-geobase)

Converts a region to a federal district (type 4 in the geobase). In every other way, this function is the same as ‘regionToCity’.

```
SELECT DISTINCT regionToName(regionToDistrict(toUInt32(number), ua))
FROM system.numbers
LIMIT 15
┌─regionToName(regionToDistrict(toUInt32(number), \ua\))─┐
│                                                          │
│ Central federal district                                 │
│ Northwest federal district                               │
│ South federal district                                   │
│ North Caucases federal district                          │
│ Privolga federal district                                │
│ Ural federal district                                    │
│ Siberian federal district                                │
│ Far East federal district                                │
│ Scotland                                                 │
│ Faroe Islands                                            │
│ Flemish region                                           │
│ Brussels capital region                                  │
│ Wallonia                                                 │
│ Federation of Bosnia and Herzegovina                     │
└──────────────────────────────────────────────────────────┘
```

### regionToCountry(id[, geobase])

Converts a region to a country. In every other way, this function is the same as ‘regionToCity’.
Example: `regionToCountry(toUInt32(213)) = 225` converts Moscow (213) to Russia (225).

### regionToContinent(id[, geobase])

Converts a region to a continent. In every other way, this function is the same as ‘regionToCity’.
Example: `regionToContinent(toUInt32(213)) = 10001` converts Moscow (213) to Eurasia (10001).

### regionToTopContinent (#regiontotopcontinent)

Finds the highest continent in the hierarchy for the region.

**Syntax**

```
regionToTopContinent(id[, geobase])
```

**Arguments**

- `id` — Region ID from the Yandex geobase. [UInt32
- `geobase` — Dictionary key. See Multiple Geobases. String. Optional.

**Returned value**

- Identifier of the top level continent (the latter when you climb the hierarchy of regions).
- 0, if there is none.

Type: `UInt32`.

### regionToPopulation(id[, geobase])

Gets the population for a region.
The population can be recorded in files with the geobase. See the section “External dictionaries”.
If the population is not recorded for the region, it returns 0.
In the Yandex geobase, the population might be recorded for child regions, but not for parent regions.

### regionIn(lhs, rhs[, geobase])

Checks whether a ‘lhs’ region belongs to a ‘rhs’ region. Returns a UInt8 number equal to 1 if it belongs, or 0 if it does not belong.
The relationship is reflexive – any region also belongs to itself.

### regionHierarchy(id[, geobase])

Accepts a UInt32 number – the region ID from the Yandex geobase. Returns an array of region IDs consisting of the passed region and all parents along the chain.
Example: `regionHierarchy(toUInt32(213)) = [213,1,3,225,10001,1]`.

### regionToName(id[, lang])

Accepts a UInt32 number – the region ID from the Yandex geobase. A string with the name of the language can be passed as a second argument. Supported languages are: ru, en, ua, uk, by, kz, tr. If the second argument is omitted, the language ‘ru’ is used. If the language is not supported, an exception is thrown. Returns a string – the name of the region in the corresponding language. If the region with the specified ID does not exist, an empty string is returned.

`ua` and `uk` both mean Ukrainian.

' where id=36;
update biz_data_query_model_help_content set content_en = '# Rounding Functions

## floor(x[, N])

Returns the largest round number that is less than or equal to `x`. A round number is a multiple of 1/10N, or the nearest number of the appropriate data type if 1 / 10N isn’t exact.
‘N’ is an integer constant, optional parameter. By default it is zero, which means to round to an integer.
‘N’ may be negative.

Examples: `floor(123.45, 1) = 123.4, floor(123.45, -1) = 120.`

`x` is any numeric type. The result is a number of the same type.
For integer arguments, it makes sense to round with a negative `N` value (for non-negative `N`, the function does not do anything).
If rounding causes overflow (for example, floor(-128, -1)), an implementation-specific result is returned.

## ceil(x[, N]), ceiling(x[, N])

Returns the smallest round number that is greater than or equal to `x`. In every other way, it is the same as the `floor` function (see above).

## trunc(x[, N]), truncate(x[, N])

Returns the round number with largest absolute value that has an absolute value less than or equal to `x`‘s. In every other way, it is the same as the ’floor’ function (see above).

## round(x[, N])

Rounds a value to a specified number of decimal places.

The function returns the nearest number of the specified order. In case when given number has equal distance to surrounding numbers, the function uses banker’s rounding for float number types and rounds away from zero for the other number types.

```
round(expression [, decimal_places])
```

**Arguments**

- `expression` — A number to be rounded. Can be any expression returning the numeric data type.

- ```
  decimal-places
  ```



  — An integer value.

  - If `decimal-places > 0` then the function rounds the value to the right of the decimal point.
  - If `decimal-places < 0` then the function rounds the value to the left of the decimal point.
  - If `decimal-places = 0` then the function rounds the value to integer. In this case the argument can be omitted.

**Returned value:**

The rounded number of the same type as the input number.

### Examples

**Example of use**

```
SELECT number / 2 AS x, round(x) FROM system.numbers LIMIT 3
┌───x─┬─round(divide(number, 2))─┐
│   0 │                        0 │
│ 0.5 │                        0 │
│   1 │                        1 │
└─────┴──────────────────────────┘
```

**Examples of rounding**

Rounding to the nearest number.

```
round(3.2, 0) = 3
round(4.1267, 2) = 4.13
round(22,-1) = 20
round(467,-2) = 500
round(-467,-2) = -500
```

Banker’s rounding.

```
round(3.5) = 4
round(4.5) = 4
round(3.55, 1) = 3.6
round(3.65, 1) = 3.6
```

**See Also**

- roundBankers

## roundBankers

Rounds a number to a specified decimal position.

- If the rounding number is halfway between two numbers, the function uses banker’s rounding.

  ```
  Bankers rounding is a method of rounding fractional numbers. When the rounding number is halfway between two numbers, its rounded to the nearest even digit at the specified decimal position. For example: 3.5 rounds up to 4, 2.5 rounds down to 2.

  Its the default rounding method for floating point numbers defined in [IEEE 754](https://en.wikipedia.org/wiki/IEEE_754#Roundings_to_nearest). The [round](#rounding_functions-round) function performs the same rounding for floating point numbers. The `roundBankers` function also rounds integers the same way, for example, `roundBankers(45, -1) = 40`.
  ```

- In other cases, the function rounds numbers to the nearest integer.

Using banker’s rounding, you can reduce the effect that rounding numbers has on the results of summing or subtracting these numbers.

For example, sum numbers 1.5, 2.5, 3.5, 4.5 with different rounding:

- No rounding: 1.5 + 2.5 + 3.5 + 4.5 = 12.
- Banker’s rounding: 2 + 2 + 4 + 4 = 12.
- Rounding to the nearest integer: 2 + 3 + 4 + 5 = 14.

**Syntax**

```
roundBankers(expression [, decimal_places])
```

**Arguments**

- `expression` — A number to be rounded. Can be any expression returning the numeric data type.

- ```
  decimal-places
  ```

  — Decimal places. An integer number.

  - `decimal-places > 0` — The function rounds the number to the given position right of the decimal point. Example: `roundBankers(3.55, 1) = 3.6`.
  - `decimal-places < 0` — The function rounds the number to the given position left of the decimal point. Example: `roundBankers(24.55, -1) = 20`.
  - `decimal-places = 0` — The function rounds the number to an integer. In this case the argument can be omitted. Example: `roundBankers(2.5) = 2`.

**Returned value**

A value rounded by the banker’s rounding method.

### Examples

**Example of use**

Query:

```
 SELECT number / 2 AS x, roundBankers(x, 0) AS b fROM system.numbers limit 10
```

Result:

```
┌───x─┬─b─┐
│   0 │ 0 │
│ 0.5 │ 0 │
│   1 │ 1 │
│ 1.5 │ 2 │
│   2 │ 2 │
│ 2.5 │ 2 │
│   3 │ 3 │
│ 3.5 │ 4 │
│   4 │ 4 │
│ 4.5 │ 4 │
└─────┴───┘
```

**Examples of Banker’s rounding**

```
roundBankers(0.4) = 0
roundBankers(-3.5) = -4
roundBankers(4.5) = 4
roundBankers(3.55, 1) = 3.6
roundBankers(3.65, 1) = 3.6
roundBankers(10.35, 1) = 10.4
roundBankers(10.755, 2) = 11,76
```

**See Also**

- round

## roundToExp2(num)

Accepts a number. If the number is less than one, it returns 0. Otherwise, it rounds the number down to the nearest (whole non-negative) degree of two.

## roundDuration(num)

Accepts a number. If the number is less than one, it returns 0. Otherwise, it rounds the number down to numbers from the set: 1, 10, 30, 60, 120, 180, 240, 300, 600, 1200, 1800, 3600, 7200, 18000, 36000. This function is specific to Yandex.Metrica and used for implementing the report on session length.

## roundAge(num)

Accepts a number. If the number is less than 18, it returns 0. Otherwise, it rounds the number down to a number from the set: 18, 25, 35, 45, 55. This function is specific to Yandex.Metrica and used for implementing the report on user age.

## roundDown(num, arr)

Accepts a number and rounds it down to an element in the specified array. If the value is less than the lowest bound, the lowest bound is returned.

' where id=37;
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
(0,2019-05-20)        0       \N      \N      (NULL,NULL)(1,2019-05-20)        1       First   First   (First,First)(2,2019-05-20)        0       \N      \N      (NULL,NULL)(3,2019-05-20)        0       \N      \N      (NULL,NULL)(4,2019-05-20)        0       \N      \N      (NULL,NULL)
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
┌─id─┬─parent_id─┐│  1 │         0 ││  2 │         1 ││  3 │         1 ││  4 │         2 │└────┴───────────┘
```

First-level children:

```
SELECT dictGetChildren(hierarchy_flat_dictionary, number) FROM system.numbers LIMIT 4;┌─dictGetChildren(hierarchy_flat_dictionary, number)─┐│ [1]                                                  ││ [2,3]                                                ││ [4]                                                  ││ []                                                   │└──────────────────────────────────────────────────────┘
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
┌─id─┬─parent_id─┐│  1 │         0 ││  2 │         1 ││  3 │         1 ││  4 │         2 │└────┴───────────┘
```

All descendants:

```
SELECT dictGetDescendants(hierarchy_flat_dictionary, number) FROM system.numbers LIMIT 4;┌─dictGetDescendants(hierarchy_flat_dictionary, number)─┐│ [1,2,3,4]                                               ││ [2,3,4]                                                 ││ [4]                                                     ││ []                                                      │└─────────────────────────────────────────────────────────┘
```

First-level descendants:

```
SELECT dictGetDescendants(hierarchy_flat_dictionary, number, 1) FROM system.numbers LIMIT 4;┌─dictGetDescendants(hierarchy_flat_dictionary, number, 1)─┐│ [1]                                                        ││ [2,3]                                                      ││ [4]                                                        ││ []                                                         │└────────────────────────────────────────────────────────────┘
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
update biz_data_query_model_help_content set content_en = '# Functions for Working with Strings

Note

Functions for searching and replacing in strings are described separately.

## empty

Returns 1 for an empty string or 0 for a non-empty string.
The result type is UInt8.
A string is considered non-empty if it contains at least one byte, even if this is a space or a null byte.
The function also works for arrays.

## notEmpty

Returns 0 for an empty string or 1 for a non-empty string.
The result type is UInt8.
The function also works for arrays.

## length

Returns the length of a string in bytes (not in characters, and not in code points).
The result type is UInt64.
The function also works for arrays.

## lengthUTF8

Returns the length of a string in Unicode code points (not in characters), assuming that the string contains a set of bytes that make up UTF-8 encoded text. If this assumption is not met, it returns some result (it does not throw an exception).
The result type is UInt64.

## char_length, CHAR_LENGTH

Returns the length of a string in Unicode code points (not in characters), assuming that the string contains a set of bytes that make up UTF-8 encoded text. If this assumption is not met, it returns some result (it does not throw an exception).
The result type is UInt64.

## character_length, CHARACTER_LENGTH

Returns the length of a string in Unicode code points (not in characters), assuming that the string contains a set of bytes that make up UTF-8 encoded text. If this assumption is not met, it returns some result (it does not throw an exception).
The result type is UInt64.

## lower, lcase

Converts ASCII Latin symbols in a string to lowercase.

## upper, ucase

Converts ASCII Latin symbols in a string to uppercase.

## lowerUTF8

Converts a string to lowercase, assuming the string contains a set of bytes that make up a UTF-8 encoded text.
It does not detect the language. So for Turkish the result might not be exactly correct.
If the length of the UTF-8 byte sequence is different for upper and lower case of a code point, the result may be incorrect for this code point.
If the string contains a set of bytes that is not UTF-8, then the behavior is undefined.

## upperUTF8

Converts a string to uppercase, assuming the string contains a set of bytes that make up a UTF-8 encoded text.
It does not detect the language. So for Turkish the result might not be exactly correct.
If the length of the UTF-8 byte sequence is different for upper and lower case of a code point, the result may be incorrect for this code point.
If the string contains a set of bytes that is not UTF-8, then the behavior is undefined.

## isValidUTF8

Returns 1, if the set of bytes is valid UTF-8 encoded, otherwise 0.

## toValidUTF8

Replaces invalid UTF-8 characters by the `�` (U+FFFD) character. All running in a row invalid characters are collapsed into the one replacement character.

```
toValidUTF8(input_string)
```

**Arguments**

- `input_string` — Any set of bytes represented as the String data type object.

Returned value: Valid UTF-8 string.

**Example**

```
SELECT toValidUTF8(\x61\xF0\x80\x80\x80b);
┌─toValidUTF8(a����b)─┐
│ a�b                   │
└───────────────────────┘
```

## repeat

Repeats a string as many times as specified and concatenates the replicated values as a single string.

Alias: `REPEAT`.

**Syntax**

```
repeat(s, n)
```

**Arguments**

- `s` — The string to repeat. String.
- `n` — The number of times to repeat the string. UInt.

**Returned value**

The single string, which contains the string `s` repeated `n` times. If `n` \< 1, the function returns empty string.

Type: `String`.

**Example**

Query:

```
SELECT repeat(abc, 10);
```

Result:

```
┌─repeat(abc, 10)──────────────┐
│ abcabcabcabcabcabcabcabcabcabc │
└────────────────────────────────┘
```

## reverse

Reverses the string (as a sequence of bytes).

## reverseUTF8

Reverses a sequence of Unicode code points, assuming that the string contains a set of bytes representing a UTF-8 text. Otherwise, it does something else (it does not throw an exception).

## format(pattern, s0, s1, …)

Formatting constant pattern with the string listed in the arguments. `pattern` is a simplified Python format pattern. Format string contains “replacement fields” surrounded by curly braces `{}`. Anything that is not contained in braces is considered literal text, which is copied unchanged to the output. If you need to include a brace character in the literal text, it can be escaped by doubling: `{{` and `}}`. Field names can be numbers (starting from zero) or empty (then they are treated as consequence numbers).

```
SELECT format({1} {0} {1}, World, Hello)
┌─format({1} {0} {1}, World, Hello)─┐
│ Hello World Hello                       │
└─────────────────────────────────────────┘
SELECT format({} {}, Hello, World)
┌─format({} {}, Hello, World)─┐
│ Hello World                       │
└───────────────────────────────────┘
```

## concat

Concatenates the strings listed in the arguments, without a separator.

**Syntax**

```
concat(s1, s2, ...)
```

**Arguments**

Values of type String or FixedString.

**Returned values**

Returns the String that results from concatenating the arguments.

If any of argument values is `NULL`, `concat` returns `NULL`.

**Example**

Query:

```
SELECT concat(Hello, , World!);
```

Result:

```
┌─concat(Hello, , World!)─┐
│ Hello, World!               │
└─────────────────────────────┘
```

## concatAssumeInjective

Same as concat, the difference is that you need to ensure that `concat(s1, s2, ...) → sn` is injective, it will be used for optimization of GROUP BY.

The function is named “injective” if it always returns different result for different values of arguments. In other words: different arguments never yield identical result.

**Syntax**

```
concatAssumeInjective(s1, s2, ...)
```

**Arguments**

Values of type String or FixedString.

**Returned values**

Returns the String that results from concatenating the arguments.

If any of argument values is `NULL`, `concatAssumeInjective` returns `NULL`.

**Example**

Input table:

```
CREATE TABLE key_val(`key1` String, `key2` String, `value` UInt32) ENGINE = TinyLog;
INSERT INTO key_val VALUES (Hello, ,World,1), (Hello, ,World,2), (Hello, ,World!,3), (Hello,, World!,2);
SELECT * from key_val;
┌─key1────┬─key2─────┬─value─┐
│ Hello,  │ World    │     1 │
│ Hello,  │ World    │     2 │
│ Hello,  │ World!   │     3 │
│ Hello   │ , World! │     2 │
└─────────┴──────────┴───────┘
```

Query:

```
SELECT concat(key1, key2), sum(value) FROM key_val GROUP BY concatAssumeInjective(key1, key2);
```

Result:

```
┌─concat(key1, key2)─┬─sum(value)─┐
│ Hello, World!      │          3 │
│ Hello, World!      │          2 │
│ Hello, World       │          3 │
└────────────────────┴────────────┘
```

## substring(s, offset, length), mid(s, offset, length), substr(s, offset, length)

Returns a substring starting with the byte from the ‘offset’ index that is ‘length’ bytes long. Character indexing starts from one (as in standard SQL). The ‘offset’ and ‘length’ arguments must be constants.

## substringUTF8(s, offset, length)

The same as ‘substring’, but for Unicode code points. Works under the assumption that the string contains a set of bytes representing a UTF-8 encoded text. If this assumption is not met, it returns some result (it does not throw an exception).

## appendTrailingCharIfAbsent(s, c)

If the ‘s’ string is non-empty and does not contain the ‘c’ character at the end, it appends the ‘c’ character to the end.

## convertCharset(s, from, to)

Returns the string ‘s’ that was converted from the encoding in ‘from’ to the encoding in ‘to’.

## base64Encode(s)

Encodes ‘s’ string into base64

Alias: `TO_BASE64`.

## base64Decode(s)

Decode base64-encoded string ‘s’ into original string. In case of failure raises an exception.

Alias: `FROM_BASE64`.

## tryBase64Decode(s)

Similar to base64Decode, but in case of error an empty string would be returned.

## endsWith(s, suffix)

Returns whether to end with the specified suffix. Returns 1 if the string ends with the specified suffix, otherwise it returns 0.

## startsWith(str, prefix)

Returns 1 whether string starts with the specified prefix, otherwise it returns 0.

```
SELECT startsWith(Spider-Man, Spi);
```

**Returned values**

- 1, if the string starts with the specified prefix.
- 0, if the string does not start with the specified prefix.

**Example**

Query:

```
SELECT startsWith(Hello, world!, He);
```

Result:

```
┌─startsWith(Hello, world!, He)─┐
│                                 1 │
└───────────────────────────────────┘
```

## trim[ ](https://clickhouse.tech/docs/en/sql-reference/functions/string-functions/#trim)

Removes all specified characters from the start or end of a string.
By default removes all consecutive occurrences of common whitespace (ASCII character 32) from both ends of a string.

**Syntax**

```
trim([[LEADING|TRAILING|BOTH] trim_character FROM] input_string)
```

**Arguments**

- `trim_character` — Specified characters for trim. String.
- `input_string` — String for trim. String.

**Returned value**

A string without leading and (or) trailing specified characters.

Type: `String`.

**Example**

Query:

```
SELECT trim(BOTH  () FROM (   Hello, world!   ));
```

Result:

```
┌─trim(BOTH  () FROM (   Hello, world!   ))─┐
│ Hello, world!                                 │
└───────────────────────────────────────────────┘
```

## trimLeft

Removes all consecutive occurrences of common whitespace (ASCII character 32) from the beginning of a string. It does not remove other kinds of whitespace characters (tab, no-break space, etc.).

**Syntax**

```
trimLeft(input_string)
```

Alias: `ltrim(input_string)`.

**Arguments**

- `input_string` — string to trim. String.

**Returned value**

A string without leading common whitespaces.

Type: `String`.

**Example**

Query:

```
SELECT trimLeft(     Hello, world!     );
```

Result:

```
┌─trimLeft(     Hello, world!     )─┐
│ Hello, world!                       │
└─────────────────────────────────────┘
```

## trimRight

Removes all consecutive occurrences of common whitespace (ASCII character 32) from the end of a string. It does not remove other kinds of whitespace characters (tab, no-break space, etc.).

**Syntax**

```
trimRight(input_string)
```

Alias: `rtrim(input_string)`.

**Arguments**

- `input_string` — string to trim. String.

**Returned value**

A string without trailing common whitespaces.

Type: `String`.

**Example**

Query:

```
SELECT trimRight(     Hello, world!     );
```

Result:

```
┌─trimRight(     Hello, world!     )─┐
│      Hello, world!                   │
└──────────────────────────────────────┘
```

## trimBoth

Removes all consecutive occurrences of common whitespace (ASCII character 32) from both ends of a string. It does not remove other kinds of whitespace characters (tab, no-break space, etc.).

**Syntax**

```
trimBoth(input_string)
```

Alias: `trim(input_string)`.

**Arguments**

- `input_string` — string to trim. String.

**Returned value**

A string without leading and trailing common whitespaces.

Type: `String`.

**Example**

Query:

```
SELECT trimBoth(     Hello, world!     );
```

Result:

```
┌─trimBoth(     Hello, world!     )─┐
│ Hello, world!                       │
└─────────────────────────────────────┘
```

## CRC32(s)

Returns the CRC32 checksum of a string, using CRC-32-IEEE 802.3 polynomial and initial value `0xffffffff` (zlib implementation).

The result type is UInt32.

## CRC32IEEE(s)

Returns the CRC32 checksum of a string, using CRC-32-IEEE 802.3 polynomial.

The result type is UInt32.

## CRC64(s)

Returns the CRC64 checksum of a string, using CRC-64-ECMA polynomial.

The result type is UInt64.

## normalizeQuery

Replaces literals, sequences of literals and complex aliases with placeholders.

**Syntax**

```
normalizeQuery(x)
```

**Arguments**

- `x` — Sequence of characters.

**Returned value**

- Sequence of characters with placeholders.

Type: String.

**Example**

Query:

```
SELECT normalizeQuery([1, 2, 3, x]) AS query;
```

Result:

```
┌─query────┐
│ [?.., x] │
└──────────┘
```

## normalizedQueryHash

Returns identical 64bit hash values without the values of literals for similar queries. It helps to analyze query log.

**Syntax**

```
normalizedQueryHash(x)
```

**Arguments**

- `x` — Sequence of characters. String.

**Returned value**

- Hash value.

Type: UInt64.

**Example**

Query:

```
SELECT normalizedQueryHash(SELECT 1 AS `xyz`) != normalizedQueryHash(SELECT 1 AS `abc`) AS res;
```

Result:

```
┌─res─┐
│   1 │
└─────┘
```

## encodeXMLComponent

Escapes characters to place string into XML text node or attribute.

The following five XML predefined entities will be replaced: `<`, `&`, `>`, `"`, ``.

**Syntax**

```
encodeXMLComponent(x)
```

**Arguments**

- `x` — The sequence of characters. String

**Returned value**

- The sequence of characters with escape characters.

Type: String.

**Example**

Query:

```
SELECT encodeXMLComponent(Hello, "world"!);
SELECT encodeXMLComponent(<123>);
SELECT encodeXMLComponent(&clickhouse);
SELECT encodeXMLComponent(\foo\);
```

Result:

```
Hello, &quot;world&quot;!
&lt;123&gt;
&amp;clickhouse
&apos;foo&apos;
```

## decodeXMLComponent

Replaces XML predefined entities with characters. Predefined entities are `"` `&` `` `>` `<`
This function also replaces numeric character references with Unicode characters. Both decimal (like `✓`) and hexadecimal (`✓`) forms are supported.

**Syntax**

```
decodeXMLComponent(x)
```

**Arguments**

- `x` — A sequence of characters.String.

**Returned value**

- The sequence of characters after replacement.

Type: String.

**Example**

Query:

```
SELECT decodeXMLComponent(&apos;foo&apos;);
SELECT decodeXMLComponent(&lt; &#x3A3; &gt;);
```

Result:

```
foo
< Σ >
```

**See Also**

- List of XML and HTML character entity references

## extractTextFromHTML

A function to extract text from HTML or XHTML.
It does not necessarily 100% conform to any of the HTML, XML or XHTML standards, but the implementation is reasonably accurate and it is fast. The rules are the following:

1. Comments are skipped. Example: `<!-- test -->`. Comment must end with `-->`. Nested comments are not possible.
   Note: constructions like `<!-->` and `<!--->` are not valid comments in HTML but they are skipped by other rules.
2. CDATA is pasted verbatim. Note: CDATA is XML/XHTML specific. But it is processed for "best-effort" approach.
3. `script` and `style` elements are removed with all their content. Note: it is assumed that closing tag cannot appear inside content. For example, in JS string literal has to be escaped like `"<\/script>"`.
   Note: comments and CDATA are possible inside `script` or `style` - then closing tags are not searched inside CDATA. Example: `<script><![CDATA[</script>]]></script>`. But they are still searched inside comments. Sometimes it becomes complicated: `<script>var x = "<!--"; </script> var y = "-->"; alert(x + y);</script>`
   Note: `script` and `style` can be the names of XML namespaces - then they are not treated like usual `script` or `style` elements. Example: `<script:a>Hello</script:a>`.
   Note: whitespaces are possible after closing tag name: `</script >` but not before: `< / script>`.
4. Other tags or tag-like elements are skipped without inner content. Example: `<a>.</a>`
   Note: it is expected that this HTML is illegal: `<a test=">"></a>`
   Note: it also skips something like tags: `<>`, `<!---->`, etc.
   Note: tag without end is skipped to the end of input: `<hello`
5. HTML and XML entities are not decoded. They must be processed by separate function.
6. Whitespaces in the text are collapsed or inserted by specific rules.
   - Whitespaces at the beginning and at the end are removed.
   - Consecutive whitespaces are collapsed.
   - But if the text is separated by other elements and there is no whitespace, it is inserted.
   - It may cause unnatural examples: `Hello<b>world</b>`, `Hello<!-- -->world` - there is no whitespace in HTML, but the function inserts it. Also consider: `Hello<p>world</p>`, `Hello<br>world`. This behavior is reasonable for data analysis, e.g. to convert HTML to a bag of words.
7. Also note that correct handling of whitespaces requires the support of `<pre></pre>` and CSS `display` and `white-space` properties.

**Syntax**

```
extractTextFromHTML(x)
```

**Arguments**

- `x` — input text.String.

**Returned value**

- Extracted text.

Type: String.

**Example**

The first example contains several tags and a comment and also shows whitespace processing.
The second example shows `CDATA` and `script` tag processing.
In the third example text is extracted from the full HTML response received by the [url](https://clickhouse.tech/docs/en/sql-reference/table-functions/url/) function.

Query:

```
SELECT extractTextFromHTML( <p> A text <i>with</i><b>tags</b>. <!-- comments --> </p> );
SELECT extractTextFromHTML(<![CDATA[The content within <b>CDATA</b>]]> <script>alert("Script");</script>);
SELECT extractTextFromHTML(html) FROM url(http://www.donothingfor2minutes.com/, RawBLOB, html String);
```

Result:

```
A text with tags .
The content within <b>CDATA</b>
Do Nothing for 2 Minutes 2:00 &nbsp;
```

' where id=39;
update biz_data_query_model_help_content set content_en = '# Functions for Splitting and Merging Strings and Arrays

## splitByChar(separator, s)

Splits a string into substrings separated by a specified character. It uses a constant string `separator` which consisting of exactly one character.
Returns an array of selected substrings. Empty substrings may be selected if the separator occurs at the beginning or end of the string, or if there are multiple consecutive separators.

**Syntax**

```
splitByChar(separator, s)
```

**Arguments**

- `separator` — The separator which should contain exactly one character. String
- `s` — The string to split. String

**Returned value(s)**

Returns an array of selected substrings. Empty substrings may be selected when:

- A separator occurs at the beginning or end of the string;
- There are multiple consecutive separators;
- The original string `s` is empty.

Type: Array(String).

**Example**

```
SELECT splitByChar(,, 1,2,3,abcde);
┌─splitByChar(,, 1,2,3,abcde)─┐
│ [1,2,3,abcde]           │
└─────────────────────────────────┘
```

## splitByString(separator, s)

Splits a string into substrings separated by a string. It uses a constant string `separator` of multiple characters as the separator. If the string `separator` is empty, it will split the string `s` into an array of single characters.

**Syntax**

```
splitByString(separator, s)
```

**Arguments**

- `separator` — The separator. String.
- `s` — The string to split. String.

**Returned value(s)**

Returns an array of selected substrings. Empty substrings may be selected when:

Type: Array(String).

- A non-empty separator occurs at the beginning or end of the string;
- There are multiple consecutive non-empty separators;
- The original string `s` is empty while the separator is not empty.

**Example**

```
SELECT splitByString(, , 1, 2 3, 4,5, abcde);
┌─splitByString(, , 1, 2 3, 4,5, abcde)─┐
│ [1,2 3,4,5,abcde]                 │
└───────────────────────────────────────────┘
SELECT splitByString(, abcde);
┌─splitByString(, abcde)─┐
│ [a,b,c,d,e]      │
└────────────────────────────┘
```

## splitByRegexp(regexp, s)

Splits a string into substrings separated by a regular expression. It uses a regular expression string `regexp` as the separator. If the `regexp` is empty, it will split the string `s` into an array of single characters. If no match is found for this regular expression, the string `s` wont be split.

**Syntax**

```
splitByRegexp(regexp, s)
```

**Arguments**

- `regexp` — Regular expression. Constant. String or FixedString.
- `s` — The string to split. String.

**Returned value(s)**

Returns an array of selected substrings. Empty substrings may be selected when:

- A non-empty regular expression match occurs at the beginning or end of the string;
- There are multiple consecutive non-empty regular expression matches;
- The original string `s` is empty while the regular expression is not empty.

Type: Array(String).

**Example**

Query:

```
SELECT splitByRegexp(\\d+, a12bc23de345f);
```

Result:

```
┌─splitByRegexp(\\d+, a12bc23de345f)─┐
│ [a,bc,de,f]                    │
└────────────────────────────────────────┘
```

Query:

```
SELECT splitByRegexp(, abcde);
```

Result:

```
┌─splitByRegexp(, abcde)─┐
│ [a,b,c,d,e]      │
└────────────────────────────┘
```

## arrayStringConcat(arr[, separator])

Concatenates the strings listed in the array with the separator.’separator’ is an optional parameter: a constant string, set to an empty string by default.
Returns the string.

## alphaTokens(s)

Selects substrings of consecutive bytes from the ranges a-z and A-Z.Returns an array of substrings.

**Example**

```
SELECT alphaTokens(abca1abc);
┌─alphaTokens(abca1abc)─┐
│ [abca,abc]          │
└─────────────────────────┘
```

## extractAllGroups(text, regexp)

Extracts all groups from non-overlapping substrings matched by a regular expression.

**Syntax**

```
extractAllGroups(text, regexp)
```

**Arguments**

- `text` — String or FixedString.
- `regexp` — Regular expression. Constant.  String or FixedString.

**Returned values**

- If the function finds at least one matching group, it returns `Array(Array(String))` column, clustered by group_id (1 to N, where N is number of capturing groups in `regexp`).
- If there is no matching group, returns an empty array.

Type:Array.

**Example**

Query:

```
SELECT extractAllGroups(abc=123, 8="hkl", ("[^"]+"|\\w+)=("[^"]+"|\\w+));
```

Result:

```
┌─extractAllGroups(abc=123, 8="hkl", ("[^"]+"|\\w+)=("[^"]+"|\\w+))─┐
│ [[abc,123],[8,"hkl"]]                                         │
└───────────────────────────────────────────────────────────────────────┘
```

' where id=40;



update biz_data_query_model_help_content set content_en = '# Functions for Searching in Strings

The search is case-sensitive by default in all these functions. There are separate variants for case insensitive search.

Note

Functions for replacing and other manipulations with strings are described separately.

## position(haystack, needle), locate(haystack, needle)

Searches for the substring `needle` in the string `haystack`.

Returns the position (in bytes) of the found substring in the string, starting from 1.

For a case-insensitive search, use the function positionCaseInsensitive.

**Syntax**

```
position(haystack, needle[, start_pos])
position(needle IN haystack)
```

Alias: `locate(haystack, needle[, start_pos])`.

Note

Syntax of `position(needle IN haystack)` provides SQL-compatibility, the function works the same way as to `position(haystack, needle)`.

**Arguments**

- `haystack` — String, in which substring will to be searched. String.
- `needle` — Substring to be searched.  String.
- `start_pos` – Position of the first character in the string to start search. UInt.Optional.

**Returned values**

- Starting position in bytes (counting from 1), if substring was found.
- 0, if the substring was not found.

Type: `Integer`.

**Examples**

The phrase “Hello, world!” contains a set of bytes representing a single-byte encoded text. The function returns some expected result:

Query:

```
SELECT position(Hello, world!, !);
```

Result:

```
┌─position(Hello, world!, !)─┐
│                             13 │
└────────────────────────────────┘
SELECT
    position(Hello, world!, o, 1),
    position(Hello, world!, o, 7)
┌─position(Hello, world!, o, 1)─┬─position(Hello, world!, o, 7)─┐
│                                 5 │                                 9 │
└───────────────────────────────────┴───────────────────────────────────┘
```

The same phrase in Russian contains characters which can’t be represented using a single byte. The function returns some unexpected result (use positionUTF8 function for multi-byte encoded text):

Query:

```
SELECT position(Привет, мир!, !);
```

Result:

```
┌─position(Привет, мир!, !)─┐
│                            21 │
└───────────────────────────────┘
```

**Examples for POSITION(needle IN haystack) syntax**

Query:

```
SELECT 3 = position(c IN abc);
```

Result:

```
┌─equals(3, position(abc, c))─┐
│                               1 │
└─────────────────────────────────┘
```

Query:

```
SELECT 6 = position(/ IN s) FROM (SELECT Hello/World AS s);
```

Result:

```
┌─equals(6, position(s, /))─┐
│                           1 │
└─────────────────────────────┘
```

## positionCaseInsensitive

The same as position returns the position (in bytes) of the found substring in the string, starting from 1. Use the function for a case-insensitive search.

Works under the assumption that the string contains a set of bytes representing a single-byte encoded text. If this assumption is not met and a character can’t be represented using a single byte, the function does not throw an exception and returns some unexpected result. If character can be represented using two bytes, it will use two bytes and so on.

**Syntax**

```
positionCaseInsensitive(haystack, needle[, start_pos])
```

**Arguments**

- `haystack` — String, in which substring will to be searched. String.
- `needle` — Substring to be searched. String.
- `start_pos` — Optional parameter, position of the first character in the string to start search. UInt.

**Returned values**

- Starting position in bytes (counting from 1), if substring was found.
- 0, if the substring was not found.

Type: `Integer`.

**Example**

Query:

```
SELECT positionCaseInsensitive(Hello, world!, hello);
```

Result:

```
┌─positionCaseInsensitive(Hello, world!, hello)─┐
│                                                 1 │
└───────────────────────────────────────────────────┘
```

## positionUTF8

Returns the position (in Unicode points) of the found substring in the string, starting from 1.

Works under the assumption that the string contains a set of bytes representing a UTF-8 encoded text. If this assumption is not met, the function does not throw an exception and returns some unexpected result. If character can be represented using two Unicode points, it will use two and so on.

For a case-insensitive search, use the function positionCaseInsensitiveUTF8.

**Syntax**

```
positionUTF8(haystack, needle[, start_pos])
```

**Arguments**

- `haystack` — String, in which substring will to be searched. String.
- `needle` — Substring to be searched.  String.
- `start_pos` — Optional parameter, position of the first character in the string to start search. UInt.

**Returned values**

- Starting position in Unicode points (counting from 1), if substring was found.
- 0, if the substring was not found.

Type: `Integer`.

**Examples**

The phrase “Hello, world!” in Russian contains a set of Unicode points representing a single-point encoded text. The function returns some expected result:

Query:

```
SELECT positionUTF8(Привет, мир!, !);
```

Result:

```
┌─positionUTF8(Привет, мир!, !)─┐
│                                12 │
└───────────────────────────────────┘
```

The phrase “Salut, étudiante!”, where character `é` can be represented using a one point (`U+00E9`) or two points (`U+0065U+0301`) the function can be returned some unexpected result:

Query for the letter `é`, which is represented one Unicode point `U+00E9`:

```
SELECT positionUTF8(Salut, étudiante!, !);
```

Result:

```
┌─positionUTF8(Salut, étudiante!, !)─┐
│                                     17 │
└────────────────────────────────────────┘
```

Query for the letter `é`, which is represented two Unicode points `U+0065U+0301`:

```
SELECT positionUTF8(Salut, étudiante!, !);
```

Result:

```
┌─positionUTF8(Salut, étudiante!, !)─┐
│                                     18 │
└────────────────────────────────────────┘
```

## positionCaseInsensitiveUTF8

The same as positionUTF8, but is case-insensitive. Returns the position (in Unicode points) of the found substring in the string, starting from 1.

Works under the assumption that the string contains a set of bytes representing a UTF-8 encoded text. If this assumption is not met, the function does not throw an exception and returns some unexpected result. If character can be represented using two Unicode points, it will use two and so on.

**Syntax**

```
positionCaseInsensitiveUTF8(haystack, needle[, start_pos])
```

**Arguments**

- `haystack` — String, in which substring will to be searched.  String.
- `needle` — Substring to be searched. String.
- `start_pos` — Optional parameter, position of the first character in the string to start search. UInt.

**Returned value**

- Starting position in Unicode points (counting from 1), if substring was found.
- 0, if the substring was not found.

Type: `Integer`.

**Example**

Query:

```
SELECT positionCaseInsensitiveUTF8(Привет, мир!, Мир);
```

Result:

```
┌─positionCaseInsensitiveUTF8(Привет, мир!, Мир)─┐
│                                                  9 │
└────────────────────────────────────────────────────┘
```

## multiSearchAllPositions

The same as position but returns `Array` of positions (in bytes) of the found corresponding substrings in the string. Positions are indexed starting from 1.

The search is performed on sequences of bytes without respect to string encoding and collation.

- For case-insensitive ASCII search, use the function `multiSearchAllPositionsCaseInsensitive`.
- For search in UTF-8, use the function multiSearchAllPositionsUTF8.
- For case-insensitive UTF-8 search, use the function multiSearchAllPositionsCaseInsensitiveUTF8.

**Syntax**

```
multiSearchAllPositions(haystack, [needle1, needle2, ..., needlen])
```

**Arguments**

- `haystack` — String, in which substring will to be searched. String.
- `needle` — Substring to be searched.  String.

**Returned values**

- Array of starting positions in bytes (counting from 1), if the corresponding substring was found and 0 if not found.

**Example**

Query:

```
SELECT multiSearchAllPositions(Hello, World!, [hello, !, world]);
```

Result:

```
┌─multiSearchAllPositions(Hello, World!, [hello, !, world])─┐
│ [0,13,0]                                                          │
└───────────────────────────────────────────────────────────────────┘
```

## multiSearchAllPositionsUTF8

See `multiSearchAllPositions`.

## multiSearchFirstPosition(haystack, [needle1, needle2, …, needlen])

The same as `position` but returns the leftmost offset of the string `haystack` that is matched to some of the needles.

For a case-insensitive search or/and in UTF-8 format use functions `multiSearchFirstPositionCaseInsensitive, multiSearchFirstPositionUTF8, multiSearchFirstPositionCaseInsensitiveUTF8`.

## multiSearchFirstIndex(haystack, [needle1, needle2, …, needlen])

Returns the index `i` (starting from 1) of the leftmost found needlei in the string `haystack` and 0 otherwise.

For a case-insensitive search or/and in UTF-8 format use functions `multiSearchFirstIndexCaseInsensitive, multiSearchFirstIndexUTF8, multiSearchFirstIndexCaseInsensitiveUTF8`.

## multiSearchAny(haystack, [needle1, needle2, …, needlen])

Returns 1, if at least one string needlei matches the string `haystack` and 0 otherwise.

For a case-insensitive search or/and in UTF-8 format use functions `multiSearchAnyCaseInsensitive, multiSearchAnyUTF8, multiSearchAnyCaseInsensitiveUTF8`.

Note

In all `multiSearch*` functions the number of needles should be less than 28 because of implementation specification.

## match(haystack, pattern)

Checks whether the string matches the `pattern` regular expression. A `re2` regular expression. The syntax of the `re2` regular expressions is more limited than the syntax of the Perl regular expressions.

Returns 0 if it does not match, or 1 if it matches.

Note that the backslash symbol (`\`) is used for escaping in the regular expression. The same symbol is used for escaping in string literals. So in order to escape the symbol in a regular expression, you must write two backslashes (\) in a string literal.

The regular expression works with the string as if it is a set of bytes. The regular expression can’t contain null bytes.
For patterns to search for substrings in a string, it is better to use LIKE or ‘position’, since they work much faster.

## multiMatchAny(haystack, [pattern1, pattern2, …, patternn])

The same as `match`, but returns 0 if none of the regular expressions are matched and 1 if any of the patterns matches. It uses hyperscan library. For patterns to search substrings in a string, it is better to use `multiSearchAny` since it works much faster.

Note

The length of any of the `haystack` string must be less than 232 bytes otherwise the exception is thrown. This restriction takes place because of hyperscan API.

## multiMatchAnyIndex(haystack, [pattern1, pattern2, …, patternn])

The same as `multiMatchAny`, but returns any index that matches the haystack.

## multiMatchAllIndices(haystack, [pattern1, pattern2, …, patternn])

The same as `multiMatchAny`, but returns the array of all indicies that match the haystack in any order.

## multiFuzzyMatchAny(haystack, distance, [pattern1, pattern2, …, patternn])

The same as `multiMatchAny`, but returns 1 if any pattern matches the haystack within a constant edit distance. This function is also in an experimental mode and can be extremely slow. For more information see hyperscan documentation.

## multiFuzzyMatchAnyIndex(haystack, distance, [pattern1, pattern2, …, patternn])

The same as `multiFuzzyMatchAny`, but returns any index that matches the haystack within a constant edit distance.

## multiFuzzyMatchAllIndices(haystack, distance, [pattern1, pattern2, …, patternn])

The same as `multiFuzzyMatchAny`, but returns the array of all indices in any order that match the haystack within a constant edit distance.

Note

`multiFuzzyMatch*` functions do not support UTF-8 regular expressions, and such expressions are treated as bytes because of hyperscan restriction.

Note

To turn off all functions that use hyperscan, use setting `SET allow_hyperscan = 0;`.

## extract(haystack, pattern)

Extracts a fragment of a string using a regular expression. If ‘haystack’ does not match the ‘pattern’ regex, an empty string is returned. If the regex does not contain subpatterns, it takes the fragment that matches the entire regex. Otherwise, it takes the fragment that matches the first subpattern.

## extractAll(haystack, pattern)

Extracts all the fragments of a string using a regular expression. If ‘haystack’ does not match the ‘pattern’ regex, an empty string is returned. Returns an array of strings consisting of all matches to the regex. In general, the behavior is the same as the ‘extract’ function (it takes the first subpattern, or the entire expression if there isn’t a subpattern).

## extractAllGroupsHorizontal

Matches all groups of the `haystack` string using the `pattern` regular expression. Returns an array of arrays, where the first array includes all fragments matching the first group, the second array - matching the second group, etc.

Note

`extractAllGroupsHorizontal` function is slower than [extractAllGroupsVertical.

**Syntax**

```
extractAllGroupsHorizontal(haystack, pattern)
```

**Arguments**

- `haystack` — Input string. Type:  String.
- `pattern` — Regular expression with re2 syntax. Must contain groups, each group enclosed in parentheses. If `pattern` contains no groups, an exception is thrown. Type:  String.

**Returned value**

- Type: Array.

If `haystack` does not match the `pattern` regex, an array of empty arrays is returned.

**Example**

Query:

```
SELECT extractAllGroupsHorizontal(abc=111, def=222, ghi=333, ("[^"]+"|\\w+)=("[^"]+"|\\w+));
```

Result:

```
┌─extractAllGroupsHorizontal(abc=111, def=222, ghi=333, ("[^"]+"|\\w+)=("[^"]+"|\\w+))─┐
│ [[abc,def,ghi],[111,222,333]]                                                │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

**See Also**

- extractAllGroupsVertical

## extractAllGroupsVertical

Matches all groups of the `haystack` string using the `pattern` regular expression. Returns an array of arrays, where each array includes matching fragments from every group. Fragments are grouped in order of appearance in the `haystack`.

**Syntax**

```
extractAllGroupsVertical(haystack, pattern)
```

**Arguments**

- `haystack` — Input string. Type: String.
- `pattern` — Regular expression with re2 syntax. Must contain groups, each group enclosed in parentheses. If `pattern` contains no groups, an exception is thrown. Type:  String.

**Returned value**

- Type: Array.

If `haystack` does not match the `pattern` regex, an empty array is returned.

**Example**

Query:

```
SELECT extractAllGroupsVertical(abc=111, def=222, ghi=333, ("[^"]+"|\\w+)=("[^"]+"|\\w+));
```

Result:

```
┌─extractAllGroupsVertical(abc=111, def=222, ghi=333, ("[^"]+"|\\w+)=("[^"]+"|\\w+))─┐
│ [[abc,111],[def,222],[ghi,333]]                                            │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

**See Also**

- extractAllGroupsHorizontal

## like(haystack, pattern), haystack LIKE pattern operator

Checks whether a string matches a simple regular expression.
The regular expression can contain the metasymbols `%` and `_`.

`%` indicates any quantity of any bytes (including zero characters).

`_` indicates any one byte.

Use the backslash (`\`) for escaping metasymbols. See the note on escaping in the description of the ‘match’ function.

For regular expressions like `%needle%`, the code is more optimal and works as fast as the `position` function.
For other regular expressions, the code is the same as for the ‘match’ function.

## notLike(haystack, pattern), haystack NOT LIKE pattern operator

The same thing as ‘like’, but negative.

## ilike[ ](https://clickhouse.tech/docs/en/sql-reference/functions/string-search-functions/#ilike)

Case insensitive variant of like function. You can use `ILIKE` operator instead of the `ilike` function.

**Syntax**

```
ilike(haystack, pattern)
```

**Arguments**

- `haystack` — Input string.  String.
- `pattern` — If `pattern` does not contain percent signs or underscores, then the `pattern` only represents the string itself. An underscore (`_`) in `pattern` stands for (matches) any single character. A percent sign (`%`) matches any sequence of zero or more characters.

Some `pattern` examples:

```
abc ILIKE abc    true
abc ILIKE a%     true
abc ILIKE _b_    true
abc ILIKE c      false
```

**Returned values**

- True, if the string matches `pattern`.
- False, if the string does not match `pattern`.

**Example**

Input table:

```
┌─id─┬─name─────┬─days─┐
│  1 │ January  │   31 │
│  2 │ February │   29 │
│  3 │ March    │   31 │
│  4 │ April    │   30 │
└────┴──────────┴──────┘
```

Query:

```
SELECT * FROM Months WHERE ilike(name, %j%);
```

Result:

```
┌─id─┬─name────┬─days─┐
│  1 │ January │   31 │
└────┴─────────┴──────┘
```

**See Also**

- Like

## ngramDistance(haystack, needle)

Calculates the 4-gram distance between `haystack` and `needle`: counts the symmetric difference between two multisets of 4-grams and normalizes it by the sum of their cardinalities. Returns float number from 0 to 1 – the closer to zero, the more strings are similar to each other. If the constant `needle` or `haystack` is more than 32Kb, throws an exception. If some of the non-constant `haystack` or `needle` strings are more than 32Kb, the distance is always one.

For case-insensitive search or/and in UTF-8 format use functions `ngramDistanceCaseInsensitive, ngramDistanceUTF8, ngramDistanceCaseInsensitiveUTF8`.

## ngramSearch(haystack, needle)

Same as `ngramDistance` but calculates the non-symmetric difference between `needle` and `haystack` – the number of n-grams from needle minus the common number of n-grams normalized by the number of `needle` n-grams. The closer to one, the more likely `needle` is in the `haystack`. Can be useful for fuzzy string search.

For case-insensitive search or/and in UTF-8 format use functions `ngramSearchCaseInsensitive, ngramSearchUTF8, ngramSearchCaseInsensitiveUTF8`.

Note

For UTF-8 case we use 3-gram distance. All these are not perfectly fair n-gram distances. We use 2-byte hashes to hash n-grams and then calculate the (non-)symmetric difference between these hash tables – collisions may occur. With UTF-8 case-insensitive format we do not use fair `tolower` function – we zero the 5-th bit (starting from zero) of each codepoint byte and first bit of zeroth byte if bytes more than one – this works for Latin and mostly for all Cyrillic letters.

## countSubstrings[ ](https://clickhouse.tech/docs/en/sql-reference/functions/string-search-functions/#countSubstrings)

Returns the number of substring occurrences.

For a case-insensitive search, use countSubstringsCaseInsensitive or countSubstringsCaseInsensitiveUTF8 functions.

**Syntax**

```
countSubstrings(haystack, needle[, start_pos])
```

**Arguments**

- `haystack` — The string to search in.  String.
- `needle` — The substring to search for.  String.
- `start_pos` – Position of the first character in the string to start search. Optional. UInt.

**Returned values**

- Number of occurrences.

Type:  UInt64.

**Examples**

Query:

```
SELECT countSubstrings(foobar.com, .);
```

Result:

```
┌─countSubstrings(foobar.com, .)─┐
│                                  1 │
└────────────────────────────────────┘
```

Query:

```
SELECT countSubstrings(aaaa, aa);
```

Result:

```
┌─countSubstrings(aaaa, aa)─┐
│                             2 │
└───────────────────────────────┘
```

Query:

```
SELECT countSubstrings(abc___abc, abc, 4);
```

Result:

```
┌─countSubstrings(abc___abc, abc, 4)─┐
│                                      1 │
└────────────────────────────────────────┘
```

## countSubstringsCaseInsensitive

Returns the number of substring occurrences case-insensitive.

**Syntax**

```
countSubstringsCaseInsensitive(haystack, needle[, start_pos])
```

**Arguments**

- `haystack` — The string to search in.  String.
- `needle` — The substring to search for. String.
- `start_pos` — Position of the first character in the string to start search. Optional. UInt.

**Returned values**

- Number of occurrences.

Type: UInt64.

**Examples**

Query:

```
SELECT countSubstringsCaseInsensitive(aba, B);
```

Result:

```
┌─countSubstringsCaseInsensitive(aba, B)─┐
│                                          1 │
└────────────────────────────────────────────┘
```

Query:

```
SELECT countSubstringsCaseInsensitive(foobar.com, CoM);
```

Result:

```
┌─countSubstringsCaseInsensitive(foobar.com, CoM)─┐
│                                                   1 │
└─────────────────────────────────────────────────────┘
```

Query:

```
SELECT countSubstringsCaseInsensitive(abC___abC, aBc, 2);
```

Result:

```
┌─countSubstringsCaseInsensitive(abC___abC, aBc, 2)─┐
│                                                     1 │
└───────────────────────────────────────────────────────┘
```

## countSubstringsCaseInsensitiveUTF8

Returns the number of substring occurrences in `UTF-8` case-insensitive.

**Syntax**

```
SELECT countSubstringsCaseInsensitiveUTF8(haystack, needle[, start_pos])
```

**Arguments**

- `haystack` — The string to search in.  String.
- `needle` — The substring to search for.  String.
- `start_pos` — Position of the first character in the string to start search. Optional.UInt.

**Returned values**

- Number of occurrences.

Type: UInt64.

**Examples**

Query:

```
SELECT countSubstringsCaseInsensitiveUTF8(абв, A);
```

Result:

```
┌─countSubstringsCaseInsensitiveUTF8(абв, A)─┐
│                                              1 │
└────────────────────────────────────────────────┘
```

Query:

```
SELECT countSubstringsCaseInsensitiveUTF8(аБв__АбВ__абв, Абв);
```

Result:

```
┌─countSubstringsCaseInsensitiveUTF8(аБв__АбВ__абв, Абв)─┐
│                                                          3 │
└────────────────────────────────────────────────────────────┘
```

## countMatches(haystack, pattern)

Returns the number of regular expression matches for a `pattern` in a `haystack`.

**Syntax**

```
countMatches(haystack, pattern)
```

**Arguments**

- `haystack` — The string to search in. String.
- `pattern` — The regular expression with re2 syntax. String.

**Returned value**

- The number of matches.

Type: UInt64.

**Examples**

Query:

```
SELECT countMatches(foobar.com, o+);
```

Result:

```
┌─countMatches(foobar.com, o+)─┐
│                                2 │
└──────────────────────────────────┘
```

Query:

```
SELECT countMatches(aaaa, aa);
```

Result:

```
┌─countMatches(aaaa, aa)────┐
│                             2 │
└───────────────────────────────┘
```

' where id=41;


update biz_data_query_model_help_content set content_en = '# Functions for Searching and Replacing in Strings

Note

Functions for searching and other manipulations with strings are described separately.

## replaceOne(haystack, pattern, replacement)

Replaces the first occurrence, if it exists, of the ‘pattern’ substring in ‘haystack’ with the ‘replacement’ substring.
Hereafter, ‘pattern’ and ‘replacement’ must be constants.

## replaceAll(haystack, pattern, replacement), replace(haystack, pattern, replacement)

Replaces all occurrences of the ‘pattern’ substring in ‘haystack’ with the ‘replacement’ substring.

## replaceRegexpOne(haystack, pattern, replacement)

Replacement using the ‘pattern’ regular expression. A re2 regular expression.
Replaces only the first occurrence, if it exists.
A pattern can be specified as ‘replacement’. This pattern can include substitutions `\0-\9`.
The substitution `\0` includes the entire regular expression. Substitutions `\1-\9` correspond to the subpattern numbers.To use the `\` character in a template, escape it using `\`.
Also keep in mind that a string literal requires an extra escape.

Example 1. Converting the date to American format:

```
SELECT DISTINCT
    EventDate,
    replaceRegexpOne(toString(EventDate), (\\d{4})-(\\d{2})-(\\d{2}), \\2/\\3/\\1) AS res
FROM test.hits
LIMIT 7
FORMAT TabSeparated
2014-03-17      03/17/2014
2014-03-18      03/18/2014
2014-03-19      03/19/2014
2014-03-20      03/20/2014
2014-03-21      03/21/2014
2014-03-22      03/22/2014
2014-03-23      03/23/2014
```

Example 2. Copying a string ten times:

```
SELECT replaceRegexpOne(Hello, World!, .*, \\0\\0\\0\\0\\0\\0\\0\\0\\0\\0) AS res
┌─res────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World! │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## replaceRegexpAll(haystack, pattern, replacement)

This does the same thing, but replaces all the occurrences. Example:

```
SELECT replaceRegexpAll(Hello, World!, ., \\0\\0) AS res
┌─res────────────────────────┐
│ HHeelllloo,,  WWoorrlldd!! │
└────────────────────────────┘
```

As an exception, if a regular expression worked on an empty substring, the replacement is not made more than once.
Example:

```
SELECT replaceRegexpAll(Hello, World!, ^, here: ) AS res
┌─res─────────────────┐
│ here: Hello, World! │
└─────────────────────┘
```

## regexpQuoteMeta(s)

The function adds a backslash before some predefined characters in the string.
Predefined characters: `\0`, `\\`, `|`, `(`, `)`, `^`, `$`, `.`, `[`, `]`, `?`, `*`, `+`, `{`, `:`, `-`.
This implementation slightly differs from re2::RE2::QuoteMeta. It escapes zero byte as `\0` instead of `\x00` and it escapes only required characters.



' where id=42;
update biz_data_query_model_help_content set content_en = '# Mathematical Functions

All the functions return a Float64 number. The accuracy of the result is close to the maximum precision possible, but the result might not coincide with the machine representable number nearest to the corresponding real number.

## e()

Returns a Float64 number that is close to the number e.

## pi()

Returns a Float64 number that is close to the number π.

## exp(x)

Accepts a numeric argument and returns a Float64 number close to the exponent of the argument.

## log(x), ln(x)

Accepts a numeric argument and returns a Float64 number close to the natural logarithm of the argument.

## exp2(x)

Accepts a numeric argument and returns a Float64 number close to 2 to the power of x.

## log2(x)

Accepts a numeric argument and returns a Float64 number close to the binary logarithm of the argument.

## exp10(x)

Accepts a numeric argument and returns a Float64 number close to 10 to the power of x.

## log10(x)

Accepts a numeric argument and returns a Float64 number close to the decimal logarithm of the argument.

## sqrt(x)

Accepts a numeric argument and returns a Float64 number close to the square root of the argument.

## cbrt(x)

Accepts a numeric argument and returns a Float64 number close to the cubic root of the argument.

## erf(x)

If ‘x’ is non-negative, then `erf(x / σ√2)` is the probability that a random variable having a normal distribution with standard deviation ‘σ’ takes the value that is separated from the expected value by more than ‘x’.

Example (three sigma rule):

```
SELECT erf(3 / sqrt(2));
┌─erf(divide(3, sqrt(2)))─┐
│      0.9973002039367398 │
└─────────────────────────┘
```

## erfc(x)

Accepts a numeric argument and returns a Float64 number close to 1 - erf(x), but without loss of precision for large ‘x’ values.

## lgamma(x)

The logarithm of the gamma function.

## tgamma(x)

Gamma function.

## sin(x)

The sine.

## cos(x)

The cosine.

## tan(x)

The tangent.

## asin(x)

The arc sine.

## acos(x)

The arc cosine.

## atan(x)

The arc tangent.

## pow(x, y), power(x, y)

Takes two numeric arguments x and y. Returns a Float64 number close to x to the power of y.

## intExp2

Accepts a numeric argument and returns a UInt64 number close to 2 to the power of x.

## intExp10

Accepts a numeric argument and returns a UInt64 number close to 10 to the power of x.

## cosh(x)

Hyperbolic cosine.

**Syntax**

```
cosh(x)
```

**Arguments**

- `x` — The angle, in radians. Values from the interval: `-∞ < x < +∞`. Float64.

**Returned value**

- Values from the interval: `1 <= cosh(x) < +∞`.

Type: Float64.

**Example**

Query:

```
SELECT cosh(0);
```

Result:

```
┌─cosh(0)──┐
│        1 │
└──────────┘
```

## acosh(x)

Inverse hyperbolic cosine.

**Syntax**

```
acosh(x)
```

**Arguments**

- `x` — Hyperbolic cosine of angle. Values from the interval: `1 <= x < +∞`.  Float64.

**Returned value**

- The angle, in radians. Values from the interval: `0 <= acosh(x) < +∞`.

Type:  Float64.

**Example**

Query:

```
SELECT acosh(1);
```

Result:

```
┌─acosh(1)─┐
│        0 │
└──────────┘
```

**See Also**

- cosh(x)

## sinh(x)

Hyperbolic sine.

**Syntax**

```
sinh(x)
```

**Arguments**

- `x` — The angle, in radians. Values from the interval: `-∞ < x < +∞`.  Float64.

**Returned value**

- Values from the interval: `-∞ < sinh(x) < +∞`.

Type:  Float64.

**Example**

Query:

```
SELECT sinh(0);
```

Result:

```
┌─sinh(0)──┐
│        0 │
└──────────┘
```

## asinh(x)

Inverse hyperbolic sine.

**Syntax**

```
asinh(x)
```

**Arguments**

- `x` — Hyperbolic sine of angle. Values from the interval: `-∞ < x < +∞`.  Float64.

**Returned value**

- The angle, in radians. Values from the interval: `-∞ < asinh(x) < +∞`.

Type:  Float64.

**Example**

Query:

```
SELECT asinh(0);
```

Result:

```
┌─asinh(0)─┐
│        0 │
└──────────┘
```

**See Also**

- sinh(x)

## atanh(x)[ ](https://clickhouse.tech/docs/en/sql-reference/functions/math-functions/#atanhx)

Inverse hyperbolic tangent.

**Syntax**

```
atanh(x)
```

**Arguments**

- `x` — Hyperbolic tangent of angle. Values from the interval: `–1 < x < 1`.  Float64.

**Returned value**

- The angle, in radians. Values from the interval: `-∞ < atanh(x) < +∞`.

Type:  Float64.

**Example**

Query:

```
SELECT atanh(0);
```

Result:

```
┌─atanh(0)─┐
│        0 │
└──────────┘
```

## atan2(y, x)

The function calculates the angle in the Euclidean plane, given in radians, between the positive x axis and the ray to the point `(x, y) ≠ (0, 0)`.

**Syntax**

```
atan2(y, x)
```

**Arguments**

- `y` — y-coordinate of the point through which the ray passes.  Float64.
- `x` — x-coordinate of the point through which the ray passes.  Float64.

**Returned value**

- The angle `θ` such that `−π < θ ≤ π`, in radians.

Type:  Float64.

**Example**

Query:

```
SELECT atan2(1, 1);
```

Result:

```
┌────────atan2(1, 1)─┐
│ 0.7853981633974483 │
└────────────────────┘
```

## hypot(x, y)

Calculates the length of the hypotenuse of a right-angle triangle. The function avoids problems that occur when squaring very large or very small numbers.

**Syntax**

```
hypot(x, y)
```

**Arguments**

- `x` — The first cathetus of a right-angle triangle. Float64.
- `y` — The second cathetus of a right-angle triangle. Float64.

**Returned value**

- The length of the hypotenuse of a right-angle triangle.

Type: Float64.

**Example**

Query:

```
SELECT hypot(1, 1);
```

Result:

```
┌────────hypot(1, 1)─┐
│ 1.4142135623730951 │
└────────────────────┘
```

## log1p(x)

Calculates `log(1+x)`. The function `log1p(x)` is more accurate than `log(1+x)` for small values of x.

**Syntax**

```
log1p(x)
```

**Arguments**

- `x` — Values from the interval: `-1 < x < +∞`.  Float64.

**Returned value**

- Values from the interval: `-∞ < log1p(x) < +∞`.

Type:  Float64.

**Example**

Query:

```
SELECT log1p(0);
```

Result:

```
┌─log1p(0)─┐
│        0 │
└──────────┘
```

**See Also**

- log(x)

## sign(x)

Returns the sign of a real number.

**Syntax**

```
sign(x)
```

**Arguments**

- `x` — Values from `-∞` to `+∞`. Support all numeric types in ClickHouse.

**Returned value**

- -1 for `x < 0`
- 0 for `x = 0`
- 1 for `x > 0`

**Examples**

Sign for the zero value:

```
SELECT sign(0);
```

Result:

```
┌─sign(0)─┐
│       0 │
└─────────┘
```

Sign for the positive value:

```
SELECT sign(1);
```

Result:

```
┌─sign(1)─┐
│       1 │
└─────────┘
```

Sign for the negative value:

```
SELECT sign(-1);
```

Result:

```
┌─sign(-1)─┐
│       -1 │
└──────────┘
```

' where id=43;
update biz_data_query_model_help_content set content_en = '# Array Functions

## empty

Returns 1 for an empty array, or 0 for a non-empty array.
The result type is UInt8.
The function also works for strings.

Can be optimized by enabling the [optimize_functions_to_subcolumns] setting. With `optimize_functions_to_subcolumns = 1` the function reads only [size0] subcolumn instead of reading and processing the whole array column. The query `SELECT empty(arr) FROM table` transforms to `SELECT arr.size0 = 0 FROM TABLE`.

## notEmpty

Returns 0 for an empty array, or 1 for a non-empty array.
The result type is UInt8.
The function also works for strings.

Can be optimized by enabling the [optimize_functions_to_subcolumns] setting. With `optimize_functions_to_subcolumns = 1` the function reads only [size0] subcolumn instead of reading and processing the whole array column. The query `SELECT notEmpty(arr) FROM table` transforms to `SELECT arr.size0 != 0 FROM TABLE`.

## length

Returns the number of items in the array.
The result type is UInt64.
The function also works for strings.

Can be optimized by enabling the [optimize_functions_to_subcolumns] setting. With `optimize_functions_to_subcolumns = 1` the function reads only [size0] subcolumn instead of reading and processing the whole array column. The query `SELECT length(arr) FROM table` transforms to `SELECT arr.size0 FROM TABLE`.

## emptyArrayUInt8, emptyArrayUInt16, emptyArrayUInt32, emptyArrayUInt64

## emptyArrayInt8, emptyArrayInt16, emptyArrayInt32, emptyArrayInt64

## emptyArrayFloat32, emptyArrayFloat64

## emptyArrayDate, emptyArrayDateTime

## emptyArrayString

Accepts zero arguments and returns an empty array of the appropriate type.

## emptyArrayToSingle

Accepts an empty array and returns a one-element array that is equal to the default value.

## range(end), range([start, ] end [, step])

Returns an array of `UInt` numbers from `start` to `end - 1` by `step`.

**Syntax**

```
range([start, ] end [, step])
```

**Arguments**

- `start` — The first element of the array. Optional, required if `step` is used. Default value: 0. [UInt]
- `end` — The number before which the array is constructed. Required. [UInt]
- `step` — Determines the incremental step between each element in the array. Optional. Default value: 1. [UInt]

**Returned value**

- Array of `UInt` numbers from `start` to `end - 1` by `step`.

**Implementation details**

- All arguments must be positive values: `start`, `end`, `step` are `UInt` data types, as well as elements of the returned array.
- An exception is thrown if query results in arrays with a total length of more than 100,000,000 elements.

**Examples**

Query:

```
SELECT range(5), range(1, 5), range(1, 5, 2);
```

Result:

```
┌─range(5)────┬─range(1, 5)─┬─range(1, 5, 2)─┐
│ [0,1,2,3,4] │ [1,2,3,4]   │ [1,3]          │
└─────────────┴─────────────┴────────────────┘
```

## array(x1, …), operator [x1, …]

Creates an array from the function arguments.
The arguments must be constants and have types that have the smallest common type. At least one argument must be passed, because otherwise it isn’t clear which type of array to create. That is, you can’t use this function to create an empty array (to do that, use the ‘emptyArray*’ function described above).
Returns an ‘Array(T)’ type result, where ‘T’ is the smallest common type out of the passed arguments.

## arrayConcat

Combines arrays passed as arguments.

```
arrayConcat(arrays)
```

**Arguments**

- `arrays` – Arbitrary number of arguments of [Array] type.
  **Example**

```
SELECT arrayConcat([1, 2], [3, 4], [5, 6]) AS res
┌─res───────────┐
│ [1,2,3,4,5,6] │
└───────────────┘
```

## arrayElement(arr, n), operator arr[n]

Get the element with the index `n` from the array `arr`. `n` must be any integer type.
Indexes in an array begin from one.
Negative indexes are supported. In this case, it selects the corresponding element numbered from the end. For example, `arr[-1]` is the last item in the array.

If the index falls outside of the bounds of an array, it returns some default value (0 for numbers, an empty string for strings, etc.), except for the case with a non-constant array and a constant index 0 (in this case there will be an error `Array indices are 1-based`).

## has(arr, elem)

Checks whether the ‘arr’ array has the ‘elem’ element.
Returns 0 if the element is not in the array, or 1 if it is.

`NULL` is processed as a value.

```
SELECT has([1, 2, NULL], NULL)
┌─has([1, 2, NULL], NULL)─┐
│                       1 │
└─────────────────────────┘
```

## hasAll

Checks whether one array is a subset of another.

```
hasAll(set, subset)
```

**Arguments**

- `set` – Array of any type with a set of elements.
- `subset` – Array of any type with elements that should be tested to be a subset of `set`.

**Return values**

- `1`, if `set` contains all of the elements from `subset`.
- `0`, otherwise.

**Peculiar properties**

- An empty array is a subset of any array.
- `Null` processed as a value.
- Order of values in both of arrays does not matter.

**Examples**

`SELECT hasAll([], [])` returns 1.

`SELECT hasAll([1, Null], [Null])` returns 1.

`SELECT hasAll([1.0, 2, 3, 4], [1, 3])` returns 1.

`SELECT hasAll([a, b], [a])` returns 1.

`SELECT hasAll([1], [a])` returns 0.

`SELECT hasAll([[1, 2], [3, 4]], [[1, 2], [3, 5]])` returns 0.

## hasAny

Checks whether two arrays have intersection by some elements.

```
hasAny(array1, array2)
```

**Arguments**

- `array1` – Array of any type with a set of elements.
- `array2` – Array of any type with a set of elements.

**Return values**

- `1`, if `array1` and `array2` have one similar element at least.
- `0`, otherwise.

**Peculiar properties**

- `Null` processed as a value.
- Order of values in both of arrays does not matter.

**Examples**

`SELECT hasAny([1], [])` returns `0`.

`SELECT hasAny([Null], [Null, 1])` returns `1`.

`SELECT hasAny([-128, 1., 512], [1])` returns `1`.

`SELECT hasAny([[1, 2], [3, 4]], [a, c])` returns `0`.

`SELECT hasAll([[1, 2], [3, 4]], [[1, 2], [1, 2]])` returns `1`.

## hasSubstr

Checks whether all the elements of array2 appear in array1 in the same exact order. Therefore, the function will return 1, if and only if `array1 = prefix + array2 + suffix`.

```
hasSubstr(array1, array2)
```

In other words, the functions will check whether all the elements of `array2` are contained in `array1` like
the `hasAll` function. In addition, it will check that the elements are observed in the same order in both `array1` and `array2`.

For Example:
\- `hasSubstr([1,2,3,4], [2,3])` returns 1. However, `hasSubstr([1,2,3,4], [3,2])` will return `0`.
\- `hasSubstr([1,2,3,4], [1,2,3])` returns 1. However, `hasSubstr([1,2,3,4], [1,2,4])` will return `0`.

**Arguments**

- `array1` – Array of any type with a set of elements.
- `array2` – Array of any type with a set of elements.

**Return values**

- `1`, if `array1` contains `array2`.
- `0`, otherwise.

**Peculiar properties**

- The function will return `1` if `array2` is empty.
- `Null` processed as a value. In other words `hasSubstr([1, 2, NULL, 3, 4], [2,3])` will return `0`. However, `hasSubstr([1, 2, NULL, 3, 4], [2,NULL,3])` will return `1`
- Order of values in both of arrays does matter.

**Examples**

`SELECT hasSubstr([], [])` returns 1.

`SELECT hasSubstr([1, Null], [Null])` returns 1.

`SELECT hasSubstr([1.0, 2, 3, 4], [1, 3])` returns 0.

`SELECT hasSubstr([a, b], [a])` returns 1.

`SELECT hasSubstr([a, b , c], [a, b])` returns 1.

`SELECT hasSubstr([a, b , c], [a, c])` returns 0.

`SELECT hasSubstr([[1, 2], [3, 4], [5, 6]], [[1, 2], [3, 4]])` returns 1.

## indexOf(arr, x)

Returns the index of the first ‘x’ element (starting from 1) if it is in the array, or 0 if it is not.

Example:

```
SELECT indexOf([1, 3, NULL, NULL], NULL)┌─indexOf([1, 3, NULL, NULL], NULL)─┐│                                 3 │└───────────────────────────────────┘
```

Elements set to `NULL` are handled as normal values.

## arrayCount([func,] arr1, …)

Returns the number of elements in the arr array for which func returns something other than 0. If ‘func’ is not specified, it returns the number of non-zero elements in the array.

Note that the `arrayCount` is a [higher-order function]. You can pass a lambda function to it as the first argument.

## countEqual(arr, x)

Returns the number of elements in the array equal to x. Equivalent to arrayCount (elem -> elem = x, arr).

`NULL` elements are handled as separate values.

Example:

```
SELECT countEqual([1, 2, NULL, NULL], NULL)┌─countEqual([1, 2, NULL, NULL], NULL)─┐│                                    2 │└──────────────────────────────────────┘
```

## arrayEnumerate(arr)

Returns the array [1, 2, 3, …, length (arr) ]

This function is normally used with ARRAY JOIN. It allows counting something just once for each array after applying ARRAY JOIN. Example:

```
SELECT    count() AS Reaches,    countIf(num = 1) AS HitsFROM test.hitsARRAY JOIN    GoalsReached,    arrayEnumerate(GoalsReached) AS numWHERE CounterID = 160656LIMIT 10┌─Reaches─┬──Hits─┐│   95606 │ 31406 │└─────────┴───────┘
```

In this example, Reaches is the number of conversions (the strings received after applying ARRAY JOIN), and Hits is the number of pageviews (strings before ARRAY JOIN). In this particular case, you can get the same result in an easier way:

```
SELECT    sum(length(GoalsReached)) AS Reaches,    count() AS HitsFROM test.hitsWHERE (CounterID = 160656) AND notEmpty(GoalsReached)┌─Reaches─┬──Hits─┐│   95606 │ 31406 │└─────────┴───────┘
```

This function can also be used in higher-order functions. For example, you can use it to get array indexes for elements that match a condition.

## arrayEnumerateUniq(arr, …)

Returns an array the same size as the source array, indicating for each element what its position is among elements with the same value.
For example: arrayEnumerateUniq([10, 20, 10, 30]) = [1, 1, 2, 1].

This function is useful when using ARRAY JOIN and aggregation of array elements.
Example:

```
SELECT    Goals.ID AS GoalID,    sum(Sign) AS Reaches,    sumIf(Sign, num = 1) AS VisitsFROM test.visitsARRAY JOIN    Goals,    arrayEnumerateUniq(Goals.ID) AS numWHERE CounterID = 160656GROUP BY GoalIDORDER BY Reaches DESCLIMIT 10┌──GoalID─┬─Reaches─┬─Visits─┐│   53225 │    3214 │   1097 ││ 2825062 │    3188 │   1097 ││   56600 │    2803 │    488 ││ 1989037 │    2401 │    365 ││ 2830064 │    2396 │    910 ││ 1113562 │    2372 │    373 ││ 3270895 │    2262 │    812 ││ 1084657 │    2262 │    345 ││   56599 │    2260 │    799 ││ 3271094 │    2256 │    812 │└─────────┴─────────┴────────┘
```

In this example, each goal ID has a calculation of the number of conversions (each element in the Goals nested data structure is a goal that was reached, which we refer to as a conversion) and the number of sessions. Without ARRAY JOIN, we would have counted the number of sessions as sum(Sign). But in this particular case, the rows were multiplied by the nested Goals structure, so in order to count each session one time after this, we apply a condition to the value of the arrayEnumerateUniq(Goals.ID) function.

The arrayEnumerateUniq function can take multiple arrays of the same size as arguments. In this case, uniqueness is considered for tuples of elements in the same positions in all the arrays.

```
SELECT arrayEnumerateUniq([1, 1, 1, 2, 2, 2], [1, 1, 2, 1, 1, 2]) AS res
┌─res───────────┐
│ [1,2,1,1,2,1] │
└───────────────┘
```

This is necessary when using ARRAY JOIN with a nested data structure and further aggregation across multiple elements in this structure.

## arrayPopBack

Removes the last item from the array.

```
arrayPopBack(array)
```

**Arguments**

- `array` – Array.

**Example**

```
SELECT arrayPopBack([1, 2, 3]) AS res;
┌─res───┐
│ [1,2] │
└───────┘
```

## arrayPopFront

Removes the first item from the array.

```
arrayPopFront(array)
```

**Arguments**

- `array` – Array.

**Example**

```
SELECT arrayPopFront([1, 2, 3]) AS res;┌─res───┐│ [2,3] │└───────┘
```

## arrayPushBack

Adds one item to the end of the array.

```
arrayPushBack(array, single_value)
```

**Arguments**

- `array` – Array.
- `single_value` – A single value. Only numbers can be added to an array with numbers, and only strings can be added to an array of strings. When adding numbers, ClickHouse automatically sets the `single_value` type for the data type of the array. For more information about the types of data in ClickHouse, see “[Data types]”. Can be `NULL`. The function adds a `NULL` element to an array, and the type of array elements converts to `Nullable`.

**Example**

```
SELECT arrayPushBack([a], b) AS res;┌─res───────┐│ [a,b] │└───────────┘
```

## arrayPushFront

Adds one element to the beginning of the array.

```
arrayPushFront(array, single_value)
```

**Arguments**

- `array` – Array.
- `single_value` – A single value. Only numbers can be added to an array with numbers, and only strings can be added to an array of strings. When adding numbers, ClickHouse automatically sets the `single_value` type for the data type of the array. For more information about the types of data in ClickHouse, see “[Data types]”. Can be `NULL`. The function adds a `NULL` element to an array, and the type of array elements converts to `Nullable`.

**Example**

```
SELECT arrayPushFront([b], a) AS res;┌─res───────┐│ [a,b] │└───────────┘
```

## arrayResize

Changes the length of the array.

```
arrayResize(array, size[, extender])
```

**Arguments:**

- `array` — Array.

- ```
  size
  ```



  — Required length of the array.

  - If `size` is less than the original size of the array, the array is truncated from the right.

- If `size` is larger than the initial size of the array, the array is extended to the right with `extender` values or default values for the data type of the array items.

- `extender` — Value for extending an array. Can be `NULL`.

**Returned value:**

An array of length `size`.

**Examples of calls**

```
SELECT arrayResize([1], 3);┌─arrayResize([1], 3)─┐│ [1,0,0]             │└─────────────────────┘SELECT arrayResize([1], 3, NULL);┌─arrayResize([1], 3, NULL)─┐│ [1,NULL,NULL]             │└───────────────────────────┘
```

## arraySlice

Returns a slice of the array.

```
arraySlice(array, offset[, length])
```

**Arguments**

- `array` – Array of data.
- `offset` – Indent from the edge of the array. A positive value indicates an offset on the left, and a negative value is an indent on the right. Numbering of the array items begins with 1.
- `length` – The length of the required slice. If you specify a negative value, the function returns an open slice `[offset, array_length - length)`. If you omit the value, the function returns the slice `[offset, the_end_of_array]`.

**Example**

```
SELECT arraySlice([1, 2, NULL, 4, 5], 2, 3) AS res;┌─res────────┐│ [2,NULL,4] │└────────────┘
```

Array elements set to `NULL` are handled as normal values.

## arraySort([func,] arr, …)

Sorts the elements of the `arr` array in ascending order. If the `func` function is specified, sorting order is determined by the result of the `func` function applied to the elements of the array. If `func` accepts multiple arguments, the `arraySort` function is passed several arrays that the arguments of `func` will correspond to. Detailed examples are shown at the end of `arraySort` description.

Example of integer values sorting:

```
SELECT arraySort([1, 3, 3, 0]);┌─arraySort([1, 3, 3, 0])─┐│ [0,1,3,3]               │└─────────────────────────┘
```

Example of string values sorting:

```
SELECT arraySort([hello, world, !]);┌─arraySort([hello, world, !])─┐│ [!,hello,world]              │└────────────────────────────────────┘
```

Consider the following sorting order for the `NULL`, `NaN` and `Inf` values:

```
SELECT arraySort([1, nan, 2, NULL, 3, nan, -4, NULL, inf, -inf]);┌─arraySort([1, nan, 2, NULL, 3, nan, -4, NULL, inf, -inf])─┐│ [-inf,-4,1,2,3,inf,nan,nan,NULL,NULL]                     │└───────────────────────────────────────────────────────────┘
```

- `-Inf` values are first in the array.
- `NULL` values are last in the array.
- `NaN` values are right before `NULL`.
- `Inf` values are right before `NaN`.

Note that `arraySort` is a [higher-order function]. You can pass a lambda function to it as the first argument. In this case, sorting order is determined by the result of the lambda function applied to the elements of the array.

Let’s consider the following example:

```
SELECT arraySort((x) -> -x, [1, 2, 3]) as res;┌─res─────┐│ [3,2,1] │└─────────┘
```

For each element of the source array, the lambda function returns the sorting key, that is, [1 –> -1, 2 –> -2, 3 –> -3]. Since the `arraySort` function sorts the keys in ascending order, the result is [3, 2, 1]. Thus, the `(x) –> -x` lambda function sets the [descending order] in a sorting.

The lambda function can accept multiple arguments. In this case, you need to pass the `arraySort` function several arrays of identical length that the arguments of lambda function will correspond to. The resulting array will consist of elements from the first input array; elements from the next input array(s) specify the sorting keys. For example:

```
SELECT arraySort((x, y) -> y, [hello, world], [2, 1]) as res;
┌─res────────────────┐
│ [world, hello] │
└────────────────────┘
```

Here, the elements that are passed in the second array ([2, 1]) define a sorting key for the corresponding element from the source array ([‘hello’, ‘world’]), that is, [‘hello’ –> 2, ‘world’ –> 1]. Since the lambda function does not use `x`, actual values of the source array do not affect the order in the result. So, ‘hello’ will be the second element in the result, and ‘world’ will be the first.

Other examples are shown below.

```
SELECT arraySort((x, y) -> y, [0, 1, 2], [c, b, a]) as res;
┌─res─────┐
│ [2,1,0] │
└─────────┘
SELECT arraySort((x, y) -> -y, [0, 1, 2], [1, 2, 3]) as res;
┌─res─────┐
│ [2,1,0] │
└─────────┘
```

Note

To improve sorting efficiency, the [Schwartzian transform] is used.

## arrayReverseSort([func,] arr, …)

Sorts the elements of the `arr` array in descending order. If the `func` function is specified, `arr` is sorted according to the result of the `func` function applied to the elements of the array, and then the sorted array is reversed. If `func` accepts multiple arguments, the `arrayReverseSort` function is passed several arrays that the arguments of `func` will correspond to. Detailed examples are shown at the end of `arrayReverseSort` description.

Example of integer values sorting:

```
SELECT arrayReverseSort([1, 3, 3, 0]);┌─arrayReverseSort([1, 3, 3, 0])─┐│ [3,3,1,0]                      │└────────────────────────────────┘
```

Example of string values sorting:

```
SELECT arrayReverseSort([hello, world, !]);┌─arrayReverseSort([hello, world, !])─┐│ [world,hello,!]                     │└───────────────────────────────────────────┘
```

Consider the following sorting order for the `NULL`, `NaN` and `Inf` values:

```
SELECT arrayReverseSort([1, nan, 2, NULL, 3, nan, -4, NULL, inf, -inf]) as res;┌─res───────────────────────────────────┐│ [inf,3,2,1,-4,-inf,nan,nan,NULL,NULL] │└───────────────────────────────────────┘
```

- `Inf` values are first in the array.
- `NULL` values are last in the array.
- `NaN` values are right before `NULL`.
- `-Inf` values are right before `NaN`.

Note that the `arrayReverseSort` is a [higher-order function]. You can pass a lambda function to it as the first argument. Example is shown below.

```
SELECT arrayReverseSort((x) -> -x, [1, 2, 3]) as res;┌─res─────┐│ [1,2,3] │└─────────┘
```

The array is sorted in the following way:

1. At first, the source array ([1, 2, 3]) is sorted according to the result of the lambda function applied to the elements of the array. The result is an array [3, 2, 1].
2. Array that is obtained on the previous step, is reversed. So, the final result is [1, 2, 3].

The lambda function can accept multiple arguments. In this case, you need to pass the `arrayReverseSort` function several arrays of identical length that the arguments of lambda function will correspond to. The resulting array will consist of elements from the first input array; elements from the next input array(s) specify the sorting keys. For example:

```
SELECT arrayReverseSort((x, y) -> y, [hello, world], [2, 1]) as res;┌─res───────────────┐│ [hello,world] │└───────────────────┘
```

In this example, the array is sorted in the following way:

1. At first, the source array ([‘hello’, ‘world’]) is sorted according to the result of the lambda function applied to the elements of the arrays. The elements that are passed in the second array ([2, 1]), define the sorting keys for corresponding elements from the source array. The result is an array [‘world’, ‘hello’].
2. Array that was sorted on the previous step, is reversed. So, the final result is [‘hello’, ‘world’].

Other examples are shown below.

```
SELECT arrayReverseSort((x, y) -> y, [4, 3, 5], [a, b, c]) AS res;┌─res─────┐│ [5,3,4] │└─────────┘SELECT arrayReverseSort((x, y) -> -y, [4, 3, 5], [1, 2, 3]) AS res;┌─res─────┐│ [4,3,5] │└─────────┘
```

## arrayUniq(arr, …)

If one argument is passed, it counts the number of different elements in the array.
If multiple arguments are passed, it counts the number of different tuples of elements at corresponding positions in multiple arrays.

If you want to get a list of unique items in an array, you can use arrayReduce(‘groupUniqArray’, arr).

## arrayJoin(arr)

A special function. See the section [“ArrayJoin function”].

## arrayDifference

Calculates the difference between adjacent array elements. Returns an array where the first element will be 0, the second is the difference between `a[1] - a[0]`, etc. The type of elements in the resulting array is determined by the type inference rules for subtraction (e.g. `UInt8` - `UInt8` = `Int16`).

**Syntax**

```
arrayDifference(array)
```

**Arguments**

- `array` – [Array].

**Returned values**

Returns an array of differences between adjacent elements.

Type: [UInt*], [Int*], [Float*].

**Example**

Query:

```
SELECT arrayDifference([1, 2, 3, 4]);
```

Result:

```
┌─arrayDifference([1, 2, 3, 4])─┐
│ [0,1,1,1]                     │
└───────────────────────────────┘
```

Example of the overflow due to result type Int64:

Query:

```
SELECT arrayDifference([0, 1000]);
```

Result:

```
┌─arrayDifference([0, 1000])─┐│ [0,-8446744073709551616]                   │└────────────────────────────────────────────┘
```

## arrayDistinct

Takes an array, returns an array containing the distinct elements only.

**Syntax**

```
arrayDistinct(array)
```

**Arguments**

- `array` – [Array].

**Returned values**

Returns an array containing the distinct elements.

**Example**

Query:

```
SELECT arrayDistinct([1, 2, 2, 3, 1]);
```

Result:

```
┌─arrayDistinct([1, 2, 2, 3, 1])─┐
│ [1,2,3]                        │
└────────────────────────────────┘
```

## arrayEnumerateDense(arr)

Returns an array of the same size as the source array, indicating where each element first appears in the source array.

Example:

```
SELECT arrayEnumerateDense([10, 20, 10, 30])┌─arrayEnumerateDense([10, 20, 10, 30])─┐│ [1,2,1,3]                             │└───────────────────────────────────────┘
```

## arrayIntersect(arr)

Takes multiple arrays, returns an array with elements that are present in all source arrays. Elements order in the resulting array is the same as in the first array.

Example:

```
SELECT    arrayIntersect([1, 2], [1, 3], [2, 3]) AS no_intersect,    arrayIntersect([1, 2], [1, 3], [1, 4]) AS intersect┌─no_intersect─┬─intersect─┐│ []           │ [1]       │└──────────────┴───────────┘
```

## arrayReduce

Applies an aggregate function to array elements and returns its result. The name of the aggregation function is passed as a string in single quotes `max`, `sum`. When using parametric aggregate functions, the parameter is indicated after the function name in parentheses `uniqUpTo(6)`.

**Syntax**

```
arrayReduce(agg_func, arr1, arr2, ..., arrN)
```

**Arguments**

- `agg_func` — The name of an aggregate function which should be a constant [string].
- `arr` — Any number of [array] type columns as the parameters of the aggregation function.

**Returned value**

**Example**

Query:

```
SELECT arrayReduce(max, [1, 2, 3]);
```

Result:

```
┌─arrayReduce(max, [1, 2, 3])─┐│                             3 │└───────────────────────────────┘
```

If an aggregate function takes multiple arguments, then this function must be applied to multiple arrays of the same size.

Query:

```
SELECT arrayReduce(maxIf, [3, 5], [1, 0]);
```

Result:

```
┌─arrayReduce(maxIf, [3, 5], [1, 0])─┐│                                    3 │└──────────────────────────────────────┘
```

Example with a parametric aggregate function:

Query:

```
SELECT arrayReduce(uniqUpTo(3), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
```

Result:

```
┌─arrayReduce(uniqUpTo(3), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])─┐│                                                           4 │└─────────────────────────────────────────────────────────────┘
```

## arrayReduceInRanges

Applies an aggregate function to array elements in given ranges and returns an array containing the result corresponding to each range. The function will return the same result as multiple `arrayReduce(agg_func, arraySlice(arr1, index, length), ...)`.

**Syntax**

```
arrayReduceInRanges(agg_func, ranges, arr1, arr2, ..., arrN)
```

**Arguments**

- `agg_func` — The name of an aggregate function which should be a constant [string].
- `ranges` — The ranges to aggretate which should be an [array] of [tuples] which containing the index and the length of each range.
- `arr` — Any number of [Array] type columns as the parameters of the aggregation function.

**Returned value**

- Array containing results of the aggregate function over specified ranges.

Type: [Array].

**Example**

Query:

```
SELECT arrayReduceInRanges(
    sum,
    [(1, 5), (2, 3), (3, 4), (4, 4)],
    [100, 20, 3, 4000, 500, 60, 7]
) AS res
```

Result:

```
┌─res─────────────────────────┐
│ [1234500,234000,34560,4567] │
└─────────────────────────────┘
```

## arrayReverse(arr)

Returns an array of the same size as the original array containing the elements in reverse order.

Example:

```
SELECT arrayReverse([1, 2, 3])
┌─arrayReverse([1, 2, 3])─┐
│ [3,2,1]                 │
└─────────────────────────┘
```

## reverse(arr)

Synonym for [“arrayReverse”]

## arrayFlatten

Converts an array of arrays to a flat array.

Function:

- Applies to any depth of nested arrays.
- Does not change arrays that are already flat.

The flattened array contains all the elements from all source arrays.

**Syntax**

```
flatten(array_of_arrays)
```

Alias: `flatten`.

**Arguments**

- `array_of_arrays` — [Array] of arrays. For example, `[[1,2,3], [4,5]]`.

**Examples**

```
SELECT flatten([[[1]], [[2], [3]]]);
┌─flatten(array(array([1]), array([2], [3])))─┐
│ [1,2,3]                                     │
└─────────────────────────────────────────────┘
```

## arrayCompact

Removes consecutive duplicate elements from an array. The order of result values is determined by the order in the source array.

**Syntax**

```
arrayCompact(arr)
```

**Arguments**

`arr` — The [array] to inspect.

**Returned value**

The array without duplicate.

Type: `Array`.

**Example**

Query:

```
SELECT arrayCompact([1, 1, nan, nan, 2, 3, 3, 3]);
```

Result:

```
┌─arrayCompact([1, 1, nan, nan, 2, 3, 3, 3])─┐
│ [1,nan,nan,2,3]                            │
└────────────────────────────────────────────┘
```

## arrayZip

Combines multiple arrays into a single array. The resulting array contains the corresponding elements of the source arrays grouped into tuples in the listed order of arguments.

**Syntax**

```
arrayZip(arr1, arr2, ..., arrN)
```

**Arguments**

- `arrN` — [Array].

The function can take any number of arrays of different types. All the input arrays must be of equal size.

**Returned value**

- Array with elements from the source arrays grouped into [tuples]. Data types in the tuple are the same as types of the input arrays and in the same order as arrays are passed.

Type: [Array].

**Example**

Query:

```
SELECT arrayZip([a, b, c], [5, 2, 1]);
```

Result:

```
┌─arrayZip([a, b, c], [5, 2, 1])─┐
│ [(a,5),(b,2),(c,1)]            │
└──────────────────────────────────────┘
```

## arrayAUC

Calculate AUC (Area Under the Curve, which is a concept in machine learning, see more details: https://en.wikipedia.org/wiki/Receiver_operating_characteristic#Area_under_the_curve).

**Syntax**

```
arrayAUC(arr_scores, arr_labels)
```

**Arguments**

- `arr_scores` — scores prediction model gives.
- `arr_labels` — labels of samples, usually 1 for positive sample and 0 for negtive sample.

**Returned value**

Returns AUC value with type Float64.

**Example**

Query:

```
select arrayAUC([0.1, 0.4, 0.35, 0.8], [0, 0, 1, 1]);
```

Result:

```
┌─arrayAUC([0.1, 0.4, 0.35, 0.8], [0, 0, 1, 1])─┐
│                                          0.75 │
└───────────────────────────────────────────────┘
```

## arrayMap(func, arr1, …)

Returns an array obtained from the original application of the `func` function to each element in the `arr` array.

Examples:

```
SELECT arrayMap(x -> (x + 2), [1, 2, 3]) as res;
┌─res─────┐
│ [3,4,5] │
└─────────┘
```

The following example shows how to create a tuple of elements from different arrays:

```
SELECT arrayMap((x, y) -> (x, y), [1, 2, 3], [4, 5, 6]) AS res
┌─res─────────────────┐
│ [(1,4),(2,5),(3,6)] │
└─────────────────────┘
```

Note that the `arrayMap` is a [higher-order function]. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayFilter(func, arr1, …)

Returns an array containing only the elements in `arr1` for which `func` returns something other than 0.

Examples:

```
SELECT arrayFilter(x -> x LIKE %World%, [Hello, abc World]) AS res┌─res───────────┐│ [abc World] │└───────────────┘SELECT    arrayFilter(        (i, x) -> x LIKE %World%,        arrayEnumerate(arr),        [Hello, abc World] AS arr)    AS res┌─res─┐│ [2] │└─────┘
```

Note that the `arrayFilter` is a [higher-order function]. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayFill(func, arr1, …)

Scan through `arr1` from the first element to the last element and replace `arr1[i]` by `arr1[i - 1]` if `func` returns 0. The first element of `arr1` will not be replaced.

Examples:

```
SELECT arrayFill(x -> not isNull(x), [1, null, 3, 11, 12, null, null, 5, 6, 14, null, null]) AS res
┌─res──────────────────────────────┐
│ [1,1,3,11,12,12,12,5,6,14,14,14] │
└──────────────────────────────────┘
```

Note that the `arrayFill` is a [higher-order function]. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayReverseFill(func, arr1, …)

Scan through `arr1` from the last element to the first element and replace `arr1[i]` by `arr1[i + 1]` if `func` returns 0. The last element of `arr1` will not be replaced.

Examples:

```
SELECT arrayReverseFill(x -> not isNull(x), [1, null, 3, 11, 12, null, null, 5, 6, 14, null, null]) AS res
┌─res────────────────────────────────┐
│ [1,3,3,11,12,5,5,5,6,14,NULL,NULL] │
└────────────────────────────────────┘
```

Note that the `arrayReverseFill` is a [higher-order function]. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arraySplit(func, arr1, …)

Split `arr1` into multiple arrays. When `func` returns something other than 0, the array will be split on the left hand side of the element. The array will not be split before the first element.

Examples:

```
SELECT arraySplit((x, y) -> y, [1, 2, 3, 4, 5], [1, 0, 0, 1, 0]) AS res
┌─res─────────────┐
│ [[1,2,3],[4,5]] │
└─────────────────┘
```

Note that the `arraySplit` is a [higher-order function]. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayReverseSplit(func, arr1, …)

Split `arr1` into multiple arrays. When `func` returns something other than 0, the array will be split on the right hand side of the element. The array will not be split after the last element.

Examples:

```
SELECT arrayReverseSplit((x, y) -> y, [1, 2, 3, 4, 5], [1, 0, 0, 1, 0]) AS res┌─res───────────────┐│ [[1],[2,3,4],[5]] │└───────────────────┘
```

Note that the `arrayReverseSplit` is a [higher-order function]. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayExists([func,] arr1, …)

Returns 1 if there is at least one element in `arr` for which `func` returns something other than 0. Otherwise, it returns 0.

Note that the `arrayExists` is a [higher-order function]. You can pass a lambda function to it as the first argument.

## arrayAll([func,] arr1, …)

Returns 1 if `func` returns something other than 0 for all the elements in `arr`. Otherwise, it returns 0.

Note that the `arrayAll` is a [higher-order function]. You can pass a lambda function to it as the first argument.

## arrayFirst(func, arr1, …)

Returns the first element in the `arr1` array for which `func` returns something other than 0.

Note that the `arrayFirst` is a [higher-order function]. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayFirstIndex(func, arr1, …)

Returns the index of the first element in the `arr1` array for which `func` returns something other than 0.

Note that the `arrayFirstIndex` is a [higher-order function]. You must pass a lambda function to it as the first argument, and it can’t be omitted.

## arrayMin

Returns the minimum of elements in the source array.

If the `func` function is specified, returns the mininum of elements converted by this function.

Note that the `arrayMin` is a [higher-order function]. You can pass a lambda function to it as the first argument.

**Syntax**

```
arrayMin([func,] arr)
```

**Arguments**

- `func` — Function. [Expression].
- `arr` — Array. [Array].

**Returned value**

- The minimum of function values (or the array minimum).

Type: if `func` is specified, matches `func` return value type, else matches the array elements type.

**Examples**

Query:

```
SELECT arrayMin([1, 2, 4]) AS res;
```

Result:

```
┌─res─┐
│   1 │
└─────┘
```

Query:

```
SELECT arrayMin(x -> (-x), [1, 2, 4]) AS res;
```

Result:

```
┌─res─┐
│  -4 │
└─────┘
```

## arrayMax

Returns the maximum of elements in the source array.

If the `func` function is specified, returns the maximum of elements converted by this function.

Note that the `arrayMax` is a [higher-order function]. You can pass a lambda function to it as the first argument.

**Syntax**

```
arrayMax([func,] arr)
```

**Arguments**

- `func` — Function. [Expression].
- `arr` — Array. [Array].

**Returned value**

- The maximum of function values (or the array maximum).

Type: if `func` is specified, matches `func` return value type, else matches the array elements type.

**Examples**

Query:

```
SELECT arrayMax([1, 2, 4]) AS res;
```

Result:

```
┌─res─┐
│   4 │
└─────┘
```

Query:

```
SELECT arrayMax(x -> (-x), [1, 2, 4]) AS res;
```

Result:

```
┌─res─┐
│  -1 │
└─────┘
```

## arraySum

Returns the sum of elements in the source array.

If the `func` function is specified, returns the sum of elements converted by this function.

Note that the `arraySum` is a [higher-order function]. You can pass a lambda function to it as the first argument.

**Syntax**

```
arraySum([func,] arr)
```

**Arguments**

- `func` — Function. [Expression].
- `arr` — Array. [Array].

**Returned value**

- The sum of the function values (or the array sum).

Type: for decimal numbers in source array (or for converted values, if `func` is specified) — [Decimal128], for floating point numbers — [Float64], for numeric unsigned — [UInt64], and for numeric signed — [Int64].

**Examples**

Query:

```
SELECT arraySum([2, 3]) AS res;
```

Result:

```
┌─res─┐
│   5 │
└─────┘
```

Query:

```
SELECT arraySum(x -> x*x, [2, 3]) AS res;
```

Result:

```
┌─res─┐
│  13 │
└─────┘
```

## arrayAvg

Returns the average of elements in the source array.

If the `func` function is specified, returns the average of elements converted by this function.

Note that the `arrayAvg` is a [higher-order function]. You can pass a lambda function to it as the first argument.

**Syntax**

```
arrayAvg([func,] arr)
```

**Arguments**

- `func` — Function. [Expression].
- `arr` — Array. [Array].

**Returned value**

- The average of function values (or the array average).

Type: [Float64].

**Examples**

Query:

```
SELECT arrayAvg([1, 2, 4]) AS res;
```

Result:

```
┌────────────────res─┐
│ 2.3333333333333335 │
└────────────────────┘
```

Query:

```
SELECT arrayAvg(x -> (x * x), [2, 4]) AS res;
```

Result:

```
┌─res─┐
│  10 │
└─────┘
```

## arrayCumSum([func,] arr1, …)

Returns an array of partial sums of elements in the source array (a running sum). If the `func` function is specified, then the values of the array elements are converted by this function before summing.

Example:

```
SELECT arrayCumSum([1, 1, 1, 1]) AS res
┌─res──────────┐
│ [1, 2, 3, 4] │
└──────────────┘
```

Note that the `arrayCumSum` is a [higher-order function]. You can pass a lambda function to it as the first argument.

## arrayCumSumNonNegative(arr)

Same as `arrayCumSum`, returns an array of partial sums of elements in the source array (a running sum). Different `arrayCumSum`, when then returned value contains a value less than zero, the value is replace with zero and the subsequent calculation is performed with zero parameters. For example:

```
SELECT arrayCumSumNonNegative([1, 1, -4, 1]) AS res
┌─res───────┐
│ [1,2,0,1] │
└───────────┘
```

Note that the `arraySumNonNegative` is a [higher-order function]. You can pass a lambda function to it as the first argument.

## arrayProduct

Multiplies elements of an [array].

**Syntax**

```
arrayProduct(arr)
```

**Arguments**

- `arr` — [Array] of numeric values.

**Returned value**

- A product of arrays elements.

Type: [Float64].

**Examples**

Query:

```
SELECT arrayProduct([1,2,3,4,5,6]) as res;
```

Result:

```
┌─res───┐
│ 720   │
└───────┘
```

Query:

```
SELECT arrayProduct([toDecimal64(1,8), toDecimal64(2,8), toDecimal64(3,8)]) as res, toTypeName(res);
```

Return value type is always [Float64]. Result:

```
┌─res─┬─toTypeName(arrayProduct(array(toDecimal64(1, 8), toDecimal64(2, 8), toDecimal64(3, 8))))─┐
│ 6   │ Float64                                                                                  │
└─────┴──────────────────────────────────────────────────────────────────────────────────────────┘
```

' where id=44;


update biz_data_query_model_help_content set content_en = '# Functions for Working with Dates and Times

Support for time zones.

All functions for working with the date and time that have a logical use for the time zone can accept a second optional time zone argument. Example: Asia/Yekaterinburg. In this case, they use the specified time zone instead of the local (default) one.

```
SELECT
    toDateTime(2016-06-15 23:00:00) AS time,
    toDate(time) AS date_local,
    toDate(time, Asia/Yekaterinburg) AS date_yekat,
    toString(time, US/Samoa) AS time_samoa
┌────────────────time─┬─date_local─┬─date_yekat─┬─time_samoa──────────┐
│ 2016-06-15 23:00:00 │ 2016-06-15 │ 2016-06-16 │ 2016-06-15 09:00:00 │
└─────────────────────┴────────────┴────────────┴─────────────────────┘
```

## timeZone

Returns the timezone of the server.

**Syntax**

```
timeZone()
```

Alias: `timezone`.

**Returned value**

- Timezone.

Type: [String].

## toTimeZone

Converts time or date and time to the specified time zone. The time zone is an attribute of the `Date` and `DateTime` data types. The internal value (number of seconds) of the table field or of the resultsets column does not change, the columns type changes and its string representation changes accordingly.

**Syntax**

```
toTimezone(value, timezone)
```

Alias: `toTimezone`.

**Arguments**

- `value` — Time or date and time. [DateTime64].
- `timezone` — Timezone for the returned value. [String].

**Returned value**

- Date and time.

Type: [DateTime].

**Example**

Query:

```
SELECT toDateTime(2019-01-01 00:00:00, UTC) AS time_utc,
    toTypeName(time_utc) AS type_utc,
    toInt32(time_utc) AS int32utc,
    toTimeZone(time_utc, Asia/Yekaterinburg) AS time_yekat,
    toTypeName(time_yekat) AS type_yekat,
    toInt32(time_yekat) AS int32yekat,
    toTimeZone(time_utc, US/Samoa) AS time_samoa,
    toTypeName(time_samoa) AS type_samoa,
    toInt32(time_samoa) AS int32samoa
FORMAT Vertical;
```

Result:

```
Row 1:
──────
time_utc:   2019-01-01 00:00:00
type_utc:   DateTime(UTC)
int32utc:   1546300800
time_yekat: 2019-01-01 05:00:00
type_yekat: DateTime(Asia/Yekaterinburg)
int32yekat: 1546300800
time_samoa: 2018-12-31 13:00:00
type_samoa: DateTime(US/Samoa)
int32samoa: 1546300800
```

`toTimeZone(time_utc, Asia/Yekaterinburg)` changes the `DateTime(UTC)` type to `DateTime(Asia/Yekaterinburg)`. The value (Unixtimestamp) 1546300800 stays the same, but the string representation (the result of the toString() function) changes from `time_utc: 2019-01-01 00:00:00` to `time_yekat: 2019-01-01 05:00:00`.

## timeZoneOf

Returns the timezone name of [DateTime] or [DateTime64] data types.

**Syntax**

```
timeZoneOf(value)
```

Alias: `timezoneOf`.

**Arguments**

- `value` — Date and time. [DateTime] or [DateTime64].

**Returned value**

- Timezone name.

Type: [String].

**Example**

Query:

```
SELECT timezoneOf(now());
```

Result:

```
┌─timezoneOf(now())─┐
│ Etc/UTC           │
└───────────────────┘
```

## timeZoneOffset

Returns a timezone offset in seconds from [UTC]. The function takes into account [daylight saving time] and historical timezone changes at the specified date and time.
[IANA timezone database] is used to calculate the offset.

**Syntax**

```
timeZoneOffset(value)
```

Alias: `timezoneOffset`.

**Arguments**

- `value` — Date and time. [DateTime] or [DateTime64].

**Returned value**

- Offset from UTC in seconds.

Type: [Int32].

**Example**

Query:

```
SELECT toDateTime(2021-04-21 10:20:30, America/New_York) AS Time, toTypeName(Time) AS Type,
       timeZoneOffset(Time) AS Offset_in_seconds, (Offset_in_seconds / 3600) AS Offset_in_hours;
```

Result:

```
┌────────────────Time─┬─Type─────────────────────────┬─Offset_in_seconds─┬─Offset_in_hours─┐
│ 2021-04-21 10:20:30 │ DateTime(America/New_York) │            -14400 │              -4 │
└─────────────────────┴──────────────────────────────┴───────────────────┴─────────────────┘
```

## toYear

Converts a date or date with time to a UInt16 number containing the year number (AD).

Alias: `YEAR`.

## toQuarter

Converts a date or date with time to a UInt8 number containing the quarter number.

Alias: `QUARTER`.

## toMonth

Converts a date or date with time to a UInt8 number containing the month number (1-12).

Alias: `MONTH`.

## toDayOfYear

Converts a date or date with time to a UInt16 number containing the number of the day of the year (1-366).

Alias: `DAYOFYEAR`.

## toDayOfMonth

Converts a date or date with time to a UInt8 number containing the number of the day of the month (1-31).

Aliases: `DAYOFMONTH`, `DAY`.

## toDayOfWeek

Converts a date or date with time to a UInt8 number containing the number of the day of the week (Monday is 1, and Sunday is 7).

Alias: `DAYOFWEEK`.

## toHour

Converts a date with time to a UInt8 number containing the number of the hour in 24-hour time (0-23).
This function assumes that if clocks are moved ahead, it is by one hour and occurs at 2 a.m., and if clocks are moved back, it is by one hour and occurs at 3 a.m. (which is not always true – even in Moscow the clocks were twice changed at a different time).

Alias: `HOUR`.

## toMinute

Converts a date with time to a UInt8 number containing the number of the minute of the hour (0-59).

Alias: `MINUTE`.

## toSecond

Converts a date with time to a UInt8 number containing the number of the second in the minute (0-59).
Leap seconds are not accounted for.

Alias: `SECOND`.

## toUnixTimestamp

For DateTime argument: converts value to the number with type UInt32 -- Unix Timestamp .
For String argument: converts the input string to the datetime according to the timezone (optional second argument, server timezone is used by default) and returns the corresponding unix timestamp.

**Syntax**

```
toUnixTimestamp(datetime)
toUnixTimestamp(str, [timezone])
```

**Returned value**

- Returns the unix timestamp.

Type: `UInt32`.

**Example**

Query:

```
SELECT toUnixTimestamp(2017-11-05 08:07:47, Asia/Tokyo) AS unix_timestamp
```

Result:

```
┌─unix_timestamp─┐
│     1509836867 │
└────────────────┘
```

Attention

The return type `toStartOf*` functions described below is `Date` or `DateTime`. Though these functions can take `DateTime64` as an argument, passing them a `DateTime64` that is out of the normal range (years 1925 - 2283) will give an incorrect result.

## toStartOfYear

Rounds down a date or date with time to the first day of the year.
Returns the date.

## toStartOfISOYear

Rounds down a date or date with time to the first day of ISO year.
Returns the date.

## toStartOfQuarter

Rounds down a date or date with time to the first day of the quarter.
The first day of the quarter is either 1 January, 1 April, 1 July, or 1 October.
Returns the date.

## toStartOfMonth

Rounds down a date or date with time to the first day of the month.
Returns the date.

Attention

The behavior of parsing incorrect dates is implementation specific. ClickHouse may return zero date, throw an exception or do “natural” overflow.

## toMonday

Rounds down a date or date with time to the nearest Monday.
Returns the date.

## toStartOfWeek(t[,mode])

Rounds down a date or date with time to the nearest Sunday or Monday by mode.
Returns the date.
The mode argument works exactly like the mode argument to toWeek(). For the single-argument syntax, a mode value of 0 is used.

## toStartOfDay

Rounds down a date with time to the start of the day.

## toStartOfHour

Rounds down a date with time to the start of the hour.

## toStartOfMinute

Rounds down a date with time to the start of the minute.

## toStartOfSecond

Truncates sub-seconds.

**Syntax**

```
toStartOfSecond(value[, timezone])
```

**Arguments**

- `value` — Date and time. [DateTime64].
- `timezone` — [Timezone] for the returned value (optional). If not specified, the function uses the timezone of the `value` parameter. [String].

**Returned value**

- Input value without sub-seconds.

Type: [DateTime64].

**Examples**

Query without timezone:

```
WITH toDateTime64(2020-01-01 10:20:30.999, 3) AS dt64
SELECT toStartOfSecond(dt64);
```

Result:

```
┌───toStartOfSecond(dt64)─┐
│ 2020-01-01 10:20:30.000 │
└─────────────────────────┘
```

Query with timezone:

```
WITH toDateTime64(2020-01-01 10:20:30.999, 3) AS dt64
SELECT toStartOfSecond(dt64, Europe/Moscow);
```

Result:

```
┌─toStartOfSecond(dt64, Europe/Moscow)─┐
│                2020-01-01 13:20:30.000 │
└────────────────────────────────────────┘
```

**See also**

- [Timezone] server configuration parameter.

## toStartOfFiveMinute

Rounds down a date with time to the start of the five-minute interval.

## toStartOfTenMinutes

Rounds down a date with time to the start of the ten-minute interval.

## toStartOfFifteenMinutes

Rounds down the date with time to the start of the fifteen-minute interval.

## toStartOfInterval(time_or_data, INTERVAL x unit [, time_zone])

This is a generalization of other functions named `toStartOf*`. For example,
`toStartOfInterval(t, INTERVAL 1 year)` returns the same as `toStartOfYear(t)`,
`toStartOfInterval(t, INTERVAL 1 month)` returns the same as `toStartOfMonth(t)`,
`toStartOfInterval(t, INTERVAL 1 day)` returns the same as `toStartOfDay(t)`,
`toStartOfInterval(t, INTERVAL 15 minute)` returns the same as `toStartOfFifteenMinutes(t)` etc.

## toTime

Converts a date with time to a certain fixed date, while preserving the time.

## toRelativeYearNum

Converts a date with time or date to the number of the year, starting from a certain fixed point in the past.

## toRelativeQuarterNum

Converts a date with time or date to the number of the quarter, starting from a certain fixed point in the past.

## toRelativeMonthNum

Converts a date with time or date to the number of the month, starting from a certain fixed point in the past.

## toRelativeWeekNum

Converts a date with time or date to the number of the week, starting from a certain fixed point in the past.

## toRelativeDayNum

Converts a date with time or date to the number of the day, starting from a certain fixed point in the past.

## toRelativeHourNum

Converts a date with time or date to the number of the hour, starting from a certain fixed point in the past.

## toRelativeMinuteNum

Converts a date with time or date to the number of the minute, starting from a certain fixed point in the past.

## toRelativeSecondNum

Converts a date with time or date to the number of the second, starting from a certain fixed point in the past.

## toISOYear

Converts a date or date with time to a UInt16 number containing the ISO Year number.

## toISOWeek

Converts a date or date with time to a UInt8 number containing the ISO Week number.

## toWeek(date[,mode])

This function returns the week number for date or datetime. The two-argument form of toWeek() enables you to specify whether the week starts on Sunday or Monday and whether the return value should be in the range from 0 to 53 or from 1 to 53. If the mode argument is omitted, the default mode is 0.
`toISOWeek()`is a compatibility function that is equivalent to `toWeek(date,3)`.
The following table describes how the mode argument works.

| Mode | First day of week | Range | Week 1 is the first week …    |
| ---- | ----------------- | ----- | ----------------------------- |
| 0    | Sunday            | 0-53  | with a Sunday in this year    |
| 1    | Monday            | 0-53  | with 4 or more days this year |
| 2    | Sunday            | 1-53  | with a Sunday in this year    |
| 3    | Monday            | 1-53  | with 4 or more days this year |
| 4    | Sunday            | 0-53  | with 4 or more days this year |
| 5    | Monday            | 0-53  | with a Monday in this year    |
| 6    | Sunday            | 1-53  | with 4 or more days this year |
| 7    | Monday            | 1-53  | with a Monday in this year    |
| 8    | Sunday            | 1-53  | contains January 1            |
| 9    | Monday            | 1-53  | contains January 1            |

For mode values with a meaning of “with 4 or more days this year,” weeks are numbered according to ISO 8601:1988:

- If the week containing January 1 has 4 or more days in the new year, it is week 1.
- Otherwise, it is the last week of the previous year, and the next week is week 1.

For mode values with a meaning of “contains January 1”, the week contains January 1 is week 1. It does not matter how many days in the new year the week contained, even if it contained only one day.

```
toWeek(date, [, mode][, Timezone])
```

**Arguments**

- `date` – Date or DateTime.
- `mode` – Optional parameter, Range of values is [0,9], default is 0.
- `Timezone` – Optional parameter, it behaves like any other conversion function.

**Example**

```
SELECT toDate(2016-12-27) AS date, toWeek(date) AS week0, toWeek(date,1) AS week1, toWeek(date,9) AS week9;
┌───────date─┬─week0─┬─week1─┬─week9─┐
│ 2016-12-27 │    52 │    52 │     1 │
└────────────┴───────┴───────┴───────┘
```

## toYearWeek(date[,mode])

Returns year and week for a date. The year in the result may be different from the year in the date argument for the first and the last week of the year.

The mode argument works exactly like the mode argument to toWeek(). For the single-argument syntax, a mode value of 0 is used.

`toISOYear()`is a compatibility function that is equivalent to `intDiv(toYearWeek(date,3),100)`.

**Example**

```
SELECT toDate(2016-12-27) AS date, toYearWeek(date) AS yearWeek0, toYearWeek(date,1) AS yearWeek1, toYearWeek(date,9) AS yearWeek9;
┌───────date─┬─yearWeek0─┬─yearWeek1─┬─yearWeek9─┐
│ 2016-12-27 │    201652 │    201652 │    201701 │
└────────────┴───────────┴───────────┴───────────┘
```

## date_trunc

Truncates date and time data to the specified part of date.

**Syntax**

```
date_trunc(unit, value[, timezone])
```

Alias: `dateTrunc`.

**Arguments**

- `unit` — The type of interval to truncate the result. [String Literal].
  Possible values:
  - `second`
  - `minute`
  - `hour`
  - `day`
  - `week`
  - `month`
  - `quarter`
  - `year`
- `value` — Date and time. [DateTime] or [DateTime64].
- `timezone` — [Timezone name] for the returned value (optional). If not specified, the function uses the timezone of the `value` parameter. [String].

**Returned value**

- Value, truncated to the specified part of date.

Type: [Datetime].

**Example**

Query without timezone:

```
SELECT now(), date_trunc(hour, now());
```

Result:

```
┌───────────────now()─┬─date_trunc(hour, now())─┐
│ 2020-09-28 10:40:45 │       2020-09-28 10:00:00 │
└─────────────────────┴───────────────────────────┘
```

Query with the specified timezone:

```
SELECT now(), date_trunc(hour, now(), Europe/Moscow);
```

Result:

```
┌───────────────now()─┬─date_trunc(hour, now(), Europe/Moscow)─┐
│ 2020-09-28 10:46:26 │                        2020-09-28 13:00:00 │
└─────────────────────┴────────────────────────────────────────────┘
```

**See Also**

- [toStartOfInterval]

## date_add

Adds the time interval or date interval to the provided date or date with time.

**Syntax**

```
date_add(unit, value, date)
```

Aliases: `dateAdd`, `DATE_ADD`.

**Arguments**

- `unit` — The type of interval to add. [String].
  Possible values:
  - `second`
  - `minute`
  - `hour`
  - `day`
  - `week`
  - `month`
  - `quarter`
  - `year`
- `value` — Value of interval to add. [Int].
- `date` — The date or date with time to which `value` is added. [Date] or [DateTime].

**Returned value**

Date or date with time obtained by adding `value`, expressed in `unit`, to `date`.

Type: [Date] or [DateTime].

**Example**

Query:

```
SELECT date_add(YEAR, 3, toDate(2018-01-01));
```

Result:

```
┌─plus(toDate(2018-01-01), toIntervalYear(3))─┐
│                                    2021-01-01 │
└───────────────────────────────────────────────┘
```

## date_diff

Returns the difference between two dates or dates with time values.

**Syntax**

```
date_diff(unit, startdate, enddate, [timezone])
```

Aliases: `dateDiff`, `DATE_DIFF`.

**Arguments**

- `unit` — The type of interval for result. [String].
  Possible values:
  - `second`
  - `minute`
  - `hour`
  - `day`
  - `week`
  - `month`
  - `quarter`
  - `year`
- `startdate` — The first time value to subtract (the subtrahend). [Date] or [DateTime].
- `enddate` — The second time value to subtract from (the minuend). [Date] or [DateTime].
- `timezone` — [Timezone name] (optional). If specified, it is applied to both `startdate` and `enddate`. If not specified, timezones of `startdate` and `enddate` are used. If they are not the same, the result is unspecified. [String].

**Returned value**

Difference between `enddate` and `startdate` expressed in `unit`.

Type: [Int].

**Example**

Query:

```
SELECT dateDiff(hour, toDateTime(2018-01-01 22:00:00), toDateTime(2018-01-02 23:00:00));
```

Result:

```
┌─dateDiff(hour, toDateTime(2018-01-01 22:00:00), toDateTime(2018-01-02 23:00:00))─┐
│                                                                                     25 │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

## date_sub

Subtracts the time interval or date interval from the provided date or date with time.

**Syntax**

```
date_sub(unit, value, date)
```

Aliases: `dateSub`, `DATE_SUB`.

**Arguments**

- `unit` — The type of interval to subtract. [String].
  Possible values:
  - `second`
  - `minute`
  - `hour`
  - `day`
  - `week`
  - `month`
  - `quarter`
  - `year`
- `value` — Value of interval to subtract. [Int].
- `date` — The date or date with time from which `value` is subtracted. [Date] or [DateTime].

**Returned value**

Date or date with time obtained by subtracting `value`, expressed in `unit`, from `date`.

Type: [Date] or [DateTime].

**Example**

Query:

```
SELECT date_sub(YEAR, 3, toDate(2018-01-01));
```

Result:

```
┌─minus(toDate(2018-01-01), toIntervalYear(3))─┐
│                                     2015-01-01 │
└────────────────────────────────────────────────┘
```

## timestamp_add

Adds the specified time value with the provided date or date time value.

**Syntax**

```
timestamp_add(date, INTERVAL value unit)
```

Aliases: `timeStampAdd`, `TIMESTAMP_ADD`.

**Arguments**

- `date` — Date or date with time. [Date] or [DateTime].
- `value` — Value of interval to add. [Int].
- `unit` — The type of interval to add. [String].
  Possible values:
  - `second`
  - `minute`
  - `hour`
  - `day`
  - `week`
  - `month`
  - `quarter`
  - `year`

**Returned value**

Date or date with time with the specified `value` expressed in `unit` added to `date`.

Type: [Date] or [DateTime].

**Example**

Query:

```
select timestamp_add(toDate(2018-01-01), INTERVAL 3 MONTH);
```

Result:

```
┌─plus(toDate(2018-01-01), toIntervalMonth(3))─┐
│                                     2018-04-01 │
└────────────────────────────────────────────────┘
```

## timestamp_sub

Subtracts the time interval from the provided date or date with time.

**Syntax**

```
timestamp_sub(unit, value, date)
```

Aliases: `timeStampSub`, `TIMESTAMP_SUB`.

**Arguments**

- `unit` — The type of interval to subtract. [String].
  Possible values:
  - `second`
  - `minute`
  - `hour`
  - `day`
  - `week`
  - `month`
  - `quarter`
  - `year`
- `value` — Value of interval to subtract. [Int].
- `date` — Date or date with time. [Date] or [DateTime].

**Returned value**

Date or date with time obtained by subtracting `value`, expressed in `unit`, from `date`.

Type: [Date] or [DateTime].

**Example**

Query:

```
select timestamp_sub(MONTH, 5, toDateTime(2018-12-18 01:02:03));
```

Result:

```
┌─minus(toDateTime(2018-12-18 01:02:03), toIntervalMonth(5))─┐
│                                          2018-07-18 01:02:03 │
└──────────────────────────────────────────────────────────────┘
```

## now

Returns the current date and time.

**Syntax**

```
now([timezone])
```

**Arguments**

- `timezone` — [Timezone name] for the returned value (optional). [String].

**Returned value**

- Current date and time.

Type: [Datetime].

**Example**

Query without timezone:

```
SELECT now();
```

Result:

```
┌───────────────now()─┐
│ 2020-10-17 07:42:09 │
└─────────────────────┘
```

Query with the specified timezone:

```
SELECT now(Europe/Moscow);
```

Result:

```
┌─now(Europe/Moscow)─┐
│  2020-10-17 10:42:23 │
└──────────────────────┘
```

## today

Accepts zero arguments and returns the current date at one of the moments of request execution.
The same as ‘toDate(now())’.

## yesterday

Accepts zero arguments and returns yesterday’s date at one of the moments of request execution.
The same as ‘today() - 1’.

## timeSlot

Rounds the time to the half hour.
This function is specific to Yandex.Metrica, since half an hour is the minimum amount of time for breaking a session into two sessions if a tracking tag shows a single user’s consecutive pageviews that differ in time by strictly more than this amount. This means that tuples (the tag ID, user ID, and time slot) can be used to search for pageviews that are included in the corresponding session.

## toYYYYMM

Converts a date or date with time to a UInt32 number containing the year and month number (YYYY * 100 + MM).

## toYYYYMMDD

Converts a date or date with time to a UInt32 number containing the year and month number (YYYY * 1 + MM * 100 + DD).

## toYYYYMMDDhhmmss

Converts a date or date with time to a UInt64 number containing the year and month number (YYYY * 100 + MM * 1 + DD * 100 + hh * 1 + mm * 100 + ss).

## addYears, addMonths, addWeeks, addDays, addHours, addMinutes, addSeconds, addQuarters

Function adds a Date/DateTime interval to a Date/DateTime and then return the Date/DateTime. For example:

```
WITH
    toDate(2018-01-01) AS date,
    toDateTime(2018-01-01 00:00:00) AS date_time
SELECT
    addYears(date, 1) AS add_years_with_date,
    addYears(date_time, 1) AS add_years_with_date_time
┌─add_years_with_date─┬─add_years_with_date_time─┐
│          2019-01-01 │      2019-01-01 00:00:00 │
└─────────────────────┴──────────────────────────┘
```

## subtractYears, subtractMonths, subtractWeeks, subtractDays, subtractHours, subtractMinutes, subtractSeconds, subtractQuarters

Function subtract a Date/DateTime interval to a Date/DateTime and then return the Date/DateTime. For example:

```
WITH
    toDate(2019-01-01) AS date,
    toDateTime(2019-01-01 00:00:00) AS date_time
SELECT
    subtractYears(date, 1) AS subtract_years_with_date,
    subtractYears(date_time, 1) AS subtract_years_with_date_time
┌─subtract_years_with_date─┬─subtract_years_with_date_time─┐
│               2018-01-01 │           2018-01-01 00:00:00 │
└──────────────────────────┴───────────────────────────────┘
```

## timeSlots(StartTime, Duration,[, Size])

For a time interval starting at ‘StartTime’ and continuing for ‘Duration’ seconds, it returns an array of moments in time, consisting of points from this interval rounded down to the ‘Size’ in seconds. ‘Size’ is an optional parameter: a constant UInt32, set to 1800 by default.
For example, `timeSlots(toDateTime(2012-01-01 12:20:00), 600) = [toDateTime(2012-01-01 12:00:00), toDateTime(2012-01-01 12:30:00)]`.
This is necessary for searching for pageviews in the corresponding session.

## formatDateTime

Formats a Time according to the given Format string. Format is a constant expression, so you cannot have multiple formats for a single result column.

**Syntax**

```
formatDateTime(Time, Format\[, Timezone\])
```

**Returned value(s)**

Returns time and date values according to the determined format.

**Replacement fields**
Using replacement fields, you can define a pattern for the resulting string. “Example” column shows formatting result for `2018-01-02 22:33:44`.

| Placeholder | Description                                                  | Example    |
| ----------- | ------------------------------------------------------------ | ---------- |
| %C          | year divided by 100 and truncated to integer (00-99)         | 20         |
| %d          | day of the month, zero-padded (01-31)                        | 02         |
| %D          | Short MM/DD/YY date, equivalent to %m/%d/%y                  | 01/02/18   |
| %e          | day of the month, space-padded ( 1-31)                       | 2          |
| %F          | short YYYY-MM-DD date, equivalent to %Y-%m-%d                | 2018-01-02 |
| %G          | four-digit year format for ISO week number, calculated from the week-based year [defined by the ISO 8601] standard, normally useful only with %V | 2018       |
| %g          | two-digit year format, aligned to ISO 8601, abbreviated from four-digit notation | 18         |
| %H          | hour in 24h format (00-23)                                   | 22         |
| %I          | hour in 12h format (01-12)                                   | 10         |
| %j          | day of the year (001-366)                                    | 002        |
| %m          | month as a decimal number (01-12)                            | 01         |
| %M          | minute (00-59)                                               | 33         |
| %n          | new-line character (‘’)                                      |            |
| %p          | AM or PM designation                                         | PM         |
| %Q          | Quarter (1-4)                                                | 1          |
| %R          | 24-hour HH:MM time, equivalent to %H:%M                      | 22:33      |
| %S          | second (00-59)                                               | 44         |
| %t          | horizontal-tab character (’)                                 |            |
| %T          | ISO 8601 time format (HH:MM:SS), equivalent to %H:%M:%S      | 22:33:44   |
| %u          | ISO 8601 weekday as number with Monday as 1 (1-7)            | 2          |
| %V          | ISO 8601 week number (01-53)                                 | 01         |
| %w          | weekday as a decimal number with Sunday as 0 (0-6)           | 2          |
| %y          | Year, last two digits (00-99)                                | 18         |
| %Y          | Year                                                         | 2018       |
| %%          | a % sign                                                     | %          |

**Example**

Query:

```
SELECT formatDateTime(toDate(2010-01-04), %g)
```

Result:

```
┌─formatDateTime(toDate(2010-01-04), %g)─┐
│ 10                                         │
└────────────────────────────────────────────┘
```

## dateName

Returns specified part of date.

**Syntax**

```
dateName(date_part, date)
```

**Arguments**

- `date_part` — Date part. Possible values: year, quarter, month, week, dayofyear, day, weekday, hour, minute, second. [String].
- `date` — Date. [Date], [DateTime] or [DateTime64].
- `timezone` — Timezone. Optional. [String].

**Returned value**

- The specified part of date.

Type: [String]

**Example**

Query:

```
WITH toDateTime(2021-04-14 11:22:33) AS date_value
SELECT dateName(year, date_value), dateName(month, date_value), dateName(day, date_value);
```

Result:

```
┌─dateName(year, date_value)─┬─dateName(month, date_value)─┬─dateName(day, date_value)─┐
│ 2021                         │ April                         │ 14                          │
└──────────────────────────────┴───────────────────────────────┴─────────────────────────────
```

## FROM_UNIXTIME

Function converts Unix timestamp to a calendar date and a time of a day. When there is only a single argument of [Integer] type, it acts in the same way as [toDateTime] and return [DateTime] type.

**Example:**

Query:

```
SELECT FROM_UNIXTIME(423543535);
```

Result:

```
┌─FROM_UNIXTIME(423543535)─┐
│      1983-06-04 10:58:55 │
└──────────────────────────┘
```

When there are two arguments: first is an [Integer] or [DateTime], second is a constant format string — it acts in the same way as [formatDateTime] and return [String] type.

For example:

```
SELECT FROM_UNIXTIME(1234334543, %Y-%m-%d %R:%S) AS DateTime;
┌─DateTime────────────┐
│ 2009-02-11 14:42:23 │
└─────────────────────┘
```

## toModifiedJulianDay

Converts a [Proleptic Gregorian calendar] date in text form `YYYY-MM-DD` to a [Modified Julian Day] number in Int32. This function supports date from `-01-01` to `9999-12-31`. It raises an exception if the argument cannot be parsed as a date, or the date is invalid.

**Syntax**

```
toModifiedJulianDay(date)
```

**Arguments**

- `date` — Date in text form. [String] or [FixedString].

**Returned value**

- Modified Julian Day number.

Type: [Int32].

**Example**

Query:

```
SELECT toModifiedJulianDay(2020-01-01);
```

Result:

```
┌─toModifiedJulianDay(2020-01-01)─┐
│                             58849 │
└───────────────────────────────────┘
```

## toModifiedJulianDayOrNull

Similar to [toModifiedJulianDay()], but instead of raising exceptions it returns `NULL`.

**Syntax**

```
toModifiedJulianDayOrNull(date)
```

**Arguments**

- `date` — Date in text form. [String] or [FixedString].

**Returned value**

- Modified Julian Day number.

Type: [Nullable(Int32)].

**Example**

Query:

```
SELECT toModifiedJulianDayOrNull(2020-01-01);
```

Result:

```
┌─toModifiedJulianDayOrNull(2020-01-01)─┐
│                                   58849 │
└─────────────────────────────────────────┘
```

## fromModifiedJulianDay

Converts a [Modified Julian Day] number to a [Proleptic Gregorian calendar] date in text form `YYYY-MM-DD`. This function supports day number from `-678941` to `2973119` (which represent -01-01 and 9999-12-31 respectively). It raises an exception if the day number is outside of the supported range.

**Syntax**

```
fromModifiedJulianDay(day)
```

**Arguments**

- `day` — Modified Julian Day number. [Any integral types].

**Returned value**

- Date in text form.

Type: [String]

**Example**

Query:

```
SELECT fromModifiedJulianDay(58849);
```

Result:

```
┌─fromModifiedJulianDay(58849)─┐
│ 2020-01-01                   │
└──────────────────────────────┘
```

## fromModifiedJulianDayOrNull

Similar to [fromModifiedJulianDayOrNull()], but instead of raising exceptions it returns `NULL`.

**Syntax**

```
fromModifiedJulianDayOrNull(day)
```

**Arguments**

- `day` — Modified Julian Day number. [Any integral types].

**Returned value**

- Date in text form.

Type: [Nullable(String)]

**Example**

Query:

```
SELECT fromModifiedJulianDayOrNull(58849);
```

Result:

```
┌─fromModifiedJulianDayOrNull(58849)─┐
│ 2020-01-01                         │
└────────────────────────────────────┘
```

' where id=45;


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
\- `beats_control` — long-term probability to out-perform the first (control) variant
\- `to_be_best` — long-term probability to out-perform all other variants

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
update biz_data_query_model_help_content set content_en = '# Conditional Functions

## if

Controls conditional branching. Unlike most systems, ClickHouse always evaluate both expressions `then` and `else`.

**Syntax**

```
SELECT if(cond, then, else)
```

If the condition `cond` evaluates to a non-zero value, returns the result of the expression `then`, and the result of the expression `else`, if present, is skipped. If the `cond` is zero or `NULL`, then the result of the `then` expression is skipped and the result of the `else` expression, if present, is returned.

**Arguments**

- `cond` – The condition for evaluation that can be zero or not. The type is UInt8, Nullable(UInt8) or NULL.
- `then` – The expression to return if condition is met.
- `else` – The expression to return if condition is not met.

**Returned values**

The function executes `then` and `else` expressions and returns its result, depending on whether the condition `cond` ended up being zero or not.

**Example**

Query:

```
SELECT if(1, plus(2, 2), plus(2, 6));
```

Result:

```
┌─plus(2, 2)─┐
│          4 │
└────────────┘
```

Query:

```
SELECT if(0, plus(2, 2), plus(2, 6));
```

Result:

```
┌─plus(2, 6)─┐
│          8 │
└────────────┘
```

- `then` and `else` must have the lowest common type.

**Example:**

Take this `LEFT_RIGHT` table:

```
SELECT *
FROM LEFT_RIGHT

┌─left─┬─right─┐
│ ᴺᵁᴸᴸ │     4 │
│    1 │     3 │
│    2 │     2 │
│    3 │     1 │
│    4 │  ᴺᵁᴸᴸ │
└──────┴───────┘
```

The following query compares `left` and `right` values:

```
SELECT
    left,
    right,
    if(left < right, left is smaller than right, right is greater or equal than left) AS is_smaller
FROM LEFT_RIGHT
WHERE isNotNull(left) AND isNotNull(right)

┌─left─┬─right─┬─is_smaller──────────────────────────┐
│    1 │     3 │ left is smaller than right          │
│    2 │     2 │ right is greater or equal than left │
│    3 │     1 │ right is greater or equal than left │
└──────┴───────┴─────────────────────────────────────┘
```

Note: `NULL` values are not used in this example, check [NULL values in conditionals] section.

## Ternary Operator

It works same as `if` function.

Syntax: `cond ? then : else`

Returns `then` if the `cond` evaluates to be true (greater than zero), otherwise returns `else`.

- `cond` must be of type of `UInt8`, and `then` and `else` must have the lowest common type.
- `then` and `else` can be `NULL`

**See also**

- [ifNotFinite].

## multiIf

Allows you to write the [CASE] operator more compactly in the query.

Syntax: `multiIf(cond_1, then_1, cond_2, then_2, ..., else)`

**Arguments:**

- `cond_N` — The condition for the function to return `then_N`.
- `then_N` — The result of the function when executed.
- `else` — The result of the function if none of the conditions is met.

The function accepts `2N+1` parameters.

**Returned values**

The function returns one of the values `then_N` or `else`, depending on the conditions `cond_N`.

**Example**

Again using `LEFT_RIGHT` table.

```
SELECT
    left,
    right,
    multiIf(left < right, left is smaller, left > right, left is greater, left = right, Both equal, Null value) AS result
FROM LEFT_RIGHT

┌─left─┬─right─┬─result──────────┐
│ ᴺᵁᴸᴸ │     4 │ Null value      │
│    1 │     3 │ left is smaller │
│    2 │     2 │ Both equal      │
│    3 │     1 │ left is greater │
│    4 │  ᴺᵁᴸᴸ │ Null value      │
└──────┴───────┴─────────────────┘
```

## Using Conditional Results Directly

Conditionals always result to `0`, `1` or `NULL`. So you can use conditional results directly like this:

```
SELECT left < right AS is_small
FROM LEFT_RIGHT

┌─is_small─┐
│     ᴺᵁᴸᴸ │
│        1 │
│        0 │
│        0 │
│     ᴺᵁᴸᴸ │
└──────────┘
```

## NULL Values in Conditionals

When `NULL` values are involved in conditionals, the result will also be `NULL`.

```
SELECT
    NULL < 1,
    2 < NULL,
    NULL < NULL,
    NULL = NULL

┌─less(NULL, 1)─┬─less(2, NULL)─┬─less(NULL, NULL)─┬─equals(NULL, NULL)─┐
│ ᴺᵁᴸᴸ          │ ᴺᵁᴸᴸ          │ ᴺᵁᴸᴸ             │ ᴺᵁᴸᴸ               │
└───────────────┴───────────────┴──────────────────┴────────────────────┘
```

So you should construct your queries carefully if the types are `Nullable`.

The following example demonstrates this by failing to add equals condition to `multiIf`.

```
SELECT
    left,
    right,
    multiIf(left < right, left is smaller, left > right, right is smaller, Both equal) AS faulty_result
FROM LEFT_RIGHT

┌─left─┬─right─┬─faulty_result────┐
│ ᴺᵁᴸᴸ │     4 │ Both equal       │
│    1 │     3 │ left is smaller  │
│    2 │     2 │ Both equal       │
│    3 │     1 │ right is smaller │
│    4 │  ᴺᵁᴸᴸ │ Both equal       │
└──────┴───────┴──────────────────┘
```

' where id=47;
update biz_data_query_model_help_content set content_en = '# Encoding Functions

## char

Returns the string with the length as the number of passed arguments and each byte has the value of corresponding argument. Accepts multiple arguments of numeric types. If the value of argument is out of range of UInt8 data type, it is converted to UInt8 with possible rounding and overflow.

**Syntax**

```
char(number_1, [number_2, ..., number_n]);
```

**Arguments**

- `number_1, number_2, ..., number_n` — Numerical arguments interpreted as integers. Types: [Int], [Float].

**Returned value**

- a string of given bytes.

Type: `String`.

**Example**

Query:

```
SELECT char(104.1, 101, 108.9, 108.9, 111) AS hello;
```

Result:

```
┌─hello─┐
│ hello │
└───────┘
```

You can construct a string of arbitrary encoding by passing the corresponding bytes. Here is example for UTF-8:

Query:

```
SELECT char(0xD0, 0xBF, 0xD1, 0x80, 0xD0, 0xB8, 0xD0, 0xB2, 0xD0, 0xB5, 0xD1, 0x82) AS hello;
```

Result:

```
┌─hello──┐
│ привет │
└────────┘
```

Query:

```
SELECT char(0xE4, 0xBD, 0xA0, 0xE5, 0xA5, 0xBD) AS hello;
```

Result:

```
┌─hello─┐
│ 你好  │
└───────┘
```

## hex

Returns a string containing the argument’s hexadecimal representation.

Alias: `HEX`.

**Syntax**

```
hex(arg)
```

The function is using uppercase letters `A-F` and not using any prefixes (like `0x`) or suffixes (like `h`).

For integer arguments, it prints hex digits (“nibbles”) from the most significant to least significant (big endian or “human readable” order). It starts with the most significant non-zero byte (leading zero bytes are omitted) but always prints both digits of every byte even if leading digit is zero.

**Example**

Query:

```
SELECT hex(1);
```

Result:

```
01
```

Values of type `Date` and `DateTime` are formatted as corresponding integers (the number of days since Epoch for Date and the value of Unix Timestamp for DateTime).

For `String` and `FixedString`, all bytes are simply encoded as two hexadecimal numbers. Zero bytes are not omitted.

Values of floating point and Decimal types are encoded as their representation in memory. As we support little endian architecture, they are encoded in little endian. Zero leading/trailing bytes are not omitted.

**Arguments**

- `arg` — A value to convert to hexadecimal. Types: [String], [UInt], [Float], [Decimal], [Date] or [DateTime].

**Returned value**

- A string with the hexadecimal representation of the argument.

Type: `String`.

**Example**

Query:

```
SELECT hex(toFloat32(number)) as hex_presentation FROM numbers(15, 2);
```

Result:

```
┌─hex_presentation─┐
│ 7041         │
│ 8041         │
└──────────────────┘
```

Query:

```
SELECT hex(toFloat64(number)) as hex_presentation FROM numbers(15, 2);
```

Result:

```
┌─hex_presentation─┐
│ 2E40 │
│ 3040 │
└──────────────────┘
```

## unhex

Performs the opposite operation of [hex]. It interprets each pair of hexadecimal digits (in the argument) as a number and converts it to the byte represented by the number. The return value is a binary string (BLOB).

If you want to convert the result to a number, you can use the [reverse] and [reinterpretAs] functions.

Note

If `unhex` is invoked from within the `clickhouse-client`, binary strings display using UTF-8.

Alias: `UNHEX`.

**Syntax**

```
unhex(arg)
```

**Arguments**

- `arg` — A string containing any number of hexadecimal digits. Type: [String].

Supports both uppercase and lowercase letters `A-F`. The number of hexadecimal digits does not have to be even. If it is odd, the last digit is interpreted as the least significant half of the `00-0F` byte. If the argument string contains anything other than hexadecimal digits, some implementation-defined result is returned (an exception isn’t thrown). For a numeric argument the inverse of hex(N) is not performed by unhex().

**Returned value**

- A binary string (BLOB).

Type: [String].

**Example**

Query:

```
SELECT unhex(303132), UNHEX(4D7953514C);
```

Result:

```
┌─unhex(303132)─┬─unhex(4D7953514C)─┐
│ 012             │ MySQL               │
└─────────────────┴─────────────────────┘
```

Query:

```
SELECT reinterpretAsUInt64(reverse(unhex(FFF))) AS num;
```

Result:

```
┌──num─┐
│ 4095 │
└──────┘
```

## UUIDStringToNum(str)

Accepts a string containing 36 characters in the format `123e4567-e89b-12d3-a456-42665544`, and returns it as a set of bytes in a FixedString(16).

## UUIDNumToString(str)

Accepts a FixedString(16) value. Returns a string containing 36 characters in text format.

## bitmaskToList(num)

Accepts an integer. Returns a string containing the list of powers of two that total the source number when summed. They are comma-separated without spaces in text format, in ascending order.

## bitmaskToArray(num)

Accepts an integer. Returns an array of UInt64 numbers containing the list of powers of two that total the source number when summed. Numbers in the array are in ascending order.

## bitPositionsToArray(num)

Accepts an integer and converts it to an unsigned integer. Returns an array of `UInt64` numbers containing the list of positions of bits of `arg` that equal `1`, in ascending order.

**Syntax**

```
bitPositionsToArray(arg)
```

**Arguments**

- `arg` — Integer value. [Int/UInt].

**Returned value**

- An array containing a list of positions of bits that equal `1`, in ascending order.

Type: [Array]([UInt64]).

**Example**

Query:

```
SELECT bitPositionsToArray(toInt8(1)) AS bit_positions;
```

Result:

```
┌─bit_positions─┐
│ [0]           │
└───────────────┘
```

Query:

```
select bitPositionsToArray(toInt8(-1)) as bit_positions;
```

Result:

```
┌─bit_positions─────┐
│ [0,1,2,3,4,5,6,7] │
└───────────────────┘
```

' where id=48;
update biz_data_query_model_help_content set content_en = '# Functions for Generating Pseudo-Random Numbers

All the functions accept zero arguments or one argument. If an argument is passed, it can be any type, and its value is not used for anything. The only purpose of this argument is to prevent common subexpression elimination, so that two different instances of the same function return different columns with different random numbers.

Note

Non-cryptographic generators of pseudo-random numbers are used.

## rand, rand32

Returns a pseudo-random UInt32 number, evenly distributed among all UInt32-type numbers.

Uses a linear congruential generator.

## rand64

Returns a pseudo-random UInt64 number, evenly distributed among all UInt64-type numbers.

Uses a linear congruential generator.

## randConstant

Produces a constant column with a random value.

**Syntax**

```
randConstant([x])
```

**Arguments**

- `x` — [Expression] resulting in any of the [supported data types]. The resulting value is discarded, but the expression itself if used for bypassing [common subexpression elimination] if the function is called multiple times in one query. Optional parameter.

**Returned value**

- Pseudo-random number.

Type: [UInt32].

**Example**

Query:

```
SELECT rand(), rand(1), rand(number), randConstant(), randConstant(1), randConstant(number)
FROM numbers(3)
```

Result:

```
┌─────rand()─┬────rand(1)─┬─rand(number)─┬─randConstant()─┬─randConstant(1)─┬─randConstant(number)─┐
│ 3047369878 │ 4132449925 │   4044508545 │     2740811946 │      4229401477 │           1924032898 │
│ 2938880146 │ 1267722397 │   4154983056 │     2740811946 │      4229401477 │           1924032898 │
│  956619638 │ 4238287282 │   1104342490 │     2740811946 │      4229401477 │           1924032898 │
└────────────┴────────────┴──────────────┴────────────────┴─────────────────┴──────────────────────┘
```

# Random Functions for Working with Strings

## randomString

## randomFixedString

## randomPrintableASCII

## randomStringUTF8

## fuzzBits

**Syntax**

```
fuzzBits([s], [prob])
```

Inverts bits of `s`, each with probability `prob`.

**Arguments**
\- `s` - `String` or `FixedString`
\- `prob` - constant `Float32/64`

**Returned value**
Fuzzed string with same as s type.

**Example**

```
SELECT fuzzBits(materialize(abacaba), 0.1)
FROM numbers(3)
```

``` text
┌─fuzzBits(materialize(‘abacaba’), 0.1)─┐
│ abaaaja │
│ a*cjab+ │
│ aeca2A │
└───────────────────────────────────────┘
```

' where id=49;
update biz_data_query_model_help_content set content_en = '####Higher-order function

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
update biz_data_query_model_help_content set content_en = '#AggregateFunctions

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
┌─sumOrNull(number)─┬─toTypeName(sumOrNull(number))─┐│              ᴺᵁᴸᴸ │ Nullable(UInt64)              │└───────────────────┴───────────────────────────────┘
```

Also `-OrNull` can be used with another combinators. It is useful when the aggregate function does not accept the empty input.

Query:

```
SELECT avgOrNullIf(x, x > 10)FROM(    SELECT toDecimal32(1.23, 2) AS x)
```

Result:

```
┌─avgOrNullIf(x, greater(x, 10))─┐│                           ᴺᵁᴸᴸ │└────────────────────────────────┘
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
┌─name───┬─age─┬─wage─┐│ John   │  16 │   10 ││ Alice  │  30 │   15 ││ Mary   │  35 │    8 ││ Evelyn │  48 │ 11.5 ││ David  │  62 │  9.9 ││ Brian  │  60 │   16 │└────────┴─────┴──────┘
```

Let’s get the names of the people whose age lies in the intervals of `[30,60)` and `[60,75)`. Since we use integer representation for age, we get ages in the `[30, 59]` and `[60,74]` intervals.

To aggregate names in an array, we use the [groupArray] aggregate function. It takes one argument. In our case, it’s the `name` column. The `groupArrayResample` function should use the `age` column to aggregate names by age. To define the required intervals, we pass the `30, 75, 30` arguments into the `groupArrayResample` function.

```
SELECT groupArrayResample(30, 75, 30)(name, age) FROM people┌─groupArrayResample(30, 75, 30)(name, age)─────┐│ [[Alice,Mary,Evelyn],[David,Brian]] │└───────────────────────────────────────────────┘
```

Consider the results.

`Jonh` is out of the sample because he’s too young. Other people are distributed according to the specified age intervals.

Now let’s count the total number of people and their average wage in the specified age intervals.

```
SELECT    countResample(30, 75, 30)(name, age) AS amount,    avgResample(30, 75, 30)(wage, age) AS avg_wageFROM people┌─amount─┬─avg_wage──────────────────┐│ [3,2]  │ [11.5,12.949999809265137] │└────────┴───────────────────────────┘
```

' where id=53;


update biz_data_query_model_help_content set content_en = '# Parametric Aggregate Functions

Some aggregate functions can accept not only argument columns (used for compression), but a set of parameters – constants for initialization. The syntax is two pairs of brackets instead of one. The first is for parameters, and the second is for arguments.

## histogram

Calculates an adaptive histogram. It does not guarantee precise results.

```
histogram(number_of_bins)(values)
```

The functions uses [A Streaming Parallel Decision Tree Algorithm](http://jmlr.org/papers/volume11/ben-haim10a/ben-haim10a.pdf). The borders of histogram bins are adjusted as new data enters a function. In common case, the widths of bins are not equal.

**Arguments**

`values` — [Expression] resulting in input values.

**Parameters**

`number_of_bins` — Upper limit for the number of bins in the histogram. The function automatically calculates the number of bins. It tries to reach the specified number of bins, but if it fails, it uses fewer bins.

**Returned values**

- Array



  of



  Tuples



  of the following format:

  ```

  ```

  [(lower_1, upper_1, height_1), ... (lower_N, upper_N, height_N)]

  ```
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
┌─time─┬─number─┐│    1 │      1 ││    2 │      3 ││    3 │      2 ││    4 │      1 ││    5 │      3 ││    6 │      2 │└──────┴────────┘
```

Count how many times the number 2 occurs after the number 1 with any amount of other numbers between them:

```
SELECT sequenceCount((?1).*(?2))(time, number = 1, number = 2) FROM t┌─sequenceCount((?1).*(?2))(time, equals(number, 1), equals(number, 2))─┐│                                                                       2 │└─────────────────────────────────────────────────────────────────────────┘
```

**See Also**

- [sequenceMatch]

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
┌─event_date─┬─user_id─┬───────────timestamp─┬─eventID─┬─product─┐│ 2019-01-28 │       1 │ 2019-01-29 10:00:00 │    1003 │ phone   │└────────────┴─────────┴─────────────────────┴─────────┴─────────┘┌─event_date─┬─user_id─┬───────────timestamp─┬─eventID─┬─product─┐│ 2019-01-31 │       1 │ 2019-01-31 09:00:00 │    1007 │ phone   │└────────────┴─────────┴─────────────────────┴─────────┴─────────┘┌─event_date─┬─user_id─┬───────────timestamp─┬─eventID─┬─product─┐│ 2019-01-30 │       1 │ 2019-01-30 08:00:00 │    1009 │ phone   │└────────────┴─────────┴─────────────────────┴─────────┴─────────┘┌─event_date─┬─user_id─┬───────────timestamp─┬─eventID─┬─product─┐│ 2019-02-01 │       1 │ 2019-02-01 08:00:00 │    1010 │ phone   │└────────────┴─────────┴─────────────────────┴─────────┴─────────┘
```

Find out how far the user `user_id` could get through the chain in a period in January-February of 2019.

Query:

```
SELECT    level,    count() AS cFROM(    SELECT        user_id,        windowFunnel(6048)(timestamp, eventID = 1003, eventID = 1009, eventID = 1007, eventID = 1010) AS level    FROM trend    WHERE (event_date >= 2019-01-01) AND (event_date <= 2019-02-02)    GROUP BY user_id)GROUP BY levelORDER BY level ASC;
```

Result:

```
┌─level─┬─c─┐│     4 │ 1 │└───────┴───┘
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
┌───────date─┬─uid─┐│ 2020-01-01 │   0 ││ 2020-01-01 │   1 ││ 2020-01-01 │   2 ││ 2020-01-01 │   3 ││ 2020-01-01 │   4 │└────────────┴─────┘┌───────date─┬─uid─┐│ 2020-01-02 │   0 ││ 2020-01-02 │   1 ││ 2020-01-02 │   2 ││ 2020-01-02 │   3 ││ 2020-01-02 │   4 ││ 2020-01-02 │   5 ││ 2020-01-02 │   6 ││ 2020-01-02 │   7 ││ 2020-01-02 │   8 ││ 2020-01-02 │   9 │└────────────┴─────┘┌───────date─┬─uid─┐│ 2020-01-03 │   0 ││ 2020-01-03 │   1 ││ 2020-01-03 │   2 ││ 2020-01-03 │   3 ││ 2020-01-03 │   4 ││ 2020-01-03 │   5 ││ 2020-01-03 │   6 ││ 2020-01-03 │   7 ││ 2020-01-03 │   8 ││ 2020-01-03 │   9 ││ 2020-01-03 │  10 ││ 2020-01-03 │  11 ││ 2020-01-03 │  12 ││ 2020-01-03 │  13 ││ 2020-01-03 │  14 │└────────────┴─────┘
```

**2.** Group users by unique ID `uid` using the `retention` function.

Query:

```
SELECT    uid,    retention(date = 2020-01-01, date = 2020-01-02, date = 2020-01-03) AS rFROM retention_testWHERE date IN (2020-01-01, 2020-01-02, 2020-01-03)GROUP BY uidORDER BY uid ASC
```

Result:

```
┌─uid─┬─r───────┐│   0 │ [1,1,1] ││   1 │ [1,1,1] ││   2 │ [1,1,1] ││   3 │ [1,1,1] ││   4 │ [1,1,1] ││   5 │ [0,0,0] ││   6 │ [0,0,0] ││   7 │ [0,0,0] ││   8 │ [0,0,0] ││   9 │ [0,0,0] ││  10 │ [0,0,0] ││  11 │ [0,0,0] ││  12 │ [0,0,0] ││  13 │ [0,0,0] ││  14 │ [0,0,0] │└─────┴─────────┘
```

**3.** Calculate the total number of site visits per day.

Query:

```
SELECT    sum(r[1]) AS r1,    sum(r[2]) AS r2,    sum(r[3]) AS r3FROM(    SELECT        uid,        retention(date = 2020-01-01, date = 2020-01-02, date = 2020-01-03) AS r    FROM retention_test    WHERE date IN (2020-01-01, 2020-01-02, 2020-01-03)    GROUP BY uid)
```

Result:

```
┌─r1─┬─r2─┬─r3─┐│  5 │  5 │  5 │└────┴────┴────┘
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

Same behavior as [sumMap] except that an array of keys is passed as a parameter. This can be especially useful when working with a high cardinality of keys.

## sequenceNextNode

Returns a value of the next event that matched an event chain.

*Experimental function, `SET allow_experimental_funnel_functions = 1` to enable it.*

**Syntax**

```
sequenceNextNode(direction, base)(timestamp, event_column, base_condition, event1, event2, event3, ...)
```

**Parameters**

- `direction` — Used to navigate to directions.
  - forward — Moving forward.
  - backward — Moving backward.
- `base` — Used to set the base point.
  - head — Set the base point to the first event.
  - tail — Set the base point to the last event.
  - first_match — Set the base point to the first matched `event1`.
  - last_match — Set the base point to the last matched `event1`.

**Arguments**

- `timestamp` — Name of the column containing the timestamp. Data types supported: [Date], [DateTime] and other unsigned integer types.
- `event_column` — Name of the column containing the value of the next event to be returned. Data types supported: [String] and [Nullable(String)].
- `base_condition` — Condition that the base point must fulfill.
- `event1`, `event2`, ... — Conditions describing the chain of events. [UInt8].

**Returned values**

- `event_column[next_index]` — If the pattern is matched and next value exists.
- `NULL` - If the pattern isn’t matched or next value doesnt exist.

Type: [Nullable(String)].

**Example**

It can be used when events are A->B->C->D->E and you want to know the event following B->C, which is D.

The query statement searching the event following A->B:

```
CREATE TABLE test_flow (    dt DateTime,     id int,     page String)ENGINE = MergeTree() PARTITION BY toYYYYMMDD(dt) ORDER BY id;INSERT INTO test_flow VALUES (1, 1, A) (2, 1, B) (3, 1, C) (4, 1, D) (5, 1, E);SELECT id, sequenceNextNode(forward, head)(dt, page, page = A, page = A, page = B) as next_flow FROM test_flow GROUP BY id;
```

Result:

```
┌─id─┬─next_flow─┐│  1 │ C         │└────┴───────────┘
```

**Behavior for `forward` and `head`**

```
ALTER TABLE test_flow DELETE WHERE 1 = 1 settings mutations_sync = 1;INSERT INTO test_flow VALUES (1, 1, Home) (2, 1, Gift) (3, 1, Exit);INSERT INTO test_flow VALUES (1, 2, Home) (2, 2, Home) (3, 2, Gift) (4, 2, Basket);INSERT INTO test_flow VALUES (1, 3, Gift) (2, 3, Home) (3, 3, Gift) (4, 3, Basket);SELECT id, sequenceNextNode(forward, head)(dt, page, page = Home, page = Home, page = Gift) FROM test_flow GROUP BY id;                  dt   id   page 1970-01-01 09:00:01    1   Home // Base point, Matched with Home 1970-01-01 09:00:02    1   Gift // Matched with Gift 1970-01-01 09:00:03    1   Exit // The result  1970-01-01 09:00:01    2   Home // Base point, Matched with Home 1970-01-01 09:00:02    2   Home // Unmatched with Gift 1970-01-01 09:00:03    2   Gift 1970-01-01 09:00:04    2   Basket     1970-01-01 09:00:01    3   Gift // Base point, Unmatched with Home 1970-01-01 09:00:02    3   Home       1970-01-01 09:00:03    3   Gift       1970-01-01 09:00:04    3   Basket
```

**Behavior for `backward` and `tail`**

```
SELECT id, sequenceNextNode(backward, tail)(dt, page, page = Basket, page = Basket, page = Gift) FROM test_flow GROUP BY id;                 dt   id   page1970-01-01 09:00:01    1   Home1970-01-01 09:00:02    1   Gift1970-01-01 09:00:03    1   Exit // Base point, Unmatched with Basket1970-01-01 09:00:01    2   Home 1970-01-01 09:00:02    2   Home // The result 1970-01-01 09:00:03    2   Gift // Matched with Gift1970-01-01 09:00:04    2   Basket // Base point, Matched with Basket1970-01-01 09:00:01    3   Gift1970-01-01 09:00:02    3   Home // The result 1970-01-01 09:00:03    3   Gift // Base point, Matched with Gift1970-01-01 09:00:04    3   Basket // Base point, Matched with Basket
```

**Behavior for `forward` and `first_match`**

```
SELECT id, sequenceNextNode(forward, first_match)(dt, page, page = Gift, page = Gift) FROM test_flow GROUP BY id;                 dt   id   page1970-01-01 09:00:01    1   Home1970-01-01 09:00:02    1   Gift // Base point1970-01-01 09:00:03    1   Exit // The result1970-01-01 09:00:01    2   Home 1970-01-01 09:00:02    2   Home 1970-01-01 09:00:03    2   Gift // Base point1970-01-01 09:00:04    2   Basket  The result1970-01-01 09:00:01    3   Gift // Base point1970-01-01 09:00:02    3   Home // The result1970-01-01 09:00:03    3   Gift   1970-01-01 09:00:04    3   Basket    SELECT id, sequenceNextNode(forward, first_match)(dt, page, page = Gift, page = Gift, page = Home) FROM test_flow GROUP BY id;                 dt   id   page1970-01-01 09:00:01    1   Home1970-01-01 09:00:02    1   Gift // Base point1970-01-01 09:00:03    1   Exit // Unmatched with Home1970-01-01 09:00:01    2   Home 1970-01-01 09:00:02    2   Home 1970-01-01 09:00:03    2   Gift // Base point1970-01-01 09:00:04    2   Basket // Unmatched with Home1970-01-01 09:00:01    3   Gift // Base point1970-01-01 09:00:02    3   Home // Matched with Home1970-01-01 09:00:03    3   Gift // The result1970-01-01 09:00:04    3   Basket
```

**Behavior for `backward` and `last_match`**

```
SELECT id, sequenceNextNode(backward, last_match)(dt, page, page = Gift, page = Gift) FROM test_flow GROUP BY id;                 dt   id   page1970-01-01 09:00:01    1   Home // The result1970-01-01 09:00:02    1   Gift // Base point1970-01-01 09:00:03    1   Exit 1970-01-01 09:00:01    2   Home 1970-01-01 09:00:02    2   Home // The result1970-01-01 09:00:03    2   Gift // Base point1970-01-01 09:00:04    2   Basket    1970-01-01 09:00:01    3   Gift 1970-01-01 09:00:02    3   Home // The result1970-01-01 09:00:03    3   Gift // Base point  1970-01-01 09:00:04    3   Basket    SELECT id, sequenceNextNode(backward, last_match)(dt, page, page = Gift, page = Gift, page = Home) FROM test_flow GROUP BY id;                 dt   id   page1970-01-01 09:00:01    1   Home // Matched with Home, the result is null1970-01-01 09:00:02    1   Gift // Base point1970-01-01 09:00:03    1   Exit 1970-01-01 09:00:01    2   Home // The result1970-01-01 09:00:02    2   Home // Matched with Home1970-01-01 09:00:03    2   Gift // Base point1970-01-01 09:00:04    2   Basket    1970-01-01 09:00:01    3   Gift // The result1970-01-01 09:00:02    3   Home // Matched with Home1970-01-01 09:00:03    3   Gift // Base point  1970-01-01 09:00:04    3   Basket
```

**Behavior for `base_condition`**

```
CREATE TABLE test_flow_basecond(    `dt` DateTime,    `id` int,    `page` String,    `ref` String)ENGINE = MergeTreePARTITION BY toYYYYMMDD(dt)ORDER BY id;INSERT INTO test_flow_basecond VALUES (1, 1, A, ref4) (2, 1, A, ref3) (3, 1, B, ref2) (4, 1, B, ref1);SELECT id, sequenceNextNode(forward, head)(dt, page, ref = ref1, page = A) FROM test_flow_basecond GROUP BY id;                  dt   id   page   ref  1970-01-01 09:00:01    1   A      ref4 // The head can not be base point because the ref column of the head unmatched with ref1. 1970-01-01 09:00:02    1   A      ref3  1970-01-01 09:00:03    1   B      ref2  1970-01-01 09:00:04    1   B      ref1
```

``` sql
SELECT id, sequenceNextNode(backward, tail)(dt, page, ref = ref4, page = B) FROM test_flow_basecond GROUP BY id;                  dt   id   page   ref  1970-01-01 09:00:01    1   A      ref4 1970-01-01 09:00:02    1   A      ref3  1970-01-01 09:00:03    1   B      ref2  1970-01-01 09:00:04    1   B      ref1 // The tail can not be base point because the ref column of the tail unmatched with ref4.SELECT id, sequenceNextNode(forward, first_match)(dt, page, ref = ref3, page = A) FROM test_flow_basecond GROUP BY id;                  dt   id   page   ref  1970-01-01 09:00:01    1   A      ref4 // This row can not be base point because the ref column unmatched with ref3. 1970-01-01 09:00:02    1   A      ref3 // Base point 1970-01-01 09:00:03    1   B      ref2 // The result 1970-01-01 09:00:04    1   B      ref1 SELECT id, sequenceNextNode(backward, last_match)(dt, page, ref = ref2, page = B) FROM test_flow_basecond GROUP BY id;                  dt   id   page   ref  1970-01-01 09:00:01    1   A      ref4 1970-01-01 09:00:02    1   A      ref3 // The result 1970-01-01 09:00:03    1   B      ref2 // Base point 1970-01-01 09:00:04    1   B      ref1 // This row can not be base point because the ref c
```

' where id=54;
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
COLUMNS(regexp)
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
SELECT COLUMNS(a), COLUMNS(c), toTypeName(COLUMNS(c)) FROM col_names
┌─aa─┬─ab─┬─bc─┬─toTypeName(bc)─┐
│  1 │  1 │  1 │ Int8           │
└────┴────┴────┴────────────────┘
```

Each column returned by the `COLUMNS` expression is passed to the function as a separate argument. Also you can pass other arguments to the function if it supports them. Be careful when using functions. If a function does not support the number of arguments you have passed to it, ClickHouse throws an exception.

For example:

```
SELECT COLUMNS(a) + COLUMNS(c) FROM col_names
Received exception from server (version 19.14.1):
Code: 42. DB::Exception: Received from localhost:9000. DB::Exception: Number of arguments for function plus does not match: passed 3, should be 2.
```

In this example, `COLUMNS(a)` returns two columns: `aa` and `ab`. `COLUMNS(c)` returns the `bc` column. The `+` operator can’t apply to 3 arguments, so ClickHouse throws an exception with the relevant message.

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
update biz_data_query_model_help_content set content_en = '# ALL Clause

If there are multiple matching rows in the table, then `ALL` returns all of them. `SELECT ALL` is identical to `SELECT` without `DISTINCT`. If both `ALL` and `DISTINCT` specified, exception will be thrown.

`ALL` can also be specified inside aggregate function with the same effect(noop), for instance:

```
SELECT sum(ALL number) FROM numbers(10);
```

equals to

```
SELECT sum(number) FROM numbers(10);
```

' where id=56;
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
VALUES (Hello, [1,2]), (World, [3,4,5]), (Goodbye, []);
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
VALUES (Hello, [1,2], [10,20]), (World, [3,4,5], [30,40,50]), (Goodbye, [], []);
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

The query execution order is optimized when running `ARRAY JOIN`. Although `ARRAY JOIN` must always be specified before the [WHERE]/[PREWHERE] clause in a query, technically they can be performed in any order, unless result of `ARRAY JOIN` is used for filtering. The processing order is controlled by the query optimizer.

' where id=57;
update biz_data_query_model_help_content set content_en = '# DISTINCT Clause

If `SELECT DISTINCT` is specified, only unique rows will remain in a query result. Thus only a single row will remain out of all the sets of fully matching rows in the result.

## Null Processing

`DISTINCT` works with [NULL] as if `NULL` were a specific value, and `NULL==NULL`. In other words, in the `DISTINCT` results, different combinations with `NULL` occur only once. It differs from `NULL` processing in most other contexts.

## Alternatives

It is possible to obtain the same result by applying [GROUP BY] across the same set of values as specified as `SELECT` clause, without using any aggregate functions. But there are few differences from `GROUP BY` approach:

- `DISTINCT` can be applied together with `GROUP BY`.
- When [ORDER BY] is omitted and [LIMIT] is defined, the query stops running immediately after the required number of different rows has been read.
- Data blocks are output as they are processed, without waiting for the entire query to finish running.

## Examples

ClickHouse supports using the `DISTINCT` and `ORDER BY` clauses for different columns in one query. The `DISTINCT` clause is executed before the `ORDER BY` clause.

Example table:

```
┌─a─┬─b─┐
│ 2 │ 1 │
│ 1 │ 2 │
│ 3 │ 3 │
│ 2 │ 4 │
└───┴───┘
```

When selecting data with the `SELECT DISTINCT a FROM t1 ORDER BY b ASC` query, we get the following result:

```
┌─a─┐
│ 2 │
│ 1 │
│ 3 │
└───┘
```

If we change the sorting direction `SELECT DISTINCT a FROM t1 ORDER BY b DESC`, we get the following result:

```
┌─a─┐
│ 3 │
│ 1 │
│ 2 │
└───┘
```

Row `2, 4` was cut before sorting.

Take this implementation specificity into account when programming queries.

' where id=58;
update biz_data_query_model_help_content set content_en = '# DISTINCT Clause

If `SELECT DISTINCT` is specified, only unique rows will remain in a query result. Thus only a single row will remain out of all the sets of fully matching rows in the result.

## Null Processing

`DISTINCT` works with [NULL] as if `NULL` were a specific value, and `NULL==NULL`. In other words, in the `DISTINCT` results, different combinations with `NULL` occur only once. It differs from `NULL` processing in most other contexts.

## Alternatives

It is possible to obtain the same result by applying [GROUP BY] across the same set of values as specified as `SELECT` clause, without using any aggregate functions. But there are few differences from `GROUP BY` approach:

- `DISTINCT` can be applied together with `GROUP BY`.
- When [ORDER BY] is omitted and [LIMIT] is defined, the query stops running immediately after the required number of different rows has been read.
- Data blocks are output as they are processed, without waiting for the entire query to finish running.

## Examples

ClickHouse supports using the `DISTINCT` and `ORDER BY` clauses for different columns in one query. The `DISTINCT` clause is executed before the `ORDER BY` clause.

Example table:

```
┌─a─┬─b─┐
│ 2 │ 1 │
│ 1 │ 2 │
│ 3 │ 3 │
│ 2 │ 4 │
└───┴───┘
```

When selecting data with the `SELECT DISTINCT a FROM t1 ORDER BY b ASC` query, we get the following result:

```
┌─a─┐
│ 2 │
│ 1 │
│ 3 │
└───┘
```

If we change the sorting direction `SELECT DISTINCT a FROM t1 ORDER BY b DESC`, we get the following result:

```
┌─a─┐
│ 3 │
│ 1 │
│ 2 │
└───┘
```

Row `2, 4` was cut before sorting.

Take this implementation specificity into account when programming queries.

' where id=59;


update biz_data_query_model_help_content set content_en = '# FROM Clause

The `FROM` clause specifies the source to read data from:

- [Table]
- [Subquery]
- [Table function]

[JOIN] and [ARRAY JOIN] clauses may also be used to extend the functionality of the `FROM` clause.

Subquery is another `SELECT` query that may be specified in parenthesis inside `FROM` clause.

`FROM` clause can contain multiple data sources, separated by commas, which is equivalent of performing [CROSS JOIN] on them.

## FINAL Modifier

When `FINAL` is specified, ClickHouse fully merges the data before returning the result and thus performs all data transformations that happen during merges for the given table engine.

It is applicable when selecting data from tables that use the [MergeTree]-engine family (except `GraphiteMergeTree`). Also supported for:

- [Replicated] versions of `MergeTree` engines.
- [View], [Buffer], [Distributed], and [MaterializedView] engines that operate over other engines, provided they were created over `MergeTree`-engine tables.

Now `SELECT` queries with `FINAL` are executed in parallel and slightly faster. But there are drawbacks (see below). The [max_final_threads] setting limits the number of threads used.

### Drawbacks

Queries that use `FINAL` are executed slightly slower than similar queries that do not, because:

- Data is merged during query execution.
- Queries with `FINAL` read primary key columns in addition to the columns specified in the query.

**In most cases, avoid using `FINAL`.** The common approach is to use different queries that assume the background processes of the `MergeTree` engine have’t happened yet and deal with it by applying aggregation (for example, to discard duplicates).

## Implementation Details

If the `FROM` clause is omitted, data will be read from the `system.one` table.
The `system.one` table contains exactly one row (this table fulfills the same purpose as the DUAL table found in other DBMSs).

To execute a query, all the columns listed in the query are extracted from the appropriate table. Any columns not needed for the external query are thrown out of the subqueries.
If a query does not list any columns (for example, `SELECT count() FROM t`), some column is extracted from the table anyway (the smallest one is preferred), in order to calculate the number of rows.' where id=60;
update biz_data_query_model_help_content set content_en = '# GROUP BY Clause

`GROUP BY` clause switches the `SELECT` query into an aggregation mode, which works as follows:

- `GROUP BY` clause contains a list of expressions (or a single expression, which is considered to be the list of length one). This list acts as a “grouping key”, while each individual expression will be referred to as a “key expression”.
- All the expressions in the [SELECT], [HAVING], and [ORDER BY] clauses **must** be calculated based on key expressions **or** on [aggregate functions] over non-key expressions (including plain columns). In other words, each column selected from the table must be used either in a key expression or inside an aggregate function, but not both.
- Result of aggregating `SELECT` query will contain as many rows as there were unique values of “grouping key” in source table. Usually this signficantly reduces the row count, often by orders of magnitude, but not necessarily: row count stays the same if all “grouping key” values were distinct.

Note

There’s an additional way to run aggregation over a table. If a query contains table columns only inside aggregate functions, the `GROUP BY clause` can be omitted, and aggregation by an empty set of keys is assumed. Such queries always return exactly one row.

## NULL Processing

For grouping, ClickHouse interprets [NULL] as a value, and `NULL==NULL`. It differs from `NULL` processing in most other contexts.

Here’s an example to show what this means.

Assume you have this table:

```
┌─x─┬────y─┐
│ 1 │    2 │
│ 2 │ ᴺᵁᴸᴸ │
│ 3 │    2 │
│ 3 │    3 │
│ 3 │ ᴺᵁᴸᴸ │
└───┴──────┘
```

The query `SELECT sum(x), y FROM t_null_big GROUP BY y` results in:

```
┌─sum(x)─┬────y─┐
│      4 │    2 │
│      3 │    3 │
│      5 │ ᴺᵁᴸᴸ │
└────────┴──────┘
```

You can see that `GROUP BY` for `y = NULL` summed up `x`, as if `NULL` is this value.

If you pass several keys to `GROUP BY`, the result will give you all the combinations of the selection, as if `NULL` were a specific value.

## WITH ROLLUP Modifier

`WITH ROLLUP` modifier is used to calculate subtotals for the key expressions, based on their order in the `GROUP BY` list. The subtotals rows are added after the result table.

The subtotals are calculated in the reverse order: at first subtotals are calculated for the last key expression in the list, then for the previous one, and so on up to the first key expression.

In the subtotals rows the values of already "grouped" key expressions are set to `0` or empty line.

Note

Mind that [HAVING] clause can affect the subtotals results.

**Example**

Consider the table t:

```
┌─year─┬─month─┬─day─┐
│ 2019 │     1 │   5 │
│ 2019 │     1 │  15 │
│ 2020 │     1 │   5 │
│ 2020 │     1 │  15 │
│ 2020 │    10 │   5 │
│ 2020 │    10 │  15 │
└──────┴───────┴─────┘
```

Query:

```
SELECT year, month, day, count(*) FROM t GROUP BY year, month, day WITH ROLLUP;
```

As `GROUP BY` section has three key expressions, the result contains four tables with subtotals "rolled up" from right to left:

- `GROUP BY year, month, day`;
- `GROUP BY year, month` (and `day` column is filled with zeros);
- `GROUP BY year` (now `month, day` columns are both filled with zeros);
- and totals (and all three key expression columns are zeros).

```
┌─year─┬─month─┬─day─┬─count()─┐
│ 2020 │    10 │  15 │       1 │
│ 2020 │     1 │   5 │       1 │
│ 2019 │     1 │   5 │       1 │
│ 2020 │     1 │  15 │       1 │
│ 2019 │     1 │  15 │       1 │
│ 2020 │    10 │   5 │       1 │
└──────┴───────┴─────┴─────────┘
┌─year─┬─month─┬─day─┬─count()─┐
│ 2019 │     1 │   0 │       2 │
│ 2020 │     1 │   0 │       2 │
│ 2020 │    10 │   0 │       2 │
└──────┴───────┴─────┴─────────┘
┌─year─┬─month─┬─day─┬─count()─┐
│ 2019 │     0 │   0 │       2 │
│ 2020 │     0 │   0 │       4 │
└──────┴───────┴─────┴─────────┘
┌─year─┬─month─┬─day─┬─count()─┐
│    0 │     0 │   0 │       6 │
└──────┴───────┴─────┴─────────┘
```

## WITH CUBE Modifier

`WITH CUBE` modifier is used to calculate subtotals for every combination of the key expressions in the `GROUP BY` list. The subtotals rows are added after the result table.

In the subtotals rows the values of all "grouped" key expressions are set to `0` or empty line.

Note

Mind that [HAVING] clause can affect the subtotals results.

**Example**

Consider the table t:

```
┌─year─┬─month─┬─day─┐
│ 2019 │     1 │   5 │
│ 2019 │     1 │  15 │
│ 2020 │     1 │   5 │
│ 2020 │     1 │  15 │
│ 2020 │    10 │   5 │
│ 2020 │    10 │  15 │
└──────┴───────┴─────┘
```

Query:

```
SELECT year, month, day, count(*) FROM t GROUP BY year, month, day WITH CUBE;
```

As `GROUP BY` section has three key expressions, the result contains eight tables with subtotals for all key expression combinations:

- `GROUP BY year, month, day`
- `GROUP BY year, month`
- `GROUP BY year, day`
- `GROUP BY year`
- `GROUP BY month, day`
- `GROUP BY month`
- `GROUP BY day`
- and totals.

Columns, excluded from `GROUP BY`, are filled with zeros.

```
┌─year─┬─month─┬─day─┬─count()─┐
│ 2020 │    10 │  15 │       1 │
│ 2020 │     1 │   5 │       1 │
│ 2019 │     1 │   5 │       1 │
│ 2020 │     1 │  15 │       1 │
│ 2019 │     1 │  15 │       1 │
│ 2020 │    10 │   5 │       1 │
└──────┴───────┴─────┴─────────┘
┌─year─┬─month─┬─day─┬─count()─┐
│ 2019 │     1 │   0 │       2 │
│ 2020 │     1 │   0 │       2 │
│ 2020 │    10 │   0 │       2 │
└──────┴───────┴─────┴─────────┘
┌─year─┬─month─┬─day─┬─count()─┐
│ 2020 │     0 │   5 │       2 │
│ 2019 │     0 │   5 │       1 │
│ 2020 │     0 │  15 │       2 │
│ 2019 │     0 │  15 │       1 │
└──────┴───────┴─────┴─────────┘
┌─year─┬─month─┬─day─┬─count()─┐
│ 2019 │     0 │   0 │       2 │
│ 2020 │     0 │   0 │       4 │
└──────┴───────┴─────┴─────────┘
┌─year─┬─month─┬─day─┬─count()─┐
│    0 │     1 │   5 │       2 │
│    0 │    10 │  15 │       1 │
│    0 │    10 │   5 │       1 │
│    0 │     1 │  15 │       2 │
└──────┴───────┴─────┴─────────┘
┌─year─┬─month─┬─day─┬─count()─┐
│    0 │     1 │   0 │       4 │
│    0 │    10 │   0 │       2 │
└──────┴───────┴─────┴─────────┘
┌─year─┬─month─┬─day─┬─count()─┐
│    0 │     0 │   5 │       3 │
│    0 │     0 │  15 │       3 │
└──────┴───────┴─────┴─────────┘
┌─year─┬─month─┬─day─┬─count()─┐
│    0 │     0 │   0 │       6 │
└──────┴───────┴─────┴─────────┘
```

## WITH TOTALS Modifier

If the `WITH TOTALS` modifier is specified, another row will be calculated. This row will have key columns containing default values (zeros or empty lines), and columns of aggregate functions with the values calculated across all the rows (the “total” values).

This extra row is only produced in `JSON*`, `TabSeparated*`, and `Pretty*` formats, separately from the other rows:

- In `JSON*` formats, this row is output as a separate ‘totals’ field.
- In `TabSeparated*` formats, the row comes after the main result, preceded by an empty row (after the other data).
- In `Pretty*` formats, the row is output as a separate table after the main result.
- In the other formats it is not available.

`WITH TOTALS` can be run in different ways when [HAVING] is present. The behavior depends on the `totals_mode` setting.

### Configuring Totals Processing

By default, `totals_mode = before_having`. In this case, ‘totals’ is calculated across all rows, including the ones that do not pass through HAVING and `max_rows_to_group_by`.

The other alternatives include only the rows that pass through HAVING in ‘totals’, and behave differently with the setting `max_rows_to_group_by` and `group_by_overflow_mode = any`.

`after_having_exclusive` – Don’t include rows that didn’t pass through `max_rows_to_group_by`. In other words, ‘totals’ will have less than or the same number of rows as it would if `max_rows_to_group_by` were omitted.

`after_having_inclusive` – Include all the rows that didn’t pass through ‘max_rows_to_group_by’ in ‘totals’. In other words, ‘totals’ will have more than or the same number of rows as it would if `max_rows_to_group_by` were omitted.

`after_having_auto` – Count the number of rows that passed through HAVING. If it is more than a certain amount (by default, 50%), include all the rows that didn’t pass through ‘max_rows_to_group_by’ in ‘totals’. Otherwise, do not include them.

`totals_auto_threshold` – By default, 0.5. The coefficient for `after_having_auto`.

If `max_rows_to_group_by` and `group_by_overflow_mode = any` are not used, all variations of `after_having` are the same, and you can use any of them (for example, `after_having_auto`).

You can use `WITH TOTALS` in subqueries, including subqueries in the [JOIN] clause (in this case, the respective total values are combined).

## Examples

Example:

```
SELECT    count(),    median(FetchTiming > 60 ? 60 : FetchTiming),    count() - sum(Refresh)FROM hits
```

As opposed to MySQL (and conforming to standard SQL), you can’t get some value of some column that is not in a key or aggregate function (except constant expressions). To work around this, you can use the ‘any’ aggregate function (get the first encountered value) or ‘min/max’.

Example:

```
SELECT    domainWithoutWWW(URL) AS domain,    count(),    any(Title) AS title -- getting the first occurred page header for each domain.FROM hitsGROUP BY domain
```

For every different key value encountered, `GROUP BY` calculates a set of aggregate function values.

## Implementation Details

Aggregation is one of the most important features of a column-oriented DBMS, and thus it’s implementation is one of the most heavily optimized parts of ClickHouse. By default, aggregation is done in memory using a hash-table. It has 40+ specializations that are chosen automatically depending on “grouping key” data types.

### GROUP BY Optimization Depending on Table Sorting Key

The aggregation can be performed more effectively, if a table is sorted by some key, and `GROUP BY` expression contains at least prefix of sorting key or injective functions. In this case when a new key is read from table, the in-between result of aggregation can be finalized and sent to client. This behaviour is switched on by the [optimize_aggregation_in_order] setting. Such optimization reduces memory usage during aggregation, but in some cases may slow down the query execution.

### GROUP BY in External Memory

You can enable dumping temporary data to the disk to restrict memory usage during `GROUP BY`.
The [max_bytes_before_external_group_by] setting determines the threshold RAM consumption for dumping `GROUP BY` temporary data to the file system. If set to 0 (the default), it is disabled.

When using `max_bytes_before_external_group_by`, we recommend that you set `max_memory_usage` about twice as high. This is necessary because there are two stages to aggregation: reading the data and forming intermediate data (1) and merging the intermediate data (2). Dumping data to the file system can only occur during stage 1. If the temporary data wasn’t dumped, then stage 2 might require up to the same amount of memory as in stage 1.

For example, if [max_memory_usage] was set to 100 and you want to use external aggregation, it makes sense to set `max_bytes_before_external_group_by` to 100, and `max_memory_usage` to 200. When external aggregation is triggered (if there was at least one dump of temporary data), maximum consumption of RAM is only slightly more than `max_bytes_before_external_group_by`.

With distributed query processing, external aggregation is performed on remote servers. In order for the requester server to use only a small amount of RAM, set `distributed_aggregation_memory_efficient` to 1.

When merging data flushed to the disk, as well as when merging results from remote servers when the `distributed_aggregation_memory_efficient` setting is enabled, consumes up to `1/256 * the_number_of_threads` from the total amount of RAM.

When external aggregation is enabled, if there was less than `max_bytes_before_external_group_by` of data (i.e. data was not flushed), the query runs just as fast as without external aggregation. If any temporary data was flushed, the run time will be several times longer (approximately three times).

If you have an [ORDER BY] with a [LIMIT] after `GROUP BY`, then the amount of used RAM depends on the amount of data in `LIMIT`, not in the whole table. But if the `ORDER BY` does not have `LIMIT`, do not forget to enable external sorting (`max_bytes_before_external_sort`).

' where id=61;
update biz_data_query_model_help_content set content_en = '# HAVING Clause

Allows filtering the aggregation results produced by [GROUP BY]. It is similar to the [WHERE]clause, but the difference is that `WHERE` is performed before aggregation, while `HAVING` is performed after it.

It is possible to reference aggregation results from `SELECT` clause in `HAVING` clause by their alias. Alternatively, `HAVING` clause can filter on results of additional aggregates that are not returned in query results.

## Limitations[ ](https://clickhouse.tech/docs/en/sql-reference/statements/select/having/#limitations)

`HAVING` can’t be used if aggregation is not performed. Use `WHERE` instead.

' where id=62;
update biz_data_query_model_help_content set content_en = '# INTO OUTFILE Clause

Add the `INTO OUTFILE filename` clause (where filename is a string literal) to `SELECT query` to redirect its output to the specified file on the client-side.

## Implementation Details[ ](https://clickhouse.tech/docs/en/sql-reference/statements/select/into-outfile/#implementation-details)

- This functionality is available in the [command-line client]and [clickhouse-local]. Thus a query sent via [HTTP interface] will fail.
- The query will fail if a file with the same filename already exists.
  - The default [output format]is `TabSeparated` (like in the command-line client batch mode).

' where id=63;
update biz_data_query_model_help_content set content_en = '# JOIN Clause

Join produces a new table by combining columns from one or multiple tables by using values common to each. It is a common operation in databases with SQL support, which corresponds to [relational algebra] join. The special case of one table join is often referred to as “self-join”.

Syntax:

```
SELECT <expr_list>
FROM <left_table>
[GLOBAL] [INNER|LEFT|RIGHT|FULL|CROSS] [OUTER|SEMI|ANTI|ANY|ASOF] JOIN <right_table>
(ON <expr_list>)|(USING <column_list>) ...
```

Expressions from `ON` clause and columns from `USING` clause are called “join keys”. Unless otherwise stated, join produces a [Cartesian product] from rows with matching “join keys”, which might produce results with much more rows than the source tables.

## Supported Types of JOIN

All standard [SQL JOIN]) types are supported:

- `INNER JOIN`, only matching rows are returned.
- `LEFT OUTER JOIN`, non-matching rows from left table are returned in addition to matching rows.
- `RIGHT OUTER JOIN`, non-matching rows from right table are returned in addition to matching rows.
- `FULL OUTER JOIN`, non-matching rows from both tables are returned in addition to matching rows.
- `CROSS JOIN`, produces cartesian product of whole tables, “join keys” are **not** specified.

`JOIN` without specified type implies `INNER`. Keyword `OUTER` can be safely omitted. Alternative syntax for `CROSS JOIN` is specifying multiple tables in [FROM clause] separated by commas.

Additional join types available in ClickHouse:

- `LEFT SEMI JOIN` and `RIGHT SEMI JOIN`, a whitelist on “join keys”, without producing a cartesian product.
- `LEFT ANTI JOIN` and `RIGHT ANTI JOIN`, a blacklist on “join keys”, without producing a cartesian product.
- `LEFT ANY JOIN`, `RIGHT ANY JOIN` and `INNER ANY JOIN`, partially (for opposite side of `LEFT` and `RIGHT`) or completely (for `INNER` and `FULL`) disables the cartesian product for standard `JOIN` types.
- `ASOF JOIN` and `LEFT ASOF JOIN`, joining sequences with a non-exact match. `ASOF JOIN` usage is described below.

## Setting

Note

The default join type can be overriden using [join_default_strictness] setting.

Also the behavior of ClickHouse server for `ANY JOIN` operations depends on the [any_join_distinct_right_table_keys] setting.

### ASOF JOIN Usage

`ASOF JOIN` is useful when you need to join records that have no exact match.

Algorithm requires the special column in tables. This column:

- Must contain an ordered sequence.
- Can be one of the following types: [Int*, UInt*], [Float*], [Date], [DateTime], [Decimal*].
- Can’t be the only column in the `JOIN` clause.

Syntax `ASOF JOIN ... ON`:

```
SELECT expressions_list
FROM table_1
ASOF LEFT JOIN table_2
ON equi_cond AND closest_match_cond
```

You can use any number of equality conditions and exactly one closest match condition. For example, `SELECT count() FROM table_1 ASOF LEFT JOIN table_2 ON table_1.a == table_2.b AND table_2.t <= table_1.t`.

Conditions supported for the closest match: `>`, `>=`, `<`, `<=`.

Syntax `ASOF JOIN ... USING`:

```
SELECT expressions_list
FROM table_1
ASOF JOIN table_2
USING (equi_column1, ... equi_columnN, asof_column)
```

`ASOF JOIN` uses `equi_columnX` for joining on equality and `asof_column` for joining on the closest match with the `table_1.asof_column >= table_2.asof_column` condition. The `asof_column` column always the last one in the `USING` clause.

For example, consider the following tables:

```
     table_1                           table_2
  event   | ev_time | user_id       event   | ev_time | user_id
----------|---------|----------   ----------|---------|----------
              ...                               ...
event_1_1 |  12:00  |  42         event_2_1 |  11:59  |   42
              ...                 event_2_2 |  12:30  |   42
event_1_2 |  13:00  |  42         event_2_3 |  13:00  |   42
              ...                               ...
```

`ASOF JOIN` can take the timestamp of a user event from `table_1` and find an event in `table_2` where the timestamp is closest to the timestamp of the event from `table_1` corresponding to the closest match condition. Equal timestamp values are the closest if available. Here, the `user_id` column can be used for joining on equality and the `ev_time` column can be used for joining on the closest match. In our example, `event_1_1` can be joined with `event_2_1` and `event_1_2` can be joined with `event_2_3`, but `event_2_2` can’t be joined.

Note

`ASOF` join is **not** supported in the [Join] table engine.

## Distributed Join

There are two ways to execute join involving distributed tables:

- When using a normal `JOIN`, the query is sent to remote servers. Subqueries are run on each of them in order to make the right table, and the join is performed with this table. In other words, the right table is formed on each server separately.
- When using `GLOBAL ... JOIN`, first the requestor server runs a subquery to calculate the right table. This temporary table is passed to each remote server, and queries are run on them using the temporary data that was transmitted.

Be careful when using `GLOBAL`. For more information, see the [Distributed subqueries] section.

## Usage Recommendations

### Processing of Empty or NULL Cells

While joining tables, the empty cells may appear. The setting [join_use_nulls] define how ClickHouse fills these cells.

If the `JOIN` keys are [Nullable] fields, the rows where at least one of the keys has the value [NULL] are not joined.

### Syntax

The columns specified in `USING` must have the same names in both subqueries, and the other columns must be named differently. You can use aliases to change the names of columns in subqueries.

The `USING` clause specifies one or more columns to join, which establishes the equality of these columns. The list of columns is set without brackets. More complex join conditions are not supported.

### Syntax Limitations

For multiple `JOIN` clauses in a single `SELECT` query:

- Taking all the columns via `*` is available only if tables are joined, not subqueries.
- The `PREWHERE` clause is not available.

For `ON`, `WHERE`, and `GROUP BY` clauses:

- Arbitrary expressions cannot be used in `ON`, `WHERE`, and `GROUP BY` clauses, but you can define an expression in a `SELECT` clause and then use it in these clauses via an alias.

### Performance

When running a `JOIN`, there is no optimization of the order of execution in relation to other stages of the query. The join (a search in the right table) is run before filtering in `WHERE` and before aggregation.

Each time a query is run with the same `JOIN`, the subquery is run again because the result is not cached. To avoid this, use the special [Join] table engine, which is a prepared array for joining that is always in RAM.

In some cases, it is more efficient to use [IN] instead of `JOIN`.

If you need a `JOIN` for joining with dimension tables (these are relatively small tables that contain dimension properties, such as names for advertising campaigns), a `JOIN` might not be very convenient due to the fact that the right table is re-accessed for every query. For such cases, there is an “external dictionaries” feature that you should use instead of `JOIN`. For more information, see the [External dictionaries] section.

### Memory Limitations

By default, ClickHouse uses the [hash join] algorithm. ClickHouse takes the `<right_table>` and creates a hash table for it in RAM. After some threshold of memory consumption, ClickHouse falls back to merge join algorithm.

If you need to restrict join operation memory consumption use the following settings:

- [max_rows_in_join] — Limits number of rows in the hash table.
- [max_bytes_in_join] — Limits size of the hash table.

When any of these limits is reached, ClickHouse acts as the [join_overflow_mode] setting instructs.

## Examples

Example:

```
SELECT
    CounterID,
    hits,
    visits
FROM
(
    SELECT
        CounterID,
        count() AS hits
    FROM test.hits
    GROUP BY CounterID
) ANY LEFT JOIN
(
    SELECT
        CounterID,
        sum(Sign) AS visits
    FROM test.visits
    GROUP BY CounterID
) USING CounterID
ORDER BY hits DESC
LIMIT 10
┌─CounterID─┬───hits─┬─visits─┐
│   1143050 │ 523264 │  13665 │
│    731962 │ 475698 │ 102716 │
│    722545 │ 337212 │ 108187 │
│    722889 │ 252197 │  10547 │
│   2237260 │ 196036 │   9522 │
│  23057320 │ 147211 │   7689 │
│    722818 │  90109 │  17847 │
│     48221 │  85379 │   4652 │
│  19762435 │  77807 │   7026 │
│    722884 │  77492 │  11056 │
└───────────┴────────┴────────┘
```

' where id=64;
update biz_data_query_model_help_content set content_en = '# LIMIT Clause

`LIMIT m` allows to select the first `m` rows from the result.

`LIMIT n, m` allows to select the `m` rows from the result after skipping the first `n` rows. The `LIMIT m OFFSET n` syntax is equivalent.

`n` and `m` must be non-negative integers.

If there is no [ORDER BY] clause that explicitly sorts results, the choice of rows for the result may be arbitrary and non-deterministic.

Note

The number of rows in the result set can also depend on the [limit] setting.

## LIMIT … WITH TIES Modifier

When you set `WITH TIES` modifier for `LIMIT n[,m]` and specify `ORDER BY expr_list`, you will get in result first `n` or `n,m` rows and all rows with same `ORDER BY` fields values equal to row at position `n` for `LIMIT n` and `m` for `LIMIT n,m`.

This modifier also can be combined with [ORDER BY … WITH FILL modifier].

For example, the following query

```
SELECT * FROM (
    SELECT number%50 AS n FROM numbers(100)
) ORDER BY n LIMIT 0,5
```

returns

```
┌─n─┐
│ 0 │
│ 0 │
│ 1 │
│ 1 │
│ 2 │
└───┘
```

but after apply `WITH TIES` modifier

```
SELECT * FROM (
    SELECT number%50 AS n FROM numbers(100)
) ORDER BY n LIMIT 0,5 WITH TIES
```

it returns another rows set

```
┌─n─┐
│ 0 │
│ 0 │
│ 1 │
│ 1 │
│ 2 │
│ 2 │
└───┘
```

cause row number 6 have same value “2” for field `n` as row number 5' where id=65;
update biz_data_query_model_help_content set content_en = '# LIMIT BY Clause

A query with the `LIMIT n BY expressions` clause selects the first `n` rows for each distinct value of `expressions`. The key for `LIMIT BY` can contain any number of [expressions].

ClickHouse supports the following syntax variants:

- `LIMIT [offset_value, ]n BY expressions`
- `LIMIT n OFFSET offset_value BY expressions`

During query processing, ClickHouse selects data ordered by sorting key. The sorting key is set explicitly using an [ORDER BY] clause or implicitly as a property of the table engine. Then ClickHouse applies `LIMIT n BY expressions` and returns the first `n` rows for each distinct combination of `expressions`. If `OFFSET` is specified, then for each data block that belongs to a distinct combination of `expressions`, ClickHouse skips `offset_value` number of rows from the beginning of the block and returns a maximum of `n` rows as a result. If `offset_value` is bigger than the number of rows in the data block, ClickHouse returns zero rows from the block.

Note

`LIMIT BY` is not related to [LIMIT]. They can both be used in the same query.

## Examples

Sample table:

```
CREATE TABLE limit_by(id Int, val Int) ENGINE = Memory;
INSERT INTO limit_by VALUES (1, 10), (1, 11), (1, 12), (2, 20), (2, 21);
```

Queries:

```
SELECT * FROM limit_by ORDER BY id, val LIMIT 2 BY id
┌─id─┬─val─┐
│  1 │  10 │
│  1 │  11 │
│  2 │  20 │
│  2 │  21 │
└────┴─────┘
SELECT * FROM limit_by ORDER BY id, val LIMIT 1, 2 BY id
┌─id─┬─val─┐
│  1 │  11 │
│  1 │  12 │
│  2 │  21 │
└────┴─────┘
```

The `SELECT * FROM limit_by ORDER BY id, val LIMIT 2 OFFSET 1 BY id` query returns the same result.

The following query returns the top 5 referrers for each `domain, device_type` pair with a maximum of 100 rows in total (`LIMIT n BY + LIMIT`).

```
SELECT
    domainWithoutWWW(URL) AS domain,
    domainWithoutWWW(REFERRER_URL) AS referrer,
    device_type,
    count() cnt
FROM hits
GROUP BY domain, referrer, device_type
ORDER BY cnt DESC
LIMIT 5 BY domain, device_type
LIMIT 100
```

' where id=66;
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
   SELECT toFloat32(number % 10) AS n, original AS source
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
    original AS source
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

' where id=67;
update biz_data_query_model_help_content set content_en = '# PREWHERE Clause

Prewhere is an optimization to apply filtering more efficiently. It is enabled by default even if `PREWHERE` clause is not specified explicitly. It works by automatically moving part of [WHERE] condition to prewhere stage. The role of `PREWHERE` clause is only to control this optimization if you think that you know how to do it better than it happens by default.

With prewhere optimization, at first only the columns necessary for executing prewhere expression are read. Then the other columns are read that are needed for running the rest of the query, but only those blocks where the prewhere expression is “true” at least for some rows. If there are a lot of blocks where prewhere expression is “false” for all rows and prewhere needs less columns than other parts of query, this often allows to read a lot less data from disk for query execution.

## Controlling Prewhere Manually

The clause has the same meaning as the `WHERE` clause. The difference is in which data is read from the table. When manually controlling `PREWHERE` for filtration conditions that are used by a minority of the columns in the query, but that provide strong data filtration. This reduces the volume of data to read.

A query may simultaneously specify `PREWHERE` and `WHERE`. In this case, `PREWHERE` precedes `WHERE`.

If the `optimize_move_to_prewhere` setting is set to 0, heuristics to automatically move parts of expressions from `WHERE` to `PREWHERE` are disabled.

Attention

The `PREWHERE` section is executed before`FINAL`, so the results of `FROM FINAL` queries may be skewed when using`PREWHERE` with fields not in the `ORDER BY` section of a table.' where id=68;
update biz_data_query_model_help_content set content_en = '# SAMPLE Clause

The `SAMPLE` clause allows for approximated `SELECT` query processing.

When data sampling is enabled, the query is not performed on all the data, but only on a certain fraction of data (sample). For example, if you need to calculate statistics for all the visits, it is enough to execute the query on the 1/10 fraction of all the visits and then multiply the result by 10.

Approximated query processing can be useful in the following cases:

- When you have strict timing requirements (like \<100ms) but you can’t justify the cost of additional hardware resources to meet them.
- When your raw data is not accurate, so approximation does not noticeably degrade the quality.
- Business requirements target approximate results (for cost-effectiveness, or to market exact results to premium users).

Note

You can only use sampling with the tables in the [MergeTree] family, and only if the sampling expression was specified during table creation (see [MergeTree engine]).

The features of data sampling are listed below:

- Data sampling is a deterministic mechanism. The result of the same `SELECT .. SAMPLE` query is always the same.
- Sampling works consistently for different tables. For tables with a single sampling key, a sample with the same coefficient always selects the same subset of possible data. For example, a sample of user IDs takes rows with the same subset of all the possible user IDs from different tables. This means that you can use the sample in subqueries in the [IN] clause. Also, you can join samples using the [JOIN] clause.
- Sampling allows reading less data from a disk. Note that you must specify the sampling key correctly. For more information, see [Creating a MergeTree Table].

For the `SAMPLE` clause the following syntax is supported:

| SAMPLE Clause Syntax | Description                         |
| -------------------- | ----------------------------------- |
| `SAMPLE k`           | Here `k` is the number from 0 to 1. |

The query is executed on `k` fraction of data. For example, `SAMPLE 0.1` runs the query on 10% of data. [Read more] `SAMPLE n` Here `n` is a sufficiently large integer.The query is executed on a sample of at least `n` rows (but not significantly more than this). For example, `SAMPLE 1000` runs the query on a minimum of 10,000,000 rows. [Read more] `SAMPLE k OFFSET m` Here `k` and `m` are the numbers from 0 to 1.The query is executed on a sample of `k` fraction of the data. The data used for the sample is offset by `m` fraction. [Read more]

## SAMPLE K

Here `k` is the number from 0 to 1 (both fractional and decimal notations are supported). For example, `SAMPLE 1/2` or `SAMPLE 0.5`.

In a `SAMPLE k` clause, the sample is taken from the `k` fraction of data. The example is shown below:

```
SELECT
    Title,
    count() * 10 AS PageViews
FROM hits_distributed
SAMPLE 0.1
WHERE
    CounterID = 34
GROUP BY Title
ORDER BY PageViews DESC LIMIT 1000
```

In this example, the query is executed on a sample from 0.1 (10%) of data. Values of aggregate functions are not corrected automatically, so to get an approximate result, the value `count()` is manually multiplied by 10.

## SAMPLE N

Here `n` is a sufficiently large integer. For example, `SAMPLE 1000`.

In this case, the query is executed on a sample of at least `n` rows (but not significantly more than this). For example, `SAMPLE 1000` runs the query on a minimum of 10,000,000 rows.

Since the minimum unit for data reading is one granule (its size is set by the `index_granularity` setting), it makes sense to set a sample that is much larger than the size of the granule.

When using the `SAMPLE n` clause, you do not know which relative percent of data was processed. So you do not know the coefficient the aggregate functions should be multiplied by. Use the `_sample_factor` virtual column to get the approximate result.

The `_sample_factor` column contains relative coefficients that are calculated dynamically. This column is created automatically when you [create] a table with the specified sampling key. The usage examples of the `_sample_factor` column are shown below.

Let’s consider the table `visits`, which contains the statistics about site visits. The first example shows how to calculate the number of page views:

```
SELECT sum(PageViews * _sample_factor)
FROM visits
SAMPLE 1000
```

The next example shows how to calculate the total number of visits:

```
SELECT sum(_sample_factor)
FROM visits
SAMPLE 1000
```

The example below shows how to calculate the average session duration. Note that you do not need to use the relative coefficient to calculate the average values.

```
SELECT avg(Duration)
FROM visits
SAMPLE 1000
```

## SAMPLE K OFFSET M

Here `k` and `m` are numbers from 0 to 1. Examples are shown below.

**Example 1**

```
SAMPLE 1/10
```

In this example, the sample is 1/10th of all data:

```
[++------------]
```

**Example 2**

```
SAMPLE 1/10 OFFSET 1/2
```

Here, a sample of 10% is taken from the second half of the data.

' where id=69;

update biz_data_query_model_help_content set content_en = '# UNION Clause

You can use `UNION` with explicitly specifying `UNION ALL` or `UNION DISTINCT`.

If you dont specify `ALL` or `DISTINCT`, it will depend on the `union_default_mode` setting. The difference between `UNION ALL` and `UNION DISTINCT` is that `UNION DISTINCT` will do a distinct transform for union result, it is equivalent to `SELECT DISTINCT` from a subquery containing `UNION ALL`.

You can use `UNION` to combine any number of `SELECT` queries by extending their results. Example:

```
SELECT CounterID, 1 AS table, toInt64(count()) AS c
    FROM test.hits
    GROUP BY CounterID

UNION ALL

SELECT CounterID, 2 AS table, sum(Sign) AS c
    FROM test.visits
    GROUP BY CounterID
    HAVING c > 0
```

Result columns are matched by their index (order inside `SELECT`). If column names do not match, names for the final result are taken from the first query.

Type casting is performed for unions. For example, if two queries being combined have the same field with non-`Nullable` and `Nullable` types from a compatible type, the resulting `UNION` has a `Nullable` type field.

Queries that are parts of `UNION` can be enclosed in round brackets. ORDER BY and LIMIT are applied to separate queries, not to the final result. If you need to apply a conversion to the final result, you can put all the queries with `UNION` in a subquery in the FROM clause.

If you use `UNION` without explicitly specifying `UNION ALL` or `UNION DISTINCT`, you can specify the union mode using the union_default_mode setting. The setting values can be `ALL`, `DISTINCT` or an empty string. However, if you use `UNION` with `union_default_mode` setting to empty string, it will throw an exception. The following examples demonstrate the results of queries with different values setting.

Query:

```
SET union_default_mode = DISTINCT;
SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 2;
```

Result:

```
┌─1─┐
│ 1 │
└───┘
┌─1─┐
│ 2 │
└───┘
┌─1─┐
│ 3 │
└───┘
```

Query:

```
SET union_default_mode = ALL;
SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 2;
```

Result:

```
┌─1─┐
│ 1 │
└───┘
┌─1─┐
│ 2 │
└───┘
┌─1─┐
│ 2 │
└───┘
┌─1─┐
│ 3 │
└───┘
```

Queries that are parts of `UNION/UNION ALL/UNION DISTINCT` can be run simultaneously, and their results can be mixed together.

' where id=70;
update biz_data_query_model_help_content set content_en = '# WHERE Clause

`WHERE` clause allows to filter the data that is coming from FROM clause of `SELECT`.

If there is a `WHERE` clause, it must contain an expression with the `UInt8` type. This is usually an expression with comparison and logical operators. Rows where this expression evaluates to 0 are expluded from further transformations or result.

`WHERE` expression is evaluated on the ability to use indexes and partition pruning, if the underlying table engine supports that.' where id=71;
update biz_data_query_model_help_content set content_en = '# WITH Clause

ClickHouse supports Common Table Expressions (CTE), that is provides to use results of `WITH` clause in the rest of `SELECT` query. Named subqueries can be included to the current and child query context in places where table objects are allowed. Recursion is prevented by hiding the current level CTEs from the WITH expression.

## Syntax

```
WITH <expression> AS <identifier>
```

or

```
WITH <identifier> AS <subquery expression>
```

## Examples

**Example 1:** Using constant expression as “variable”

```
WITH 2019-08-01 15:23:00 as ts_upper_bound
SELECT *
FROM hits
WHERE
    EventDate = toDate(ts_upper_bound) AND
    EventTime <= ts_upper_bound;
```

**Example 2:** Evicting a sum(bytes) expression result from the SELECT clause column list

```
WITH sum(bytes) as s
SELECT
    formatReadableSize(s),
    table
FROM system.parts
GROUP BY table
ORDER BY s;
```

**Example 3:** Using results of a scalar subquery

```
/* this example would return TOP 10 of most huge tables */
WITH
    (
        SELECT sum(bytes)
        FROM system.parts
        WHERE active
    ) AS total_disk_usage
SELECT
    (sum(bytes) / total_disk_usage) * 100 AS table_disk_usage,
    table
FROM system.parts
GROUP BY table
ORDER BY table_disk_usage DESC
LIMIT 10;
```

**Example 4:** Reusing expression in a subquery

```
WITH test1 AS (SELECT i + 1, j + 1 FROM test1)
SELECT * FROM test1;
```

' where id=72;
update biz_data_query_model_help_content set content_en = '# count

Counts the number of rows or not-NULL values.

ClickHouse supports the following syntaxes for `count`:

- `count(expr)` or `COUNT(DISTINCT expr)`.
- `count()` or `COUNT(*)`. The `count()` syntax is ClickHouse-specific.

**Arguments**

The function can take:

- Zero parameters.
- One [expression].

**Returned value**

- If the function is called without parameters it counts the number of rows.
- If the [expression] is passed, then the function counts how many times this expression returned not null. If the expression returns a [Nullable]-type value, then the result of `count` stays not `Nullable`. The function returns 0 if the expression returned `NULL` for all the rows.

In both cases the type of the returned value is [UInt64].

**Details**

ClickHouse supports the `COUNT(DISTINCT ...)` syntax. The behavior of this construction depends on the [count_distinct_implementation] setting. It defines which of the [uniq*] functions is used to perform the operation. The default is the [uniqExact] function.

The `SELECT count() FROM table` query is not optimized, because the number of entries in the table is not stored separately. It chooses a small column from the table and counts the number of values in it.

However `SELECT count(nullable_column) FROM table` query can be optimized by enabling the [optimize_functions_to_subcolumns] setting. With `optimize_functions_to_subcolumns = 1` the function reads only [null] subcolumn instead of reading and processing the whole column data. The query `SELECT count(n) FROM table` transforms to `SELECT sum(NOT n.null) FROM table`.

**Examples**

Example 1:

```
SELECT count() FROM t
┌─count()─┐
│       5 │
└─────────┘
```

Example 2:

```
SELECT name, value FROM system.settings WHERE name = count_distinct_implementation
┌─name──────────────────────────┬─value─────┐
│ count_distinct_implementation │ uniqExact │
└───────────────────────────────┴───────────┘
SELECT count(DISTINCT num) FROM t
┌─uniqExact(num)─┐
│              3 │
└────────────────┘
```

This example shows that `count(DISTINCT num)` is performed by the `uniqExact` function according to the `count_distinct_implementation` setting value.

' where id=73;
update biz_data_query_model_help_content set content_en = '## min

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
update biz_data_query_model_help_content set content_en = '# max

Aggregate function that calculates the maximum across a group of values.

Example:

```
SELECT max(salary) FROM employees;
SELECT department, max(salary) FROM employees GROUP BY department;
```

If you need non-aggregate function to choose a maximum of two values, see `greatest`:

```
SELECT greatest(a, b) FROM table;
```

' where id=75;
update biz_data_query_model_help_content set content_en = '#sum

Calculatesthesum.Onlyworksfornumbers.' where id=76;
update biz_data_query_model_help_content set content_en = '# avg

Calculates the arithmetic mean.

**Syntax**

```
avg(x)
```

**Arguments**

- `x` — input values, must be Integer, Float, or Decimal.

**Returned value**

- The arithmetic mean, always as Float64.
- `NaN` if the input parameter `x` is empty.

**Example**

Query:

```
SELECT avg(x) FROM values(x Int8, 0, 1, 2, 3, 4, 5);
```

Result:

```
┌─avg(x)─┐
│    2.5 │
└────────┘
```

**Example**

Create a temp table:

Query:

```
CREATE table test (t UInt8) ENGINE = Memory;
```

Get the arithmetic mean:

Query:

```
SELECT avg(t) FROM test;
```

Result:

```
┌─avg(x)─┐
│    nan │
└────────┘
```

' where id=77;
update biz_data_query_model_help_content set content_en = '# any

Selects the first encountered value.
The query can be executed in any order and even in a different order each time, so the result of this function is indeterminate.
To get a determinate result, you can use the ‘min’ or ‘max’ function instead of ‘any’.

In some cases, you can rely on the order of execution. This applies to cases when SELECT comes from a subquery that uses ORDER BY.

When a `SELECT` query has the `GROUP BY` clause or at least one aggregate function, ClickHouse (in contrast to MySQL) requires that all expressions in the `SELECT`, `HAVING`, and `ORDER BY` clauses be calculated from keys or from aggregate functions. In other words, each column selected from the table must be used either in keys or inside aggregate functions. To get behavior like in MySQL, you can put the other columns in the `any` aggregate function.

' where id=78;
update biz_data_query_model_help_content set content_en = '# stddevPop

The result is equal to the square root of varPop.' where id=79;
update biz_data_query_model_help_content set content_en = '# stddevSamp

The result is equal to the square root of varSamp.

' where id=80;
update biz_data_query_model_help_content set content_en = '# varPop(x)

Calculates the amount `Σ((x - x̅)^2) / n`, where `n` is the sample size and `x̅`is the average value of `x`.

In other words, dispersion for a set of values. Returns `Float64`.' where id=81;
update biz_data_query_model_help_content set content_en = '# varSamp

Calculates the amount `Σ((x - x̅)^2) / (n - 1)`, where `n` is the sample size and `x̅`is the average value of `x`.

It represents an unbiased estimate of the variance of a random variable if passed values form its sample.

Returns `Float64`. When `n <= 1`, returns `+∞`.' where id=82;
update biz_data_query_model_help_content set content_en = '# covarPop

Syntax: `covarPop(x, y)`

Calculates the value of `Σ((x - x̅)(y - y̅)) / n`.

Note

This function uses a numerically unstable algorithm. If you need numerical stability in calculations, use the `covarPopStable` function. It works slower but provides a lower computational error.

' where id=83;
update biz_data_query_model_help_content set content_en = '# covarSamp

Calculates the value of `Σ((x - x̅)(y - y̅)) / (n - 1)`.

Returns Float64. When `n <= 1`, returns +∞.

Note

This function uses a numerically unstable algorithm. If you need numerical stability in calculations, use the `covarSampStable` function. It works slower but provides a lower computational error.

' where id=84;
update biz_data_query_model_help_content set content_en = '# anyHeavy

Selects a frequently occurring value using the heavy hitters algorithm. If there is a value that occurs more than in half the cases in each of the query’s execution threads, this value is returned. Normally, the result is nondeterministic.

```
anyHeavy(column)
```

**Arguments**

- `column` – The column name.

**Example**

Take the [OnTime] data set and select any frequently occurring value in the `AirlineID` column.

```
SELECT anyHeavy(AirlineID) AS res
FROM ontime
┌───res─┐
│ 19690 │
└───────┘
```

' where id=85;
update biz_data_query_model_help_content set content_en = '## anyLast

Selects the last value encountered.
The result is just as indeterminate as for the  any function.

' where id=86;
update biz_data_query_model_help_content set content_en = '# argMin

Calculates the `arg` value for a minimum `val` value. If there are several different values of `arg` for minimum values of `val`, returns the first of these values encountered.

**Syntax**

```
argMin(arg, val)
```

**Arguments**

- `arg` — Argument.
- `val` — Value.

**Returned value**

- `arg` value that corresponds to minimum `val` value.

Type: matches `arg` type.

**Example**

Input table:

```
┌─user─────┬─salary─┐
│ director │   5000 │
│ manager  │   3000 │
│ worker   │   1000 │
└──────────┴────────┘
```

Query:

```
SELECT argMin(user, salary) FROM salary
```

Result:

```
┌─argMin(user, salary)─┐
│ worker               │
└──────────────────────┘
```

' where id=87;
update biz_data_query_model_help_content set content_en = '# argMax

Calculates the `arg` value for a maximum `val` value. If there are several different values of `arg` for maximum values of `val`, returns the first of these values encountered.

**Syntax**

```
argMax(arg, val)
```

**Arguments**

- `arg` — Argument.
- `val` — Value.

**Returned value**

- `arg` value that corresponds to maximum `val` value.

Type: matches `arg` type.

**Example**

Input table:

```
┌─user─────┬─salary─┐
│ director │   5000 │
│ manager  │   3000 │
│ worker   │   1000 │
└──────────┴────────┘
```

Query:

```
SELECT argMax(user, salary) FROM salary;
```

Result:

```
┌─argMax(user, salary)─┐
│ director             │
└──────────────────────┘
```' where id=88;
update biz_data_query_model_help_content set content_en = '# avgWeighted

Calculates the [weighted arithmetic mean].

**Syntax**

```
avgWeighted(x, weight)
```

**Arguments**

- `x` — Values.
- `weight` — Weights of the values.

`x` and `weight` must both be
[Integer],
[floating-point], or
[Decimal],
but may have different types.

**Returned value**

- `NaN` if all the weights are equal to 0 or the supplied weights parameter is empty.
- Weighted mean otherwise.

**Return type** is always [Float64].

**Example**

Query:

```
SELECT avgWeighted(x, w)
FROM values(x Int8, w Int8, (4, 1), (1, 0), (10, 2))
```

Result:

```
┌─avgWeighted(x, weight)─┐
│                      8 │
└────────────────────────┘
```

**Example**

Query:

```
SELECT avgWeighted(x, w)
FROM values(x Int8, w Float64, (4, 1), (1, 0), (10, 2))
```

Result:

```
┌─avgWeighted(x, weight)─┐
│                      8 │
└────────────────────────┘
```

**Example**

Query:

```
SELECT avgWeighted(x, w)
FROM values(x Int8, w Int8, (0, 0), (1, 0), (10, 0))
```

Result:

```
┌─avgWeighted(x, weight)─┐
│                    nan │
└────────────────────────┘
```

**Example**

Query:

```
CREATE table test (t UInt8) ENGINE = Memory;
SELECT avgWeighted(t) FROM test
```

Result:

```
┌─avgWeighted(x, weight)─┐
│                    nan │
└────────────────────────┘
```

' where id=89;
update biz_data_query_model_help_content set content_en = '# corr

Syntax: `corr(x, y)`

Calculates the Pearson correlation coefficient: `Σ((x - x̅)(y - y̅)) / sqrt(Σ((x - x̅)^2) * Σ((y - y̅)^2))`.

Note

This function uses a numerically unstable algorithm. If you need numerical stability in calculations, use the `corrStable` function. It works slower but provides a lower computational error.

' where id=90;
update biz_data_query_model_help_content set content_en = '# topK

Returns an array of the approximately most frequent values in the specified column. The resulting array is sorted in descending order of approximate frequency of values (not by the values themselves).

Implements the Filtered Space-Saving] algorithm for analyzing TopK, based on the reduce-and-combine algorithm from [Parallel Space Saving].

```
topK(N)(column)
```

This function does not provide a guaranteed result. In certain situations, errors might occur and it might return frequent values that aren’t the most frequent values.

We recommend using the `N < 10` value; performance is reduced with large `N` values. Maximum value of `N = 65536`.

**Arguments**

- `N` – The number of elements to return.

If the parameter is omitted, default value 10 is used.

**Arguments**

- `x` – The value to calculate frequency.

**Example**

Take the [OnTime] data set and select the three most frequently occurring values in the `AirlineID` column.

```
SELECT topK(3)(AirlineID) AS res
FROM ontime
┌─res─────────────────┐
│ [19393,19790,19805] │
└─────────────────────┘
```' where id=91;
update biz_data_query_model_help_content set content_en = '# topKWeighted

Returns an array of the approximately most frequent values in the specified column. The resulting array is sorted in descending order of approximate frequency of values (not by the values themselves). Additionally, the weight of the value is taken into account.

**Syntax**

```
topKWeighted(N)(x, weight)
```

**Arguments**

- `N` — The number of elements to return.
- `x` — The value.
- `weight` — The weight. Every value is accounted `weight` times for frequency calculation. UInt64.

**Returned value**

Returns an array of the values with maximum approximate sum of weights.

**Example**

Query:

```
SELECT topKWeighted(10)(number, number) FROM numbers(1000)
```

Result:

```
┌─topKWeighted(10)(number, number)──────────┐
│ [999,998,997,996,995,994,993,992,991,990] │
└───────────────────────────────────────────┘
```' where id=92;
update biz_data_query_model_help_content set content_en = '# groupArray

Syntax: `groupArray(x)` or `groupArray(max_size)(x)`

Creates an array of argument values.
Values can be added to the array in any (indeterminate) order.

The second version (with the `max_size` parameter) limits the size of the resulting array to `max_size` elements. For example, `groupArray(1)(x)` is equivalent to `[any (x)]`.

In some cases, you can still rely on the order of execution. This applies to cases when `SELECT` comes from a subquery that uses `ORDER BY`.

' where id=93;
update biz_data_query_model_help_content set content_en = '# groupUniqArray

Syntax: `groupUniqArray(x)` or `groupUniqArray(max_size)(x)`

Creates an array from different argument values. Memory consumption is the same as for the uniqExact function.

The second version (with the `max_size` parameter) limits the size of the resulting array to `max_size` elements.
For example, `groupUniqArray(1)(x)` is equivalent to `[any(x)]`.

' where id=94;
update biz_data_query_model_help_content set content_en = '# groupArrayInsertAt

Inserts a value into the array at the specified position.

**Syntax**

```
groupArrayInsertAt(default_x, size)(x, pos)
```

If in one query several values are inserted into the same position, the function behaves in the following ways:

- If a query is executed in a single thread, the first one of the inserted values is used.
- If a query is executed in multiple threads, the resulting value is an undetermined one of the inserted values.

**Arguments**

- `x` — Value to be inserted. [Expression] resulting in one of the [supported data types].
- `pos` — Position at which the specified element `x` is to be inserted. Index numbering in the array starts from zero. [UInt32].
- `default_x` — Default value for substituting in empty positions. Optional parameter. [Expression] resulting in the data type configured for the `x` parameter. If `default_x` is not defined, the [default values] are used.
- `size` — Length of the resulting array. Optional parameter. When using this parameter, the default value `default_x` must be specified. [UInt32].

**Returned value**

- Array with inserted values.

Type: [Array].

**Example**

Query:

```
SELECT groupArrayInsertAt(toString(number), number * 2) FROM numbers(5);
```

Result:

```
┌─groupArrayInsertAt(toString(number), multiply(number, 2))─┐
│ [0,,1,,2,,3,,4]                         │
└───────────────────────────────────────────────────────────┘
```

Query:

```
SELECT groupArrayInsertAt(-)(toString(number), number * 2) FROM numbers(5);
```

Result:

```
┌─groupArrayInsertAt(-)(toString(number), multiply(number, 2))─┐
│ [0,-,1,-,2,-,3,-,4]                          │
└────────────────────────────────────────────────────────────────┘
```

Query:

```
SELECT groupArrayInsertAt(-, 5)(toString(number), number * 2) FROM numbers(5);
```

Result:

```
┌─groupArrayInsertAt(-, 5)(toString(number), multiply(number, 2))─┐
│ [0,-,1,-,2]                                             │
└───────────────────────────────────────────────────────────────────┘
```

Multi-threaded insertion of elements into one position.

Query:

```
SELECT groupArrayInsertAt(number, 0) FROM numbers_mt(10) SETTINGS max_block_size = 1;
```

As a result of this query you get random integer in the `[0,9]` range. For example:

```
┌─groupArrayInsertAt(number, 0)─┐
│ [7]                           │
└───────────────────────────────┘
```' where id=95;
update biz_data_query_model_help_content set content_en = '# groupArrayMovingSum

Calculates the moving sum of input values.

```
groupArrayMovingSum(numbers_for_summing)
groupArrayMovingSum(window_size)(numbers_for_summing)
```

The function can take the window size as a parameter. If left unspecified, the function takes the window size equal to the number of rows in the column.

**Arguments**

- `numbers_for_summing` — Expression resulting in a numeric data type value.
- `window_size` — Size of the calculation window.

**Returned values**

- Array of the same size and type as the input data.

**Example**

The sample table:

```
CREATE TABLE t
(
    `int` UInt8,
    `float` Float32,
    `dec` Decimal32(2)
)
ENGINE = TinyLog
┌─int─┬─float─┬──dec─┐
│   1 │   1.1 │ 1.10 │
│   2 │   2.2 │ 2.20 │
│   4 │   4.4 │ 4.40 │
│   7 │  7.77 │ 7.77 │
└─────┴───────┴──────┘
```

The queries:

```
SELECT
    groupArrayMovingSum(int) AS I,
    groupArrayMovingSum(float) AS F,
    groupArrayMovingSum(dec) AS D
FROM t
┌─I──────────┬─F───────────────────────────────┬─D──────────────────────┐
│ [1,3,7,14] │ [1.1,3.302,7.703,15.47] │ [1.10,3.30,7.70,15.47] │
└────────────┴─────────────────────────────────┴────────────────────────┘
SELECT
    groupArrayMovingSum(2)(int) AS I,
    groupArrayMovingSum(2)(float) AS F,
    groupArrayMovingSum(2)(dec) AS D
FROM t
┌─I──────────┬─F───────────────────────────────┬─D──────────────────────┐
│ [1,3,6,11] │ [1.1,3.302,6.604,12.17] │ [1.10,3.30,6.60,12.17] │
└────────────┴─────────────────────────────────┴────────────────────────┘
```

' where id=96;
update biz_data_query_model_help_content set content_en = '# groupArrayMovingAvg

Calculates the moving average of input values.

```
groupArrayMovingAvg(numbers_for_summing)
groupArrayMovingAvg(window_size)(numbers_for_summing)
```

The function can take the window size as a parameter. If left unspecified, the function takes the window size equal to the number of rows in the column.

**Arguments**

- `numbers_for_summing` — [Expression] resulting in a numeric data type value.
- `window_size` — Size of the calculation window.

**Returned values**

- Array of the same size and type as the input data.

The function uses [rounding towards zero]. It truncates the decimal places insignificant for the resulting data type.

**Example**

The sample table `b`:

```
CREATE TABLE t
(
    `int` UInt8,
    `float` Float32,
    `dec` Decimal32(2)
)
ENGINE = TinyLog
┌─int─┬─float─┬──dec─┐
│   1 │   1.1 │ 1.10 │
│   2 │   2.2 │ 2.20 │
│   4 │   4.4 │ 4.40 │
│   7 │  7.77 │ 7.77 │
└─────┴───────┴──────┘
```

The queries:

```
SELECT
    groupArrayMovingAvg(int) AS I,
    groupArrayMovingAvg(float) AS F,
    groupArrayMovingAvg(dec) AS D
FROM t
┌─I─────────┬─F───────────────────────────────────┬─D─────────────────────┐
│ [0,0,1,3] │ [0.275,0.8255,1.9250001,3.8675] │ [0.27,0.82,1.92,3.86] │
└───────────┴─────────────────────────────────────┴───────────────────────┘
SELECT
    groupArrayMovingAvg(2)(int) AS I,
    groupArrayMovingAvg(2)(float) AS F,
    groupArrayMovingAvg(2)(dec) AS D
FROM t
┌─I─────────┬─F────────────────────────────────┬─D─────────────────────┐
│ [0,1,3,5] │ [0.55,1.651,3.302,6.085] │ [0.55,1.65,3.30,6.08] │
└───────────┴──────────────────────────────────┴───────────────────────┘
```' where id=97;
update biz_data_query_model_help_content set content_en = '# groupArraySample

Creates an array of sample argument values. The size of the resulting array is limited to `max_size` elements. Argument values are selected and added to the array randomly.

**Syntax**

```
groupArraySample(max_size[, seed])(x)
```

**Arguments**

- `max_size` — Maximum size of the resulting array. UInt64.
- `seed` — Seed for the random number generator. Optional. UInt64. Default value: `123456`.
- `x` — Argument (column name or expression).

**Returned values**

- Array of randomly selected `x` arguments.

Type: Array.

**Examples**

Consider table `colors`:

```
┌─id─┬─color──┐
│  1 │ red    │
│  2 │ blue   │
│  3 │ green  │
│  4 │ white  │
│  5 │ orange │
└────┴────────┘
```

Query with column name as argument:

```
SELECT groupArraySample(3)(color) as newcolors FROM colors;
```

Result:

```
┌─newcolors──────────────────┐
│ [white,blue,green]   │
└────────────────────────────┘
```

Query with column name and different seed:

```
SELECT groupArraySample(3, 987654321)(color) as newcolors FROM colors;
```

Result:

```
┌─newcolors──────────────────┐
│ [red,orange,green]   │
└────────────────────────────┘
```

Query with expression as argument:

```
SELECT groupArraySample(3)(concat(light-, color)) as newcolors FROM colors;
```

Result:

```
┌─newcolors───────────────────────────────────┐
│ [light-blue,light-orange,light-green] │
└─────────────────────────────────────────────┘
```' where id=98;
update biz_data_query_model_help_content set content_en = '# groupBitAnd

Applies bitwise `AND` for series of numbers.

```
groupBitAnd(expr)
```

**Arguments**

`expr` – An expression that results in `UInt*` type.

**Return value**

Value of the `UInt*` type.

**Example**

Test data:

```
binary     decimal
00101100 = 44
00011100 = 28
1101 = 13
01010101 = 85
```

Query:

```
SELECT groupBitAnd(num) FROM t
```

Where `num` is the column with the test data.

Result:

```
binary     decimal
0100 = 4
```' where id=99;


update biz_data_query_model_help_content set content_en = '# groupBitOr

Applies bitwise `OR` for series of numbers.

```
groupBitOr(expr)
```

**Arguments**

`expr` – An expression that results in `UInt*` type.

**Returned value**

Value of the `UInt*` type.

**Example**

Test data:

```
binary     decimal
00101100 = 44
00011100 = 28
1101 = 13
01010101 = 85
```

Query:

```
SELECT groupBitOr(num) FROM t
```

Where `num` is the column with the test data.

Result:

```
binary     decimal
01111101 = 125
```' where id=100;
update biz_data_query_model_help_content set content_en = '# groupBitXor

Applies bitwise `XOR` for series of numbers.

```
groupBitXor(expr)
```

**Arguments**

`expr` – An expression that results in `UInt*` type.

**Return value**

Value of the `UInt*` type.

**Example**

Test data:

```
binary     decimal
00101100 = 44
00011100 = 28
1101 = 13
01010101 = 85
```

Query:

```
SELECT groupBitXor(num) FROM t
```

Where `num` is the column with the test data.

Result:

```
binary     decimal
01101000 = 104
```' where id=101;
update biz_data_query_model_help_content set content_en = '# groupBitmap

Bitmap or Aggregate calculations from a unsigned integer column, return cardinality of type UInt64, if add suffix -State, then return bitmap object.

```
groupBitmap(expr)
```

**Arguments**

`expr` – An expression that results in `UInt*` type.

**Return value**

Value of the `UInt64` type.

**Example**

Test data:

```
UserID
1
1
2
3
```

Query:

```
SELECT groupBitmap(UserID) as num FROM t
```

Result:

```
num
3
```' where id=102;
update biz_data_query_model_help_content set content_en = '# groupBitmapAnd

Calculations the AND of a bitmap column, return cardinality of type UInt64, if add suffix -State, then return bitmap object.

```
groupBitmapAnd(expr)
```

**Arguments**

`expr` – An expression that results in `AggregateFunction(groupBitmap, UInt*)` type.

**Return value**

Value of the `UInt64` type.

**Example**

```
DROP TABLE IF EXISTS bitmap_column_expr_test2;
CREATE TABLE bitmap_column_expr_test2
(
    tag_id String,
    z AggregateFunction(groupBitmap, UInt32)
)
ENGINE = MergeTree
ORDER BY tag_id;

INSERT INTO bitmap_column_expr_test2 VALUES (tag1, bitmapBuild(cast([1,2,3,4,5,6,7,8,9,10] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (tag2, bitmapBuild(cast([6,7,8,9,10,11,12,13,14,15] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (tag3, bitmapBuild(cast([2,4,6,8,10,12] as Array(UInt32))));

SELECT groupBitmapAnd(z) FROM bitmap_column_expr_test2 WHERE like(tag_id, tag%);
┌─groupBitmapAnd(z)─┐
│               3   │
└───────────────────┘

SELECT arraySort(bitmapToArray(groupBitmapAndState(z))) FROM bitmap_column_expr_test2 WHERE like(tag_id, tag%);
┌─arraySort(bitmapToArray(groupBitmapAndState(z)))─┐
│ [6,8,10]                                         │
└──────────────────────────────────────────────────┘
```' where id=103;
update biz_data_query_model_help_content set content_en = '# groupBitmapOr

Calculations the OR of a bitmap column, return cardinality of type UInt64, if add suffix -State, then return bitmap object. This is equivalent to `groupBitmapMerge`.

```
groupBitmapOr(expr)
```

**Arguments**

`expr` – An expression that results in `AggregateFunction(groupBitmap, UInt*)` type.

**Returned value**

Value of the `UInt64` type.

**Example**

```
DROP TABLE IF EXISTS bitmap_column_expr_test2;
CREATE TABLE bitmap_column_expr_test2
(
    tag_id String,
    z AggregateFunction(groupBitmap, UInt32)
)
ENGINE = MergeTree
ORDER BY tag_id;

INSERT INTO bitmap_column_expr_test2 VALUES (tag1, bitmapBuild(cast([1,2,3,4,5,6,7,8,9,10] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (tag2, bitmapBuild(cast([6,7,8,9,10,11,12,13,14,15] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (tag3, bitmapBuild(cast([2,4,6,8,10,12] as Array(UInt32))));

SELECT groupBitmapOr(z) FROM bitmap_column_expr_test2 WHERE like(tag_id, tag%);
┌─groupBitmapOr(z)─┐
│             15   │
└──────────────────┘

SELECT arraySort(bitmapToArray(groupBitmapOrState(z))) FROM bitmap_column_expr_test2 WHERE like(tag_id, tag%);
┌─arraySort(bitmapToArray(groupBitmapOrState(z)))─┐
│ [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]           │
└─────────────────────────────────────────────────┘
```' where id=104;
update biz_data_query_model_help_content set content_en = '# groupBitmapXor

Calculations the XOR of a bitmap column, return cardinality of type UInt64, if add suffix -State, then return bitmap object.

```
groupBitmapOr(expr)
```

**Arguments**

`expr` – An expression that results in `AggregateFunction(groupBitmap, UInt*)` type.

**Returned value**

Value of the `UInt64` type.

**Example**

```
DROP TABLE IF EXISTS bitmap_column_expr_test2;
CREATE TABLE bitmap_column_expr_test2
(
    tag_id String,
    z AggregateFunction(groupBitmap, UInt32)
)
ENGINE = MergeTree
ORDER BY tag_id;

INSERT INTO bitmap_column_expr_test2 VALUES (tag1, bitmapBuild(cast([1,2,3,4,5,6,7,8,9,10] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (tag2, bitmapBuild(cast([6,7,8,9,10,11,12,13,14,15] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (tag3, bitmapBuild(cast([2,4,6,8,10,12] as Array(UInt32))));

SELECT groupBitmapXor(z) FROM bitmap_column_expr_test2 WHERE like(tag_id, tag%);
┌─groupBitmapXor(z)─┐
│              10   │
└───────────────────┘

SELECT arraySort(bitmapToArray(groupBitmapXorState(z))) FROM bitmap_column_expr_test2 WHERE like(tag_id, tag%);
┌─arraySort(bitmapToArray(groupBitmapXorState(z)))─┐
│ [1,3,5,6,8,10,11,13,14,15]                       │
└──────────────────────────────────────────────────┘
```' where id=105;
update biz_data_query_model_help_content set content_en = '# sumWithOverflow

Computes the sum of the numbers, using the same data type for the result as for the input parameters. If the sum exceeds the maximum value for this data type, it is calculated with overflow.

Only works for numbers.

' where id=106;
update biz_data_query_model_help_content set content_en = '# deltaSum

Sums the arithmetic difference between consecutive rows. If the difference is negative, it is ignored.

Note

The underlying data must be sorted for this function to work properly. If you would like to use this function in a [materialized view], you most likely want to use the [deltaSumTimestamp] method instead.

**Syntax**

```
deltaSum(value)
```

**Arguments**

- `value` — Input values, must be [Integer] or [Float] type.

**Returned value**

- A gained arithmetic difference of the `Integer` or `Float` type.

**Examples**

Query:

```
SELECT deltaSum(arrayJoin([1, 2, 3]));
```

Result:

```
┌─deltaSum(arrayJoin([1, 2, 3]))─┐
│                              2 │
└────────────────────────────────┘
```

Query:

```
SELECT deltaSum(arrayJoin([1, 2, 3, 0, 3, 4, 2, 3]));
```

Result:

```
┌─deltaSum(arrayJoin([1, 2, 3, 0, 3, 4, 2, 3]))─┐
│                                             7 │
└───────────────────────────────────────────────┘
```

Query:

```
SELECT deltaSum(arrayJoin([2.25, 3, 4.5]));
```

Result:

```
┌─deltaSum(arrayJoin([2.25, 3, 4.5]))─┐
│                                2.25 │
└─────────────────────────────────────┘
```' where id=107;
update biz_data_query_model_help_content set content_en = '# sumMap

Syntax: `sumMap(key, value)` or `sumMap(Tuple(key, value))`

Totals the `value` array according to the keys specified in the `key` array.

Passing tuple of keys and values arrays is a synonym to passing two arrays of keys and values.

The number of elements in `key` and `value` must be the same for each row that is totaled.

Returns a tuple of two arrays: keys in sorted order, and values summed for the corresponding keys.

Example:

```
CREATE TABLE sum_map(
    date Date,
    timeslot DateTime,
    statusMap Nested(
        status UInt16,
        requests UInt64
    ),
    statusMapTuple Tuple(Array(Int32), Array(Int32))
) ENGINE = Log;
INSERT INTO sum_map VALUES
    (2000-01-01, 2000-01-01 00:00:00, [1, 2, 3], [10, 10, 10], ([1, 2, 3], [10, 10, 10])),
    (2000-01-01, 2000-01-01 00:00:00, [3, 4, 5], [10, 10, 10], ([3, 4, 5], [10, 10, 10])),
    (2000-01-01, 2000-01-01 00:01:00, [4, 5, 6], [10, 10, 10], ([4, 5, 6], [10, 10, 10])),
    (2000-01-01, 2000-01-01 00:01:00, [6, 7, 8], [10, 10, 10], ([6, 7, 8], [10, 10, 10]));

SELECT
    timeslot,
    sumMap(statusMap.status, statusMap.requests),
    sumMap(statusMapTuple)
FROM sum_map
GROUP BY timeslot
┌────────────timeslot─┬─sumMap(statusMap.status, statusMap.requests)─┬─sumMap(statusMapTuple)─────────┐
│ 2000-01-01 00:00:00 │ ([1,2,3,4,5],[10,10,20,10,10])               │ ([1,2,3,4,5],[10,10,20,10,10]) │
│ 2000-01-01 00:01:00 │ ([4,5,6,7,8],[10,10,20,10,10])               │ ([4,5,6,7,8],[10,10,20,10,10]) │
└─────────────────────┴──────────────────────────────────────────────┴────────────────────────────────┘
```' where id=108;
update biz_data_query_model_help_content set content_en = '# minMap

Syntax: `minMap(key, value)` or `minMap(Tuple(key, value))`

Calculates the minimum from `value` array according to the keys specified in the `key` array.

Passing a tuple of keys and value arrays is identical to passing two arrays of keys and values.

The number of elements in `key` and `value` must be the same for each row that is totaled.

Returns a tuple of two arrays: keys in sorted order, and values calculated for the corresponding keys.

Example:

```
SELECT minMap(a, b)
FROM values(a Array(Int32), b Array(Int64), ([1, 2], [2, 2]), ([2, 3], [1, 1]))
┌─minMap(a, b)──────┐
│ ([1,2,3],[2,1,1]) │
└───────────────────┘
```' where id=109;
update biz_data_query_model_help_content set content_en = '# maxMap

Syntax: `maxMap(key, value)` or `maxMap(Tuple(key, value))`

Calculates the maximum from `value` array according to the keys specified in the `key` array.

Passing a tuple of keys and value arrays is identical to passing two arrays of keys and values.

The number of elements in `key` and `value` must be the same for each row that is totaled.

Returns a tuple of two arrays: keys and values calculated for the corresponding keys.

Example:

```
SELECT maxMap(a, b)
FROM values(a Array(Int32), b Array(Int64), ([1, 2], [2, 2]), ([2, 3], [1, 1]))
┌─maxMap(a, b)──────┐
│ ([1,2,3],[2,2,1]) │
└───────────────────┘
```' where id=110;
update biz_data_query_model_help_content set content_en = '####initializeAggregation

The component used to initialize the aggregation of the specified lines. This component is used for functions hava State as the suffix.

The component used to test or process columns of the AggregateFunction and AggregationgMergeTree types.

**Syntax**

```
initializeAggregation(aggregate_function,column_1,column_2)
```

**Parameter**

-`aggregate_function`—聚合函数名。这个函数的状态—正创建的。String。

**Return value**

The aggregated result of the specified lines are returned. The type of the return value is the same as that of the function that has initializeAgregation as the first parameter.

For example, for functions have State as the suffix, the return value is AggregateFunction.

**Example**

Query:

```
SELECTuniqMerge(state)FROM(SELECTinitializeAggregation(uniqState,number%3)ASstateFROMsystem.numbersLIMIT1);
```

Result:

┌─uniqMerge(state)─┐
│3│
└──────────────────┘' where id=111;
update biz_data_query_model_help_content set content_en = '# skewPop

Computes the [skewness] of a sequence.

```
skewPop(expr)
```

**Arguments**

`expr` — [Expression] returning a number.

**Returned value**

The skewness of the given distribution. Type — [Float64]

**Example**

```
SELECT skewPop(value) FROM series_with_value_column;
```

' where id=112;
update biz_data_query_model_help_content set content_en = '# skewSamp

Computes the [sample skewness] of a sequence.

It represents an unbiased estimate of the skewness of a random variable if passed values form its sample.

```
skewSamp(expr)
```

**Arguments**

`expr` — [Expression] returning a number.

**Returned value**

The skewness of the given distribution. Type — [Float64]. If `n <= 1` (`n` is the size of the sample), then the function returns `nan`.

**Example**

```
SELECT skewSamp(value) FROM series_with_value_column;
```' where id=113;
update biz_data_query_model_help_content set content_en = '# kurtPop

Computes the [kurtosis] of a sequence.

```
kurtPop(expr)
```

**Arguments**

`expr` — [Expression] returning a number.

**Returned value**

The kurtosis of the given distribution. Type — [Float64]

**Example**

```
SELECT kurtPop(value) FROM series_with_value_column;
```' where id=114;
update biz_data_query_model_help_content set content_en = '# kurtSamp

Computes the [sample kurtosis] of a sequence.

It represents an unbiased estimate of the kurtosis of a random variable if passed values form its sample.

```
kurtSamp(expr)
```

**Arguments**

`expr` — [Expression] returning a number.

**Returned value**

The kurtosis of the given distribution. Type — [Float64]. If `n <= 1` (`n` is a size of the sample), then the function returns `nan`.

**Example**

```
SELECT kurtSamp(value) FROM series_with_value_column;
```' where id=115;
update biz_data_query_model_help_content set content_en = '# uniq

Calculates the approximate number of different values of the argument.

```
uniq(x[, ...])
```

**Arguments**

The function takes a variable number of parameters. Parameters can be `Tuple`, `Array`, `Date`, `DateTime`, `String`, or numeric types.

**Returned value**

- A UInt64-type number.

**Implementation details**

Function:

- Calculates a hash for all parameters in the aggregate, then uses it in calculations.

- Uses an adaptive sampling algorithm. For the calculation state, the function uses a sample of element hash values up to 65536.

  ```
  This algorithm is very accurate and very efficient on the CPU. When the query contains several of these functions, using `uniq` is almost as fast as using other aggregate functions.
  ```

- Provides the result deterministically (it does not depend on the query processing order).

We recommend using this function in almost all scenarios.

' where id=116;
update biz_data_query_model_help_content set content_en = '# uniqExact

Calculates the exact number of different argument values.

```
uniqExact(x[, ...])
```

Use the `uniqExact` function if you absolutely need an exact result. Otherwise use the [uniq](https://clickhouse.tech/docs/en/sql-reference/aggregate-functions/reference/uniq/#agg_function-uniq) function.

The `uniqExact` function uses more memory than `uniq`, because the size of the state has unbounded growth as the number of different values increases.

**Arguments**

The function takes a variable number of parameters. Parameters can be `Tuple`, `Array`, `Date`, `DateTime`, `String`, or numeric types.

' where id=117;
update biz_data_query_model_help_content set content_en = '# uniqCombined

Calculates the approximate number of different argument values.

```
uniqCombined(HLL_precision)(x[, ...])
```

The `uniqCombined` function is a good choice for calculating the number of different values.

**Arguments**

The function takes a variable number of parameters. Parameters can be `Tuple`, `Array`, `Date`, `DateTime`, `String`, or numeric types.

`HLL_precision` is the base-2 logarithm of the number of cells in [HyperLogLog]. Optional, you can use the function as `uniqCombined(x[, ...])`. The default value for `HLL_precision` is 17, which is effectively 96 KiB of space (2^17 cells, 6 bits each).

**Returned value**

- A number [UInt64]-type number.

**Implementation details**

Function:

- Calculates a hash (64-bit hash for `String` and 32-bit otherwise) for all parameters in the aggregate, then uses it in calculations.

- Uses a combination of three algorithms: array, hash table, and HyperLogLog with an error correction table.

  ```
  For a small number of distinct elements, an array is used. When the set size is larger, a hash table is used. For a larger number of elements, HyperLogLog is used, which will occupy a fixed amount of memory.
  ```

- Provides the result deterministically (it does not depend on the query processing order).

Note

Since it uses 32-bit hash for non-`String` type, the result will have very high error for cardinalities significantly larger than `UINT_MAX` (error will raise quickly after a few tens of billions of distinct values), hence in this case you should use [uniqCombined64]

Compared to the [uniq] function, the `uniqCombined`:

- Consumes several times less memory.
- Calculates with several times higher accuracy.
- Usually has slightly lower performance. In some scenarios, `uniqCombined` can perform better than `uniq`, for example, with distributed queries that transmit a large number of aggregation states over the network.' where id=118;
update biz_data_query_model_help_content set content_en = '# uniqCombined64

Same as uniqCombined, but uses 64-bit hash for all data types.' where id=119;
update biz_data_query_model_help_content set content_en = '# uniqHLL12

Calculates the approximate number of different argument values, using the [HyperLogLog] algorithm.

```
uniqHLL12(x[, ...])
```

**Arguments**

The function takes a variable number of parameters. Parameters can be `Tuple`, `Array`, `Date`, `DateTime`, `String`, or numeric types.

**Returned value**

- A [UInt64]-type number.

**Implementation details**

Function:

- Calculates a hash for all parameters in the aggregate, then uses it in calculations.

- Uses the HyperLogLog algorithm to approximate the number of different argument values.

  ```
  2^12 5-bit cells are used. The size of the state is slightly more than 2.5 KB. The result is not very accurate (up to ~10% error) for small data sets (<10K elements). However, the result is fairly accurate for high-cardinality data sets (10K-100M), with a maximum error of ~1.6%. Starting from 100M, the estimation error increases, and the function will return very inaccurate results for data sets with extremely high cardinality (1B+ elements).
  ```

- Provides the determinate result (it does not depend on the query processing order).

We do not recommend using this function. In most cases, use the [uniq] or [uniqCombined] function.' where id=120;
update biz_data_query_model_help_content set content_en = '# quantile

Computes an approximate [quantile] of a numeric data sequence.

This function applies [reservoir sampling] with a reservoir size up to 8192 and a random number generator for sampling. The result is non-deterministic. To get an exact quantile, use the [quantileExact] function.

When using multiple `quantile*` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the [quantiles] function.

**Syntax**

```
quantile(level)(expr)
```

Alias: `median`.

**Arguments**

- `level` — Level of quantile. Optional parameter. Constant floating-point number from 0 to 1. We recommend using a `level` value in the range of `[0.01, 0.99]`. Default value: 0.5. At `level=0.5` the function calculates [median].
- `expr` — Expression over the column values resulting in numeric [data types], [Date] or [DateTime].

**Returned value**

- Approximate quantile of the specified level.

Type:

- [Float64] for numeric data type input.
- [Date] if input values have the `Date` type.
- [DateTime] if input values have the `DateTime` type.

**Example**

Input table:

```
┌─val─┐
│   1 │
│   1 │
│   2 │
│   3 │
└─────┘
```

Query:

```
SELECT quantile(val) FROM t
```

Result:

```
┌─quantile(val)─┐
│           1.5 │
└───────────────┘
```' where id=121;
update biz_data_query_model_help_content set content_en = '# quantiles Functions

## quantiles

Syntax: `quantiles(level1, level2, …)(x)`

All the quantile functions also have corresponding quantiles functions: `quantiles`, `quantilesDeterministic`, `quantilesTiming`, `quantilesTimingWeighted`, `quantilesExact`, `quantilesExactWeighted`, `quantilesTDigest`, `quantilesBFloat16`. These functions calculate all the quantiles of the listed levels in one pass, and return an array of the resulting values.

## quantilesExactExclusive

Exactly computes the [quantiles] of a numeric data sequence.

To get exact value, all the passed values are combined into an array, which is then partially sorted. Therefore, the function consumes `O(n)` memory, where `n` is a number of values that were passed. However, for a small number of values, the function is very effective.

This function is equivalent to [PERCENTILE.EXC] Excel function, ([type R6]).

Works more efficiently with sets of levels than [quantileExactExclusive].

**Syntax**

```
quantilesExactExclusive(level1, level2, ...)(expr)
```

**Arguments**

- `expr` — Expression over the column values resulting in numeric [data types], [Date] or [DateTime].

**Parameters**

- `level` — Levels of quantiles. Possible values: (0, 1) — bounds not included. [Float].

**Returned value**

- [Array] of quantiles of the specified levels.

Type of array values:

- [Float64] for numeric data type input.
- [Date] if input values have the `Date` type.
- [DateTime] if input values have the `DateTime` type.

**Example**

Query:

```
CREATE TABLE num AS numbers(1000);

SELECT quantilesExactExclusive(0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.999)(x) FROM (SELECT number AS x FROM num);
```

Result:

```
┌─quantilesExactExclusive(0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.999)(x)─┐
│ [249.25,499.5,749.75,899.9,949.9499999999999,989.99,998.999]        │
└─────────────────────────────────────────────────────────────────────┘
```

## quantilesExactInclusive

Exactly computes the [quantiles] of a numeric data sequence.

To get exact value, all the passed values are combined into an array, which is then partially sorted. Therefore, the function consumes `O(n)` memory, where `n` is a number of values that were passed. However, for a small number of values, the function is very effective.

This function is equivalent to [PERCENTILE.INC] Excel function, ([type R7]).

Works more efficiently with sets of levels than [quantileExactInclusive].

**Syntax**

```
quantilesExactInclusive(level1, level2, ...)(expr)
```

**Arguments**

- `expr` — Expression over the column values resulting in numeric [data types], [Date] or [DateTime].

**Parameters**

- `level` — Levels of quantiles. Possible values: [0, 1] — bounds included. [Float].

**Returned value**

- [Array] of quantiles of the specified levels.

Type of array values:

- [Float64] for numeric data type input.
- [Date] if input values have the `Date` type.
- [DateTime] if input values have the `DateTime` type.

**Example**

Query:

```
CREATE TABLE num AS numbers(1000);

SELECT quantilesExactInclusive(0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.999)(x) FROM (SELECT number AS x FROM num);
```

Result:

```
┌─quantilesExactInclusive(0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.999)(x)─┐
│ [249.75,499.5,749.25,899.1,949.05,989.01,998.001]                   │
└─────────────────────────────────────────────────────────────────────┘
```' where id=122;
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
┌─quantileExactHigh(number)─┐│                         5 │└───────────────────────────┘
```

## quantileExactExclusive

Exactly computes the [quantile] of a numeric data sequence.

To get exact value, all the passed values are combined into an array, which is then partially sorted. Therefore, the function consumes `O(n)` memory, where `n` is a number of values that were passed. However, for a small number of values, the function is very effective.

This function is equivalent to [PERCENTILE.EXC] Excel function, ([type R6]).

When using multiple `quantileExactExclusive` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the [quantilesExactExclusive] function.

**Syntax**

```
quantileExactExclusive(level)(expr)
```

**Arguments**

- `expr` — Expression over the column values resulting in numeric [data types], [Date] or [DateTime].

**Parameters**

- `level` — Level of quantile. Optional. Possible values: (0, 1) — bounds not included. Default value: 0.5. At `level=0.5` the function calculates [median]. [Float].

**Returned value**

- Quantile of the specified level.

Type:

- [Float64] for numeric data type input.
- [Date] if input values have the `Date` type.
- [DateTime] if input values have the `DateTime` type.

**Example**

Query:

```
CREATE TABLE num AS numbers(1000);SELECT quantileExactExclusive(0.6)(x) FROM (SELECT number AS x FROM num);
```

Result:

```
┌─quantileExactExclusive(0.6)(x)─┐│                          599.6 │└────────────────────────────────┘
```

## quantileExactInclusive

Exactly computes the [quantile] of a numeric data sequence.

To get exact value, all the passed values are combined into an array, which is then partially sorted. Therefore, the function consumes `O(n)` memory, where `n` is a number of values that were passed. However, for a small number of values, the function is very effective.

This function is equivalent to [PERCENTILE.INC] Excel function, ([type R7]).

When using multiple `quantileExactInclusive` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the [quantilesExactInclusive] function.

**Syntax**

```
quantileExactInclusive(level)(expr)
```

**Arguments**

- `expr` — Expression over the column values resulting in numeric [data types], [Date] or [DateTime].

**Parameters**

- `level` — Level of quantile. Optional. Possible values: [0, 1] — bounds included. Default value: 0.5. At `level=0.5` the function calculates [median]. [Float].

**Returned value**

- Quantile of the specified level.

Type:

- [Float64] for numeric data type input.
- [Date] if input values have the `Date` type.
- [DateTime] if input values have the `DateTime` type.

**Example**

Query:

```
CREATE TABLE num AS numbers(1000);

SELECT quantileExactInclusive(0.6)(x) FROM (SELECT number AS x FROM num);
```

Result:

```
┌─quantileExactInclusive(0.6)(x)─┐
│                          599.4 │
└────────────────────────────────┘
```' where id=123;
update biz_data_query_model_help_content set content_en = '# quantileExactWeighted

Exactly computes the [quantile] of a numeric data sequence, taking into account the weight of each element.

To get exact value, all the passed values are combined into an array, which is then partially sorted. Each value is counted with its weight, as if it is present `weight` times. A hash table is used in the algorithm. Because of this, if the passed values are frequently repeated, the function consumes less RAM than [quantileExact]. You can use this function instead of `quantileExact` and specify the weight 1.

When using multiple `quantile*` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the [quantiles] function.

**Syntax**

```
quantileExactWeighted(level)(expr, weight)
```

Alias: `medianExactWeighted`.

**Arguments**

- `level` — Level of quantile. Optional parameter. Constant floating-point number from 0 to 1. We recommend using a `level` value in the range of `[0.01, 0.99]`. Default value: 0.5. At `level=0.5` the function calculates [median].
- `expr` — Expression over the column values resulting in numeric [data types], [Date] or [DateTime].
- `weight` — Column with weights of sequence members. Weight is a number of value occurrences.

**Returned value**

- Quantile of the specified level.

Type:

- [Float64] for numeric data type input.
- [Date] if input values have the `Date` type.
- [DateTime] if input values have the `DateTime` type.

**Example**

Input table:

```
┌─n─┬─val─┐
│ 0 │   3 │
│ 1 │   2 │
│ 2 │   1 │
│ 5 │   4 │
└───┴─────┘
```

Query:

```
SELECT quantileExactWeighted(n, val) FROM t
```

Result:

```
┌─quantileExactWeighted(n, val)─┐
│                             1 │
└───────────────────────────────┘
```' where id=124;

update biz_data_query_model_help_content set content_en = '# quantileTiming

With the determined precision computes the quantile of a numeric data sequence.

The result is deterministic (it does not depend on the query processing order). The function is optimized for working with sequences which describe distributions like loading web pages times or backend response times.

When using multiple `quantile*` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the quantiles function.

**Syntax**

```
quantileTiming(level)(expr)
```

Alias: `medianTiming`.

**Arguments**

- `level` — Level of quantile. Optional parameter. Constant floating-point number from 0 to 1. We recommend using a `level` value in the range of `[0.01, 0.99]`. Default value: 0.5. At `level=0.5` the function calculates median.
- `expr` — Expression over a column values returning a Float*-type number.
  - If negative values are passed to the function, the behavior is undefined.
  - If the value is greater than 30,000 (a page loading time of more than 30 seconds), it is assumed to be 30,000.

**Accuracy**

The calculation is accurate if:

- Total number of values does not exceed 5670.
- Total number of values exceeds 5670, but the page loading time is less than 1024ms.

Otherwise, the result of the calculation is rounded to the nearest multiple of 16 ms.

Note

For calculating page loading time quantiles, this function is more effective and accurate than quantile.

**Returned value**

- Quantile of the specified level.

Type: `Float32`.

Note

If no values are passed to the function (when using `quantileTimingIf`), NaN is returned. The purpose of this is to differentiate these cases from cases that result in zero. See ORDER BY clause for notes on sorting `NaN` values.

**Example**

Input table:

```
┌─response_time─┐
│            72 │
│           112 │
│           126 │
│           145 │
│           104 │
│           242 │
│           313 │
│           168 │
│           108 │
└───────────────┘
```

Query:

```
SELECT quantileTiming(response_time) FROM t
```

Result:

```
┌─quantileTiming(response_time)─┐
│                           126 │
└───────────────────────────────┘
```' where id=125;
update biz_data_query_model_help_content set content_en = '# quantileTimingWeighted

With the determined precision computes the quantile of a numeric data sequence according to the weight of each sequence member.

The result is deterministic (it does not depend on the query processing order). The function is optimized for working with sequences which describe distributions like loading web pages times or backend response times.

When using multiple `quantile*` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the quantiles function.

**Syntax**

```
quantileTimingWeighted(level)(expr, weight)
```

Alias: `medianTimingWeighted`.

**Arguments**

- `level` — Level of quantile. Optional parameter. Constant floating-point number from 0 to 1. We recommend using a `level` value in the range of `[0.01, 0.99]`. Default value: 0.5. At `level=0.5` the function calculates median.

- `expr` — Expression over a column values returning a Float*-type number.

  ```
  - If negative values are passed to the function, the behavior is undefined.
  - If the value is greater than 30,000 (a page loading time of more than 30 seconds), it is assumed to be 30,000.
  ```

- `weight` — Column with weights of sequence elements. Weight is a number of value occurrences.

**Accuracy**

The calculation is accurate if:

- Total number of values does not exceed 5670.
- Total number of values exceeds 5670, but the page loading time is less than 1024ms.

Otherwise, the result of the calculation is rounded to the nearest multiple of 16 ms.

Note

For calculating page loading time quantiles, this function is more effective and accurate than quantile.

**Returned value**

- Quantile of the specified level.

Type: `Float32`.

Note

If no values are passed to the function (when using `quantileTimingIf`), NaN is returned. The purpose of this is to differentiate these cases from cases that result in zero. See ORDER BY clause for notes on sorting `NaN` values.

**Example**

Input table:

```
┌─response_time─┬─weight─┐
│            68 │      1 │
│           104 │      2 │
│           112 │      3 │
│           126 │      2 │
│           138 │      1 │
│           162 │      1 │
└───────────────┴────────┘
```

Query:

```
SELECT quantileTimingWeighted(response_time, weight) FROM t
```

Result:

```
┌─quantileTimingWeighted(response_time, weight)─┐
│                                           112 │
└───────────────────────────────────────────────┘
```

# quantilesTimingWeighted

Same as `quantileTimingWeighted`, but accept multiple parameters with quantile levels and return an Array filled with many values of that quantiles.

**Example**

Input table:

```
┌─response_time─┬─weight─┐
│            68 │      1 │
│           104 │      2 │
│           112 │      3 │
│           126 │      2 │
│           138 │      1 │
│           162 │      1 │
└───────────────┴────────┘
```

Query:

```
SELECT quantilesTimingWeighted(0,5, 0.99)(response_time, weight) FROM t
```

Result:

```
┌─quantilesTimingWeighted(0.5, 0.99)(response_time, weight)─┐
│ [112,162]                                                 │
└───────────────────────────────────────────────────────────┘
```' where id=126;
update biz_data_query_model_help_content set content_en = '# quantileDeterministic

Computes an approximate quantile of a numeric data sequence.

This function applies reservoir sampling with a reservoir size up to 8192 and deterministic algorithm of sampling. The result is deterministic. To get an exact quantile, use the quantileExact function.

When using multiple `quantile*` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the quantiles function.

**Syntax**

```
quantileDeterministic(level)(expr, determinator)
```

Alias: `medianDeterministic`.

**Arguments**

- `level` — Level of quantile. Optional parameter. Constant floating-point number from 0 to 1. We recommend using a `level` value in the range of `[0.01, 0.99]`. Default value: 0.5. At `level=0.5` the function calculates median.
- `expr` — Expression over the column values resulting in numeric data types, Date or DateTime.
- `determinator` — Number whose hash is used instead of a random number generator in the reservoir sampling algorithm to make the result of sampling deterministic. As a determinator you can use any deterministic positive number, for example, a user id or an event id. If the same determinator value occures too often, the function works incorrectly.

**Returned value**

- Approximate quantile of the specified level.

Type:

- Float64for numeric data type input.
- Date if input values have the `Date` type.
- DateTime if input values have the `DateTime` type.

**Example**

Input table:

```
┌─val─┐
│   1 │
│   1 │
│   2 │
│   3 │
└─────┘
```

Query:

```
SELECT quantileDeterministic(val, 1) FROM t
```

Result:

```
┌─quantileDeterministic(val, 1)─┐
│                           1.5 │
└───────────────────────────────┘
```

' where id=127;
update biz_data_query_model_help_content set content_en = '# quantileTDigest

Computes an approximate quantile of a numeric data sequence using the t-digest algorithm.

Memory consumption is `log(n)`, where `n` is a number of values. The result depends on the order of running the query, and is nondeterministic.

The performance of the function is lower than performance of quantile] or quantileTiming. In terms of the ratio of State size to precision, this function is much better than `quantile`.

When using multiple `quantile*` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the quantiles function.

**Syntax**

```
quantileTDigest(level)(expr)
```

Alias: `medianTDigest`.

**Arguments**

- `level` — Level of quantile. Optional parameter. Constant floating-point number from 0 to 1. We recommend using a `level` value in the range of `[0.01, 0.99]`. Default value: 0.5. At `level=0.5` the function calculates median.
- `expr` — Expression over the column values resulting in numeric data types, Date or DateTime.

**Returned value**

- Approximate quantile of the specified level.

Type:

- Float64 for numeric data type input.
- Date if input values have the `Date` type.
- DateTime if input values have the `DateTime` type.

**Example**

Query:

```
SELECT quantileTDigest(number) FROM numbers(10)
```

Result:

```
┌─quantileTDigest(number)─┐
│                     4.5 │
└─────────────────────────┘
```' where id=128;
update biz_data_query_model_help_content set content_en = '# quantileTDigestWeighted

Computes an approximate quantile of a numeric data sequence using the t-digest algorithm. The function takes into account the weight of each sequence member. The maximum error is 1%. Memory consumption is `log(n)`, where `n` is a number of values.

The performance of the function is lower than performance of quantile or quantileTiming. In terms of the ratio of State size to precision, this function is much better than `quantile`.

The result depends on the order of running the query, and is nondeterministic.

When using multiple `quantile*` functions with different levels in a query, the internal states are not combined (that is, the query works less efficiently than it could). In this case, use the quantilesfunction.

Note

Using `quantileTDigestWeighted` is not recommended for tiny data sets and can lead to significat error. In this case, consider possibility of using `quantileTDigest` instead.

**Syntax**

```
quantileTDigestWeighted(level)(expr, weight)
```

Alias: `medianTDigestWeighted`.

**Arguments**

- `level` — Level of quantile. Optional parameter. Constant floating-point number from 0 to 1. We recommend using a `level` value in the range of `[0.01, 0.99]`. Default value: 0.5. At `level=0.5` the function calculates median.
- `expr` — Expression over the column values resulting in numeric data types, Date or DateTime.
- `weight` — Column with weights of sequence elements. Weight is a number of value occurrences.

**Returned value**

- Approximate quantile of the specified level.

Type:

- Float64 for numeric data type input.
- Date if input values have the `Date` type.
- DateTime if input values have the `DateTime` type.

**Example**

Query:

```
SELECT quantileTDigestWeighted(number, 1) FROM numbers(10)
```

Result:

```
┌─quantileTDigestWeighted(number, 1)─┐
│                                4.5 │
└────────────────────────────────────┘
```' where id=129;
update biz_data_query_model_help_content set content_en = '# simpleLinearRegression

Performs simple (unidimensional) linear regression.

```
simpleLinearRegression(x, y)
```

Parameters:

- `x` — Column with dependent variable values.
- `y` — Column with explanatory variable values.

Returned values:

Constants `(a, b)` of the resulting line `y = a*x + b`.

**Examples**

```
SELECT arrayReduce(simpleLinearRegression, [0, 1, 2, 3], [0, 1, 2, 3])
┌─arrayReduce(simpleLinearRegression, [0, 1, 2, 3], [0, 1, 2, 3])─┐
│ (1,0)                                                             │
└───────────────────────────────────────────────────────────────────┘
SELECT arrayReduce(simpleLinearRegression, [0, 1, 2, 3], [3, 4, 5, 6])
┌─arrayReduce(simpleLinearRegression, [0, 1, 2, 3], [3, 4, 5, 6])─┐
│ (1,3)                                                             │
└───────────────────────────────────────────────────────────────────┘
```' where id=130;
update biz_data_query_model_help_content set content_en = '# stochasticLinearRegression

This function implements stochastic linear regression. It supports custom parameters for learning rate, L2 regularization coefficient, mini-batch size and has few methods for updating weights ([Adam](https://en.wikipedia.org/wiki/Stochastic_gradient_descent#Adam) (used by default), simple SGD, Momentum, Nesterov.

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
   Such query will fit the model and return its weights - first are weights, which correspond to the parameters of the model, the last one is bias. So in the example above the query will return a column with 3 values.' where id=131;
update biz_data_query_model_help_content set content_en = '# stochasticLogisticRegression

This function implements stochastic logistic regression. It can be used for binary classification problem, supports the same custom parameters as stochasticLinearRegression and works the same way.

### Parameters

Parameters are exactly the same as in stochasticLinearRegression:
`learning rate`, `l2 regularization coefficient`, `mini-batch size`, `method for updating weights`.
For more information see parameters.

```
stochasticLogisticRegression(1.0, 1.0, 10, SGD)
```

**1.** Fitting

```
See the `Fitting` section in the [stochasticLinearRegression](#stochasticlinearregression-usage-fitting) description.

Predicted labels have to be in \[-1, 1\].
```

**2.** Predicting

```
Using saved state we can predict probability of object having label `1`.

​``` sql
WITH (SELECT state FROM your_model) AS model SELECT
evalMLMethod(model, param1, param2) FROM test_data
​```

The query will return a column of probabilities. Note that first argument of `evalMLMethod` is `AggregateFunctionState` object, next are columns of features.

We can also set a bound of probability, which assigns elements to different labels.

​``` sql
SELECT ans < 1.1 AND ans > 0.5 FROM
(WITH (SELECT state FROM your_model) AS model SELECT
evalMLMethod(model, param1, param2) AS ans FROM test_data)
​```

Then the result will be labels.

`test_data` is a table like `train_data` but may not contain target value.
```' where id=132;
update biz_data_query_model_help_content set content_en = '# categoricalInformationValue

Calculates the value of `(P(tag = 1) - P(tag = 0))(log(P(tag = 1)) - log(P(tag = 0)))` for each category.

```
categoricalInformationValue(category1, category2, ..., tag)
```

The result indicates how a discrete (categorical) feature `[category1, category2, ...]` contribute to a learning model which predicting the value of `tag`.

' where id=133;
update biz_data_query_model_help_content set content_en = '# studentTTest

Applies Students t-test to samples from two populations.

**Syntax**

```
studentTTest(sample_data, sample_index)
```

Values of both samples are in the `sample_data` column. If `sample_index` equals to 0 then the value in that row belongs to the sample from the first population. Otherwise it belongs to the sample from the second population.
The null hypothesis is that means of populations are equal. Normal distribution with equal variances is assumed.

**Arguments**

- `sample_data` — Sample data. Integer, Float or Decimal.
- `sample_index` — Sample index. Integer.

**Returned values**

Tuple with two elements:

- calculated t-statistic. Float64.
- calculated p-value. Float64.

**Example**

Input table:

```
┌─sample_data─┬─sample_index─┐
│        20.3 │            0 │
│        21.1 │            0 │
│        21.9 │            1 │
│        21.7 │            0 │
│        19.9 │            1 │
│        21.8 │            1 │
└─────────────┴──────────────┘
```

Query:

```
SELECT studentTTest(sample_data, sample_index) FROM student_ttest;
```

Result:

```
┌─studentTTest(sample_data, sample_index)───┐
│ (-0.21739130434783777,0.8385421208415731) │
└───────────────────────────────────────────┘
```' where id=134;
update biz_data_query_model_help_content set content_en = '# welchTTest

Applies Welchs t-test to samples from two populations.

**Syntax**

```
welchTTest(sample_data, sample_index)
```

Values of both samples are in the `sample_data` column. If `sample_index` equals to 0 then the value in that row belongs to the sample from the first population. Otherwise it belongs to the sample from the second population.
The null hypothesis is that means of populations are equal. Normal distribution is assumed. Populations may have unequal variance.

**Arguments**

- `sample_data` — Sample data. Integer, Float or Decimal.
- `sample_index` — Sample index. Integer.

**Returned values**

Tuple with two elements:

- calculated t-statistic. Float64].
- calculated p-value. Float64.

**Example**

Input table:

```
┌─sample_data─┬─sample_index─┐
│        20.3 │            0 │
│        22.1 │            0 │
│        21.9 │            0 │
│        18.9 │            1 │
│        20.3 │            1 │
│          19 │            1 │
└─────────────┴──────────────┘
```

Query:

```
SELECT welchTTest(sample_data, sample_index) FROM welch_ttest;
```

Result:

```
┌─welchTTest(sample_data, sample_index)─────┐
│ (2.7988719532211235,0.051807360348581945) │
└───────────────────────────────────────────┘
```

' where id=135;
update biz_data_query_model_help_content set content_en = '# mannWhitneyUTest

Applies the Mann-Whitney rank test to samples from two populations.

**Syntax**

```
mannWhitneyUTest[(alternative[, continuity_correction])](sample_data, sample_index)
```

Values of both samples are in the `sample_data` column. If `sample_index` equals to 0 then the value in that row belongs to the sample from the first population. Otherwise it belongs to the sample from the second population.
The null hypothesis is that two populations are stochastically equal. Also one-sided hypothesises can be tested. This test does not assume that data have normal distribution.

**Arguments**

- `sample_data` — sample data. Integer], Floator Decimal.
- `sample_index` — sample index. Integer.

**Parameters**

-  alternative hypothesis. (Optional, default: two-sided.)String
   - `two-sided`;
   - `greater`;
   - `less`.
-  `continuity_correction` — if not 0 then continuity correction in the normal approximation for the p-value is applied. (Optional, default: 1.) UInt64.

**Returned values**

Tuple with two elements:

- calculated U-statistic. Float64.
- calculated p-value. xFloat64.

**Example**

Input table:

```
┌─sample_data─┬─sample_index─┐
│          10 │            0 │
│          11 │            0 │
│          12 │            0 │
│           1 │            1 │
│           2 │            1 │
│           3 │            1 │
└─────────────┴──────────────┘
```

Query:

```
SELECT mannWhitneyUTest(greater)(sample_data, sample_index) FROM mww_ttest;
```

Result:

```
┌─mannWhitneyUTest(greater)(sample_data, sample_index)─┐
│ (9,0.04042779918503192)                                │
└────────────────────────────────────────────────────────┘
```



' where id=136;
update biz_data_query_model_help_content set content_en = '# median

The `median*` functions are the aliases for the corresponding `quantile*` functions. They calculate median of a numeric data sample.

Functions:

- `median` — Alias for quantile.
- `medianDeterministic` — Alias for quantileDeterministic.
- `medianExact` — Alias for quantileExact.
- `medianExactWeighted` — Alias for quantileExactWeighted.
- `medianTiming` — Alias for quantileTiming.
- `medianTimingWeighted` — Alias for quantileTimingWeighted.
- `medianTDigest` — Alias for quantileTDigest.
- `medianTDigestWeighted` — Alias for quantileTDigestWeighted.
- `medianBFloat16` — Alias for quantileBFloat16.

**Example**

Input table:

```
┌─val─┐
│   1 │
│   1 │
│   2 │
│   3 │
└─────┘
```

Query:

```
SELECT medianDeterministic(val, 1) FROM t
```

Result:

```
┌─medianDeterministic(val, 1)─┐
│                         1.5 │
└─────────────────────────────┘
```

' where id=137;
update biz_data_query_model_help_content set content_en = '# rankCorr

Computes a rank correlation coefficient.

**Syntax**

```
rankCorr(x, y)
```

**Arguments**

- `x` — Arbitrary value. Float32or Float64.
- `y` — Arbitrary value. Float32 or Float64.

**Returned value(s)**

- Returns a rank correlation coefficient of the ranks of x and y. The value of the correlation coefficient ranges from -1 to +1. If less than two arguments are passed, the function will return an exception. The value close to +1 denotes a high linear relationship, and with an increase of one random variable, the second random variable also increases. The value close to -1 denotes a high linear relationship, and with an increase of one random variable, the second random variable decreases. The value close or equal to 0 denotes no relationship between the two random variables.

Type: Float64.

**Example**

Query:

```
SELECT rankCorr(number, number) FROM numbers(100);
```

Result:

```
┌─rankCorr(number, number)─┐
│                        1 │
└──────────────────────────┘
```

Query:

```
SELECT roundBankers(rankCorr(exp(number), sin(number)), 3) FROM numbers(100);
```

Result:

```
┌─roundBankers(rankCorr(exp(number), sin(number)), 3)─┐
│                                              -0.037 │
└─────────────────────────────────────────────────────┘
```

' where id=138;


