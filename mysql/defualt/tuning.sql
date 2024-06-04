# BEFORE
EXPLAIN
SELECT *
FROM 사원
WHERE SUBSTRING(사원번호, 1, 4) = 1100
  AND LENGTH(사원번호) = 5;

# AFTER 1
EXPLAIN
SELECT *
FROM 사원
WHERE LENGTH(사원번호) = 5
  AND SUBSTRING(사원번호, 1, 4) = 1100;

# AFTER 2
EXPLAIN
SELECT *
FROM (SELECT *
      FROM 사원
      WHERE LENGTH(사원번호) = 5) AS 사원
WHERE SUBSTRING(사원번호, 1, 4) = 1100;

# AFTER 3
EXPLAIN
SELECT *
FROM 사원
WHERE 사원번호 BETWEEN 11000 and 11009;


# BEFORE
show index from 사원;

EXPLAIN
SELECT 성별 AS 성별, COUNT(1) 건수
FROM 사원
GROUP BY 성별;


EXPLAIN
SELECT COUNT(1)
FROM 급여
WHERE 사용여부 = '1';

show index from 급여;


# BEFORE
show index from 사원;

EXPLAIN
SELECT *
FROM 사원
WHERE CONCAT(성별, ' ', 성) = 'M Radwan';

# AFTER
EXPLAIN
SELECT *
FROM 사원
WHERE 성별 = 'M'
  AND 성 = 'Radwan';

# AFTER
EXPLAIN
SELECT DISTINCT 사원.사원번호, 사원.이름, 사원.성, 부서관리자.부서번호
FROM 사원
         JOIN 부서관리자
              ON (사원.사원번호 = 부서관리자.사원번호)

# BEFORE
EXPLAIN
SELECT 'M' AS 성별, 사원번호
FROM 사원
WHERE 성별 = 'M'
  AND 성 = 'Baba'
UNION ALL
SELECT 'F', 사원번호
FROM 사원
WHERE 성별 = ' F'
  AND 성 = 'Baba';

# AFTER
show index from 사원;
describe 사원;
EXPLAIN
SELECT 성, 성별, COUNT(1) as 카운트
FROM 사원
GROUP BY 성별, 성;


EXPLAIN
SELECT 사원번호
FROM 사원
WHERE year(입사일자) = 1989
  AND 사원번호 > 100000;


show index from 사원출입기록;
EXPLAIN
SELECT *
FROM 사원출입기록 IGNORE INDEX (I_출입문)
WHERE 출입문 = 'B';

# BEFORE
EXPLAIN
SELECT 이름, 성
FROM 사원
WHERE 입사일자 BETWEEN
          STR_TO_DATE('1994-01-01', '%Y-%m-%d') AND
          STR_TO_DATE('2000-12-31', '%Y-%m-%d');

EXPLAIN
SELECT 이름, 성
FROM 사원
WHERE YEAR(입사일자) BETWEEN
          '1994' AND
          '2000';

EXPLAIN
SELECT 매핑.사원번호, 부서.부서번호
FROM 부서사원_매핑 매핑,
     부서
WHERE 매핑.부서번호 = 부서.부서번호
  AND 매핑.시작일자 >= '2002-03-01';

EXPLAIN
SELECT 이름, 성
FROM 사원
WHERE YEAR(입사일자) BETWEEN
          '1994' AND
          '2000';

EXPLAIN
SELECT 매핑.사원번호, 부서.부서번호
FROM 부서사원_매핑 매핑,
     부서
WHERE 매핑.부서번호 = 부서.부서번호
  AND 매핑.시작일자 >= '2002-03-01';

EXPLAIN
SELECT STRAIGHT_JOIN 매핑.사원번호, 부서.부서번호
FROM 부서사원_매핑 매핑,
     부서
WHERE 매핑.부서번호 = 부서.부서번호
  AND 매핑.시작일자 >= '2002-03-01';


