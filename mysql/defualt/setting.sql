use tuning;

show tables;

select count(1) from 사원;

EXPLAIN select *
FROM 사원
where 사원번호 BETWEEN 10001 and 20000;

show variables like 'profiling%';
set profiling = 'ON';

show profiles;

show profile for query 1;

