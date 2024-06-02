--1. Support for the VECTOR data type
drop table if exists mytab_v;
create table mytab_v (v64 vector(3, float64));

describe mytab_v
variable myvar vector = '[1.1, 2.2, 3.0]'
insert into mytab_v values(:myvar);
select * from mytab_v;
--2. Support for the SQL BOOLEAN data type
drop table if exists mytab_b;
create table mytab_b (b boolean);
describe mytab_b
var b boolean = true
insert into mytab_b (b) values (:b);
select * from mytab_b;
--4. href:  https://medium.com/oracledevs/powering-on-with-sql-plus-for-oracle-database-23ai-69632f1d14ba