# BEFORE
EXPLAIN
SELECT 사원.사원번호, 사원.이름, 사원.성
FROM 사원
WHERE 사원번호 > 450000
  AND (SELECT MAX(연봉)
       FROM 급여
       WHERE 사원번호 = 사원.사원번호) > 100000;

EXPLAIN
SELECT 사원.사원번호, 사원.이름, 사원.성
FROM 사원,
     급여
WHERE 사원.사원번호 = 급여.사원번호
  AND 사원.사원번호 > 450000
  AND 급여.연봉 > 100000;

describe 사원;
describe 급여;
show index from 사원;
show index from 급여;

EXPLAIN
SELECT 사원.사원번호, 사원.이름, 사원.성
FROM 사원,
     급여
WHERE 사원.사원번호 > 450000
  AND 사원.사원번호 = 급여.사원번호
GROUP BY 사원.사원번호
HAVING MAX(급여.연봉) > 100000;

SELECT 사원.사원번호, 사원.이름, 사원.성
FROM 사원
         JOIN (SELECT 사원번호, MAX(연봉) AS 최대연봉
               FROM 급여
               GROUP BY 사원번호) AS 급여MAX ON 급여MAX.사원번호 = 사원.사원번호
WHERE 사원.사원번호 > 450000
  AND 급여MAX.최대연봉 > 100000;

# BEFORE
SELECT COUNT(DISTINCT 사원.사원번호) as 데이터건수
FROM 사원,
     (SELECT 사원번호
      FROM 사원출입기록 기록
      WHERE 출입문 = 'A') 기록
WHERE 사원.사원번호 = 기록.사원번호;

EXPLAIN
SELECT COUNT(DISTINCT 사원.사원번호) as 데이터건수
FROM 사원
         inner join 사원출입기록 on 사원.사원번호 = 사원출입기록.사원번호
WHERE 출입문 = 'A';

EXPLAIN
SELECT COUNT(DISTINCT 사원출입기록.사원번호) as 데이터건수
FROM 사원출입기록
WHERE 사원출입기록.출입문 = 'A';

# 1,SIMPLE,사원출입기록,,ref,I_출입문,I_출입문,4,const,315090,100,Using index
# 1,SIMPLE,사원,,eq_ref,PRIMARY,PRIMARY,4,tuning.사원출입기록.사원번호,1,100,Using index

EXPLAIN
SELECT COUNT(1) as 데이터건수
FROM 사원
WHERE EXISTS(SELECT 1
             FROM 사원출입기록 기록
             WHERE 출입문 = 'A'
               AND 기록.사원번호 = 사원.사원번호)


# BEFORE
SELECT 사원.사원번호,
       급여.평균연봉,
       급여.최고연봉,
       급여.최저연봉
FROM 사원,
     (SELECT 사원번호,
             ROUND(AVG(연봉), 0) 평균연봉,
             ROUND(MAX(연봉), 0) 최고연봉,
             ROUND(MIN(연봉), 0) 최저연봉
      FROM 급여
      GROUP BY 사원번호) 급여
WHERE 사원.사원번호 = 급여.사원번호
  AND 사원.사원번호 BETWEEN 10001 AND 10100

EXPLAIN
SELECT 사원.사원번호,
       ROUND(AVG(연봉), 0) 평균연봉,
       ROUND(MAX(연봉), 0) 최고연봉,
       ROUND(MIN(연봉), 0) 최저연봉
FROM 사원
         INNER JOIN 급여 ON 사원.사원번호 = 급여.사원번호
WHERE 사원.사원번호 BETWEEN 10001 AND 10100
GROUP BY 사원번호;

SELECT 사원.사원번호, 사원.이름, 사원.성, 사원.입사일자
FROM 사원,
     급여
WHERE 사원.사원번호 = 급여.사원번호
  AND 사원.사원번호 BETWEEN 10001 AND 50000
GROUP BY 사원.사원번호
ORDER BY SUM(급여.연봉)
        DESC
LIMIT 150, 10