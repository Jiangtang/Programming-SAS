/*
http://support.sas.com/resources/papers/proceedings15/2123-2015.pdf
http://www.jiangtanghu.com/blog/2015/09/04/a-quick-look-at-sas-ds2-merge/
*/

data DEMOG;
input

PATIENT_ID AGE WEIGHT;
datalines;
1 42 185
2 55 170
3 30 160
;

data VITALS;
input
PATIENT_ID VISIT HEART_RATE;
datalines;
1 1 60
1 2 58
2 1 74
2 2 72
2 3 69
3 1 71
;

data alldata/debug;
merge demog vitals;
by patient_id;
weight = weight / 2.2;
run;

proc ds2; 
    data ds2; 
       method run(); 
         merge demog vitals;
        by patient_id;
/*weight = weight / 2.2;*/
       end; 
     enddata; 
    run; 
quit;
