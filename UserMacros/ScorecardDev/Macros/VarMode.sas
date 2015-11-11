/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro VarMode */
/*******************************************************/
%macro VarMode(TransDS, IDVar, XVar, OutDS);
/* Calculation of the mode of a variable Xvar from a transaction 
   dataset using the classic implementation in ANSI SQL */
proc sql noprint;
	create table &OutDS as 
		SELECT &IDVar , MIN( &XVar ) AS mode
		FROM (
               SELECT &IDVar,  &XVar
               FROM &TransDS p1
               GROUP BY &IDVar, &XVar
               HAVING COUNT( * ) = 
                     (SELECT MAX( CNT )
                      FROM (SELECT COUNT( * ) AS CNT
                            FROM &TransDS p2
                            WHERE p2.&IDVar= p1.&IDVar
                            GROUP BY p2.&XVar
                            ) AS p3
                      )
              ) AS p
        GROUP BY p.&IDVar;
quit;
%mend;

