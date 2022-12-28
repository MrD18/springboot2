INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(1, '数据分析默认执行ClickHouse下推(push down)查询，采用ClickHouse的SQL语法；非下推查询采用Presto的SQL语法来进行。
数据平台通过Beetl模板引擎对SQL语法进行了扩展，可以建模时使用变量，并支持表达式、IF、FOR等逻辑控制。
在执行查询时，会先通过Beetl模板引擎对定义的模型渲染处理，根据传入的参数进行占位符的替换，形成一个可执行的SQL，然后根据当前请求的下推设置，执行下推查询或者非下推的Presto查询。
```
// 示例代码
SELECT
  "timestamp",
  "${metric}"
FROM
  stream_kafka.bdp_store_kafka.nbd_console_log
WHERE
  host = ''${host}''
LIMIT
  ${limitNumber}
```
在请求模型数据时，可以传metric、host、limitNumber等自定义参数，具体可在查询设置中配置，使模型的使用更加灵活，具体使用可以在模型列表的"复制"功能详情中看到curl调用的示例。', 0, 1, '2021-05-19 10:26:37', 1, '2021-05-19 10:26:37');

INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(2, 'lickHouse支持JSON、CSV、Pretty等多种格式的结果集。可以通过ClickHouse客户端工具快速、方便的导出大批量数据到指定格式文件。例如：
```
//格式:
clickhouse-client -h [主机地址] -f [结果格式] -q [sql语句] > 目标文件
//示例:
clickhouse-client -h 127.0.0.1 -f CSV -q ''select * from bdp_store_kafka.zxy_test5 limit 10'' > test.csv
```
```
注意：可复制当前SQL编辑器中的sql语句作为-q参数值，但数据平台指定表为catalog.schema.table三级结构，请将复制的SQL中的catalog名字去掉，例如将"stream_kafka"."bdp_store_kafka"."zxy_test5"中的"stream_kafka"去掉。
```', 0, 1, '2021-05-21 10:26:37', 1, '2021-05-21 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(10, '#### ALTER

`ALTER` 仅支持 `*MergeTree` ，`Merge`以及`Distributed`等引擎表。
该操作有多种形式。

#### 列操作

改变表结构：

```
ALTER TABLE [db].name [ON CLUSTER cluster] ADD|DROP|CLEAR|COMMENT|MODIFY COLUMN ...
```

在语句中，配置一个或多个用逗号分隔的动作。每个动作是对某个列实施的操作行为。

支持下列动作：

- ADD COLUMN— 添加列
- DROP COLUMN — 删除列
- CLEAR COLUMN— 重置列的值
- COMMENT COLUMN— 给列增加注释说明
- MODIFY COLUMN— 改变列的值类型，默认表达式以及TTL

这些动作将在下文中进行详述。

#### 增加列

```
ADD COLUMN [IF NOT EXISTS] name [type] [default_expr] [codec] [AFTER name_after]
```

使用指定的`name`, `type`, `codec` 以及 `default_expr` (请参见 Default expressions)，往表中增加新的列。

如果sql中包含 `IF NOT EXISTS` ，执行语句时如果列已经存在，CH不会报错。如果指定`AFTER name_after`（表中另一个列的名称），则新的列会加在指定列的后面。否则，新的列将被添加到表的末尾。注意，不能将新的列添加到表的开始位置， `name_after` 可以是执行该动作时已经在表中存在的任意列。

添加列仅仅是改变原有表的结构不会对已有数据产生影响。执行完 `ALTER`后磁盘中也不会出现新的数据。如果查询表时列的数据为空，那么CH会使用列的默认值来进行填充（如果有默认表达式，则使用这个；或者用0或空字符串）。当数据块完成合并(参见MergeTree)后，磁盘中会出现该列的数据。

这种方式允许 `ALTER` 语句能马上执行。不需要增加原有数据的大小。

示例:

```
ALTER TABLE visits ADD COLUMN browser String AFTER user_id
```

#### 删除列

```
DROP COLUMN [IF EXISTS] name
```

通过指定 `name`删除列。如果语句包含 `IF EXISTS`，执行时遇到不存在的列也不会报错。

从文件系统中删除数据。由于是删除列的整个文件，该语句几乎是立即执行完成的。

示例:

```
ALTER TABLE visits DROP COLUMN browser
```

#### 清空列

```
CLEAR COLUMN [IF EXISTS] name IN PARTITION partition_name
```

重置指定分区中列的值。 分区名称 `partition_name` 请参见 怎样设置分区表达式

如果语句中包含 `IF EXISTS` ，遇到不存在的列，sql执行不会报错。

示例:

```
ALTER TABLE visits CLEAR COLUMN browser IN PARTITION tuple()
```

#### 增加注释

```
COMMENT COLUMN [IF EXISTS] name ''comment''
```

给列增加注释说明。如果语句中包含 `IF EXISTS` ，遇到不存在的列，sql执行不会报错。

每个列都可以包含注释。如果列的注释已经存在，新的注释会替换旧的。
注释信息保存在 DESCRIBE TABLE查询的 `comment_expression` 字段中。

示例:

```
ALTER TABLE visits COMMENT COLUMN browser ''The table shows the browser used for accessing the site.''
```

#### 修改列

```
MODIFY COLUMN [IF EXISTS] name [type] [default_expr] [TTL]
```

该语句可以改变 `name` 列的属性：

- Type
- Default expression
- TTL

有关修改列TTL的示例，请参见 Column TTL.

如果语句中包含 `IF EXISTS` ，遇到不存在的列，sql执行不会报错。

当改变列的类型时，列的值也被转换了，如同对列使用 toType函数一样。如果只改变了默认表达式，该语句几乎不会做任何复杂操作，并且几乎是立即执行完成的。

示例:

```
ALTER TABLE visits MODIFY COLUMN browser Array(String)
```

改变列的类型是唯一的复杂型动作 - 它改变了数据文件的内容。对于大型表，执行起来要花费较长的时间。
该操作分为如下处理步骤：

- 为修改的数据准备新的临时文件
- 重命名原来的文件
- 将新的临时文件改名为原来的数据文件名
- 删除原来的文件

仅仅在第一步是耗费时间的。如果该阶段执行失败，那么数据没有变化。如果执行后续的步骤中失败了，数据可以手动恢复。例外的情形是，当原来的文件从文件系统中被删除了，但是新的数据没有写入到临时文件中并且丢失了。

列操作的 `ALTER`行为是可以被复制的。这些指令会保存在ZooKeeper中，这样每个副本节点都能执行它们。所有的 `ALTER` 将按相同的顺序执行。
The query waits for the appropriate actions to be completed on the other replicas.
然而，改变可复制表的列是可以被中断的，并且所有动作都以异步方式执行。

#### ALTER 操作限制

`ALTER` 操作允许在嵌套的数据结构中创建和删除单独的元素（列），但是不是整个嵌套结构。添加一个嵌套数据结构的列时，你可以用类似这样的名称 `name.nested_name` 及类型 `Array(T)` 来操作。嵌套数据结构等同于
列名前带有同样前缀的多个数组列。

不支持对primary key或者sampling key中的列（在 `ENGINE` 表达式中用到的列）进行删除操作。改变包含在primary key中的列的类型时，如果操作不会导致数据的变化（例如，往Enum中添加一个值，或者将`DateTime` 类型改成 `UInt32`），那么这种操作是可行的。

如果 `ALTER` 操作不足以完成你想要的表变动操作，你可以创建一张新的表，通过 INSERT SELECT将数据拷贝进去，然后通过 [ENAME将新的表改成和原有表一样的名称，并删除原有的表。你可以使用 clickhouse-copier 代替 `INSERT SELECT`。

`ALTER` 操作会阻塞对表的所有读写操作。换句话说，当一个大的 `SELECT` 语句和 `ALTER`同时执行时，`ALTER`会等待，直到 `SELECT` 执行结束。与此同时，当 `ALTER` 运行时，新的 sql 语句将会等待。

对于不存储数据的表（例如 `Merge` 及 `Distributed` 表）， `ALTER` 仅仅改变了自身的表结构，不会改变从属的表结构。例如，对 `Distributed` 表执行 ALTER 操作时，需要对其它包含该表的服务器执行该操作。

#### key表达式的修改

支持下列表达式：

```
MODIFY ORDER BY new_expression
```

该操作仅支持 `MergeTree` 系列表 (含 replicated 表)。它会将表的排序键变成 `new_expression` (元组表达式)。主键仍保持不变。

该操作是轻量级的，仅会改变元数据。

#### 跳过索引来更改数据
该操作仅支持`MergeTree` 系列表 (含replicated表)。
下列操作是允许的：

- `ALTER TABLE [db].name ADD INDEX name expression TYPE type GRANULARITY value AFTER name [AFTER name2]` - 在表的元数据中增加索引说明
- `ALTER TABLE [db].name DROP INDEX name` - 从表的元数据中删除索引描述，并从磁盘上删除索引文件

由于只改变表的元数据或者删除文件，因此该操作是轻量级的，也可以被复制到其它节点（通过Zookeeper同步索引元数据）

#### 更改约束

参见constraints查看更多信息。

通过下面的语法，可以添加或删除约束：

```
ALTER TABLE [db].name ADD CONSTRAINT constraint_name CHECK expression;
ALTER TABLE [db].name DROP CONSTRAINT constraint_name;
```

上述语句会从表中增加或删除约束的元数据，因此会被立即处理。
对已有数据的约束检查 *将不会执行* 。

对可复制表的操作可通过Zookeeper传播到其它副本节点。

#### 更改分区及文件块

允许进行下列关于partitions的操作：

- DETACH PARTITION— 将分区数据移动到 `detached` ，并且忘记它
- DROP PARTITION — 删除一个partition.
- ATTACH PART|PARTITION— 将`detached` 目录中的分区重新添加到表中.
- ATTACH PARTITION FROM— 从表中复制数据分区到另一张表，并添加分区
- REPLACE PARTITION— 从表中复制数据分区到其它表及副本
- MOVE PARTITION TO TABLE— 从表中复制数据分区到其它表.
- CLEAR COLUMN IN PARTITION— 重置分区中某个列的值
- CLEAR INDEX IN PARTITION— 重置分区中指定的二级索引
- FREEZE PARTITION— 创建分区的备份
- FETCH PARTITION— 从其它服务器上下载分
- MOVE PARTITION|PART— 将分区/数据块移动到另外的磁盘/卷

#### 分区剥离

```
ALTER TABLE table_name DETACH PARTITION partition_expr
```

将指定分区的数据移动到 `detached` 目录。服务器会忽略被分离的数据分区。只有当你使用ATTACH时，服务器才会知晓这部分数据。

示例:

```
ALTER TABLE visits DETACH PARTITION 201901
```

从如何设置分区表达式章节中获取分区表达式的设置说明。

当执行操作以后，可以对 `detached` 目录的数据进行任意操作，例如删除文件，或者放着不管。

该操作是可以复制的，它会将所有副本节点上的数据移动到 `detached` 目录。注意仅能在副本的leader节点上执行该操作。想了解副本是否是leader节点，需要在system.replicas表执行 `SELECT` 操作。或者，可以很方便的在所有副本节点上执行 `DETACH`操作，但除leader外其它的副本节点会抛出异常。

#### 删除分区

```
ALTER TABLE table_name DROP PARTITION partition_expr
```

从表中删除指定分区。该操作会将分区标记为不活跃的，然后在大约10分钟内删除全部数据。

在如何设置分区表达式中获取分区表达式的设置说明。
该操作是可复制的，副本节点的数据也将被删除。

#### 删除已剥离的分区|数据块

```
ALTER TABLE table_name DROP DETACHED PARTITION|PART partition_expr
```

从`detached`目录中删除指定分区的特定部分或所有数据。访问如何设置分区表达式可获取设置分区表达式的详细信息。

#### 关联分区|数据块

```
ALTER TABLE table_name ATTACH PARTITION|PART partition_expr
```

从`detached`目录中添加数据到数据表。可以添加整个分区的数据，或者单独的数据块。例如：

```
ALTER TABLE visits ATTACH PARTITION 201901;
ALTER TABLE visits ATTACH PART 201901_2_2_0;
```

访问如何设置分区表达式可获取设置分区表达式的详细信息。

该操作是可以复制的。副本启动器检查 `detached`目录是否有数据。如果有，该操作会检查数据的完整性。如果一切正常，该操作将数据添加到表中。其它副本节点通过副本启动器下载这些数据。

因此可以在某个副本上将数据放到 `detached`目录，然后通过 `ALTER ... ATTACH` 操作将这部分数据添加到该表的所有副本。

#### 从...关联分区

```
ALTER TABLE table2 ATTACH PARTITION partition_expr FROM table1
```

该操作将 `table1` 表的数据分区复制到 `table2` 表的已有分区。注意`table1`表的数据不会被删除。

为保证该操作能成功运行，下列条件必须满足：

- 2张表必须有相同的结构
- 2张表必须有相同的分区键

#### 替换分区

```
ALTER TABLE table2 REPLACE PARTITION partition_expr FROM table1
```

该操作将 `table1` 表的数据分区复制到 `table2`表，并替换 `table2`表的已有分区。注意`table1`表的数据不会被删除。

为保证该操作能成功运行，下列条件必须满足：

- 2张表必须有相同的结构
- 2张表必须有相同的分区键

#### 将分区移动到表

```
ALTER TABLE table_source MOVE PARTITION partition_expr TO TABLE table_dest
```

该操作将 `table_source`表的数据分区移动到 `table_dest`表，并删除`table_source`表的数据。

为保证该操作能成功运行，下列条件必须满足：

- 2张表必须有相同的结构
- 2张表必须有相同的分区键
- 2张表必须属于相同的引擎系列（可复制表或不可复制表）
- 2张表必须有相同的存储方式

#### 清空分区的列

```
ALTER TABLE table_name CLEAR COLUMN column_name IN PARTITION partition_expr
```

重置指定分区的特定列的值。如果建表时使用了 `DEFAULT` 语句，该操作会将列的值重置为该默认值。

示例:

```
ALTER TABLE visits CLEAR COLUMN hour in PARTITION 201902
```

#### 冻结分区

```
ALTER TABLE table_name FREEZE [PARTITION partition_expr]
```

该操作为指定分区创建一个本地备份。如果 `PARTITION` 语句省略，该操作会一次性为所有分区创建备份。

Note

整个备份过程不需要停止服务

注意对于老式的表，可以指定分区名前缀（例如，‘2019’），然后该操作会创建所有对应分区的备份。访问如何设置分区表达式可获取设置分区表达式的详细信息。

在执行操作的同时，对于数据快照，该操作会创建到表数据的硬链接。硬链接放置在 `/var/lib/clickhouse/shadow/N/...`，也就是：
\- `/var/lib/clickhouse/` 服务器配置文件中指定的CH工作目录
\- `N` 备份的增长序号

Note

如果你使用多个磁盘存储数据表，
那么每个磁盘上都有 `shadow/N`目录，用来保存`PARTITION` 表达式对应的数据块。

备份内部也会创建和 `/var/lib/clickhouse/` 内部一样的目录结构。该操作在所有文件上执行‘chmod’，禁止往里写入数据

当备份创建完毕，你可以从 `/var/lib/clickhouse/shadow/`复制数据到远端服务器，然后删除本地数据。注意 `ALTER t FREEZE PARTITION`操作是不能复制的，它仅在本地服务器上创建本地备份。

该操作创建备份几乎是即时的（但是首先它会等待相关表的当前操作执行完成）

```
ALTER TABLE t FREEZE PARTITION` 仅仅复制数据, 而不是元数据信息. 要复制表的元数据信息, 拷贝这个文件 `/var/lib/clickhouse/metadata/database/table.sql
```

从备份中恢复数据，按如下步骤操作：
\1. 如果表不存在，先创建。 查看.sql 文件获取执行语句 (将`ATTACH` 替换成 `CREATE`).
\2. 从 备份的 `data/database/table/`目录中将数据复制到 `/var/lib/clickhouse/data/database/table/detached/`目录
\3. 运行 `ALTER TABLE t ATTACH PARTITION`操作，将数据添加到表中

恢复数据不需要停止服务进程。
想了解备份及数据恢复的更多信息，请参见数据备份 。

#### 删除分区的索引

```
ALTER TABLE table_name CLEAR INDEX index_name IN PARTITION partition_expr
```

该操作和 `CLEAR COLUMN`类似，但是它重置的是索引而不是列的数据。

#### 获取分区

```
ALTER TABLE table_name FETCH PARTITION partition_expr FROM ''path-in-zookeeper''
```

从另一服务器上下载分区数据。仅支持可复制引擎表。
该操作做了如下步骤：
\1. 从指定数据分片上下载分区。在 path-in-zookeeper 这一参数你必须设置Zookeeper中该分片的path值。
\2. 然后将已下载的数据放到 `table_name` 表的 `detached` 目录下。通过ATTACH PARTITION|PART将数据加载到表中。

示例:

```
ALTER TABLE users FETCH PARTITION 201902 FROM ''/clickhouse/tables/01-01/visits'';
ALTER TABLE users ATTACH PARTITION 201902;
```

注意:

- `ALTER ... FETCH PARTITION` 操作不支持复制，它仅在本地服务器上将分区移动到 `detached`目录。
- `ALTER TABLE ... ATTACH`操作是可复制的。它将数据添加到所有副本。数据从某个副本的`detached` 目录中添加进来，然后添加到邻近的副本

在开始下载之前，系统检查分区是否存在以及和表结构是否匹配。然后从健康的副本集中自动选择最合适的副本。

虽然操作叫做 `ALTER TABLE`，但是它并不能改变表结构，也不会立即改变表中可用的数据。

#### 移动分区|数据块

将 `MergeTree`引擎表的分区或数据块移动到另外的卷/磁盘中。参见使用多个块设备存储数据

```
ALTER TABLE table_name MOVE PARTITION|PART partition_expr TO DISK|VOLUME ''disk_name''
```

`ALTER TABLE t MOVE` 操作:

- 不支持复制，因为不同副本可以有不同的存储方式
- 如果指定的磁盘或卷没有配置，返回错误。如果存储方式中设定的数据移动条件不能满足，该操作同样报错。
- 这种情况也会报错：即将移动的数据已经由后台进程在进行移动操作时，并行的 `ALTER TABLE t MOVE`操作或者作为后台数据合并的结果。这种情形下用户不能任何额外的动作。

示例:

```
ALTER TABLE hits MOVE PART ''20190301_14343_16206_438'' TO VOLUME ''slow''
ALTER TABLE hits MOVE PARTITION ''2019-09-01'' TO DISK ''fast_ssd''
```

#### 如何设置分区表达式

通过不同方式在 `ALTER ... PARTITION` 操作中设置分区表达式：

- `system.parts`表 `partition`列的某个值，例如， `ALTER TABLE visits DETACH PARTITION 201901`
- 表的列表达式。支持常量及常量表达式。例如， `ALTER TABLE visits DETACH PARTITION toYYYYMM(toDate(''2019-01-25''))`
- 使用分区ID。分区ID是字符串变量（可能的话有较好的可读性），在文件系统和ZooKeeper中作为分区名称。分区ID必须配置在 `PARTITION ID`中，用单引号包含，例如， `ALTER TABLE visits DETACH PARTITION ID ''201901''`
- 在ALTER ATTACH PART和DROP DETACHED PART操作中，要配置块的名称，使用system.detached_parts表中 `name`列的字符串值，例如： `ALTER TABLE visits ATTACH PART ''201901_1_1_0''`

设置分区时，引号使用要看分区表达式的类型。例如，对于 `String`类型，需要设置用引号(`''`)包含的名称。对于 `Date` 和 `Int*`引号就不需要了。
对于老式的表，可以用数值`201901` 或字符串 `''201901''`来设置分区。新式的表语法严格和类型一致（类似于VALUES输入的解析）

上述所有规则同样适用于OPTIMIZE操作。在对未分区的表进行 OPTIMIZE 操作时，如果需要指定唯一的分区，这样设置表达式`PARTITION tuple()`。例如：

```
OPTIMIZE TABLE table_not_partitioned PARTITION tuple() FINAL;
```

`ALTER ... PARTITION` 操作的示例在`00502_custom_partitioning_local` 和 `00502_custom_partitioning_replicated_zookeeper`提供了演示。

#### 更改表的TTL

通过以下形式的请求可以修改table TTL

```
ALTER TABLE table-name MODIFY TTL ttl-expression
```

#### ALTER操作的同步性

对于不可复制的表，所有 `ALTER`操作都是同步执行的。对于可复制的表，ALTER操作会将指令添加到ZooKeeper中，然后会尽快的执行它们。然而，该操作可以等待其它所有副本将指令执行完毕。

对于 `ALTER ... ATTACH|DETACH|DROP`操作，可以通过设置 `replication_alter_partitions_sync` 来启用等待。可用参数值： `0` – 不需要等待; `1` – 仅等待自己执行(默认); `2` – 等待所有节点

#### Mutations

Mutations是一类允许对表的行记录进行删除或更新的ALTER操作。相较于标准的 `UPDATE` 和 `DELETE` 用于少量行操作而言，Mutations用来对表的很多行进行重量级的操作。该操作支持 `MergeTree`系列表，包含支持复制功能的表。

已有的表已经支持mutations操作（不需要转换）。但是在首次对表进行mutation操作以后，它的元数据格式变得和和之前的版本不兼容，并且不能回退到之前版本。

目前可用的命令:

```
ALTER TABLE [db.]table DELETE WHERE filter_expr
```

`filter_expr`必须是 `UInt8`型。该操作将删除表中 `filter_expr`表达式值为非0的列

```
ALTER TABLE [db.]table UPDATE column1 = expr1 [, ...] WHERE filter_expr
```

`filter_expr`必须是 `UInt8`型。该操作将更新表中各行 `filter_expr`表达式值为非0的指定列的值。通过 `CAST` 操作将值转换成对应列的类型。不支持对用于主键或分区键表达式的列进行更新操作。

```
ALTER TABLE [db.]table MATERIALIZE INDEX name IN PARTITION partition_name
```

该操作更新 `partition_name`分区中的二级索引 `name`.
单次操作可以包含多个逗号分隔的命令。

对于 *MergeTree引擎表，mutation操作通过重写整个数据块来实现。没有原子性保证 - 被mutation操作的数据会被替换，在mutation期间开始执行的`SELECT`查询能看到所有已经完成mutation的数据，以及还没有被mutation替换的数据。

mutation总是按照它们的创建顺序来排序并以同样顺序在每个数据块中执行。mutation操作也会部分的和Insert操作一起排序 - 在mutation提交之前插入的数据会参与mutation操作，在mutation提交之后的插入的数据则不会参与mutation。注意mutation从来不会阻塞插入操作。

mutation操作在提交后（对于可复制表，添加到Zookeeper,对于不可复制表，添加到文件系统）立即返回。mutation操作本身是根据系统的配置参数异步执行的。要跟踪mutation的进度，可以使用系统表 `system.mutations`。已经成功提交的mutation操作在服务重启后仍会继续执行。一旦mutation完成提交，就不能回退了，但是如果因为某种原因操作被卡住了，可以通过`KILL MUTATION`操作来取消它的执行。

已完成的mutations记录不会立即删除（要保留的记录数量由 `finished_mutations_to_keep` 这一参数决定）。之前的mutation记录会被删除。

#### 修改用户

修改CH的用户账号

#### 语法

```
ALTER USER [IF EXISTS] name [ON CLUSTER cluster_name]
    [RENAME TO new_name]
    [IDENTIFIED [WITH {PLAINTEXT_PASSWORD|SHA256_PASSWORD|DOUBLE_SHA1_PASSWORD}] BY {''password''|''hash''}]
    [[ADD|DROP] HOST {LOCAL | NAME ''name'' | REGEXP ''name_regexp'' | IP ''address'' | LIKE ''pattern''} [,...] | ANY | NONE]
    [DEFAULT ROLE role [,...] | ALL | ALL EXCEPT role [,...] ]
    [SETTINGS variable [= value] [MIN [=] min_value] [MAX [=] max_value] [READONLY|WRITABLE] | PROFILE ''profile_name''] [,...]
```

#### 说明

要使用 `ALTER USER`，你必须拥有ALTER USER 操作的权限

#### Examples

设置默认角色：

```
ALTER USER user DEFAULT ROLE role1, role2
```

如果角色之前没分配给用户，CH会抛出异常。

将所有分配的角色设为默认

```
ALTER USER user DEFAULT ROLE ALL
```

如果以后给用户分配了某个角色，它将自动成为默认角色

将除了 `role1` 和 `role2`之外的其它角色 设为默认

```
ALTER USER user DEFAULT ROLE ALL EXCEPT role1, role2
```

#### 修改角色

修改角色.

#### 语法
```
ALTER ROLE [IF EXISTS] name [ON CLUSTER cluster_name]
    [RENAME TO new_name]
    [SETTINGS variable [= value] [MIN [=] min_value] [MAX [=] max_value] [READONLY|WRITABLE] | PROFILE ''profile_name''] [,...]
```

#### 修改row policy

修改row policy.

#### 语法

```
ALTER [ROW] POLICY [IF EXISTS] name [ON CLUSTER cluster_name] ON [database.]table
    [RENAME TO new_name]
    [AS {PERMISSIVE | RESTRICTIVE}]
    [FOR SELECT]
    [USING {condition | NONE}][,...]
    [TO {role [,...] | ALL | ALL EXCEPT role [,...]}]
```

#### 修改配额quotas

修改配额quotas.

#### 语法

```
ALTER QUOTA [IF EXISTS] name [ON CLUSTER cluster_name]
    [RENAME TO new_name]
    [KEYED BY {''none'' | ''user name'' | ''ip address'' | ''client key'' | ''client key or user name'' | ''client key or ip address''}]
    [FOR [RANDOMIZED] INTERVAL number {SECOND | MINUTE | HOUR | DAY | WEEK | MONTH | QUARTER | YEAR}
        {MAX { {QUERIES | ERRORS | RESULT ROWS | RESULT BYTES | READ ROWS | READ BYTES | EXECUTION TIME} = number } [,...] |
        NO LIMITS | TRACKING ONLY} [,...]]
    [TO {role [,...] | ALL | ALL EXCEPT role [,...]}]
```

#### 修改settings配置

修改settings配置.

#### 语法

```
ALTER SETTINGS PROFILE [IF EXISTS] name [ON CLUSTER cluster_name]
    [RENAME TO new_name]
    [SETTINGS variable [= value] [MIN [=] min_value] [MAX [=] max_value] [READONLY|WRITABLE] | INHERIT ''profile_name''] [,...]
```', 0, 1, '2021-05-22 10:26:37', 1, '2021-05-22 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(11, '#### SYSTEM Queries

- RELOAD EMBEDDED DICTIONARIES
- RELOAD DICTIONARIES
- RELOAD DICTIONARY
- DROP DNS CACHE
- DROP MARK CACHE
- DROP UNCOMPRESSED CACHE
- DROP COMPILED EXPRESSION CACHE
- DROP REPLICA
- FLUSH LOGS
- RELOAD CONFIG
- SHUTDOWN
- KILL
- STOP DISTRIBUTED SENDS
- FLUSH DISTRIBUTED
- START DISTRIBUTED SENDS
- STOP MERGES
- START MERGES
- STOP TTL MERGES
- START TTL MERGES
- STOP MOVES
- START MOVES
- STOP FETCHES
- START FETCHES
- STOP REPLICATED SENDS
- START REPLICATED SENDS
- STOP REPLICATION QUEUES
- START REPLICATION QUEUES
- SYNC REPLICA
- RESTART REPLICA
- RESTART REPLICAS

#### RELOAD EMBEDDED DICTIONARIES]

重新加载所有内置字典。默认情况下内置字典是禁用的。
总是返回 ‘OK.’，不管这些内置字典的更新结果如何。

#### RELOAD DICTIONARIES

重载已经被成功加载过的所有字典。
默认情况下，字典是延时加载的（ dictionaries_lazy_load），不是在服务启动时自动加载，而是在第一次使用dictGet函数或通过 `SELECT from tables with ENGINE = Dictionary` 进行访问时被初始化。这个命令 `SYSTEM RELOAD DICTIONARIES` 就是针对这类表进行重新加载的。

#### RELOAD DICTIONARY Dictionary_name

完全重新加载指定字典 `dictionary_name`，不管该字典的状态如何(LOADED / NOT_LOADED / FAILED)。不管字典的更新结果如何，总是返回 `OK.`
字典的状态可以通过查询 `system.dictionaries`表来检查。

```
SELECT name, status FROM system.dictionaries;
```

#### DROP DNS CACHE

重置CH的dns缓存。有时候（对于旧的ClickHouse版本）当某些底层环境发生变化时（修改其它Clickhouse服务器的ip或字典所在服务器的ip），需要使用该命令。
更多自动化的缓存管理相关信息，参见disable_internal_dns_cache, dns_cache_update_period这些参数。

#### DROP MARK CACHE

重置mark缓存。在进行ClickHouse开发或性能测试时使用。

#### DROP REPLICA

使用下面的语句可以删除已经无效的副本。

```
SYSTEM DROP REPLICA ''replica_name'' FROM TABLE database.table;
SYSTEM DROP REPLICA ''replica_name'' FROM DATABASE database;
SYSTEM DROP REPLICA ''replica_name'';
SYSTEM DROP REPLICA ''replica_name'' FROM ZKPATH ''/path/to/table/in/zk'';
```

该操作将副本的路径从Zookeeper中删除。当副本失效，并且由于该副本已经不存在导致它的元数据不能通过 `DROP TABLE`从zookeeper中删除，这种情形下可以使用该命令。它只会删除失效或过期的副本，不会删除本地的副本。请使用 `DROP TABLE` 来删除本地副本。 `DROP REPLICA` 不会删除任何表，并且不会删除磁盘上的任何数据或元数据信息。

第1条语句：删除 `database.table`表的 `replica_name`副本的元数据
第2条语句：删除 `database` 数据库的 所有`replica_name`副本的元数据
第3条语句：删除本地服务器所有 `replica_name`副本的元数据
第4条语句：用于在表的其它所有副本都删除时，删除已失效副本的元数据。使用时需要明确指定表的路径。该路径必须和创建表时 `ReplicatedMergeTree`引擎的第一个参数一致。

#### DROP UNCOMPRESSED CACHE

重置未压缩数据的缓存。用于ClickHouse开发和性能测试。
管理未压缩数据缓存的参数，使用以下的服务器级别设置 uncompressed_cache_size以及 `query/user/profile`级别设置 use_uncompressed_cache

#### DROP COMPILED EXPRESSION CACHE

重置已编译的表达式缓存。用于ClickHouse开发和性能测试。
当 `query/user/profile` 启用配置项 compile时，编译的表达式缓存开启。

#### FLUSH LOGS

将日志信息缓冲数据刷入系统表（例如system.query_log）。调试时允许等待不超过7.5秒。当信息队列为空时，会创建系统表。

#### RELOAD CONFIG

重新加载ClickHouse的配置。用于当配置信息存放在ZooKeeper时。

#### SHUTDOWN

关闭ClickHouse服务（类似于 `service clickhouse-server stop` / `kill {$pid_clickhouse-server}`）

#### KILL

关闭ClickHouse进程 （ `kill -9 {$ pid_clickhouse-server}`）

#### Managing Distributed Tables

ClickHouse可以管理 distribute表。当用户向这类表插入数据时，ClickHouse首先为需要发送到集群节点的数据创建一个队列，然后异步的发送它们。你可以维护队列的处理过程，通过STOP DISTRIBUTED SENDS, FLUSH DISTRIBUTED, 以及 START DISTRIBUTED SENDS。你也可以设置 `insert_distributed_sync`参数来以同步的方式插入分布式数据。

#### STOP DISTRIBUTED SENDS

当向分布式表插入数据时，禁用后台的分布式数据分发。

```
SYSTEM STOP DISTRIBUTED SENDS [db.]<distributed_table_name>
```

#### FLUSH DISTRIBUTED

强制让ClickHouse同步向集群节点同步发送数据。如果有节点失效，ClickHouse抛出异常并停止插入操作。当所有节点都恢复上线时，你可以重试之前的操作直到成功执行。

```
SYSTEM FLUSH DISTRIBUTED [db.]<distributed_table_name>
```

#### START DISTRIBUTED SENDS

当向分布式表插入数据时，允许后台的分布式数据分发。

```
SYSTEM START DISTRIBUTED SENDS [db.]<distributed_table_name>
```

#### Managing MergeTree Tables

ClickHouse可以管理 MergeTree表的后台处理进程。

#### STOP MERGES

为MergeTree系列引擎表停止后台合并操作。

```
SYSTEM STOP MERGES [[db.]merge_tree_family_table_name]
```

Note

`DETACH / ATTACH` 表操作会在后台进行表的merge操作，甚至当所有MergeTree表的合并操作已经停止的情况下。

#### START MERGES

为MergeTree系列引擎表启动后台合并操作。

```
SYSTEM START MERGES [[db.]merge_tree_family_table_name]
```

#### STOP TTL MERGES

根据 TTL expression，为MergeTree系列引擎表停止后台删除旧数据。
不管表存在与否，都返回 `OK.`。当数据库不存在时返回错误。

```
SYSTEM STOP TTL MERGES [[db.]merge_tree_family_table_name]
```

#### START TTL MERGES

根据 TTL expression，为MergeTree系列引擎表启动后台删除旧数据。不管表存在与否，都返回 `OK.`。当数据库不存在时返回错误。

```
SYSTEM START TTL MERGES [[db.]merge_tree_family_table_name]
```

#### STOP MOVES

根据 TTL expression，为MergeTree系列引擎表停止后台移动数据。不管表存在与否，都返回 `OK.`。当数据库不存在时返回错误。

```
SYSTEM STOP MOVES [[db.]merge_tree_family_table_name]
```

#### START MOVES

根据 TTL expression，为MergeTree系列引擎表启动后台移动数据。不管表存在与否，都返回 `OK.`。当数据库不存在时返回错误。

```
SYSTEM STOP MOVES [[db.]merge_tree_family_table_name]
```

#### Managing ReplicatedMergeTree Tables

管理 ReplicatedMergeTree表的后台复制相关进程。

#### STOP FETCHES

停止后台获取 `ReplicatedMergeTree`系列引擎表中插入的数据块。
不管表引擎类型如何或表/数据库是否存，都返回 `OK.`。

```
SYSTEM STOP FETCHES [[db.]replicated_merge_tree_family_table_name]
```

#### START FETCHES

启动后台获取 `ReplicatedMergeTree`系列引擎表中插入的数据块。
不管表引擎类型如何或表/数据库是否存，都返回 `OK.`。

```
SYSTEM START FETCHES [[db.]replicated_merge_tree_family_table_name]
```

#### STOP REPLICATED SENDS

停止通过后台分发 `ReplicatedMergeTree`系列引擎表中新插入的数据块到集群的其它副本节点。

```
SYSTEM STOP REPLICATED SENDS [[db.]replicated_merge_tree_family_table_name]
```

#### START REPLICATED SENDS

启动通过后台分发 `ReplicatedMergeTree`系列引擎表中新插入的数据块到集群的其它副本节点。

```
SYSTEM START REPLICATED SENDS [[db.]replicated_merge_tree_family_table_name]
```

#### STOP REPLICATION QUEUES

停止从Zookeeper中获取 `ReplicatedMergeTree`系列表的复制队列的后台任务。可能的后台任务类型包含：merges, fetches, mutation，带有 `ON CLUSTER`的ddl语句

```
SYSTEM STOP REPLICATION QUEUES [[db.]replicated_merge_tree_family_table_name]
```

#### START REPLICATION QUEUES

启动从Zookeeper中获取 `ReplicatedMergeTree`系列表的复制队列的后台任务。可能的后台任务类型包含：merges, fetches, mutation，带有 `ON CLUSTER`的ddl语句

```
SYSTEM START REPLICATION QUEUES [[db.]replicated_merge_tree_family_table_name]
```

#### SYNC REPLICA

直到 `ReplicatedMergeTree`表将要和集群的其它副本进行同步之前会一直运行。如果当前对表的获取操作禁用的话，在达到 `receive_timeout`之前会一直运行。

```
SYSTEM SYNC REPLICA [db.]replicated_merge_tree_family_table_name
```

#### RESTART REPLICA

重置 `ReplicatedMergeTree`表的Zookeeper会话状态。该操作会以Zookeeper为参照，对比当前状态，有需要的情况下将任务添加到ZooKeeper队列。
基于ZooKeeper的日期初始化复制队列，类似于 `ATTACH TABLE`语句。短时间内不能对表进行任何操作。

```
SYSTEM RESTART REPLICA [db.]replicated_merge_tree_family_table_name
```

#### RESTART REPLICAS

重置所有 `ReplicatedMergeTree`表的ZooKeeper会话状态。该操作会以Zookeeper为参照，对比当前状态，有需要的情况下将任务添加到ZooKeeper队列。
', 0, 1, '2021-05-23 10:26:37', 1, '2021-05-23 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(12, '#### SHOW 查询

#### SHOW CREATE TABLE

```
SHOW CREATE [TEMPORARY] [TABLE|DICTIONARY] [db.]table [INTO OUTFILE filename] [FORMAT format]
```

返回单个字符串类型的 ‘statement’列，其中只包含了一个值 - 用来创建指定对象的 `CREATE` 语句。

#### SHOW DATABASES

```
SHOW DATABASES [INTO OUTFILE filename] [FORMAT format]
```

打印所有的数据库列表，该查询等同于 `SELECT name FROM system.databases [INTO OUTFILE filename] [FORMAT format]`

#### SHOW PROCESSLIST

```
SHOW PROCESSLIST [INTO OUTFILE filename] [FORMAT format]
```

输出 system.processes表的内容，包含有当前正在处理的请求列表，除了 `SHOW PROCESSLIST`查询。

`SELECT * FROM system.processes` 查询返回和当前请求相关的所有数据

提示 (在控制台执行):

```
$ watch -n1 "clickhouse-client --query=''SHOW PROCESSLIST''"
```

#### SHOW TABLES

显示表的清单

```
SHOW [TEMPORARY] TABLES [{FROM | IN} <db>] [LIKE ''<pattern>'' | WHERE expr] [LIMIT <N>] [INTO OUTFILE <filename>] [FORMAT <format>]
```

如果未使用 `FROM` 字句，该查询返回当前数据库的所有表清单

可以用下面的方式获得和 `SHOW TABLES`一样的结果：

```
SELECT name FROM system.tables WHERE database = <db> [AND name LIKE <pattern>] [LIMIT <N>] [INTO OUTFILE <filename>] [FORMAT <format>]
```

**示例**

下列查询获取最前面的2个位于`system`库中且表名包含 `co`的表。

```
SHOW TABLES FROM system LIKE ''%co%'' LIMIT 2
┌─name───────────────────────────┐
│ aggregate_function_combinators │
│ collations                     │
└────────────────────────────────┘
```

#### SHOW DICTIONARIES

以列表形式显示外部字典.

```
SHOW DICTIONARIES [FROM <db>] [LIKE ''<pattern>''] [LIMIT <N>] [INTO OUTFILE <filename>] [FORMAT <format>]
```

如果 `FROM`字句没有指定，返回当前数据库的字典列表

可以通过下面的查询获取和 `SHOW DICTIONARIES`相同的结果：

```
SELECT name FROM system.dictionaries WHERE database = <db> [AND name LIKE <pattern>] [LIMIT <N>] [INTO OUTFILE <filename>] [FORMAT <format>]
```

**示例**

下列查询获取最前面的2个位于 `system`库中且名称包含 `reg`的字典表。

```
SHOW DICTIONARIES FROM db LIKE ''%reg%'' LIMIT 2
┌─name─────────┐
│ regions      │
│ region_names │
└──────────────┘
```

#### SHOW GRANTS

显示用户的权限

#### 语法

```
SHOW GRANTS [FOR user]
```

如果未指定用户，输出当前用户的权限

#### SHOW CREATE USER

显示 user creation用到的参数。

`SHOW CREATE USER` 不会输出用户的密码信息

#### 语法

```
SHOW CREATE USER [name | CURRENT_USER]
```

#### SHOW CREATE ROLE

显示 role creation 中用到的参数。

#### 语法

```
SHOW CREATE ROLE name
```

#### SHOW CREATE ROW POLICY

显示 row policy creation中用到的参数

#### 语法

```
SHOW CREATE [ROW] POLICY name ON [database.]table
```

#### SHOW CREATE QUOTA

显示 quota creation中用到的参数

#### 语法

```
SHOW CREATE QUOTA [name | CURRENT]
```

#### SHOW CREATE SETTINGS PROFILE

显示 settings profile creation中用到的参数

#### 语法

```
SHOW CREATE [SETTINGS] PROFILE name
```
', 0, 1, '2021-05-24 10:26:37', 1, '2021-05-24 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(13, '#### 授权

- 给ClickHouse的用户或角色赋予 权限
- 将角色分配给用户或其他角色

取消权限，使用 REVOKE语句。查看已授权的权限请使用 SHOW GRANTS。

#### 授权操作语法

```
GRANT [ON CLUSTER cluster_name] privilege[(column_name [,...])] [,...] ON {db.table|db.*|*.*|table|*} TO {user | role | CURRENT_USER} [,...] [WITH GRANT OPTION]
```

- `privilege` — 权限类型
- `role` — 用户角色
- `user` — 用户账号

`WITH GRANT OPTION` 授予 `user` 或 `role`执行 `GRANT` 操作的权限。用户可将在自身权限范围内的权限进行授权

#### 角色分配的语法

```
GRANT [ON CLUSTER cluster_name] role [,...] TO {user | another_role | CURRENT_USER} [,...] [WITH ADMIN OPTION]
```

- `role` — 角色
- `user` — 用户

`WITH ADMIN OPTION` 授予 `user` 或 `role` 执行ADMIN OPTION 的权限

#### 用法

使用 `GRANT`，你的账号必须有 `GRANT OPTION`的权限。用户只能将在自身权限范围内的权限进行授权

例如，管理员有权通过下面的语句给 `john`账号添加授权

```
GRANT SELECT(x,y) ON db.table TO john WITH GRANT OPTION
```

这意味着 `john` 有权限执行以下操作：

- `SELECT x,y FROM db.table`.
- `SELECT x FROM db.table`.
- `SELECT y FROM db.table`.

`john` 不能执行`SELECT z FROM db.table`。同样的 `SELECT * FROMdb.table` 也是不允许的。执行这个查询时，CH不会返回任何数据，甚至 `x` 和 `y`列。唯一的例外是，当表仅包含 `x`和`y`列时。这种情况下，CH返回所有数据。

同样 `john` 有权执行 `GRANT OPTION`，因此他能给其它账号进行和自己账号权限范围相同的授权。

可以使用`*` 号代替表或库名进行授权操作。例如， `GRANT SELECT ONdb.* TO john` 操作运行 `john`对 `db`库的所有表执行 `SELECT`查询。同样，你可以忽略库名。在这种情形下，权限将指向当前的数据库。例如， `GRANT SELECT ON* to john` 对当前数据库的所有表指定授权， `GARNT SELECT ON mytable to john`对当前数据库的 `mytable`表进行授权。

访问 `systen`数据库总是被允许的（因为这个数据库用来处理sql操作）
可以一次给多个账号进行多种授权操作。 `GRANT SELECT,INSERT ON *.* TO john,robin` 允许 `john`和`robin` 账号对任意数据库的任意表执行 `INSERT`和 `SELECT`操作。

#### 权限

权限是指执行特定操作的许可

权限有层级结构。一组允许的操作依赖相应的权限范围。

权限的层级：

- SELECT

- INSERT

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
      - `ALTER ADD INDEX`
      - `ALTER DROP INDEX`
      - `ALTER MATERIALIZE INDEX`
      - `ALTER CLEAR INDEX`

    - `ALTER CONSTRAINT`

      - `ALTER ADD CONSTRAINT`

      - ALTER DROP CONSTRAINT
        - ALTER TTL
        - ALTER MATERIALIZE TTL
        - ALTER SETTINGS
        - ALTER MOVE PARTITION
        - ALTER FETCH PARTITION
        - ALTER FREEZE PARTITION

      - CREATE

        - `CREATE DATABASE`
        - `CREATE TABLE`
        - `CREATE VIEW`
        - `CREATE DICTIONARY`
        - `CREATE TEMPORARY TABLE`

      - DROP

        - `DROP DATABASE`
        - `DROP TABLE`
        - `DROP VIEW`
        - `DROP DICTIONARY`

      - TRUNCATE

      - OPTIMIZE

      - SHOW

        - `SHOW DATABASES`
        - `SHOW TABLES`
        - `SHOW COLUMNS`
        - `SHOW DICTIONARIES`

      - KILL QUERY

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
          - `SYSTEM RELOAD DICTIONARY`
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

      - dictGet

如何对待该层级的示例：
\- `ALTER` 权限包含所有其它 `ALTER *` 的权限
\- `ALTER CONSTRAINT` 包含 `ALTER ADD CONSTRAINT` 和 `ALTER DROP CONSTRAINT`权限

权限被应用到不同级别。 Knowing of a level suggests syntax available for privilege.

级别（由低到高）：

- `COLUMN` - 可以授权到列，表，库或者全局
- `TABLE` - 可以授权到表，库，或全局
- `VIEW` - 可以授权到视图，库，或全局
- `DICTIONARY` - 可以授权到字典，库，或全局
- `DATABASE` - 可以授权到数据库或全局
- `GLABLE` - 可以授权到全局
- `GROUP` - 不同级别的权限分组。当授予 `GROUP`级别的权限时， 根据所用的语法，只有对应分组中的权限才会被分配。

允许的语法示例：

- `GRANT SELECT(x) ON db.table TO user`
- `GRANT SELECT ON db.* TO user`

不允许的语法示例：

- `GRANT CREATE USER(x) ON db.table TO user`
- `GRANT CREATE USER ON db.* TO user`

特殊的权限 `ALL` 将所有权限授予给用户或角色

默认情况下，一个用户账号或角色没有可授予的权限

如果用户或角色没有任何权限，它将显示为 `NONE`权限

有些操作根据它们的实现需要一系列的权限。例如， RENAME操作需要以下权限来执行：`SELECT`, `CREATE TABLE`, `INSERT` 和 `DROP TABLE`。

#### SELECT

允许执行 SELECT 查询

权限级别: `COLUMN`.

**说明**

有该权限的用户可以对指定的表和库的指定列进行 `SELECT`查询。如果用户查询包含了其它列则结果不返回数据。

考虑如下的授权语句：

```
GRANT SELECT(x,y) ON db.table TO john
```

该权限允许 `john` 对 `db.table`表的列`x`,`y`执行任意 `SELECT`查询，例如 `SELECT x FROM db.table`。 `john` 不能执行 `SELECT z FROM db.table`以及 `SELECT * FROM db.table`。执行这个查询时，CH不会返回任何数据，甚至 `x` 和 `y`列。唯一的例外是，当表仅包含 `x`和`y`列时。这种情况下，CH返回所有数据。

#### INSERT

允许执行 INSERT 操作.

权限级别: `COLUMN`.

**说明**

有该权限的用户可以对指定的表和库的指定列进行 `INSERT`操作。如果用户查询包含了其它列则结果不返回数据。

**示例**

```
GRANT INSERT(x,y) ON db.table TO john
```

该权限允许 `john` 对 `db.table`表的列`x`,`y`执行数据插入操作

#### ALTER

允许根据下列权限层级执行 ALTER操作

- ```
  ALTER
  ```

  . 级别:



  ```
  COLUMN
  ```

  .

  - ```
    ALTER TABLE
    ```

    . 级别:



    ```
    GROUP
    ```

    - `ALTER UPDATE`. 级别: `COLUMN`. 别名: `UPDATE`

    - `ALTER DELETE`. 级别: `COLUMN`. 别名: `DELETE`

    - ```
      ALTER COLUMN
      ```

      . 级别:



      ```
      GROUP
      ```

      - `ALTER ADD COLUMN`. 级别: `COLUMN`. 别名: `ADD COLUMN`
      - `ALTER DROP COLUMN`. 级别: `COLUMN`. 别名: `DROP COLUMN`
      - `ALTER MODIFY COLUMN`. 级别: `COLUMN`. 别名: `MODIFY COLUMN`
      - `ALTER COMMENT COLUMN`. 级别: `COLUMN`. 别名: `COMMENT COLUMN`
      - `ALTER CLEAR COLUMN`. 级别: `COLUMN`. 别名: `CLEAR COLUMN`
      - `ALTER RENAME COLUMN`. 级别: `COLUMN`. 别名: `RENAME COLUMN`

    - ```
      ALTER INDEX
      ```

      . 级别:



      ```
      GROUP
      ```

      . 别名:



      ```
      INDEX
      ```

      - `ALTER ORDER BY`. 级别: `TABLE`. 别名: `ALTER MODIFY ORDER BY`, `MODIFY ORDER BY`
      - `ALTER ADD INDEX`. 级别: `TABLE`. 别名: `ADD INDEX`
      - `ALTER DROP INDEX`. 级别: `TABLE`. 别名: `DROP INDEX`
      - `ALTER MATERIALIZE INDEX`. 级别: `TABLE`. 别名: `MATERIALIZE INDEX`
      - `ALTER CLEAR INDEX`. 级别: `TABLE`. 别名: `CLEAR INDEX`

    - ```
      ALTER CONSTRAINT
      ```

      . 级别:



      ```
      GROUP
      ```

      . 别名:



      ```
      CONSTRAINT
      ```

      - `ALTER ADD CONSTRAINT`. 级别: `TABLE`. 别名: `ADD CONSTRAINT`
      - `ALTER DROP CONSTRAINT`. 级别: `TABLE`. 别名: `DROP CONSTRAINT`

    - `ALTER TTL`. 级别: `TABLE`. 别名: `ALTER MODIFY TTL`, `MODIFY TTL`

    - `ALTER MATERIALIZE TTL`. 级别: `TABLE`. 别名: `MATERIALIZE TTL`

    - `ALTER SETTINGS`. 级别: `TABLE`. 别名: `ALTER SETTING`, `ALTER MODIFY SETTING`, `MODIFY SETTING`

    - `ALTER MOVE PARTITION`. 级别: `TABLE`. 别名: `ALTER MOVE PART`, `MOVE PARTITION`, `MOVE PART`

    - `ALTER FETCH PARTITION`. 级别: `TABLE`. 别名: `FETCH PARTITION`

    - `ALTER FREEZE PARTITION`. 级别: `TABLE`. 别名: `FREEZE PARTITION`

  - ```
    ALTER VIEW
    ```



    级别:



    ```
    GROUP
    ```

    - `ALTER VIEW REFRESH`. 级别: `VIEW`. 别名: `ALTER LIVE VIEW REFRESH`, `REFRESH VIEW`
    - `ALTER VIEW MODIFY QUERY`. 级别: `VIEW`. 别名: `ALTER TABLE MODIFY QUERY`

如何对待该层级的示例：
\- `ALTER` 权限包含所有其它 `ALTER *` 的权限
\- `ALTER CONSTRAINT` 包含 `ALTER ADD CONSTRAINT` 和 `ALTER DROP CONSTRAINT`权限

**备注**

- `MODIFY SETTING`权限允许修改表的引擎设置。它不会影响服务的配置参数
- `ATTACH` 操作需要 CREATE 权限.
- `DETACH` 操作需要 DROP 权限.
- 要通过 KILL MUTATION 操作来终止mutation, 你需要有发起mutation操作的权限。例如，当你想终止 `ALTER UPDATE`操作时，需要有 `ALTER UPDATE`, `ALTER TABLE`, 或 `ALTER`权限

#### CREATE

允许根据下面的权限层级来执行 CREATE 和 ATTACH DDL语句:

- ```
  CREATE
  ```

  . 级别:



  ```
  GROUP
  ```

  - `CREATE DATABASE`. 级别: `DATABASE`
  - `CREATE TABLE`. 级别: `TABLE`
  - `CREATE VIEW`. 级别: `VIEW`
  - `CREATE DICTIONARY`. 级别: `DICTIONARY`
  - `CREATE TEMPORARY TABLE`. 级别: `GLOBAL`

**备注**

- 删除已创建的表，用户需要 DROP权限

#### DROP

允许根据下面的权限层级来执行 DROP 和 DETACH :

- ```
  DROP
  ```

  . 级别:

  - `DROP DATABASE`. 级别: `DATABASE`
  - `DROP TABLE`. 级别: `TABLE`
  - `DROP VIEW`. 级别: `VIEW`
  - `DROP DICTIONARY`. 级别: `DICTIONARY`

#### TRUNCATE

允许执行 TRUNCATE .

权限级别: `TABLE`.

#### OPTIMIZE

允许执行 OPTIMIZE TABLE .

权限级别: `TABLE`.

#### SHOW

允许根据下面的权限层级来执行 `SHOW`, `DESCRIBE`, `USE`, 和 `EXISTS` :

- ```
  SHOW
  ```

  . 级别:



  ```
  GROUP
  ```

  - `SHOW DATABASES`. 级别: `DATABASE`. 允许执行 `SHOW DATABASES`, `SHOW CREATE DATABASE`, `USE <database>` .
  - `SHOW TABLES`. 级别: `TABLE`. 允许执行 `SHOW TABLES`, `EXISTS <table>`, `CHECK <table>` .
  - `SHOW COLUMNS`. 级别: `COLUMN`. 允许执行 `SHOW CREATE TABLE`, `DESCRIBE` .
  - `SHOW DICTIONARIES`. 级别: `DICTIONARY`. 允许执行 `SHOW DICTIONARIES`, `SHOW CREATE DICTIONARY`, `EXISTS <dictionary>` .

**备注**

用户同时拥有 `SHOW`权限，当用户对指定表，字典或数据库有其它的权限时。

#### KILL QUERY

允许根据下面的权限层级来执行 KILL:

权限级别: `GLOBAL`.

**备注**

`KILL QUERY` 权限允许用户终止其它用户提交的操作。

#### 访问管理

允许用户执行管理用户/角色和行规则的操作:

- ```
  ACCESS MANAGEMENT
  ```

  . 级别:



  ```
  GROUP
  ```

  - `CREATE USER`. 级别: `GLOBAL`

  - `ALTER USER`. 级别: `GLOBAL`

  - `DROP USER`. 级别: `GLOBAL`

  - `CREATE ROLE`. 级别: `GLOBAL`

  - `ALTER ROLE`. 级别: `GLOBAL`

  - `DROP ROLE`. 级别: `GLOBAL`

  - `ROLE ADMIN`. 级别: `GLOBAL`

  - `CREATE ROW POLICY`. 级别: `GLOBAL`. 别名: `CREATE POLICY`

  - `ALTER ROW POLICY`. 级别: `GLOBAL`. 别名: `ALTER POLICY`

  - `DROP ROW POLICY`. 级别: `GLOBAL`. 别名: `DROP POLICY`

  - `CREATE QUOTA`. 级别: `GLOBAL`

  - `ALTER QUOTA`. 级别: `GLOBAL`

  - `DROP QUOTA`. 级别: `GLOBAL`

  - `CREATE SETTINGS PROFILE`. 级别: `GLOBAL`. 别名: `CREATE PROFILE`

  - `ALTER SETTINGS PROFILE`. 级别: `GLOBAL`. 别名: `ALTER PROFILE`

  - `DROP SETTINGS PROFILE`. 级别: `GLOBAL`. 别名: `DROP PROFILE`

  - ```
    SHOW ACCESS
    ```

    . 级别:



    ```
    GROUP
    ```

    - `SHOW_USERS`. 级别: `GLOBAL`. 别名: `SHOW CREATE USER`
    - `SHOW_ROLES`. 级别: `GLOBAL`. 别名: `SHOW CREATE ROLE`
    - `SHOW_ROW_POLICIES`. 级别: `GLOBAL`. 别名: `SHOW POLICIES`, `SHOW CREATE ROW POLICY`, `SHOW CREATE POLICY`
    - `SHOW_QUOTAS`. 级别: `GLOBAL`. 别名: `SHOW CREATE QUOTA`
    - `SHOW_SETTINGS_PROFILES`. 级别: `GLOBAL`. 别名: `SHOW PROFILES`, `SHOW CREATE SETTINGS PROFILE`, `SHOW CREATE PROFILE`

`ROLE ADMIN` 权限允许用户对角色进行分配以及撤回，包括根据管理选项尚未分配的角色

#### SYSTEM

允许根据下面的权限层级来执行 SYSTEM :

- ```
  SYSTEM
  ```

  . 级别:



  ```
  GROUP
  ```

  - `SYSTEM SHUTDOWN`. 级别: `GLOBAL`. 别名: `SYSTEM KILL`, `SHUTDOWN`

  - ```
    SYSTEM DROP CACHE
    ```

    . 别名:



    ```
    DROP CACHE
    ```

    - `SYSTEM DROP DNS CACHE`. 级别: `GLOBAL`. 别名: `SYSTEM DROP DNS`, `DROP DNS CACHE`, `DROP DNS`
    - `SYSTEM DROP MARK CACHE`. 级别: `GLOBAL`. 别名: `SYSTEM DROP MARK`, `DROP MARK CACHE`, `DROP MARKS`
    - `SYSTEM DROP UNCOMPRESSED CACHE`. 级别: `GLOBAL`. 别名: `SYSTEM DROP UNCOMPRESSED`, `DROP UNCOMPRESSED CACHE`, `DROP UNCOMPRESSED`

  - ```
    SYSTEM RELOAD
    ```

    . 级别:



    ```
    GROUP
    ```

    - `SYSTEM RELOAD CONFIG`. 级别: `GLOBAL`. 别名: `RELOAD CONFIG`
    - `SYSTEM RELOAD DICTIONARY`. 级别: `GLOBAL`. 别名: `SYSTEM RELOAD DICTIONARIES`, `RELOAD DICTIONARY`, `RELOAD DICTIONARIES`
    - `SYSTEM RELOAD EMBEDDED DICTIONARIES`. 级别: `GLOBAL`. 别名: R`ELOAD EMBEDDED DICTIONARIES`

  - `SYSTEM MERGES`. 级别: `TABLE`. 别名: `SYSTEM STOP MERGES`, `SYSTEM START MERGES`, `STOP MERGES`, `START MERGES`

  - `SYSTEM TTL MERGES`. 级别: `TABLE`. 别名: `SYSTEM STOP TTL MERGES`, `SYSTEM START TTL MERGES`, `STOP TTL MERGES`, `START TTL MERGES`

  - `SYSTEM FETCHES`. 级别: `TABLE`. 别名: `SYSTEM STOP FETCHES`, `SYSTEM START FETCHES`, `STOP FETCHES`, `START FETCHES`

  - `SYSTEM MOVES`. 级别: `TABLE`. 别名: `SYSTEM STOP MOVES`, `SYSTEM START MOVES`, `STOP MOVES`, `START MOVES`

  - ```
    SYSTEM SENDS
    ```

    . 级别:



    ```
    GROUP
    ```

    . 别名:



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

    - `SYSTEM DISTRIBUTED SENDS`. 级别: `TABLE`. 别名: `SYSTEM STOP DISTRIBUTED SENDS`, `SYSTEM START DISTRIBUTED SENDS`, `STOP DISTRIBUTED SENDS`, `START DISTRIBUTED SENDS`
    - `SYSTEM REPLICATED SENDS`. 级别: `TABLE`. 别名: `SYSTEM STOP REPLICATED SENDS`, `SYSTEM START REPLICATED SENDS`, `STOP REPLICATED SENDS`, `START REPLICATED SENDS`

  - `SYSTEM REPLICATION QUEUES`. 级别: `TABLE`. 别名: `SYSTEM STOP REPLICATION QUEUES`, `SYSTEM START REPLICATION QUEUES`, `STOP REPLICATION QUEUES`, `START REPLICATION QUEUES`

  - `SYSTEM SYNC REPLICA`. 级别: `TABLE`. 别名: `SYNC REPLICA`

  - `SYSTEM RESTART REPLICA`. 级别: `TABLE`. 别名: `RESTART REPLICA`

  - ```
    SYSTEM FLUSH
    ```

    . 级别:



    ```
    GROUP
    ```

    - `SYSTEM FLUSH DISTRIBUTED`. 级别: `TABLE`. 别名: `FLUSH DISTRIBUTED`
    - `SYSTEM FLUSH LOGS`. 级别: `GLOBAL`. 别名: `FLUSH LOGS`

`SYSTEM RELOAD EMBEDDED DICTIONARIES` 权限隐式的通过操作 `SYSTEM RELOAD DICTIONARY ON *.*` 来进行授权.

#### 内省introspection

允许使用 introspection 函数.

- ```
  INTROSPECTION
  ```

  . 级别:



  ```
  GROUP
  ```

  . 别名:



  ```
  INTROSPECTION FUNCTIONS
  ```

  - `addressToLine`. 级别: `GLOBAL`
  - `addressToSymbol`. 级别: `GLOBAL`
  - `demangle`. 级别: `GLOBAL`

#### 数据源

允许在 table engines 和 table functions中使用外部数据源。

- ```
  SOURCES
  ```

  . 级别:



  ```
  GROUP
  ```

  - `FILE`. 级别: `GLOBAL`
  - `URL`. 级别: `GLOBAL`
  - `REMOTE`. 级别: `GLOBAL`
  - `YSQL`. 级别: `GLOBAL`
  - `ODBC`. 级别: `GLOBAL`
  - `JDBC`. 级别: `GLOBAL`
  - `HDFS`. 级别: `GLOBAL`
  - `S3`. 级别: `GLOBAL`

`SOURCES` 权限允许使用所有数据源。当然也可以单独对每个数据源进行授权。要使用数据源时，还需要额外的权限。

示例:

- 创建 MySQL table engine, 需要 `CREATE TABLE (ON db.table_name)` 和 `MYSQL`权限。4
- 要使用 mysql table function，需要 `CREATE TEMPORARY TABLE` 和 `MYSQL` 权限

#### dictGet

- `dictGet`. 别名: `dictHas`, `dictGetHierarchy`, `dictIsIn`

允许用户执行 dictGet, dictHas, dictGetHierarchy, dictIsIn 等函数.

权限级别: `DICTIONARY`.

**示例**

- `GRANT dictGet ON mydb.mydictionary TO john`
- `GRANT dictGet ON mydictionary TO john`

#### ALL

对规定的实体（列，表，库等）给用户或角色授予所有权限

#### NONE

不授予任何权限

#### ADMIN OPTION

`ADMIN OPTION` 权限允许用户将他们的角色分配给其它用户
', 0, 1, '2021-05-25 10:26:37', 1, '2021-05-25 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(14, '#### 权限取消

取消用户或角色的权限

#### 语法

**取消用户的权限**

```
REVOKE [ON CLUSTER cluster_name] privilege[(column_name [,...])] [,...] ON {db.table|db.*|*.*|table|*} FROM {user | CURRENT_USER} [,...] | ALL | ALL EXCEPT {user | CURRENT_USER} [,...]
```

**取消用户的角色**

```
REVOKE [ON CLUSTER cluster_name] [ADMIN OPTION FOR] role [,...] FROM {user | role | CURRENT_USER} [,...] | ALL | ALL EXCEPT {user_name | role_name | CURRENT_USER} [,...]
```

#### 说明

要取消某些权限，可使用比要撤回的权限更大范围的权限。例如，当用户有 `SELECT (x,y)`权限时，管理员可执行 `REVOKE SELECT(x,y) ...`, 或 `REVOKE SELECT * ...`, 甚至是 `REVOKE ALL PRIVILEGES ...`来取消原有权限。

#### 取消部分权限

可以取消部分权限。例如，当用户有 `SELECT *.*` 权限时，可以通过授予对部分库或表的读取权限来撤回原有权限。

#### 示例

授权 `john`账号能查询所有库的所有表，除了 `account`库。

```
GRANT SELECT ON *.* TO john;
REVOKE SELECT ON accounts.* FROM john;
```

授权 `mira`账号能查询 `accounts.staff`表的所有列，除了 `wage`这一列。

```
GRANT SELECT ON accounts.staff TO mira;
REVOKE SELECT(wage) ON accounts.staff FROM mira;
```
', 0, 1, '2021-05-26 10:26:37', 1, '2021-05-26 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(15, '#### 杂项查询

#### ATTACH

与`CREATE`类似，但有所区别

- 使用关键词 `ATTACH`
- 查询不会在磁盘上创建数据。但会假定数据已经在对应位置存放，同时将与表相关的信息添加到服务器。
  执行 `ATTACH` 查询后，服务器将知道表已经被创建。

如果表之前已分离 (`DETACH`），意味着其结构是已知的，可以使用简要的写法来建立表，即不需要定义表结构的Schema细节。

```
ATTACH TABLE [IF NOT EXISTS] [db.]name [ON CLUSTER cluster]
```

启动服务器时会自动触发此查询。

服务器将表的元数据作为文件存储 `ATTACH` 查询，它只是在启动时运行。有些表例外，如系统表，它们是在服务器上显式指定的。

#### CHECK TABLE

检查表中的数据是否已损坏。

```
CHECK TABLE [db.]name
```

`CHECK TABLE` 查询会比较存储在服务器上的实际文件大小与预期值。 如果文件大小与存储的值不匹配，则表示数据已损坏。 例如，这可能是由查询执行期间的系统崩溃引起的。

查询返回一行结果，列名为 `result`, 该行的值为 布尔值 类型:

- 0-表中的数据已损坏；
- 1-数据保持完整性；

该 `CHECK TABLE` 查询支持下表引擎:

- Log
- TinyLog
- StripeLog
- MergeTree 家族

对其他不支持的表引擎的表执行会导致异常。

来自 `*Log` 家族的引擎不提供故障自动数据恢复。 使用 `CHECK TABLE` 查询及时跟踪数据丢失。

对于 `MergeTree` 家族引擎， `CHECK TABLE` 查询显示本地服务器上表的每个单独数据部分的检查状态。

**如果数据已损坏**

如果表已损坏，则可以将未损坏的数据复制到另一个表。 要做到这一点:

1. 创建一个与损坏的表结构相同的新表。 请执行查询 `CREATE TABLE <new_table_name> AS <damaged_table_name>`.
2. 将 max_threads 值设置为1，以在单个线程中处理下一个查询。 要这样做，请运行查询 `SET max_threads = 1`.
3. 执行查询 `INSERT INTO <new_table_name> SELECT * FROM <damaged_table_name>`. 此请求将未损坏的数据从损坏的表复制到另一个表。 只有损坏部分之前的数据才会被复制。
4. 重新启动 `clickhouse-client` 以重置 `max_threads` 值。

#### DESCRIBE TABLE

查看表的描述信息，返回各列的Schema，语法如下：

```
DESC|DESCRIBE TABLE [db.]table [INTO OUTFILE filename] [FORMAT format]
```

返回以下 `String` 类型列:

- `name` — 列名。
- `type`— 列的类型。
- `default_type` — 默认表达式 (`DEFAULT`, `MATERIALIZED` 或 `ALIAS`)中使用的子句。 如果没有指定默认表达式，则列包含一个空字符串。
- `default_expression` — `DEFAULT` 子句中指定的值。
- `comment_expression` — 注释信息。

嵌套数据结构以 “expanded” 格式输出。 每列分别显示，列名后加点号。

#### DETACH

从服务器中删除目标表信息（删除对象是表), 执行查询后,服务器视作该表已经不存在。

```
DETACH TABLE [IF EXISTS] [db.]name [ON CLUSTER cluster]
```

这不会删除表的数据或元数据。 在下一次服务器启动时，服务器将读取元数据并再次查找该表。
也可以不停止服务器的情况下，使用前面介绍的 `ATTACH` 查询来重新关联该表（系统表除外，没有为它们存储元数据）。

#### DROP

删除已经存在的实体。如果指定 `IF EXISTS`， 则如果实体不存在，则不返回错误。
建议使用时添加 `IF EXISTS` 修饰符。

#### DROP DATABASE

删除 `db` 数据库中的所有表，然后删除 `db` 数据库本身。

语法:

```
DROP DATABASE [IF EXISTS] db [ON CLUSTER cluster]
```

#### DROP TABLE

删除表。

语法:

```
DROP [TEMPORARY] TABLE [IF EXISTS] [db.]name [ON CLUSTER cluster]
```

#### DROP DICTIONARY

删除字典。

语法:

```
DROP DICTIONARY [IF EXISTS] [db.]name
```

#### DROP USER

删除用户。

语法:

```
DROP USER [IF EXISTS] name [,...] [ON CLUSTER cluster_name]
```

#### DROP ROLE

删除角色。

同时该角色所拥有的权限也会被收回。

语法:

```
DROP ROLE [IF EXISTS] name [,...] [ON CLUSTER cluster_name]
```

#### DROP ROW POLICY

删除行策略。

已删除行策略将从分配该策略的所有实体撤销。

语法:

```
DROP [ROW] POLICY [IF EXISTS] name [,...] ON [database.]table [,...] [ON CLUSTER cluster_name]
```

#### DROP QUOTA

删除配额。

已删除的配额将从分配该配额的所有实体撤销。

语法:

```
DROP QUOTA [IF EXISTS] name [,...] [ON CLUSTER cluster_name]
```

#### DROP SETTINGS PROFILE

删除settings配置。

已删除的settings配置将从分配该settings配置的所有实体撤销。

语法:

```
DROP [SETTINGS] PROFILE [IF EXISTS] name [,...] [ON CLUSTER cluster_name]
```

#### DROP VIEW

删除视图。视图也可以通过 `DROP TABLE` 删除，但是 `DROP VIEW` 检查 `[db.]name` 是视图。

语法:

```
DROP VIEW [IF EXISTS] [db.]name [ON CLUSTER cluster]
```

#### EXISTS

```
EXISTS [TEMPORARY] [TABLE|DICTIONARY] [db.]name [INTO OUTFILE filename] [FORMAT format]
```

返回单个 `UInt8` 类型的列，其中包含单个值 `0` 如果表或数据库不存在，或 `1` 如果该表存在于指定的数据库中。

#### KILL QUERY

```
KILL QUERY [ON CLUSTER cluster]
  WHERE <where expression to SELECT FROM system.processes query>
  [SYNC|ASYNC|TEST]
  [FORMAT format]
```

尝试强制终止当前正在运行的查询。
要终止的查询是使用 `KILL` 查询的 `WHERE` 子句定义的标准从system.processes表中选择的。

例:

```
-- Forcibly terminates all queries with the specified query_id:
KILL QUERY WHERE query_id=''2-857d-4a57-9ee0-327da5d60a90''

-- Synchronously terminates all queries run by ''username'':
KILL QUERY WHERE user=''username'' SYNC
```

只读用户只能停止自己提交的查询。

默认情况下，使用异步版本的查询 (`ASYNC`），不需要等待确认查询已停止。

而相对的，终止同步版本 (`SYNC`）的查询会显示每步停止时间。

返回信息包含 `kill_status` 列，该列可以采用以下值:

1. ‘finished’ – 查询已成功终止。
2. ‘waiting’ – 发送查询信号终止后，等待查询结束。
3. 其他值，会解释为什么查询不能停止。

测试查询 (`TEST`）仅检查用户的权限，并显示要停止的查询列表。

#### KILL MUTATION

```
KILL MUTATION [ON CLUSTER cluster]
  WHERE <where expression to SELECT FROM system.mutations query>
  [TEST]
  [FORMAT format]
```

尝试取消和删除当前正在执行的 mutations 。 要取消的mutation是使用 `KILL` 查询的WHERE子句指定的过滤器从`system.mutations` 表中选择的。

测试查询 (`TEST`）仅检查用户的权限并显示要停止的mutations列表。

例:

```
-- Cancel and remove all mutations of the single table:
KILL MUTATION WHERE database = ''default'' AND table = ''table''

-- Cancel the specific mutation:
KILL MUTATION WHERE database = ''default'' AND table = ''table'' AND mutation_id = ''mutation_3.txt''
```

当mutation卡住且无法完成时，该查询是有用的(例如，当mutation查询中的某些函数在应用于表中包含的数据时抛出异常)。

Mutation已经做出的更改不会回滚。

#### OPTIMIZE

```
OPTIMIZE TABLE [db.]name [ON CLUSTER cluster] [PARTITION partition | PARTITION ID ''partition_id''] [FINAL] [DEDUPLICATE]
```

此查询尝试初始化 MergeTree家族的表引擎的表中未计划合并数据部分。

该 `OPTMIZE` 查询也支持 MaterializedView 和 Buffer 引擎。 不支持其他表引擎。

当 `OPTIMIZE` 与 ReplicatedMergeTree 家族的表引擎一起使用时，ClickHouse将创建一个合并任务，并等待所有节点上的执行（如果 `replication_alter_partitions_sync` 设置已启用）。

- 如果 `OPTIMIZE` 出于任何原因不执行合并，它不通知客户端。 要启用通知，请使用 optimize_throw_if_noop 设置。
- 如果您指定 `PARTITION`，仅优化指定的分区。 如何设置分区表达式.
- 如果您指定 `FINAL`，即使所有数据已经在一个部分中，也会执行优化。
- 如果您指定 `DEDUPLICATE`，则将对完全相同的行进行重复数据删除（所有列进行比较），这仅适用于MergeTree引擎。

警告

`OPTIMIZE` 无法修复 “Too many parts” 错误。

#### RENAME

重命名一个或多个表。

```
RENAME TABLE [db11.]name11 TO [db12.]name12, [db21.]name21 TO [db22.]name22, ... [ON CLUSTER cluster]
```

所有表都在全局锁定下重命名。 重命名表是一个轻型操作。 如果您在TO之后指定了另一个数据库，则表将被移动到此数据库。 但是，包含数据库的目录必须位于同一文件系统中（否则，将返回错误）。
如果您在一个查询中重命名多个表，这是一个非原子操作，它可能被部分执行，其他会话中的查询可能会接收错误 Table ... doesn''t exist ...。

#### SET

```
SET param = value
```

为当前会话的 设置 `param` 分配值 `value`。 您不能以这种方式更改 服务器设置。

您还可以在单个查询中从指定的设置配置文件中设置所有值。

```
SET profile = ''profile-name-from-the-settings-file''
```

有关详细信息，请参阅设置.

#### SET ROLE

激活当前用户的角色。

```
SET ROLE {DEFAULT | NONE | role [,...] | ALL | ALL EXCEPT role [,...]}
```

#### SET DEFAULT ROLE

将默认角色设置为用户。

默认角色在用户登录时自动激活。 您只能将以前授予的角色设置为默认值。 如果角色没有授予用户，ClickHouse会抛出异常。

```
SET DEFAULT ROLE {NONE | role [,...] | ALL | ALL EXCEPT role [,...]} TO {user|CURRENT_USER} [,...]
```

#### 示例

为用户设置多个默认角色:

```
SET DEFAULT ROLE role1, role2, ... TO user
```

将所有授予的角色设置为用户的默认角色:

```
SET DEFAULT ROLE ALL TO user
```

清除用户的默认角色:

```
SET DEFAULT ROLE NONE TO user
```

将所有授予的角色设置为默认角色，但其中一些角色除外:

```
SET DEFAULT ROLE ALL EXCEPT role1, role2 TO user
```

#### TRUNCATE

```
TRUNCATE TABLE [IF EXISTS] [db.]name [ON CLUSTER cluster]
```

从表中删除所有数据。 当省略 `IF EXISTS`子句时，如果该表不存在，则查询返回错误。

该 `TRUNCATE` 查询不支持 View, File, URL 和 Null 表引擎.

#### USE

```
USE db
```

用于设置会话的当前数据库。
当前数据库用于搜索表，如果数据库没有在查询中明确定义与表名之前的点。
使用HTTP协议时无法进行此查询，因为没有会话的概念。
', 0, 1, '2021-05-27 10:26:37', 1, '2021-05-27 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(16, '#### CREATE DATABASE

该查询用于根据指定名称创建数据库。

```
CREATE DATABASE [IF NOT EXISTS] db_name
```

数据库其实只是用于存放表的一个目录。
如果查询中存在`IF NOT EXISTS`，则当数据库已经存在时，该查询不会返回任何错误。

#### CREATE TABLE

对于`CREATE TABLE`，存在以下几种方式。

```
CREATE TABLE [IF NOT EXISTS] [db.]table_name [ON CLUSTER cluster]
(
    name1 [type1] [DEFAULT|MATERIALIZED|ALIAS expr1],
    name2 [type2] [DEFAULT|MATERIALIZED|ALIAS expr2],
    ...
) ENGINE = engine
```

在指定的’db’数据库中创建一个名为’name’的表，如果查询中没有包含’db’，则默认使用当前选择的数据库作为’db’。后面的是包含在括号中的表结构以及表引擎的声明。
其中表结构声明是一个包含一组列描述声明的组合。如果表引擎是支持索引的，那么可以在表引擎的参数中对其进行说明。

在最简单的情况下，列描述是指`名称 类型`这样的子句。例如： `RegionID UInt32`。
但是也可以为列另外定义默认值表达式（见后文）。

```
CREATE TABLE [IF NOT EXISTS] [db.]table_name AS [db2.]name2 [ENGINE = engine]
```

创建一个与`db2.name2`具有相同结构的表，同时你可以对其指定不同的表引擎声明。如果没有表引擎声明，则创建的表将与`db2.name2`使用相同的表引擎。

```
CREATE TABLE [IF NOT EXISTS] [db.]table_name ENGINE = engine AS SELECT ...
```

使用指定的引擎创建一个与`SELECT`子句的结果具有相同结构的表，并使用`SELECT`子句的结果填充它。

以上所有情况，如果指定了`IF NOT EXISTS`，那么在该表已经存在的情况下，查询不会返回任何错误。在这种情况下，查询几乎不会做任何事情。

在`ENGINE`子句后还可能存在一些其他的子句，更详细的信息可以参考 表引擎 中关于建表的描述。

#### 默认值

在列描述中你可以通过以下方式之一为列指定默认表达式：`DEFAULT expr`，`MATERIALIZED expr`，`ALIAS expr`。
示例：`URLDomain String DEFAULT domain(URL)`。

如果在列描述中未定义任何默认表达式，那么系统将会根据类型设置对应的默认值，如：数值类型为零、字符串类型为空字符串、数组类型为空数组、日期类型为’1970-01-01’以及时间类型为 zero unix timestamp。

如果定义了默认表达式，则可以不定义列的类型。如果没有明确的定义类的类型，则使用默认表达式的类型。例如：`EventDate DEFAULT toDate(EventTime)` - 最终’EventDate’将使用’Date’作为类型。

如果同时指定了默认表达式与列的类型，则将使用类型转换函数将默认表达式转换为指定的类型。例如：`Hits UInt32 DEFAULT 0`与`Hits UInt32 DEFAULT toUInt32(0)`意思相同。

默认表达式可以包含常量或表的任意其他列。当创建或更改表结构时，系统将会运行检查，确保不会包含循环依赖。对于INSERT, 它仅检查表达式是否是可以解析的 - 它们可以从中计算出所有需要的列的默认值。

```
DEFAULT expr
```

普通的默认值，如果INSERT中不包含指定的列，那么将通过表达式计算它的默认值并填充它。

```
MATERIALIZED expr
```

物化表达式，被该表达式指定的列不能包含在INSERT的列表中，因为它总是被计算出来的。
对于INSERT而言，不需要考虑这些列。
另外，在SELECT查询中如果包含星号，此列不会被用来替换星号，这是因为考虑到数据转储，在使用`SELECT *`查询出的结果总能够被’INSERT’回表。

```
ALIAS expr
```

别名。这样的列不会存储在表中。
它的值不能够通过INSERT写入，同时使用SELECT查询星号时，这些列也不会被用来替换星号。
但是它们可以显示的用于SELECT中，在这种情况下，在查询分析中别名将被替换。

当使用ALTER查询对添加新的列时，不同于为所有旧数据添加这个列，对于需要在旧数据中查询新列，只会在查询时动态计算这个新列的值。但是如果新列的默认表示中依赖其他列的值进行计算，那么同样会加载这些依赖的列的数据。

如果你向表中添加一个新列，并在之后的一段时间后修改它的默认表达式，则旧数据中的值将会被改变。请注意，在运行后台合并时，缺少的列的值将被计算后写入到合并后的数据部分中。

不能够为nested类型的列设置默认值。

#### 制约因素

随着列描述约束可以定义:

```
CREATE TABLE [IF NOT EXISTS] [db.]table_name [ON CLUSTER cluster]
(
    name1 [type1] [DEFAULT|MATERIALIZED|ALIAS expr1] [compression_codec] [TTL expr1],
    ...
    CONSTRAINT constraint_name_1 CHECK boolean_expr_1,
    ...
) ENGINE = engine
```

`boolean_expr_1` 可以通过任何布尔表达式。 如果为表定义了约束，则将为表中的每一行检查它们中的每一行 `INSERT` query. If any constraint is not satisfied — server will raise an exception with constraint name and checking expression.

添加大量的约束会对big的性能产生负面影响 `INSERT` 查询。

#### Ttl表达式

定义值的存储时间。 只能为MergeTree系列表指定。 有关详细说明，请参阅列和表的TTL.

#### 列压缩编解ecs

默认情况下，ClickHouse应用以下定义的压缩方法 服务器设置，列。 您还可以定义在每个单独的列的压缩方法 `CREATE TABLE` 查询。

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

如果指定了编解ec，则默认编解码器不适用。 编解码器可以组合在一个流水线中，例如, `CODEC(Delta, ZSTD)`. 要为您的项目选择最佳的编解码器组合，请通过类似于Altinity中描述的基准测试新编码提高ClickHouse效率文章.

警告

您无法使用外部实用程序解压缩ClickHouse数据库文件，如 `lz4`. 相反，使用特殊的ﾂ环板compressorｮﾂ嘉ｯﾂ偲实用程序。

下表引擎支持压缩:

- MergeTree 家庭
- 日志 家庭
- 设置
- 加入我们

ClickHouse支持通用编解码器和专用编解ecs。

##### 专业编解ecs

这些编解码器旨在通过使用数据的特定功能使压缩更有效。 其中一些编解码器不压缩数据本身。 相反，他们准备的数据用于共同目的的编解ec，其压缩它比没有这种准备更好。

专业编解ecs:

- `Delta(delta_bytes)` — Compression approach in which raw values are replaced by the difference of two neighboring values, except for the first value that stays unchanged. Up to `delta_bytes` 用于存储增量值，所以 `delta_bytes` 是原始值的最大大小。 可能 `delta_bytes` 值:1,2,4,8. 默认值 `delta_bytes` 是 `sizeof(type)` 如果等于1，2，4或8。 在所有其他情况下，它是1。
- `DoubleDelta` — Calculates delta of deltas and writes it in compact binary form. Optimal compression rates are achieved for monotonic sequences with a constant stride, such as time series data. Can be used with any fixed-width type. Implements the algorithm used in Gorilla TSDB, extending it to support 64-bit types. Uses 1 extra bit for 32-byte deltas: 5-bit prefixes instead of 4-bit prefixes. For additional information, see Compressing Time Stamps in Gorilla：一个快速、可扩展的内存时间序列数据库.
- `Gorilla` — Calculates XOR between current and previous value and writes it in compact binary form. Efficient when storing a series of floating point values that change slowly, because the best compression rate is achieved when neighboring values are binary equal. Implements the algorithm used in Gorilla TSDB, extending it to support 64-bit types. For additional information, see Compressing Values in Gorilla：一个快速、可扩展的内存时间序列数据库.
- `T64` — Compression approach that crops unused high bits of values in integer data types (including `Enum`, `Date` 和 `DateTime`). 在算法的每个步骤中，编解码器采用64个值块，将它们放入64x64位矩阵中，对其进行转置，裁剪未使用的值位并将其余部分作为序列返回。 未使用的位是使用压缩的整个数据部分的最大值和最小值之间没有区别的位。

`DoubleDelta` 和 `Gorilla` 编解码器在Gorilla TSDB中用作其压缩算法的组件。 大猩猩的方法是有效的情况下，当有缓慢变化的值与他们的时间戳序列。 时间戳是由有效地压缩 `DoubleDelta` 编解ec，和值有效地由压缩 `Gorilla` 编解ec 例如，要获取有效存储的表，可以在以下配置中创建它:

```
CREATE TABLE codec_example
(
    timestamp DateTime CODEC(DoubleDelta),
    slow_values Float32 CODEC(Gorilla)
)
ENGINE = MergeTree()
```

##### 通用编解ecs

编解ecs:

- `NONE` — No compression.
- `LZ4` — Lossless 数据压缩算法 默认情况下使用。 应用LZ4快速压缩。
- `LZ4HC[(level)]` — LZ4 HC (high compression) algorithm with configurable level. Default level: 9. Setting `level <= 0` 应用默认级别。 可能的水平：[1，12]。 推荐级别范围：[4，9]。
- `ZSTD[(level)]` — ZSTD压缩算法可配置 `level`. 可能的水平：[1，22]。 默认值：1。

高压缩级别对于非对称场景非常有用，例如压缩一次，重复解压缩。 更高的级别意味着更好的压缩和更高的CPU使用率。

#### 临时表

ClickHouse支持临时表，其具有以下特征：

- 当回话结束时，临时表将随会话一起消失，这包含链接中断。
- 临时表仅能够使用Memory表引擎。
- 无法为临时表指定数据库。它是在数据库之外创建的。
- 如果临时表与另一个表名称相同，那么当在查询时没有显示的指定db的情况下，将优先使用临时表。
- 对于分布式处理，查询中使用的临时表将被传递到远程服务器。

可以使用下面的语法创建一个临时表：

```
CREATE TEMPORARY TABLE [IF NOT EXISTS] table_name [ON CLUSTER cluster]
(
    name1 [type1] [DEFAULT|MATERIALIZED|ALIAS expr1],
    name2 [type2] [DEFAULT|MATERIALIZED|ALIAS expr2],
    ...
)
```

大多数情况下，临时表不是手动创建的，只有在分布式查询处理中使用`(GLOBAL) IN`时为外部数据创建。更多信息，可以参考相关章节。

#### 分布式DDL查询 （ON CLUSTER 子句）

对于 `CREATE`， `DROP`， `ALTER`，以及`RENAME`查询，系统支持其运行在整个集群上。
例如，以下查询将在`cluster`集群的所有节点上创建名为`all_hits`的`Distributed`表：

```
CREATE TABLE IF NOT EXISTS all_hits ON CLUSTER cluster (p Date, i Int32) ENGINE = Distributed(cluster, default, hits)
```

为了能够正确的运行这种查询，每台主机必须具有相同的cluster声明（为了简化配置的同步，你可以使用zookeeper的方式进行配置）。同时这些主机还必须链接到zookeeper服务器。
这个查询将最终在集群的每台主机上运行，即使一些主机当前处于不可用状态。同时它还保证了所有的查询在单台主机中的执行顺序。

#### CREATE VIEW

```
CREATE [MATERIALIZED] VIEW [IF NOT EXISTS] [db.]table_name [TO[db.]name] [ENGINE = engine] [POPULATE] AS SELECT ...
```

创建一个视图。它存在两种可选择的类型：普通视图与物化视图。

普通视图不存储任何数据，只是执行从另一个表中的读取。换句话说，普通视图只是保存了视图的查询，当从视图中查询时，此查询被作为子查询用于替换FROM子句。

举个例子，假设你已经创建了一个视图：

```
CREATE VIEW view AS SELECT ...
```

还有一个查询：

```
SELECT a, b, c FROM view
```

这个查询完全等价于：

```
SELECT a, b, c FROM (SELECT ...)
```

物化视图存储的数据是由相应的SELECT查询转换得来的。

在创建物化视图时，你还必须指定表的引擎 - 将会使用这个表引擎存储数据。

目前物化视图的工作原理：当将数据写入到物化视图中SELECT子句所指定的表时，插入的数据会通过SELECT子句查询进行转换并将最终结果插入到视图中。

如果创建物化视图时指定了POPULATE子句，则在创建时将该表的数据插入到物化视图中。就像使用`CREATE TABLE ... AS SELECT ...`一样。否则，物化视图只会包含在物化视图创建后的新写入的数据。我们不推荐使用POPULATE，因为在视图创建期间写入的数据将不会写入其中。

当一个`SELECT`子句包含`DISTINCT`, `GROUP BY`, `ORDER BY`, `LIMIT`时，请注意，这些仅会在插入数据时在每个单独的数据块上执行。例如，如果你在其中包含了`GROUP BY`，则只会在查询期间进行聚合，但聚合范围仅限于单个批的写入数据。数据不会进一步被聚合。但是当你使用一些其他数据聚合引擎时这是例外的，如：`SummingMergeTree`。

目前对物化视图执行`ALTER`是不支持的，因此这可能是不方便的。如果物化视图是使用的`TO [db.]name`的方式进行构建的，你可以使用`DETACH`语句现将视图剥离，然后使用`ALTER`运行在目标表上，然后使用`ATTACH`将之前剥离的表重新加载进来。

视图看起来和普通的表相同。例如，你可以通过`SHOW TABLES`查看到它们。

没有单独的删除视图的语法。如果要删除视图，请使用`DROP TABLE`。

来源文章

#### CREATE DICTIONARY

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
', 0, 1, '2021-05-28 10:26:37', 1, '2021-05-28 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(17, '#### INSERT INTO 语句

INSERT INTO 语句主要用于向系统中添加数据.

查询的基本格式:

```
INSERT INTO [db.]table [(c1, c2, c3)] VALUES (v11, v12, v13), (v21, v22, v23), ...
```

您可以在查询中指定要插入的列的列表，如：`(c1, c2, c3)]`。您还可以使用列匹配器，例如 APPLY， EXCEPT， REPLACE。

例如，考虑该表:

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
INSERT INTO insert_select_testtable (*) VALUES (1, ''a'', 1) ;
```

如果要在除了''b''列以外的所有列中插入数据，您需要传递和括号中选择的列数一样多的值:

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

在这个示例中，我们看到插入的第二行的`a`和`c`列的值由传递的值填充，而`b`列由默认值填充。

对于存在于表结构中但不存在于插入列表中的列，它们将会按照如下方式填充数据：

- 如果存在`DEFAULT`表达式，根据`DEFAULT`表达式计算被填充的值。
- 如果没有定义`DEFAULT`表达式，则填充零或空字符串。

如果strict_insert_defaults=1，你必须在查询中列出所有没有定义`DEFAULT`表达式的列。

数据可以以ClickHouse支持的任何输入输出格式传递给INSERT。格式的名称必须显示的指定在查询中：

```
INSERT INTO [db.]table [(c1, c2, c3)] FORMAT format_name data_set
```

例如，下面的查询所使用的输入格式就与上面INSERT … VALUES的中使用的输入格式相同：

```
INSERT INTO [db.]table [(c1, c2, c3)] FORMAT Values (v11, v12, v13), (v21, v22, v23), ...
```

ClickHouse会清除数据前所有的空白字符与一行摘要信息（如果需要的话）。所以在进行查询时，我们建议您将数据放入到输入输出格式名称后的新的一行中去（如果数据是以空白字符开始的，这将非常重要）。

示例:

```
INSERT INTO t FORMAT TabSeparated
11  Hello, world!
22  Qwerty
```

在使用命令行客户端或HTTP客户端时，你可以将具体的查询语句与数据分开发送。更多具体信息，请参考«客户端»部分。

#### 使用`SELECT`的结果写入

```
INSERT INTO [db.]table [(c1, c2, c3)] SELECT ...
```

写入与SELECT的列的对应关系是使用位置来进行对应的，尽管它们在SELECT表达式与INSERT中的名称可能是不同的。如果需要，会对它们执行对应的类型转换。

除了VALUES格式之外，其他格式中的数据都不允许出现诸如`now()`，`1 + 2`等表达式。VALUES格式允许您有限度的使用这些表达式，但是不建议您这么做，因为执行这些表达式总是低效的。

系统不支持的其他用于修改数据的查询：`UPDATE`, `DELETE`, `REPLACE`, `MERGE`, `UPSERT`, `INSERT UPDATE`。
但是，您可以使用 `ALTER TABLE ... DROP PARTITION`查询来删除一些旧的数据。

#### 性能的注意事项

在进行`INSERT`时将会对写入的数据进行一些处理，按照主键排序，按照月份对数据进行分区等。所以如果在您的写入数据中包含多个月份的混合数据时，将会显著的降低`INSERT`的性能。为了避免这种情况：

- 数据总是以尽量大的batch进行写入，如每次写入100,000行。
- 数据在写入ClickHouse前预先的对数据进行分组。

在以下的情况下，性能不会下降：

- 数据总是被实时的写入。
- 写入的数据已经按照时间排序。
', 0, 1, '2021-05-29 10:26:37', 1, '2021-05-29 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(18, '#### 函数

ClickHouse中至少存在两种类型的函数 - 常规函数（它们称之为«函数»）和聚合函数。 常规函数的工作就像分别为每一行执行一次函数计算一样（对于每一行，函数的结果不依赖于其他行）。 聚合函数则从各行累积一组值（即函数的结果以来整个结果集）。

在本节中，我们将讨论常规函数。 有关聚合函数，请参阅«聚合函数»一节。

\* - ’arrayJoin’函数与表函数均属于第三种类型的函数。 *

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

如果查询中的函数在请求服务器上执行，但您需要在远程服务器上执行它，则可以将其包装在«any»聚合函数中，或将其添加到«GROUP BY»中。
', 0, 1, '2021-05-30 10:26:37', 1, '2021-05-30 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(19, '#### 算术函数

对于所有算术函数，结果类型为结果适合的最小数值类型（如果存在这样的类型）。最小数值类型是根据数值的位数，是否有符号以及是否是浮点类型而同时进行的。如果没有足够的位，则采用最高位类型。

例如:

```
SELECT toTypeName(0), toTypeName(0 + 0), toTypeName(0 + 0 + 0), toTypeName(0 + 0 + 0 + 0)
┌─toTypeName(0)─┬─toTypeName(plus(0, 0))─┬─toTypeName(plus(plus(0, 0), 0))─┬─toTypeName(plus(plus(plus(0, 0), 0), 0))─┐
│ UInt8         │ UInt16                 │ UInt32                          │ UInt64                                   │
└───────────────┴────────────────────────┴─────────────────────────────────┴──────────────────────────────────────────┘
```

算术函数适用于UInt8，UInt16，UInt32，UInt64，Int8，Int16，Int32，Int64，Float32或Float64中的任何类型。

溢出的产生方式与C++相同。

#### plus(a, b), a + b operator

计算数值的总和。
您还可以将Date或DateTime与整数进行相加。在Date的情况下，和整数相加整数意味着添加相应的天数。对于DateTime，这意味着添加相应的秒数。

#### minus(a, b), a - b operator

计算数值之间的差，结果总是有符号的。

您还可以将Date或DateTime与整数进行相减。见上面的’plus’。

#### multiply(a, b), a * b operator

计算数值的乘积。

#### divide(a, b), a / b operator

计算数值的商。结果类型始终是浮点类型。
它不是整数除法。对于整数除法，请使用’intDiv’函数。
当除以零时，你得到’inf’，‘- inf’或’nan’。

#### intDiv(a,b)

计算数值的商，向下舍入取整（按绝对值）。
除以零或将最小负数除以-1时抛出异常。

#### intDivOrZero(a,b)

与’intDiv’的不同之处在于它在除以零或将最小负数除以-1时返回零。

#### modulo(a, b), a % b operator

计算除法后的余数。
如果参数是浮点数，则通过删除小数部分将它们预转换为整数。
其余部分与C++中的含义相同。截断除法用于负数。
除以零或将最小负数除以-1时抛出异常。

#### moduloOrZero(a, b)

和modulo不同之处在于，除以0时结果返回0

#### negate(a), -a operator

通过改变数值的符号位对数值取反，结果总是有符号的

#### abs(a)

计算数值（a）的绝对值。也就是说，如果a \< 0，它返回-a。对于无符号类型，它不执行任何操作。对于有符号整数类型，它返回无符号数。

#### gcd(a,b)

返回数值的最大公约数。
除以零或将最小负数除以-1时抛出异常。

#### lcm(a,b)

返回数值的最小公倍数。
除以零或将最小负数除以-1时抛出异常。
', 0, 1, '2021-05-31 10:26:37', 1, '2021-05-31 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(20, '#### 比较函数

比较函数始终返回0或1（UInt8）。

可以比较以下类型：

- 数字
- String 和 FixedString
- 日期
- 日期时间

以上每个组内的类型均可互相比较，但是对于不同组的类型间不能够进行比较。

例如，您无法将日期与字符串进行比较。您必须使用函数将字符串转换为日期，反之亦然。

字符串按字节进行比较。较短的字符串小于以其开头并且至少包含一个字符的所有字符串。

#### 等于，a=b和a==b 运算符

#### 不等于，a!=b和a<>b 运算符

#### 少, < 运算符

#### 大于, > 运算符

#### 小于等于, <= 运算符

#### 大于等于, >= 运算符
', 0, 1, '2021-06-01 10:26:37', 1, '2021-06-01 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(21, '#### 逻辑函数

逻辑函数可以接受任何数字类型的参数，并返回UInt8类型的0或1。

当向函数传递零时，函数将判定为«false»，否则，任何其他非零的值都将被判定为«true»。

#### 和，`AND` 运算符

#### 或，`OR` 运算符

#### 非，`NOT` 运算符

#### 异或，`XOR` 运算符
', 0, 1, '2021-06-02 10:26:37', 1, '2021-06-02 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(22, '#### 类型转换函数

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

NaN and Inf。

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

对于负数和NaN and Inf。

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
┌─s─────────────┬─s_cut─┐
│ foo\0\0\0\0\0 │ foo   │
└───────────────┴───────┘
SELECT toFixedString(''foo\0bar'', 8) AS s, toStringCutToZero(s) AS s_cut
┌─s──────────┬─s_cut─┐
│ foo\0bar\0 │ foo   │
└────────────┴───────┘
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

把String数据类型。

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
', 0, 1, '2021-06-03 10:26:37', 1, '2021-06-03 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(23, '#### IN运算符相关函数

#### in,notIn,globalIn,globalNotIn

请参阅IN 运算符部分。

#### tuple(x, y, …), 运算符 (x, y, …)

函数用于对多个列进行分组。
对于具有类型T1，T2，…的列，它返回包含这些列的元组（T1，T2，…）。 执行该函数没有任何成本。
元组通常用作IN运算符的中间参数值，或用于创建lambda函数的形参列表。 元组不能写入表。

#### tupleElement(tuple, n), 运算符 x.N

用于从元组中获取列的函数
’N’是列索引，从1开始。N必须是正整数常量，并且不大于元组的大小。
执行该函数没有任何成本。
', 0, 1, '2021-06-04 10:26:37', 1, '2021-06-04 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(24, '#### 内省功能

您可以使用本章中描述的函数来反省 ELF 和 DWARF 用于查询分析。

警告

这些功能很慢，可能会强加安全考虑。

对于内省功能的正确操作:

- 安装 `clickhouse-common-static-dbg` 包。

- 设置 allow_introspection_functions 设置为1。

  ```
  出于安全考虑，内省函数默认是关闭的。
  ```

ClickHouse将探查器报告保存到 trace_log 系统表. 确保正确配置了表和探查器。

#### addressToLine

将ClickHouse服务器进程内的虚拟内存地址转换为ClickHouse源代码中的文件名和行号。

如果您使用官方的ClickHouse软件包，您需要安装 `clickhouse-common-static-dbg` 包。

**语法**

```
addressToLine(address_of_binary_instruction)
```

**参数**

- `address_of_binary_instruction` (UInt64 — 正在运行进程的指令地址。

**返回值**

- 源代码文件名和行号（用冒号分隔的行号）

  ```
  示例, `/build/obj-x86_64-linux-gnu/../src/Common/ThreadPool.cpp:199`, where `199` is a line number.
  ```

- 如果函数找不到调试信息，返回二进制文件的名称。

- 如果地址无效，返回空字符串。

类型: 字符串.

**示例**

启用内省功能:

```
SET allow_introspection_functions=1
```

从中选择第一个字符串 `trace_log` 系统表:

```
SELECT * FROM system.trace_log LIMIT 1 \G
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

该 `trace` 字段包含采样时的堆栈跟踪。

获取单个地址的源代码文件名和行号:

```
SELECT addressToLine(94784076370703) \G
Row 1:
──────
addressToLine(94784076370703): /build/obj-x86_64-linux-gnu/../src/Common/ThreadPool.cpp:199
```

将函数应用于整个堆栈跟踪:

```
SELECT
    arrayStringConcat(arrayMap(x -> addressToLine(x), trace), ''\n'') AS trace_source_code_lines
FROM system.trace_log
LIMIT 1
\G
```

该 arrayMap 功能允许处理的每个单独的元素 `trace` 阵列由 `addressToLine` 功能。 这种处理的结果，你在看 `trace_source_code_lines` 列的输出。

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

#### addressToSymbol

将ClickHouse服务器进程内的虚拟内存地址转换为ClickHouse对象文件中的符号。

**语法**

```
addressToSymbol(address_of_binary_instruction)
```

**参数**

- `address_of_binary_instruction` (UInt64 — Address of instruction in a running process.

**返回值**

- 来自ClickHouse对象文件的符号。
- 如果地址无效，返回空字符串。

类型: 字符串.

**示例**

启用内省功能:

```
SET allow_introspection_functions=1
```

从中选择第一个字符串 `trace_log` 系统表:

```
SELECT * FROM system.trace_log LIMIT 1 \G
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

该 `trace` 字段包含采样时的堆栈跟踪。

获取单个地址的符号:

```
SELECT addressToSymbol(94138803686098) \G
Row 1:
──────
addressToSymbol(94138803686098): _ZNK2DB24IAggregateFunctionHelperINS_20AggregateFunctionSumImmNS_24AggregateFunctionSumDataImEEEEE19addBatchSinglePlaceEmPcPPKNS_7IColumnEPNS_5ArenaE
```

将函数应用于整个堆栈跟踪:

```
SELECT
    arrayStringConcat(arrayMap(x -> addressToSymbol(x), trace), ''\n'') AS trace_symbols
FROM system.trace_log
LIMIT 1
\G
```

该 arrayMap 功能允许处理的每个单独的元素 `trace` 阵列由 `addressToSymbols` 功能。 这种处理的结果，你在看 `trace_symbols` 列的输出。

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

#### demangle

转换一个符号，您可以使用 addressToSymbol 函数到C++函数名。

**语法**

```
demangle(symbol)
```

**参数**

- `symbol` (字符串 — Symbol from an object file.

**返回值**

- C++函数的名称。
- 如果符号无效，则为空字符串。

类型: 字符串.

**示例**

启用内省功能:

```
SET allow_introspection_functions=1
```

从中选择第一个字符串 `trace_log` 系统表:

```
SELECT * FROM system.trace_log LIMIT 1 \G
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

该 `trace` 字段包含采样时的堆栈跟踪。

获取单个地址的函数名称:

```
SELECT demangle(addressToSymbol(94138803686098)) \G
Row 1:
──────
demangle(addressToSymbol(94138803686098)): DB::IAggregateFunctionHelper<DB::AggregateFunctionSum<unsigned long, unsigned long, DB::AggregateFunctionSumData<unsigned long> > >::addBatchSinglePlace(unsigned long, char*, DB::IColumn const**, DB::Arena*) const
```

将函数应用于整个堆栈跟踪:

```
SELECT
    arrayStringConcat(arrayMap(x -> demangle(addressToSymbol(x)), trace), ''\n'') AS trace_functions
FROM system.trace_log
LIMIT 1
\G
```

该 arrayMap 功能允许处理的每个单独的元素 `trace` 阵列由 `demangle` 功能。 这种处理的结果，你在看 `trace_functions` 列的输出。

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
', 0, 1, '2021-06-05 10:26:37', 1, '2021-06-05 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(25, '#### GEO函数

#### 大圆形距离

使用great-circle distance公式计算地球表面两点之间的距离。

```
greatCircleDistance(lon1Deg, lat1Deg, lon2Deg, lat2Deg)
```

**输入参数**

- `lon1Deg` — 第一个点的经度，单位：度，范围： `[-180°, 180°]`。
- `lat1Deg` — 第一个点的纬度，单位：度，范围： `[-90°, 90°]`。
- `lon2Deg` — 第二个点的经度，单位：度，范围： `[-180°, 180°]`。
- `lat2Deg` — 第二个点的纬度，单位：度，范围： `[-90°, 90°]`。

正值对应北纬和东经，负值对应南纬和西经。

**返回值**

地球表面的两点之间的距离，以米为单位。

当输入参数值超出规定的范围时将抛出异常。

**示例**

```
SELECT greatCircleDistance(55.755831, 37.617673, -55.755831, -37.617673)
┌─greatCircleDistance(55.755831, 37.617673, -55.755831, -37.617673)─┐
│                                                14132374.194975413 │
└───────────────────────────────────────────────────────────────────┘
```

#### 尖尖的人

检查指定的点是否至少包含在指定的一个椭圆中。
下述中的坐标是几何图形在笛卡尔坐标系中的位置。

```
pointInEllipses(x, y, x₀, y₀, a₀, b₀,...,xₙ, yₙ, aₙ, bₙ)
```

**输入参数**

- `x, y` — 平面上某个点的坐标。
- `xᵢ, yᵢ` — 第i个椭圆的中心坐标。
- `aᵢ, bᵢ` — 以x, y坐标为单位的第i个椭圆的轴。

输入参数的个数必须是`2+4⋅n`，其中`n`是椭圆的数量。

**返回值**

如果该点至少包含在一个椭圆中，则返回`1`；否则，则返回`0`。

**示例**

```
SELECT pointInEllipses(55.755831, 37.617673, 55.755831, 37.617673, 1.0, 2.0)
┌─pointInEllipses(55.755831, 37.617673, 55.755831, 37.617673, 1., 2.)─┐
│                                                                   1 │
└─────────────────────────────────────────────────────────────────────┘
```

#### pointInPolygon

检查指定的点是否包含在指定的多边形中。

```
pointInPolygon((x, y), [(a, b), (c, d) ...], ...)
```

**输入参数**

- `(x, y)` — 平面上某个点的坐标。元组类型，包含坐标的两个数字。
- `(a, b), (c, d) ...]` — 多边形的顶点。阵列类型。每个顶点由一对坐标`(a, b)`表示。顶点可以按顺时针或逆时针指定。顶点的个数应该大于等于3。同时只能是常量的。
- 该函数还支持镂空的多边形（切除部分）。如果需要，可以使用函数的其他参数定义需要切除部分的多边形。(The function does not support non-simply-connected polygons.)

**返回值**

如果坐标点存在在多边形范围内，则返回`1`。否则返回`0`。
如果坐标位于多边形的边界上，则该函数可能返回`1`，或可能返回`0`。

**示例**

```
SELECT pointInPolygon((3., 3.), [(6, 0), (8, 4), (5, 8), (0, 2)]) AS res
┌─res─┐
│   1 │
└─────┘
```

#### geohashEncode

将经度和纬度编码为geohash-string。

```
geohashEncode(longitude, latitude, [precision])
```

**输入值**

- longitude - 要编码的坐标的经度部分。其值应在`[-180°，180°]`范围内
- latitude - 要编码的坐标的纬度部分。其值应在`[-90°，90°]`范围内
- precision - 可选，生成的geohash-string的长度，默认为`12`。取值范围为`[1,12]`。任何小于`1`或大于`12`的值都会默认转换为`12`。

**返回值**

- 坐标编码的字符串（使用base32编码的修改版本）。

**示例**

```
SELECT geohashEncode(-5.60302734375, 42.593994140625, 0) AS res
┌─res──────────┐
│ ezs42d000000 │
└──────────────┘
```

#### geohashDecode

将任何geohash编码的字符串解码为经度和纬度。

**输入值**

- encoded string - geohash编码的字符串。

**返回值**

- (longitude, latitude) - 经度和纬度的`Float64`值的2元组。

**示例**

```
SELECT geohashDecode(''ezs42'') AS res
┌─res─────────────────────────────┐
│ (-5.60302734375,42.60498046875) │
└─────────────────────────────────┘
```

#### geoToH3

计算指定的分辨率的H3索引`(lon, lat)`。

```
geoToH3(lon, lat, resolution)
```

**输入值**

- `lon` — 经度。 Float64类型。
- `lat` — 纬度。 Float64类型。
- `resolution` — 索引的分辨率。 取值范围为: `0, 15]`。 UInt8类型。

**返回值**

- H3中六边形的索引值。
- 发生异常时返回0。

UInt64类型。

**示例**

```
SELECT geoToH3(37.79506683, 55.71290588, 15) as h3Index
┌────────────h3Index─┐
│ 644325524701193974 │
└────────────────────┘
```

#### geohashesInBox

计算在指定精度下计算最小包含指定的经纬范围的最小图形的geohash数组。

**输入值**

- longitude_min - 最小经度。其值应在`[-180°，180°]`范围内
- latitude_min - 最小纬度。其值应在`[-90°，90°]`范围内
- longitude_max - 最大经度。其值应在`[-180°，180°]`范围内
- latitude_max - 最大纬度。其值应在`[-90°，90°]`范围内
- precision - geohash的精度。其值应在`[1, 12]`内的`UInt8`类型的数字

请注意，上述所有的坐标参数必须同为`Float32`或`Float64`中的一种类型。

**返回值**

- 包含指定范围内的指定精度的geohash字符串数组。注意，您不应该依赖返回数组中geohash的顺序。
- [] - 当传入的最小经纬度大于最大经纬度时将返回一个空数组。

请注意，如果生成的数组长度超过10000时，则函数将抛出异常。

**示例**

```
SELECT geohashesInBox(24.48, 40.56, 24.785, 40.81, 4) AS thasos
┌─thasos──────────────────────────────────────┐
│ [''sx1q'',''sx1r'',''sx32'',''sx1w'',''sx1x'',''sx38''] │
└─────────────────────────────────────────────┘
```
', 0, 1, '2021-06-06 10:26:37', 1, '2021-06-06 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(26, '#### Hash函数

Hash函数可以用于将元素不可逆的伪随机打乱。

#### halfMD5

计算字符串的MD5。然后获取结果的前8个字节并将它们作为UInt64（大端）返回。
此函数相当低效（500万个短字符串/秒/核心）。
如果您不需要一定使用MD5，请使用’sipHash64’函数。

#### MD5

计算字符串的MD5并将结果放入FixedString(16)中返回。
如果您只是需要一个128位的hash，同时不需要一定使用MD5，请使用’sipHash128’函数。
如果您要获得与md5sum程序相同的输出结果，请使用lower(hex(MD5(s)))。

#### sipHash64

计算字符串的SipHash。
接受String类型的参数，返回UInt64。
SipHash是一种加密哈希函数。它的处理性能至少比MD5快三倍。

#### sipHash128

计算字符串的SipHash。
接受String类型的参数，返回FixedString(16)。
与sipHash64函数的不同在于它的最终计算结果为128位。

#### cityHash64

计算任意数量字符串的CityHash64或使用特定实现的Hash函数计算任意数量其他类型的Hash。
对于字符串，使用CityHash算法。 这是一个快速的非加密哈希函数，用于字符串。
对于其他类型的参数，使用特定实现的Hash函数，这是一种快速的非加密的散列函数。
如果传递了多个参数，则使用CityHash组合这些参数的Hash结果。
例如，您可以计算整个表的checksum，其结果取决于行的顺序：`SELECT sum(cityHash64(*)) FROM table`。

#### intHash32

为任何类型的整数计算32位的哈希。
这是相对高效的非加密Hash函数。

#### intHash64

从任何类型的整数计算64位哈希码。
它的工作速度比intHash32函数快。

#### SHA1

#### SHA224

#### SHA256

计算字符串的SHA-1，SHA-224或SHA-256，并将结果字节集返回为FixedString(20)，FixedString(28)或FixedString(32)。
该函数相当低效（SHA-1大约500万个短字符串/秒/核心，而SHA-224和SHA-256大约220万个短字符串/秒/核心）。
我们建议仅在必须使用这些Hash函数且无法更改的情况下使用这些函数。
即使在这些情况下，我们仍建议将函数采用在写入数据时使用预计算的方式将其计算完毕。而不是在SELECT中计算它们。

#### URLHash(url[,N])

一种快速的非加密哈希函数，用于规范化的从URL获得的字符串。
`URLHash(s)` - 从一个字符串计算一个哈希，如果结尾存在尾随符号`/`，`？`或`#`则忽略。
`URLHash（s，N）` - 计算URL层次结构中字符串到N级别的哈希值，如果末尾存在尾随符号`/`，`？`或`#`则忽略。
URL的层级与URLHierarchy中的层级相同。 此函数被用于Yandex.Metrica。

#### farmHash64

计算字符串的FarmHash64。
接受一个String类型的参数。返回UInt64。
有关详细信息，请参阅链接：FarmHash64

#### javaHash

计算字符串的JavaHash。
接受一个String类型的参数。返回Int32。
有关更多信息，请参阅链接：JavaHash

#### hiveHash

计算字符串的HiveHash。
接受一个String类型的参数。返回Int32。
与JavaHash相同，但不会返回负数。

#### metroHash64

计算字符串的MetroHash。
接受一个String类型的参数。返回UInt64。
有关详细信息，请参阅链接：MetroHash64

#### jumpConsistentHash

计算UInt64的JumpConsistentHash。
接受UInt64类型的参数。返回Int32。
有关更多信息，请参见链接：JumpConsistentHash

#### murmurHash2_32,murmurHash2_64

计算字符串的MurmurHash2。
接受一个String类型的参数。返回UInt64或UInt32。
有关更多信息，请参阅链接：MurmurHash2

#### murmurHash3_32,murmurHash3_64,murmurHash3_128

计算字符串的MurmurHash3。
接受一个String类型的参数。返回UInt64或UInt32或FixedString(16)。
有关更多信息，请参阅链接：MurmurHash3

#### xxHash32,xxHash64

计算字符串的xxHash。
接受一个String类型的参数。返回UInt64或UInt32。
有关更多信息，请参见链接：xxHash
', 0, 1, '2021-06-07 10:26:37', 1, '2021-06-07 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(27, '#### IP函数

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

#### ﾂ古ｶﾂ益ﾂ催ﾂ団ﾂ法ﾂ人),

接受一个IPv4地址以及一个UInt8类型的CIDR。返回包含子网最低范围以及最高范围的元组。

```
SELECT IPv4CIDRToRange(toIPv4(''192.168.5.2''), 16)
┌─IPv4CIDRToRange(toIPv4(''192.168.5.2''), 16)─┐
│ (''192.168.0.0'',''192.168.255.255'')          │
└────────────────────────────────────────────┘
```

#### ﾂ暗ｪﾂ氾环催ﾂ団ﾂ法ﾂ人),

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
', 0, 1, '2021-06-08 10:26:37', 1, '2021-06-08 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(28, '#### JSON函数

在Yandex.Metrica中，用户使用JSON作为访问参数。为了处理这些JSON，实现了一些函数。（尽管在大多数情况下，JSON是预先进行额外处理的，并将结果值放在单独的列中。）所有的这些函数都进行了尽可能的假设。以使函数能够尽快的完成工作。

我们对JSON格式做了如下假设：

1. 字段名称（函数的参数）必须使常量。
2. 字段名称必须使用规范的编码。例如：`visitParamHas(''{"abc":"def"}'', ''abc'') = 1`，但是 `visitParamHas(''{"\\u0061\\u0062\\u0063":"def"}'', ''abc'') = 0`
3. 函数可以随意的在多层嵌套结构下查找字段。如果存在多个匹配字段，则返回第一个匹配字段。
4. JSON除字符串文本外不存在空格字符。

#### visitParamHas(参数，名称)

检查是否存在«name»名称的字段

#### visitParamExtractUInt(参数，名称)

将名为«name»的字段的值解析成UInt64。如果这是一个字符串字段，函数将尝试从字符串的开头解析一个数字。如果该字段不存在，或无法从它中解析到数字，则返回0。

#### visitParamExtractInt(参数，名称)

与visitParamExtractUInt相同，但返回Int64。

#### visitParamExtractFloat(参数，名称)

与visitParamExtractUInt相同，但返回Float64。

#### visitParamExtractBool(参数，名称)

解析true/false值。其结果是UInt8类型的。

#### visitParamExtractRaw(参数，名称)

返回字段的值，包含空格符。

示例:

```
visitParamExtractRaw(''{"abc":"\\n\\u0000"}'', ''abc'') = ''"\\n\\u0000"''
visitParamExtractRaw(''{"abc":{"def":[1,2,3]}}'', ''abc'') = ''{"def":[1,2,3]}''
```

#### visitParamExtractString(参数，名称)

使用双引号解析字符串。这个值没有进行转义。如果转义失败，它将返回一个空白字符串。

示例:

```
visitParamExtractString(''{"abc":"\\n\\u0000"}'', ''abc'') = ''\n\0''
visitParamExtractString(''{"abc":"\\u263a"}'', ''abc'') = ''☺''
visitParamExtractString(''{"abc":"\\u263"}'', ''abc'') = ''''
visitParamExtractString(''{"abc":"hello}'', ''abc'') = ''''
```

目前不支持`\uXXXX\uYYYY`这些字符编码，这些编码不在基本多文种平面中（它们被转化为CESU-8而不是UTF-8）。

以下函数基于simdjson，专为更复杂的JSON解析要求而设计。但上述假设2仍然适用。

#### JSONHas(json[, indices_or_keys]…)

如果JSON中存在该值，则返回`1`。

如果该值不存在，则返回`0`。

示例：

```
select JSONHas(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''b'') = 1
select JSONHas(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''b'', 4) = 0
```

`indices_or_keys`可以是零个或多个参数的列表，每个参数可以是字符串或整数。

- String = 按成员名称访问JSON对象成员。
- 正整数 = 从头开始访问第n个成员/成员名称。
- 负整数 = 从末尾访问第n个成员/成员名称。

您可以使用整数来访问JSON数组和JSON对象。

例如：

```
select JSONExtractKey(''{"a": "hello", "b": [-100, 200.0, 300]}'', 1) = ''a''
select JSONExtractKey(''{"a": "hello", "b": [-100, 200.0, 300]}'', 2) = ''b''
select JSONExtractKey(''{"a": "hello", "b": [-100, 200.0, 300]}'', -1) = ''b''
select JSONExtractKey(''{"a": "hello", "b": [-100, 200.0, 300]}'', -2) = ''a''
select JSONExtractString(''{"a": "hello", "b": [-100, 200.0, 300]}'', 1) = ''hello''
```

#### JSONLength(json[, indices_or_keys]…)

返回JSON数组或JSON对象的长度。

如果该值不存在或类型错误，将返回`0`。

示例：

```
select JSONLength(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''b'') = 3
select JSONLength(''{"a": "hello", "b": [-100, 200.0, 300]}'') = 2
```

#### JSONType(json[, indices_or_keys]…)

返回JSON值的类型。

如果该值不存在，将返回`Null`。

示例：

```
select JSONType(''{"a": "hello", "b": [-100, 200.0, 300]}'') = ''Object''
select JSONType(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''a'') = ''String''
select JSONType(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''b'') = ''Array''
```

#### JSONExtractUInt(json[, indices_or_keys]…)

#### JSONExtractInt(json[, indices_or_keys]…)

#### JSONExtractFloat(json[, indices_or_keys]…)

#### JSONExtractBool(json[, indices_or_keys]…)

解析JSON并提取值。这些函数类似于`visitParam*`函数。

如果该值不存在或类型错误，将返回`0`。

示例:

```
select JSONExtractInt(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''b'', 1) = -100
select JSONExtractFloat(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''b'', 2) = 200.0
select JSONExtractUInt(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''b'', -1) = 300
```

#### JSONExtractString(json[, indices_or_keys]…)

解析JSON并提取字符串。此函数类似于`visitParamExtractString`函数。

如果该值不存在或类型错误，则返回空字符串。

该值未转义。如果unescaping失败，则返回一个空字符串。

示例:

```
select JSONExtractString(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''a'') = ''hello''
select JSONExtractString(''{"abc":"\\n\\u0000"}'', ''abc'') = ''\n\0''
select JSONExtractString(''{"abc":"\\u263a"}'', ''abc'') = ''☺''
select JSONExtractString(''{"abc":"\\u263"}'', ''abc'') = ''''
select JSONExtractString(''{"abc":"hello}'', ''abc'') = ''''
```

#### JSONExtract(json[, indices_or_keys…], Return_type)

解析JSON并提取给定ClickHouse数据类型的值。

这是以前的`JSONExtract<type>函数的变体。 这意味着`JSONExtract(…, ‘String’)`返回与`JSONExtractString()`返回完全相同。`JSONExtract(…, ‘Float64’)`返回于`JSONExtractFloat()`返回完全相同。

示例:

```
SELECT JSONExtract(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''Tuple(String, Array(Float64))'') = (''hello'',[-100,200,300])
SELECT JSONExtract(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''Tuple(b Array(Float64), a String)'') = ([-100,200,300],''hello'')
SELECT JSONExtract(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''b'', ''Array(Nullable(Int8))'') = [-100, NULL, NULL]
SELECT JSONExtract(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''b'', 4, ''Nullable(Int64)'') = NULL
SELECT JSONExtract(''{"passed": true}'', ''passed'', ''UInt8'') = 1
SELECT JSONExtract(''{"day": "Thursday"}'', ''day'', ''Enum8(''Sunday'' = 0, ''Monday'' = 1, ''Tuesday'' = 2, ''Wednesday'' = 3, ''Thursday'' = 4, ''Friday'' = 5, ''Saturday'' = 6)'') = ''Thursday''
SELECT JSONExtract(''{"day": 5}'', ''day'', ''Enum8(''Sunday'' = 0, ''Monday'' = 1, ''Tuesday'' = 2, ''Wednesday'' = 3, ''Thursday'' = 4, ''Friday'' = 5, ''Saturday'' = 6)'') = ''Friday''
```

#### JSONExtractKeysAndValues(json[, indices_or_keys…], Value_type)

从JSON中解析键值对，其中值是给定的ClickHouse数据类型。

示例：

```
SELECT JSONExtractKeysAndValues(''{"x": {"a": 5, "b": 7, "c": 11}}'', ''x'', ''Int8'') = [(''a'',5),(''b'',7),(''c'',11)];
```

#### JSONExtractRaw(json[, indices_or_keys]…)

返回JSON的部分。

如果部件不存在或类型错误，将返回空字符串。

示例:

```
select JSONExtractRaw(''{"a": "hello", "b": [-100, 200.0, 300]}'', ''b'') = ''[-100, 200.0, 300]''
```
', 0, 1, '2021-06-09 10:26:37', 1, '2021-06-09 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(29, '#### Nullable处理函数

#### isNull

检查参数是否为NULL。

```
isNull(x)
```

**参数**

- `x` — 一个非复合数据类型的值。

**返回值**

- `1` 如果`x`为`NULL`。
- `0` 如果`x`不为`NULL`。

**示例**

存在以下内容的表

```
┌─x─┬────y─┐
│ 1 │ ᴺᵁᴸᴸ │
│ 2 │    3 │
└───┴──────┘
```

对其进行查询

```
:) SELECT x FROM t_null WHERE isNull(y)

SELECT x
FROM t_null
WHERE isNull(y)

┌─x─┐
│ 1 │
└───┘

1 rows in set. Elapsed: 0.010 sec.
```

#### isNotNull

检查参数是否不为 NULL.

```
isNotNull(x)
```

**参数:**

- `x` — 一个非复合数据类型的值。

**返回值**

- `0` 如果`x`为`NULL`。
- `1` 如果`x`不为`NULL`。

**示例**

存在以下内容的表

```
┌─x─┬────y─┐
│ 1 │ ᴺᵁᴸᴸ │
│ 2 │    3 │
└───┴──────┘
```

对其进行查询

```
:) SELECT x FROM t_null WHERE isNotNull(y)

SELECT x
FROM t_null
WHERE isNotNull(y)

┌─x─┐
│ 2 │
└───┘

1 rows in set. Elapsed: 0.010 sec.
```

#### 合并

检查从左到右是否传递了«NULL»参数并返回第一个非`''NULL`参数。

```
coalesce(x,...)
```

**参数:**

- 任何数量的非复合类型的参数。所有参数必须与数据类型兼容。

**返回值**

- 第一个非’NULL`参数。
- `NULL`，如果所有参数都是’NULL`。

**示例**

考虑可以指定多种联系客户的方式的联系人列表。

```
┌─name─────┬─mail─┬─phone─────┬──icq─┐
│ client 1 │ ᴺᵁᴸᴸ │ 123-45-67 │  123 │
│ client 2 │ ᴺᵁᴸᴸ │ ᴺᵁᴸᴸ      │ ᴺᵁᴸᴸ │
└──────────┴──────┴───────────┴──────┘
```

`mail`和`phone`字段是String类型，但`icq`字段是`UInt32`，所以它需要转换为`String`。

从联系人列表中获取客户的第一个可用联系方式：

```
:) SELECT coalesce(mail, phone, CAST(icq,''Nullable(String)'')) FROM aBook

SELECT coalesce(mail, phone, CAST(icq, ''Nullable(String)''))
FROM aBook

┌─name─────┬─coalesce(mail, phone, CAST(icq, ''Nullable(String)''))─┐
│ client 1 │ 123-45-67                                            │
│ client 2 │ ᴺᵁᴸᴸ                                                 │
└──────────┴──────────────────────────────────────────────────────┘

2 rows in set. Elapsed: 0.006 sec.
```

#### ifNull

如果第一个参数为«NULL»，则返回第二个参数的值。

```
ifNull(x,alt)
```

**参数:**

- `x` — 要检查«NULL»的值。
- `alt` — 如果`x`为’NULL`，函数返回的值。

**返回值**

- 价值 `x`，如果 `x` 不是 `NULL`.
- 价值 `alt`，如果 `x` 是 `NULL`.

**示例**

```
SELECT ifNull(''a'', ''b'')

┌─ifNull(''a'', ''b'')─┐
│ a                │
└──────────────────┘

SELECT ifNull(NULL, ''b'')

┌─ifNull(NULL, ''b'')─┐
│ b                 │
└───────────────────┘
```

#### nullIf

如果参数相等，则返回`NULL`。

```
nullIf(x, y)
```

**参数:**

`x`, `y` — 用于比较的值。 它们必须是类型兼容的，否则将抛出异常。

**返回值**

- 如果参数相等，则为`NULL`。
- 如果参数不相等，则为`x`值。

**示例**

```
SELECT nullIf(1, 1)

┌─nullIf(1, 1)─┐
│         ᴺᵁᴸᴸ │
└──────────────┘

SELECT nullIf(1, 2)

┌─nullIf(1, 2)─┐
│            1 │
└──────────────┘
```

#### assumeNotNull

将可为空类型的值转换为非`Nullable`类型的值。

```
assumeNotNull(x)
```

**参数：**

- `x` — 原始值。

**返回值**

- 如果`x`不为`NULL`，返回非`Nullable`类型的原始值。
- 如果`x`为`NULL`，返回对应非`Nullable`类型的默认值。

**示例**

存在如下`t_null`表。

```
SHOW CREATE TABLE t_null

┌─statement─────────────────────────────────────────────────────────────────┐
│ CREATE TABLE default.t_null ( x Int8,  y Nullable(Int8)) ENGINE = TinyLog │
└───────────────────────────────────────────────────────────────────────────┘

┌─x─┬────y─┐
│ 1 │ ᴺᵁᴸᴸ │
│ 2 │    3 │
└───┴──────┘
```

将列`y`作为`assumeNotNull`函数的参数。

```
SELECT assumeNotNull(y) FROM t_null

┌─assumeNotNull(y)─┐
│                0 │
│                3 │
└──────────────────┘

SELECT toTypeName(assumeNotNull(y)) FROM t_null

┌─toTypeName(assumeNotNull(y))─┐
│ Int8                         │
│ Int8                         │
└──────────────────────────────┘
```

#### 可调整

将参数的类型转换为`Nullable`。

```
toNullable(x)
```

**参数：**

- `x` — 任何非复合类型的值。

**返回值**

- 输入的值，但其类型为`Nullable`。

**示例**

```
SELECT toTypeName(10)

┌─toTypeName(10)─┐
│ UInt8          │
└────────────────┘

SELECT toTypeName(toNullable(10))

┌─toTypeName(toNullable(10))─┐
│ Nullable(UInt8)            │
└────────────────────────────┘
```
', 0, 1, '2021-06-10 10:26:37', 1, '2021-06-10 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(30, '#### URL函数

所有这些功能都不遵循RFC。它们被最大程度简化以提高性能。

#### URL截取函数

如果URL中没有要截取的内容则返回空字符串。

#### 协议

返回URL的协议。例如： http、ftp、mailto、magnet…

#### 域

获取域名。

#### domainwithoutww

返回域名并删除第一个’www.’。

#### topLevelDomain

返回顶级域名。例如：.ru。

#### 第一重要的元素分区域

返回«第一个有效子域名»。这并不是一个标准概念，仅用于Yandex.Metrica。如果顶级域名为’com’，‘net’，‘org’或者‘co’则第一个有效子域名为二级域名。否则则返回三级域名。例如，irstSignificantSubdomain  = ’yandex’， firstSignificantSubdomain = ‘yandex’。一些实现细节在未来可能会进行改变。

#### cutToFirstSignificantSubdomain

返回包含顶级域名与第一个有效子域名之间的内容（请参阅上面的内容）。

例如， `cutToFirstSignificantSubdomain= ''yandex.com.tr''`.

#### 路径

返回URL路径。例如：`/top/news.html`，不包含请求参数。

#### pathFull

与上面相同，但包括请求参数和fragment。例如：/top/news.html?page=2#comments

#### 查询字符串

返回请求参数。例如：page=1&lr=213。请求参数不包含问号已经# 以及# 之后所有的内容。

#### 片段

返回URL的fragment标识。fragment不包含#。

#### querystring andfragment

返回请求参数和fragment标识。例如：page=1#29390。

#### extractURLParameter(URL,name)

返回URL请求参数中名称为’name’的参数。如果不存在则返回一个空字符串。如果存在多个匹配项则返回第一个相匹配的。此函数假设参数名称与参数值在url中的编码方式相同。

#### extractURLParameters(URL)

返回一个数组，其中以name=value的字符串形式返回url的所有请求参数。不以任何编码解析任何内容。

#### extractURLParameterNames(URL)

返回一个数组，其中包含url的所有请求参数的名称。不以任何编码解析任何内容。

#### URLHierarchy(URL)

返回一个数组，其中包含以/切割的URL的所有内容。？将被包含在URL路径以及请求参数中。连续的分割符号被记为一个。

#### Urlpathhierarchy(URL)

与上面相同，但结果不包含协议和host部分。 /element(root)不包括在内。该函数用于在Yandex.Metric中实现导出URL的树形结构。

```
URLPathHierarchy(''https://example.com/browse/CONV-6788'') =
[
    ''/browse/'',
    ''/browse/CONV-6788''
]
```

#### decodeURLComponent(URL)

返回已经解码的URL。
例如:

```
SELECT decodeURLComponent(''http://127.0.0.1:8123/?query=SELECT%201%3B'') AS DecodedURL;
┌─DecodedURL─────────────────────────────┐
│ http://127.0.0.1:8123/?query=SELECT 1; │
└────────────────────────────────────────┘
```

#### 删除URL中的部分内容

如果URL中不包含指定的部分，则URL不变。

#### cutWWW

删除开始的第一个’www.’。

#### cutQueryString

删除请求参数。问号也将被删除。

#### cutFragment

删除fragment标识。#同样也会被删除。

#### cutquerystring andfragment

删除请求参数以及fragment标识。问号以及#也会被删除。

#### cutURLParameter(URL,name)

删除URL中名称为’name’的参数。改函数假设参数名称以及参数值经过URL相同的编码。
', 0, 1, '2021-06-11 10:26:37', 1, '2021-06-11 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(31, '#### UUID函数

下面列出了所有UUID的相关函数

#### generateuidv4

生成一个UUID（版本4）。

```
generateUUIDv4()
```

**返回值**

UUID类型的值。

**使用示例**

此示例演示如何在表中创建UUID类型的列，并对其写入数据。

```
:) CREATE TABLE t_uuid (x UUID) ENGINE=TinyLog

:) INSERT INTO t_uuid SELECT generateUUIDv4()

:) SELECT * FROM t_uuid

┌────────────────────────────────────x─┐
│ f4bf890f-f9dc-4332-ad5c-0c18e73f28e9 │
└──────────────────────────────────────┘
```

#### toUUID(x)

将String类型的值转换为UUID类型的值。

```
toUUID(String)
```

**返回值**

UUID类型的值

**使用示例**

```
:) SELECT toUUID(''61f0c404-5cb3-11e7-907b-a6006ad3dba0'') AS uuid

┌─────────────────────────────────uuid─┐
│ 61f0c404-5cb3-11e7-907b-a6006ad3dba0 │
└──────────────────────────────────────┘
```

#### UUIDStringToNum

接受一个String类型的值，其中包含36个字符且格式为`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`，将其转换为UUID的数值并以固定字符串(16)将其返回。

```
UUIDStringToNum(String)
```

**返回值**

固定字符串(16)

**使用示例**

```
:) SELECT
    ''612f3c40-5d3b-217e-707b-6a546a3d7b29'' AS uuid,
    UUIDStringToNum(uuid) AS bytes

┌─uuid─────────────────────────────────┬─bytes────────────┐
│ 612f3c40-5d3b-217e-707b-6a546a3d7b29 │ a/<@];!~p{jTj={) │
└──────────────────────────────────────┴──────────────────┘
```

#### UUIDNumToString

接受一个固定字符串(16)类型的值，返回其对应的String表现形式。

```
UUIDNumToString(FixedString(16))
```

**返回值**

字符串。

**使用示例**

```
SELECT
    ''a/<@];!~p{jTj={)'' AS bytes,
    UUIDNumToString(toFixedString(bytes, 16)) AS uuid

┌─bytes────────────┬─uuid─────────────────────────────────┐
│ a/<@];!~p{jTj={) │ 612f3c40-5d3b-217e-707b-6a546a3d7b29 │
└──────────────────┴──────────────────────────────────────┘
```
', 0, 1, '2021-06-12 10:26:37', 1, '2021-06-12 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(32, '#### arrayJoin函数

这是一个非常有用的函数。

普通函数不会更改结果集的行数，而只是计算每行中的值（map）。
聚合函数将多行压缩到一行中（fold或reduce）。
’arrayJoin’函数获取每一行并将他们展开到多行（unfold）。

此函数将数组作为参数，并将该行在结果集中复制数组元素个数。
除了应用此函数的列中的值之外，简单地复制列中的所有值;它被替换为相应的数组值。

查询可以使用多个`arrayJoin`函数。在这种情况下，转换被执行多次。

请注意SELECT查询中的ARRAY JOIN语法，它提供了更广泛的可能性。

示例:

```
SELECT arrayJoin([1, 2, 3] AS src) AS dst, ''Hello'', src
┌─dst─┬─''Hello''─┬─src─────┐
│   1 │ Hello     │ [1,2,3] │
│   2 │ Hello     │ [1,2,3] │
│   3 │ Hello     │ [1,2,3] │
└─────┴───────────┴─────────┘
```
', 0, 1, '2021-06-13 10:26:37', 1, '2021-06-13 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(33, '#### 位图函数

位图函数用于对两个位图对象进行计算，对于任何一个位图函数，它都将返回一个位图对象，例如and，or，xor，not等等。

位图对象有两种构造方法。一个是由聚合函数groupBitmapState构造的，另一个是由Array Object构造的。同时还可以将位图对象转化为数组对象。

我们使用RoaringBitmap实际存储位图对象，当基数小于或等于32时，它使用Set保存。当基数大于32时，它使用RoaringBitmap保存。这也是为什么低基数集的存储更快的原因。

有关RoaringBitmap的更多信息，请参阅：RoaringBitmap。

#### bitmapBuild

从无符号整数数组构建位图对象。

```
bitmapBuild(array)
```

**参数**

- `array` – 无符号整数数组.

**示例**

```
SELECT bitmapBuild([1, 2, 3, 4, 5]) AS res
```

#### bitmapToArray

将位图转换为整数数组。

```
bitmapToArray(bitmap)
```

**参数**

- `bitmap` – 位图对象.

**示例**

```
SELECT bitmapToArray(bitmapBuild([1, 2, 3, 4, 5])) AS res
┌─res─────────┐
│ [1,2,3,4,5] │
└─────────────┘
```

#### bitmapSubsetInRange

将位图指定范围（不包含range_end）转换为另一个位图。

```
bitmapSubsetInRange(bitmap, range_start, range_end)
```

**参数**

- `bitmap` – 位图对象.
- `range_start` – 范围起始点（含）.
- `range_end` – 范围结束点（不含）.

**示例**

```
SELECT bitmapToArray(bitmapSubsetInRange(bitmapBuild([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,100,200,500]), toUInt32(30), toUInt32(200))) AS res
┌─res───────────────┐
│ [30,31,32,33,100] │
└───────────────────┘
```

#### bitmapSubsetLimit

将位图指定范围（起始点和数目上限）转换为另一个位图。

```
bitmapSubsetLimit(bitmap, range_start, limit)
```

**参数**

- `bitmap` – 位图对象.
- `range_start` – 范围起始点（含）.
- `limit` – 子位图基数上限.

**示例**

```
SELECT bitmapToArray(bitmapSubsetInRange(bitmapBuild([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,100,200,500]), toUInt32(30), toUInt32(200))) AS res
┌─res───────────────────────┐
│ [30,31,32,33,100,200,500] │
└───────────────────────────┘
```

#### bitmapContains

检查位图是否包含指定元素。

```
bitmapContains(haystack, needle)
```

**参数**

- `haystack` – 位图对象.
- `needle` – 元素，类型UInt32.

**示例**

```
SELECT bitmapContains(bitmapBuild([1,5,7,9]), toUInt32(9)) AS res
┌─res─┐
│  1  │
└─────┘
```

#### bitmapHasAny

与`hasAny(array，array)`类似，如果位图有任何公共元素则返回1，否则返回0。
对于空位图，返回0。

```
bitmapHasAny(bitmap,bitmap)
```

**参数**

- `bitmap` – bitmap对象。

**示例**

```
SELECT bitmapHasAny(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res
┌─res─┐
│  1  │
└─────┘
```

#### bitmapHasAll

与`hasAll(array，array)`类似，如果第一个位图包含第二个位图的所有元素，则返回1，否则返回0。
如果第二个参数是空位图，则返回1。

```
bitmapHasAll(bitmap,bitmap)
```

**参数**

- `bitmap` – bitmap 对象。

**示例**

```
SELECT bitmapHasAll(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res
┌─res─┐
│  0  │
└─────┘
```

#### 位图和

为两个位图对象进行与操作，返回一个新的位图对象。

```
bitmapAnd(bitmap1,bitmap2)
```

**参数**

- `bitmap1` – 位图对象。
- `bitmap2` – 位图对象。

**示例**

```
SELECT bitmapToArray(bitmapAnd(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]))) AS res
┌─res─┐
│ [3] │
└─────┘
```

#### 位图

为两个位图对象进行或操作，返回一个新的位图对象。

```
bitmapOr(bitmap1,bitmap2)
```

**参数**

- `bitmap1` – 位图对象。
- `bitmap2` – 位图对象。

**示例**

```
SELECT bitmapToArray(bitmapOr(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]))) AS res
┌─res─────────┐
│ [1,2,3,4,5] │
└─────────────┘
```

#### bitmapXor

为两个位图对象进行异或操作，返回一个新的位图对象。

```
bitmapXor(bitmap1,bitmap2)
```

**参数**

- `bitmap1` – 位图对象。
- `bitmap2` – 位图对象。

**示例**

```
SELECT bitmapToArray(bitmapXor(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]))) AS res
┌─res───────┐
│ [1,2,4,5] │
└───────────┘
```

#### bitmapAndnot

计算两个位图的差异，返回一个新的位图对象。

```
bitmapAndnot(bitmap1,bitmap2)
```

**参数**

- `bitmap1` – 位图对象。
- `bitmap2` – 位图对象。

**示例**

```
SELECT bitmapToArray(bitmapAndnot(bitmapBuild([1,2,3]),bitmapBuild([3,4,5]))) AS res
┌─res───┐
│ [1,2] │
└───────┘
```

#### bitmapCardinality

返回一个UInt64类型的数值，表示位图对象的基数。

```
bitmapCardinality(bitmap)
```

**参数**

- `bitmap` – 位图对象。

**示例**

```
SELECT bitmapCardinality(bitmapBuild([1, 2, 3, 4, 5])) AS res
┌─res─┐
│   5 │
└─────┘
```

#### bitmapMin

返回一个UInt64类型的数值，表示位图中的最小值。如果位图为空则返回UINT32_MAX。

```
bitmapMin(bitmap)
```

**参数**

- `bitmap` – 位图对象。

**示例**

```
SELECT bitmapMin(bitmapBuild([1, 2, 3, 4, 5])) AS res
┌─res─┐
│   1 │
└─────┘
```

#### bitmapMax

返回一个UInt64类型的数值，表示位图中的最大值。如果位图为空则返回0。

```
bitmapMax(bitmap)
```

**参数**

- `bitmap` – 位图对象。

**示例**

```
SELECT bitmapMax(bitmapBuild([1, 2, 3, 4, 5])) AS res
┌─res─┐
│   5 │
└─────┘
```

#### 位图和标准性

为两个位图对象进行与操作，返回结果位图的基数。

```
bitmapAndCardinality(bitmap1,bitmap2)
```

**参数**

- `bitmap1` – 位图对象。
- `bitmap2` – 位图对象。

**示例**

```
SELECT bitmapAndCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res;
┌─res─┐
│   1 │
└─────┘
```

#### bitmapOrCardinality

为两个位图进行或运算，返回结果位图的基数。

```
bitmapOrCardinality(bitmap1,bitmap2)
```

**参数**

- `bitmap1` – 位图对象。
- `bitmap2` – 位图对象。

**示例**

```
SELECT bitmapOrCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res;
┌─res─┐
│   5 │
└─────┘
```

#### bitmapXorCardinality

为两个位图进行异或运算，返回结果位图的基数。

```
bitmapXorCardinality(bitmap1,bitmap2)
```

**参数**

- `bitmap1` – 位图对象。
- `bitmap2` – 位图对象。

**示例**

```
SELECT bitmapXorCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res;
┌─res─┐
│   4 │
└─────┘
```

#### 位图和非标准性

计算两个位图的差异，返回结果位图的基数。

```
bitmapAndnotCardinality(bitmap1,bitmap2)
```

**参数**

- `bitmap1` – 位图对象。
- `bitmap2` - 位图对象。

**示例**

```
SELECT bitmapAndnotCardinality(bitmapBuild([1,2,3]),bitmapBuild([3,4,5])) AS res;
┌─res─┐
│   2 │
└─────┘
```
', 0, 1, '2021-06-14 10:26:37', 1, '2021-06-14 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(34, '#### 位操作函数

位操作函数适用于UInt8，UInt16，UInt32，UInt64，Int8，Int16，Int32，Int64，Float32或Float64中的任何类型。

结果类型是一个整数，其位数等于其参数的最大位。如果至少有一个参数为有符数字，则结果为有符数字。如果参数是浮点数，则将其强制转换为Int64。

#### bitAnd(a,b)

#### bitOr(a,b)

#### bitXor(a,b)

#### bitNot(a)

#### bitShiftLeft(a,b)

#### bitShiftRight(a,b)

#### bitRotateLeft(a,b)

#### bitRotateRight(a,b)

#### bitTest(a,b)

#### bitTestAll(a,b)

#### bitTestAny(a,b)
', 0, 1, '2021-06-15 10:26:37', 1, '2021-06-15 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(35, '#### 其他函数

#### 主机名()

返回一个字符串，其中包含执行此函数的主机的名称。 对于分布式处理，如果在远程服务器上执行此函数，则将返回远程服务器主机的名称。

#### basename

在最后一个斜杠或反斜杠后的字符串文本。 此函数通常用于从路径中提取文件名。

```
basename( expr )
```

**参数**

- `expr` — 任何一个返回字符串

**返回值**

一个String类型的值，其包含：

- 在最后一个斜杠或反斜杠后的字符串文本内容。

  ```
  如果输入的字符串以斜杆或反斜杆结尾，例如：`/`或`c:\`，函数将返回一个空字符串。
  ```

- 如果输入的字符串中不包含斜杆或反斜杠，函数返回输入字符串本身。

**示例**

```
SELECT ''some/long/path/to/file'' AS a, basename(a)
┌─a──────────────────────┬─basename(''some\\long\\path\\to\\file'')─┐
│ some\long\path\to\file │ file                                   │
└────────────────────────┴────────────────────────────────────────┘
SELECT ''some\\long\\path\\to\\file'' AS a, basename(a)
┌─a──────────────────────┬─basename(''some\\long\\path\\to\\file'')─┐
│ some\long\path\to\file │ file                                   │
└────────────────────────┴────────────────────────────────────────┘
SELECT ''some-file-name'' AS a, basename(a)
┌─a──────────────┬─basename(''some-file-name'')─┐
│ some-file-name │ some-file-name             │
└────────────────┴────────────────────────────┘
```

#### visibleWidth(x)

以文本格式（以制表符分隔）向控制台输出值时，计算近似宽度。
系统使用此函数实现Pretty格式。
以文本格式（制表符分隔）将值输出到控制台时，计算近似宽度。
这个函数被系统用于实现漂亮的格式。

`NULL` 表示为对应于 `NULL` 在 `Pretty` 格式。

```
SELECT visibleWidth(NULL)

┌─visibleWidth(NULL)─┐
│                  4 │
└────────────────────┘
```

#### toTypeName(x)

返回包含参数的类型名称的字符串。

如果将`NULL`作为参数传递给函数，那么它返回`Nullable（Nothing）`类型，它对应于ClickHouse中的内部`NULL`。

#### 块大小()

获取Block的大小。
在ClickHouse中，查询始终工作在Block（包含列的部分的集合）上。此函数允许您获取调用其的块的大小。

#### 实现(x)

将一个常量列变为一个非常量列。
在ClickHouse中，非常量列和常量列在内存中的表示方式不同。尽管函数对于常量列和非常量总是返回相同的结果，但它们的工作方式可能完全不同（执行不同的代码）。此函数用于调试这种行为。

#### ignore(…)

接受任何参数，包括`NULL`。始终返回0。
但是，函数的参数总是被计算的。该函数可以用于基准测试。

#### 睡眠（秒)

在每个Block上休眠’seconds’秒。可以是整数或浮点数。

#### sleepEachRow（秒)

在每行上休眠’seconds’秒。可以是整数或浮点数。

#### 当前数据库()

返回当前数据库的名称。
当您需要在CREATE TABLE中的表引擎参数中指定数据库，您可以使用此函数。

#### isFinite(x)

接受Float32或Float64类型的参数，如果参数不是infinite且不是NaN，则返回1，否则返回0。

#### isInfinite(x)

接受Float32或Float64类型的参数，如果参数是infinite，则返回1，否则返回0。注意NaN返回0。

#### isNaN(x)

接受Float32或Float64类型的参数，如果参数是Nan，则返回1，否则返回0。

#### hasColumnInTable([‘hostname’[, ‘username’[, ‘password’]],] ‘database’, ‘table’, ‘column’)

接受常量字符串：数据库名称、表名称和列名称。 如果存在列，则返回等于1的UInt8常量表达式，否则返回0。 如果设置了hostname参数，则测试将在远程服务器上运行。
如果表不存在，该函数将引发异常。
对于嵌套数据结构中的元素，该函数检查是否存在列。 对于嵌套数据结构本身，函数返回0。

#### 酒吧

使用unicode构建图表。

`bar(x, min, max, width)` 当`x = max`时， 绘制一个宽度与`(x - min)`成正比且等于`width`的字符带。

参数:

- `x` — 要显示的尺寸。
- `min, max` — 整数常量，该值必须是`Int64`。
- `width` — 常量，可以是正整数或小数。

字符带的绘制精度是符号的八分之一。

示例:

```
SELECT
    toHour(EventTime) AS h,
    count() AS c,
    bar(c, 0, 600000, 20) AS bar
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

#### 变换

根据定义，将某些元素转换为其他元素。
此函数有两种使用方式：

1. `transform(x, array_from, array_to, default)`

`x` – 要转换的值。

`array_from` – 用于转换的常量数组。

`array_to` – 将’from’中的值转换为的常量数组。

`default` – 如果’x’不等于’from’中的任何值，则默认转换的值。

`array_from` 和 `array_to` – 拥有相同大小的数组。

类型约束:

```
transform(T, Array(T), Array(U), U) -> U
```

`T`和`U`可以是String，Date，DateTime或任意数值类型的。
对于相同的字母（T或U），如果数值类型，那么它们不可不完全匹配的，只需要具备共同的类型即可。
例如，第一个参数是Int64类型，第二个参数是Array(UInt16)类型。

如果’x’值等于’array_from’数组中的一个元素，它将从’array_to’数组返回一个对应的元素（下标相同）。否则，它返回’default’。如果’array_from’匹配到了多个元素，则返回第一个匹配的元素。

示例:

```
SELECT
    transform(SearchEngineID, [2, 3], [''Yandex'', ''Google''], ''Other'') AS title,
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

1. `transform(x, array_from, array_to)`

与第一种不同在于省略了’default’参数。
如果’x’值等于’array_from’数组中的一个元素，它将从’array_to’数组返回相应的元素（下标相同）。 否则，它返回’x’。

类型约束:

```
transform(T, Array(T), Array(T)) -> T
```

示例:

```
SELECT
    transform(domain(Referer), [''yandex.ru'', ''google.ru'', ''vk.com''], [''www.yandex'', ''example.com'']) AS s,
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

#### formatReadableSize(x)

接受大小（字节数）。返回带有后缀（KiB, MiB等）的字符串。

示例:

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

#### 至少(a,b)

返回a和b中的最小值。

#### 最伟大(a,b)

返回a和b的最大值。

#### 碌莽禄time拢time()

返回服务正常运行的秒数。

#### 版本()

以字符串形式返回服务器的版本。

#### 时区()

返回服务器的时区。

#### blockNumber

返回行所在的Block的序列号。

#### rowNumberInBlock

返回行所在Block中行的序列号。 针对不同的Block始终重新计算。

#### rowNumberInAllBlocks()

返回行所在结果集中的序列号。此函数仅考虑受影响的Block。

#### 运行差异(x)

计算数据块中相邻行的值之间的差异。
对于第一行返回0，并为每个后续行返回与前一行的差异。

函数的结果取决于受影响的Block和Block中的数据顺序。
如果使用ORDER BY创建子查询并从子查询外部调用该函数，则可以获得预期结果。

示例:

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
    WHERE EventDate = ''2016-11-24''
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

#### 运行差异启动与第一值

与运行差异相同，区别在于第一行返回第一行的值，后续每个后续行返回与上一行的差值。

#### MACNumToString(num)

接受一个UInt64类型的数字。 将其解释为big endian的MAC地址。 返回包含相应MAC地址的字符串，格式为AA:BB:CC:DD:EE:FF（以冒号分隔的十六进制形式的数字）。

#### MACStringToNum(s)

与MACNumToString相反。 如果MAC地址格式无效，则返回0。

#### MACStringToOUI(s)

接受格式为AA:BB:CC:DD:EE:FF（十六进制形式的冒号分隔数字）的MAC地址。 返回前三个八位字节作为UInt64编号。 如果MAC地址格式无效，则返回0。

#### getSizeOfEnumType

返回枚举中的枚举数量。

```
getSizeOfEnumType(value)
```

**参数:**

- `value` — `Enum`类型的值。

**返回值**

- `Enum`的枚举数量。
- 如果类型不是`Enum`，则抛出异常。

**示例**

```
SELECT getSizeOfEnumType( CAST(''a'' AS Enum8(''a'' = 1, ''b'' = 2) ) ) AS x

┌─x─┐
│ 2 │
└───┘
```

#### toColumnTypeName

返回在RAM中列的数据类型的名称。

```
toColumnTypeName(value)
```

**参数:**

- `value` — 任何类型的值。

**返回值**

- 一个字符串，其内容是`value`在RAM中的类型名称。

**toTypeName '' 与 '' toColumnTypeName的区别示例**

```
:) select toTypeName(cast(''2018-01-01 01:02:03'' AS DateTime))

SELECT toTypeName(CAST(''2018-01-01 01:02:03'', ''DateTime''))

┌─toTypeName(CAST(''2018-01-01 01:02:03'', ''DateTime''))─┐
│ DateTime                                            │
└─────────────────────────────────────────────────────┘

1 rows in set. Elapsed: 0.008 sec.

:) select toColumnTypeName(cast(''2018-01-01 01:02:03'' AS DateTime))

SELECT toColumnTypeName(CAST(''2018-01-01 01:02:03'', ''DateTime''))

┌─toColumnTypeName(CAST(''2018-01-01 01:02:03'', ''DateTime''))─┐
│ Const(UInt32)                                             │
└───────────────────────────────────────────────────────────┘
```

该示例显示`DateTime`数据类型作为`Const(UInt32)`存储在内存中。

#### dumpColumnStructure

输出在RAM中的数据结果的详细信息。

```
dumpColumnStructure(value)
```

**参数:**

- `value` — 任何类型的值.

**返回值**

- 一个字符串，其内容是`value`在RAM中的数据结构的详细描述。

**示例**

```
SELECT dumpColumnStructure(CAST(''2018-01-01 01:02:03'', ''DateTime''))

┌─dumpColumnStructure(CAST(''2018-01-01 01:02:03'', ''DateTime''))─┐
│ DateTime, Const(size = 1, UInt32(size = 1))                  │
└──────────────────────────────────────────────────────────────┘
```

#### defaultValueOfArgumentType

输出数据类型的默认值。

不包括用户设置的自定义列的默认值。

```
defaultValueOfArgumentType(expression)
```

**参数:**

- `expression` — 任意类型的值或导致任意类型值的表达式。

**返回值**

- 数值类型返回`0`。
- 字符串类型返回空的字符串。
- 可为空类型返回`ᴺᵁᴸᴸ`。

**示例**

```
:) SELECT defaultValueOfArgumentType( CAST(1 AS Int8) )

SELECT defaultValueOfArgumentType(CAST(1, ''Int8''))

┌─defaultValueOfArgumentType(CAST(1, ''Int8''))─┐
│                                           0 │
└─────────────────────────────────────────────┘

1 rows in set. Elapsed: 0.002 sec.

:) SELECT defaultValueOfArgumentType( CAST(1 AS Nullable(Int8) ) )

SELECT defaultValueOfArgumentType(CAST(1, ''Nullable(Int8)''))

┌─defaultValueOfArgumentType(CAST(1, ''Nullable(Int8)''))─┐
│                                                  ᴺᵁᴸᴸ │
└───────────────────────────────────────────────────────┘

1 rows in set. Elapsed: 0.002 sec.
```

#### indexHint

输出符合索引选择范围内的所有数据，同时不实用参数中的表达式进行过滤。

传递给函数的表达式参数将不会被计算，但ClickHouse使用参数中的表达式进行索引过滤。

**返回值**

- 1。

**示例**

这是一个包含ontime测试数据集的测试表。

```
SELECT count() FROM ontime

┌─count()─┐
│ 4276457 │
└─────────┘
```

该表使用`(FlightDate, (Year, FlightDate))`作为索引。

对该表进行如下的查询：

```
:) SELECT FlightDate AS k, count() FROM ontime GROUP BY k ORDER BY k

SELECT
    FlightDate AS k,
    count()
FROM ontime
GROUP BY k
ORDER BY k ASC

┌──────────k─┬─count()─┐
│ 2017-01-01 │   13970 │
│ 2017-01-02 │   15882 │
........................
│ 2017-09-28 │   16411 │
│ 2017-09-29 │   16384 │
│ 2017-09-30 │   12520 │
└────────────┴─────────┘

273 rows in set. Elapsed: 0.072 sec. Processed 4.28 million rows, 8.55 MB (59.00 million rows/s., 118.01 MB/s.)
```

在这个查询中，由于没有使用索引，所以ClickHouse将处理整个表的所有数据(`Processed 4.28 million rows`)。使用下面的查询尝试使用索引进行查询：

```
:) SELECT FlightDate AS k, count() FROM ontime WHERE k = ''2017-09-15'' GROUP BY k ORDER BY k

SELECT
    FlightDate AS k,
    count()
FROM ontime
WHERE k = ''2017-09-15''
GROUP BY k
ORDER BY k ASC

┌──────────k─┬─count()─┐
│ 2017-09-15 │   16428 │
└────────────┴─────────┘

1 rows in set. Elapsed: 0.014 sec. Processed 32.74 thousand rows, 65.49 KB (2.31 million rows/s., 4.63 MB/s.)
```

在最后一行的显示中，通过索引ClickHouse处理的行数明显减少（`Processed 32.74 thousand rows`）。

现在将表达式`k = ''2017-09-15''`传递给`indexHint`函数：

```
:) SELECT FlightDate AS k, count() FROM ontime WHERE indexHint(k = ''2017-09-15'') GROUP BY k ORDER BY k

SELECT
    FlightDate AS k,
    count()
FROM ontime
WHERE indexHint(k = ''2017-09-15'')
GROUP BY k
ORDER BY k ASC

┌──────────k─┬─count()─┐
│ 2017-09-14 │    7071 │
│ 2017-09-15 │   16428 │
│ 2017-09-16 │    1077 │
│ 2017-09-30 │    8167 │
└────────────┴─────────┘

4 rows in set. Elapsed: 0.004 sec. Processed 32.74 thousand rows, 65.49 KB (8.97 million rows/s., 17.94 MB/s.)
```

对于这个请求，根据ClickHouse显示ClickHouse与上一次相同的方式应用了索引（`Processed 32.74 thousand rows`）。但是，最终返回的结果集中并没有根据`k = ''2017-09-15''`表达式进行过滤结果。

由于ClickHouse中使用稀疏索引，因此在读取范围时（本示例中为相邻日期），"额外"的数据将包含在索引结果中。使用`indexHint`函数可以查看到它们。

#### 复制

使用单个值填充一个数组。

用于arrayJoin的内部实现。

```
replicate(x, arr)
```

**参数:**

- `arr` — 原始数组。 ClickHouse创建一个与原始数据长度相同的新数组，并用值`x`填充它。
- `x` — 生成的数组将被填充的值。

**输出**

- 一个被`x`填充的数组。

**示例**

```
SELECT replicate(1, [''a'', ''b'', ''c''])

┌─replicate(1, [''a'', ''b'', ''c''])─┐
│ [1,1,1]                       │
└───────────────────────────────┘
```

#### 文件系统可用

返回磁盘的剩余空间信息（以字节为单位）。使用配置文件中的path配置评估此信息。

#### 文件系统容量

返回磁盘的容量信息，以字节为单位。使用配置文件中的path配置评估此信息。

#### 最后聚会

获取聚合函数的状态。返回聚合结果（最终状态）。

#### 跑累积

获取聚合函数的状态并返回其具体的值。这是从第一行到当前行的所有行累计的结果。

例如，获取聚合函数的状态（示例runningAccumulate(uniqState(UserID))），对于数据块的每一行，返回所有先前行和当前行的状态合并后的聚合函数的结果。
因此，函数的结果取决于分区中数据块的顺序以及数据块中行的顺序。

#### joinGet(‘join_storage_table_name’, ‘get_column’,join_key)

使用指定的连接键从Join类型引擎的表中获取数据。

#### modelEvaluate(model_name, …)

使用外部模型计算。
接受模型的名称以及模型的参数。返回Float64类型的值。

#### throwIf(x)

如果参数不为零则抛出异常。
', 0, 1, '2021-06-16 10:26:37', 1, '2021-06-16 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(36, '#### 功能与Yandex的工作。梅特里卡词典

为了使下面的功能正常工作，服务器配置必须指定获取所有Yandex的路径和地址。梅特里卡字典. 字典在任何这些函数的第一次调用时加载。 如果无法加载引用列表，则会引发异常。

For information about creating reference lists, see the section «Dictionaries».

#### 多个地理基

ClickHouse支持同时使用多个备选地理基（区域层次结构），以支持某些地区所属国家的各种观点。

该 ‘clickhouse-server’ config指定具有区域层次结构的文件::`<path_to_regions_hierarchy_file>/opt/geo/regions_hierarchy.txt</path_to_regions_hierarchy_file>`

除了这个文件，它还搜索附近有_符号和任何后缀附加到名称（文件扩展名之前）的文件。
例如，它还会找到该文件 `/opt/geo/regions_hierarchy_ua.txt`，如果存在。

`ua` 被称为字典键。 对于没有后缀的字典，键是空字符串。

所有字典都在运行时重新加载（每隔一定数量的秒重新加载一次，如builtin_dictionaries_reload_interval config参数中定义，或默认情况下每小时一次）。 但是，可用字典列表在服务器启动时定义一次。

All functions for working with regions have an optional argument at the end – the dictionary key. It is referred to as the geobase.
示例:

```
regionToCountry(RegionID) – Uses the default dictionary: /opt/geo/regions_hierarchy.txt
regionToCountry(RegionID, '''') – Uses the default dictionary: /opt/geo/regions_hierarchy.txt
regionToCountry(RegionID, ''ua'') – Uses the dictionary for the ''ua'' key: /opt/geo/regions_hierarchy_ua.txt
```

#### ﾂ环板(ｮﾂ嘉ｯﾂ偲青regionｼﾂ氾ｶﾂ鉄ﾂ工ﾂ渉])

Accepts a UInt32 number – the region ID from the Yandex geobase. If this region is a city or part of a city, it returns the region ID for the appropriate city. Otherwise, returns 0.

#### 虏茅驴麓卤戮碌禄路戮鲁拢])

将区域转换为区域（地理数据库中的类型5）。 在所有其他方式，这个功能是一样的 ‘regionToCity’.

```
SELECT DISTINCT regionToName(regionToArea(toUInt32(number), ''ua''))
FROM system.numbers
LIMIT 15
┌─regionToName(regionToArea(toUInt32(number), ''ua''))─┐
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

#### regionToDistrict(id[,geobase])

将区域转换为联邦区（地理数据库中的类型4）。 在所有其他方式，这个功能是一样的 ‘regionToCity’.

```
SELECT DISTINCT regionToName(regionToDistrict(toUInt32(number), ''ua''))
FROM system.numbers
LIMIT 15
┌─regionToName(regionToDistrict(toUInt32(number), ''ua''))─┐
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

#### 虏茅驴麓卤戮碌禄路戮鲁拢(陆毛隆隆(803)888-8325])

将区域转换为国家。 在所有其他方式，这个功能是一样的 ‘regionToCity’.
示例: `regionToCountry(toUInt32(213)) = 225` 转换莫斯科（213）到俄罗斯（225）。

#### 掳胫((禄脢鹿脷露胫鲁隆鹿((酶-11-16""[脪陆,ase])

将区域转换为大陆。 在所有其他方式，这个功能是一样的 ‘regionToCity’.
示例: `regionToContinent(toUInt32(213)) = 10001` 将莫斯科（213）转换为欧亚大陆（10001）。

#### ﾂ环板(ｮﾂ嘉ｯﾂ偲青regionｬﾂ静ｬﾂ青ｻﾂ催ｬﾂ渉])

获取区域的人口。
The population can be recorded in files with the geobase. See the section «External dictionaries».
如果没有为该区域记录人口，则返回0。
在Yandex地理数据库中，可能会为子区域记录人口，但不会为父区域记录人口。

#### regionIn(lhs,rhs[,地理数据库])

检查是否 ‘lhs’ 属于一个区域 ‘rhs’ 区域。 如果属于UInt8，则返回等于1的数字，如果不属于则返回0。
The relationship is reflexive – any region also belongs to itself.

#### ﾂ暗ｪﾂ氾环催ﾂ団ﾂ法ﾂ人])

Accepts a UInt32 number – the region ID from the Yandex geobase. Returns an array of region IDs consisting of the passed region and all parents along the chain.
示例: `regionHierarchy(toUInt32(213)) = [213,1,3,225,10001,10000]`.

#### 地区名称(id[,郎])

Accepts a UInt32 number – the region ID from the Yandex geobase. A string with the name of the language can be passed as a second argument. Supported languages are: ru, en, ua, uk, by, kz, tr. If the second argument is omitted, the language ‘ru’ is used. If the language is not supported, an exception is thrown. Returns a string – the name of the region in the corresponding language. If the region with the specified ID doesn’t exist, an empty string is returned.

`ua` 和 `uk` 都意味着乌克兰。
', 0, 1, '2021-06-17 10:26:37', 1, '2021-06-17 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(37, '#### 取整函数

#### 楼(x[,N])

返回小于或等于x的最大舍入数。该函数使用参数乘1/10N，如果1/10N不精确，则选择最接近的精确的适当数据类型的数。
’N’是一个整数常量，可选参数。默认为0，这意味着不对其进行舍入。
’N’可以是负数。

示例: `floor(123.45, 1) = 123.4, floor(123.45, -1) = 120.`

`x`是任何数字类型。结果与其为相同类型。
对于整数参数，使用负’N’值进行舍入是有意义的（对于非负«N»，该函数不执行任何操作）。
如果取整导致溢出（例如，floor(-128，-1)），则返回特定于实现的结果。

#### ceil(x[,N]),天花板(x[,N])

返回大于或等于’x’的最小舍入数。在其他方面，它与’floor’功能相同（见上文）。

#### 圆形(x[,N])

将值取整到指定的小数位数。

该函数按顺序返回最近的数字。如果给定数字包含多个最近数字，则函数返回其中最接近偶数的数字（银行的取整方式）。

```
round(expression [, decimal_places])
```

**参数：**

- `expression` — 要进行取整的数字。可以是任何返回数字类型。

- ```
  decimal-places
  ```



  — 整数类型。

  - 如果`decimal-places > 0`，则该函数将值舍入小数点右侧。
  - 如果`decimal-places < 0`，则该函数将小数点左侧的值四舍五入。
  - 如果`decimal-places = 0`，则该函数将该值舍入为整数。在这种情况下，可以省略参数。

**返回值：**

与输入数字相同类型的取整后的数字。

#### 示例

**使用示例**

```
SELECT number / 2 AS x, round(x) FROM system.numbers LIMIT 3
┌───x─┬─round(divide(number, 2))─┐
│   0 │                        0 │
│ 0.5 │                        0 │
│   1 │                        1 │
└─────┴──────────────────────────┘
```

**取整的示例**

取整到最近的数字。

```
round(3.2, 0) = 3
round(4.1267, 2) = 4.13
round(22,-1) = 20
round(467,-2) = 500
round(-467,-2) = -500
```

银行的取整。

```
round(3.5) = 4
round(4.5) = 4
round(3.55, 1) = 3.6
round(3.65, 1) = 3.6
```

#### roundToExp2(num)

接受一个数字。如果数字小于1，则返回0。否则，它将数字向下舍入到最接近的（整个非负）2的x次幂。

#### 圆形饱和度(num)

接受一个数字。如果数字小于1，则返回0。否则，它将数字向下舍入为集合中的数字：1，10，30，60，120，180，240，300，600，1200，1800，3600，7200，18000，36000。此函数用于Yandex.Metrica报表中计算会话的持续时长。

#### 圆数(num)

接受一个数字。如果数字小于18，则返回0。否则，它将数字向下舍入为集合中的数字：18，25，35，45，55。此函数用于Yandex.Metrica报表中用户年龄的计算。

#### roundDown(num,arr)

接受一个数字，将其向下舍入到指定数组中的元素。如果该值小于数组中的最低边界，则返回最低边界。
', 0, 1, '2021-06-18 10:26:37', 1, '2021-06-18 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(38, '#### 字典函数

有关连接和配置外部词典的信息，请参阅外部词典。

#### dictGetUInt8,dictGetUInt16,dictGetUInt32,dictGetUInt64

#### dictGetInt8,dictGetInt16,dictGetInt32,dictGetInt64

#### dictGetFloat32,dictGetFloat64

#### dictGetDate,dictGetDateTime

#### dictgetuid

#### dictGetString

```
dictGetT(''dict_name'', ''attr_name'', id)
```

- 使用’id’键获取dict_name字典中attr_name属性的值。`dict_name`和`attr_name`是常量字符串。`id`必须是UInt64。
  如果字典中没有`id`键，则返回字典描述中指定的默认值。

#### dictGetTOrDefault

```
dictGetTOrDefault(''dict_name'', ''attr_name'', id, default)
```

与`dictGetT`函数相同，但默认值取自函数的最后一个参数。

#### dictIsIn

```
dictIsIn (''dict_name'', child_id, ancestor_id)
```

- 对于’dict_name’分层字典，查找’child_id’键是否位于’ancestor_id’内（或匹配’ancestor_id’）。返回UInt8。

#### 独裁主义

```
dictGetHierarchy(''dict_name'', id)
```

- 对于’dict_name’分层字典，返回从’id’开始并沿父元素链继续的字典键数组。返回Array（UInt64）

#### dictHas

```
dictHas(''dict_name'', id)
```

- 检查字典是否存在指定的`id`。如果不存在，则返回0;如果存在，则返回1。
', 0, 1, '2021-06-19 10:26:37', 1, '2021-06-19 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(39, '#### 字符串函数

#### empty

对于空字符串返回1，对于非空字符串返回0。
结果类型是UInt8。
如果字符串包含至少一个字节，则该字符串被视为非空字符串，即使这是一个空格或空字符。
该函数也适用于数组。

#### notEmpty

对于空字符串返回0，对于非空字符串返回1。
结果类型是UInt8。
该函数也适用于数组。

#### length

返回字符串的字节长度。
结果类型是UInt64。
该函数也适用于数组。

#### lengthUTF8

假定字符串以UTF-8编码组成的文本，返回此字符串的Unicode字符长度。如果传入的字符串不是UTF-8编码，则函数可能返回一个预期外的值（不会抛出异常）。
结果类型是UInt64。

#### char_length,CHAR_LENGTH

假定字符串以UTF-8编码组成的文本，返回此字符串的Unicode字符长度。如果传入的字符串不是UTF-8编码，则函数可能返回一个预期外的值（不会抛出异常）。
结果类型是UInt64。

#### character_length,CHARACTER_LENGTH

假定字符串以UTF-8编码组成的文本，返回此字符串的Unicode字符长度。如果传入的字符串不是UTF-8编码，则函数可能返回一个预期外的值（不会抛出异常）。
结果类型是UInt64。

#### lower, lcase

将字符串中的ASCII转换为小写。

#### upper, ucase

将字符串中的ASCII转换为大写。

#### lowerUTF8

将字符串转换为小写，函数假设字符串是以UTF-8编码文本的字符集。
同时函数不检测语言。因此对土耳其人来说，结果可能不完全正确。
如果UTF-8字节序列的长度对于代码点的大写和小写不同，则该代码点的结果可能不正确。
如果字符串包含一组非UTF-8的字节，则将引发未定义行为。

#### upperUTF8

将字符串转换为大写，函数假设字符串是以UTF-8编码文本的字符集。
同时函数不检测语言。因此对土耳其人来说，结果可能不完全正确。
如果UTF-8字节序列的长度对于代码点的大写和小写不同，则该代码点的结果可能不正确。
如果字符串包含一组非UTF-8的字节，则将引发未定义行为。

#### isValidUTF8

检查字符串是否为有效的UTF-8编码，是则返回1，否则返回0。

#### toValidUTF8

用`�`（U+FFFD）字符替换无效的UTF-8字符。所有连续的无效字符都会被替换为一个替换字符。

```
toValidUTF8( input_string )
```

参数：

- input_string — 任何一个字符串类型的对象。

返回值： 有效的UTF-8字符串。

#### 示例

```
SELECT toValidUTF8(''\x61\xF0\x80\x80\x80b'')
┌─toValidUTF8(''a����b'')─┐
│ a�b                   │
└───────────────────────┘
```

#### reverse

反转字符串。

#### reverseUTF8

以Unicode字符为单位反转UTF-8编码的字符串。如果字符串不是UTF-8编码，则可能获取到一个非预期的结果（不会抛出异常）。

#### format(pattern, s0, s1, …)

使用常量字符串`pattern`格式化其他参数。`pattern`字符串中包含由大括号`{}`包围的«替换字段»。 未被包含在大括号中的任何内容都被视为文本内容，它将原样保留在返回值中。 如果你需要在文本内容中包含一个大括号字符，它可以通过加倍来转义：`{{`和`{{ ''}}'' }}`。 字段名称可以是数字（从零开始）或空（然后将它们视为连续数字）

```
SELECT format(''{1} {0} {1}'', ''World'', ''Hello'')

┌─format(''{1} {0} {1}'', ''World'', ''Hello'')─┐
│ Hello World Hello                       │
└─────────────────────────────────────────┘

SELECT format(''{} {}'', ''Hello'', ''World'')

┌─format(''{} {}'', ''Hello'', ''World'')─┐
│ Hello World                       │
└───────────────────────────────────┘
```

#### concat(s1, s2, …)

将参数中的多个字符串拼接，不带分隔符。

#### concatAssumeInjective(s1, s2, …)

与concat相同，区别在于，你需要保证concat(s1, s2, s3) -> s4是单射的，它将用于GROUP BY的优化。

#### substring(s,offset,length),mid(s,offset,length),substr(s,offset,length)

以字节为单位截取指定位置字符串，返回以’offset’位置为开头，长度为’length’的子串。’offset’从1开始（与标准SQL相同）。’offset’和’length’参数必须是常量。

#### substringUTF8(s,offset,length)

与’substring’相同，但其操作单位为Unicode字符，函数假设字符串是以UTF-8进行编码的文本。如果不是则可能返回一个预期外的结果（不会抛出异常）。

#### appendTrailingCharIfAbsent(s,c)

如果’s’字符串非空并且末尾不包含’c’字符，则将’c’字符附加到末尾。

#### convertCharset(s,from,to)

返回从’from’中的编码转换为’to’中的编码的字符串’s’。

#### base64Encode(s)

将字符串’s’编码成base64

#### base64Decode(s)

使用base64将字符串解码成原始字符串。如果失败则抛出异常。

#### tryBase64Decode(s)

使用base64将字符串解码成原始字符串。但如果出现错误，将返回空字符串。

#### endsWith(s,后缀)

返回是否以指定的后缀结尾。如果字符串以指定的后缀结束，则返回1，否则返回0。

#### startsWith（s，前缀)

返回是否以指定的前缀开头。如果字符串以指定的前缀开头，则返回1，否则返回0。

#### trimLeft(s)

返回一个字符串，用于删除左侧的空白字符。

#### trimRight(s)

返回一个字符串，用于删除右侧的空白字符。

#### trimBoth(s)

返回一个字符串，用于删除任一侧的空白字符。
', 0, 1, '2021-06-20 10:26:37', 1, '2021-06-20 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(40, '#### 字符串拆分合并函数

#### splitByChar（分隔符，s)

将字符串以’separator’拆分成多个子串。’separator’必须为仅包含一个字符的字符串常量。
返回拆分后的子串的数组。 如果分隔符出现在字符串的开头或结尾，或者如果有多个连续的分隔符，则将在对应位置填充空的子串。

#### splitByString(分隔符，s)

与上面相同，但它使用多个字符的字符串作为分隔符。 该字符串必须为非空。

#### arrayStringConcat(arr[,分隔符])

使用separator将数组中列出的字符串拼接起来。’separator’是一个可选参数：一个常量字符串，默认情况下设置为空字符串。
返回拼接后的字符串。

#### alphaTokens(s)

从范围a-z和A-Z中选择连续字节的子字符串。返回子字符串数组。

**示例：**

```
SELECT alphaTokens(''abca1abc'')

┌─alphaTokens(''abca1abc'')─┐
│ [''abca'',''abc'']          │
└─────────────────────────┘
```
', 0, 1, '2021-06-21 10:26:37', 1, '2021-06-21 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(41, '#### 字符串搜索函数

下列所有函数在默认的情况下区分大小写。对于不区分大小写的搜索，存在单独的变体。

#### 位置（大海捞针），定位（大海捞针)

在字符串`haystack`中搜索子串`needle`。
返回子串的位置（以字节为单位），从1开始，如果未找到子串，则返回0。

对于不区分大小写的搜索，请使用函数`positionCaseInsensitive`。

#### positionUTF8(大海捞针)

与`position`相同，但位置以Unicode字符返回。此函数工作在UTF-8编码的文本字符集中。如非此编码的字符集，则返回一些非预期结果（他不会抛出异常）。

对于不区分大小写的搜索，请使用函数`positionCaseInsensitiveUTF8`。

#### 多搜索分配（干草堆，[针1，针2, …, needlen])

与`position`相同，但函数返回一个数组，其中包含所有匹配needle我的位置。

对于不区分大小写的搜索或/和UTF-8格式，使用函数`multiSearchAllPositionsCaseInsensitive，multiSearchAllPositionsUTF8，multiSearchAllPositionsCaseInsensitiveUTF8`。

#### multiSearchFirstPosition(大海捞针,[针1，针2, …, needlen])

与`position`相同，但返回在`haystack`中与needles字符串匹配的最左偏移。

对于不区分大小写的搜索或/和UTF-8格式，使用函数`multiSearchFirstPositionCaseInsensitive，multiSearchFirstPositionUTF8，multiSearchFirstPositionCaseInsensitiveUTF8`。

#### multiSearchFirstIndex(大海捞针,[针1，针2, …, needlen])

返回在字符串`haystack`中最先查找到的needle我的索引`i`（从1开始），没有找到任何匹配项则返回0。

对于不区分大小写的搜索或/和UTF-8格式，使用函数`multiSearchFirstIndexCaseInsensitive，multiSearchFirstIndexUTF8，multiSearchFirstIndexCaseInsensitiveUTF8`。

#### 多搜索（大海捞针，[针1，针2, …, needlen])

如果`haystack`中至少存在一个needle我匹配则返回1，否则返回0。

对于不区分大小写的搜索或/和UTF-8格式，使用函数`multiSearchAnyCaseInsensitive，multiSearchAnyUTF8，multiSearchAnyCaseInsensitiveUTF8`。

注意

在所有`multiSearch*`函数中，由于实现规范，needles的数量应小于28。

#### 匹配（大海捞针，模式)

检查字符串是否与`pattern`正则表达式匹配。`pattern`可以是一个任意的`re2`正则表达式。 `re2`正则表达式的语法比Perl正则表达式的语法存在更多限制。

如果不匹配返回0，否则返回1。

请注意，反斜杠符号（`\`）用于在正则表达式中转义。由于字符串中采用相同的符号来进行转义。因此，为了在正则表达式中转义符号，必须在字符串文字中写入两个反斜杠（\）。

正则表达式与字符串一起使用，就像它是一组字节一样。正则表达式中不能包含空字节。
对于在字符串中搜索子字符串的模式，最好使用LIKE或«position»，因为它们更加高效。

#### multiMatchAny（大海捞针，[模式1，模式2, …, patternn])

与`match`相同，但如果所有正则表达式都不匹配，则返回0；如果任何模式匹配，则返回1。它使用超扫描库。对于在字符串中搜索子字符串的模式，最好使用«multisearchany»，因为它更高效。

注意

任何`haystack`字符串的长度必须小于232\<!-- sup-->字节，否则抛出异常。这种限制是因为hyperscan API而产生的。

#### multiMatchAnyIndex（大海捞针，[模式1，模式2, …, patternn])

与`multiMatchAny`相同，但返回与haystack匹配的任何内容的索引位置。

#### multiFuzzyMatchAny(干草堆,距离,[模式1，模式2, …, patternn])

与`multiMatchAny`相同，但如果在haystack能够查找到任何模式匹配能够在指定的编辑距离。

#### multiFuzzyMatchAnyIndex(大海捞针,距离,[模式1，模式2, …, patternn])

与`multiFuzzyMatchAny`相同，但返回匹配项的匹配能容的索引位置。

注意

`multiFuzzyMatch*`函数不支持UTF-8正则表达式，由于hyperscan限制，这些表达式被按字节解析。

注意

如要关闭所有hyperscan函数的使用，请设置`SET allow_hyperscan = 0;`。

#### 提取（大海捞针，图案)

使用正则表达式截取字符串。如果’haystack’与’pattern’不匹配，则返回空字符串。如果正则表达式中不包含子模式，它将获取与整个正则表达式匹配的子串。否则，它将获取与第一个子模式匹配的子串。

#### extractAll（大海捞针，图案)

使用正则表达式提取字符串的所有片段。如果’haystack’与’pattern’正则表达式不匹配，则返回一个空字符串。否则返回所有与正则表达式匹配的字符串数组。通常，行为与’extract’函数相同（它采用第一个子模式，如果没有子模式，则采用整个表达式）。

#### 像（干草堆，模式），干草堆像模式运算符

检查字符串是否与简单正则表达式匹配。
正则表达式可以包含的元符号有`％`和`_`。

`%` 表示任何字节数（包括零字符）。

`_` 表示任何一个字节。

可以使用反斜杠（`\`）来对元符号进行转义。请参阅«match»函数说明中有关转义的说明。

对于像`％needle％`这样的正则表达式，改函数与`position`函数一样快。
对于其他正则表达式，函数与’match’函数相同。

#### 不喜欢（干草堆，模式），干草堆不喜欢模式运算符

与’like’函数返回相反的结果。

#### 大海捞针)

基于4-gram计算`haystack`和`needle`之间的距离：计算两个4-gram集合之间的对称差异，并用它们的基数和对其进行归一化。返回0到1之间的任何浮点数 – 越接近0则表示越多的字符串彼此相似。如果常量的`needle`或`haystack`超过32KB，函数将抛出异常。如果非常量的`haystack`或`needle`字符串超过32Kb，则距离始终为1。

对于不区分大小写的搜索或/和UTF-8格式，使用函数`ngramDistanceCaseInsensitive，ngramDistanceUTF8，ngramDistanceCaseInsensitiveUTF8`。

#### ﾂ暗ｪﾂ氾环催ﾂ団ﾂ法ﾂ人)

与`ngramDistance`相同，但计算`needle`和`haystack`之间的非对称差异——`needle`的n-gram减去`needle`归一化n-gram。可用于模糊字符串搜索。

对于不区分大小写的搜索或/和UTF-8格式，使用函数`ngramSearchCaseInsensitive，ngramSearchUTF8，ngramSearchCaseInsensitiveUTF8`。

注意

对于UTF-8，我们使用3-gram。所有这些都不是完全公平的n-gram距离。我们使用2字节哈希来散列n-gram，然后计算这些哈希表之间的（非）对称差异 - 可能会发生冲突。对于UTF-8不区分大小写的格式，我们不使用公平的`tolower`函数 - 我们将每个Unicode字符字节的第5位（从零开始）和字节的第一位归零 - 这适用于拉丁语，主要用于所有西里尔字母。
', 0, 1, '2021-06-22 10:26:37', 1, '2021-06-22 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(42, '#### 字符串替换函数

#### replaceOne(haystack, pattern, replacement)

用’replacement’子串替换’haystack’中第一次出现的’pattern’子串（如果存在）。
’pattern’和’replacement’必须是常量。

#### replaceAll(haystack, pattern, replacement), replace(haystack, pattern, replacement)

用’replacement’子串替换’haystack’中出现的所有的’pattern’子串。

#### replaceRegexpOne(haystack, pattern, replacement)

使用’pattern’正则表达式的替换。 ‘pattern’可以是任意一个有效的re2正则表达式。
如果存在与’pattern’正则表达式匹配的匹配项，仅替换第一个匹配项。
模式pattern可以指定为‘replacement’。此模式可以包含替代`\0-\9`。
替代`\0`包含了整个正则表达式。替代`\1-\9`对应于子模式编号。要在模板中使用反斜杠`\`，请使用`\`将其转义。
另外还请记住，字符串字面值(literal)需要额外的转义。

示例1.将日期转换为美国格式：

```
SELECT DISTINCT
    EventDate,
    replaceRegexpOne(toString(EventDate), ''(\\d{4})-(\\d{2})-(\\d{2})'', ''\\2/\\3/\\1'') AS res
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

示例2.复制字符串十次：

```
SELECT replaceRegexpOne(''Hello, World!'', ''.*'', ''\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0'') AS res
┌─res────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World! │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### replaceRegexpAll(haystack, pattern, replacement)

与replaceRegexpOne相同，但会替换所有出现的匹配项。例如：

```
SELECT replaceRegexpAll(''Hello, World!'', ''.'', ''\\0\\0'') AS res
┌─res────────────────────────┐
│ HHeelllloo,,  WWoorrlldd!! │
└────────────────────────────┘
```

作为例外，对于空子字符串，正则表达式只会进行一次替换。
示例:

```
SELECT replaceRegexpAll(''Hello, World!'', ''^'', ''here: '') AS res
┌─res─────────────────┐
│ here: Hello, World! │
└─────────────────────┘
```

#### regexpQuoteMeta(s)

该函数用于在字符串中的某些预定义字符之前添加反斜杠。
预定义字符：`\0`, `\\`, `|`, `(`, `)`, `^`, `$`, `.`, `[`, `]`, `?`, `*`, `+`, `{`, `:`, `-`。
这个实现与re2::RE2::QuoteMeta略有不同。它以`\0` 转义零字节，而不是`\x00`，并且只转义必需的字符。
有关详细信息，请参阅链接：RE2
', 0, 1, '2021-06-23 10:26:37', 1, '2021-06-23 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(43, '#### 数学函数

以下所有的函数都返回一个Float64类型的数值。返回结果总是以尽可能最大精度返回，但还是可能与机器中可表示最接近该值的数字不同。

#### e()

返回一个接近数学常量e的Float64数字。

#### pi()

返回一个接近数学常量π的Float64数字。

#### exp(x)

接受一个数值类型的参数并返回它的指数。

#### log(x),ln(x)

接受一个数值类型的参数并返回它的自然对数。

#### exp2(x)

接受一个数值类型的参数并返回它的2的x次幂。

#### log2(x)

接受一个数值类型的参数并返回它的底2对数。

#### exp10(x)

接受一个数值类型的参数并返回它的10的x次幂。

#### log10(x)

接受一个数值类型的参数并返回它的底10对数。

#### sqrt(x)

接受一个数值类型的参数并返回它的平方根。

#### cbrt(x)

接受一个数值类型的参数并返回它的立方根。

#### erf(x)

如果’x’是非负数，那么`erf(x / σ√2)`是具有正态分布且标准偏差为«σ»的随机变量的值与预期值之间的距离大于«x»。

示例 （三西格玛准则）:

```
SELECT erf(3 / sqrt(2))
┌─erf(divide(3, sqrt(2)))─┐
│      0.9973002039367398 │
└─────────────────────────┘
```

#### erfc(x)

接受一个数值参数并返回一个接近1 - erf(x)的Float64数字，但不会丢失大«x»值的精度。

#### lgamma(x)

返回x的绝对值的自然对数的伽玛函数。

#### tgamma(x)

返回x的伽玛函数。

#### sin(x)

返回x的三角正弦值。

#### cos(x)

返回x的三角余弦值。

#### tan(x)

返回x的三角正切值。

#### asin(x)

返回x的反三角正弦值。

#### acos(x)

返回x的反三角余弦值。

#### atan(x)

返回x的反三角正切值。

#### pow(x,y),power(x,y)

接受x和y两个参数。返回x的y次方。

#### intExp2

接受一个数值类型的参数并返回它的2的x次幂（UInt64）。

#### intExp10

接受一个数值类型的参数并返回它的10的x次幂（UInt64）。
', 0, 1, '2021-06-24 10:26:37', 1, '2021-06-24 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(44, '#### 数组函数

#### empty

对于空数组返回1，对于非空数组返回0。
结果类型是UInt8。
该函数也适用于字符串。

#### notEmpty

对于空数组返回0，对于非空数组返回1。
结果类型是UInt8。
该函数也适用于字符串。

#### length

返回数组中的元素个数。
结果类型是UInt64。
该函数也适用于字符串。

#### emptyArrayUInt8,emptyArrayUInt16,emptyArrayUInt32,emptyArrayUInt64

#### emptyArrayInt8,emptyArrayInt16,emptyArrayInt32,emptyArrayInt64

#### emptyArrayFloat32,emptyArrayFloat64

#### emptyArrayDate，emptyArrayDateTime

#### emptyArrayString

不接受任何参数并返回适当类型的空数组。

#### emptyArrayToSingle

接受一个空数组并返回一个仅包含一个默认值元素的数组。

#### range(N)

返回从0到N-1的数字数组。
以防万一，如果在数据块中创建总长度超过100,000,000个元素的数组，则抛出异常。

#### array(x1, …), operator [x1, …]

使用函数的参数作为数组元素创建一个数组。
参数必须是常量，并且具有最小公共类型的类型。必须至少传递一个参数，否则将不清楚要创建哪种类型的数组。也就是说，你不能使用这个函数来创建一个空数组（为此，使用上面描述的’emptyArray  *’函数）。
返回’Array（T）’类型的结果，其中’T’是传递的参数中最小的公共类型。

#### arrayConcat

合并参数中传递的所有数组。

```
arrayConcat(arrays)
```

**参数**

- `arrays` – 任意数量的阵列类型的参数.
  **示例**

```
SELECT arrayConcat([1, 2], [3, 4], [5, 6]) AS res
┌─res───────────┐
│ [1,2,3,4,5,6] │
└───────────────┘
```

#### arrayElement(arr,n),运算符arr[n]

从数组`arr`中获取索引为«n»的元素。 `n`必须是任何整数类型。
数组中的索引从一开始。
支持负索引。在这种情况下，它选择从末尾开始编号的相应元素。例如，`arr [-1]`是数组中的最后一项。

如果索引超出数组的边界，则返回默认值（数字为0，字符串为空字符串等）。

#### has(arr,elem)

检查’arr’数组是否具有’elem’元素。
如果元素不在数组中，则返回0;如果在，则返回1。

`NULL` 值的处理。

```
SELECT has([1, 2, NULL], NULL)

┌─has([1, 2, NULL], NULL)─┐
│                       1 │
└─────────────────────────┘
```

#### hasAll

检查一个数组是否是另一个数组的子集。

```
hasAll(set, subset)
```

**参数**

- `set` – 具有一组元素的任何类型的数组。
- `subset` – 任何类型的数组，其元素应该被测试为`set`的子集。

**返回值**

- `1`， 如果`set`包含`subset`中的所有元素。
- `0`， 否则。

**特殊的定义**

- 空数组是任何数组的子集。
- «Null»作为数组中的元素值进行处理。
- 忽略两个数组中的元素值的顺序。

**示例**

`SELECT hasAll([], [])` 返回1。

`SELECT hasAll([1, Null], [Null])` 返回1。

`SELECT hasAll([1.0, 2, 3, 4], [1, 3])` 返回1。

`SELECT hasAll([''a'', ''b''], [''a''])` 返回1。

`SELECT hasAll([1], [''a''])` 返回0。

`SELECT hasAll([[1, 2], [3, 4]], [[1, 2], [3, 5]])` 返回0。

#### hasAny

检查两个数组是否存在交集。

```
hasAny(array1, array2)
```

**参数**

- `array1` – 具有一组元素的任何类型的数组。
- `array2` – 具有一组元素的任何类型的数组。

**返回值**

- `1`， 如果`array1`和`array2`存在交集。
- `0`， 否则。

**特殊的定义**

- «Null»作为数组中的元素值进行处理。
- 忽略两个数组中的元素值的顺序。

**示例**

`SELECT hasAny([1], [])` 返回 `0`.

`SELECT hasAny([Null], [Null, 1])` 返回 `1`.

`SELECT hasAny([-128, 1., 512], [1])` 返回 `1`.

`SELECT hasAny([[1, 2], [3, 4]], [''a'', ''c''])` 返回 `0`.

`SELECT hasAll([[1, 2], [3, 4]], [[1, 2], [1, 2]])` 返回 `1`.

#### indexOf(arr,x)

返回数组中第一个’x’元素的索引（从1开始），如果’x’元素不存在在数组中，则返回0。

示例:

```
:) SELECT indexOf([1,3,NULL,NULL],NULL)

SELECT indexOf([1, 3, NULL, NULL], NULL)

┌─indexOf([1, 3, NULL, NULL], NULL)─┐
│                                 3 │
└───────────────────────────────────┘
```

设置为«NULL»的元素将作为普通的元素值处理。

#### countEqual(arr,x)

返回数组中等于x的元素的个数。相当于arrayCount（elem - > elem = x，arr）。

`NULL`值将作为单独的元素值处理。

示例:

```
SELECT countEqual([1, 2, NULL, NULL], NULL)

┌─countEqual([1, 2, NULL, NULL], NULL)─┐
│                                    2 │
└──────────────────────────────────────┘
```

#### arrayEnumerate(arr)

返回 Array [1, 2, 3, …, length (arr) ]

此功能通常与ARRAY JOIN一起使用。它允许在应用ARRAY JOIN后为每个数组计算一次。例如：

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

在此示例中，Reaches是转换次数（应用ARRAY JOIN后接收的字符串），Hits是浏览量（ARRAY JOIN之前的字符串）。在这种特殊情况下，您可以更轻松地获得相同的结果：

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

此功能也可用于高阶函数。例如，您可以使用它来获取与条件匹配的元素的数组索引。

#### arrayEnumerateUniq(arr, …)

返回与源数组大小相同的数组，其中每个元素表示与其下标对应的源数组元素在源数组中出现的次数。
例如：arrayEnumerateUniq（ [10,20,10,30 ]）=  [1,1,2,1 ]。

使用ARRAY JOIN和数组元素的聚合时，此函数很有用。

示例:

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

在此示例中，每个GoalID都计算转换次数（目标嵌套数据结构中的每个元素都是达到的目标，我们称之为转换）和会话数。如果没有ARRAY JOIN，我们会将会话数计为总和（Sign）。但在这种特殊情况下，行乘以嵌套的Goals结构，因此为了在此之后计算每个会话一次，我们将一个条件应用于arrayEnumerateUniq（Goals.ID）函数的值。

arrayEnumerateUniq函数可以使用与参数大小相同的多个数组。在这种情况下，对于所有阵列中相同位置的元素元组，考虑唯一性。

```
SELECT arrayEnumerateUniq([1, 1, 1, 2, 2, 2], [1, 1, 2, 1, 1, 2]) AS res
┌─res───────────┐
│ [1,2,1,1,2,1] │
└───────────────┘
```

当使用带有嵌套数据结构的ARRAY JOIN并在此结构中跨多个元素进一步聚合时，这是必需的。

#### arrayPopBack

从数组中删除最后一项。

```
arrayPopBack(array)
```

**参数**

- `array` – 数组。

**示例**

```
SELECT arrayPopBack([1, 2, 3]) AS res
┌─res───┐
│ [1,2] │
└───────┘
```

#### arrayPopFront

从数组中删除第一项。

```
arrayPopFront(array)
```

**参数**

- `array` – 数组。

**示例**

```
SELECT arrayPopFront([1, 2, 3]) AS res
┌─res───┐
│ [2,3] │
└───────┘
```

#### arrayPushBack

添加一个元素到数组的末尾。

```
arrayPushBack(array, single_value)
```

**参数**

- `array` – 数组。
- `single_value` – 单个值。只能将数字添加到带数字的数组中，并且只能将字符串添加到字符串数组中。添加数字时，ClickHouse会自动为数组的数据类型设置`single_value`类型。有关ClickHouse中数据类型的更多信息，请参阅«数据类型»。可以是’NULL`。该函数向数组添加一个«NULL»元素，数组元素的类型转换为`Nullable`。

**示例**

```
SELECT arrayPushBack([''a''], ''b'') AS res
┌─res───────┐
│ [''a'',''b''] │
└───────────┘
```

#### arrayPushFront

将一个元素添加到数组的开头。

```
arrayPushFront(array, single_value)
```

**参数**

- `array` – 数组。
- `single_value` – 单个值。只能将数字添加到带数字的数组中，并且只能将字符串添加到字符串数组中。添加数字时，ClickHouse会自动为数组的数据类型设置`single_value`类型。有关ClickHouse中数据类型的更多信息，请参阅«数据类型»。可以是’NULL`。该函数向数组添加一个«NULL»元素，数组元素的类型转换为`Nullable`。

**示例**

```
SELECT arrayPushFront([''b''], ''a'') AS res
┌─res───────┐
│ [''a'',''b''] │
└───────────┘
```

#### arrayResize

更改数组的长度。

```
arrayResize(array, size[, extender])
```

**参数:**

- `array` — 数组.

- ```
  size
  ```



  — 数组所需的长度。

  - 如果`size`小于数组的原始大小，则数组将从右侧截断。

- 如果`size`大于数组的初始大小，则使用`extender`值或数组项的数据类型的默认值将数组扩展到右侧。

- `extender` — 扩展数组的值。可以是’NULL`。

**返回值:**

一个`size`长度的数组。

**调用示例**

```
SELECT arrayResize([1], 3)

┌─arrayResize([1], 3)─┐
│ [1,0,0]             │
└─────────────────────┘

SELECT arrayResize([1], 3, NULL)

┌─arrayResize([1], 3, NULL)─┐
│ [1,NULL,NULL]             │
└───────────────────────────┘
```

#### arraySlice

返回一个子数组，包含从指定位置的指定长度的元素。

```
arraySlice(array, offset[, length])
```

**参数**

- `array` – 数组。
- `offset` – 数组的偏移。正值表示左侧的偏移量，负值表示右侧的缩进值。数组下标从1开始。
- `length` - 子数组的长度。如果指定负值，则该函数返回`[offset，array_length - length`。如果省略该值，则该函数返回`[offset，the_end_of_array]`。

**示例**

```
SELECT arraySlice([1, 2, NULL, 4, 5], 2, 3) AS res
┌─res────────┐
│ [2,NULL,4] │
└────────────┘
```

设置为«NULL»的数组元素作为普通的数组元素值处理。

#### arraySort([func,] arr, …)

以升序对`arr`数组的元素进行排序。如果指定了`func`函数，则排序顺序由`func`函数的调用结果决定。如果`func`接受多个参数，那么`arraySort`函数也将解析与`func`函数参数相同数量的数组参数。更详细的示例在`arraySort`的末尾。

整数排序示例:

```
SELECT arraySort([1, 3, 3, 0]);
┌─arraySort([1, 3, 3, 0])─┐
│ [0,1,3,3]               │
└─────────────────────────┘
```

字符串排序示例:

```
SELECT arraySort([''hello'', ''world'', ''!'']);
┌─arraySort([''hello'', ''world'', ''!''])─┐
│ [''!'',''hello'',''world'']              │
└────────────────────────────────────┘
```

`NULL`，`NaN`和`Inf`的排序顺序：

```
SELECT arraySort([1, nan, 2, NULL, 3, nan, -4, NULL, inf, -inf]);
┌─arraySort([1, nan, 2, NULL, 3, nan, -4, NULL, inf, -inf])─┐
│ [-inf,-4,1,2,3,inf,nan,nan,NULL,NULL]                     │
└───────────────────────────────────────────────────────────┘
```

- `-Inf` 是数组中的第一个。
- `NULL` 是数组中的最后一个。
- `NaN` 在`NULL`的前面。
- `Inf` 在`NaN`的前面。

注意：`arraySort`是高阶函数。您可以将lambda函数作为第一个参数传递给它。在这种情况下，排序顺序由lambda函数的调用结果决定。

让我们来看一下如下示例：

```
SELECT arraySort((x) -> -x, [1, 2, 3]) as res;
┌─res─────┐
│ [3,2,1] │
└─────────┘
```

对于源数组的每个元素，lambda函数返回排序键，即1 -> -1, 2 -> -2, 3 -> -3]。由于`arraySort`函数按升序对键进行排序，因此结果为3,2,1]。因此，`(x) -> -x` lambda函数将排序设置为降序。

lambda函数可以接受多个参数。在这种情况下，您需要为`arraySort`传递与lambda参数个数相同的数组。函数使用第一个输入的数组中的元素组成返回结果；使用接下来传入的数组作为排序键。例如：

```
SELECT arraySort((x, y) -> y, [''hello'', ''world''], [2, 1]) as res;
┌─res────────────────┐
│ [''world'', ''hello''] │
└────────────────────┘
```

这里，在第二个数组（[2, 1]）中定义了第一个数组（[‘hello’，‘world’]）的相应元素的排序键，即[‘hello’ -> 2，‘world’ -> 1]。 由于lambda函数中没有使用`x`，因此源数组中的实际值不会影响结果的顺序。所以，’world’将是结果中的第一个元素，’hello’将是结果中的第二个元素。

其他示例如下所示。

```
SELECT arraySort((x, y) -> y, [0, 1, 2], [''c'', ''b'', ''a'']) as res;
┌─res─────┐
│ [2,1,0] │
└─────────┘
SELECT arraySort((x, y) -> -y, [0, 1, 2], [1, 2, 3]) as res;
┌─res─────┐
│ [2,1,0] │
└─────────┘
```

注意

为了提高排序效率， 使用了施瓦茨变换。

#### arrayReverseSort([func,] arr, …)

以降序对`arr`数组的元素进行排序。如果指定了`func`函数，则排序顺序由`func`函数的调用结果决定。如果`func`接受多个参数，那么`arrayReverseSort`函数也将解析与`func`函数参数相同数量的数组作为参数。更详细的示例在`arrayReverseSort`的末尾。

整数排序示例:

```
SELECT arrayReverseSort([1, 3, 3, 0]);
┌─arrayReverseSort([1, 3, 3, 0])─┐
│ [3,3,1,0]                      │
└────────────────────────────────┘
```

字符串排序示例:

```
SELECT arrayReverseSort([''hello'', ''world'', ''!'']);
┌─arrayReverseSort([''hello'', ''world'', ''!''])─┐
│ [''world'',''hello'',''!'']                     │
└───────────────────────────────────────────┘
```

`NULL`，`NaN`和`Inf`的排序顺序：

```
SELECT arrayReverseSort([1, nan, 2, NULL, 3, nan, -4, NULL, inf, -inf]) as res;
┌─res───────────────────────────────────┐
│ [inf,3,2,1,-4,-inf,nan,nan,NULL,NULL] │
└───────────────────────────────────────┘
```

- `Inf` 是数组中的第一个。
- `NULL` 是数组中的最后一个。
- `NaN` 在`NULL`的前面。
- `-Inf` 在`NaN`的前面。

注意：`arraySort`是高阶函数。您可以将lambda函数作为第一个参数传递给它。如下示例所示。

```
SELECT arrayReverseSort((x) -> -x, [1, 2, 3]) as res;
┌─res─────┐
│ [1,2,3] │
└─────────┘
```

数组按以下方式排序：
数组按以下方式排序:

1. 首先，根据lambda函数的调用结果对源数组（[1, 2, 3]）进行排序。 结果是[3, 2, 1]。
2. 反转上一步获得的数组。 所以，最终的结果是[1, 2, 3]。

lambda函数可以接受多个参数。在这种情况下，您需要为`arrayReverseSort`传递与lambda参数个数相同的数组。函数使用第一个输入的数组中的元素组成返回结果；使用接下来传入的数组作为排序键。例如：

```
SELECT arrayReverseSort((x, y) -> y, [''hello'', ''world''], [2, 1]) as res;
┌─res───────────────┐
│ [''hello'',''world''] │
└───────────────────┘
```

在这个例子中，数组按以下方式排序：

1. 首先，根据lambda函数的调用结果对源数组（[‘hello’，‘world’]）进行排序。 其中，在第二个数组（[2,1]）中定义了源数组中相应元素的排序键。 所以，排序结果[‘world’，‘hello’]。
2. 反转上一步骤中获得的排序数组。 所以，最终的结果是[‘hello’，‘world’]。

其他示例如下所示。

```
SELECT arrayReverseSort((x, y) -> y, [4, 3, 5], [''a'', ''b'', ''c'']) AS res;
┌─res─────┐
│ [5,3,4] │
└─────────┘
SELECT arrayReverseSort((x, y) -> -y, [4, 3, 5], [1, 2, 3]) AS res;
┌─res─────┐
│ [4,3,5] │
└─────────┘
```

#### arrayUniq(arr, …)

如果传递一个参数，则计算数组中不同元素的数量。
如果传递了多个参数，则它计算多个数组中相应位置的不同元素元组的数量。

如果要获取数组中唯一项的列表，可以使用arrayReduce（‘groupUniqArray’，arr）。

#### arrayJoin(arr)

一个特殊的功能。请参见«ArrayJoin函数»部分。

#### arrayDifference(arr)

返回一个数组，其中包含所有相邻元素对之间的差值。例如：

```
SELECT arrayDifference([1, 2, 3, 4])
┌─arrayDifference([1, 2, 3, 4])─┐
│ [0,1,1,1]                     │
└───────────────────────────────┘
```

#### arrayDistinct(arr)

返回一个包含所有数组中不同元素的数组。例如：

```
SELECT arrayDistinct([1, 2, 2, 3, 1])
┌─arrayDistinct([1, 2, 2, 3, 1])─┐
│ [1,2,3]                        │
└────────────────────────────────┘
```

#### arrayEnumerateDense(arr)

返回与源数组大小相同的数组，指示每个元素首次出现在源数组中的位置。例如：arrayEnumerateDense（[10,20,10,30]）= [1,2,1,3]。

#### arrayIntersect(arr)

返回所有数组元素的交集。例如：

```
SELECT
    arrayIntersect([1, 2], [1, 3], [2, 3]) AS no_intersect,
    arrayIntersect([1, 2], [1, 3], [1, 4]) AS intersect
┌─no_intersect─┬─intersect─┐
│ []           │ [1]       │
└──────────────┴───────────┘
```

#### arrayReduce(agg_func, arr1, …)

将聚合函数应用于数组并返回其结果。如果聚合函数具有多个参数，则此函数可应用于相同大小的多个数组。

arrayReduce（‘agg_func’，arr1，…） - 将聚合函数`agg_func`应用于数组`arr1 ...`。如果传递了多个数组，则相应位置上的元素将作为多个参数传递给聚合函数。例如：SELECT arrayReduce（‘max’，[1,2,3]）= 3

#### arrayReverse(arr)

返回与源数组大小相同的数组，包含反转源数组的所有元素的结果。
', 0, 1, '2021-06-25 10:26:37', 1, '2021-06-25 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(45, '#### 时间日期函数

支持时区。

所有的时间日期函数都可以在第二个可选参数中接受时区参数。示例：Asia / Yekaterinburg。在这种情况下，它们使用指定的时区而不是本地（默认）时区。

```
SELECT
    toDateTime(''2016-06-15 23:00:00'') AS time,
    toDate(time) AS date_local,
    toDate(time, ''Asia/Yekaterinburg'') AS date_yekat,
    toString(time, ''US/Samoa'') AS time_samoa
┌────────────────time─┬─date_local─┬─date_yekat─┬─time_samoa──────────┐
│ 2016-06-15 23:00:00 │ 2016-06-15 │ 2016-06-16 │ 2016-06-15 09:00:00 │
└─────────────────────┴────────────┴────────────┴─────────────────────┘
```

仅支持与UTC相差一整小时的时区。

#### toTimeZone

将Date或DateTime转换为指定的时区。 时区是Date/DateTime类型的属性。 表字段或结果集的列的内部值（秒数）不会更改，列的类型会更改，并且其字符串表示形式也会相应更改。

```
SELECT
    toDateTime(''2019-01-01 00:00:00'', ''UTC'') AS time_utc,
    toTypeName(time_utc) AS type_utc,
    toInt32(time_utc) AS int32utc,
    toTimeZone(time_utc, ''Asia/Yekaterinburg'') AS time_yekat,
    toTypeName(time_yekat) AS type_yekat,
    toInt32(time_yekat) AS int32yekat,
    toTimeZone(time_utc, ''US/Samoa'') AS time_samoa,
    toTypeName(time_samoa) AS type_samoa,
    toInt32(time_samoa) AS int32samoa
FORMAT Vertical;
Row 1:
──────
time_utc:   2019-01-01 00:00:00
type_utc:   DateTime(''UTC'')
int32utc:   1546300800
time_yekat: 2019-01-01 05:00:00
type_yekat: DateTime(''Asia/Yekaterinburg'')
int32yekat: 1546300800
time_samoa: 2018-12-31 13:00:00
type_samoa: DateTime(''US/Samoa'')
int32samoa: 1546300800
```

`toTimeZone(time_utc, ''Asia/Yekaterinburg'')` 把 `DateTime(''UTC'')` 类型转换为 `DateTime(''Asia/Yekaterinburg'')`. 内部值 (Unixtimestamp) 1546300800 保持不变, 但是字符串表示(toString() 函数的结果值) 由 `time_utc: 2019-01-01 00:00:00` 转换为o `time_yekat: 2019-01-01 05:00:00`.

#### toYear

将Date或DateTime转换为包含年份编号（AD）的UInt16类型的数字。

#### toQuarter

将Date或DateTime转换为包含季度编号的UInt8类型的数字。

#### toMonth

将Date或DateTime转换为包含月份编号（1-12）的UInt8类型的数字。

#### toDayOfYear

将Date或DateTime转换为包含一年中的某一天的编号的UInt16（1-366）类型的数字。

#### toDayOfMonth

将Date或DateTime转换为包含一月中的某一天的编号的UInt8（1-31）类型的数字。

#### toDayOfWeek

将Date或DateTime转换为包含一周中的某一天的编号的UInt8（周一是1, 周日是7）类型的数字。

#### toHour

将DateTime转换为包含24小时制（0-23）小时数的UInt8数字。
这个函数假设如果时钟向前移动，它是一个小时，发生在凌晨2点，如果时钟被移回，它是一个小时，发生在凌晨3点（这并非总是如此 - 即使在莫斯科时钟在不同的时间两次改变）。

#### toMinute

将DateTime转换为包含一小时中分钟数（0-59）的UInt8数字。

#### toSecond

将DateTime转换为包含一分钟中秒数（0-59）的UInt8数字。
闰秒不计算在内。

#### toUnixTimestamp

对于DateTime参数：将值转换为UInt32类型的数字-Unix时间戳。
对于String参数：根据时区将输入字符串转换为日期时间（可选的第二个参数，默认使用服务器时区），并返回相应的unix时间戳。

**语法**

```
toUnixTimestamp(datetime)
toUnixTimestamp(str, [timezone])
```

**返回值**

- 返回 unix timestamp.

类型: `UInt32`.

**示例**

查询:

```
SELECT toUnixTimestamp(''2017-11-05 08:07:47'', ''Asia/Tokyo'') AS unix_timestamp
```

结果:

```
┌─unix_timestamp─┐
│     1509836867 │
└────────────────┘
```

#### toStartOfYear

将Date或DateTime向前取整到本年的第一天。
返回Date类型。

#### toStartOfISOYear

将Date或DateTime向前取整到ISO本年的第一天。
返回Date类型。

#### toStartOfQuarter

将Date或DateTime向前取整到本季度的第一天。
返回Date类型。

#### toStartOfMonth

将Date或DateTime向前取整到本月的第一天。
返回Date类型。

注意

解析不正确日期的行为是特定于实现的。 ClickHouse可能会返回零日期，抛出异常或执行«natural»溢出。

#### toMonday

将Date或DateTime向前取整到本周的星期一。
返回Date类型。

#### toStartOfWeek(t[,mode])

按mode将Date或DateTime向前取整到最近的星期日或星期一。
返回Date类型。
mode参数的工作方式与toWeek()的mode参数完全相同。 对于单参数语法，mode使用默认值0。

#### toStartOfDay

将DateTime向前取整到今天的开始。

#### toStartOfHour

将DateTime向前取整到当前小时的开始。

#### toStartOfMinute

将DateTime向前取整到当前分钟的开始。

#### toStartOfSecond

将DateTime向前取整到当前秒数的开始。

**语法**

```
toStartOfSecond(value[, timezone])
```

**参数**

- `value` — 时间和日期DateTime64.
- `timezone` — 返回值的Timezone (可选参数)。 如果未指定将使用 `value` 参数的时区。 String。

**返回值**

- 输入值毫秒部分为零。

类型: DateTime64.

**示例**

不指定时区查询:

```
WITH toDateTime64(''2020-01-01 10:20:30.999'', 3) AS dt64
SELECT toStartOfSecond(dt64);
```

结果:

```
┌───toStartOfSecond(dt64)─┐
│ 2020-01-01 10:20:30.000 │
└─────────────────────────┘
```

指定时区查询:

```
WITH toDateTime64(''2020-01-01 10:20:30.999'', 3) AS dt64
SELECT toStartOfSecond(dt64, ''Europe/Moscow'');
```

结果:

```
┌─toStartOfSecond(dt64, ''Europe/Moscow'')─┐
│                2020-01-01 13:20:30.000 │
└────────────────────────────────────────┘
```

**参考**

- Timezone 服务器配置选项。

#### toStartOfFiveMinute

将DateTime以五分钟为单位向前取整到最接近的时间点。

#### toStartOfTenMinutes

将DateTime以十分钟为单位向前取整到最接近的时间点。

#### toStartOfFifteenMinutes

将DateTime以十五分钟为单位向前取整到最接近的时间点。

#### toStartOfInterval(time_or_data,间隔x单位[,time_zone])

这是名为`toStartOf*`的所有函数的通用函数。例如，
`toStartOfInterval（t，INTERVAL 1 year）`返回与`toStartOfYear（t）`相同的结果，
`toStartOfInterval（t，INTERVAL 1 month）`返回与`toStartOfMonth（t）`相同的结果，
`toStartOfInterval（t，INTERVAL 1 day）`返回与`toStartOfDay（t）`相同的结果，
`toStartOfInterval（t，INTERVAL 15 minute）`返回与`toStartOfFifteenMinutes（t）`相同的结果。

#### toTime

将DateTime中的日期转换为一个固定的日期，同时保留时间部分。

#### toRelativeYearNum

将Date或DateTime转换为年份的编号，从过去的某个固定时间点开始。

#### toRelativeQuarterNum

将Date或DateTime转换为季度的数字，从过去的某个固定时间点开始。

#### toRelativeMonthNum

将Date或DateTime转换为月份的编号，从过去的某个固定时间点开始。

#### toRelativeWeekNum

将Date或DateTime转换为星期数，从过去的某个固定时间点开始。

#### toRelativeDayNum

将Date或DateTime转换为当天的编号，从过去的某个固定时间点开始。

#### toRelativeHourNum

将DateTime转换为小时数，从过去的某个固定时间点开始。

#### toRelativeMinuteNum

将DateTime转换为分钟数，从过去的某个固定时间点开始。

#### toRelativeSecondNum

将DateTime转换为秒数，从过去的某个固定时间点开始。

#### toISOYear

将Date或DateTime转换为包含ISO年份的UInt16类型的编号。

#### toISOWeek

将Date或DateTime转换为包含ISO周数的UInt8类型的编号。

#### toWeek(date[,mode])

返回Date或DateTime的周数。两个参数形式可以指定星期是从星期日还是星期一开始，以及返回值应在0到53还是从1到53的范围内。如果省略了mode参数，则默认 模式为0。
`toISOWeek()`是一个兼容函数，等效于`toWeek(date,3)`。
下表描述了mode参数的工作方式。

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

对于象“with 4 or more days this year,”的mode值，根据ISO 8601：1988对周进行编号：

- 如果包含1月1日的一周在后一年度中有4天或更多天，则为第1周。
- 否则，它是上一年的最后一周，下周是第1周。

对于像“contains January 1”的mode值, 包含1月1日的那周为本年度的第1周。

```
toWeek(date, [, mode][, Timezone])
```

**参数**

- `date` – Date 或 DateTime.
- `mode` – 可选参数, 取值范围 [0,9]， 默认0。
- `Timezone` – 可选参数， 可其他时间日期转换参数的行为一致。

**示例**

```
SELECT toDate(''2016-12-27'') AS date, toWeek(date) AS week0, toWeek(date,1) AS week1, toWeek(date,9) AS week9;
┌───────date─┬─week0─┬─week1─┬─week9─┐
│ 2016-12-27 │    52 │    52 │     1 │
└────────────┴───────┴───────┴───────┘
```

#### toYearWeek(date[,mode])

返回Date的年和周。 结果中的年份可能因为Date为该年份的第一周和最后一周而于Date的年份不同。

mode参数的工作方式与toWeek()的mode参数完全相同。 对于单参数语法，mode使用默认值0。

`toISOYear()`是一个兼容函数，等效于`intDiv(toYearWeek(date,3),100)`.

**示例**

```
SELECT toDate(''2016-12-27'') AS date, toYearWeek(date) AS yearWeek0, toYearWeek(date,1) AS yearWeek1, toYearWeek(date,9) AS yearWeek9;
┌───────date─┬─yearWeek0─┬─yearWeek1─┬─yearWeek9─┐
│ 2016-12-27 │    201652 │    201652 │    201701 │
└────────────┴───────────┴───────────┴───────────┘
```

#### date_trunc

将Date或DateTime按指定的单位向前取整到最接近的时间点。

**语法**

```
date_trunc(unit, value[, timezone])
```

别名: `dateTrunc`.

**参数**

- `unit` — 单位. String.
  可选值:
  - `second`
  - `minute`
  - `hour`
  - `day`
  - `week`
  - `month`
  - `quarter`
  - `year`
- `value` — DateTime 或者 DateTime64.
- `timezone` — Timezone name 返回值的时区(可选值)。如果未指定将使用`value`的时区。 String.

**返回值**

- 按指定的单位向前取整后的DateTime。

类型: Datetime.

**示例**

不指定时区查询:

```
SELECT now(), date_trunc(''hour'', now());
```

结果:

```
┌───────────────now()─┬─date_trunc(''hour'', now())─┐
│ 2020-09-28 10:40:45 │       2020-09-28 10:00:00 │
└─────────────────────┴───────────────────────────┘
```

指定时区查询:

```
SELECT now(), date_trunc(''hour'', now(), ''Europe/Moscow'');
```

结果:

```
┌───────────────now()─┬─date_trunc(''hour'', now(), ''Europe/Moscow'')─┐
│ 2020-09-28 10:46:26 │                        2020-09-28 13:00:00 │
└─────────────────────┴────────────────────────────────────────────┘
```

**参考**

- toStartOfInterval

#### now

返回当前日期和时间。

**语法**

```
now([timezone])
```

**参数**

- `timezone` — Timezone name 返回结果的时区(可先参数). String.

**返回值**

- 当前日期和时间。

类型: Datetime.

**示例**

不指定时区查询:

```
SELECT now();
```

结果:

```
┌───────────────now()─┐
│ 2020-10-17 07:42:09 │
└─────────────────────┘
```

指定时区查询:

```
SELECT now(''Europe/Moscow'');
```

结果:

```
┌─now(''Europe/Moscow'')─┐
│  2020-10-17 10:42:23 │
└──────────────────────┘
```

#### today

不接受任何参数并在请求执行时的某一刻返回当前日期(Date)。
其功能与’toDate（now()）’相同。

#### yesterday

不接受任何参数并在请求执行时的某一刻返回昨天的日期(Date)。
其功能与’today() - 1’相同。

#### timeSlot

将时间向前取整半小时。
此功能用于Yandex.Metrica，因为如果跟踪标记显示单个用户的连续综合浏览量在时间上严格超过此数量，则半小时是将会话分成两个会话的最短时间。这意味着（tag id，user id，time slot）可用于搜索相应会话中包含的综合浏览量。

#### toYYYYMM

将Date或DateTime转换为包含年份和月份编号的UInt32类型的数字（YYYY * 100 + MM）。

#### toYYYYMMDD

将Date或DateTime转换为包含年份和月份编号的UInt32类型的数字（YYYY * 10000 + MM * 100 + DD）。

#### toYYYYMMDDhhmmss

将Date或DateTime转换为包含年份和月份编号的UInt64类型的数字（YYYY * 10000000000 + MM * 100000000 + DD * 1000000 + hh * 10000 + mm * 100 + ss）。

#### addYears, addMonths, addWeeks, addDays, addHours, addMinutes, addSeconds, addQuarters

函数将一段时间间隔添加到Date/DateTime，然后返回Date/DateTime。例如：

```
WITH
    toDate(''2018-01-01'') AS date,
    toDateTime(''2018-01-01 00:00:00'') AS date_time
SELECT
    addYears(date, 1) AS add_years_with_date,
    addYears(date_time, 1) AS add_years_with_date_time
┌─add_years_with_date─┬─add_years_with_date_time─┐
│          2019-01-01 │      2019-01-01 00:00:00 │
└─────────────────────┴──────────────────────────┘
```

#### subtractYears,subtractMonths,subtractWeeks,subtractDays,subtractours,subtractMinutes,subtractSeconds,subtractQuarters

函数将Date/DateTime减去一段时间间隔，然后返回Date/DateTime。例如：

```
WITH
    toDate(''2019-01-01'') AS date,
    toDateTime(''2019-01-01 00:00:00'') AS date_time
SELECT
    subtractYears(date, 1) AS subtract_years_with_date,
    subtractYears(date_time, 1) AS subtract_years_with_date_time
┌─subtract_years_with_date─┬─subtract_years_with_date_time─┐
│               2018-01-01 │           2018-01-01 00:00:00 │
└──────────────────────────┴───────────────────────────────┘
```

#### dateDiff

返回两个Date或DateTime类型之间的时差。

**语法**

```
dateDiff(''unit'', startdate, enddate, [timezone])
```

**参数**

- `unit` — 返回结果的时间单位。 String.

  ```
  支持的时间单位: second, minute, hour, day, week, month, quarter, year.
  ```

- `startdate` — 第一个待比较值。 Date 或 DateTime.

- `enddate` — 第二个待比较值。 Date 或 DateTime.

- `timezone` — 可选参数。 如果指定了，则同时适用于`startdate`和`enddate`。如果不指定，则使用`startdate`和`enddate`的时区。如果两个时区不一致，则结果不可预料。

**返回值**

以`unit`为单位的`startdate`和`enddate`之间的时差。

类型: `int`.

**示例**

查询:

```
SELECT dateDiff(''hour'', toDateTime(''2018-01-01 22:00:00''), toDateTime(''2018-01-02 23:00:00''));
```

结果:

```
┌─dateDiff(''hour'', toDateTime(''2018-01-01 22:00:00''), toDateTime(''2018-01-02 23:00:00''))─┐
│                                                                                     25 │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

#### timeSlots(StartTime, Duration,[, Size])

它返回一个时间数组，其中包括从从«StartTime»开始到«StartTime + Duration 秒»内的所有符合«size»（以秒为单位）步长的时间点。其中«size»是一个可选参数，默认为1800。
例如，`timeSlots(toDateTime(''2012-01-01 12:20:00'')，600) = [toDateTime（''2012-01-01 12:00:00''），toDateTime（''2012-01-01 12:30:00'' ）]`。
这对于搜索在相应会话中综合浏览量是非常有用的。

#### formatDateTime

函数根据给定的格式字符串来格式化时间。请注意：格式字符串必须是常量表达式，例如：单个结果列不能有多种格式字符串。

**语法**

```
formatDateTime(Time, Format\[, Timezone\])
```

**返回值**

根据指定格式返回的日期和时间。

**支持的格式修饰符**

使用格式修饰符来指定结果字符串的样式。«Example» 列是对`2018-01-02 22:33:44`的格式化结果。

| 修饰符 | 描述                                                         | 示例       |
| ------ | ------------------------------------------------------------ | ---------- |
| %C     | 年除以100并截断为整数(00-99)                                 | 20         |
| %d     | 月中的一天，零填充（01-31)                                   | 02         |
| %D     | 短MM/DD/YY日期，相当于%m/%d/%y                               | 01/02/2018 |
| %e     | 月中的一天，空格填充（ 1-31)                                 | 2          |
| %F     | 短YYYY-MM-DD日期，相当于%Y-%m-%d                             | 2018-01-02 |
| %G     | ISO周号的四位数年份格式， 从基于周的年份由ISO 8601定义 标准计算得出，通常仅对％V有用 | 2018       |
| %g     | 两位数的年份格式，与ISO 8601一致，四位数表示法的缩写         | 18         |
| %H     | 24小时格式（00-23)                                           | 22         |
| %I     | 12小时格式（01-12)                                           | 10         |
| %j     | 一年中的一天 (001-366)                                       | 002        |
| %m     | 月份为十进制数（01-12)                                       | 01         |
| %M     | 分钟(00-59)                                                  | 33         |
| %n     | 换行符(")                                                    |            |
| %p     | AM或PM指定                                                   | PM         |
| %Q     | 季度（1-4)                                                   | 1          |
| %R     | 24小时HH:MM时间，相当于%H:%M                                 | 22:33      |
| %S     | 秒 (00-59)                                                   | 44         |
| %t     | 水平制表符(’)                                                |            |
| %T     | ISO8601时间格式(HH:MM:SS)，相当于%H:%M:%S                    | 22:33:44   |
| %u     | ISO8601工作日为数字，星期一为1(1-7)                          | 2          |
| %V     | ISO8601周编号(01-53)                                         | 01         |
| %w     | 工作日为十进制数，周日为0(0-6)                               | 2          |
| %y     | 年份，最后两位数字（00-99)                                   | 18         |
| %Y     | 年                                                           | 2018       |
| %%     | %符号                                                        | %          |

**示例**

查询:

```
SELECT formatDateTime(toDate(''2010-01-04''), ''%g'')
```

结果:

```
┌─formatDateTime(toDate(''2010-01-04''), ''%g'')─┐
│ 10                                         │
└────────────────────────────────────────────┘
```

Original article

#### FROM_UNIXTIME

当只有单个整数类型的参数时，它的作用与`toDateTime`相同，并返回DateTime类型。

例如:

```
SELECT FROM_UNIXTIME(423543535)
┌─FROM_UNIXTIME(423543535)─┐
│      1983-06-04 10:58:55 │
└──────────────────────────┘
```

当有两个参数时，第一个是整型或DateTime，第二个是常量格式字符串，它的作用与`formatDateTime`相同，并返回`String`类型。

例如:

```
SELECT FROM_UNIXTIME(1234334543, ''%Y-%m-%d %R:%S'') AS DateTime
┌─DateTime────────────┐
│ 2009-02-11 14:42:23 │
└─────────────────────┘
```
', 0, 1, '2021-06-26 10:26:37', 1, '2021-06-26 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(46, '#### 机器学习函数

#### evalMLMethod（预测)

使用拟合回归模型的预测请使用`evalMLMethod`函数。 请参阅`linearRegression`中的链接。

#### 随机线性回归

`stochasticLinearRegression`聚合函数使用线性模型和MSE损失函数实现随机梯度下降法。 使用`evalMLMethod`来预测新数据。
请参阅示例和注释此处。

#### 随机逻辑回归

`stochasticLogisticRegression`聚合函数实现了二元分类问题的随机梯度下降法。 使用`evalMLMethod`来预测新数据。
请参阅示例和注释此处。
', 0, 1, '2021-06-27 10:26:37', 1, '2021-06-27 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(47, '#### 条件函数

#### if

控制条件分支。 与大多数系统不同，ClickHouse始终评估两个表达式 `then` 和 `else`。

**语法**

```
SELECT if(cond, then, else)
```

如果条件 `cond` 的计算结果为非零值，则返回表达式 `then` 的结果，并且跳过表达式 `else` 的结果（如果存在）。 如果 `cond` 为零或 `NULL`，则将跳过 `then` 表达式的结果，并返回 `else` 表达式的结果（如果存在）。

**参数**

- `cond` – 条件结果可以为零或不为零。 类型是 UInt8，Nullable(UInt8) 或 NULL。
- `then` - 如果满足条件则返回的表达式。
- `else` - 如果不满足条件则返回的表达式。

**返回值**

该函数执行 `then` 和 `else` 表达式并返回其结果，这取决于条件 `cond` 最终是否为零。

**示例**

查询:

```
SELECT if(1, plus(2, 2), plus(2, 6))
```

结果:

```
┌─plus(2, 2)─┐
│          4 │
└────────────┘
```

查询:

```
SELECT if(0, plus(2, 2), plus(2, 6))
```

结果:

```
┌─plus(2, 6)─┐
│          8 │
└────────────┘
```

- `then` 和 `else` 必须具有最低的通用类型。

**示例:**

给定表`LEFT_RIGHT`:

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

下面的查询比较了 `left` 和 `right` 的值:

```
SELECT
    left,
    right,
    if(left < right, ''left is smaller than right'', ''right is greater or equal than left'') AS is_smaller
FROM LEFT_RIGHT
WHERE isNotNull(left) AND isNotNull(right)

┌─left─┬─right─┬─is_smaller──────────────────────────┐
│    1 │     3 │ left is smaller than right          │
│    2 │     2 │ right is greater or equal than left │
│    3 │     1 │ right is greater or equal than left │
└──────┴───────┴─────────────────────────────────────┘
```

注意：在此示例中未使用''NULL''值，请检查条件中的NULL值 部分。

#### 三元运算符

与 `if` 函数相同。

语法: `cond ? then : else`

如果`cond ！= 0`则返回`then`，如果`cond = 0`则返回`else`。

- `cond`必须是`UInt8`类型，`then`和`else`必须存在最低的共同类型。
- `then`和`else`可以是`NULL`

#### multiIf

允许您在查询中更紧凑地编写CASE运算符。

```
multiIf(cond_1, then_1, cond_2, then_2...else)
```

**参数:**

- `cond_N` — 函数返回`then_N`的条件。
- `then_N` — 执行时函数的结果。
- `else` — 如果没有满足任何条件，则为函数的结果。

该函数接受`2N + 1`参数。

**返回值**

该函数返回值«then_N»或«else»之一，具体取决于条件`cond_N`。

**示例**

再次使用表 `LEFT_RIGHT` 。

```
SELECT
    left,
    right,
    multiIf(left < right, ''left is smaller'', left > right, ''left is greater'', left = right, ''Both equal'', ''Null value'') AS result
FROM LEFT_RIGHT

┌─left─┬─right─┬─result──────────┐
│ ᴺᵁᴸᴸ │     4 │ Null value      │
│    1 │     3 │ left is smaller │
│    2 │     2 │ Both equal      │
│    3 │     1 │ left is greater │
│    4 │  ᴺᵁᴸᴸ │ Null value      │
└──────┴───────┴─────────────────┘
```

#### 直接使用条件结果

条件结果始终为 `0`、 `1` 或 `NULL`。 因此，你可以像这样直接使用条件结果：

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

#### 条件中的NULL值

当条件中包含 `NULL` 值时，结果也将为 `NULL`。

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

因此，如果类型是 `Nullable`，你应该仔细构造查询。

以下示例说明这一点。

```
SELECT
    left,
    right,
    multiIf(left < right, ''left is smaller'', left > right, ''right is smaller'', ''Both equal'') AS faulty_result
FROM LEFT_RIGHT

┌─left─┬─right─┬─faulty_result────┐
│ ᴺᵁᴸᴸ │     4 │ Both equal       │
│    1 │     3 │ left is smaller  │
│    2 │     2 │ Both equal       │
│    3 │     1 │ right is smaller │
│    4 │  ᴺᵁᴸᴸ │ Both equal       │
└──────┴───────┴──────────────────┘
```
', 0, 1, '2021-06-28 10:26:37', 1, '2021-06-28 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(48, '#### 编码函数

#### char

返回长度为传递参数数量的字符串，并且每个字节都有对应参数的值。接受数字Numeric类型的多个参数。如果参数的值超出了UInt8数据类型的范围，则将其转换为UInt8，并可能进行舍入和溢出。

**语法**

```
char(number_1, [number_2, ..., number_n]);
```

**参数**

- `number_1, number_2, ..., number_n` — 数值参数解释为整数。类型: Int, Float.

**返回值**

- 给定字节数的字符串。

类型: `String`。

**示例**

查询:

```
SELECT char(104.1, 101, 108.9, 108.9, 111) AS hello
```

结果:

```
┌─hello─┐
│ hello │
└───────┘
```

你可以通过传递相应的字节来构造任意编码的字符串。 这是UTF-8的示例:

查询:

```
SELECT char(0xD0, 0xBF, 0xD1, 0x80, 0xD0, 0xB8, 0xD0, 0xB2, 0xD0, 0xB5, 0xD1, 0x82) AS hello;
```

结果:

```
┌─hello──┐
│ привет │
└────────┘
```

查询:

```
SELECT char(0xE4, 0xBD, 0xA0, 0xE5, 0xA5, 0xBD) AS hello;
```

结果:

```
┌─hello─┐
│ 你好  │
└───────┘
```

#### hex

接受`String`，`unsigned integer`，`Date`或`DateTime`类型的参数。返回包含参数的十六进制表示的字符串。使用大写字母`A-F`。不使用`0x`前缀或`h`后缀。对于字符串，所有字节都简单地编码为两个十六进制数字。数字转换为大端（«易阅读»）格式。对于数字，去除其中较旧的零，但仅限整个字节。例如，`hex（1）=''01''`。 `Date`被编码为自Unix时间开始以来的天数。 `DateTime`编码为自Unix时间开始以来的秒数。

#### unhex(str)

接受包含任意数量的十六进制数字的字符串，并返回包含相应字节的字符串。支持大写和小写字母A-F。十六进制数字的数量不必是偶数。如果是奇数，则最后一位数被解释为00-0F字节的低位。如果参数字符串包含除十六进制数字以外的任何内容，则返回一些实现定义的结果（不抛出异常）。
如果要将结果转换为数字，可以使用«reverse»和«reinterpretAsType»函数。

#### UUIDStringToNum(str)

接受包含36个字符的字符串，格式为«123e4567-e89b-12d3-a456-426655440000»，并将其转化为FixedString（16）返回。

#### UUIDNumToString(str)

接受FixedString（16）值。返回包含36个字符的文本格式的字符串。

#### bitmaskToList(num)

接受一个整数。返回一个字符串，其中包含一组2的幂列表，其列表中的所有值相加等于这个整数。列表使用逗号分割，按升序排列。

#### bitmaskToArray(num)

接受一个整数。返回一个UInt64类型数组，其中包含一组2的幂列表，其列表中的所有值相加等于这个整数。数组中的数字按升序排列。
', 0, 1, '2021-06-29 10:26:37', 1, '2021-06-29 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(49, '#### 随机函数

随机函数使用非加密方式生成伪随机数字。

所有随机函数都只接受一个参数或不接受任何参数。
您可以向它传递任何类型的参数，但传递的参数将不会使用在任何随机数生成过程中。
此参数的唯一目的是防止公共子表达式消除，以便在相同的查询中使用相同的随机函数生成不同的随机数。

#### rand, rand32

返回一个UInt32类型的随机数字，所有UInt32类型的数字被生成的概率均相等。此函数线性同于的方式生成随机数。

#### rand64

返回一个UInt64类型的随机数字，所有UInt64类型的数字被生成的概率均相等。此函数线性同于的方式生成随机数。

#### randConstant

返回一个UInt32类型的随机数字，该函数不同之处在于仅为每个数据块参数一个随机数。
', 0, 1, '2021-06-30 10:26:37', 1, '2021-06-30 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(50, '#### 高阶函数

#### `->` 运算符, lambda(params, expr) 函数

用于描述一个lambda函数用来传递给其他高阶函数。箭头的左侧有一个形式参数，它可以是一个标识符或多个标识符所组成的元祖。箭头的右侧是一个表达式，在这个表达式中可以使用形式参数列表中的任何一个标识符或表的任何一个列名。

示例: `x -> 2 * x, str -> str != Referer.`

高阶函数只能接受lambda函数作为其参数。

高阶函数可以接受多个参数的lambda函数作为其参数，在这种情况下，高阶函数需要同时传递几个长度相等的数组，这些数组将被传递给lambda参数。

除了’arrayMap’和’arrayFilter’以外的所有其他函数，都可以省略第一个参数（lambda函数）。在这种情况下，默认返回数组元素本身。

#### arrayMap(func, arr1, …)

将arr
将从’func’函数的原始应用程序获得的数组返回到’arr’数组中的每个元素。
返回从原始应用程序获得的数组 ‘func’ 函数中的每个元素 ‘arr’ 阵列。

#### arrayFilter(func, arr1, …)

返回一个仅包含以下元素的数组 ‘arr1’ 对于哪个 ‘func’ 返回0以外的内容。

示例:

```
SELECT arrayFilter(x -> x LIKE ''%World%'', [''Hello'', ''abc World'']) AS res
┌─res───────────┐
│ [''abc World''] │
└───────────────┘
SELECT
    arrayFilter(
        (i, x) -> x LIKE ''%World%'',
        arrayEnumerate(arr),
        [''Hello'', ''abc World''] AS arr)
    AS res
┌─res─┐
│ [2] │
└─────┘
```

#### arrayCount([func,] arr1, …)

返回数组arr中非零元素的数量，如果指定了’func’，则通过’func’的返回值确定元素是否为非零元素。

#### arrayExists([func,] arr1, …)

返回数组’arr’中是否存在非零元素，如果指定了’func’，则使用’func’的返回值确定元素是否为非零元素。

#### arrayAll([func,] arr1, …)

返回数组’arr’中是否存在为零的元素，如果指定了’func’，则使用’func’的返回值确定元素是否为零元素。

#### arraySum([func,] arr1, …)

计算arr数组的总和，如果指定了’func’，则通过’func’的返回值计算数组的总和。

#### arrayFirst(func, arr1, …)

返回数组中第一个匹配的元素，函数使用’func’匹配所有元素，直到找到第一个匹配的元素。

#### arrayFirstIndex(func, arr1, …)

返回数组中第一个匹配的元素的下标索引，函数使用’func’匹配所有元素，直到找到第一个匹配的元素。

#### arrayCumSum([func,] arr1, …)

返回源数组部分数据的总和，如果指定了`func`函数，则使用`func`的返回值计算总和。

示例:

```
SELECT arrayCumSum([1, 1, 1, 1]) AS res
┌─res──────────┐
│ [1, 2, 3, 4] │
└──────────────┘
```

#### arrayCumSumNonNegative(arr)

与arrayCumSum相同，返回源数组部分数据的总和。不同于arrayCumSum，当返回值包含小于零的值时，该值替换为零，后续计算使用零继续计算。例如：

```
SELECT arrayCumSumNonNegative([1, 1, -4, 1]) AS res
┌─res───────┐
│ [1,2,0,1] │
└───────────┘
```

#### arraySort([func,] arr1, …)

返回升序排序`arr1`的结果。如果指定了`func`函数，则排序顺序由`func`的结果决定。

Schwartzian变换用于提高排序效率。

示例:

```
SELECT arraySort((x, y) -> y, [''hello'', ''world''], [2, 1]);
┌─res────────────────┐
│ [''world'', ''hello''] │
└────────────────────┘
```

请注意，NULL和NaN在最后（NaN在NULL之前）。例如：

```
SELECT arraySort([1, nan, 2, NULL, 3, nan, 4, NULL])
┌─arraySort([1, nan, 2, NULL, 3, nan, 4, NULL])─┐
│ [1,2,3,4,nan,nan,NULL,NULL]                   │
└───────────────────────────────────────────────┘
```

#### arrayReverseSort([func,] arr1, …)

返回降序排序`arr1`的结果。如果指定了`func`函数，则排序顺序由`func`的结果决定。

请注意，NULL和NaN在最后（NaN在NULL之前）。例如：

```
SELECT arrayReverseSort([1, nan, 2, NULL, 3, nan, 4, NULL])
┌─arrayReverseSort([1, nan, 2, NULL, 3, nan, 4, NULL])─┐
│ [4,3,2,1,nan,nan,NULL,NULL]                          │
└──────────────────────────────────────────────────────┘
```
', 0, 1, '2021-07-01 10:26:37', 1, '2021-07-01 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(51, '#### 聚合函数

聚合函数如数据库专家预期的方式 正常 工作。

ClickHouse还支持:

- 参数聚合函数，它接受除列之外的其他参数。
- 组合器，这改变了聚合函数的行为。

#### 空处理

在聚合过程中，所有 `NULL` 被跳过。

**例:**

考虑这个表:

```
┌─x─┬────y─┐
│ 1 │    2 │
│ 2 │ ᴺᵁᴸᴸ │
│ 3 │    2 │
│ 3 │    3 │
│ 3 │ ᴺᵁᴸᴸ │
└───┴──────┘
```

比方说，你需要计算 `y` 列的总数:

```
SELECT sum(y) FROM t_null_big
┌─sum(y)─┐
│      7 │
└────────┘
```

现在你可以使用 `groupArray` 函数用 `y` 列创建一个数组:

```
SELECT groupArray(y) FROM t_null_big
┌─groupArray(y)─┐
│ [2,2,3]       │
└───────────────┘
```

在 `groupArray` 生成的数组中不包括 `NULL`。
', 0, 1, '2021-07-02 10:26:37', 1, '2021-07-02 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(53, '#### 聚合函数组合器

聚合函数的名称可以附加一个后缀。 这改变了聚合函数的工作方式。

#### -If

-If可以加到任何聚合函数之后。加了-If之后聚合函数需要接受一个额外的参数，一个条件（Uint8类型），如果条件满足，那聚合函数处理当前的行数据，如果不满足，那返回默认值（通常是0或者空字符串）。

例： `sumIf(column, cond)`, `countIf(cond)`, `avgIf(x, cond)`, `quantilesTimingIf(level1, level2)(x, cond)`, `argMinIf(arg, val, cond)` 等等。

使用条件聚合函数，您可以一次计算多个条件的聚合，而无需使用子查询和 `JOIN`例如，在Yandex.Metrica，条件聚合函数用于实现段比较功能。

#### -Array

-Array后缀可以附加到任何聚合函数。 在这种情况下，聚合函数采用的参数 ‘Array(T)’ 类型（数组）而不是 ‘T’ 类型参数。 如果聚合函数接受多个参数，则它必须是长度相等的数组。 在处理数组时，聚合函数的工作方式与所有数组元素的原始聚合函数类似。

示例1： `sumArray(arr)` -总计所有的所有元素 ‘arr’ 阵列。在这个例子中，它可以更简单地编写: `sum(arraySum(arr))`.

示例2： `uniqArray(arr)` – 计算‘arr’中唯一元素的个数。这可以是一个更简单的方法： `uniq(arrayJoin(arr))`，但它并不总是可以添加 ‘arrayJoin’ 到查询。

如果和-If组合，‘Array’ 必须先来，然后 ‘If’. 例： `uniqArrayIf(arr, cond)`， `quantilesTimingArrayIf(level1, level2)(arr, cond)`。由于这个顺序，该 ‘cond’ 参数不会是数组。

#### -State

如果应用此combinator，则聚合函数不会返回结果值（例如唯一值的数量 uniq 函数），但是返回聚合的中间状态（对于 `uniq`，返回的是计算唯一值的数量的哈希表）。 这是一个 `AggregateFunction(...)` 可用于进一步处理或存储在表中以完成稍后的聚合。

要使用这些状态，请使用:

- AggregatingMergeTree 表引擎。
- finalizeAggregation 功能。
- runningAccumulate 功能。
- -Merge combinator
- -MergeState combinator

#### -Merge

如果应用此组合器，则聚合函数将中间聚合状态作为参数，组合状态以完成聚合，并返回结果值。

#### -MergeState

以与-Merge 相同的方式合并中间聚合状态。 但是，它不会返回结果值，而是返回中间聚合状态，类似于-State。

#### -ForEach

将表的聚合函数转换为聚合相应数组项并返回结果数组的数组的聚合函数。 例如, `sumForEach` 对于数组 `[1, 2]`, `[3, 4, 5]`和`[6, 7]`返回结果 `[10, 13, 5]` 之后将相应的数组项添加在一起。

#### -OrDefault

更改聚合函数的行为。

如果聚合函数没有输入值，则使用此组合器它返回其返回数据类型的默认值。 适用于可以采用空输入数据的聚合函数。

`-OrDefault` 可与其他组合器一起使用。

**语法**

```
<aggFunction>OrDefault(x)
```

**参数**

- `x` — 聚合函数参数。

**返回值**

如果没有要聚合的内容，则返回聚合函数返回类型的默认值。

类型取决于所使用的聚合函数。

**示例**

查询:

```
SELECT avg(number), avgOrDefault(number) FROM numbers(0)
```

结果:

```
┌─avg(number)─┬─avgOrDefault(number)─┐
│         nan │                    0 │
└─────────────┴──────────────────────┘
```

还有 `-OrDefault` 可与其他组合器一起使用。 当聚合函数不接受空输入时，它很有用。

查询:

```
SELECT avgOrDefaultIf(x, x > 10)
FROM
(
    SELECT toDecimal32(1.23, 2) AS x
)
```

结果:

```
┌─avgOrDefaultIf(x, greater(x, 10))─┐
│                              0.00 │
└───────────────────────────────────┘
```

#### -OrNull

更改聚合函数的行为。

此组合器将聚合函数的结果转换为 可为空 数据类型。 如果聚合函数没有值来计算它返回 NULL.

`-OrNull` 可与其他组合器一起使用。

**语法**

```
<aggFunction>OrNull(x)
```

**参数**

- `x` — Aggregate function parameters.

**返回值**

- 聚合函数的结果，转换为 `Nullable` 数据类型。
- `NULL`，如果没有什么聚合。

类型: `Nullable(aggregate function return type)`.

**示例**

添加 `-orNull` 到聚合函数的末尾。

查询:

```
SELECT sumOrNull(number), toTypeName(sumOrNull(number)) FROM numbers(10) WHERE number > 10
```

结果:

```
┌─sumOrNull(number)─┬─toTypeName(sumOrNull(number))─┐
│              ᴺᵁᴸᴸ │ Nullable(UInt64)              │
└───────────────────┴───────────────────────────────┘
```

还有 `-OrNull` 可与其他组合器一起使用。 当聚合函数不接受空输入时，它很有用。

查询:

```
SELECT avgOrNullIf(x, x > 10)
FROM
(
    SELECT toDecimal32(1.23, 2) AS x
)
```

结果:

```
┌─avgOrNullIf(x, greater(x, 10))─┐
│                           ᴺᵁᴸᴸ │
└────────────────────────────────┘
```

#### -Resample

允许您将数据划分为组，然后单独聚合这些组中的数据。 通过将一列中的值拆分为间隔来创建组。

```
<aggFunction>Resample(start, end, step)(<aggFunction_params>, resampling_key)
```

**参数**

- `start` — `resampling_key` 开始值。
- `stop` — `resampling_key` 结束边界。 区间内部不包含 `stop` 值，即 `[start, stop)`.
- `step` — 分组的步长。 The `aggFunction` 在每个子区间上独立执行。
- `resampling_key` — 取样列，被用来分组.
- `aggFunction_params` — `aggFunction` 参数。

**返回值**

- `aggFunction` 每个子区间的结果，结果为数组。

**示例**

考虑一下 `people` 表具有以下数据的表结构：

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

让我们得到的人的名字，他们的年龄在于的时间间隔 `[30,60)` 和 `[60,75)`。 由于我们使用整数表示的年龄，我们得到的年龄 `[30, 59]` 和 `[60,74]` 间隔。

要在数组中聚合名称，我们使用 groupArray 聚合函数。 这需要一个参数。 在我们的例子中，它是 `name` 列。 `groupArrayResample` 函数应该使用 `age` 按年龄聚合名称， 要定义所需的时间间隔，我们传入 `30, 75, 30` 参数给 `groupArrayResample` 函数。

```
SELECT groupArrayResample(30, 75, 30)(name, age) FROM people
┌─groupArrayResample(30, 75, 30)(name, age)─────┐
│ [[''Alice'',''Mary'',''Evelyn''],[''David'',''Brian'']] │
└───────────────────────────────────────────────┘
```

考虑结果。

`Jonh` 没有被选中，因为他太年轻了。 其他人按照指定的年龄间隔进行分配。

现在让我们计算指定年龄间隔内的总人数和平均工资。

```
SELECT
    countResample(30, 75, 30)(name, age) AS amount,
    avgResample(30, 75, 30)(wage, age) AS avg_wage
FROM people
┌─amount─┬─avg_wage──────────────────┐
│ [3,2]  │ [11.5,12.949999809265137] │
└────────┴───────────────────────────┘
```
', 0, 1, '2021-07-03 10:26:37', 1, '2021-07-03 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(54, '#### 参数聚合函数

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

- Array



  的



  Tuples



  如下：

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
', 0, 1, '2021-07-04 10:26:37', 1, '2021-07-04 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(55, '#### 选择查询

`SELECT` 查询执行数据检索。 默认情况下，请求的数据返回给客户端，同时结合 INSERT INTO 可以被转发到不同的表。

#### 语法

```
[WITH expr_list|(subquery)]
SELECT [DISTINCT] expr_list
[FROM [db.]table | (subquery) | table_function] [FINAL]
[SAMPLE sample_coeff]
[ARRAY JOIN ...]
[GLOBAL] [ANY|ALL|ASOF] [INNER|LEFT|RIGHT|FULL|CROSS] [OUTER|SEMI|ANTI] JOIN (subquery)|table (ON <expr_list>)|(USING <column_list>)
[PREWHERE expr]
[WHERE expr]
[GROUP BY expr_list] [WITH TOTALS]
[HAVING expr]
[ORDER BY expr_list] [WITH FILL] [FROM expr] [TO expr] [STEP expr]
[LIMIT [offset_value, ]n BY columns]
[LIMIT [n, ]m] [WITH TIES]
[UNION ALL ...]
[INTO OUTFILE filename]
[FORMAT format]
```

所有子句都是可选的，但紧接在 `SELECT` 后面的必需表达式列表除外，更详细的请看 下面.

每个可选子句的具体内容在单独的部分中进行介绍，这些部分按与执行顺序相同的顺序列出:

- WITH 子句
- FROM 子句
- SAMPLE 子句
- JOIN 子句
- PREWHERE 子句
- WHERE 子句
- GROUP BY 子句
- LIMIT BY 子句
- HAVING 子句
- SELECT 子句
- DISTINCT 子句
- LIMIT 子句
- UNION ALL 子句
- INTO OUTFILE 子句
- FORMAT 子句

#### SELECT 子句

表达式 指定 `SELECT` 子句是在上述子句中的所有操作完成后计算的。 这些表达式的工作方式就好像它们应用于结果中的单独行一样。 如果表达式 `SELECT` 子句包含聚合函数，然后ClickHouse将使用 GROUP BY 聚合参数应用在聚合函数和表达式上。

如果在结果中包含所有列，请使用星号 (`*`）符号。 例如, `SELECT * FROM ...`.

将结果中的某些列与 re2 正则表达式匹配，可以使用 `COLUMNS` 表达。

```
COLUMNS(''regexp'')
```

例如表:

```
CREATE TABLE default.col_names (aa Int8, ab Int8, bc Int8) ENGINE = TinyLog
```

以下查询所有列名包含 `a` 。

```
SELECT COLUMNS(''a'') FROM col_names
┌─aa─┬─ab─┐
│  1 │  1 │
└────┴────┘
```

所选列不按字母顺序返回。

您可以使用多个 `COLUMNS` 表达式并将函数应用于它们。

例如:

```
SELECT COLUMNS(''a''), COLUMNS(''c''), toTypeName(COLUMNS(''c'')) FROM col_names
┌─aa─┬─ab─┬─bc─┬─toTypeName(bc)─┐
│  1 │  1 │  1 │ Int8           │
└────┴────┴────┴────────────────┘
```

返回的每一列 `COLUMNS` 表达式作为单独的参数传递给函数。 如果函数支持其他参数，您也可以将其他参数传递给函数。 使用函数时要小心，如果函数不支持传递给它的参数，ClickHouse将抛出异常。

例如:

```
SELECT COLUMNS(''a'') + COLUMNS(''c'') FROM col_names
Received exception from server (version 19.14.1):
Code: 42. DB::Exception: Received from localhost:9000. DB::Exception: Number of arguments for function plus doesn''t match: passed 3, should be 2.
```

该例子中, `COLUMNS(''a'')` 返回两列: `aa` 和 `ab`. `COLUMNS(''c'')` 返回 `bc` 列。 该 `+` 运算符不能应用于3个参数，因此ClickHouse抛出一个带有相关消息的异常。

匹配的列 `COLUMNS` 表达式可以具有不同的数据类型。 如果 `COLUMNS` 不匹配任何列，并且是在 `SELECT` 唯一的表达式，ClickHouse则抛出异常。

#### 星号

您可以在查询的任何部分使用星号替代表达式。进行查询分析、时，星号将展开为所有表的列（不包括 `MATERIALIZED` 和 `ALIAS` 列）。 只有少数情况下使用星号是合理的:

- 创建转储表时。
- 对于只包含几列的表，例如系统表。
- 获取表中列的信息。 在这种情况下，设置 `LIMIT 1`. 但最好使用 `DESC TABLE` 查询。
- 当对少量列使用 `PREWHERE` 进行强过滤时。
- 在子查询中（因为外部查询不需要的列从子查询中排除）。

在所有其他情况下，我们不建议使用星号，因为它只给你一个列DBMS的缺点，而不是优点。 换句话说，不建议使用星号。

#### 极端值

除结果之外，还可以获取结果列的最小值和最大值。 要做到这一点，设置 **extremes** 设置为1。 最小值和最大值是针对数字类型、日期和带有时间的日期计算的。 对于其他类型列，输出默认值。

分别的额外计算两行 – 最小值和最大值。 这额外的两行采用输出格式为 `JSON*`, `TabSeparated*`，和 `Pretty*` formats，与其他行分开。 它们不以其他格式输出。

为 `JSON*` 格式时，极端值单独的输出在 ‘extremes’ 字段。 为 `TabSeparated*` 格式时，此行来的主要结果集后，然后显示 ‘totals’ 字段。 它前面有一个空行（在其他数据之后）。 在 `Pretty*` 格式时，该行在主结果之后输出为一个单独的表，然后显示 ‘totals’ 字段。

极端值在 `LIMIT` 之前被计算，但在 `LIMIT BY` 之后被计算. 然而，使用 `LIMIT offset, size`， `offset` 之前的行都包含在 `extremes`. 在流请求中，结果还可能包括少量通过 `LIMIT` 过滤的行.

#### 备注

您可以在查询的任何部分使用同义词 (`AS` 别名）。

`GROUP BY` 和 `ORDER BY` 子句不支持位置参数。 这与MySQL相矛盾，但符合标准SQL。 例如, `GROUP BY 1, 2` 将被理解为根据常量分组 (i.e. aggregation of all rows into one).

#### 实现细节

如果查询省略 `DISTINCT`, `GROUP BY` ， `ORDER BY` ， `IN` ， `JOIN` 子查询，查询将被完全流处理，使用O(1)量的RAM。 若未指定适当的限制，则查询可能会消耗大量RAM:

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

有关详细信息，请参阅部分 “Settings”. 可以使用外部排序（将临时表保存到磁盘）和外部聚合。
', 0, 1, '2021-07-05 10:26:37', 1, '2021-07-05 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(56, '#### ALL 子句

`SELECT ALL` 和 `SELECT` 不带 `DISTINCT` 是一样的。

- 如果指定了 `ALL` ，则忽略它。
- 如果同时指定了 `ALL` 和 `DISTINCT` ，则会抛出异常。

`ALL` 也可以在聚合函数中指定，具有相同的效果（空操作）。例如：

```
SELECT sum(ALL number) FROM numbers(10);
```

等于

```
SELECT sum(number) FROM numbers(10);
```
', 0, 1, '2021-07-06 10:26:37', 1, '2021-07-06 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(57, '#### ARRAY JOIN子句

对于包含数组列的表来说是一种常见的操作，用于生成一个新表，该表具有包含该初始列中的每个单独数组元素的列，而其他列的值将被重复显示。 这是 `ARRAY JOIN` 语句最基本的场景。

它可以被视为执行 `JOIN` 并具有数组或嵌套数据结构。 类似于 arrayJoin 功能，但该子句功能更广泛。

语法:

```
SELECT <expr_list>
FROM <left_subquery>
[LEFT] ARRAY JOIN <array>
[WHERE|PREWHERE <expr>]
...
```

您只能在 `SELECT` 查询指定一个 `ARRAY JOIN` 。

`ARRAY JOIN` 支持的类型有:

- `ARRAY JOIN` - 一般情况下，空数组不包括在结果中 `JOIN`.
- `LEFT ARRAY JOIN` - 的结果 `JOIN` 包含具有空数组的行。 空数组的值设置为数组元素类型的默认值（通常为0、空字符串或NULL）。

#### 基本 ARRAY JOIN 示例

下面的例子展示 `ARRAY JOIN` 和 `LEFT ARRAY JOIN` 的用法，让我们创建一个表包含一个 Array 的列并插入值:

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

下面的例子使用 `ARRAY JOIN` 子句:

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

下一个示例使用 `LEFT ARRAY JOIN` 子句:

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

#### 使用别名

在使用`ARRAY JOIN` 时可以为数组指定别名，数组元素可以通过此别名访问，但数组本身则通过原始名称访问。 示例:

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

可以使用别名与外部数组执行 `ARRAY JOIN` 。 例如:

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

在 `ARRAY JOIN` 中，多个数组可以用逗号分隔, 在这例子中 `JOIN` 与它们同时执行（直接sum，而不是笛卡尔积）。 请注意，所有数组必须具有相同的大小。 示例:

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

下面的例子使用 arrayEnumerate 功能:

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

#### 具有嵌套数据结构的数组连接

`ARRAY JOIN` 也适用于 嵌套数据结构:

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

当指定嵌套数据结构的名称 `ARRAY JOIN`，意思是一样的 `ARRAY JOIN` 它包含的所有数组元素。 下面列出了示例:

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

这种变化也是有道理的:

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

可以将别名用于嵌套数据结构，以便选择 `JOIN` 结果或源数组。 例如:

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

使用功能 arrayEnumerate 的例子:

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

#### 实现细节

运行时优化查询执行顺序 `ARRAY JOIN`. 虽然 `ARRAY JOIN` 必须始终之前指定 WHERE 子句中的查询，从技术上讲，它们可以以任何顺序执行，除非结果 `ARRAY JOIN` 用于过滤。 处理顺序由查询优化器控制。
', 0, 1, '2021-07-07 10:26:37', 1, '2021-07-07 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(58, '#### DISTINCT子句

如果 `SELECT DISTINCT` 被声明，则查询结果中只保留唯一行。 因此，在结果中所有完全匹配的行集合中，只有一行被保留。

#### 空处理

`DISTINCT` 适用于 NULL 就好像 `NULL` 是一个特定的值，并且 `NULL==NULL`. 换句话说，在 `DISTINCT` 结果，不同的组合 `NULL` 仅发生一次。 它不同于 `NULL` 在大多数其他情况中的处理方式。

#### 替代办法

通过应用可以获得相同的结果 GROUP BY 在同一组值指定为 `SELECT` 子句，并且不使用任何聚合函数。 但与 `GROUP BY` 有几个不同的地方:

- `DISTINCT` 可以与 `GROUP BY` 一起使用.
- 当 ORDER BY 被省略并且 LIMIT 被定义时，在读取所需数量的不同行后立即停止运行。
- 数据块在处理时输出，而无需等待整个查询完成运行。

#### 限制

`DISTINCT` 不支持当 `SELECT` 包含有数组的列。

#### 例子

ClickHouse支持使用 `DISTINCT` 和 `ORDER BY` 在一个查询中的不同的列。 `DISTINCT` 子句在 `ORDER BY` 子句前被执行。

示例表:

```
┌─a─┬─b─┐
│ 2 │ 1 │
│ 1 │ 2 │
│ 3 │ 3 │
│ 2 │ 4 │
└───┴───┘
```

当执行 `SELECT DISTINCT a FROM t1 ORDER BY b ASC` 来查询数据，我们得到以下结果:

```
┌─a─┐
│ 2 │
│ 1 │
│ 3 │
└───┘
```

如果我们改变排序方向 `SELECT DISTINCT a FROM t1 ORDER BY b DESC`，我们得到以下结果:

```
┌─a─┐
│ 3 │
│ 1 │
│ 2 │
└───┘
```

行 `2, 4` 排序前被切割。

在编程查询时考虑这种实现特性。
', 0, 1, '2021-07-08 10:26:37', 1, '2021-07-08 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(59, '#### 格式化子句

ClickHouse支持广泛的 序列化格式 可用于查询结果等。 有多种方法可以选择格式化 `SELECT` 的输出，其中之一是指定 `FORMAT format` 在查询结束时以任何特定格式获取结果集。

特定的格式方便使用，与其他系统集成或增强性能。

#### 默认格式

如果 `FORMAT` 被省略则使用默认格式，这取决于用于访问ClickHouse服务器的设置和接口。 为 HTTP接口 和 命令行客户端 在批处理模式下，默认格式为 `TabSeparated`. 对于交互模式下的命令行客户端，默认格式为 `PrettyCompact` （它生成紧凑的人类可读表）。

#### 实现细节

使用命令行客户端时，数据始终以内部高效格式通过网络传递 (`Native`). 客户端独立解释 `FORMAT` 查询子句并格式化数据本身（以减轻网络和服务器的额外负担）。
', 0, 1, '2021-07-09 10:26:37', 1, '2021-07-09 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(60, '#### FROM子句

`FROM` 子句指定从以下数据源中读取数据:

- 表
- 子查询
- 表函数

JOIN 和 ARRAY JOIN 子句也可以用来扩展 `FROM` 的功能

子查询是另一个 `SELECT` 可以指定在 `FROM` 后的括号内的查询。

`FROM` 子句可以包含多个数据源，用逗号分隔，这相当于在他们身上执行 CROSS JOIN

#### FINAL 修饰符

当 `FINAL` 被指定，ClickHouse会在返回结果之前完全合并数据，从而执行给定表引擎合并期间发生的所有数据转换。

它适用于从使用 MergeTree-引擎族（除了 `GraphiteMergeTree`). 还支持:

- Replicated 版本 `MergeTree` 引擎
- View, Buffer, Distributed，和 MaterializedView 在其他引擎上运行的引擎，只要是它们底层是 `MergeTree`-引擎表即可。

现在使用 `FINAL` 修饰符 的 `SELECT` 查询启用了并发执行, 这会快一点。但是仍然存在缺陷 (见下)。 max_final_threads 设置使用的最大线程数限制。

#### 缺点

使用的查询 `FINAL` 执行速度比类似的查询慢一点，因为:

- 在查询执行期间合并数据。
- 查询与 `FINAL` 除了读取查询中指定的列之外，还读取主键列。

**在大多数情况下，避免使用 FINAL.** 常见的方法是使用假设后台进程的不同查询 `MergeTree` 引擎还没有发生，并通过应用聚合（例如，丢弃重复项）来处理它。

#### 实现细节

如果 `FROM` 子句被省略，数据将从读取 `system.one` 表。
该 `system.one` 表只包含一行（此表满足与其他 DBMS 中的 DUAL 表有相同的作用）。

若要执行查询，将从相应的表中提取查询中列出的所有列。 外部查询不需要的任何列都将从子查询中抛出。
如果查询未列出任何列（例如, `SELECT count() FROM t`），无论如何都会从表中提取一些列（首选是最小的列），以便计算行数。
', 0, 1, '2021-07-10 10:26:37', 1, '2021-07-10 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(61, '#### GROUP BY子句

`GROUP BY` 子句将 `SELECT` 查询结果转换为聚合模式，其工作原理如下:

- `GROUP BY` 子句包含表达式列表（或单个表达式 -- 可以认为是长度为1的列表）。 这份名单充当 “grouping key”，而每个单独的表达式将被称为 “key expressions”.
- 在所有的表达式在 SELECT, HAVING，和 ORDER BY 子句中 **必须** 基于键表达式进行计算 **或** 上 聚合函数 在非键表达式（包括纯列）上。 换句话说，从表中选择的每个列必须用于键表达式或聚合函数内，但不能同时使用。
- 聚合结果 `SELECT` 查询将包含尽可能多的行，因为有唯一值 “grouping key” 在源表中。 通常这会显着减少行数，通常是数量级，但不一定：如果所有行数保持不变 “grouping key” 值是不同的。

注

还有一种额外的方法可以在表上运行聚合。 如果查询仅在聚合函数中包含表列，则 `GROUP BY` 可以省略，并且通过一个空的键集合来假定聚合。 这样的查询总是只返回一行。

#### 空处理

对于分组，ClickHouse解释 NULL 作为一个值，并且 `NULL==NULL`. 它不同于 `NULL` 在大多数其他上下文中的处理方式。

这里有一个例子来说明这意味着什么。

假设你有一张表:

```
┌─x─┬────y─┐
│ 1 │    2 │
│ 2 │ ᴺᵁᴸᴸ │
│ 3 │    2 │
│ 3 │    3 │
│ 3 │ ᴺᵁᴸᴸ │
└───┴──────┘
```

查询 `SELECT sum(x), y FROM t_null_big GROUP BY y` 结果:

```
┌─sum(x)─┬────y─┐
│      4 │    2 │
│      3 │    3 │
│      5 │ ᴺᵁᴸᴸ │
└────────┴──────┘
```

你可以看到 `GROUP BY` 为 `y = NULL` 总结 `x`，仿佛 `NULL` 是这个值。

如果你通过几个键 `GROUP BY`，结果会给你选择的所有组合，就好像 `NULL` 是一个特定的值。

#### WITH TOTAL 修饰符

如果 `WITH TOTALS` 被指定，将计算另一行。 此行将具有包含默认值（零或空行）的关键列，以及包含跨所有行计算值的聚合函数列（ “total” 值）。

这个额外的行仅产生于 `JSON*`, `TabSeparated*`，和 `Pretty*` 格式，与其他行分开:

- 在 `JSON*` 格式，这一行是作为一个单独的输出 ‘totals’ 字段。
- 在 `TabSeparated*` 格式，该行位于主结果之后，前面有一个空行（在其他数据之后）。
- 在 `Pretty*` 格式时，该行在主结果之后作为单独的表输出。
- 在其他格式中，它不可用。

`WITH TOTALS` 可以以不同的方式运行时 HAVING 是存在的。 该行为取决于 `totals_mode` 设置。

#### 配置总和处理

默认情况下, `totals_mode = ''before_having''`. 在这种情况下, ‘totals’ 是跨所有行计算，包括那些不通过具有和 `max_rows_to_group_by`.

其他替代方案仅包括通过具有在 ‘totals’，并与设置不同的行为 `max_rows_to_group_by` 和 `group_by_overflow_mode = ''any''`.

`after_having_exclusive` – Don''t include rows that didn''t pass through `max_rows_to_group_by`. 换句话说, ‘totals’ 将有少于或相同数量的行，因为它会 `max_rows_to_group_by` 被省略。

`after_having_inclusive` – Include all the rows that didn''t pass through ‘max_rows_to_group_by’ 在 ‘totals’. 换句话说, ‘totals’ 将有多个或相同数量的行，因为它会 `max_rows_to_group_by` 被省略。

`after_having_auto` – Count the number of rows that passed through HAVING. If it is more than a certain amount (by default, 50%), include all the rows that didn''t pass through ‘max_rows_to_group_by’ 在 ‘totals’. 否则，不包括它们。

`totals_auto_threshold` – By default, 0.5. The coefficient for `after_having_auto`.

如果 `max_rows_to_group_by` 和 `group_by_overflow_mode = ''any''` 不使用，所有的变化 `after_having` 是相同的，你可以使用它们中的任何一个（例如, `after_having_auto`).

您可以使用 `WITH TOTALS` 在子查询中，包括在子查询 JOIN 子句（在这种情况下，将各自的总值合并）。

#### 例子

示例:

```
SELECT
    count(),
    median(FetchTiming > 60 ? 60 : FetchTiming),
    count() - sum(Refresh)
FROM hits
```

但是，与标准SQL相比，如果表没有任何行（根本没有任何行，或者使用 WHERE 过滤之后没有任何行），则返回一个空结果，而不是来自包含聚合函数初始值的行。

相对于MySQL（并且符合标准SQL），您无法获取不在键或聚合函数（常量表达式除外）中的某些列的某些值。 要解决此问题，您可以使用 ‘any’ 聚合函数（获取第一个遇到的值）或 ‘min/max’.

示例:

```
SELECT
    domainWithoutWWW(URL) AS domain,
    count(),
    any(Title) AS title -- getting the first occurred page header for each domain.
FROM hits
GROUP BY domain
```

对于遇到的每个不同的键值, `GROUP BY` 计算一组聚合函数值。

`GROUP BY` 不支持数组列。

不能将常量指定为聚合函数的参数。 示例: `sum(1)`. 相反，你可以摆脱常数。 示例: `count()`.

#### 实现细节

聚合是面向列的 DBMS 最重要的功能之一，因此它的实现是ClickHouse中最优化的部分之一。 默认情况下，聚合使用哈希表在内存中完成。 它有 40+ 的特殊化自动选择取决于 “grouping key” 数据类型。

#### 在外部存储器中分组

您可以启用将临时数据转储到磁盘以限制内存使用期间 `GROUP BY`.
该 max_bytes_before_external_group_by 设置确定倾销的阈值RAM消耗 `GROUP BY` 临时数据到文件系统。 如果设置为0（默认值），它将被禁用。

使用时 `max_bytes_before_external_group_by`，我们建议您设置 `max_memory_usage` 大约两倍高。 这是必要的，因为聚合有两个阶段：读取数据和形成中间数据（1）和合并中间数据（2）。 将数据转储到文件系统只能在阶段1中发生。 如果未转储临时数据，则阶段2可能需要与阶段1相同的内存量。

例如，如果 max_memory_usage 设置为10000000000，你想使用外部聚合，这是有意义的设置 `max_bytes_before_external_group_by` 到10000000000，和 `max_memory_usage` 到20000000000。 当触发外部聚合（如果至少有一个临时数据转储）时，RAM的最大消耗仅略高于 `max_bytes_before_external_group_by`.

通过分布式查询处理，在远程服务器上执行外部聚合。 为了使请求者服务器只使用少量的RAM，设置 `distributed_aggregation_memory_efficient` 到1。

当合并数据刷新到磁盘时，以及当合并来自远程服务器的结果时， `distributed_aggregation_memory_efficient` 设置被启用，消耗高达 `1/256 * the_number_of_threads` 从RAM的总量。

当启用外部聚合时，如果数据量小于 `max_bytes_before_external_group_by` (例如数据没有被 flushed), 查询执行速度和不在外部聚合的速度一样快. 如果临时数据被flushed到外部存储, 执行的速度会慢几倍 (大概是三倍).

如果你有一个 ORDER BY 用一个 LIMIT 后 `GROUP BY`，然后使用的RAM的量取决于数据的量 `LIMIT`，不是在整个表。 但如果 `ORDER BY` 没有 `LIMIT`，不要忘记启用外部排序 (`max_bytes_before_external_sort`).
', 0, 1, '2021-07-11 10:26:37', 1, '2021-07-11 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(62, '#### HAVING 子句

允许过滤由 GROUP BY 生成的聚合结果. 它类似于 WHERE ，但不同的是 `WHERE` 在聚合之前执行，而 `HAVING` 之后进行。

可以从 `SELECT` 生成的聚合结果中通过他们的别名来执行 `HAVING` 子句。 或者 `HAVING` 子句可以筛选查询结果中未返回的其他聚合的结果。

#### 限制

`HAVING` 如果不执行聚合则无法使用。 使用 `WHERE` 则相反。
', 0, 1, '2021-07-12 10:26:37', 1, '2021-07-12 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(63, '#### INTO OUTFILE 子句

添加 `INTO OUTFILE filename` 子句（其中filename是字符串） `SELECT query` 将其输出重定向到客户端上的指定文件。

#### 实现细节

- 此功能是在可用 命令行客户端 和 clickhouse-local. 因此通过 HTTP接口 发送查询将会失败。
- 如果具有相同文件名的文件已经存在，则查询将失败。
- 默认值 输出格式 是 `TabSeparated` （就像在命令行客户端批处理模式中一样）。
', 0, 1, '2021-07-13 10:26:37', 1, '2021-07-13 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(64, '#### JOIN子句

Join通过使用一个或多个表的公共值合并来自一个或多个表的列来生成新表。 它是支持SQL的数据库中的常见操作，它对应于 关系代数 加入。 一个表连接的特殊情况通常被称为 “self-join”.

语法:

```
SELECT <expr_list>
FROM <left_table>
[GLOBAL] [INNER|LEFT|RIGHT|FULL|CROSS] [OUTER|SEMI|ANTI|ANY|ASOF] JOIN <right_table>
(ON <expr_list>)|(USING <column_list>) ...
```

从表达式 `ON` 从子句和列 `USING` 子句被称为 “join keys”. 除非另有说明，加入产生一个 笛卡尔积 从具有匹配的行 “join keys”，这可能会产生比源表更多的行的结果。

#### 支持的联接类型

所有标准 SQL JOIN 支持类型:

- `INNER JOIN`，只返回匹配的行。
- `LEFT OUTER JOIN`，除了匹配的行之外，还返回左表中的非匹配行。
- `RIGHT OUTER JOIN`，除了匹配的行之外，还返回右表中的非匹配行。
- `FULL OUTER JOIN`，除了匹配的行之外，还会返回两个表中的非匹配行。
- `CROSS JOIN`，产生整个表的笛卡尔积, “join keys” 是 **不** 指定。

`JOIN` 没有指定类型暗指 `INNER`. 关键字 `OUTER` 可以安全地省略。 替代语法 `CROSS JOIN` 在指定多个表 FROM 用逗号分隔。

ClickHouse中提供的其他联接类型:

- `LEFT SEMI JOIN` 和 `RIGHT SEMI JOIN`,白名单 “join keys”，而不产生笛卡尔积。
- `LEFT ANTI JOIN` 和 `RIGHT ANTI JOIN`，黑名单 “join keys”，而不产生笛卡尔积。
- `LEFT ANY JOIN`, `RIGHT ANY JOIN` and `INNER ANY JOIN`, partially (for opposite side of `LEFT` and `RIGHT`) or completely (for `INNER` and `FULL`) disables the cartesian product for standard `JOIN` types.
- `ASOF JOIN` and `LEFT ASOF JOIN`, joining sequences with a non-exact match. `ASOF JOIN` usage is described below.

#### 严格

注

可以使用以下方式复盖默认的严格性值 join_default_strictness 设置。

Also the behavior of ClickHouse server for `ANY JOIN` operations depends on the any_join_distinct_right_table_keys setting.

#### ASOF JOIN使用

`ASOF JOIN` 当您需要连接没有完全匹配的记录时非常有用。

该算法需要表中的特殊列。 该列需要满足:

- 必须包含有序序列。
- 可以是以下类型之一: Int*，UInt*, Float*, Date, DateTime, Decimal*.
- 不能是`JOIN`子句中唯一的列

语法 `ASOF JOIN ... ON`:

```
SELECT expressions_list
FROM table_1
ASOF LEFT JOIN table_2
ON equi_cond AND closest_match_cond
```

您可以使用任意数量的相等条件和一个且只有一个最接近的匹配条件。 例如, `SELECT count() FROM table_1 ASOF LEFT JOIN table_2 ON table_1.a == table_2.b AND table_2.t <= table_1.t`.

支持最接近匹配的运算符: `>`, `>=`, `<`, `<=`.

语法 `ASOF JOIN ... USING`:

```
SELECT expressions_list
FROM table_1
ASOF JOIN table_2
USING (equi_column1, ... equi_columnN, asof_column)
```

`table_1.asof_column >= table_2.asof_column` 中， `ASOF JOIN` 使用 `equi_columnX` 来进行条件匹配， `asof_column` 用于JOIN最接近匹配。 `asof_column` 列总是在最后一个 `USING` 条件中。

例如，参考下表:

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

`ASOF JOIN`会从 `table_2` 中的用户事件时间戳找出和 `table_1` 中用户事件时间戳中最近的一个时间戳，来满足最接近匹配的条件。如果有得话，则相等的时间戳值是最接近的值。在此例中，`user_id` 列可用于条件匹配，`ev_time` 列可用于最接近匹配。在此例中，`event_1_1` 可以 JOIN `event_2_1`，`event_1_2` 可以JOIN `event_2_3`，但是 `event_2_2` 不能被JOIN。

注

`ASOF JOIN`在 JOIN 表引擎中 **不受** 支持。

#### 分布式联接

有两种方法可以执行涉及分布式表的join:

- 当使用正常 `JOIN`，将查询发送到远程服务器。 为了创建正确的表，在每个子查询上运行子查询，并使用此表执行联接。 换句话说，在每个服务器上单独形成右表。
- 使用时 `GLOBAL ... JOIN`，首先请求者服务器运行一个子查询来计算正确的表。 此临时表将传递到每个远程服务器，并使用传输的临时数据对其运行查询。

使用时要小心 `GLOBAL`. 有关详细信息，请参阅 分布式子查询 科。

#### 使用建议

#### 处理空单元格或空单元格

在连接表时，可能会出现空单元格。 设置 join_use_nulls 定义ClickHouse如何填充这些单元格。

如果 `JOIN` 键是 可为空 字段，其中至少有一个键具有值的行 NULL 没有加入。

#### 语法

在指定的列 `USING` 两个子查询中必须具有相同的名称，并且其他列必须以不同的方式命名。 您可以使用别名更改子查询中的列名。

该 `USING` 子句指定一个或多个要联接的列，这将建立这些列的相等性。 列的列表设置不带括号。 不支持更复杂的连接条件。

#### 语法限制

对于多个 `JOIN` 单个子句 `SELECT` 查询:

- 通过以所有列 `*` 仅在联接表时才可用，而不是子查询。
- 该 `PREWHERE` 条款不可用。

为 `ON`, `WHERE`，和 `GROUP BY` 条款:

- 任意表达式不能用于 `ON`, `WHERE`，和 `GROUP BY` 子句，但你可以定义一个表达式 `SELECT` 子句，然后通过别名在这些子句中使用它。

#### 性能

当运行 `JOIN`，与查询的其他阶段相关的执行顺序没有优化。 连接（在右表中搜索）在过滤之前运行 `WHERE` 和聚集之前。

每次使用相同的查询运行 `JOIN`，子查询再次运行，因为结果未缓存。 为了避免这种情况，使用特殊的 加入我们 表引擎，它是一个用于连接的准备好的数组，总是在RAM中。

在某些情况下，使用效率更高 IN 而不是 `JOIN`.

如果你需要一个 `JOIN` 对于连接维度表（这些是包含维度属性的相对较小的表，例如广告活动的名称）， `JOIN` 由于每个查询都会重新访问正确的表，因此可能不太方便。 对于这种情况下，有一个 “external dictionaries” 您应该使用的功能 `JOIN`. 有关详细信息，请参阅 外部字典 科。

#### 内存限制

默认情况下，ClickHouse使用 哈希联接 算法。 ClickHouse采取 `<right_table>` 并在RAM中为其创建哈希表。 在某个内存消耗阈值之后，ClickHouse回退到合并联接算法。

如果需要限制联接操作内存消耗，请使用以下设置:

- max_rows_in_join — Limits number of rows in the hash table.
- max_bytes_in_join — Limits size of the hash table.

当任何这些限制达到，ClickHouse作为 join_overflow_mode 设置指示。

#### 例子

示例:

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
', 0, 1, '2021-07-14 10:26:37', 1, '2021-07-14 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(65, '#### LIMIT

`LIMIT m` 允许选择结果中起始的 `m` 行。

`LIMIT n, m` 允许选择个 `m` 从跳过第一个结果后的行 `n` 行。 与 `LIMIT m OFFSET n` 语法是等效的。

`n` 和 `m` 必须是非负整数。

如果没有 ORDER BY 子句显式排序结果，结果的行选择可能是任意的和非确定性的。

#### LIMIT … WITH TIES 修饰符

如果为 `LIMIT n[,m]` 设置了 `WITH TIES` ，并且声明了 `ORDER BY expr_list`, 除了得到无修饰符的结果（正常情况下的 `limit n`, 前n行数据), 还会返回与第`n`行具有相同排序字段的行(即如果第n+1行的字段与第n行 拥有相同的排序字段，同样返回该结果.

此修饰符可以与： ORDER BY … WITH FILL modifier 组合使用.

例如以下查询：

```
SELECT * FROM (
    SELECT number%50 AS n FROM numbers(100)
) ORDER BY n LIMIT 0,5
```

返回

```
┌─n─┐
│ 0 │
│ 0 │
│ 1 │
│ 1 │
│ 2 │
└───┘
```

添加 `WITH TIES` 修饰符后

```
SELECT * FROM (
    SELECT number%50 AS n FROM numbers(100)
) ORDER BY n LIMIT 0,5 WITH TIES
```

则返回了以下的数据行

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

虽然指定了`LIMIT 5`, 但第6行的`n`字段值为2，与第5行相同，因此也作为满足条件的记录返回。
简而言之，该修饰符可理解为是否增加“并列行”的数据。
', 0, 1, '2021-07-15 10:26:37', 1, '2021-07-15 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(66, '#### LIMIT BY子句

与查询 `LIMIT n BY expressions` 子句选择第一个 `n` 每个不同值的行 `expressions`. `LIMIT BY` 可以包含任意数量的 表达式.

ClickHouse支持以下语法变体:

- `LIMIT [offset_value, ]n BY expressions`
- `LIMIT n OFFSET offset_value BY expressions`

在查询处理过程中，ClickHouse会选择按排序键排序的数据。 排序键使用以下命令显式设置 ORDER BY 子句或隐式作为表引擎的属性。 然后ClickHouse应用 `LIMIT n BY expressions` 并返回第一 `n` 每个不同组合的行 `expressions`. 如果 `OFFSET` 被指定，则对于每个数据块属于一个不同的组合 `expressions`，ClickHouse跳过 `offset_value` 从块开始的行数，并返回最大值 `n` 行的结果。 如果 `offset_value` 如果数据块中的行数大于数据块中的行数，ClickHouse将从该块返回零行。

注

`LIMIT BY` 是不相关的 LIMIT. 它们都可以在同一个查询中使用。

#### 例

样例表:

```
CREATE TABLE limit_by(id Int, val Int) ENGINE = Memory;
INSERT INTO limit_by VALUES (1, 10), (1, 11), (1, 12), (2, 20), (2, 21);
```

查询:

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

该 `SELECT * FROM limit_by ORDER BY id, val LIMIT 2 OFFSET 1 BY id` 查询返回相同的结果。

以下查询返回每个引用的前5个引用 `domain, device_type` 最多可与100行配对 (`LIMIT n BY + LIMIT`).

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
', 0, 1, '2021-07-16 10:26:37', 1, '2021-07-16 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(67, '#### ORDER BY

```
ORDER BY` 子句包含一个表达式列表，每个表达式都可以用 `DESC` （降序）或 `ASC` （升序）修饰符确定排序方向。 如果未指定方向, 默认是 `ASC` ，所以它通常被省略。 排序方向适用于单个表达式，而不适用于整个列表。 示例: `ORDER BY Visits DESC, SearchPhrase
```

对于排序表达式列表具有相同值的行以任意顺序输出，也可以是非确定性的（每次都不同）。
如果省略ORDER BY子句，则行的顺序也是未定义的，并且可能也是非确定性的。

#### 特殊值的排序

有两种方法 `NaN` 和 `NULL` 排序顺序:

- 默认情况下或与 `NULLS LAST` 修饰符：首先是值，然后 `NaN`，然后 `NULL`.
- 与 `NULLS FIRST` 修饰符：第一 `NULL`，然后 `NaN`，然后其他值。

#### 示例

对于表

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

运行查询 `SELECT * FROM t_null_nan ORDER BY y NULLS FIRST` 获得:

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

当对浮点数进行排序时，Nan与其他值是分开的。 无论排序顺序如何，Nan都在最后。 换句话说，对于升序排序，它们被放置为好像它们比所有其他数字大，而对于降序排序，它们被放置为好像它们比其他数字小。

#### 排序规则支持

对于按字符串值排序，可以指定排序规则（比较）。 示例: `ORDER BY SearchPhrase COLLATE ''tr''` -对于按关键字升序排序，使用土耳其字母，不区分大小写，假设字符串是UTF-8编码。 `COLLATE` 可以按顺序独立地指定或不按每个表达式。 如果 `ASC` 或 `DESC` 被指定, `COLLATE` 在它之后指定。 使用时 `COLLATE`，排序始终不区分大小写。

我们只建议使用 `COLLATE` 对于少量行的最终排序，因为排序与 `COLLATE` 比正常的按字节排序效率低。

#### 实现细节

更少的RAM使用，如果一个足够小 LIMIT 除了指定 `ORDER BY`. 否则，所花费的内存量与用于排序的数据量成正比。 对于分布式查询处理，如果 GROUP BY 省略排序，在远程服务器上部分完成排序，并将结果合并到请求者服务器上。 这意味着对于分布式排序，要排序的数据量可以大于单个服务器上的内存量。

如果没有足够的RAM，则可以在外部存储器中执行排序（在磁盘上创建临时文件）。 使用设置 `max_bytes_before_external_sort` 为此目的。 如果将其设置为0（默认值），则禁用外部排序。 如果启用，则当要排序的数据量达到指定的字节数时，将对收集的数据进行排序并转储到临时文件中。 读取所有数据后，将合并所有已排序的文件并输出结果。 文件被写入到 `/var/lib/clickhouse/tmp/` 目录中的配置（默认情况下，但你可以使用 `tmp_path` 参数来更改此设置）。

运行查询可能占用的内存比 `max_bytes_before_external_sort` 大. 因此，此设置的值必须大大小于 `max_memory_usage`. 例如，如果您的服务器有128GB的RAM，并且您需要运行单个查询，请设置 `max_memory_usage` 到100GB，和 `max_bytes_before_external_sort` 至80GB。

外部排序的工作效率远远低于在RAM中进行排序。

#### ORDER BY Expr WITH FILL Modifier

此修饰符可以与 LIMIT … WITH TIES modifier 进行组合使用.

可以在`ORDER BY expr`之后用可选的`FROM expr`，`TO expr`和`STEP expr`参数来设置`WITH FILL`修饰符。
所有`expr`列的缺失值将被顺序填充，而其他列将被填充为默认值。

使用以下语法填充多列，在ORDER BY部分的每个字段名称后添加带有可选参数的WITH FILL修饰符。

```
ORDER BY expr [WITH FILL] [FROM const_expr] [TO const_expr] [STEP const_numeric_expr], ... exprN [WITH FILL] [FROM expr] [TO expr] [STEP numeric_expr]
```

`WITH FILL` 仅适用于具有数字（所有类型的浮点，小数，整数）或日期/日期时间类型的字段。
当未定义 `FROM const_expr` 填充顺序时，则使用 `ORDER BY` 中的最小 `expr` 字段值。
如果未定义 `TO const_expr` 填充顺序，则使用 `ORDER BY` 中的最大`expr`字段值。
当定义了 `STEP const_numeric_expr` 时，对于数字类型，`const_numeric_expr` 将 `as is` 解释为 `days` 作为日期类型，将 `seconds` 解释为DateTime类型。
如果省略了 `STEP const_numeric_expr`，则填充顺序使用 `1.0` 表示数字类型，`1 day`表示日期类型，`1 second` 表示日期时间类型。

例如下面的查询：

```
SELECT n, source FROM (
   SELECT toFloat32(number % 10) AS n, ''original'' AS source
   FROM numbers(10) WHERE number % 3 = 1
) ORDER BY n
```

返回

```
┌─n─┬─source───┐
│ 1 │ original │
│ 4 │ original │
│ 7 │ original │
└───┴──────────┘
```

但是如果配置了 `WITH FILL` 修饰符

```
SELECT n, source FROM (
   SELECT toFloat32(number % 10) AS n, ''original'' AS source
   FROM numbers(10) WHERE number % 3 = 1
) ORDER BY n WITH FILL FROM 0 TO 5.51 STEP 0.5
```

返回

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
对于我们有多个字段 `ORDER BY field2 WITH FILL, field1 WITH FILL` 的情况，填充顺序将遵循`ORDER BY`子句中字段的顺序。

示例:

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

返回

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

字段 `d1` 没有填充并使用默认值，因为我们没有 `d2` 值的重复值，并且无法正确计算 `d1` 的顺序。
以下查询中`ORDER BY` 中的字段将被更改

```
SELECT
    toDate((number * 10) * 86400) AS d1,
    toDate(number * 86400) AS d2,
    ''original'' AS source
FROM numbers(10)
WHERE (number % 3) = 1
ORDER BY
    d1 WITH FILL STEP 5,
    d2 WITH FILL;
```

返回

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
', 0, 1, '2021-07-17 10:26:37', 1, '2021-07-17 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(68, '#### PREWHERE 子句

Prewhere是更有效地进行过滤的优化。 默认情况下，即使在 `PREWHERE` 子句未显式指定。 它也会自动移动 WHERE 条件到prewhere阶段。 `PREWHERE` 子句只是控制这个优化，如果你认为你知道如何做得比默认情况下更好才去控制它。

使用prewhere优化，首先只读取执行prewhere表达式所需的列。 然后读取运行其余查询所需的其他列，但只读取prewhere表达式所在的那些块 “true” 至少对于一些行。 如果有很多块，其中prewhere表达式是 “false” 对于所有行和prewhere需要比查询的其他部分更少的列，这通常允许从磁盘读取更少的数据以执行查询。

#### 手动控制Prewhere

该子句具有与 `WHERE` 相同的含义，区别在于从表中读取数据。 当手动控制 `PREWHERE` 对于查询中的少数列使用的过滤条件，但这些过滤条件提供了强大的数据过滤。 这减少了要读取的数据量。

查询可以同时指定 `PREWHERE` 和 `WHERE`. 在这种情况下, `PREWHERE` 先于 `WHERE`.

如果 `optimize_move_to_prewhere` 设置为0，启发式自动移动部分表达式 `WHERE` 到 `PREWHERE` 被禁用。

#### 限制

`PREWHERE` 只有支持 `*MergeTree` 族系列引擎的表。
', 0, 1, '2021-07-18 10:26:37', 1, '2021-07-18 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(69, '#### 采样子句

该 `SAMPLE` 子句允许近似于 `SELECT` 查询处理。

启用数据采样时，不会对所有数据执行查询，而只对特定部分数据（样本）执行查询。 例如，如果您需要计算所有访问的统计信息，只需对所有访问的1/10分数执行查询，然后将结果乘以10即可。

近似查询处理在以下情况下可能很有用:

- 当你有严格的时间需求（如\<100ms），但你不能通过额外的硬件资源来满足他们的成本。
- 当您的原始数据不准确时，所以近似不会明显降低质量。
- 业务需求的目标是近似结果（为了成本效益，或者向高级用户推销确切结果）。

注

您只能使用采样中的表 MergeTree 族，并且只有在表创建过程中指定了采样表达式（请参阅 MergeTree引擎.

下面列出了数据采样的功能:

- 数据采样是一种确定性机制。 同样的结果 `SELECT .. SAMPLE` 查询始终是相同的。
- 对于不同的表，采样工作始终如一。 对于具有单个采样键的表，具有相同系数的采样总是选择相同的可能数据子集。 例如，用户Id的示例采用来自不同表的所有可能的用户Id的相同子集的行。 这意味着您可以在子查询中使用采样 IN 此外，您可以使用 JOIN 。
- 采样允许从磁盘读取更少的数据。 请注意，您必须正确指定采样键。 有关详细信息，请参阅 创建MergeTree表.

为 `SAMPLE` 子句支持以下语法:

| SAMPLE Clause Syntax | 产品描述                  |
| -------------------- | ------------------------- |
| `SAMPLE k`           | 这里 `k` 是从0到1的数字。 |

查询执行于 `k``SAMPLE 0.1`Read more`SAMPLE n``n``n``SAMPLE 10000000`Read more`SAMPLE k OFFSET m``k``m``k``m`Read more

#### SAMPLE K

这里 `k` 从0到1的数字（支持小数和小数表示法）。 例如, `SAMPLE 1/2` 或 `SAMPLE 0.5`.

在一个 `SAMPLE k` 子句，样品是从 `k` 数据的分数。 示例如下所示:

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

在此示例中，对0.1(10%)数据的样本执行查询。 聚合函数的值不会自动修正，因此要获得近似结果，值 `count()` 手动乘以10。

#### SAMPLE N

这里 `n` 是足够大的整数。 例如, `SAMPLE 10000000`.

在这种情况下，查询在至少一个样本上执行 `n` 行（但不超过这个）。 例如, `SAMPLE 10000000` 在至少10,000,000行上运行查询。

由于数据读取的最小单位是一个颗粒（其大小由 `index_granularity` 设置），是有意义的设置一个样品，其大小远大于颗粒。

使用时 `SAMPLE n` 子句，你不知道处理了哪些数据的相对百分比。 所以你不知道聚合函数应该乘以的系数。 使用 `_sample_factor` 虚拟列得到近似结果。

该 `_sample_factor` 列包含动态计算的相对系数。 当您执行以下操作时，将自动创建此列 创建 具有指定采样键的表。 的使用示例 `_sample_factor` 列如下所示。

让我们考虑表 `visits`，其中包含有关网站访问的统计信息。 第一个示例演示如何计算页面浏览量:

```
SELECT sum(PageViews * _sample_factor)
FROM visits
SAMPLE 10000000
```

下一个示例演示如何计算访问总数:

```
SELECT sum(_sample_factor)
FROM visits
SAMPLE 10000000
```

下面的示例显示了如何计算平均会话持续时间。 请注意，您不需要使用相对系数来计算平均值。

```
SELECT avg(Duration)
FROM visits
SAMPLE 10000000
```

#### SAMPLE K OFFSET M

这里 `k` 和 `m` 是从0到1的数字。 示例如下所示。

**示例1**

```
SAMPLE 1/10
```

在此示例中，示例是所有数据的十分之一:

```
[++------------]
```

**示例2**

```
SAMPLE 1/10 OFFSET 1/2
```

这里，从数据的后半部分取出10％的样本。
', 0, 1, '2021-07-19 10:26:37', 1, '2021-07-19 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(70, '#### UNION ALL子句

你可以使用 `UNION ALL` 结合任意数量的 `SELECT` 来扩展其结果。 示例:

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

结果列通过它们的索引进行匹配（在内部的顺序 `SELECT`). 如果列名称不匹配，则从第一个查询中获取最终结果的名称。

对联合执行类型转换。 例如，如果合并的两个查询具有相同的字段与非-`Nullable` 和 `Nullable` 从兼容类型的类型，由此产生的 `UNION ALL` 有一个 `Nullable` 类型字段。

属于以下部分的查询 `UNION ALL` 不能用圆括号括起来。 ORDER BY 和 LIMIT 应用于单独的查询，而不是最终结果。 如果您需要将转换应用于最终结果，则可以将所有查询 `UNION ALL` 在子查询中 FROM 子句。

#### 限制

只有 `UNION ALL` 支持。 `UNION` (`UNION DISTINCT`）不支持。 如果你需要 `UNION DISTINCT`，你可以写 `SELECT DISTINCT` 子查询中包含 `UNION ALL`.

#### 实现细节

属于 `UNION ALL` 的查询可以同时运行，并且它们的结果可以混合在一起。
', 0, 1, '2021-07-20 10:26:37', 1, '2021-07-20 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(71, '#### WHERE

`WHERE` 子句允许过滤从 FROM 子句 `SELECT`.

如果有一个 `WHERE` 子句，它必须包含一个表达式与 `UInt8` 类型。 这通常是一个带有比较和逻辑运算符的表达式。 此表达式计算结果为0的行将从进一步的转换或结果中解释出来。

`WHERE` 如果基础表引擎支持，则根据使用索引和分区修剪的能力评估表达式。

注

有一个叫做过滤优化 prewhere 的东西.
', 0, 1, '2021-07-21 10:26:37', 1, '2021-07-21 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(72, '#### WITH子句

本节提供对公共表表达式的支持 (CTE），所以结果 `WITH` 子句可以在其余部分中使用 `SELECT` 查询。

#### 限制

1. 不支持递归查询。
2. 当在section中使用子查询时，它的结果应该是只有一行的标量。
3. Expression的结果在子查询中不可用。

#### 例

**示例1:** 使用常量表达式作为 “variable”

```
WITH ''2019-08-01 15:23:00'' as ts_upper_bound
SELECT *
FROM hits
WHERE
    EventDate = toDate(ts_upper_bound) AND
    EventTime <= ts_upper_bound
```

**示例2:** 从SELECT子句列表中逐出sum(bytes)表达式结果

```
WITH sum(bytes) as s
SELECT
    formatReadableSize(s),
    table
FROM system.parts
GROUP BY table
ORDER BY s
```

**例3:** 使用标量子查询的结果

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
LIMIT 10
```

**例4:** 在子查询中重用表达式

作为子查询中表达式使用的当前限制的解决方法，您可以复制它。

```
WITH [''hello''] AS hello
SELECT
    hello,
    *
FROM
(
    WITH [''hello''] AS hello
    SELECT hello
)
┌─hello─────┬─hello─────┐
│ [''hello''] │ [''hello''] │
└───────────┴───────────┘
```
', 0, 1, '2021-07-22 10:26:37', 1, '2021-07-22 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(73, '#### count

计数行数或非空值。

ClickHouse支持以下 `count` 语法:
\- `count(expr)` 或 `COUNT(DISTINCT expr)`。
\- `count()` 或 `COUNT(*)`. 该 `count()` 语法是ClickHouse特定的。

**参数**

该函数可以采取:

- 零参数。
- 一个 表达式。

**返回值**

- 如果没有参数调用函数，它会计算行数。
- 如果 表达式 被传递，则该函数计数此表达式返回非null的次数。 如果表达式返回 可为空类型的值，`count`的结果仍然不 `Nullable`。 如果表达式对于所有的行都返回 `NULL` ，则该函数返回 0 。

在这两种情况下，返回值的类型为 UInt64。

**详细信息**

ClickHouse支持 `COUNT(DISTINCT ...)` 语法，这种结构的行为取决于 count_distinct_implementation 设置。 它定义了用于执行该操作的 uniq*函数。 默认值是 uniqExact函数。

`SELECT count() FROM table` 这个查询未被优化，因为表中的条目数没有单独存储。 它从表中选择一个小列并计算其值的个数。

**示例**

示例1:

```
SELECT count() FROM t
┌─count()─┐
│       5 │
└─────────┘
```

示例2:

```
SELECT name, value FROM system.settings WHERE name = ''count_distinct_implementation''
┌─name──────────────────────────┬─value─────┐
│ count_distinct_implementation │ uniqExact │
└───────────────────────────────┴───────────┘
SELECT count(DISTINCT num) FROM t
┌─uniqExact(num)─┐
│              3 │
└────────────────┘
```

这个例子表明 `count(DISTINCT num)` 是通过 `count_distinct_implementation` 的设定值 `uniqExact` 函数来执行的。
', 0, 1, '2021-07-23 10:26:37', 1, '2021-07-23 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(74, '#### min

计算最小值。
', 0, 1, '2021-07-24 10:26:37', 1, '2021-07-24 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(75, '#### max

计算最大值。
', 0, 1, '2021-07-25 10:26:37', 1, '2021-07-25 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(76, '#### sum

计算总和。
只适用于数字
', 0, 1, '2021-07-26 10:26:37', 1, '2021-07-26 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(77, '#### avg

计算算术平均值。

**语法**

```
avg(x)
```

**参数**

- `x` — 输入值, 必须是 Integer, Float, 或 Decimal。

**返回值**

- 算术平均值，总是 Float64 类型。
- 输入参数 `x` 为空时返回 `NaN` 。

**示例**

查询:

```
SELECT avg(x) FROM values(''x Int8'', 0, 1, 2, 3, 4, 5);
```

结果:

```
┌─avg(x)─┐
│    2.5 │
└────────┘
```

**示例**

创建一个临时表:

查询:

```
CREATE table test (t UInt8) ENGINE = Memory;
```

获取算术平均值:

查询:

```
SELECT avg(t) FROM test;
```

结果:

```
┌─avg(x)─┐
│    nan │
└────────┘
```
', 0, 1, '2021-07-27 10:26:37', 1, '2021-07-27 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(78, '#### any

选择第一个遇到的值。
查询可以以任何顺序执行，甚至每次都以不同的顺序执行，因此此函数的结果是不确定的。
要获得确定的结果，您可以使用 ‘min’ 或 ‘max’ 功能，而不是 ‘any’.

在某些情况下，可以依靠执行的顺序。 这适用于SELECT来自使用ORDER BY的子查询的情况。

当一个 `SELECT` 查询具有 `GROUP BY` 子句或至少一个聚合函数，ClickHouse（相对于MySQL）要求在所有表达式 `SELECT`, `HAVING`，和 `ORDER BY` 子句可以从键或聚合函数计算。 换句话说，从表中选择的每个列必须在键或聚合函数内使用。 要获得像MySQL这样的行为，您可以将其他列放在 `any` 聚合函数。
', 0, 1, '2021-07-28 10:26:37', 1, '2021-07-28 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(79, '#### stddevPop

结果等于 [varPop] (../../../sql-reference/aggregate-functions/reference/varpop.md)的平方根。

注

该函数使用数值不稳定的算法。 如果你需要 数值稳定性 在计算中，使用 `stddevPopStable` 函数。 它的工作速度较慢，但提供较低的计算错误。
', 0, 1, '2021-07-29 10:26:37', 1, '2021-07-29 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(80, '#### stddevSamp

结果等于 [varSamp] (../../../sql-reference/aggregate-functions/reference/varsamp.md)的平方根。

注

该函数使用数值不稳定的算法。 如果你需要 数值稳定性 在计算中，使用 `stddevSampStable` 函数。 它的工作速度较慢，但提供较低的计算错误。
', 0, 1, '2021-07-30 10:26:37', 1, '2021-07-30 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(81, '#### varPop(x)

计算 `Σ((x - x̅)^2) / n`，这里 `n` 是样本大小， `x̅` 是 `x` 的平均值。

换句话说，计算一组数据的离差。 返回 `Float64`。

注

该函数使用数值不稳定的算法。 如果你需要 数值稳定性 在计算中，使用 `varPopStable` 函数。 它的工作速度较慢，但提供较低的计算错误。
', 0, 1, '2021-07-31 10:26:37', 1, '2021-07-31 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(82, '#### varSamp

计算 `Σ((x - x̅)^2) / (n - 1)`，这里 `n` 是样本大小， `x̅`是`x`的平均值。

它表示随机变量的方差的无偏估计，如果传递的值形成其样本。

返回 `Float64`。 当 `n <= 1`，返回 `+∞`。

注

该函数使用数值不稳定的算法。 如果你需要 数值稳定性 在计算中，使用 `varSampStable` 函数。 它的工作速度较慢，但提供较低的计算错误。
', 0, 1, '2021-08-01 10:26:37', 1, '2021-08-01 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(83, '#### covarPop

**语法**

```
covarPop(x, y)
```

计算 `Σ((x - x̅)(y - y̅)) / n` 的值。

注

该函数使用数值不稳定的算法。 如果你需要 数值稳定性 在计算中，使用 `covarPopStable` 函数。 它的工作速度较慢，但提供了较低的计算错误。
', 0, 1, '2021-08-02 10:26:37', 1, '2021-08-02 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(84, '#### covarSamp

**语法**

```
covarSamp(x, y)
```

计算 `Σ((x - x̅)(y - y̅)) / (n - 1)` 的值。

返回Float64。 当 `n <= 1`, 返回 +∞。

注

该函数使用数值不稳定的算法。 如果你需要 数值稳定性 在计算中，使用 `covarSampStable` 函数。 它的工作速度较慢，但提供较低的计算错误
', 0, 1, '2021-08-03 10:26:37', 1, '2021-08-03 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(85, '#### anyHeavy

选择一个频繁出现的值，使用heavy hitters 算法。 如果某个值在查询的每个执行线程中出现的情况超过一半，则返回此值。 通常情况下，结果是不确定的。

```
anyHeavy(column)
```

**参数**

- `column` – The column name。

**示例**

使用 OnTime 数据集，并选择在 `AirlineID` 列任何频繁出现的值。

查询:

```
SELECT anyHeavy(AirlineID) AS res
FROM ontime;
```

结果:

```
┌───res─┐
│ 19690 │
└───────┘
```
', 0, 1, '2021-08-04 10:26:37', 1, '2021-08-04 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(86, '#### anyLast

选择遇到的最后一个值。
其结果和any 函数一样是不确定的。
', 0, 1, '2021-08-05 10:26:37', 1, '2021-08-05 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(87, '#### argMin

语法: `argMin(arg, val)` 或 `argMin(tuple(arg, val))`

计算 `val` 最小值对应的 `arg` 值。 如果 `val` 最小值存在几个不同的 `arg` 值，输出遇到的第一个(`arg`)值。

这个函数的Tuple版本将返回 `val` 最小值对应的tuple。本函数适合和`SimpleAggregateFunction`搭配使用。

**示例:**

输入表:

```
┌─user─────┬─salary─┐
│ director │   5000 │
│ manager  │   3000 │
│ worker   │   1000 │
└──────────┴────────┘
```

查询:

```
SELECT argMin(user, salary), argMin(tuple(user, salary)) FROM salary;
```

结果:

```
┌─argMin(user, salary)─┬─argMin(tuple(user, salary))─┐
│ worker               │ (''worker'',1000)             │
└──────────────────────┴─────────────────────────────┘
```
', 0, 1, '2021-08-06 10:26:37', 1, '2021-08-06 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(88, '#### argMax

计算 `val` 最大值对应的 `arg` 值。 如果 `val` 最大值存在几个不同的 `arg` 值，输出遇到的第一个值。

这个函数的Tuple版本将返回 `val` 最大值对应的元组。本函数适合和 `SimpleAggregateFunction` 搭配使用。

**语法**

```
argMax(arg, val)
```

或

```
argMax(tuple(arg, val))
```

**参数**

- `arg` — Argument.
- `val` — Value.

**返回值**

- `val` 最大值对应的 `arg` 值。

类型: 匹配 `arg` 类型。

对于输入中的元组:

- 元组 `(arg, val)`, 其中 `val` 最大值，`arg` 是对应的值。

类型: 元组。

**示例**

输入表:

```
┌─user─────┬─salary─┐
│ director │   5000 │
│ manager  │   3000 │
│ worker   │   1000 │
└──────────┴────────┘
```

查询:

```
SELECT argMax(user, salary), argMax(tuple(user, salary), salary), argMax(tuple(user, salary)) FROM salary;
```

结果:

```
┌─argMax(user, salary)─┬─argMax(tuple(user, salary), salary)─┬─argMax(tuple(user, salary))─┐
│ director             │ (''director'',5000)                   │ (''director'',5000)           │
└──────────────────────┴─────────────────────────────────────┴─────────────────────────────┘
```
', 0, 1, '2021-08-07 10:26:37', 1, '2021-08-07 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(89, '#### avgWeighted

计算 加权算术平均值。

**语法**

```
avgWeighted(x, weight)
```

**参数**

- `x` — 值。
- `weight` — 值的加权。

`x` 和 `weight` 的类型必须是
整数, 或
浮点数, 或
定点数,
但是可以不一样。

**返回值**

- `NaN`。 如果所有的权重都等于0 或所提供的权重参数是空。
- 加权平均值。 其他。

类型: 总是Float64.

**示例**

查询:

```
SELECT avgWeighted(x, w)
FROM values(''x Int8, w Int8'', (4, 1), (1, 0), (10, 2))
```

结果:

```
┌─avgWeighted(x, weight)─┐
│                      8 │
└────────────────────────┘
```

**示例**

查询:

```
SELECT avgWeighted(x, w)
FROM values(''x Int8, w Int8'', (0, 0), (1, 0), (10, 0))
```

结果:

```
┌─avgWeighted(x, weight)─┐
│                    nan │
└────────────────────────┘
```

**示例**

查询:

```
CREATE table test (t UInt8) ENGINE = Memory;
SELECT avgWeighted(t) FROM test
```

结果:

```
┌─avgWeighted(x, weight)─┐
│                    nan │
└────────────────────────┘
```
', 0, 1, '2021-08-08 10:26:37', 1, '2021-08-08 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(90, '#### corr

**语法**

```
`corr(x, y)`
```

计算Pearson相关系数: `Σ((x - x̅)(y - y̅)) / sqrt(Σ((x - x̅)^2) * Σ((y - y̅)^2))`。

注

该函数使用数值不稳定的算法。 如果你需要 数值稳定性 在计算中，使用 `corrStable` 函数。 它的工作速度较慢，但提供较低的计算错误。
', 0, 1, '2021-08-09 10:26:37', 1, '2021-08-09 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(91, '#### topK

返回指定列中近似最常见值的数组。 生成的数组按值的近似频率降序排序（而不是值本身）。

实现了过滤节省空间算法， 使用基于reduce-and-combine的算法，借鉴并行节省空间。

**语法**

```
topK(N)(x)
```

此函数不提供保证的结果。 在某些情况下，可能会发生错误，并且可能会返回不是最高频的值。

我们建议使用 `N < 10` 值，`N` 值越大，性能越低。最大值 `N = 65536`。

**参数**

- `N` — 要返回的元素数。

如果省略该参数，则使用默认值10。

**参数**

- `x` – (要计算频次的)值。

**示例**

就拿 OnTime 数据集来说，选择`AirlineID` 列中出现最频繁的三个。

```
SELECT topK(3)(AirlineID) AS res
FROM ontime
┌─res─────────────────┐
│ [19393,19790,19805] │
└─────────────────────┘
```
', 0, 1, '2021-08-10 10:26:37', 1, '2021-08-10 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(92, '#### topKWeighted

类似于 `topK` 但需要一个整数类型的附加参数 - `weight`。 每个输入都被记入 `weight` 次频率计算。

**语法**

```
topKWeighted(N)(x, weight)
```

**参数**

- `N` — 要返回的元素数。

**参数**

- `x` – (要计算频次的)值。
- `weight` — 权重。 UInt8类型。

**返回值**

返回具有最大近似权重总和的值数组。

**示例**

查询:

```
SELECT topKWeighted(10)(number, number) FROM numbers(1000)
```

结果:

```
┌─topKWeighted(10)(number, number)──────────┐
│ [999,998,997,996,995,994,993,992,991,990] │
└───────────────────────────────────────────┘
```
', 0, 1, '2021-08-11 10:26:37', 1, '2021-08-11 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(93, '#### groupArray

**语法**

```
groupArray(x)
或
groupArray(max_size)(x)
```

创建参数值的数组。
值可以按任何（不确定）顺序添加到数组中。

第二个版本（带有 `max_size` 参数）将结果数组的大小限制为 `max_size` 个元素。
例如, `groupArray (1) (x)` 相当于 `[any (x)]` 。

在某些情况下，您仍然可以依赖执行顺序。这适用于SELECT(查询)来自使用了 `ORDER BY` 子查询的情况。
', 0, 1, '2021-08-12 10:26:37', 1, '2021-08-12 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(94, '#### groupUniqArray

**语法**

```
groupUniqArray(x)
或
groupUniqArray(max_size)(x)
```

从不同的参数值创建一个数组。 内存消耗和 uniqExact 函数是一样的。

第二个版本（带有 `max_size` 参数）将结果数组的大小限制为 `max_size` 个元素。
例如, `groupUniqArray(1)(x)` 相当于 `[any(x)]`.
', 0, 1, '2021-08-13 10:26:37', 1, '2021-08-13 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(95, '#### groupArrayInsertAt

在指定位置向数组中插入一个值。

**语法**

```
groupArrayInsertAt(default_x, size)(x, pos);
```

如果在一个查询中将多个值插入到同一位置，则该函数的行为方式如下:

- 如果在单个线程中执行查询，则使用第一个插入的值。
- 如果在多个线程中执行查询，则结果值是未确定的插入值之一。

**参数**

- `x` — 要插入的值。生成所支持的数据类型。
- `pos` — 指定元素 `x` 将被插入的位置。 数组中的索引编号从零开始。 UInt32.
- `default_x` — 在空位置替换的默认值。可选参数。生成 `x` 数据类型 (数据) 的表达式。 如果 `default_x` 未定义，则 默认值 被使用。
- `size`— 结果数组的长度。可选参数。如果使用该参数，必须指定默认值 `default_x` 。 UInt32。

**返回值**

- 具有插入值的数组。

类型: 阵列。

**示例**

查询:

```
SELECT groupArrayInsertAt(toString(number), number * 2) FROM numbers(5);
```

结果:

```
┌─groupArrayInsertAt(toString(number), multiply(number, 2))─┐
│ [''0'','''',''1'','''',''2'','''',''3'','''',''4'']                         │
└───────────────────────────────────────────────────────────┘
```

查询:

```
SELECT groupArrayInsertAt(''-'')(toString(number), number * 2) FROM numbers(5);
```

结果:

```
┌─groupArrayInsertAt(''-'')(toString(number), multiply(number, 2))─┐
│ [''0'',''-'',''1'',''-'',''2'',''-'',''3'',''-'',''4'']                          │
└────────────────────────────────────────────────────────────────┘
```

查询:

```
SELECT groupArrayInsertAt(''-'', 5)(toString(number), number * 2) FROM numbers(5);
```

结果:

```
┌─groupArrayInsertAt(''-'', 5)(toString(number), multiply(number, 2))─┐
│ [''0'',''-'',''1'',''-'',''2'']                                             │
└───────────────────────────────────────────────────────────────────┘
```

在一个位置多线程插入数据。

查询:

```
SELECT groupArrayInsertAt(number, 0) FROM numbers_mt(10) SETTINGS max_block_size = 1;
```

作为这个查询的结果，你会得到 `[0,9]` 范围的随机整数。 例如:

```
┌─groupArrayInsertAt(number, 0)─┐
│ [7]                           │
└───────────────────────────────┘
```
', 0, 1, '2021-08-14 10:26:37', 1, '2021-08-14 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(96, '#### groupArrayMovingSum

计算输入值的移动和。

**语法**

```
groupArrayMovingSum(numbers_for_summing)
groupArrayMovingSum(window_size)(numbers_for_summing)
```

该函数可以将窗口大小作为参数。 如果未指定，则该函数的窗口大小等于列中的行数。

**参数**

- `numbers_for_summing` — 表达式 生成数值数据类型值。
- `window_size` — 窗口大小。

**返回值**

- 与输入数据大小相同的数组。
  对于输入数据类型是Decimal 数组元素类型是 `Decimal128` 。
  对于其他的数值类型, 获取其对应的 `NearestFieldType` 。

**示例**

样表:

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

查询:

```
SELECT
    groupArrayMovingSum(int) AS I,
    groupArrayMovingSum(float) AS F,
    groupArrayMovingSum(dec) AS D
FROM t
┌─I──────────┬─F───────────────────────────────┬─D──────────────────────┐
│ [1,3,7,14] │ [1.1,3.3000002,7.7000003,15.47] │ [1.10,3.30,7.70,15.47] │
└────────────┴─────────────────────────────────┴────────────────────────┘
SELECT
    groupArrayMovingSum(2)(int) AS I,
    groupArrayMovingSum(2)(float) AS F,
    groupArrayMovingSum(2)(dec) AS D
FROM t
┌─I──────────┬─F───────────────────────────────┬─D──────────────────────┐
│ [1,3,6,11] │ [1.1,3.3000002,6.6000004,12.17] │ [1.10,3.30,6.60,12.17] │
└────────────┴─────────────────────────────────┴────────────────────────┘
```
', 0, 1, '2021-08-15 10:26:37', 1, '2021-08-15 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(97, '#### groupArrayMovingAvg

计算输入值的移动平均值。

**语法**

```
groupArrayMovingAvg(numbers_for_summing)
groupArrayMovingAvg(window_size)(numbers_for_summing)
```

该函数可以将窗口大小作为参数。 如果未指定，则该函数的窗口大小等于列中的行数。

**参数**

- `numbers_for_summing` — 表达式 生成数值数据类型值。
- `window_size` — 窗口大小。

**返回值**

- 与输入数据大小相同的数组。

对于输入数据类型是Integer,
和floating-point,
对应的返回值类型是 `Float64` 。
对于输入数据类型是Decimal 返回值类型是 `Decimal128` 。

该函数对于 `Decimal128` 使用 四舍五入到零. 它截断无意义的小数位来保证结果的数据类型。

**示例**

样表 `t`:

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

查询:

```
SELECT
    groupArrayMovingAvg(int) AS I,
    groupArrayMovingAvg(float) AS F,
    groupArrayMovingAvg(dec) AS D
FROM t
┌─I────────────────────┬─F─────────────────────────────────────────────────────────────────────────────┬─D─────────────────────┐
│ [0.25,0.75,1.75,3.5] │ [0.2750000059604645,0.8250000178813934,1.9250000417232513,3.8499999940395355] │ [0.27,0.82,1.92,3.86] │
└──────────────────────┴───────────────────────────────────────────────────────────────────────────────┴───────────────────────┘
SELECT
    groupArrayMovingAvg(2)(int) AS I,
    groupArrayMovingAvg(2)(float) AS F,
    groupArrayMovingAvg(2)(dec) AS D
FROM t
┌─I───────────────┬─F───────────────────────────────────────────────────────────────────────────┬─D─────────────────────┐
│ [0.5,1.5,3,5.5] │ [0.550000011920929,1.6500000357627869,3.3000000715255737,6.049999952316284] │ [0.55,1.65,3.30,6.08] │
└─────────────────┴─────────────────────────────────────────────────────────────────────────────┴─────────
```
', 0, 1, '2021-08-16 10:26:37', 1, '2021-08-16 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(98, '#### groupArraySample

构建一个参数值的采样数组。
结果数组的大小限制为 `max_size` 个元素。参数值被随机选择并添加到数组中。

**语法**

```
groupArraySample(max_size[, seed])(x)
```

**参数**

- `max_size` — 结果数组的最大长度。UInt64。
- `seed` — 随机数发生器的种子。可选。UInt64。默认值: `123456`。
- `x` — 参数 (列名 或者 表达式)。

**返回值**

- 随机选取参数 `x` (的值)组成的数组。

类型: Array.

**示例**

样表 `colors`:

```
┌─id─┬─color──┐
│  1 │ red    │
│  2 │ blue   │
│  3 │ green  │
│  4 │ white  │
│  5 │ orange │
└────┴────────┘
```

使用列名做参数查询:

```
SELECT groupArraySample(3)(color) as newcolors FROM colors;
```

结果:

```
┌─newcolors──────────────────┐
│ [''white'',''blue'',''green'']   │
└────────────────────────────┘
```

使用列名和不同的(随机数)种子查询:

```
SELECT groupArraySample(3, 987654321)(color) as newcolors FROM colors;
```

结果:

```
┌─newcolors──────────────────┐
│ [''red'',''orange'',''green'']   │
└────────────────────────────┘
```

使用表达式做参数查询:

```
SELECT groupArraySample(3)(concat(''light-'', color)) as newcolors FROM colors;
```

结果:

```
┌─newcolors───────────────────────────────────┐
│ [''light-blue'',''light-orange'',''light-green''] │
└─────────────────────────────────────────────┘
```
', 0, 1, '2021-08-17 10:26:37', 1, '2021-08-17 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(99, '#### groupBitAnd

对于数字序列按位应用 `AND` 。

**语法**

```
groupBitAnd(expr)
```

**参数**

`expr` – 结果为 `UInt*` 类型的表达式。

**返回值**

`UInt*` 类型的值。

**示例**

测试数据:

```
binary     decimal
00101100 = 44
00011100 = 28
00001101 = 13
01010101 = 85
```

查询:

```
SELECT groupBitAnd(num) FROM t
```

`num` 是包含测试数据的列。

结果:

```
binary     decimal
00000100 = 4
```
', 0, 1, '2021-08-18 10:26:37', 1, '2021-08-18 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(100, '#### groupBitOr

对于数字序列按位应用 `OR` 。

**语法**

```
groupBitOr(expr)
```

**参数**

`expr` – 结果为 `UInt*` 类型的表达式。

**返回值**

`UInt*` 类型的值。

**示例**

测试数据::

```
binary     decimal
00101100 = 44
00011100 = 28
00001101 = 13
01010101 = 85
```

查询:

```
SELECT groupBitOr(num) FROM t
```

`num` 是包含测试数据的列。

结果:

```
binary     decimal
01111101 = 125
```
', 0, 1, '2021-08-19 10:26:37', 1, '2021-08-19 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(101, '#### groupBitXor

对于数字序列按位应用 `XOR` 。

**语法**

```
groupBitXor(expr)
```

**参数**

`expr` – 结果为 `UInt*` 类型的表达式。

**返回值**

`UInt*` 类型的值。

**示例**

测试数据:

```
binary     decimal
00101100 = 44
00011100 = 28
00001101 = 13
01010101 = 85
```

查询:

```
SELECT groupBitXor(num) FROM t
```

`num` 是包含测试数据的列。

结果:

```
binary     decimal
01101000 = 104
```
', 0, 1, '2021-08-20 10:26:37', 1, '2021-08-20 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(102, 'vgroupBitmap

从无符号整数列进行位图或聚合计算，返回 `UInt64` 类型的基数，如果添加后缀 `State` ，则返回位图对象。

**语法**

```
groupBitmap(expr)
```

**参数**

`expr` – 结果为 `UInt*` 类型的表达式。

**返回值**

`UInt64` 类型的值。

**示例**

测试数据:

```
UserID
1
1
2
3
```

查询:

```
SELECT groupBitmap(UserID) as num FROM t
```

结果:

```
num
3
```
', 0, 1, '2021-08-21 10:26:37', 1, '2021-08-21 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(103, '#### groupBitmapAnd

计算位图列的 `AND` ，返回 `UInt64` 类型的基数，如果添加后缀 `State` ，则返回 位图对象。

**语法**

```
groupBitmapAnd(expr)
```

**参数**

`expr` – 结果为 `AggregateFunction(groupBitmap, UInt*)` 类型的表达式。

**返回值**

`UInt64` 类型的值。

**示例**

```
DROP TABLE IF EXISTS bitmap_column_expr_test2;
CREATE TABLE bitmap_column_expr_test2
(
    tag_id String,
    z AggregateFunction(groupBitmap, UInt32)
)
ENGINE = MergeTree
ORDER BY tag_id;

INSERT INTO bitmap_column_expr_test2 VALUES (''tag1'', bitmapBuild(cast([1,2,3,4,5,6,7,8,9,10] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (''tag2'', bitmapBuild(cast([6,7,8,9,10,11,12,13,14,15] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (''tag3'', bitmapBuild(cast([2,4,6,8,10,12] as Array(UInt32))));

SELECT groupBitmapAnd(z) FROM bitmap_column_expr_test2 WHERE like(tag_id, ''tag%'');
┌─groupBitmapAnd(z)─┐
│               3   │
└───────────────────┘

SELECT arraySort(bitmapToArray(groupBitmapAndState(z))) FROM bitmap_column_expr_test2 WHERE like(tag_id, ''tag%'');
┌─arraySort(bitmapToArray(groupBitmapAndState(z)))─┐
│ [6,8,10]                                         │
└──────────────────────────────────────────────────┘
```
', 0, 1, '2021-08-22 10:26:37', 1, '2021-08-22 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(104, '#### groupBitmapOr

计算位图列的 `OR` ，返回 `UInt64` 类型的基数，如果添加后缀 `State` ，则返回 位图对象。

**语法**

```
groupBitmapOr(expr)
```

**参数**

`expr` – 结果为 `AggregateFunction(groupBitmap, UInt*)` 类型的表达式。

**返回值**

`UInt64` 类型的值。

**示例**

```
DROP TABLE IF EXISTS bitmap_column_expr_test2;
CREATE TABLE bitmap_column_expr_test2
(
    tag_id String,
    z AggregateFunction(groupBitmap, UInt32)
)
ENGINE = MergeTree
ORDER BY tag_id;

INSERT INTO bitmap_column_expr_test2 VALUES (''tag1'', bitmapBuild(cast([1,2,3,4,5,6,7,8,9,10] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (''tag2'', bitmapBuild(cast([6,7,8,9,10,11,12,13,14,15] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (''tag3'', bitmapBuild(cast([2,4,6,8,10,12] as Array(UInt32))));

SELECT groupBitmapOr(z) FROM bitmap_column_expr_test2 WHERE like(tag_id, ''tag%'');
┌─groupBitmapOr(z)─┐
│             15   │
└──────────────────┘

SELECT arraySort(bitmapToArray(groupBitmapOrState(z))) FROM bitmap_column_expr_test2 WHERE like(tag_id, ''tag%'');
┌─arraySort(bitmapToArray(groupBitmapOrState(z)))─┐
│ [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]           │
└─────────────────────────────────────────────────┘
```
', 0, 1, '2021-08-23 10:26:37', 1, '2021-08-23 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(105, '#### groupBitmapXor

计算位图列的 `XOR` ，返回 `UInt64` 类型的基数，如果添加后缀 `State` ，则返回 位图对象。

**语法**

```
groupBitmapXor(expr)
```

**参数**

`expr` – 结果为 `AggregateFunction(groupBitmap, UInt*)` 类型的表达式。

**返回值**

`UInt64` 类型的值。

**示例**

```
DROP TABLE IF EXISTS bitmap_column_expr_test2;
CREATE TABLE bitmap_column_expr_test2
(
    tag_id String,
    z AggregateFunction(groupBitmap, UInt32)
)
ENGINE = MergeTree
ORDER BY tag_id;

INSERT INTO bitmap_column_expr_test2 VALUES (''tag1'', bitmapBuild(cast([1,2,3,4,5,6,7,8,9,10] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (''tag2'', bitmapBuild(cast([6,7,8,9,10,11,12,13,14,15] as Array(UInt32))));
INSERT INTO bitmap_column_expr_test2 VALUES (''tag3'', bitmapBuild(cast([2,4,6,8,10,12] as Array(UInt32))));

SELECT groupBitmapXor(z) FROM bitmap_column_expr_test2 WHERE like(tag_id, ''tag%'');
┌─groupBitmapXor(z)─┐
│              10   │
└───────────────────┘

SELECT arraySort(bitmapToArray(groupBitmapXorState(z))) FROM bitmap_column_expr_test2 WHERE like(tag_id, ''tag%'');
┌─arraySort(bitmapToArray(groupBitmapXorState(z)))─┐
│ [1,3,5,6,8,10,11,13,14,15]                       │
└──────────────────────────────────────────────────┘
```
', 0, 1, '2021-08-24 10:26:37', 1, '2021-08-24 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(106, '#### sumWithOverflow

使用与输入参数相同的数据类型计算结果的数字总和。如果总和超过此数据类型的最大值，则使用溢出进行计算。

只适用于数字。
', 0, 1, '2021-08-25 10:26:37', 1, '2021-08-25 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(107, '#### deltaSum

计算连续行之间的差值和。如果差值为负，则忽略。

**语法**

```
deltaSum(value)
```

**参数**

- `value` — 必须是 整型 或者 浮点型 。

**返回值**

- `Integer` or `Float` 型的算术差值和。

**示例**

查询:

```
SELECT deltaSum(arrayJoin([1, 2, 3]));
```

结果:

```
┌─deltaSum(arrayJoin([1, 2, 3]))─┐
│                              2 │
└────────────────────────────────┘
```

查询:

```
SELECT deltaSum(arrayJoin([1, 2, 3, 0, 3, 4, 2, 3]));
```

结果:

```
┌─deltaSum(arrayJoin([1, 2, 3, 0, 3, 4, 2, 3]))─┐
│                                             7 │
└───────────────────────────────────────────────┘
```

查询:

```
SELECT deltaSum(arrayJoin([2.25, 3, 4.5]));
```

结果:

```
┌─deltaSum(arrayJoin([2.25, 3, 4.5]))─┐
│                                2.25 │
└─────────────────────────────────────┘
```
', 0, 1, '2021-08-26 10:26:37', 1, '2021-08-26 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(108, '#### sumMap

**语法**

```
sumMap(key, value)
或
sumMap(Tuple(key, value))
```

根据 `key` 数组中指定的键对 `value` 数组进行求和。

传递 `key` 和 `value` 数组的元组与传递 `key` 和 `value` 的两个数组是同义的。
要总计的每一行的 `key` 和 `value` (数组)元素的数量必须相同。
返回两个数组组成的一个元组: 排好序的 `key` 和对应 `key` 的 `value` 之和。

示例:

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
    (''2000-01-01'', ''2000-01-01 00:00:00'', [1, 2, 3], [10, 10, 10], ([1, 2, 3], [10, 10, 10])),
    (''2000-01-01'', ''2000-01-01 00:00:00'', [3, 4, 5], [10, 10, 10], ([3, 4, 5], [10, 10, 10])),
    (''2000-01-01'', ''2000-01-01 00:01:00'', [4, 5, 6], [10, 10, 10], ([4, 5, 6], [10, 10, 10])),
    (''2000-01-01'', ''2000-01-01 00:01:00'', [6, 7, 8], [10, 10, 10], ([6, 7, 8], [10, 10, 10]));

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
```
', 0, 1, '2021-08-27 10:26:37', 1, '2021-08-27 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(109, '#### minMap

**语法**

```
minMap(key, value)
或
minMap(Tuple(key, value))
```

根据 `key` 数组中指定的键对 `value` 数组计算最小值。

传递 `key` 和 `value` 数组的元组与传递 `key` 和 `value` 的两个数组是同义的。
要总计的每一行的 `key` 和 `value` (数组)元素的数量必须相同。
返回两个数组组成的元组: 排好序的 `key` 和对应 `key` 的 `value` 计算值(最小值)。

**示例**

```
SELECT minMap(a, b)
FROM values(''a Array(Int32), b Array(Int64)'', ([1, 2], [2, 2]), ([2, 3], [1, 1]))
┌─minMap(a, b)──────┐
│ ([1,2,3],[2,1,1]) │
└───────────────────┘
```
', 0, 1, '2021-08-28 10:26:37', 1, '2021-08-28 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(110, '#### maxMap

**语法**

```
maxMap(key, value)
 或
maxMap(Tuple(key, value))
```

根据 `key` 数组中指定的键对 `value` 数组计算最大值。

传递 `key` 和 `value` 数组的元组与传递 `key` 和 `value` 的两个数组是同义的。
要总计的每一行的 `key` 和 `value` (数组)元素的数量必须相同。
返回两个数组组成的元组: 排好序的`key` 和对应 `key` 的 `value` 计算值(最大值)。

示例:

```
SELECT maxMap(a, b)
FROM values(''a Array(Int32), b Array(Int64)'', ([1, 2], [2, 2]), ([2, 3], [1, 1]))
┌─maxMap(a, b)──────┐
│ ([1,2,3],[2,2,1]) │
└───────────────────┘
```
', 0, 1, '2021-08-29 10:26:37', 1, '2021-08-29 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(111, '#### initializeAggregation

初始化你输入行的聚合。用于后缀是 `State` 的函数。
用它来测试或处理 `AggregateFunction` 和 `AggregationgMergeTree` 类型的列。

**语法**

```
initializeAggregation (aggregate_function, column_1, column_2)
```

**参数**

- `aggregate_function` — 聚合函数名。 这个函数的状态 — 正创建的。String。
- `column_n` — 将其转换为函数的参数的列。String。

**返回值**

返回输入行的聚合结果。返回类型将与 `initializeAgregation` 用作第一个参数的函数的返回类型相同。
例如，对于后缀为 `State` 的函数，返回类型将是 `AggregateFunction`。

**示例**

查询:

```
SELECT uniqMerge(state) FROM (SELECT initializeAggregation(''uniqState'', number % 3) AS state FROM system.numbers LIMIT 10000);
```

结果:

┌─uniqMerge(state)─┐
│ 3 │
└──────────────────┘
', 0, 1, '2021-08-30 10:26:37', 1, '2021-08-30 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(112, '#### skewPop

计算给定序列的偏度。

**语法**

```
skewPop(expr)
```

**参数**

`expr` — 表达式 返回一个数字。

**返回值**

给定分布的偏度。类型 — Float64

**示例**

```
SELECT skewPop(value) FROM series_with_value_column;
```
', 0, 1, '2021-08-31 10:26:37', 1, '2021-08-31 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(113, '#### skewSamp

计算给定序列的样本偏度。

如果传递的值形成其样本，它代表了一个随机变量的偏度的无偏估计。

**语法**

```
skewSamp(expr)
```

**参数**

`expr` — 表达式 返回一个数字。

**返回值**

给定分布的偏度。 类型 — Float64。 如果 `n <= 1` (`n` 样本的大小), 函数返回 `nan`。

**示例**

```
SELECT skewSamp(value) FROM series_with_value_column;
```
', 0, 1, '2021-09-01 10:26:37', 1, '2021-09-01 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(114, '#### kurtPop

计算给定序列的 峰度。

**语法**

```
kurtPop(expr)
```

**参数**

`expr` — 结果为数字的 表达式。

**返回值**

给定分布的峰度。 类型 — Float64

**示例**

\``` sql
SELECT kurtPop(value) FROM series_with_value_column;
', 0, 1, '2021-09-02 10:26:37', 1, '2021-09-02 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(115, '#### kurtSamp

计算给定序列的 峰度样本。
它表示随机变量峰度的无偏估计，如果传递的值形成其样本。

**语法**

```
kurtSamp(expr)
```

**参数**

`expr` — 结果为数字的 表达式。

**返回值**

给定序列的峰度。类型 — Float64。 如果 `n <= 1` (`n` 是样本的大小），则该函数返回 `nan`。

**示例**

```
SELECT kurtSamp(value) FROM series_with_value_column;
```
', 0, 1, '2021-09-03 10:26:37', 1, '2021-09-03 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(116, '#### uniq

计算参数的不同值的近似数量。

**语法**

```
uniq(x[, ...])
```

**参数**

该函数采用可变数量的参数。 参数可以是 `Tuple`, `Array`, `Date`, `DateTime`, `String`, 或数字类型。

**返回值**

- UInt64 类型数值。

**实现细节**

功能:

- 计算聚合中所有参数的哈希值，然后在计算中使用它。

- 使用自适应采样算法。 对于计算状态，该函数使用最多65536个元素哈希值的样本。

  这个算法是非常精确的，并且对于CPU来说非常高效。如果查询包含一些这样的函数，那和其他聚合函数相比 `uniq` 将是几乎一样快。

- 确定性地提供结果（它不依赖于查询处理顺序）。

我们建议在几乎所有情况下使用此功能。

**参见**

- uniqCombined
- uniqCombined64
- uniqHLL12
- uniqExact
', 0, 1, '2021-09-04 10:26:37', 1, '2021-09-04 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(117, '#### uniqExact

计算不同参数值的准确数目。

**语法**

```
uniqExact(x[, ...])
```

如果你绝对需要一个确切的结果，使用 `uniqExact` 函数。 否则使用 uniq 函数。

`uniqExact` 函数比 `uniq` 使用更多的内存，因为状态的大小随着不同值的数量的增加而无界增长。

**参数**

该函数采用可变数量的参数。 参数可以是 `Tuple`, `Array`, `Date`, `DateTime`, `String`，或数字类型。

**参见**

- uniq
- uniqCombined
- uniqHLL12
', 0, 1, '2021-09-05 10:26:37', 1, '2021-09-05 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(118, '#### uniqCombined

计算不同参数值的近似数量。

**语法**

```
uniqCombined(HLL_precision)(x[, ...])
```

该 `uniqCombined` 函数是计算不同值数量的不错选择。

**参数**

该函数采用可变数量的参数。 参数可以是 `Tuple`, `Array`, `Date`, `DateTime`, `String`，或数字类型。

`HLL_precision` 是以2为底的单元格数的对数 HyperLogLog。可选，您可以将该函数用作 `uniqCombined(x, ...])`。 `HLL_precision` 的默认值是17，这是有效的96KiB的空间（2^17个单元，每个6比特）。

**返回值**

- 一个UInt64类型的数字。

**实现细节**

功能:

- 为聚合中的所有参数计算哈希（`String`类型用64位哈希，其他32位），然后在计算中使用它。

- 使用三种算法的组合：数组、哈希表和包含错误修正表的HyperLogLog。

  少量的不同的值，使用数组。 值再多一些，使用哈希表。对于大量的数据来说，使用HyperLogLog，HyperLogLog占用一个固定的内存空间。

- 确定性地提供结果（它不依赖于查询处理顺序）。

注

由于它对非 `String` 类型使用32位哈希，对于基数显著大于`UINT_MAX` ，结果将有非常高的误差(误差将在几百亿不同值之后迅速提高), 因此这种情况，你应该使用 uniqCombined64

相比于 uniq 函数, 该 `uniqCombined`:

- 消耗内存要少几倍。
- 计算精度高出几倍。
- 通常具有略低的性能。 在某些情况下, `uniqCombined` 可以表现得比 `uniq` 好，例如，使用通过网络传输大量聚合状态的分布式查询。

**参见**

- uniq
- uniqCombined64
- uniqHLL12
- uniqExact
', 0, 1, '2021-09-06 10:26:37', 1, '2021-09-06 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(119, '#### uniqCombined64

和 uniqCombined一样, 但对于所有数据类型使用64位哈希。
', 0, 1, '2021-09-07 10:26:37', 1, '2021-09-07 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(120, '#### uniqHLL12

计算不同参数值的近似数量，使用 HyperLogLog 算法。

**语法**

```
uniqHLL12(x[, ...])
```

**参数**

该函数采用可变数量的参数。 参数可以是 `Tuple`, `Array`, `Date`, `DateTime`, `String`，或数字类型。

**返回值**

**返回值**

- 一个UInt64类型的数字。

**实现细节**

功能:

- 计算聚合中所有参数的哈希值，然后在计算中使用它。

- 使用 HyperLogLog 算法来近似不同参数值的数量。

  ```
  使用2^12个5比特单元。 状态的大小略大于2.5KB。 对于小数据集（<10K元素），结果不是很准确（误差高达10%）。 但是, 对于高基数数据集（10K-100M），结果相当准确，最大误差约为1.6%。Starting from 100M, the estimation error increases, and the function will return very inaccurate results for data sets with extremely high cardinality (1B+ elements).
  ```

- 提供确定结果（它不依赖于查询处理顺序）。

我们不建议使用此函数。 在大多数情况下, 使用 uniq 或 uniqCombined 函数。

**参见**

- uniq
- uniqCombined
- uniqExact
', 0, 1, '2021-09-08 10:26:37', 1, '2021-09-08 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(121, '#### quantile

计算数字序列的近似分位数。
此函数应用[水塘抽样]reservoir sampling。
结果是不确定的。要获得精确的分位数，使用 quantileExact 函数。
当在一个查询中使用多个不同层次的 `quantile*` 时，内部状态不会被组合（即查询的工作效率低于组合情况）。在这种情况下，使用 quantiles 函数。

**语法**

```
quantile(level)(expr)
```

别名: `median`。

**参数**

- `level` — 分位数层次。可选参数。从0到1的一个float类型的常量。我们推荐 `level` 值的范围为 `0.01, 0.99]`。默认值：0.5。当 `level=0.5` 时，该函数计算 中位数。
- `expr` — 求值表达式，类型为数值类型data types, Date 或 DateTime。

**返回值**

- 指定层次的分位数。

类型:

- Float64 用于数字数据类型输入。
- Date 如果输入值是 `Date` 类型。
- DateTime 如果输入值是 `DateTime` 类型。

**示例**

输入表:

```
┌─val─┐
│   1 │
│   1 │
│   2 │
│   3 │
└─────┘
```

查询:

```
SELECT quantile(val) FROM t
```

结果:

```
┌─quantile(val)─┐
│           1.5 │
└───────────────┘
```

**参见**

- 中位数
- 分位数
', 0, 1, '2021-09-09 10:26:37', 1, '2021-09-09 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(122, '#### quantiles

**语法**

```
quantiles(level1, level2, …)(x)
```

所有分位数函数(quantile)也有相应的分位数(quantiles)函数: `quantiles`, `quantilesDeterministic`, `quantilesTiming`, `quantilesTimingWeighted`, `quantilesExact`, `quantilesExactWeighted`, `quantilesTDigest`。 这些函数一次计算所列的级别的所有分位数, 并返回结果值的数组。
', 0, 1, '2021-09-10 10:26:37', 1, '2021-09-10 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(123, '#### quantileExact

准确计算数字序列的分位数。

为了准确计算，所有输入的数据被合并为一个数组，并且部分的排序。因此该函数需要 `O(n)` 的内存，n为输入数据的个数。但是对于少量数据来说，该函数还是非常有效的。

当在一个查询中使用多个不同层次的 `quantile*` 时，内部状态不会被组合（即查询的工作效率低于组合情况）。在这种情况下，使用 quantiles 函数。

**语法**

```
quantileExact(level)(expr)
```

别名: `medianExact`。

**参数**

- `level` — 分位数层次。可选参数。从0到1的一个float类型的常量。我们推荐 `level` 值的范围为 `0.01, 0.99]`。默认值：0.5。当 `level=0.5` 时，该函数计算中位数。
- `expr` — 求值表达式，类型为数值类型data types, Date 或 DateTime。

**返回值**

- 指定层次的分位数。

类型:

- Float64 对于数字数据类型输入。
- 日期 如果输入值具有 `Date` 类型。
- 日期时间 如果输入值具有 `DateTime` 类型。

**示例**

查询:

```
SELECT quantileExact(number) FROM numbers(10)
```

结果:

```
┌─quantileExact(number)─┐
│                     5 │
└───────────────────────┘
```

#### quantileExactLow

和 `quantileExact` 相似, 准确计算数字序列的分位数。

为了准确计算，所有输入的数据被合并为一个数组，并且全排序。这排序算法的复杂度是 `O(N·log(N))`, 其中 `N = std::distance(first, last)` 比较。

返回值取决于分位数级别和所选取的元素数量，即如果级别是 0.5, 函数返回偶数元素的低位中位数，奇数元素的中位数。中位数计算类似于 python 中使用的median_low的实现。

对于所有其他级别， 返回 `level * size_of_array` 值所对应的索引的元素值。

例如:

```
SELECT quantileExactLow(0.1)(number) FROM numbers(10)

┌─quantileExactLow(0.1)(number)─┐
│                             1 │
└───────────────────────────────┘
```

当在一个查询中使用多个不同层次的 `quantile*` 时，内部状态不会被组合（即查询的工作效率低于组合情况）。在这种情况下，使用 quantiles 函数。

**语法**

```
quantileExactLow(level)(expr)
```

别名: `medianExactLow`。

**参数**

- `level` — 分位数层次。可选参数。从0到1的一个float类型的常量。我们推荐 `level` 值的范围为 `0.01, 0.99]`。默认值：0.5。当 `level=0.5` 时，该函数计算 中位数。
- `expr` — — 求值表达式，类型为数值类型data types, Date 或 DateTime。

**返回值**

- 指定层次的分位数。

类型:

- Float64 用于数字数据类型输入。
- Date 如果输入值是 `Date` 类型。
- DateTime 如果输入值是 `DateTime` 类型。

**示例**

查询:

```
SELECT quantileExactLow(number) FROM numbers(10)
```

结果:

```
┌─quantileExactLow(number)─┐
│                        4 │
└──────────────────────────┘
```

#### quantileExactHigh

和 `quantileExact` 相似, 准确计算数字序列的分位数。

为了准确计算，所有输入的数据被合并为一个数组，并且全排序。这排序算法的复杂度是 `O(N·log(N))`, 其中 `N = std::distance(first, last)` 比较。

返回值取决于分位数级别和所选取的元素数量，即如果级别是 0.5, 函数返回偶数元素的低位中位数，奇数元素的中位数。中位数计算类似于 python 中使用的median_high的实现。

对于所有其他级别， 返回 `level * size_of_array` 值所对应的索引的元素值。

这个实现与当前的 `quantileExact` 实现完全相似。

当在一个查询中使用多个不同层次的 `quantile*` 时，内部状态不会被组合（即查询的工作效率低于组合情况）。在这种情况下，使用 quantiles 函数。

**语法**

```
quantileExactHigh(level)(expr)
```

别名: `medianExactHigh`。

**参数**

- `level` — 分位数层次。可选参数。从0到1的一个float类型的常量。我们推荐 `level` 值的范围为 `0.01, 0.99]`。默认值：0.5。当 `level=0.5` 时，该函数计算 中位数。
- `expr` — — 求值表达式，类型为数值类型data types, Date 或 DateTime。

**返回值**

- 指定层次的分位数。

类型:

- Float64 用于数字数据类型输入。
- Date 如果输入值是 `Date` 类型。
- DateTime 如果输入值是 `DateTime` 类型。

**示例**

查询:

```
SELECT quantileExactHigh(number) FROM numbers(10)
```

结果:

```
┌─quantileExactHigh(number)─┐
│                         5 │
└───────────────────────────┘
```

**参见**

- 中位数
- 分位数
', 0, 1, '2021-09-11 10:26:37', 1, '2021-09-11 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(124, '#### quantileExactWeighted

考虑到每个元素的权重，然后准确计算数值序列的分位数。

为了准确计算，所有输入的数据被合并为一个数组，并且部分的排序。每个输入值需要根据 `weight` 计算求和。该算法使用哈希表。正因为如此，在数据重复较多的时候使用的内存是少于quantileExact的。 您可以使用此函数代替 `quantileExact` 并指定`weight`为 1 。

当在一个查询中使用多个不同层次的 `quantile*` 时，内部状态不会被组合（即查询的工作效率低于组合情况）。在这种情况下，使用 quantiles 函数。

**语法**

```
quantileExactWeighted(level)(expr, weight)
```

别名: `medianExactWeighted`。

**参数**
\- `level` — 分位数层次。可选参数。从0到1的一个float类型的常量。我们推荐 `level` 值的范围为 `0.01, 0.99]`. 默认值：0.5。当 `level=0.5` 时，该函数计算 中位数。
\- `expr` — 求值表达式，类型为数值类型data types, Date 或 DateTime。
\- `weight` — 权重序列。 权重是一个数据出现的数值。

**返回值**

- 指定层次的分位数。

类型:

- Float64 对于数字数据类型输入。
- 日期 如果输入值具有 `Date` 类型。
- 日期时间 如果输入值具有 `DateTime` 类型。

**示例**

输入表:

```
┌─n─┬─val─┐
│ 0 │   3 │
│ 1 │   2 │
│ 2 │   1 │
│ 5 │   4 │
└───┴─────┘
```

查询:

```
SELECT quantileExactWeighted(n, val) FROM t
```

结果:

```
┌─quantileExactWeighted(n, val)─┐
│                             1 │
└───────────────────────────────┘
```

**参见**

- 中位数
- 分位数
', 0, 1, '2021-09-12 10:26:37', 1, '2021-09-12 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(125, '#### quantileTiming

使用确定的精度计算数字数据序列的分位数。

结果是确定性的（它不依赖于查询处理顺序）。该函数针对描述加载网页时间或后端响应时间等分布的序列进行了优化。

当在一个查询中使用多个不同层次的 `quantile*` 时，内部状态不会被组合（即查询的工作效率低于组合情况）。在这种情况下，使用quantiles函数。

**语法**

```
quantileTiming(level)(expr)
```

别名: `medianTiming`。

**参数**

- `level` — 分位数层次。可选参数。从0到1的一个float类型的常量。我们推荐 `level` 值的范围为 `0.01, 0.99]` 。默认值：0.5。当 `level=0.5` 时，该函数计算 中位数。
- `expr` — 求值表达式 返回 Float* 类型数值。
  - 如果输入负值，那结果是不可预期的。
  - 如果输入值大于30000（页面加载时间大于30s），那我们假设为30000。

**精度**

计算是准确的，如果:

- 值的总数不超过5670。
- 总数值超过5670，但页面加载时间小于1024ms。

否则，计算结果将四舍五入到16毫秒的最接近倍数。

注

对于计算页面加载时间分位数， 此函数比quantile更有效和准确。

**返回值**

- 指定层次的分位数。

类型: `Float32`。

注

如果没有值传递给函数（当使用 `quantileTimingIf`), NaN被返回。 这样做的目的是将这些案例与导致零的案例区分开来。 参见 ORDER BY clause 对于 `NaN` 值排序注意事项。

**示例**

输入表:

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

查询:

```
SELECT quantileTiming(response_time) FROM t
```

结果:

```
┌─quantileTiming(response_time)─┐
│                           126 │
└───────────────────────────────┘
```

**参见**

- 中位数
- 分位数
', 0, 1, '2021-09-13 10:26:37', 1, '2021-09-13 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(126, '#### quantileTimingWeighted

根据每个序列成员的权重，使用确定的精度计算数字序列的分位数。

结果是确定性的（它不依赖于查询处理顺序）。该函数针对描述加载网页时间或后端响应时间等分布的序列进行了优化。

当在一个查询中使用多个不同层次的 `quantile*` 时，内部状态不会被组合（即查询的工作效率低于组合情况）。在这种情况下，使用quantiles功能。

**语法**

```
quantileTimingWeighted(level)(expr, weight)
```

别名: `medianTimingWeighted`。

**参数**

- `level` — 分位数层次。可选参数。从0到1的一个float类型的常量。我们推荐 `level` 值的范围为 `0.01, 0.99]` 。默认值：0.5。当 `level=0.5` 时，该函数计算 中位数。
- `expr` — 求值表达式 返回 Float* 类型数值。
  - 如果输入负值，那结果是不可预期的。
  - 如果输入值大于30000（页面加载时间大于30s），那我们假设为30000。
- `weight` — 权重序列。 权重是一个数据出现的数值。

**精度**

计算是准确的，如果:

- 值的总数不超过5670。
- 总数值超过5670，但页面加载时间小于1024ms。

否则，计算结果将四舍五入到16毫秒的最接近倍数。

注

对于计算页面加载时间分位数， 此函数比quantile更有效和准确。

**返回值**

- 指定层次的分位数。

类型: `Float32`。

注

如果没有值传递给函数（当使用 `quantileTimingIf`), NaN被返回。 这样做的目的是将这些案例与导致零的案例区分开来。 参见 ORDER BY clause 对于 `NaN` 值排序注意事项。

**示例**

输入表:

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

查询:

```
SELECT quantileTimingWeighted(response_time, weight) FROM t
```

结果:

```
┌─quantileTimingWeighted(response_time, weight)─┐
│                                           112 │
└───────────────────────────────────────────────┘
```

#### quantilesTimingWeighted

类似于 `quantileTimingWeighted` , 但接受多个分位数层次参数，并返回一个由这些分位数值组成的数组。

**示例**

输入表:

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

查询:

```
SELECT quantilesTimingWeighted(0,5, 0.99)(response_time, weight) FROM t
```

结果:

```
┌─quantilesTimingWeighted(0.5, 0.99)(response_time, weight)─┐
│ [112,162]                                                 │
└───────────────────────────────────────────────────────────┘
```

**参见**

- 中位数
- 分位数
', 0, 1, '2021-09-14 10:26:37', 1, '2021-09-14 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(127, '#### quantileDeterministic

计算数字序列的近似分位数。

此功能适用 水塘抽样，使用储存器最大到8192和随机数发生器进行采样。 结果是非确定性的。 要获得精确的分位数，请使用 quantileExact 功能。

当在一个查询中使用多个不同层次的 `quantile*` 时，内部状态不会被组合（即查询的工作效率低于组合情况）。在这种情况下，使用quantiles功能。

**语法**

```
quantileDeterministic(level)(expr, determinator)
```

别名: `medianDeterministic`。

**参数**

- `level` — 分位数层次。可选参数。从0到1的一个float类型的常量。 我们推荐 `level` 值的范围为 `0.01, 0.99]`。默认值：0.5。 当 `level=0.5`时，该函数计算 中位数。
- `expr` — 求值表达式，类型为数值类型data types, Date 或 DateTime。
- `determinator` — 一个数字，其hash被用来代替在水塘抽样中随机生成的数字，这样可以保证取样的确定性。你可以使用用户ID或者事件ID等任何正数，但是如果相同的 `determinator` 出现多次，那结果很可能不正确。
  **返回值**
- 指定层次的近似分位数。

类型:

- Float64 用于数字数据类型输入。
- Date 如果输入值是 `Date` 类型。
- DateTime 如果输入值是 `DateTime` 类型。

**示例**

输入表:

```
┌─val─┐
│   1 │
│   1 │
│   2 │
│   3 │
└─────┘
```

查询:

```
SELECT quantileDeterministic(val, 1) FROM t
```

结果:

```
┌─quantileDeterministic(val, 1)─┐
│                           1.5 │
└───────────────────────────────┘
```

**参见**

- 中位数
- 分位数
', 0, 1, '2021-09-15 10:26:37', 1, '2021-09-15 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(128, '#### quantileTDigest

使用t-digest 算法计算数字序列近似分位数。

最大误差为1%。 内存消耗为 `log(n)`，这里 `n` 是值的个数。 结果取决于运行查询的顺序，并且是不确定的。

该函数的性能低于 quantile 或 quantileTiming 的性能。 从状态大小和精度的比值来看，这个函数比 `quantile` 更优秀。

当在一个查询中使用多个不同层次的 `quantile*` 时，内部状态不会被组合（即查询的工作效率低于组合情况）。在这种情况下，使用 quantiles 函数。

**语法**

```
quantileTDigest(level)(expr)
```

别名: `medianTDigest`。

**参数**

- `level` — 分位数层次。可选参数。从0到1的一个float类型的常量。我们推荐 `level` 值的范围为 `0.01, 0.99]` 。默认值：0.5。当 `level=0.5` 时，该函数计算 中位数。
- `expr` — 求值表达式，类型为数值类型data types, Date 或 DateTime。

**返回值**

- 指定层次的分位数。

类型:

- Float64 用于数字数据类型输入。
- Date 如果输入值是 `Date` 类型。
- DateTime 如果输入值是 `DateTime` 类型。

**示例**

查询:

```
SELECT quantileTDigest(number) FROM numbers(10)
```

结果:

```
┌─quantileTDigest(number)─┐
│                     4.5 │
└─────────────────────────┘
```

**参见**

- 中位数
- 分位数
', 0, 1, '2021-09-16 10:26:37', 1, '2021-09-16 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(129, '#### quantileTDigestWeighted

使用t-digest 算法计算数字序列近似分位数。该函数考虑了每个序列成员的权重。最大误差为1%。 内存消耗为 `log(n)`，这里 `n` 是值的个数。

该函数的性能低于 quantile 或 quantileTiming 的性能。 从状态大小和精度的比值来看，这个函数比 `quantile` 更优秀。

结果取决于运行查询的顺序，并且是不确定的。

当在一个查询中使用多个不同层次的 `quantile*` 时，内部状态不会被组合（即查询的工作效率低于组合情况）。在这种情况下，使用 quantiles 函数。

**语法**

```
quantileTDigestWeighted(level)(expr, weight)
```

别名: `medianTDigestWeighted`。

**参数**

- `level` — 分位数层次。可选参数。从0到1的一个float类型的常量。我们推荐 `level` 值的范围为 `0.01, 0.99]` 。默认值：0.5。 当 `level=0.5` 时，该函数计算 中位数。
- `expr` — 求值表达式，类型为数值类型data types, Date 或 DateTime。
- `weight` — 权重序列。 权重是一个数据出现的数值。

**返回值**

- 指定层次的分位数。

类型:

- Float64 用于数字数据类型输入。
- Date 如果输入值是 `Date` 类型。
- DateTime 如果输入值是 `DateTime` 类型。

**示例**

查询:

```
SELECT quantileTDigestWeighted(number, 1) FROM numbers(10)
```

结果:

```
┌─quantileTDigestWeighted(number, 1)─┐
│                                4.5 │
└────────────────────────────────────┘
```

**参见**

- 中位数
- 分位数
', 0, 1, '2021-09-17 10:26:37', 1, '2021-09-17 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(130, '#### simpleLinearRegression

执行简单（一维）线性回归。

**语法**

```
simpleLinearRegression(x, y)
```

**参数**

- `x` — x轴。
- `y` — y轴。

**返回值**

符合`y = a*x + b`的常量 `(a, b)` 。

**示例**

```
SELECT arrayReduce(''simpleLinearRegression'', [0, 1, 2, 3], [0, 1, 2, 3])
┌─arrayReduce(''simpleLinearRegression'', [0, 1, 2, 3], [0, 1, 2, 3])─┐
│ (1,0)                                                             │
└───────────────────────────────────────────────────────────────────┘
SELECT arrayReduce(''simpleLinearRegression'', [0, 1, 2, 3], [3, 4, 5, 6])
┌─arrayReduce(''simpleLinearRegression'', [0, 1, 2, 3], [3, 4, 5, 6])─┐
│ (1,3)                                                             │
└───────────────────────────────────────────────────────────────────┘
```
', 0, 1, '2021-09-18 10:26:37', 1, '2021-09-18 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(131, '#### stochasticLinearRegression

该函数实现随机线性回归。 它支持自定义参数的学习率、L2正则化系数、微批，并且具有少量更新权重的方法（Adam （默认）， simple SGD， Momentum， Nesterov）。

#### 参数

有4个可自定义的参数。它们按顺序传递给函数，但不需要传递所有四个参数——将使用默认值，然而好的模型需要一些参数调整。

**语法**

```
stochasticLinearRegression(1.0, 1.0, 10, ''SGD'')
```

1. `learning rate` 当执行梯度下降步骤时，步长的系数。 过大的学习率可能会导致模型的权重无限大。 默认值为 `0.00001`。
2. `l2 regularization coefficient` 这可能有助于防止过度拟合。 默认值为 `0.1`。
3. `mini-batch size` 设置元素的数量，这些元素将被计算和求和以执行梯度下降的一个步骤。纯随机下降使用一个元素，但是具有小批量（约10个元素）使梯度步骤更稳定。 默认值为 `15`。
4. `method for updating weights` 他们是: `Adam` (默认情况下), `SGD`, `Momentum`, `Nesterov`。`Momentum` 和 `Nesterov` 需要更多的计算和内存，但是它们恰好在收敛速度和随机梯度方法的稳定性方面是有用的。

#### 使用

`stochasticLinearRegression` 用于两个步骤：拟合模型和预测新数据。 为了拟合模型并保存其状态以供以后使用，我们使用 `-State` 组合器，它基本上保存了状态（模型权重等）。
为了预测我们使用函数 evalMLMethod, 这需要一个状态作为参数以及特征来预测。



**1.** 拟合

可以使用这种查询。

```
CREATE TABLE IF NOT EXISTS train_data
(
    param1 Float64,
    param2 Float64,
    target Float64
) ENGINE = Memory;

CREATE TABLE your_model ENGINE = Memory AS SELECT
stochasticLinearRegressionState(0.1, 0.0, 5, ''SGD'')(target, param1, param2)
AS state FROM train_data;
```

在这里，我们还需要将数据插入到 `train_data` 表。参数的数量不是固定的，它只取决于传入 `linearRegressionState` 的参数数量。它们都必须是数值。
注意，目标值(我们想学习预测的)列作为第一个参数插入。

**2.** 预测

在将状态保存到表中之后，我们可以多次使用它进行预测，甚至与其他状态合并，创建新的更好的模型。

```
WITH (SELECT state FROM your_model) AS model SELECT
evalMLMethod(model, param1, param2) FROM test_data
```

查询将返回一列预测值。注意，`evalMLMethod` 的第一个参数是 `AggregateFunctionState` 对象, 接下来是特征列。

`test_data` 是一个类似 `train_data` 的表 但可能不包含目标值。

#### 注

1. 要合并两个模型，用户可以创建这样的查询:
   `sql SELECT state1 + state2 FROM your_models`
   其中 `your_models` 表包含这两个模型。此查询将返回新的 `AggregateFunctionState` 对象。
2. 如果没有使用 `-State` 组合器，用户可以为自己的目的获取所创建模型的权重，而不保存模型 。
   `sql SELECT stochasticLinearRegression(0.01)(target, param1, param2) FROM train_data`
   这样的查询将拟合模型，并返回其权重——首先是权重，对应模型的参数，最后一个是偏差。 所以在上面的例子中，查询将返回一个具有3个值的列。

**参见**

- 随机指标逻辑回归
- 线性回归和逻辑回归之间的差异
', 0, 1, '2021-09-19 10:26:37', 1, '2021-09-19 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(132, '#### stochasticLogisticRegression

该函数实现随机逻辑回归。 它可以用于二进制分类问题，支持与stochasticLinearRegression相同的自定义参数，并以相同的方式工作。

#### 参数

参数与stochasticLinearRegression中的参数完全相同:
`learning rate`, `l2 regularization coefficient`, `mini-batch size`, `method for updating weights`.
欲了解更多信息，参见参数.

**语法**

```
stochasticLogisticRegression(1.0, 1.0, 10, ''SGD'')
```

**1.** 拟合

```
参考[stochasticLinearRegression](####stochasticlinearregression-usage-fitting)  `拟合` 章节文档。

预测标签的取值范围为\[-1, 1\]
```

**2.** 预测

```
使用已经保存的state我们可以预测标签为 `1` 的对象的概率。
​``` sql
WITH (SELECT state FROM your_model) AS model SELECT
evalMLMethod(model, param1, param2) FROM test_data
​```

查询结果返回一个列的概率。注意 `evalMLMethod` 的第一个参数是 `AggregateFunctionState` 对象，接下来的参数是列的特性。

我们也可以设置概率的范围， 这样需要给元素指定不同的标签。

​``` sql
SELECT ans < 1.1 AND ans > 0.5 FROM
(WITH (SELECT state FROM your_model) AS model SELECT
evalMLMethod(model, param1, param2) AS ans FROM test_data)
​```

  结果是标签。

`test_data` 是一个像 `train_data` 一样的表，但是不包含目标值。
```

**参见**

- 随机指标线性回归
- 线性回归和逻辑回归之间的差异
', 0, 1, '2021-09-20 10:26:37', 1, '2021-09-20 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(133, '#### categoricalInformationValue

对于每个类别计算 `(P(tag = 1) - P(tag = 0))(log(P(tag = 1)) - log(P(tag = 0)))` 。

```
categoricalInformationValue(category1, category2, ..., tag)
```

结果指示离散（分类）要素如何使用 `[category1, category2, ...]` 有助于使用学习模型预测`tag`的值。
', 0, 1, '2021-09-21 10:26:37', 1, '2021-09-21 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(134, '#### studentTTest

对两个总体的样本应用t检验。

**语法**

```
studentTTest(sample_data, sample_index)
```

两个样本的值都在 `sample_data` 列中。如果 `sample_index` 等于 0，则该行的值属于第一个总体的样本。 反之属于第二个总体的样本。
零假设是总体的均值相等。假设为方差相等的正态分布。

**参数**

- `sample_data` — 样本数据。Integer, Float 或 Decimal。
- `sample_index` — 样本索引。Integer。

**返回值**

元组，有两个元素:

- 计算出的t统计量。 Float64。
- 计算出的p值。Float64。

**示例**

输入表:

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

查询:

```
SELECT studentTTest(sample_data, sample_index) FROM student_ttest;
```

结果:

```
┌─studentTTest(sample_data, sample_index)───┐
│ (-0.21739130434783777,0.8385421208415731) │
└───────────────────────────────────────────┘
```

**参见**

- Student''s t-test
- welchTTest function
', 0, 1, '2021-09-22 10:26:37', 1, '2021-09-22 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(135, '#### welchTTest

对两个总体的样本应用 Welch t检验。

**语法**

```
welchTTest(sample_data, sample_index)
```

两个样本的值都在 `sample_data` 列中。如果 `sample_index` 等于 0，则该行的值属于第一个总体的样本。 反之属于第二个总体的样本。
零假设是群体的均值相等。假设为正态分布。总体可能具有不相等的方差。

**参数**

- `sample_data` — 样本数据。Integer, Float 或 Decimal.
- `sample_index` — 样本索引。Integer.

**返回值**

元组，有两个元素:

- 计算出的t统计量。 Float64。
- 计算出的p值。Float64。

**示例**

输入表:

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

查询:

```
SELECT welchTTest(sample_data, sample_index) FROM welch_ttest;
```

结果:

```
┌─welchTTest(sample_data, sample_index)─────┐
│ (2.7988719532211235,0.051807360348581945) │
└───────────────────────────────────────────┘
```

**参见**

- Welch''s t-test
- studentTTest function
', 0, 1, '2021-09-23 10:26:37', 1, '2021-09-23 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(136, '#### mannWhitneyUTest

对两个总体的样本应用 Mann-Whitney 秩检验。

**语法**

```
mannWhitneyUTest[(alternative[, continuity_correction])](sample_data, sample_index)
```

两个样本的值都在 `sample_data` 列中。如果 `sample_index` 等于 0，则该行的值属于第一个总体的样本。 反之属于第二个总体的样本。
零假设是两个总体随机相等。也可以检验单边假设。该检验不假设数据具有正态分布。

**参数**

- `sample_data` — 样本数据。Integer, Float 或 Decimal。
- `sample_index` — 样本索引。Integer.

**参数**

- ```
  alternative
  ```



  — 供选假设。(可选，默认值是:



  ```
  ''two-sided''
  ```



  。)



  String

  。

  - `''two-sided''`;
  - `''greater''`;
  - `''less''`。

- `continuity_correction` — 如果不为0，那么将对p值进行正态近似的连续性修正。(可选，默认：1。) UInt64。

**返回值**

元组，有两个元素:

- 计算出U统计量。Float64。
- 计算出的p值。Float64。

**示例**

输入表:

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

查询:

```
SELECT mannWhitneyUTest(''greater'')(sample_data, sample_index) FROM mww_ttest;
```

结果:

```
┌─mannWhitneyUTest(''greater'')(sample_data, sample_index)─┐
│ (9,0.04042779918503192)                                │
└────────────────────────────────────────────────────────┘
```

**参见**

- Mann–Whitney U test
- Stochastic ordering
', 0, 1, '2021-09-24 10:26:37', 1, '2021-09-24 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(137, '#### median

`median*` 函数是 `quantile*` 函数的别名。它们计算数字数据样本的中位数。

函数:

- `median` — quantile别名。
- `medianDeterministic` — quantileDeterministic别名。
- `medianExact` — quantileExact别名。
- `medianExactWeighted` — quantileExactWeighted别名。
- `medianTiming` — quantileTiming别名。
- `medianTimingWeighted` — quantileTimingWeighted别名。
- `medianTDigest` — quantileTDigest别名。
- `medianTDigestWeighted` — quantileTDigestWeighted别名。

**示例**

输入表:

```
┌─val─┐
│   1 │
│   1 │
│   2 │
│   3 │
└─────┘
```

查询:

```
SELECT medianDeterministic(val, 1) FROM t
```

结果:

```
┌─medianDeterministic(val, 1)─┐
│                         1.5 │
└─────────────────────────────┘
```
', 0, 1, '2021-09-25 10:26:37', 1, '2021-09-25 10:26:37');
INSERT INTO biz_data_query_model_help_content(id, content, is_deleted, modified_user_id, modified_time, creation_user_id, creation_time) VALUES(138, '#### rankCorr

计算等级相关系数。

**语法**

```
rankCorr(x, y)
```

**参数**

- `x` — 任意值。Float32 或 Float64。
- `y` — 任意值。Float32 或 Float64。

**返回值**

- Returns a rank correlation coefficient of the ranks of x and y. The value of the correlation coefficient ranges from -1 to +1. If less than two arguments are passed, the function will return an exception. The value close to +1 denotes a high linear relationship, and with an increase of one random variable, the second random variable also increases. The value close to -1 denotes a high linear relationship, and with an increase of one random variable, the second random variable decreases. The value close or equal to 0 denotes no relationship between the two random variables.

类型: Float64。

**示例**

查询:

```
SELECT rankCorr(number, number) FROM numbers(100);
```

结果:

```
┌─rankCorr(number, number)─┐
│                        1 │
└──────────────────────────┘
```

查询:

```
SELECT roundBankers(rankCorr(exp(number), sin(number)), 3) FROM numbers(100);
```

结果:

```
┌─roundBankers(rankCorr(exp(number), sin(number)), 3)─┐
│                                              -0.037 │
└─────────────────────────────────────────────────────┘
```

**参见**

- 斯皮尔曼等级相关系数Spearman''s rank correlation coefficient
', 0, 1, '2021-09-26 10:26:37', 1, '2021-09-26 10:26:37');
