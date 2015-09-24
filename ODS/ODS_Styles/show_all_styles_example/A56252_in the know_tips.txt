/*--------------------------------------------------------------*/
/*        In the Know: SAS Tips and Techniques From Around      */
/*                   The Globe, Second Edition                  */
/*                        by Phil Mason                         */
/*       Copyright(c) 2007 by SAS Institute Inc., Cary, NC, USA */
/*                        ISBN 978-1-59047-702-1                */
/*                        ISBN-10 1-55544-870-4                 */
/*--------------------------------------------------------------*/
/*                                                              */
/* This material is provided "as is" by SAS Institute Inc. There*/
/* are no warranties, expressed or implied, as to merchant-     */
/* ability or fitness for a particular purpose regarding the    */ 
/* materials or code contained herein. The Institute is not     */ 
/* responsible for errors in this material as it now exists or  */ 
/* will exist, nor does Institute provide technical support     */  
/* for it.                                                      */
/*                                                              */
/*--------------------------------------------------------------*/
/* Questions or problem reports concerning this material may be */
/* addressed to the author:                                     */
/*                                                              */
/* SAS Institute Inc.                                           */
/* SAS Press                                                    */
/* Attn: Phil Mason                                             */
/* SAS Campus Drive                                             */
/* Cary, NC   27513                                             */
/*                                                              */
/*                                                              */
/* If you prefer, you can send email to:  saspress@sas.com      */
/* Use this for subject field:                                  */
/* Comments for Phil Mason                                      */
/*                                                              */
/*--------------------------------------------------------------*/
/* Last Updated:   15JAN07                                      */
/*--------------------------------------------------------------*/


***********************
*****RESOURCE TIPS*****
***********************

__________How to save space in SAS catalogs__________
Proc datasets library=sasuser ;
  repair profile / mt=cat ;
quit ;



__________Useful options for tuning__________
options oplist stats fullstats echoauto source source2 memrpt mprint stimer ;
Saving resources when the Log is long
dm 'log; clear;autoscroll 1' ;
data _null_ ;
  set sashelp.prdsale ;
  do i=1 to 50 ;
    put year= month= actual= ;
  end ;
run ;
dm 'log; clear;autoscroll 0' ;
data _null_ ;
  set sashelp.prdsale ;
  do i=1 to 50 ;
    put year= month= actual= ;
  end ;
run ;
568    dm 'log; clear;autoscroll 1' ;
569    data _null_ ;
570      set sashelp.prdsale ;
571      do i=1 to 50 ;
572        put year= month= actual= ;
573      end ;
574    run ;

      Lines deleted

NOTE: There were 1440 observations read from the data set SASHELP.PRDSALE.
NOTE: DATA statement used (Total process time):
      real time           7.81 seconds
      cpu time            7.39 seconds

575    dm 'log; clear;autoscroll 0' ;
576    data _null_ ;
577      set sashelp.prdsale ;
578      do i=1 to 50 ;
579        put year= month= actual= ;
580      end ;
581    run ;

Lines deleted

NOTE: There were 1440 observations read from the data set SASHELP.PRDSALE.
NOTE: DATA statement used (Total process time):
      real time           0.29 seconds
      cpu time            0.29 seconds



__________Several ways to tune a SORT__________
Proc sort data=x threads ; 
  By y ;
Run ;
Proc sort data=x tagsort ;
  By y ;
Run ;
proc sort data=data-set NOEQUALS ;
  by y ;
run ;
Options sortwkno=6 ;
proc sort data=xxx(where=(price>1000)) out=yyy ;
  by y ;
run;
options sortsize=max ;
proc print data=calendar ;
  by month NOTSORTED ;
run;
Data new(SORTEDBY=year month) ; 
   Set x.y ; 
run ;





*******************
*****FUNCTIONS*****
*******************

__________Incrementing and truncating by time intervals__________
480  data _null_ ;
481    format date date7. datetime datetime16. time time8. ;
482    date=intnx('month','8sep07'd,0) ;
483    datetime=intnx('dtday','8sep07:12:34:56'dt,0) ;
484    time=intnx('hour','12:34't,0) ;
485    put date= / datetime= / time= ;
486  run ;

date=01SEP07
datetime=08SEP07:00:00:00
time=12:00:00
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds
/* SASDAY is a SAS variable containing a SAS date */ 
/* LASTDAY is the last day of the month of SASDAY */ 
LASTDAY = INTNX("MONTH",SASDAY,1) - 1;
data test ;
  first=intnx('month',date(),-2,'beginning') ;
  same=intnx('year','19nov2006'd,20,'sameday') ;
run ; 



__________Counting words__________
15   data _null_ ;
16     sentence='This is ONE way of using one in One sentence' ;
17     num=count(sentence,'one','i') ;
18     put num= ;
19   run ;

num=3
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds



__________Using PERL regular expressions for searching text__________
data _null_;
      retain patternID; 
  if _N_=1 then 
    do;
      pattern = "/ave|avenue|dr|drive|rd|road/i";
      patternID = prxparse(pattern);
    end;
  input street $80.;
  call prxsubstr(patternID, street, position, length);
  if position ^= 0 then
    do;
      match = substr(street, position, length);
      put match : $QUOTE. "found in " street : $QUOTE.;
    end;
  datalines;
153 First Street
6789 64th Ave
4 Moritz Road
7493 Wilkes Place
;
run ;
"Ave" found in "6789 64th Ave"
"Road" found in "4 Moritz Road"



__________Concatenating strings the easy way__________
1    data test ;
2      a='  Phil         ' ;
3      b='   Mason ' ;
4      c=trim(left(a))!!' '!!left(b) ;
5      d=catx(' ',a,b) ;
6      put c= d= ;
7    run ;

c=Phil Mason d=Phil Mason
NOTE: The data set WORK.TEST has 1 observations and 4 variables.
NOTE: DATA statement used (Total process time):
      real time           0.55 seconds
      cpu time            0.06 seconds



__________Putting numbers in macro variables a better way__________
Call symput('name',left(trim(my_name))) ;
Call symputx('name',my_name) ;
SAS Log
5    data test ;
6      my_val=12345 ;
7      call symput('value0',my_val) ; * auto conversion done ;
8      call symput('value1',trim(left(put(my_val,8.)))) ; * v8 ;
9      call symputx('value2',my_val) ; * SAS 9 ;
10   run ;

NOTE: Numeric values have been converted to character values at the places given by:
      (Line):(Column).
      7:24
NOTE: The data set WORK.TEST has 1 observations and 1 variables.
NOTE: DATA statement used (Total process time):
      real time           0.17 seconds
      cpu time            0.02 seconds


11   %put value0 (using symput with auto conversion) is &value0;
value0 (using symput with auto conversion) is        12345
12   %put value1 (using symput with explicit conversion) is &value1;
value1 (using symput with explicit conversion) is 12345
13   %put value2 (using symputx) is &value2;
value2 (using symputx) is 12345



__________Writing messages to the LOG, while writing text elsewhere__________
55   data test ;
56     put 'This goes to LOG by default' ;
57     file print ;
58     put 'This goes to OUTPUT window, since I selected print' ;
59     putlog 'but this still goes to the LOG' ;
60     put 'This goes to OUTPUT' ;
61     putlog 'NOTE: and I can write proper messages using colours' ;
62     putlog 'WARNING: ...' ;
63     putlog 'ERROR: ...' ;
64   run ;

This goes to LOG by default
but this still goes to the LOG
NOTE: and I can write proper messages using colours
WARNING: ...
ERROR: ...
NOTE: 2 lines were written to file PRINT.
NOTE: The data set WORK.TEST has 1 observations and 0 variables.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.01 seconds



__________Logic & Functions__________
data getweek;
   datevar=today();
   week=intck('week',intnx('year',datevar,0),datevar)+1;
run;
data one;
   bday='19jan1973'd;  
   current=today();
   age=int(intck('month',bday,current)/12);
   if month(bday)=month(current) then
     age=age-(day(bday)>day(current));
run;
pi=arcos(-1);
pi=constant('pi');
sixfact=gamma(7);
sixfact=fact(6);
	arcosh_x=log(x+sqrt(x**2-1));
	arsinh_x=log(x+sqrt(x**2+1));
	artanh_x=0.5*log((1+x)/(1-x));



__________Are your random numbers really random?__________
data case;
  retain Seed_1 Seed_2 Seed_3 1 ;
  do i=1 to 10;
    call ranuni(Seed_1,X1) ; * call with unchanging seed ;
    call ranuni(Seed_2,X2) ; * call with seed changing half way through ;
    X3=ranuni(Seed_3) ;      * function with seed changing half way through ;
    output;
   * change seed for last 5 rows ;
    if i=5 then
      do;
        Seed_2=2;
        Seed_3=2;
      end;
  end;
run;

proc print;
  id i;
  var Seed_1-Seed_3 X1-X3;
run;
I      SEED_1        SEED_2      SEED_3       X1         X2         X3

 1     397204094     397204094       1      0.18496    0.18496    0.18496
 2    2083249653    2083249653       1      0.97009    0.97009    0.97009
 3     858616159     858616159       1      0.39982    0.39982    0.39982
 4     557054349     557054349       1      0.25940    0.25940    0.25940
 5    1979126465    1979126465       1      0.92160    0.92160    0.92160
 6    2081507258     794408188       2      0.96928    0.36993    0.96928
 7    1166038895    2019015659       2      0.54298    0.94018    0.54298
 8    1141799280    1717232318       2      0.53169    0.79965    0.53169
 9     106931857    1114108698       2      0.04979    0.51880    0.04979
10     142950581    1810769283       2      0.06657    0.84321    0.06657
66   data _null_ ;
67     do i=1 to 3 ;
68       a=ranuni(123) ;
69       put a= ;
70     end ;
71   run ;

a=0.7503960881
a=0.3209120251
a=0.178389649
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.01 seconds



__________Using index to treat blanks as nulls__________
1    data _null_;
2       result1 = indexw(' ',' ');
3       put result1 =;
4       result2 = indexw(' ', '');
5       put result2 =;
6       result3 = indexw('',' ');
7       put result3 =;
8       result4 = indexw('Any Chars',' ');
9       put result4 =;
10   run;

result1=1
result2=1
result3=1
result4=0
NOTE: DATA statement used (Total process time):
      real time           0.14 seconds
      cpu time            0.04 seconds



__________Determining if you have SAS products__________
  x=sysprod('graph') ;
  if sysprod('GRAPH') and cexist('SASHELP.DEVICES') then ...



__________Peculiarities of the LENGTH function__________
1    data _null_ ;
2      blank=length(' ') ;
3      missing=length('') ;
4      normal=length('sas') ;
5      put blank= / missing= / normal= ;
6    run ;

blank=1
missing=1
normal=3
NOTE: DATA statement used (Total process time):
      real time           1.77 seconds
      cpu time            0.11 seconds
7    data _null_ ;
8      blank=length(trim(' ')) ;
9      missing=length(trim('')) ;
10     normal=length(trim('sas')) ;
11     put blank= / missing= / normal= ;
12   run ;

blank=1
missing=1
normal=3
NOTE: DATA statement used (Total process time):
      real time           0.10 seconds
      cpu time            0.03 seconds 
13   data _null_ ;
14     length a 4 ;
15     length b 6 ;
16     length c 8 ;
17     a=-123.3;
18     b=9999999999;
19     len_a=length(a) ;
20     len_b=length(b) ;
21     len_c=length(c) ;
22     put len_a= / len_b= / len_c= ;
23   run ;

NOTE: Numeric values have been converted to character values at the places given by:
      (Line):(Column).
      19:16   20:16   21:16
NOTE: Variable c is uninitialized.
len_a=12
len_b=12
len_c=12
NOTE: DATA statement used (Total process time):
      real time           0.15 seconds
      cpu time            0.05 seconds 



__________Minimum/Maximum arithmetic operators__________
             -3 >< -3
- (3 >< -3)
24   data _null_ ;
25     x=-3><-3 ;
26     put x= ;
27   run ;

x=3
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.02 seconds
if x>y then
  z=x ;
else
  z=y ;
z=x<>y ;
28   proc print data=sashelp.class ;
29     where sex<>'Alaska' ;
NOTE: The "<>" operator is interpreted as "not equals".
30   run ;

NOTE: There were 19 observations read from the data set SASHELP.CLASS.
      WHERE 1 /* an obviously TRUE where clause */ ;
NOTE: PROCEDURE PRINT used (Total process time):
      real time           1.76 seconds
      cpu time            0.20 seconds
For example
 z = MIN(x,y,z);



__________Getting the remainder of a division__________
31   data _null_ ;
32     x=mod(-3, 2) ;
33     put 'mod(-3, 2)=' x ;
34     x=mod(-3,-2) ;
35     put 'mod(-3,-2)=' x ;
36     x=mod( 3, 2) ;
37     put 'mod( 3, 2)=' x ;
38     x=mod( 3,-2) ;
39     put 'mod( 3,-2)=' x ;
40   run ;

mod(-3, 2)=-1
mod(-3,-2)=-1
mod( 3, 2)=1
mod( 3,-2)=1
NOTE: DATA statement used (Total process time):
      real time           0.16 seconds
      cpu time            0.05 seconds
                             integer quotient=
  arg-1        arg-2           int(arg1/arg2)       remainder

   -3            2                 -1                   -1
   -3           -2                  1                   -1
    3            2                  1                    1
    3           -2                 -1                    1




*******************
*****DATA STEP*****
*******************

__________How to rearrange variables in a data set__________
data new ;
  retain this that theother ;
  set old ;
run ;



__________Using Pattern Matching in WHERE clauses__________
where name=:'Ph' ;
where name like 'P_il M_s_n' ;
where name like '%son' ;
where name contains 'il' ;
where name ? 'hil' ;
where name=*'PFil Mason' ;
where name>:'Phil' ;
where name le: 'Phim' ;



__________Conditionally generating code with CALL EXECUTE__________
60   data one;
61      x=1;
62      y='A';
63      output;
64      x=2;
65      y='B';
66      output;
67   run;

NOTE: The data set WORK.ONE has 2 observations and 2 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.02 seconds


68
69   data _null_;
70      set one end=last;
71     if _n_=1 then
72       call execute('proc format; value myfmt');
73      call execute( x);
74      call execute('=');
75      call execute(quote(y));
76      if last then
77       call execute(";run;");
78   run ;

NOTE: Numeric values have been converted to character values at the places given by:
      (Line):(Column).
      73:18
NOTE: There were 2 observations read from the data set WORK.ONE.
NOTE: DATA statement used (Total process time):
      real time           0.03 seconds
      cpu time            0.04 seconds


NOTE: CALL EXECUTE generated line.
1   + proc format;
1   +              value myfmt
2   +            1
3   + =
4   + "A"
5   +            2
6   + =
7   + "B"
8   + ;
NOTE: Format MYFMT is already on the library.
NOTE: Format MYFMT has been output.
8   +  run;

NOTE: PROCEDURE FORMAT used (Total process time):
      real time           0.02 seconds
      cpu time            0.03 seconds

79   %macro x;
80     %put Line 1 ;
81     %put Line 2 ;
82   %mend x;
83
84   %macro y;
85     %put Line 3 ;
86     %put Line 4 ;
87   %mend y;
88   data _null_ ;
89     call execute('%x %y %x %y');
90   run;

Line 1
Line 2
Line 3
Line 4
Line 1
Line 2
Line 3
Line 4
NOTE: DATA statement used (Total process time):
      real time           0.04 seconds
      cpu time            0.03 seconds


NOTE: CALL EXECUTE routine executed successfully, but no SAS statements were generated.                        


__________DDE: writing to Microsoft Word__________
filename name dde 'WinWord|doc1.doc!name' notab ; *** First bookmark ;
filename problem dde 'WinWord|doc1.doc!problem' notab ; *** Second bookmark ;

data _null_ ;
  file name ;
  put 'Rod Krishock' ;
  file problem ;
  put 'stay in a cheap hotel' ;
run ;

NOTE: The file NAME is:
      FILENAME=WinWord|doc1.doc!name,
      RECFM=V,LRECL=256

NOTE: The file PROBLEM is:
      FILENAME=WinWord|doc1.doc!problem,
      RECFM=V,LRECL=256

NOTE: 1 record was written to the file NAME.
      The minimum record length was 12.
      The maximum record length was 12.
NOTE: 1 record was written to the file PROBLEM.
      The minimum record length was 21.
      The maximum record length was 21.
NOTE: The DATA statement used 0.93 seconds.



__________DDE: operating other programs from SAS__________
filename lotus dde '123w|system' notab ;   *** Program name is 123w.exe ;
data _null_ ;
  file lotus ;
  put '[run({CHART-NEW A:A1..A:F14})]' ; *** Create a new chart ;
  put '[run({SELECT "CHART 1";;"CHART"})]' ; *** Select it ;
  put '[run({CHART-RANGE "X";A:A1..A:A4;"Line";"NO"})]' ; *** Set the X range ;
  put '[run({CHART-RANGE "A";A:B1..A:B4;"Bar";"NO"}dd)]' ; * Set the Y range and
                                                             plot a bar chart ;
run ;

NOTE: The file LOTUS is:
      FILENAME=123w|system,
      RECFM=V,LRECL=256

NOTE: 4 records were written to the file LOTUS.
      The minimum record length was 30.
      The maximum record length was 48.
NOTE: The DATA statement used 1.37 seconds.
filename word dde 'winword|system' notab ; *** Program name is Winword.exe ;
data _null_ ;
  file word ;
  put '[FileOpen .Name = "phil1.DOC"]' ; *** Open a file called phil1.doc ;
  put '[macro1]' ; *** Execute a macro called macro1 ;
run ;

NOTE: The file WORD is:
      FILENAME=WinWord|system,
      RECFM=V,LRECL=256

NOTE: 1 record was written to the file WORD.
      The minimum record length was 30.
      The maximum record length was 30.
NOTE: The DATA statement used 3.62 seconds.



__________Adding variables with similar names__________
data _null_ ;
* Sample data ;
  iddusa=10 ;
  iddaus=33 ;
  iddtai=44 ;
  idduk=99 ;
  iddbel=1 ;
  iddcan=11 ;
* Define array to hold all the IDD variables ;
  array idd(*) idd: ;
* Add them up ;
  do i=1 to dim(idd) ;  
    total+idd(i) ;
  end ;
* Calculate average ;
  avg=total/dim(idd) ;
  put _all_ ;
run ;
IDDUSA=10 IDDAUS=33 IDDTAI=44 IDDUK=99 IDDBEL=1 IDDCAN=11 TOTAL=198 I=7 
AVG=33 _ERROR_=0 _N_=1                                                  



__________INPUTing data using text value positioning__________
  data logstats ;
    infile saslog ;
    input @'used' duration 6.2 ;
  run ;

  proc print data=logstats ;
  run;
OBS    DURATION 
                
 1        0.05  
 2        2.72  
 3        6.74  
 4       69.09  
 5        2.74  
 6        3.03  
 7       13.10  
 8       12.29  
 9      109.70  



__________Reading unaligned data that require informats__________
                                                    The SAS System                      13:27 Thursday, May 4, 2006   3

                  Obs       name       title                                        address

                   1     Phil Mason    "SAS Tips guy"                       Melbourne - Australia
                   2     Mark Bodt     "Expert in SAS, Microsoft & more"    Wellington - New Zealand


__________Use _NULL_ DATA steps when not creating data sets__________
    data ;                                                       
      x=1 ;                                                      
    run ;                                                        
                                                                  
NOTE: The data set WORK.DATA1 has 1 observations and 1 variables. 
NOTE: The DATA statement used 0.01 CPU seconds and 1426K.         

    data _null_ ;                                        
      x=1 ;                                              
    run ;                                                
                                                          
NOTE: The DATA statement used 0.01 CPU seconds and 1426K. 



__________Determining the number of observations in a dataset__________
52   DATA a_view / view=a_view ;
53     set sashelp.class ;
54   run ;

NOTE: DATA STEP view saved on file WORK.A_VIEW.
NOTE: A stored DATA STEP view cannot run under a different operating system
NOTE: DATA statement used (Total process time):
      real time           0.04 seconds
      cpu time            0.01 seconds


55
56   DATA _null_ ;
57     if 0 then
58       set a_view nobs=nobs ;
59     put "For a View: " nobs= ;
60     stop ;
61   Run ;

For a View: nobs=9.0071993E15
NOTE: View WORK.A_VIEW.VIEW used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds

NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds


62
63   DATA temp ;
64     if 0 then
65       set sashelp.class nobs=nobs ;
66     put "For a Disk dataset: " nobs= ;
67     stop ;
68   Run ;

For a Disk dataset: nobs=19
NOTE: The data set WORK.TEMP has 0 observations and 5 variables.
NOTE: DATA statement used (Total process time):
      real time           0.04 seconds
      cpu time            0.00 seconds


103  data temp ;
104    if 0 then
105      set sashelp.prdsale(firstobs=20 obs=25) nobs=nobs ;
106    put "with firstobs & obs: " nobs= ;
107    stop ;
108  run ;

with firstobs & obs: nobs=1440
NOTE: The data set WORK.TEMP has 0 observations and 10 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.02 seconds


109  data temp ;
110    if 0 then
111      set sashelp.prdsale nobs=nobs ;
112    put "without firstobs & obs: " nobs= ;
113    stop ;
114  run ;

without firstobs & obs: nobs=1440
NOTE: The data set WORK.TEMP has 0 observations and 10 variables.
NOTE: DATA statement used (Total process time):
      real time           0.03 seconds
      cpu time            0.04 seconds
LIBNAME v9305 V606SEQ ;                               

NOTE: Libref V9305 was successfully assigned as follows:         
      Engine:        V606SEQ                                     
      Physical Name: IVXXX.REQ3339.CARTVX2.SAS9305               

DATA temp ;                                           
  if 0 then                                           
    set v9305.ServBill nobs=nobs ;                    
  put nobs= ;                                         
  stop ;                                              
Run ;                                                 
                                                                 
NOBS=2147483647                                                  
NOTE: The data set WORK.TEMP has 0 observations and 3 variables. 
NOTE: The DATA statement used 0.03 CPU seconds.                  
* code to test if a dataset has any obs. ;
data _null_ ;           
  if 0 then set work.ytd nobs=count ;
  call symput('numobs',left(put(count,8.))) ; 
  stop ;                        
run;

%macro reports ;
%if &numobs =0     
%then %do ;
data _null_ ;
  file ft20f001 ;  
  %title ;
  put ////
    @10 "NO records were selected using the statement " // 
    @15 "&where" // 
    @10 "for any month from &start to &end" // 
    @10 'THIS RUN HAS COMPLETED SUCCESSFULLY.' ;
run ;
%end ; 
%else 
  %do ;
* generate graph of costs vs cycle;
proc chart data=work.ytd ;                                           
  by finyear ; vbar pcycle / type=sum sumvar=cost discrete; format pcycle $2. ; run;
  %end ;                                
%mend ;                         

%reports;



__________Creating views from a DATA step__________
	filename x 'IVCGI.REQ3300.CNTL(SQL)' ;                              
	data sasuser.readx / view=sasuser.readx ;                           
	infile x ;                                                        
	input line $80. ;                                                 
	if index(line,'//') ; * keep jcl lines ;                          
	acc=index(line,' JOB ')+5 ;                                       
	if acc>5 then                                                     
	account=scan(substr(line,acc),1,"'") ;                          
	run ;                                                               
                                                                         
NOTE: DATA STEP view saved on file SASUSER.READX.                        
NOTE: The original source statements cannot be retrieved from a stored   
DATA STEP view nor will a stored DATA STEP view run under a        different release of the SAS 
system or under a different operating system.                                                            
Please be sure to save the source statements for this DATA STEP    view.                                                              
NOTE: The DATA statement used 0.01 CPU seconds and 1985K.                
	proc print ;                                                        
	where account>'' ;                                                
	run ;                                                               
                                                                         
NOTE: The infile X is:                                                   
Dsname=XXXGI.REQ3300.CNTL(SQL),                                    
Unit=3380,Volume=D00106,Disp=SHR,Blksize=23440,                    
Lrecl=80,Recfm=FB                                                  
NOTE: 45 records were read from the infile X.                            
NOTE: The view SASUSER.READX.VIEW used 0.02 CPU seconds and 2066K.       
NOTE: The PROCEDURE PRINT used 0.01 CPU seconds and 2066K.               
OBS                             LINE                               
1	//XXMSPM00 JOB 'XXXGI002','A_3300 (PM9992306)',CLASS=V,     
                                                                   
OBS    ACC    ACCOUNT                                              
                                                                   
  1     16    XXXGI002                                             
data work.temp;
   set work.large;
   if variable >=0 then flag=1;
   else flag=0; 
run;
proc freq data=work.temp;
   table flag; 
run;
data work.temp / VIEW=WORK.TEMP;
  KEEP FLAG;
  set work.large;
  if variable >=0 then flag=1;
                  else flag=0;
run;

proc freq data=work.temp;
   table flag;
run;



__________How to put variable labels into titles__________
507  data _null_ ;
508     length agelabel $ 40 ;
509     set sasuser.fitness ;
510     call label(age,agelabel) ;
511     call symput("agemacro",agelabel) ;
512  stop ;
513  run ;

NOTE: There were 1 observations read from the data set SASUSER.FITNESS.
NOTE: DATA statement used (Total process time):
      real time           0.09 seconds
      cpu time            0.00 seconds


514  title "&agemacro" ;
515  proc print data=sasuser.fitness(obs=1) ;
516  run ;

NOTE: There were 1 observations read from the data set SASUSER.FITNESS.
NOTE: PROCEDURE PRINT used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds
                        Age in years                                        

 Obs    age    weight    runtime    rstpulse    runpulse    maxpulse    oxygen    group

   1     57     73.37     12.63        58          174         176      39.407      2
517  proc sql ;
518     SELECT label into: wmacro
519       FROM dictionary.columns
520         WHERE libname='SASUSER'
521             & memname='FITNESS'
522             & name='WEIGHT' ;
NOTE: No rows were selected.
522!                              * note: text is case-sensitive ;
523  quit ;
NOTE: PROCEDURE SQL used (Total process time):
      real time           0.14 seconds
      cpu time            0.04 seconds


WARNING: Apparent symbolic reference WMACRO not resolved.
524  title "&wmacro" ;
525  proc print data=sasuser.fitness(obs=1) ;
526  run ;

NOTE: There were 1 observations read from the data set SASUSER.FITNESS.
NOTE: PROCEDURE PRINT used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds
Weight in kg

Obs    age    weight    runtime    rstpulse    runpulse    maxpulse    oxygen    group

  1     57     73.37     12.63        58          174         176      39.407      2
proc sql ;  
   SELECT label INTO :gmacro                           
      FROM sashelp.vcolumn                              
      WHERE libname='SASUSER'                         
      & memname='FITNESS'                         
      & name='GROUP' ;                            
title "&gmacro" ;                                     
NOTE: The PROCEDURE SQL used 0.02 CPU seconds and 2722K.   
proc print data=sasuser.fitness(obs=1) ;              
run ;                                                 
NOTE: The PROCEDURE PRINT used 0.01 CPU seconds and 2722K. 
Experimental group
OBS  AGE  WEIGHT  RUNTIME  RSTPULSE  RUNPULSE  MAXPULSE  OXYGEN  GROUP   
1   57   73.37   12.63      58        174       176    39.407    2     



__________Simple ways to comment out code__________
proc contents data=sasuser._all_ ;                       
run cancel ;                                             
                                                              
NOTE: The procedure was not executed at the user's request.   
NOTE: The PROCEDURE CONTENTS used 0.00 CPU seconds and 1537K. 
   data ;                                                        
     put "This is a test on &sysday" ;                           
   run ;                                                         
                                                                   
This is a test on Friday                                           
NOTE: The data set WORK.DATA1 has 1 observations and 0 variables.  
NOTE: The DATA statement used 0.01 CPU seconds and 1435K.          
                                                                   
   data ;                                                        
     put "This is a test on &sysday" ;                           
   run cancel ;                                                  
                                                                   
NOTE: Data step not executed at user's request.                    
NOTE: The DATA statement used 0.00 CPU seconds and 1435K.          



__________Altering processing within a DO loop, based on a condition__________
   data temp ;
     set random ;
    *** Put all the variables starting with x into an array ;
     array scores(*) x: ;
    *** Loop through the variables looking for a score over 90% ;
     do i=1 to dim(scores) ;
       if scores(i)>.9 then
         leave ; *** If we find one then leave the loop ;
     end ;
     put scores(i)= ; *** Write out the score that we ended up with ;
   run ;

X2=0.9700887157
NOTE: The data set WORK.TEMP has 1 observations and 21 variables.
NOTE: The DATA statement used 0.02 CPU seconds and 1881K.
   data over100 ;
     set sasuser.crime(drop=state) ; * Dont need this variable ;
     array crimes(*) _numeric_ ;     * Put all the crime rates in an array ;
     do i=1 to dim(crimes) ;         * Loop through each of the crime variables ;
       if crimes(i)<100 then
         CONTINUE ;                  * If a rate is under 100 then
                                       proceed to next iteration ;
       put 'State: ' staten
           'has ' crimes(i)= ;       * These are >= 100 ;
     end ;
   run ;

State: Alabama has ASSAULT=278.3
State: Alabama has BURGLARY=1135.5
State: Alabama has LARCENY=1881.9
State: Alabama has AUTO=280.7
State: Alaska has ASSAULT=284
 etc. etc. etc.



__________Editing external files in place__________
data _null_ ;
  infile 'c:\very-long-recs.txt' 
         sharebuffers ;     /* Define input file */
  input ;                   /* Read a record into the input buffer */
  file out ;                /* Point to where you want to write output */
  put @33  'ABC'            /* write changes */
      @400 '12345'          /* write another change */
      @999 'Wow' ;          /* write the last change */ 
run ;
Data _null_ ;
  infile 'c:\very-long-recs.txt' ;
  input ;
  file 'c:\out.txt' ;
  put _infile_ ',this,that' ;  * Appends 2 fields to the end of a CSV file ;
run ;


Data _null_ ;
  infile 'c:\very-long-recs.txt' ;
  input ;
  file 'c:\out.txt' ;
  put first ',' second ',' _infile_ ; * Puts 2 fields at the start of a CSV file ;
run ;



__________DDE: make sure numbers are numeric__________
filename lotus dde '123w|test.wk4!a:a1..a:b3' notab ;

* Writing numeric values directly to spreadsheet via DDE ;
data _null_ ;
  retain tab '09'x ; ** Define a tab character ;
  file lotus ; ** Directs output to spreadsheet via DDE link ;
 * In Lotus: 1 is numeric, but 2 is character due to implicit space after variable TAB ;
 *           3 & 4 are numeric, since implicit space is overwritten ;
 *           5 & 6 are numeric since there is no implicit space, due to constant being used ;
  put '1'     tab
      '2'     /
      '3'     tab +(-1)
      '4'     /
      '5'     '09'x
      '6'     ;
run ;

NOTE: The file LOTUS is:
      FILENAME=123w|test.wk4!a:a1..a:b3,
      RECFM=V,LRECL=256

NOTE: 3 records were written to the file LOTUS.
      The minimum record length was 3.
      The maximum record length was 4.
NOTE: The DATA statement used 0.66 seconds.



__________Data of views can't change__________
data v_house / view=v_house ;
  set sasuser.houses ;
run ;

NOTE: DATA STEP view saved on file WORK.V_HOUSE.
NOTE: The original source statements cannot be retrieved from a stored DATA STEP view nor
      will a stored DATA STEP view run under a different release of the SAS system or under
      a different operating system.
      Please be sure to save the source statements for this DATA STEP view.
NOTE: The DATA statement used 0.44 seconds.


proc print data=v_house(obs=1) ;
run;

NOTE: The view WORK.V_HOUSE.VIEW used 0.39 seconds.

NOTE: The PROCEDURE PRINT used 0.44 seconds.


data sasuser.houses ;
  set sasuser.houses ;
  obs=_n_ ;
run ;

NOTE: The data set SASUSER.HOUSES has 15 observations and 7 variables.
NOTE: The DATA statement used 0.66 seconds.


NOTE: The view WORK.V_HOUSE.VIEW used 0.22 seconds.

proc print data=v_house(obs=1) ;
ERROR: The variable OBS from data set SASUSER.HOUSES is not defined in the INPUT view
       WORK.V_HOUSE.
ERROR: Failure loading view WORK.V_HOUSE.VIEW with request 4.



__________Views don't use indexes__________
options msglevel=i ; *** Tell me when SAS uses an index ;

proc datasets library=mis ;
  modify item ;
  index create _type_ ;
NOTE: Single index _TYPE_ defined.
run;

NOTE: The PROCEDURE DATASETS used 3.02 seconds.

*** This shows that the index is being used when using the dataset directly ;
proc print data=mis.item ;
  where _type_=0 ;
INFO: Index _TYPE_ selected for WHERE clause optimization.
run;

NOTE: The PROCEDURE PRINT used 0.22 seconds.

*** Make a DATA step view ;
data v_item / view=v_item ;
  set mis.item ;
  year=substr(servmth,1,2) ;
run ;

NOTE: DATA STEP view saved on file WORK.V_ITEM.
NOTE: The original source statements cannot be retrieved from a stored DATA STEP view nor
      will a stored DATA STEP view run under a different release of the SAS system or under
      a different operating system.
      Please be sure to save the source statements for this DATA STEP view.
NOTE: The DATA statement used 0.55 seconds.

*** Use the DATA step view, and notice that the index is not used ;
proc print data=v_item ;
  where _type_=0 ;
run;

NOTE: The view WORK.V_ITEM.VIEW used 1.41 seconds.

NOTE: The PROCEDURE PRINT used 1.59 seconds.

===> Example 2: SQL view

proc sql ;
  create view v_item as
  select *,
        substr(servmth,1,2) as year
  from mis.item ;
NOTE: SQL view WORK.V_ITEM has been defined.
quit ;
NOTE: The PROCEDURE SQL used 0.39 seconds.


proc print data=v_item ;
  where _type_=0 ;
run;

NOTE: The PROCEDURE PRINT used 3.62 seconds.



__________Bringing environment variables into macro variables__________
    %let comspec=%sysget(comspec);
    %let temp=%sysget(temp);
    %let name=%sysget(name);
    %put comspec=&comspec ;
comspec=C:\COMMAND.COM
    %put temp=&temp ;
temp=C:\TEMP
    %put name=&name ;
name=Philip Mason



__________Using stored compiled programs__________
  data test / pgm=sasuser.prog1 ;                                     
    set sasuser.class ;                                               
    if age<10 then                                                    
     child='YES' ;                                                    
  run ;                                                               
                                                                         
NOTE: DATA STEP program saved on file SASUSER.PROG1.                     
NOTE: The original source statements cannot be retrieved from a stored   
      DATA STEP program nor will a stored DATA STEP program run under a  
      different release of the SAS system or under a different operating 
      system.                                                            
      Please be sure to save the source statements for this stored       
      program.                                                           
NOTE: The DATA statement used 0.01 CPU seconds and 1600K.                
  data pgm=sasuser.prog1 ;                                    
  run ;                                                       
                                                                 
NOTE: DATA STEP program loaded from file SASUSER.PROG1.          
NOTE: The data set WORK.TEST has 19 observations and 6 variables.
NOTE: The DATA statement used 0.01 CPU seconds and 1694K.     

proc print data=test ;
run ;   
data test ;
  set sashelp.class ;
  value=SYMGET('macrovar') ; * Specify macro name without a leading & or % ;
run ;



__________Logic variations using IF & WHERE__________
data x ;                                                    
  zero='0' ;                                                
run ;                                                       
                                                                 
NOTE: The data set WORK.X has 1 observations and 1 variables.    
NOTE: The DATA statement used 0.01 CPU seconds and 1383K.        
data If ;                                                     
  set x ;                                                     
  if zero ;                                                   
run ;                                                         
                                                                    
NOTE: Character values have been converted to numeric              
values at the places given by: (Line):(Column).              
42:6                                                         
NOTE: The data set WORK.IF has 0 observations and 1 variables.     
NOTE: The DATA statement used 0.01 CPU seconds and 1383K.          
data Where ;                                                  
  set x ;                                                     
    where zero ;                                                
run ;                                                         
                                                                    
NOTE: The data set WORK.WHERE has 1 observations and 1 variables.  
NOTE: The DATA statement used 0.01 CPU seconds and 1399K.



__________DDE: using more advanced commands__________
** Define the sysitems topic to find which commands are supported
   by the application for DDE ;
filename lotus dde '123w|system!sysitems' notab ;

data _null_ ;
  length cmd $ 40 ; * Otherwise first command read in sets maximum length ;
  infile lotus pad dsd dlm='09'x ; * One tab delimited record is returned ;
  input cmd $ @@ ;
  put cmd ;
run ;

NOTE: The infile LOTUS is:
      FILENAME=123w|system!sysitems,
      RECFM=V,LRECL=256

SysItems
Topics
Formats
RangeNames
Selection
Status
NOTE: 1 record was read from the infile LOTUS.
      The minimum record length was 51.
      The maximum record length was 51.
NOTE: SAS went to a new line when INPUT statement reached past the end of a line.
NOTE: The DATA statement used 0.82 seconds.
** Define the sysitems topic to find which commands are supported
   by the application for DDE ;
filename word dde 'winword|system!sysitems' notab ;

data _null_ ;
  infile word pad dsd dlm='09'x ; * One tab separated record is returned ;
  input cmd $ @@ ;
  put cmd ;
run ;

NOTE: The infile WORD is:
      FILENAME=winword|system!sysitems,
      RECFM=V,LRECL=256

SYSITEMS
TOPICS
FORMATS
NOTE: 1 record was read from the infile WORD.
      The minimum record length was 23.
      The maximum record length was 23.
NOTE: SAS went to a new line when INPUT statement reached past the end of a line.
NOTE: The DATA statement used 0.81 seconds.



__________Generation Data Sets__________
* keep multiple copies of data sets ;
data x(genmax=5) ; 
   a=1 ;
run ;
* each time we create the dataset again it makes another generation ;
data x ;
  a=2 ;
run ;
data x ;
  a=3 ; 
run ;
data x ;
  a=4 ; 
run ;
* current generation is 0, or just dont specify the one you want ;
data y ; 
  set x(gennum=0) ; 
  put a= ; 
run ;
* generation 2 is the 2nd one created - actually called x#002 ;
data y ; 
  set x(gennum=2) ; 
  put a= ; 
run ;
* generation -1 is the previous one created, not the current one but the one before ;
data y ; 
  set x(gennum=-1) ; 
  put a= ; 
run ;



__________Automatic checking of the LOG__________
sub '%include "c:\demo\anal.sas";'
*** need to assign this macro call to a button on toolbar
    so that pressing the button will analyse the log ;
filename cat catalog 'work.test.test.log' ;
dm 'log;file cat' ; * write log to catalog member ;
ods listing close ;
ods html file='analyse.htm' ;
data analyse ;
  length line $200 ;
  label line='Line from LOG'
        _n_='Line number' ;
  infile cat end=end truncover ;
  file print ods=(vars=(_n_ line)) ;
  input line & ;
  if substr(line,1,5)='ERROR' then
    put _ods_ ;
  else
    if substr(line,1,7)='WARNING' then
      put _ods_ ;
	else
	  n+1 ;
  if end & n=_n_ then
    do ;
	  window status rows=15 columns=40 color=gray
               #5 'No errors or warnings were found.' color=yellow
               #9 'Press enter to continue' ;
	  display status ;
	end ;
run ;
ods html close ;
filename cat ; * free catalog member ;
dm 'del work.test.test.log' ; * delete it ;
ods listing ;



__________Using datasets without libnames__________
15   * Create a version 6 dataset ;
16   data 'c:\test.sd2' ; 
     run ;

NOTE: c:\test.sd2 is a Version 6 data set.  In future releases of SAS you may not be able to
create or update Version 6 data sets. Use PROC COPY to convert the data set to Version 9.
NOTE: The data set c:\test.sd2 has 1 observations and 0 variables.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


17   * Create a version 8 dataset ; 
18   data 'c:\test.sas7bdat' ;
     run ;

NOTE: The data set c:\test.sd7 has 1 observations and 0 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


19   * Create a version 9 dataset ;
20   data 'c:\v9\test.sas7bdat' ; 
     run ;

NOTE: The data set c:\v9\test.sas7bdat has 1 observations and 0 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


21
22   * access a dataset directly ;
23   proc print data='c:\test.sas7bdat' ; 
     run ;

NOTE: No variables in data set c:\test.sas7bdat.
NOTE: PROCEDURE PRINT used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds



__________Using wildcards to read external files__________
filename in 'c:\tab*.dat' ;

data report ;
  infile in ;
  input a b c ;
run ;



__________Data Encryption for the beginner__________
data coded ;
 * set the value of the key ; 
  retain key 1234567 ;         
  input original ;
 * encode the original value using the key ; 
  coded=bxor(original,key); 
  put key= original= coded= ;  
  cards ;
1 
1234567 
999999 
34.4 
0 
run ;                      
 
data decode ;
 * the value of the key must be the same, 
   or else the number will not decode correctly ;
  retain key 1234567 ;     
  set coded ;              
 * decode the coded value using the key ;
  decoded=bxor(coded,key); 
  put coded= decoded= ; 
run ;                   
KEY=1234567 ORIGINAL=1       CODED=1234566                              
KEY=1234567 ORIGINAL=1234567 CODED=0                              
KEY=1234567 ORIGINAL=999999  CODED=1938616                         
KEY=1234567 ORIGINAL=34.4    CODED=1234597                           
KEY=1234567 ORIGINAL=0       CODED=1234567                              
NOTE: The data set WORK.CODED has 5 observations and 3 variables. 
NOTE: The DATA statement used 0.01 CPU seconds and 1451K.         
CODED=1234566 DECODED=1                                            
CODED=0       DECODED=1234567
CODED=1938616 DECODED=999999                                       
CODED=1234597 DECODED=34                                           
CODED=1234567 DECODED=0                                            
NOTE: The data set WORK.DECODE has 5 observations and 4 variables.  
NOTE: The DATA statement used 0.01 CPU seconds and 1471K.          



__________Cautions in dealing with missing values__________
data _null_ ;                                                
 * Initialise values ;
  a=. ;                                                      
  b=0 ;                                                      
  c=-7 ;                                                     
  d=99 ;                                                     
 * Try various forms of addition involving missing values ;
  add=a+b+c+d ;                                              
  put 'Addition of missing & non-missing values :  ' add= ;  
  sum=sum(a,b,c,d) ;                                         
  put 'Sum of missing & non-missing values :  ' sum= ;       
  summiss=sum(.,a) ;                                         
  put 'Sum of missing values only :  ' summiss= ;            
  sumzero=sum(0,.,a) ;                                       
  put 'Sum of 0 and missing values :  ' sumzero= ;           
 * See how the missing value compares to zero ;
  if a<0 then                                                
    put 'Missing is less than 0' ;                           
  else if a>0 then                                           
    put 'Missing is greater than 0' ;                        
run ;                                                        
Addition of missing & non-missing values :  ADD=.                   
Sum of missing & non-missing values :  SUM=92                       
Sum of missing values only :  SUMMISS=.                             
Sum of 0 and missing values :  SUMZERO=0                            
Missing is less than 0                                              

NOTE: Missing values were generated as a result of performing an    
operation on missing values.                                  
Each place is given by: (Number of times) at (Line):(Column). 
1 at 77:8    1 at 77:10   1 at 77:12   1 at 81:11             
NOTE: The DATA statement used 0.02 CPU seconds and 1420K.
data temp;
  missing Z;
  input a;
  b = a + 0;
datalines;
7
4
.Z
5
;
run;
proc print ;
run ;
OBS    A    B

 1     7    7
 2     4    4
 3     Z    .
 4     5    5
proc format ;
  value miss
    .z='Missing data' ;
run ;   



__________Writing to an external log ? not the SAS log__________
%macro log(action,who,what,where) ;
* Description - This method will record a record to a Log file ;
* action ... 1=write to GUI log
             2=write to data log
* return ... we return the return code from the (un)lock operation ;
  %if &action=1 %then
    %let file=system.gui_log ;
  %else
    %if &action=2 %then
      %let file=system.data_log ;
    %else
      %do ;
        %put WARNING: invalid action specified for LOG macro. ;
        %goto out ;
      %end ;
  data line ;
    who="&who" ;
    what="&what" ;
    where="&where" ;
    when=datetime() ;
  run ;
  proc append base=&file data=line force ;
  run ;
%out:
%mend log ;
/*%log(1,phil,test log macro,on ashe) ;*/



__________Adding a progress "bar" to a data step__________
%macro progress(every) ;
  window progress irow=4 rows=7 columns=40 
    #1 @6 'Processing record: ' _n_ persist=yes ;
  if mod(_n_,&every)=0 then
    display progress noinput ;
%mend progress ;
data x ;
  infile 'm:\datasets\x.txt' ;
  input name $30. phone $18. ;
  %progress(1000) ;
run ;
%macro progress2(every) ;
 * this macro relies on NOBS=NOBS & END=END being on input dataset ;
 * progress will change every%, e.g. progress2(10) changes every 10% ;
  pct=round(_n_/nobs*100) ;
  window progress irow=4 rows=7 columns=40 
    #1 @6 'Percent Complete: ' pct '%' persist=yes ;
  if mod(pct,&every)=0 then
    display progress noinput ;
%mend progress2 ;
*** use it ;
data test ;
  set xxx nobs=nobs ;
  %progress2(10) ; * update progress every 10% ;
run ;



__________Using bit flags__________
* maximum binary format can handle is 64 ;
data _null_ ;
  max=2**64; 
  put max= comma27. ;
  flag=max-1;
  put flag binary64. ' - ' flag comma27. ;
run ;
* test setting bits ;
data _null_ ;
  flag=0 ;
  bit=3 ; 
  link setflag ;
  bit=6 ; 
  link setflag ;
  bit=20 ;
  link setflag ;
  return ;
setflag:
  flag=bor(flag,2**(bit-1)) ; 
  put flag binary32. flag 12. ;
return ;
run ;



__________Take a sample of data__________
data _null_ ;                                                                                                                           
  infile 'M:\My big file.txt' firstobs=101 obs=200 ; 
  file 'm:\system\small.txt' ;
  input ;
run ; 



__________Using unusual variable names__________
options validvarname=any;
data test ;
  '#1 @ the "Top"'n='John' ;
  "Applied Statistician's"N=1 ;
run ;
proc print ; 
  id '#1 @ the "Top"'n ;
  var "Applied Statistician's"N ; 
run ;
Alphabetic List of Variables and Attributes

#    Variable                  Type    Len

1    #1 @ the "Top"            Char      4
2    Applied Statistician's    Num       8



__________Renaming variables__________
data x ;
  array a(10) $ 2 ;
run ;
* Renaming one at a time ;
proc print data=x(rename=(a1=b1 a2=b2 a3=b3 a4=b4 a5=b5
                          a6=b6 a7=b7 a8=b8 a9=b9 a10=b10)) ;
* Renaming a range of variables ;
proc print data=x(rename=(a1-a10=b1-b10)) ;
run ;

data y ;
  array x(50) $ 2 ;
  rename x1-x50=something_else1-something_else50 ;
run ;



__________IN operator now accepts integer ranges__________
73   data sample ;
74     set sashelp.class ;
75       if age in (11, 13:15, 18:25) ;
76   run ;

NOTE: There were 19 observations read from the data set SASHELP.CLASS.
NOTE: The data set WORK.SAMPLE has 13 observations and 5 variables.
NOTE: DATA statement used (Total process time):
      real time           0.03 seconds
      cpu time            0.02 seconds



__________Compiled data steps__________
data test / pgm=test ;
  format compile_time exec_time time8. ;
  compile_time=%sysfunc(time()) ; * gets the current time, when compiled ;
  exec_time=time() ; * gets the current time when run ;
  put compile_time= exec_time= ;
run ;
data pgm=test ; 
run ; * run a compiled data step ;
33	data pgm=test ; 
34	run ;

NOTE: DATA STEP program loaded from file WORK.TEST.
compile_time=13:21:34 exec_time=13:22:38
NOTE: The data set WORK.TEST has 1 observations and 2 variables.
NOTE: DATA statement used:
      real time           0.01 seconds
      cpu time            0.01 seconds
34   data pgm=test ;
35     describe ;
36   run ;

NOTE: DATA step stored program WORK.TEST is defined as:

data test / pgm=test ;
   format compile_time exec_time time8. ;
   compile_time=48093.5910000801 ;
   exec_time=time() ;
   put compile_time= exec_time= ;
run ;


NOTE: DATA statement used:
      real time           0.00 seconds
      cpu time            0.00 seconds


37   data pgm=test ;
38     execute ;
39   run ;

NOTE: DATA STEP program loaded from file WORK.TEST.
compile_time=13:21:34 exec_time=13:28:12
NOTE: The data set WORK.TEST has 1 observations and 2 variables.
NOTE: DATA statement used:
      real time           0.01 seconds
      cpu time            0.01 seconds



__________Run macro code from a data step__________
353  %let x=0 ;
354  data _null_ ;
355    call execute('%let x=1 ;') ;
356    x=resolve('&x') ;
357    put x= ;
358  run ;

NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds

x=1

NOTE: CALL EXECUTE routine executed successfully, but no SAS statements were generated.



__________Reading the next value of a variable__________
  data x;
    set sasuser.class;
    if sex ne lag(sex)  then y='ABC';
    if sex ne lag(sex) then z=lag(name);
run;
1    data name ;
2      set sashelp.class ; * read this record ;
3      set sashelp.class(firstobs=2
4                        keep=name
5                        rename=(name=next_name)) ; * just read one variable from the next 
record ;
6      put _n_ name= next_name= ;
7    run ;

1 Name=Alfred next_name=Alice
2 Name=Alice next_name=Barbara
3 Name=Barbara next_name=Carol
4 Name=Carol next_name=Henry
5 Name=Henry next_name=James
6 Name=James next_name=Jane
7 Name=Jane next_name=Janet
8 Name=Janet next_name=Jeffrey
9 Name=Jeffrey next_name=John
10 Name=John next_name=Joyce
11 Name=Joyce next_name=Judy
12 Name=Judy next_name=Louise
13 Name=Louise next_name=Mary
14 Name=Mary next_name=Philip
15 Name=Philip next_name=Robert
16 Name=Robert next_name=Ronald
17 Name=Ronald next_name=Thomas
18 Name=Thomas next_name=William
NOTE: There were 19 observations read from the data set SASHELP.CLASS.
NOTE: There were 18 observations read from the data set SASHELP.CLASS.
NOTE: The data set WORK.NAME has 18 observations and 6 variables.
NOTE: DATA statement used:
      real time           0.35 seconds
      cpu time            0.05 seconds



__________Flexible new date format__________
33   options datestyle=mdy;
34   data _null_;
35     date=input('01/02/03',anydtdte8.); * ambiguous date ;
36     put date=date9.;
37   run;

date=02JAN2003
NOTE: DATA statement used (Total process time):
      real time           0.51 seconds
      cpu time            0.00 seconds


38   options datestyle=ydm;
39   data _null_;
40     date=input('01/02/03',anydtdte8.); * ambiguous date ;
41     put date=date9.;
42   run;

date=02MAR2001
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


43   options datestyle=myd;
44   data _null_;
45     date=input('01/31/2003',anydtdte10.); * unambiguous date, so option ignored ;

46     put date=date9.;
47   run;

date=31JAN2003
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds



__________Sorting array elements__________
data test ;
  array v(50) 8 ;
  do i=1 to dim(v) ;
    v(i)=i+1 ;
  end ;
  call sortn(of v1-v50);
  put 'Up: ' v(1)= v(2)= v(3)= v(48)= v(49)= v(50)= ;
  call sortn(of v50-v1);
  put 'Down: ' v(1)= v(2)= v(3)= v(48)= v(49)= v(50)= ;
 * sort values between 3 character variables ;
 * note: character variables must be same length to avoid errors ;
	x='3 dogs ' ;
	y='1 cat  ' ;
	z='2 frogs' ;
	call sortc(x,y,z) ;
	put x= y= z= ;
run ;
86   data test ;
87     array v(50) 8 ;
88     do i=1 to dim(v) ;
89       v(i)=i+1 ;
90     end ;
91     call sortn(of v1-v50);
92     put 'Up: ' v(1)= v(2)= v(3)= v(48)= v(49)= v(50)= ;
93     call sortn(of v50-v1);
94     put 'Down: ' v(1)= v(2)= v(3)= v(48)= v(49)= v(50)= ;
95    * sort values between 3 character variables ;
96    * note: character variables must be same length to avoid errors ;
97     x='3 dogs ' ;
98     y='1 cat  ' ;
99     z='2 frogs' ;
100    call sortc(x,y,z) ;
101    put x= y= z= ;
102  run ;

NOTE: The SORTN function or routine is experimental in release 9.1.
Up: v1=2 v2=3 v3=4 v48=49 v49=50 v50=51
Down: v1=51 v2=50 v3=49 v48=4 v49=3 v50=2
NOTE: The SORTC function or routine is experimental in release 9.1.
x=1 cat y=2 frogs z=3 dogs
NOTE: The data set WORK.TEST has 1 observations and 54 variables.
NOTE: DATA statement used (Total process time):
      real time           0.05 seconds
      cpu time            0.06 seconds



__________Accessing the clipboard from SAS__________
dm 'notepad work.temp.temp.source;clear;paste;end';
filename c catalog 'work.temp.temp.source';
data _null_;
  infile c;
  input;
  put _infile_;
run;
filename c catalog 'work.temp.temp.source';
data _null_;
  file c;
  put 'hello';
run;
dm 'notepad work.temp.temp.source;curpos 1 1;mark;curpos max max;store;end';



__________Flexible date formats__________
205  data _null_ ;
206    now=today() ;
207    put 'Blanks ... ' now yymmddb10. ;
208    put 'Colon ... ' now yymmddc10. ;
209    put 'Dash ... ' now yymmddd10. ;
210    put 'No Separator ... ' now yymmddn8. ;
211    put 'Period ... ' now yymmddp10. ;
212    put 'Slash ... ' now yymmdds10. ;
213  run ;

Blanks ... 2005 03 22
Colon ... 2005:03:22
Dash ... 2005-03-22
No Separator ... 20050322
Period ... 2005.03.22
Slash ... 2005/03/22
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds



__________Sending email from SAS__________
35   filename mail email to="phil@woodstreet.org.uk" ;
36   data ;
37     file mail ;
38     put 'hello' ;
39   run ;

NOTE: The file MAIL is:
      E-Mail Access Device

Message sent
      To:          phil@woodstreet.org.uk
      Cc:
      Subject:
      Attachments:
NOTE: 1 record was written to the file MAIL.
      The minimum record length was 5.
      The maximum record length was 5.
NOTE: The data set WORK.DATA2 has 1 observations and 0 variables.
NOTE: DATA statement used:
      real time           6.82 seconds
      cpu time            0.06 seconds
40   filename mail email ' '
41                  to=('phil@woodstreet.org.uk')
42                  cc=('john@woodstreet.org.uk' 'peter@woodstreet.org.uk')
43                  subject="Here are your graphs for &sysdate"
44                  attach =('c:\gchart1.gif' 'c:\gchart2.gif') ;
45   data _null_;
46     file mail;
47     put "I could put some text in here to describe the graphs.";
48     put " ";
49   run;

NOTE: The file MAIL is:
      E-Mail Access Device

Message sent
      To:          ('phil@woodstreet.org.uk' )
      Cc:          ('john@woodstreet.org.uk' 'peter@woodstreet.org.uk' )
      Subject:     Here are your graphs for 18JUL03
      Attachments: ('c:\gchart1.gif' 'c:\gchart2.gif' )
NOTE: 2 records were written to the file MAIL.
      The minimum record length was 1.
      The maximum record length was 53.
NOTE: DATA statement used:
      real time           13.89 seconds
      cpu time            0.08 seconds



__________Specifying character/numeric variable ranges__________
data _null_ ;
  set sashelp.prdsale ;
  put actual-numeric-month ; * numeric range ;
  put country-character-product ; * character range ;
run ;
Using a wildcard in variables lists
data x(keep=a:) ;                                          
  a1=1 ;                                                     
  a2=10 ;                                                    
  a3=100 ;                                                   
  b1=1000 ;                                                  
  b2=10000 ;                                                 
run;                                                       

NOTE: The data set WORK.X has 1 observations and 3 variables.   
NOTE: The DATA statement used 0.01 CPU seconds and 1435K.       
proc print ;                                           
  var a:;                                                
run ;                                                  

NOTE: The PROCEDURE PRINT used 0.01 CPU seconds and 1489K.  



__________Creating CSV files from datastep, easily__________
Put (_all_) (:) ;
32   filename out 'c:\out.csv' ;
33   data _null_;
34     file out dsd;
35     set sashelp.class;
36     put (_all_) (:);
37   run;
bb
NOTE: The file OUT is:
      File Name=c:\out.csv,
      RECFM=V,LRECL=256

NOTE: 19 records were written to the file OUT.
      The minimum record length was 17.
      The maximum record length was 21.
NOTE: There were 19 observations read from the data set SASHELP.CLASS.
NOTE: DATA statement used (Total process time):
      real time           0.13 seconds
      cpu time            0.04 seconds


38   filename out ;
NOTE: Fileref OUT has been deassigned.





*****************
*****OPTIONS*****
*****************

__________Capturing part of a SAS Log__________
%macro cliplog(marker1,marker2,pos=last,file=c:\test.txt) ;
 * note: split search text in half so we dont go and find it in our macro call ;
 * note: save mprint option since we want mprint turned off for the macro run, otherwise
         we get our search text written to the log and we will find it ;
  %let o=%sysfunc(getoption(mprint)) ;
  options nomprint ;
/* log;
   find '&marker1&marker2' &pos;
   rfind;
   mark;
   bottom;
   mark;
   store;
   unmark;
   notepad;
   clear;
   paste;
   file '&file';
   end
*/
  dm "log;find '&marker1&marker2' &pos;mark;bottom;mark;store;unmark;notepad;clear;paste;file 
'&file';end" ;
 * view the file in windows notepad ;
  x "notepad &file" ;
  options &o ;
%mend cliplog ;
***BEGIN***; /* this marks where to start the copying from the log */

/* now run all the SAS code you would like to capture */

%cliplog(***BEGIN,***) ; /* finally we call the macro which captures the log from the point we 
previously marked */



__________Useful secret options__________
proc options internal; 
run; 



__________Options by group__________
proc options group = inputcontrol;
run ;



__________Register location of SAS system__________
!SASROOT\sas.exe ?regserver 



__________Reset date on output__________
options date dtreset ;
ods rtf file='c:\test.rtf' ;
proc print data=sashelp.prdsale ;
run ;
ods rtf close ;



__________Get list of paper sizes__________
proc registry list startat="CORE\PRINTING\PAPER SIZES";
run;

* We can set the paper size to a pre-defined size, or enter measurements ;
options papersize=a3;

* Now we produce output and can verify in MS Word 
  that the page size is A3 as selected ;
ods rtf file='c:\test.rtf' ;
proc print data=sashelp.prdsale;
run ;
ods rtf close ;
[    Letter]
    Height=double:11
    Units="IN"
    Width=double:8.5 
...
[    ISO A4]
    Height=double:29.7
    Units="CM"
    Width=double:21



__________Make work files become permanent__________
1    * Test code, and all single level datasets go to work library, which is cleared when SAS
1  ! ends ;
2    data test ; x= 1 ; run ;

NOTE: The data set WORK.TEST has 1 observations and 1 variables.
NOTE: DATA statement used:
      real time           0.27 seconds
      cpu time            0.03 seconds


3
4    * Once tested, define the USER libref, sending all single level datasets to a permanent
4  ! location ;
5    libname user 'c:\' ;
NOTE: Libref USER was successfully assigned as follows:
      Engine:        V8
      Physical Name: c:\
6    data test ; x= 1 ; run ;

NOTE: The data set USER.TEST has 1 observations and 1 variables.
NOTE: DATA statement used:
      real time           0.01 seconds
      cpu time            0.01 seconds


7    * when finished free the USER fileref to redirect datasets to WORK ;
8    libname user ;
NOTE: Libref USER has been deassigned.



__________Turning comments on & off__________
%let a=/;  * debug code inactive ;
%let b=*;  * debug code inactive ;
*** to activate set A & B to blanks ***;
&a&b  
proc print data=x ;
run ;
*/;
data _null_ ;
run ;





****************
*****MACROS*****
****************

__________Automatic Macro variables__________
%put Session for &sysjobid started on &sysday &sysdate at &systime ; 
Session for XV02341 started on Thursday 29SEP94 at 06:51                  



__________Listing macro variables and their values__________
372  %let mg = i am global ;
373  %macro t ;
374     %local l1 l2 ;
375     %let l2 = i am local ;
376     %q
377  %mend t ;
378  %macro q ;
379     %local l3 ;
380     %let l3 = inner local ;
381     %put ***** local ***** ;
382     %put _local_ ;
ERROR: Macro keyword PUT appears as text.  A semicolon or other delimiter may be missing.
383     %put ----- user ----- ;
384     %put _user_ ;
385     %put ===== all ===== ;
386     %put _all_ ;
387     %mend q ;
388  %t
***** local *****
----- user -----
Q L3 inner local
T L1
T L2 i am local
GLOBAL MG i am global
===== all =====
Q L3 inner local
T L1
T L2 i am local
GLOBAL MG i am global
AUTOMATIC AFDSID 0
AUTOMATIC AFDSNAME
AUTOMATIC AFLIB
AUTOMATIC AFSTR1
AUTOMATIC AFSTR2
AUTOMATIC FSPBDV
AUTOMATIC SYSBUFFR
AUTOMATIC SYSCC 3000
AUTOMATIC SYSCHARWIDTH 1
AUTOMATIC SYSCMD
AUTOMATIC SYSDATE 22MAR05
AUTOMATIC SYSDATE9 22MAR2005
AUTOMATIC SYSDAY Tuesday
AUTOMATIC SYSDEVIC ACTIVEX
AUTOMATIC SYSDMG 0
AUTOMATIC SYSDSN WORK    DATA1
AUTOMATIC SYSENDIAN LITTLE
AUTOMATIC SYSENV FORE
AUTOMATIC SYSERR 0
AUTOMATIC SYSFILRC 0
AUTOMATIC SYSINDEX 2
AUTOMATIC SYSINFO 0
AUTOMATIC SYSJOBID 3300
AUTOMATIC SYSLAST WORK.DATA1
AUTOMATIC SYSLCKRC 0
AUTOMATIC SYSLIBRC 0
AUTOMATIC SYSMACRONAME Q
AUTOMATIC SYSMAXLONG 2147483647
AUTOMATIC SYSMENV S
AUTOMATIC SYSMSG
AUTOMATIC SYSNCPU 2
AUTOMATIC SYSPARM
AUTOMATIC SYSPBUFF
AUTOMATIC SYSPROCESSID 41D54421E93800004020000000000000
AUTOMATIC SYSPROCESSNAME DMS Process
AUTOMATIC SYSPROCNAME
AUTOMATIC SYSRC 0
AUTOMATIC SYSSCP WIN
AUTOMATIC SYSSCPL XP_PRO
AUTOMATIC SYSSITE 0031371006
AUTOMATIC SYSSIZEOFLONG 4
AUTOMATIC SYSSIZEOFUNICODE 2
AUTOMATIC SYSSTARTID
AUTOMATIC SYSSTARTNAME
AUTOMATIC SYSTIME 21:37
AUTOMATIC SYSUSERID Philip Mason
AUTOMATIC SYSVER 9.1
AUTOMATIC SYSVLONG 9.01.01M2P033104
AUTOMATIC SYSVLONG4 9.01.01M2P03312004



__________Accessing all macro variable values__________
%let name=Phil ;
%macro test ;
  %let count=1 ;
  proc print data=sashelp.vmacro ;
  run ;
%mend test ;
%test ;
proc sql ;
  select * from
    dictionary.macros ;
quit ;



__________Arithmetic calculations in macros__________
let x=%eval(1+2) ;
68     %put result=%eval(1+2) ;
result=3
69     %put result=%eval(1.0+2.0) ;
ERROR: A character operand was found in the %EVAL function or %IF condition where a numeric
       operand is required. The condition was: 1.0+2.0
result=
%put =======> %eval(9**99) ;                       
ERROR: Overflow has occurred; evaluation is terminated. 



__________Match quotes in macro comments__________
WARNING: The current word or quoted string has become more than 200 
         characters long.  You may have unbalanced quotation marks. 
%* This is Phil's unmatched quote which will cause problems ;

data x ;
  put "This single quote ' will not match with the previous one'" ;
 * since it was in quotes ;
  put 'But the first one used here will' ;
 * Note there is one single quote left unmatched ;
run ;

 * These quotes "' are O.K., since this kind of comment doesn't mind ;
/* These quotes '" are also O.K., since these comments don't mind either */
* This comment has 1 quote ' and is O.K. ;          
proc print data=sasuser.crime(obs=1) ;  
run ;                                   
%* This is not OK ' ;                                           
proc print data=sasuser.crime(obs=1) ;                          
run ;                                                           
WARNING: The current word or quoted string has become more than 200  
characters long.  You may have unbalanced quotation marks.  
%* because the proc print ends up between quotes ' and never runs ;           



__________Forcing SAS to store macro symbol tables on disk__________
* Store macro symbol table to work library ;
options msymtabmax=0 ;

*** Define some macro variables ;
%let a=1 ;
%let b=2 ;

%macro fred ;
  %let c=3 ;
%mend fred ;

%fred

*** Now look in your Work library and you can see the SAS0STn catalogs ;
***    each one has a member for each macro variable ;



__________How to produce files for import into other applications__________
ods csv file='c:\test.csv' ;
proc print data=sashelp.prdsale ;
run ;
ods csv close ; 
"Obs","ACTUAL","PREDICT","COUNTRY","REGION","DIVISION","PRODTYPE","PRODUCT","QUARTER","YEAR","MONTH"
"1",925.00,850.00,"CANADA","EAST","EDUCATION","FURNITURE","SOFA",1,1993,"Jan"
"2",999.00,297.00,"CANADA","EAST","EDUCATION","FURNITURE","SOFA",1,1993,"Feb"
"3",608.00,846.00,"CANADA","EAST","EDUCATION","FURNITURE","SOFA",1,1993,"Mar"



__________Useful merge macro__________
%************************** mergeby *******************************;
%* mergeby acts like a MERGE statement with a BY statement even if there are no BY variables;

%macro mergeby(data1, data2, byvars);
  %if %bquote(&byvars) NE %then
    %do;
      merge %unquote(&data1) %unquote(&data2);
        by %unquote(&byvars);
    %end;
  %else
    %do;
      if _end1 & _end2 then
        stop;
      if ^_end1 then 
        set %unquote(&data1) end=_end1;
      if ^_end2 then 
        set %unquote(&data2) end=_end2;
    %end;
%mend mergeby;
* Create some sample data - firstly dataset x ;
data x;
  do x=1 to 5;
    output;
  end;
run;

* Create some sample data - secondly dataset y ;
data y;
  do y=1 to 3;
    output;
  end;
run;

*** Now we merge the two datasets with a standard merge statement ;
*** - notice that there is no BY statement ;
data xy;
  merge x y;
run;

proc print data=xy;
run;

*** Now we merge the two datasets with the MERGEBY macro ;
data xy;
  %mergeby(x,y);
run;
proc print data=xy;
run;
                                                    



                                                    The SAS System                      13:27 Thursday, May 4, 2006   9
data xy(drop=last_y) ;
  retain last_y ;
  merge x y ;
  if y NE . then
    last_y=y ;
  else
    y=last_y ;
run ;



__________Automatically document your programs__________
/***
Program Name : Doc
Date         : 5Feb2007
Written By   : Phil Mason
Overview     : Scans a directory and looks at all SAS code,
               extracts the comments to creating a
               MS Word file for documentation
Parms        : target ... directory where modules are
                          located that we wish to document 
***/
%macro doc(target) ;

filename dir pipe "dir ""&target""" ;

data files(keep=file line) ;
  length file line $ 200 
         next $ 8 ;
  label file='Filename'
        line='Header' ;
  if _n_=1 then
    put '*** Processing files ***' / ;
  infile dir missover ;
 * You may need to adjust this depending on the version of the operating system you are running 
on - for my system I am able to read the file name from a directory listing at column 37 ;
  input @37 file & ;
 * Only continue if the file is a SAS file ;
  if index(upcase(file),'.SAS')>0 ;
  put '--> ' file ;
  next='' ;
 * Point to that SAS file ;
  rc1=filename(next,"&target\"||file) ;
 * Open it up ;
  fid=fopen(next) ;
  write=0 ;
 * Read through each line of the SAS file ;
  do while(fread(fid)=0) ;
    line=' ' ;
    rc3=fget(fid,line,200) ;
     * if it is the start of a comment block then I will write line ;
	if index(line,'/*')>0 then
	  write=1 ;
	if write then
        output ;
     * if its end of comment block I will stop writing lines ;
	if index(line,'*/')>0 then
	  write=0 ;
   * we only process comment blocks that start on the first line
     - i.e. headers ;
     * only continue reading lines if I am currently in a comment block ;
	if ^write then
	  leave ;
  end ;
 * close file ;
  fid=fclose(fid) ;
  rc=filename(next) ;
run ;

* free the file ;
filename dir ;

* point to an rtf file to create ;
ods rtf file='c:\Documentation.rtf' ;

title "Documentation for &target" ;
data _null_ ;
  set files ;
    by file notsorted ;
  file print ods ;
  if first.file then
    put @1 file @ ;
  put @2 line ;
run ;

* close the rtf file ;
ods rtf close ;

%mend doc ;
%doc(C:\temp\programs)
/*
Author: Phil Mason
Date: 28June2006
Purpose: This is just to demonstrate how the documentation macro works
*/
data test ;
  put 'this shouldnt appear in documentation' ;
run ;



__________Capturing part of SAS log to a file__________
%macro start(file=c:\test.sas) ;
  filename mprint "&file" ;
  options mprint mfile ;
%mend start ;
%macro finish ;
  options nomfile ;
  filename mprint ;
%mend finish ;
%start ;
* put your code here ... ;
%finish ;



__________Modifying label of a dataset & why__________
%macro label(ds) ;
  %let dsid=%sysfunc(open(&ds)) ;
%sysfunc(attrc(&dsid,label)) 
  %let dsid=%sysfunc(close(&dsid)) ;
%mend label ;
*** How to use it ;
data x(label='part 1') ;
run ;
data x(label="%label(x) - part 2") ;
set x ;
run ;



__________Keep only variables on a dataset__________
4020  data x ;
4021  set sashelp.prdsale(keep=x actual) ;
ERROR: The variable x in the DROP, KEEP, or RENAME list has never been referenced.
4022  run ;
%macro vars_on_dset(dset,vars) ;
  %let dsid=%sysfunc(open(&dset)) ;
  %let vars=%sysfunc(compbl(&vars)) ;
  %let n=%eval(1+%length(&vars)-%length(%sysfunc(compress(&vars)))) ;
  %put n=&n;
  %do i=1 %to &n ;
    %let bit=%scan(&vars,&i) ;
    %if %sysfunc(varnum(&dsid,&bit))>0 %then
      &bit ;
  %end ;
  %let dsid=%sysfunc(close(&dsid)) ;
%mend vars_on_dset ;
4042  Data out(keep=%vars_on_dset(sashelp.prdsale,x actual)) ;
n=2
MPRINT(VARS_ON_DSET):  actual
4043    Set sashelp.prdsale ;
4044  Run ;

NOTE: There were 1440 observations read from the data set SASHELP.PRDSALE.
NOTE: The data set WORK.OUT has 1440 observations and 1 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


4045  proc contents data=out ;
4046  run ;

NOTE: PROCEDURE CONTENTS used (Total process time):
      real time           0.07 seconds
      cpu time            0.01 seconds



                                          Documentation for C:\temp\Programs            13:27 Thursday, May 4, 2006  37

                                                The CONTENTS Procedure

                 Data Set Name        WORK.OUT                              Observations          1440
                 Member Type          DATA                                  Variables             1
                 Engine               V9                                    Indexes               0
                 Created              Thursday, May 04, 2006 10:52:53 PM    Observation Length    8
                 Last Modified        Thursday, May 04, 2006 10:52:53 PM    Deleted Observations  0
                 Protection                                                 Compressed            NO
                 Data Set Type                                              Sorted                NO
                 Label
                 Data Representation  WINDOWS_32
                 Encoding             wlatin1  Western (Windows)


                                           Engine/Host Dependent Information

          Data Set Page Size          4096
          Number of Data Set Pages    4
          First Data Page             1
          Max Obs per Page            501
          Obs in First Data Page      368
          Number of Data Set Repairs  0
          File Name                   C:\DOCUME~1\phil\LOCALS~1\Temp\SAS Temporary Files\_TD3564\out.sas7bdat
          Release Created             9.0101M3
          Host Created                XP_PRO


                                      Alphabetic List of Variables and Attributes

                              #    Variable    Type    Len    Format        Label

                              1    ACTUAL      Num       8    DOLLAR12.2    Actual Sales



__________Combining small values__________
%macro limit(limit=0.01,
             class1=a,
             class2=b,
             anal=x,
             more=.,
             in=in,
             out=out) ;
* Limit ... values less that this percentage are combined ;
* class1 ... 1st classification variable ;
* class2 ... 2nd classification variable ;
* anal ... analysis variable ;
* more ... value to use for values that are combined ;

proc sql ;
  create table &out as
    select &class1,
           &class2,
           sum(&anal) as &anal
      from (select &class1,
            case when(&anal/sum(&anal)<&limit) then &more
                                               else &class2
            end as &class2,
            &anal
      from &in
        group by &class1)
          group by &class1,
                   &class2 ;
  quit ;
%mend limit ;

*** Create test data ;
  data in ;
    do a=1 to 10 ;
      do b=1 to 100 ;
        x=ranuni(1)*100 ;
        output ;
      end ;
    end ;
run ;

filename graph 'c:\g1.png' ;
goptions device=png gsfname=graph ;
proc gchart data=in ;
  vbar a / subgroup=b sumvar=x discrete ;
run ; 
quit ;

***  Use limit macro to avoid large confusing legends and imperceptibly tiny  bar segments ;
%limit(limit=0.02) ;

filename graph 'c:\g2.png' ;
proc gchart data=out ;
  vbar a / subgroup=b sumvar=x discrete ;
run ; 
quit ;





***********************
*****ASSORTED TIPS*****
***********************

__________Outputting multiple PROCs to a page__________
* Setting it to a space causes SAS to fill each page before going to the next one ;
Options formdlim=' ' ;

* Setting it to a null string resets the value of formdlim to the default,
  so that each new Proc will start on a new page ;
Options formdlim='' ;



__________Printing graphs in Landscape or Portrait__________
   GOPTIONS ROTATE ;



__________Putting BY variables into TITLEs__________
OPTIONS NOBYLINE;

PROC PRINT;
TITLE "List for #BYVAR1 - #BYVAL1";
  BY ST;
  VAR Var1-Var10;
run;
List for STATE - Tasmania
List for STATE - Victoria
BY STATE=Tasmania
BY STATE=Victoria
BY DIV DEPT;
TITLE "Budget - #BYVAL1/#BYVAL2";
Budget - Academic Affairs/Art
Budget - Academic Affairs/History
Budget - Administration/Admissions
Budget - Administration/Registrar



__________Multiple graphs on a page__________
 /********************************************************************

       name: grid
      title: Replay graphs in a regular grid
    product: graph
     system: all
      procs: greplay gslide
    support: saswss                      update:  10jul95

 DISCLAIMER:

       THIS INFORMATION IS PROVIDED BY SAS INSTITUTE INC. AS A SERVICE
 TO ITS USERS.  IT IS PROVIDED "AS IS".  THERE ARE NO WARRANTIES,
 EXPRESSED OR IMPLIED, AS TO MERCHANTABILITY OR FITNESS FOR A
 PARTICULAR PURPOSE REGARDING THE ACCURACY OF THE MATERIALS OR CODE
 CONTAINED HEREIN.

 The %GRID macro lets you easily replay graphs in a regular grid with
 one or more rows and one or more columns. The %GRID macro also
 supports titles and footnotes for the entire replayed graph. For
 example, if you have run GPLOT four times and want to replay these
 graphs in a 2-by-2 grid with the title 'Four Marvellous Graphs', you
 could submit the following statements:

    title 'Four Marvellous Graphs';
    %grid( gplot*4, rows=2, cols=2);

 The %GRID macro allows 10% of the vertical size of the graph for
 titles by default. You can adjust this percentage via the TOP=
 argument in %GRID. Determining the best value for TOP= requires
 trial and error in most cases. To allow space for footnotes, use
 the BOTTOM= argument.

 The graphs to replay must be stored in a graphics catalog with
 library and member names specified by the macro variables &glibrary
 and &gout. By default, SAS/GRAPH stores graphs in WORK.GSEG, which
 is the catalog that the %GRID macro uses by default.  If your
 graphs are in another catalog, you must specify &glibrary and/or
 &gout using %LET statements as shown below.

 Each graph that is stored in a catalog has a name. Each procedure
 assigns default names such as GPLOT, GPLOT1, GPLOT2, etc. Most
 SAS/GRAPH procedures let you specify the name via a NAME= option
 which takes a quoted string that must be a valid SAS name. However,
 if a graph by that name already exists in the catalog, SAS/GRAPH
 appends a number to the name; it does not replace the previous graph
 by the same name unless you specify GOPTIONS GOUTMODE=REPLACE, but
 this option causes _all_ entries in the catalog to be deleted
 every time you save a new graph, so it is not very useful. If you want
 to replace a single graph in a catalog, sometimes you can use the
 %GDELETE macro to delete the old one and later recreate a graph with
 the same name, but this does not work reliably due to a bug in
 SAS/GRAPH. By default, %GDELETE deletes _everything_ in the catalog;
 this does seem to work reliably.

 When you use BY processing, SAS/GRAPH appends numbers to the graph
 name to designate graphs for each BY group. For example, if you run
 GPLOT with three BY groups and NAME='HENRY', the graphs are named
 HENRY, HENRY1, and HENRY2. The %GRID macro lets you abbreviate this
 list of names as HENRY*3, where the repetition factor following the
 asterisk is the total number of graphs, not the number of the last
 graph.

 *********************************************************************/

%let glibrary=WORK;
%let gout=GSEG;

%macro grid(  /* replay graphs in a rectangular grid */
   list,      /* list of names of graphs, separated by blanks;
                 a name may be followed by an asterisk and a
                 repetition factor with no intervening blanks;
                 for example, ABC*3 is expanded to: ABC ABC1 ABC2 */
   rows=1,    /* number of rows in the grid */
   cols=1,    /* number of columns in the grid */
   top=10,    /* percentage at top to reserve for titles */
   bottom=0); /* percentage at bottom to reserve for footnotes */

   %gtitle;
   %greplay;
   %tdef(rows=&rows,cols=&cols,top=&top,bottom=&bottom)
   %trep(&list,rows=&rows,cols=&cols)
   run; quit;
%mend grid;


%macro gdelete(list); /* delete list of graphs from the catalog;
                         default is _ALL_ */

   %if %bquote(&list)= %then %let list=_ALL_;
   proc greplay igout=&glibrary..&gout nofs;
      delete &list;
   run; quit;
%mend gdelete;


%macro gtitle; /* create graph with titles and footnotes only */

   %global titlecnt;
   %if %bquote(&titlecnt)= %then %let titlecnt=1;
                           %else %let titlecnt=%eval(&titlecnt+1);
   goptions nodisplay;
   proc gslide gout=&glibrary..&gout name="title&titlecnt";
   run;
   goptions display;
%mend gtitle;


%macro greplay( /* invoke PROC GREPLAY */
   tc);         /* template catalog; default is JUNK */

   %if %bquote(&tc)= %then %let tc=junk;
   proc greplay nofs tc=&tc;
      igout &glibrary..&gout;
%mend greplay;


%macro tdef(  /* define a template for a rectangular grid */
   rows=1,    /* number of rows in the grid */
   cols=1,    /* number of columns in the grid */
   top=10,    /* percentage at top to reserve for titles */
   bottom=0); /* percentage at bottom to reserve for footnotes */
   %global tdefname; /* returned: name of template */

   %local height width n row col lower upper left right;
   %let height=%eval((100-&top-&bottom)/&rows);
   %let width =%eval(100/&cols);
   %let tdefname=t&rows._&cols;
   tdef &tdefname
      0/ulx=0 uly=100 llx=0 lly=0 urx=100 ury=100 lrx=100 lry=0
   %let n=1;
   %do row=1 %to &rows;
      %let lower=%eval(100-&top-&row*&height);
      %let upper=%eval(&lower+&height);
      %do col=1 %to &cols;
         %let right=%eval(&col*&width);
         %let left =%eval(&right-&width);
         &n/ulx=&left uly=&upper llx=&left lly=&lower
            urx=&right ury=&upper lrx=&right lry=&lower
         %let n=%eval(&n+1);
      %end;
   %end;
   ;
   template &tdefname;
%mend tdef;


%macro trep( /* replay graphs using template defined by %TDEF */
   list,     /* list of names of graphs, separated by blanks;
                a name may be followed by an asterisk and a
                repetition factor with no intervening blanks;
                for example, ABC*3 is expanded to: ABC ABC1 ABC2 */
   rows=,    /* (optional) number of rows in template */
   cols=);   /* (optional) number of columns in template */
             /* rows= and cols= default to values set with %TDEF */

   %global titlecnt;
   %local i l n row col name root suffix nrep;
   %if %bquote(&rows)= %then %let rows=%scan(&tdefname,1,t_);
   %if %bquote(&cols)= %then %let cols=%scan(&tdefname,2,t_);
   treplay 0:title&titlecnt
   %let nrep=0;
   %let l=0;
   %let n=0;
   %do row=1 %to &rows;
      %do col=1 %to &cols;
         %let n=%eval(&n+1);
         %if &nrep %then %do;
            %let suffix=%eval(&suffix+1);
            %if &suffix>=&nrep %then %do;
               %let nrep=0;
               %goto tryagain;
            %end;
            %let name=&root&suffix;
            %goto doit;
         %end;
%tryagain:
         %let l=%eval(&l+1);
         %let name=%qscan(&list,&l,%str( ));
         %if &name= %then %goto break;
         %let i=%index(&name,*);
         %if &i %then %do;
            %let nrep=%substr(&name,&i+1);
            %if &nrep<=0 %then %goto tryagain;
            %let root=%substr(&name,1,&i-1);
            %let name=&root;
            %let suffix=0;
         %end;
%doit:
         &n:&name
      %end;
   %end;
%break:
   ;
%mend trep;

 /****************** Examples for the %GRID macro *******************/

%inc greplay;

data trig;
   do n=1 to 100;
      x1=sin(n/16);
      x2=sin(n/8);
      y1=cos(n/16);
      y2=cos(n/8);
      output;
   end;
run;

goptions nodisplay;
proc gplot data=trig;
   title 'Y1 by X1';
   plot y1*x1;
run;
   title 'Y1 by X2';
   plot y1*x2;
run;
   title 'Y2 by X1';
   plot y2*x1;
run;
   title 'Y2 by X2';
   plot y2*x2;
run;

title 'Four Marvellous Graphs';
%grid( gplot*4, rows=2, cols=2);


title 'Adding a Title to a Single Graph';
footnote 'And a Footnote';
%grid( gplot, top=12, bottom=5);



__________Putting multiple graphs & tables on an HTML page__________
%let panelcolumns = 4;
%let panelborder = 4;
ods tagsets.htmlpanel file="C:\bypanel2.html" gpath='c:\' options(doc='help');
goptions device=activex xpixels=320 ypixels=240;
title1 'Product Reports' ;
footnote1 ;
proc summary data=sashelp.shoes nway ;
  class region product ;
  var stores sales inventory returns ;
  output out=sum sum= mean= /autolabel autoname ;
run ;
proc gchart data=sum ;
  by region ;
  vbar product / sumvar=sales_sum pattid=midpoint discrete ;
run;
quit;
proc summary data=sashelp.shoes nway ;
  class region subsidiary ;
  var stores sales inventory returns ;
  output out=sum sum= mean= /autolabel autoname ;
run ;
%let panelcolumns = 5;
%let panelborder = 1;
ods tagsets.htmlpanel ;
title 'Summary data' ;
proc print data=sum ;
run ;
title 'Subsidiary Reports' ;
%let panelcolumns = 5;
%let panelborder = 1;
ods tagsets.htmlpanel ;
goptions dev=activex xpixels=160 ypixels=120;
proc gchart data=sum ;
  by region ;
  pie subsidiary / sumvar=sales_sum discrete ;
run;
quit;
ods _all_ close;



__________Nicknames__________
proc nickname ; run;
1    proc nickname ; run ;
NOTE: ENGINE is the default object type.

Current Catalog: SASHELP.CORE

      Nickname  Module    Type   Fileformat   Description

P  M  ACCESS    SASIOMDB  ENG    7            SAS/ACCESS Interface to PC Files
   M  ACCESS99  SASECRSP  ENG                 Read engine for CRSP ACCESS97 database
   M  BASE      SASE7     ENG    7            Base SAS I/O Engine
P  M  BLOOMBRG  SASIOBLB  ENG    9            SAS/Access Interface To Bloomberg
P  M  BMDP      SASBMDPE  ENG    607          BMDP Save file engine
P  M  CRSPACC   SASECRSP  ENG                 Read engine for CRSP ACCESS97 database
P  M  CVP       SASECVP   ENG    9            Character Variable Padding Engine
P  M  DB2       SASIODBU  ENG    7            SAS/ACCESS Interface to DB2
P  M  EXCEL     SASIOXLS  ENG    7            SAS/ACCESS Interface to PC Files
P  M  FAMECHLI  SASEFAME  ENG                 Seamless libname interface to FAME db
P  M  HAVERDLX  SASEHAVR  ENG    9            Read engine for Haver Analytics DLX db
P     IMDB      SASEIMDB  ENG    9            In Memory Database Engine
P  M  META      SASIOMET  ENG    7            Metadata engine
P  M  MYSQL     SASIOMYL  ENG    7            SAS/ACCESS Interface to MySQL
P  M  ODBC      SASIOODB  ENG    7            SAS/ACCESS Interface to ODBC
P     OLAP      SASEOLAP  ENG    9            SQL Passthru Engine for OLAP
P  M  OLEDB     SASIOOLE  ENG    7            SAS/ACCESS Interface to OLE DB
P  M  ORACLE    SASIOORA  ENG    7            SAS/ACCESS Interface to Oracle
P  M  OSIRIS    SASOSIRI  ENG    607          OSIRIS Data File engine
P     R3        SASIOSR3  ENG    9            SAS Engine for SAP R/3
P  M  REMOTE    SASIORMT  ENG    7            SAS/SHARE Remote access engine
P  M  REMOTE8   SASI8RMT  ENG    7            SAS/SHARE V8 Remote access engine
P  M  REUTERS   SASEREUT  ENG    612          Reuters financial market data interface
   M  SASIOOS2  SASIODBU  ENG    7            SAS/ACCESS Interface to DB2
P  M  SPDE      SASSPDE   ENG    7            Scalable Performance Data Engine
P  M  SPSS      SASSPSS   ENG    607          SPSS Save File engine
P     SQLVIEW   SASESQL   ENG    607          SQL view engine
   M  SXLE      SASEXML   ENG    8            W3C XML input/output engine
P  M  SYBASE    SASIOSYB  ENG    7            SAS/ACCESS Interface to Sybase
P  M  TERADATA  SASIOTRA  ENG    8            SAS/ACCESS Interface to Teradata
P     TRACE     SASETRC   ENG    7            Version 7 trace engine
P  M  V6        SASEB     ENG    607          Base SAS I/O Engine
P  M  V604      SASIO602  ENG    606          Base SAS I/O Engine - 6.06 defaults
   M  V607      SASEB     ENG    607          Base SAS I/O Engine
   M  V608      SASEB     ENG    607          Base SAS I/O Engine
   M  V609      SASEB     ENG    607          Base SAS I/O Engine
   M  V610      SASEB     ENG    607          Base SAS I/O Engine
   M  V611      SASEB     ENG    607          Base SAS I/O Engine
   M  V612      SASEB     ENG    607          Base SAS I/O Engine
   M  V7        SASE7     ENG    7            Base SAS I/O Engine
   M  V701      SASE7     ENG    7            Base SAS I/O Engine
   M  V8        SASE7     ENG    7            Base SAS I/O Engine
P  M  V9        SASE7     ENG    7            Base SAS I/O Engine
P  M  XML       SASEXML   ENG    8            W3C XML input/output engine
P  M  XPORT     SASV5XPT  ENG    607          Version 5 transport datasets

P     BASE      SASXBAM   AM                  Base A. M. for external files
P     CACHE     SASXBAMO  AM     9.1          IOM Cache Service
P  M  CATALOG   SASXBAML  AM                  Base A. M. for Catalog's
P     CLIPBRD   SASXBAMB  AM     9.1          Clipboard Access Method
P  M  COMMPORT  SASVCOMM  AM                  Communication Ports
P  M  DDE       SASVADDE  AM                  Dynamic Data Exchange
P  M  DISK      SASXBAM   AM                  Base A. M. for Disk files
P  M  DRIVEMAP  SASVDMAP  AM                  Drive Map access method
P  M  DUMMY     SASXBAM   AM                  Base A. M. for Dummy files
P  M  EMAIL     SASVMAIL  AM                  Base A. M. for EMAIL
P  M  FTP       SASXBAMF  AM                  FTP  A. M.
P     G3270     SASXBAM   AM                  Base A.M. for 3270 Graphics terminals
P     GTERM     SASXBAM   AM                  Base A. M. for Graphic terminals
P     HTTP      SASXBAMH  AM                  Base A.M. for URL
P     LIBRARY   SASXBAML  AM                  Base A. M. for Catalog's
P     MESSAGE   SASXBAM   AM                  Base A. M. for Message files
P  M  NAMEPIPE  SASVNPIP  AM                  Named Pipes
P  M  NOTESDB   SASVNOTE  AM                  Base A. M. for Lotus(tm) Notes
P  M  PIPE      SASVUPIP  AM                  Anonymous Pipes
P  M  PLOTTER   SASXBAM   AM                  Base A. M. for Plotters
P  M  PRINTER   SASVPRNT  AM                  Base A. M. for Printers
P     REAL      SASXBAMR  AM                  Real Time A.M
P  M  SOCKET    SASXBAMT  AM                  TCP/IP Socket A. M.
P     STREAM    SASXBAMO  AM     9.1          IOM Cache Service
P     TCPIP     SASXBAMT  AM                  Base A.M. for TCP/IP Sockets
P  M  TEMP      SASXBAM   AM                  Base A. M. for temp files
P     TERMINAL  SASXBAM   AM                  Base A. M. for Terminals
P  M  UPRINTER  SASXBAMP  AM                  Base A.M. for Universal Printing
P  M  URL       SASXBAMH  AM                  Base A.M. for URL



__________Finding out about unknown options of procedures__________
14   proc nickname ??? ;
                   -
                   22
                    -
                    200
ERROR 22-322: Syntax error, expecting one of the following: ;, ACCESS, AM, AMETHOD, C, CALL,
              CAT, CATALOG, ENG, ENGINE, FMT, FNC, FORMAT, FUNC, FUNCTION, INF, INFORMAT, SUBR,
              SUBROUTINE.

ERROR 200-322: The symbol is not recognized and will be ignored.




__________Inconsistent treatment of misspelt PROC names__________
    proc setinitxxxxxxxxxx ;run;
         -----------------
         1
Original site validation data
Site name:    'SAS INSTITUTE AUSTRALIA PTY LTD'.
Site number:  2582050.
Expiration:   15JAN96.
Grace Period:  0 days (ending 15JAN96).
Warning Period: 30 days (ending 14FEB96).
System birthday:   23NOV92.
Operating System:   WIN     .
Product expiration dates:
---BASE Product                   15JAN96 (CPU A)
---SAS/GRAPH                      15JAN96 (CPU A)
---SAS/ETS                        15JAN96 (CPU A)
---SAS/FSP                        15JAN96 (CPU A)
---SAS/AF                         15JAN96 (CPU A)
---SAS/CALC                       15JAN96 (CPU A)
---SAS/ASSIST                     15JAN96 (CPU A)
---SAS/CONNECT                    15JAN96 (CPU A)
---SAS/INSIGHT                    15JAN96 (CPU A)
---SAS/EIS                        15JAN96 (CPU A)
---SAS/ACC-ODBC                   15JAN96 (CPU A)

WARNING 1-322: Assuming the symbol SETINIT was misspelled as
               SETINITXXXXXXXXXX.

NOTE: The PROCEDURE SETINITXXXXXXXXX used 1.27 seconds.
399  proc optionsoptionsoptions ;run;
          ---------------------
          1

WARNING 1-322: Assuming the symbol OPTIONS was misspelled as optionsoptionsoptions.

    SAS (r) Proprietary Software Release 9.1  TS1M2

Portable Options:

<lines removed>

NOTE: The PROCEDURE OPTIONSOPTIONSOP used 8.01 seconds.
20   pro cprint data=sasuser.crime ;
     ---
     14
ERROR: Procedure CPRINT not found.
21   run ;

WARNING 14-169: Assuming the symbol PROC was misspelled as PRO.

NOTE: The SAS System stopped processing this step because of errors.
NOTE: The PROCEDURE CPRINT used 0.28 seconds.



__________Tell me what I have?__________
* what products are licensed here? What is my site number? When will SAS expire? ;
proc setinit ;
run ;

* what librefs are defined? ;
libname _all_ list ;

* what filerefs are defined? ;
filename _all_ list ;

* what macro variables are defined? ;
%put _all_ ;

* what options are set? - including undocumented internal ones ;
proc options internal ; 
run ;

* what ODS styles are available? ;
proc template ; 
  list styles ; 
run ;

* what SAS/Graph devices are available? ;
proc gdevice nofs ; 
  list _all_ ; 
run ;

* what SAS/Graph software fonts do I have? ;
proc catalog catalog=sashelp.fonts ;
  contents ; 
run ; quit ;



__________Saving graphs without ods__________
filename g 'c:\test.png' ;
goptions device=png gsfname=g ;
proc gchart data=sashelp.class ;
  vbar sex ; 
run ;



__________Using pictures as patterns in bar charts__________
goptions reset=all gsfname=g device=png xmax=6in ymax=4in xpixels=1800
         ypixels=1200 ftext='Arial' htext=5pct;
filename g 'c:\sex11.png' ; 
proc gchart data=sashelp.class ; 
   where age=11 ; 
   pie sex ;
run ;
filename g 'c:\sex12.png' ;
proc gchart data=sashelp.class ; 
  where age=12 ; 
  pie sex ; 
run ;
filename g 'c:\sex13.png' ; 
proc gchart data=sashelp.class ; 
  where age=13 ; 
  pie sex ; 
run ;
filename g 'c:\sex14.png' ; 
proc gchart data=sashelp.class ; 
  where age=14 ; 
  pie sex ; 
run ;
filename g 'c:\sex15.png' ; 
proc gchart data=sashelp.class ; 
  where age=15 ; 
  pie sex ; 
run ;
filename g 'c:\sex16.png' ; 
proc gchart data=sashelp.class ; 
  where age=16 ; 
  pie sex ; 
run ;
filename g 'c:\vbar.png' ;
pattern1  image='c:\sex11.png' ;
pattern2  image='c:\sex12.png' ;
pattern3  image='c:\sex13.png' ;
pattern4  image='c:\sex14.png' ;
pattern5  image='c:\sex15.png' ;
pattern6  image='c:\sex16.png' ;
title c=red 'Male ... ' c=green 'Female' ;
proc gchart data=sashelp.class  ;
  vbar age / subgroup=age discrete width=20 nolegend ; 
run; quit;



__________Getting list of drivers & info__________
proc gdevice nofs ;
  list _all_ ;
run ;
proc gdevice nofs ;
  list png ;
run ;





********************************
*****UTILITY PROCEDURE TIPS*****
********************************

__________More information on space used by catalog members__________
options ls=132 ; * Set linesize wide or output looks a bit weird ;
PROC CATALOG C=sashelp.datafmt ;
  CONTENTS STAT ;
run ;
  # Name     Type    Level         Create Date       Modified Date Description
????????????????????????????????????????????????????????????????????????????????????????????????
  1 BEANIPA  FILEFMT    12  22FEB2002:14:09:29  04SEP2001:00:00:00 BEA National Income and
                                                                   Product Accounts Tapes
  2 BEANIPAD FILEFMT    12  22FEB2002:14:09:29  04SEP2001:00:00:00 BEA National Income and
                                                                   Product Accounts Diskettes
  3 BEASPAGE FILEFMT    12  22FEB2002:14:09:29  04SEP2001:00:00:00 BEA S-Page Current
                                                                   Business Statistics
  4 BLSCPI   FILEFMT    12  22FEB2002:14:09:29  04SEP2001:00:00:00 BLS Consumer Price Index
                                                                   Surveys (CU,CW)
  5 BLSEENA  FILEFMT    12  22FEB2002:14:09:30  04SEP2001:00:00:00 BLS Employment, Hours, and
                                                                   Earnings National Survey (EE)
  6 BLSEESA  FILEFMT    12  22FEB2002:14:09:30  04SEP2001:00:00:00 BLS State and Area
                                                                   Employment, Hours, and
                                                                   Earnings Survey (SA)
                   Last  Last
Page Block Num of Block Block
Size  Size Blocks Bytes  Size Page
??????????????????????????????????
4096  4096      1  1438  1530    1

4096  4096      1  1439  1530    1

4096  4096      1  1510  1530    1

4096  4096      1  3533  3570    1

4096  4096      2  1254  1275    1

4096  4096      1  3286  3315    1

4096  4096      1  2047  2295



__________Displaying all characters of a SAS font__________
%macro showfont(font) ;
  filename font "c:\&font..png" ;
  goptions reset=all device=png gsfname=font ;
  title "Font: &font" ;
  proc gfont name=&font 
                  nobuild
                  height=.4 cm 
                  romcol=red
                  romfont=swissl
                  romht=.3 cm
                  showroman ;
  run;
  quit;
%mend showfont ;

%showfont(math)
%showfont(greek)



__________7 ways to tune sorts in SAS__________
PROC SORT data=fred NOEQUALS ;
  BY this that ;
run;
options sortwkno=6 ;



__________Using Integrity Constraints__________
data people ; 
  length sex  $  1 
         name $ 32 
         serial  8 ;
  delete ; 
run ;
data classes ;
  length serial   8
         class $ 32 ;
  delete ; 
run ;
proc datasets ; 
  modify people ;
    ic create null_name=not null(name) ;
	ic create check_sex=check(where=(sex in ('M','F'))) ;
    ic create one_ser=unique(serial) ;
	ic create prim=primary key(serial) ;
  modify classes ;
    ic create null_class=not null(class) ;
	ic create for_key=foreign key(serial)
      references people 
      on delete set null 
      on update cascade ;
run ; quit ;
proc sql;
   create table people
    (
     name      char(14),
     gender    char(1),
     hired     num,
     jobtype   char(1) not null,
     status    char(10),

    constraint prim_key primary key(name),
    constraint gender check(gender in ('male' 'female')),
    constraint status check(status in ('permanent' 
                            'temporary' 'terminated')) 
     );

     create table salary
     (
      name     char(14),
      salary   num not null,
      bonus    num,

      constraint for_key foreign key(name) references people
         on delete restrict on update set null
     );
  quit;





********************************************
*****PROCEDURE TIPS FOR DISPLAYING DATA*****
********************************************
 
__________Creating Tab separated output using PROC TABULATE__________
options nodate
        nonumber
        ls=254
        ps=32767 ;
proc tabulate data=sashelp.prdsale
              formchar=',             '
              noseps ;
  class country region ;
  var actual ;
  table sum*actual, country all, region all ;
run ;
  table sum*actual, country all, region*division all ;



__________Creating datasets from Proc Tabulate__________
proc tabulate data=sashelp.prdsale out=test ;
  class country region ;
  var actual predict ;
  table country all,
        region*(actual*(sum mean) predict*(min median max)) ;
run ;
proc print data=test ;
run ;



__________Traffic lighting with Proc Tabulate__________
ods html file='test.html' ;
proc format ; 
  value traf
    low-120000='red'
    other='green' ;
proc tabulate data=sashelp.prdsale ;
  class country region ;
  var actual ;
  table actual*sum*{style={background=traf.}},country,region ;
run ;
ods html close ;



__________Producing multi-panel reports with PROC REPORT__________
234  options ls=132 ps=20 ;
235  proc report data=sashelp.shoes
236              panels=2  /* 2 horizontal panels */
237              nowd ;    /* nowd for running in batch */
238    col (subsidiary product sales) ;  /* Define columns we want */
239  run ;

NOTE: There were 395 observations read from the data set SASHELP.SHOES.
NOTE: PROCEDURE REPORT used (Total process time):
      real time           0.01 seconds
      cpu time            0.02 seconds



__________Indenting output using PROC TABULATE__________
options nocenter ;

data sample ;
  length x y $ 1 ;
  input x y z ;

cards ;
a b 1
b c 2
a c 3
a b 4
b c 5
a c 6
;

proc tabulate data=sample ;
  class x y ;
  var z ;
  table x*y, z*(min mean max) / INDENT=3 ;
run ;



__________Wrapping lines with PROC REPORT__________
   proc report data=sasuser.crime
               WRAP     /* wrap lines */
               nowd ;    * nowd for running in batch ;
   run ;



__________Saving space on the page with PROC TABULATE__________
proc tabulate data=sashelp.prdsale ; 
  class country region ;   
  var actual ;                       
  table country,                      
        sum*actual*region ;        
run ;
proc tabulate data=sashelp.prdsale 
              format=dollar8.
              noseps ; 
  class country region ;   
  var actual ;                       
  table country='',                      
        sum=''*actual=''*region='' /
        rts=10 ;        
run ;



__________Defining denominator definitions in PROC TABULATE__________
proc tabulate data=sasuser.houses noseps ;
   class style bedrooms ;
   var price ;
   table style, bedrooms*price*pctn<style> ;
 run ;
proc tabulate data=sasuser.houses noseps ;
  class style bedrooms ;
  var price ;
  table style, bedrooms*price*pctn<bedrooms> ;
run ;
proc tabulate data=sashelp.prdsale ;
  class country region ;
  var actual ;
  table (country all),
         region*
         actual=' '*(sum colpctsum*f=5.1
                         rowpctsum*f=5.1
                         reppctsum*f=5.1)
         all*actual*sum=' ' ;
run;
proc tabulate data=sasuser.houses noseps ;
  class style bedrooms ;
  var price ;
  table price,
        (style all)*pctsum,
        bedrooms all ;
run ;





******************************************
*****BASIC STATISTICAL PROCEDURE TIPS*****
******************************************

__________Frequency tables with long labels treated differently in SAS 8 to SAS 9__________
data x ;
  length a $ 30 ;
  input a ;
cards ;
this-is-26-characters-long
this-is-26-characters-long-not
this-is-26-characters-long
run ;

proc freq ;
  table a ;
run ;

proc summary nway ;
  class a ;
  output out=freq ;
run ;

proc print ;
  var a _freq_ ;
run ;



__________Automatic naming in Proc Summary__________
proc summary data=sashelp.prdsale nway ;
  class country / order=freq ; * countries with most observations come first ;
  class year month / descending ; * latest data comes first ;
  var actual predict ;
  output sum= mean= min= max= out=stats / autoname autolabel ;
run ; 
proc print label ; run ;



__________MEANS: Specifying confidence limits to calculate__________
options ls=110 ;
proc means data=sashelp.tourism alpha=.05 clm ;
run ;
proc summary data=sashelp.tourism alpha=.12345 ;
  var pop pdi ;
  output out=stats lclm=low_pop low_pdi uclm=big_pop big_pdi ;
run ;
proc report data=stats nowd ;
  format low_pdi big_pdi comma12. ;
run ;



__________UNIVARIATE: Mode is the minimum when there are multiples__________
data sample ;                  
  input x ;                    
cards ;                        
1  
1 
2                              
3.1                            
3.5                            
3.9                            
4                              
;                              
run ;                          
proc univariate data=sample ;  
  var x ;                      
run ;                          



__________UNIVARIATE/FASTCLUS: Calculating weighted Medians__________
data w;
  input x w;
datalines;
1  0
3  1
4  2
4  3
7  5
99 10
;
run ;
proc univariate data=w;
  var x;
  freq w;
run;
proc fastclus data=w maxc=1 least=1;
  var x;
  weight w;
run;



__________REG: Determing whether to use intercepts__________
data DATASET;
  set DATASET;
  INTER=1;
run;
proc reg data=DATASET;
   model DEP = INDEP1 INDEP2 .. INTER
      / selection=rsquare ...;
run;





*****************************
*****THE PRINT PROCEDURE*****
*****************************

__________A better looking report with BY groups__________
proc sort data=sashelp.company ;
  by level1 level2 ;
run ;
proc print data=sashelp.company ;
  by level1 level2 ;
  var job1 n ;
run ;
proc print data=sashelp.company ;
  by level1 level2 ;
  id level1 level2 ;
  var job1 n ;
run ;
Labels are always displayed in BY groups
proc sort data=sasuser.fitness ;        
  by group ;  
run;                          
proc print data=sasuser.fitness label ; 
  by group ;                            
  var oxygen runpulse rstpulse ;        
run ;                                   
proc print data=sasuser.fitness ;       
  by group ;                            
  var oxygen runpulse rstpulse ;        
run ;                                   






******************************
*****THE FORMAT PROCEDURE*****
******************************

__________Nesting formats within other formats__________
proc format ;                                           
  value loads                                           
    5000-<6000 = 'Over 5,000'                             
    6000-<7000 = 'Over 6,000'                             
    7000-<8000 = 'Over 7,000'                             
    8000-<9000 = 'Over 8,000'                             
    other      = 'Mega!' ;                                
  value couple                                          
    2 = 'Bingo!'                                          
    5000-<10000 = [loads10.]          
    other=[comma6.] ;                                   
data _null_ ;                                           
  input x ;                                             
  put x couple. ;                                       
  cards ;
1
2
3
12
1234
5678
8888
9999
12345
;
run ;                                                   
4287  proc format ;
4288    value loads
4289      5000-<6000 = 'Over 5,000'
4290      6000-<7000 = 'Over 6,000'
4291      7000-<8000 = 'Over 7,000'
4292      8000-<9000 = 'Over 8,000'
4293      other      = 'Mega!' ;
NOTE: Format LOADS has been output.
4294    value couple
4295      2 = 'Bingo!'
4296      5000-<10000 = [loads10.]
4297      other=[comma6.] ;
NOTE: Format COUPLE has been output.

NOTE: PROCEDURE FORMAT used (Total process time):
      real time           0.10 seconds
      cpu time            0.01 seconds


4298  data _null_ ;
4299    input x ;
4300    put x couple. ;
4301    cards ;

     1
Bingo!
     3
    12
 1,234
Over 5,000
Over 8,000
Mega!
12,345
NOTE: DATA statement used (Total process time):
      real time           0.04 seconds
      cpu time            0.00 seconds


4311  ;
4312  run ;



__________Modifying standard (In)Formats with a custom (in)format__________
data _null_ ;                                                         
  input number 8. ;                                                   
  put number= ;                                                       
cards ; 
10
Phil Mason
9.5
SUGI
;;
run ;                                                                 
proc format ;                                                         
  invalue myfmt                                                       
    ' '     = 0                                                       
    .       = 0                                                       
    'A'-'Z' = 0                                                       
    'a'-'z' = 0                                                       
    other   = [8.] ; 
data _null_ ;                                                         
  input number myfmt. ; * Use our modified informat ;
  put number= ;                                                       
cards ;                                                               
10
Phil Mason
9.5
SUGI
;;
run ;
* Now we have no errors !;
* We could set values to a special missing value such as .A ;
*   which could then be selectively removed ;
1    data _null_ ;
2      input number 8. ;
3      put number= ;
4    cards ;

number=10
NOTE: Invalid data for number in line 6 1-8.
number=.
RULE:      ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
6          Phil Mason
number=. _ERROR_=1 _N_=2
number=9.5
NOTE: Invalid data for number in line 8 1-8.
number=.
8          SUGI
number=. _ERROR_=1 _N_=4
NOTE: DATA statement used (Total process time):
      real time           0.18 seconds
      cpu time            0.06 seconds


9    ;;
10   run ;
11   proc format ;
12     invalue myfmt
13       ' '     = 0
14       .       = 0
15       'A'-'Z' = 0
16       'a'-'z' = 0
17       other   = [8.] ;
NOTE: Informat MYFMT has been output.

NOTE: PROCEDURE FORMAT used (Total process time):
      real time           0.09 seconds
      cpu time            0.00 seconds


18   data _null_ ;
19     input number myfmt. ; * Use our modified informat ;
20     put number= ;
21   cards ;

number=10
number=0
number=9.5
number=0
NOTE: DATA statement used (Total process time):
      real time           0.09 seconds
      cpu time            0.00 seconds


26   ;;
27   run ;
28   * Now we have no errors !;
29   * We could set values to a special missing value such as .A ;
30   *   which could then be selectively removed ;



__________Mixing character and numeric values in Informats__________
Proc format ;
  invalue mixed
    1-10  = 1
    11-20 = 2
    'XYZ' = 9
    other=999 ;
run;
data in ;
  input info mixed. ;
  put "Input Data: " _infile_ / @13 info= ;
cards ;
1
3.2
13
XYZ
A
;;
run ;
138  Proc format ;
139    invalue mixed
140      1-10  = 1
141      11-20 = 2
142      'XYZ' = 9
143      other=999 ;
NOTE: Informat MIXED is already on the library.
NOTE: Informat MIXED has been output.
144  run;

NOTE: PROCEDURE FORMAT used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


145  data in ;
146    input info mixed. ;
147    put "Input Data: " _infile_ / @13 info= ;
148  cards ;

Input Data: 1
            info=1
Input Data: 3.2
            info=1
Input Data: 13
            info=2
Input Data: XYZ
            info=9
Input Data: A
            info=999
NOTE: The data set WORK.IN has 5 observations and 1 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


154  ;;
155  run ;



__________Automatically rounding numbers__________
retains the prPROC FORMAT ;                                                      
  PICTURE THOU7C (MIN=7 MAX=7 ROUND)
                            .  = '     O'
     -999999500 <-  -99999500  = '999999' (PREFIX='-' MULT=.001)
     -99999500  <-< 0          = '00,009' (PREFIX='-' MULT=.001)
     0           -< 999999500  = '000,009' (MULT=.001)
     OTHER                     = '*******'  ;
NOTE: Format THOU7C has been output.
NOTE: The PROCEDURE FORMAT used 0.01 CPU seconds and 1476K.

data _null_ ;                                                      
  format a b c d thou7c. ;                                         
  a=123499.99 ;                                                    
  b=123500 ;                                                       
  c=-123500 ;                                                      
  d=-123499.99 ;                                           
  put _all_ ;                                              
run ;                                                      
                                                                
A=123 B=124 C=-124 D=-123 _ERROR_=0 _N_=1                       
NOTE: The DATA statement used 0.01 CPU seconds and 1476K.



__________Using formats in a table lookup__________
proc format ;
  value $names
    "phil" = "1"
    "chris"="2"
    "kristian"="3"
    "fiona"="4"
    "elaine"="5" ;
run ;
%mkfmt(library.servs,$servs,servno,"Y",other="N",fmtlib=1) ;
%macro mkfmt(dset, fmtname, start, label, other=, library=library, fmtlib=) ;                                   
%* dset     sas dataset name ;                                           
%* fmtname  name of format to create ;                                   
%* start    variable to be used as START in format ;                     
%* label    variable to be user for LABEL in format ;                    
%* other    Optionally set all other values to this variable or literal; 
%* library  Optionally override default format library to your own Library ;
%* fmtlib   Put any text here to list your format when created ;
         
data temptemp(keep=fmtname hlo &start label) ;                         
  retain fmtname "&fmtname"                                            
  hlo ' ' ;                                                     
  set &dset                                                            
  end=eofeof ;                                                     
  label=&label ; * This could be a variable or a literal ;             
  output ;                                                             

%if &other NE  %then                                                
  %do ;                                                              
  if eofeof then                                                
    do ;                                                        
      hlo='o' ;                                                 
      label=&other ;                                            
      output ;                                                  
    end ;                                                       
%end ;                                                          

run ;                                                               

proc sort data=temptemp(rename=(&start=start)) nodupkey ;           
  by start hlo ;                                                    

proc format library=&library                                        
          %if "&fmtlib">"" %then                                              
            fmtlib ;                                                
            cntlin=temptemp ;                                       
          %if "&fmtlib">"" %then                                              
            select &fmtname ; ; * Make sure we only print 1 format from lib ; 

run ;                                                               

%mend mkfmt ;                                                         





*************
*****SQL*****
*************

__________Automatic Data Dictionary information provided by SAS__________
proc sql;                                                       
create view vcol as                                            
select * from dictionary.columns                             
where libname='SQL' and memname='EMPLOYE2';                   
NOTE: SQL view USER.VCOL has been defined.                            
proc print data=vcol label;  
run;                               



___________method on Proc SQL__________
30   proc sql _method ;
31   select retail.*
32     from sashelp.retail
33       left join
34          sashelp.prdsale
35       on retail.year=prdsale.year
36     order by retail.year ;


__________SQL views are now updatable (mostly)__________
proc sql ;
  create view test as select height/weight as ratio, * from sashelp.class ;
dm 'vt test' vt ;
dm 'vt sashelp.class' vt;
proc sql;
   update test
      set name='ABC';
dm 'vt test' vt ;



__________Montonic function__________
proc sql; 
  select monotonic() as rowno, * 
  from sashelp.prdsale 
  where 10 le monotonic() le 20 ; 
quit;



__________=: in SQL__________
If name=:'P' then flag=1 ;
proc sql; 
  select * 
  from sashelp.class 
  where name eqt 'J' ; 
quit; 



__________Conditional arithmetic__________
 Select 
  SUM (CASE FRED
         WHEN 'A' THEN AMOUNT
                  ELSE 0
       END) AS FREDAMT
  From data.set ;



__________Providing values to use in place of missing values__________
data test ;
  input a b ;
  cards ;
1 2
3 .
. 6
. .
;;
run ;
proc sql ;
  select coalesce(a,b,.m) as c
    from test ;



__________Using values just calculated__________
proc sql ;                      
  select style,                 
         bedrooms,              
         price/sqfeet as value  
  from sasuser.houses           
  where calculated value > 55 ; 



__________Examining resource usage in SQL__________
2	proc sql ;                                            
3	select * from sasuser.class where sex='F' ;         
4	select * from sasuser.class where age>15 ;          
NOTE: The PROCEDURE SQL used 0.03 CPU seconds and 1816K.   
5	proc sql ;                                            
6	reset stimer ;                                      
NOTE: The SQL Statement used 0.00 CPU seconds and 1816K.   
7	select * from sasuser.class where sex='F' ;         
NOTE: The SQL Statement used 0.01 CPU seconds and 1816K.   
8	select * from sasuser.class where age>15 ;          
NOTE: The SQL Statement used 0.01 CPU seconds and 1816K.   



__________Generating statements to define dataset/view structure__________
    proc sql ;                                                       
      describe table sasuser.fitness ;



__________Creating a range of macro variables from SQL with leading zeroes__________
proc sql noprint ;
  select name into :name01-:name19 from sashelp.class ;




*******************************************
*****OPERATING SYSTEM (MAINLY WINDOWS)*****
*******************************************

__________Run SAS easily in batch on windows__________
C:\PROGRA~1\SASINS~1\SAS\V8\SAS.EXE "%1" -nologo -config h:\mysasf~1\v8\batch.CFG -noaltlog



__________Copying datasets the fastest way__________
Data new.name ;
  Set old.name ;
Run ;
Proc copy in=old out=new ;
  Select name ;
Run ;
X 'copy c:\old\directory\name.sas7bdat c:\new\directory' ;
%macro copyfile(from,to) ;
  %if %index(&from,.)>0 %then
    %do ;
      %let lib=%scan(&from,1,.) ;
      %let dset=%scan(&from,2,.) ;
    %end ;
  %else
    %do ;
      %let lib=work ;
      %let dset=&from ;
    %end ;
  %let fromfile=%sysfunc(pathname(&lib))\&dset..sas7bdat ;
  %if %index(&to,.)>0 %then
    %do ;
      %let lib=%scan(&to,1,.) ;
      %let dset=%scan(&to,2,.) ;
    %end ;
  %else
    %do ;
      %let lib=work ;
      %let dset=&to ;
    %end ;
  %let tofile=%sysfunc(pathname(&lib))\&dset..sas7bdat ;
  options noxwait xsync ;
  filename cmd1 pipe "erase &tofile" ;
  data _null_ ;
    infile cmd1 ;
    input ;
    put 'NOTE- COMMAND OUTPUT:' _infile_ ;
  run ;
  filename cmd2 pipe "copy ""&fromfile"" ""&tofile"" " ;
  data _null_ ;
    window msg irow=4 rows=9 columns=120 
    #1 @6 'Copying file using the following command ...' 
    #3 @1 "copy ""&fromfile"" ""&tofile"" " c=blue persist=yes ;
    display msg noinput ;
    infile cmd2 ;
    input ;
    put 'NOTE- COMMAND OUTPUT:' _infile_ ;
  run ;
%mend copyfile ;
/*%copyfile(x1,system.temp) ;*/



__________Running concurrent operating system commands__________
systask command "dir c:\ /s >c:\results.txt" nowait taskname=dir ;
systask command "copy c:\test.txt d:" nowait taskname=copy ;
waitfor _all_ dir copy ;
%put Finished! ;



__________Using wildcards for file lists__________
filename c 'c:\*.txt' ;
data fred ;
  infile c filename=file ;
  input line $200. ;
 * write out the first 10 lines ;
  if _n_<10 then
    put file= line= ;
run ;
312  filename c 'c:\*.txt' ;
313  data fred ;
314    infile c filename=file ;
315    input line $200. ;
316   * write out the first 10 lines ;
317    if _n_<10 then
318      put file= line= ;
319  run ;

NOTE: The infile C is:
      File Name=c:\CountCyclesWMVDecLog.txt,
      File List=c:\*.txt,RECFM=V,LRECL=256

file=c:\Count line=# dwFOURCC=32564d57, dFrameRate=30.000, 320x240, bInterlaceYUV411=0, bHostDeinterlace=1 Decoded on Mon Jan 09 
09:02:58 2006
NOTE: The infile C is:
      File Name=c:\hcwclear.txt,
      File List=c:\*.txt,RECFM=V,LRECL=256

NOTE: The infile C is:
      File Name=c:\slog.txt,
      File List=c:\*.txt,RECFM=V,LRECL=256

file=c:\slog. line=GET /serial_system/activate/activate.php?hwkey=1777315948&serial=9888776&softid=10&check=0 HTTP/1.0

file=c:\slog. line=Host: www.inertiasoftware.com

file=c:\slog. line=User-Agent: StarSyn 1.0

file=c:\slog. line=HTTP/1.0 200 OK

file=c:\slog. line=Date: Mon, 12 Dec 2005 17:30:34 GMT

file=c:\slog. line=Server: Apache/2.0.46 (Red Hat)

file=c:\slog. line=

file=c:\slog. line=
NOTE: The infile C is:
      File Name=c:\VIS.TXT,
      File List=c:\*.txt,RECFM=V,LRECL=256

NOTE: 2 records were read from the infile C.
      The minimum record length was 0.
      The maximum record length was 123.
NOTE: 1 record was read from the infile C.
      The minimum record length was 32.
      The maximum record length was 32.
NOTE: 30 records were read from the infile C.
      The minimum record length was 0.
      The maximum record length was 100.
NOTE: 42 records were read from the infile C.
      The minimum record length was 1.
      The maximum record length was 256.
      One or more lines were truncated.
NOTE: SAS went to a new line when INPUT statement reached past the end of a line.
NOTE: The data set WORK.FRED has 41 observations and 1 variables.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds



__________Here are some programming meImporting & exporting between SAS & Microsoft Access__________
98   libname tabs 'x:\my documents\db1.mdb' ;
NOTE: Libref TABS was successfully assigned as follows:
      Engine:        ACCESS
      Physical Name: x:\my documents\db1.mdb
99   data x ;
100    set tabs.names ; * read table NAMES from database DB1 ;
101  run ;

NOTE: There were 3 observations read from the data set TABS.names.
NOTE: The data set WORK.X has 3 observations and 3 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


102  data tabs.new ; * Create a new table called NEW in database DB1 ;
103    set sashelp.class ;
104  run ;

NOTE: There were 19 observations read from the data set SASHELP.CLASS.
NOTE: The data set TABS.new has 19 observations and 5 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.02 seconds

105  libname tabs ;
NOTE: Libref TABS has been deassigned.



__________Reading and writing SAS datasets within a ZIP file__________
1    libname test 'C:\Sample SAS data.zip' ;
NOTE: Libref TEST was successfully assigned as follows:
      Engine:        V8
      Physical Name: C:\Sample SAS data.zip

2    proc print data=test.cars ;
3    run ;

NOTE: There were 116 observations read from the data set TEST.CARS.
NOTE: PROCEDURE PRINT used:
      real time           0.26 seconds
      cpu time            0.03 seconds


4    data test.new_thing ;
5      x=1 ;
6    run ;

NOTE: The data set TEST.NEW_THING has 1 observations and 1 variables.
NOTE: DATA statement used:
      real time           0.14 seconds
      cpu time            0.03 seconds



__________Browsing external files__________
fslist 'c:\frame.html'
fslist
proc fslist file='c:\config.sas';
run ;



__________Sizing the screen space used by SAS__________
-awsdef 0 0 100 100
-noawsmenu



__________Running VB macros in EXCEL from SAS__________
filename excdata dde 'Excel|System';
data _null_;
  file excdata;
  put ' RUN("File.xls!Macro2",FALSE)]';
run;



__________Creating a Pivot Table in EXCEL directly from SAS__________
/******************************************************************************/
/* Title      : createpivottable.sas                                          */
/* Description: Exports a SAS Data Set to Excel and creates a Pivot Table     */
/* Parameters : inpfile - The name of the data set to be exported             */ 
/*              xlsheet - The name of the Excel file to create                */
/*              rcols   - The name of the SAS variables to be set as row      */
/*                        fields in the Pivot Table                           */
/*              hcols   - The name of the SAS variables to be set as column   */
/*                        fields in the Pivot Table                           */
/*              dfields - The name of the SAS variables to be set as data     */
/*                        fields in the Pivot Table                           */
/* Author     : Chris Brooks                                                  */
/*              Office of National Statistics, UK                             */
/* Date       : June 2005                                                     */
/*                                                                            */
/* Change History:                                                            */
/*                                                                            */
/* Notes      : This has been tested using Windows XP Pro, SAS 9.1.3 and      */
/*              Excel2002 - there are no guarantees it will work with any     */
/*              other version of Excel as the Excel Object Model can          */
/*              (and does) change considerably between versions - you have    */
/*              been warned!!!!                                               */
/*                                                                            */
/*              The parameters rcols, hcols and dfields are space separated   */
/*              "lists" of variables (see sample call)                        */
/*                                                                            */
/* Sample Call: %createpivottable(sashelp.class,'c:\sas\sample.xls',          */
/*                     name age, sex,weight);                           */
/*                                                                            */
/******************************************************************************/


%macro createpivottable(inpfile,xlsheet,rcols,hcols,dfields);

  /* Firstly use Proc Export to create the Excel Workbook */
  
  proc export data=&inpfile outfile="&xlsheet" dbms=excel replace;
  run;

  data _null_;

    /* Open a text file which will be used to write VBA Commands to */
      
    %let filrf=pivvbs;
    %let rc=%sysfunc(filename(filrf,'c:\sas\pivot.vbs'));
        
      %if &rc ne 0 %then
          %put %sysfunc(sysmsg());

    /* Create an instance of the Excel Automation Server */
    
    %let fid=%sysfunc(fopen(&filrf,O));
    %if &rc ne 0 %then
          %put %sysfunc(sysmsg());
    %let rc=%sysfunc(fput(&fid,Set XL = CreateObject("Excel.Application")));
    
    /* Make Excel visible, otherwise there isn't a lot of point! */

      %let rc=%sysfunc(fwrite(&fid,-));
    %let rc=%sysfunc(fput(&fid,XL.Visible=True)); 
    
    /* Open the newly created workbook */

      %let rc=%sysfunc(fwrite(&fid,-));
    %let wstring=XL.Workbooks.Open "&xlsheet";
    
    /* Determine the last cell in the range */
 
    %let rc=%sysfunc(fput(&fid,&wstring)); 
    
      %let rc=%sysfunc(fwrite(&fid,-));
    %let rc=%sysfunc(fput(&fid,Xllastcell= xl.cells.specialcells(11).address)); 
        
      %let rc=%sysfunc(fwrite(&fid,-));
    
    /* Add a new worksheet to the workbook to hold the pivot table */
    
    %let rc=%sysfunc(fput(&fid,XL.Sheets.Add.name = "PivotTable")); 
    
      %let rc=%sysfunc(fwrite(&fid,-));
    %let sname=%scan(&xlsheet,-2,\.);
    %let wstring=xldata="&sname";
    %let rc=%sysfunc(fput(&fid,&wstring));
    %let rc=%sysfunc(fwrite(&fid,-));
    %let rc=%sysfunc(fput(&fid,XL.Sheets(xldata).select)); 
    
    /* Start the pivot table wizard and set the range for the pivot table to the data 
previously exported */
      %let rc=%sysfunc(fwrite(&fid,-));
    %let wstring=%nrstr(XL.ActiveSheet.PivotTableWizard SourceType=xlDatabase,XL.Range("A1" & 
":" & xllastcell),"Pivottable!R1C1",xldata));
    %let rc=%sysfunc(fput(&fid,&wstring); 
    
      %let rc=%sysfunc(fwrite(&fid,-));

    

    /* Loop through the list of row fields and set them in the pivot table */

    %let i=0; 
    %do %while(%scan(&rcols,&i+1,%str( )) ne %str( ));     
      %let i = %eval(&i+1);   
      %let var = %scan(&rcols,&i,%str( ));   
      
      %let 
rc=%sysfunc(fput(&fid,XL.ActiveSheet.PivotTables(xldata).PivotFields("&var").Orientation =1)) ;
      %let rc=%sysfunc(fwrite(&fid,-));
    %end; 
    %let i=0; 

    /* Loop through the list of column fields and set them in the pivot table */

    %do %while(%scan(&hcols,&i+1,%str( )) ne %str( ));     
      %let i = %eval(&i+1);   
      %let var = %scan(&hcols,&i,%str( ));   
      
      %let 
rc=%sysfunc(fput(&fid,XL.ActiveSheet.PivotTables(xldata).PivotFields("&var").Orientation =2)) ;
      %let rc=%sysfunc(fwrite(&fid,-));
    %end;

    /* Loop through the list of data fields and set them in the pivot table */

    %let i=0; 
    %do %while(%scan(&dfields,&i+1,%str( )) ne %str( ));     
      %let i = %eval(&i+1);   
      %let var = %scan(&dfields,&i,%str( ));   
      
      %let 
rc=%sysfunc(fput(&fid,XL.ActiveSheet.PivotTables(xldata).PivotFields("&var").Orientation =4)) ;
      %let rc=%sysfunc(fwrite(&fid,-));
      
    %end;

    /* Hide the field list */

    %let rc=%sysfunc(fput(&fid,XL.Activeworkbook.ShowPivotTableFieldList = False));
    %let rc=%sysfunc(fwrite(&fid,-));

    /* Close the file */

    
    %let rc=%sysfunc(fclose(&fid));

    x "c:\sas\pivot.vbs";
  run;

%mend;

%createpivottable(sashelp.prdsale,c:\prdsale.xls,country region division,quarter year 
month,actual predict);



__________Exporting to EXCEL__________
libname nice 'c:\nice.xls' ;
data nice.test ;
  set sashelp.class ;
run ;
libname nice ;
* Open the sheet ;
%sysexec "c:\nice.xls" ;
334  libname nice 'c:\nice.xls' ;
NOTE: Libref NICE was successfully assigned as follows:
      Engine:        EXCEL
      Physical Name: c:\nice.xls
335  data nice.test ;
336    set sashelp.class ;
337  run ;

NOTE: There were 19 observations read from the data set SASHELP.CLASS.
NOTE: The data set NICE.test has 19 observations and 5 variables.
NOTE: DATA statement used (Total process time):
      real time           0.09 seconds
      cpu time            0.01 seconds


338  libname nice ;
NOTE: Libref NICE has been deassigned.
339  * Open the sheet ;
340  %sysexec "c:\nice.xls" ;
libname out excel 'c:\test.xls' ;
data out.class ; set sashelp.class ; run ;
* try to replace dataset ;
data out.class ; set sashelp.class ; run ;
* make a new dataset ;
data out.shoes ; set sashelp.shoes ; run ;
* free it so we can read the spreadsheet from EXCEL ;
libname out ;
341  libname out excel 'c:\test.xls' ;
NOTE: Libref OUT was successfully assigned as follows:
      Engine:        EXCEL
      Physical Name: c:\test.xls
342  data out.class ; set sashelp.class ; run ;

NOTE: There were 19 observations read from the data set SASHELP.CLASS.
NOTE: The data set OUT.class has 19 observations and 5 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


343  * try to replace dataset ;
344  data out.class ; set sashelp.class ; run ;

ERROR: The MS Excel table class has been opened for OUTPUT. This table already exists, or there 
is a name conflict with an existing object. This table will not be
       replaced. This engine does not support the REPLACE option.
NOTE: The SAS System stopped processing this step because of errors.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


345  * make a new dataset ;
346  data out.shoes ; set sashelp.shoes ; run ;

NOTE: SAS variable labels, formats, and lengths are not written to DBMS tables.
NOTE: There were 395 observations read from the data set SASHELP.SHOES.
NOTE: The data set OUT.shoes has 395 observations and 7 variables.
NOTE: DATA statement used (Total process time):
      real time           0.26 seconds
      cpu time            0.03 seconds


347  * free it so we can read the spreadsheet from EXCEL ;
348  libname out ;
NOTE: Libref OUT has been deassigned.



__________Using DDE for customising MS Word output__________
* make a sample report ;
ods rtf file='c:\sample.rtf' ;
proc print data=sashelp.class ; run ;
ods rtf close ;

* Make a sample graph ;
filename out 'c:\test.png' ;
goptions device=png gsfname=out ;
proc gchart data=sashelp.class ;
  hbar age ;
run ;
filename out ;

* Microsoft Word must already be running ;
filename word dde 'MSWORD|system' ;

* send DDE commands to MS WORD to combine files and create a new one ;
data _null_ ;
  file word ;
  put '[FileNew .Template = "normal.dot", .NewTemplate = 0]' ;
  put '[toggleportrait]' ;
  put '[ViewZoom .TwoPages]' ;
  put '[ViewFooter]' ;
  put '[FormatFont .Points=10, .Font="Arial", .Bold=1]' ;
  put '[FormatParagraph .Alignment=1]' ;
  put '[Insert "This is my footer"]' ;
  put '[ViewFooter]' ;
  put '[ViewHeader]' ;
  put '[Insert "This is my lovely header"]' ;
  put '[ViewHeader]' ;
  put '[InsertPicture .name="C:\test.png"]' ;
  put '[WordLeft]' ;
  put '[SelectCurWord]' ;
  put '[FormatPicture .scalex=150, .scaley=150]' ;
  put '[WordRight]' ;
  put '[insertpagebreak]' ;
  put '[InsertFile .name="C:\sample.rtf"]' ;
  put '[FileSaveAs .name="c:\test.doc"]' ;
  put '[FileClose]' ;
run ;



__________Starting & minimising programs from SAS__________
* don't wait for command to finish or synchronize with rest of SAS ;
options noxwait noxsync ;
* start MS Word and minimize it ;
/*x "start /min C:\Program Files\Microsoft Office\Office10\winword.exe" ;*/
x "start /min C:\Progra~1\Micros~3\Office10\winword.exe" ;
x '"C:\Program Files\Microsoft Office\Office10\winword.exe"' ;
START ["title"] [/Dpath] [/I] [/MIN] [/MAX] [/SEPARATE | /SHARED]
      [/LOW | /NORMAL | /HIGH | /REALTIME | /ABOVENORMAL | /BELOWNORMAL]
      [/WAIT] [/B] [command/program]
      [parameters]

    "title"     Title to display in  window title bar.
    path        Starting directory
    B           Start application without creating a new window. The
                application has ^C handling ignored. Unless the application
                enables ^C processing, ^Break is the only way to interrupt
                the application
    I           The new environment will be the original environment passed
                to the cmd.exe and not the current environment.
    MIN         Start window minimized
    MAX         Start window maximized
    SEPARATE    Start 16-bit Windows program in separate memory space
    SHARED      Start 16-bit Windows program in shared memory space
    LOW         Start application in the IDLE priority class
    NORMAL      Start application in the NORMAL priority class
    HIGH        Start application in the HIGH priority class
    REALTIME    Start application in the REALTIME priority class
    ABOVENORMAL Start application in the ABOVENORMAL priority class
    BELOWNORMAL Start application in the BELOWNORMAL priority class
    WAIT        Start application and wait for it to terminate
    command/program
                If it is an internal cmd command or a batch file then
                the command processor is run with the /K switch to cmd.exe.
                This means that the window will remain after the command
                has been run.

                If it is not an internal cmd command or batch file then
                it is a program and will run as either a windowed application
                or a console application.

    parameters  These are the parameters passed to the command/program



__________Getting the date, time & size of a non-SAS file__________
%macro getstats(dir_cmd) ;
  %global _date _time _size ; 
  filename cmd pipe "&dir_cmd" ;                                                                                              
  data _null_ ;                                                                                                                       
    infile cmd truncover ; 
   * This works on windows XP Professional, but on other version you might need to adjust the 
settings to
     read the information you want from different positions ; 
    input #6  @1 date ddmmyy10.                                                                                                       
             @13 time time5.                                                                                                          
             @20 size comma17. ;     
   * Now write the data to macro variables to be used ; 
    call symput('_date',put(date,date9.)) ;                                                                                          
    call symput('_time',put(time,time5.)) ;                                                                                          
   * note we use left justification within formatted field , otherwise number is right 
justified within field ; 
    call symput('_size',put(size,comma9. -l)) ;
  run ;                     
%mend getstats ;
%getstats(dir c:\windows\notepad.exe) ;
%put Date=&_date Time=&_time Size=&_size ; 
387  %macro getstats(dir_cmd) ;
388    %global _date _time _size ;
389    filename cmd pipe "&dir_cmd" ;
390    data _null_ ;
391      infile cmd truncover ;
392     * This works on windows XP Professional, but on other version you might need to adjust 
the settings to
393       read the information you want from different positions ;
394      input #6  @1 date ddmmyy10.
395               @13 time time5.
396               @20 size comma17. ;
397     * Now write the data to macro variables to be used ;
398      call symput('_date',put(date,date9.)) ;
399      call symput('_time',put(time,time5.)) ;
400     * note we use left justification within formatted field , otherwise number is right 
justified within field ;
401      call symput('_size',put(size,comma9. -l)) ;
402    run ;
403  %mend getstats ;
404  %getstats(dir c:\windows\notepad.exe) ;

NOTE: The infile CMD is:
      Unnamed Pipe Access Device,
      PROCESS=dir c:\windows\notepad.exe,RECFM=V,
      LRECL=256

NOTE: 8 records were read from the infile CMD.
      The minimum record length was 0.
      The maximum record length was 50.
NOTE: DATA statement used (Total process time):
      real time           0.04 seconds
      cpu time            0.01 seconds


405  %put Date=&_date Time=&_time Size=&_size ;
Date=10AUG2004 Time= 6:00 Size=69,120





*********************
*****SAS/CONNECT*****
*********************

__________Connecting SAS sessions between mainframes__________
LIBNAME libref <REMOTE> <'sas-data-library'> SERVER=rsessid <engine/host-options> ;
The server is the Remote Session ID that you signed on with.
* I have logged onto the mainframe and entered online SAS ;
* Now I tell SAS what protocol I will use to connect ;
* and what system to connect to (you can PING the system to see if its there) ; 
options comamid=tcp
        remote=abc ;                            
* Now I tell SAS where my SAS/CONNECT logon script is ;
* The logon script tells SAS how to logon to the remote system ;
* filename rlink "ivmktg.xv02341.cntl(tcptso)" ;  
* Now I tell SAS to go ahead and log on to the remote system ;
* make sure you are not already logged on to it ;
signon ;                                   
* To cut off the link enter SIGNOFF on the command line.



__________Getting your IP address & connecting to yourself__________
*** Part 1 ***;
filename cmd pipe 'ipconfig' ;
data _null_ ;
  infile cmd dlm='.: ' ;
  input @'IP Address' n1 n2 n3 n4 3. ;
  IP_Address=compress(put(n1,3.)||'.' ||put(n2,3.)||'.'
                    ||put(n3,3.)||'.' ||put(n4,3.));
  call symput('ip',ip_address) ;
run ;
%put My IP address is &ip ;

*** Part 2 ***;
%let london=&ip;
/*%let london=homepc; * can alternatively use the PC name;*/
signon london ;
rsubmit london ;
  proc setinit ; run ;
endrsubmit ;





*************
*****ODS*****
*************

__________Using Java & ActiveX to generate static graphs__________
goptions device=actximg ;
/*goptions device=javaimg ;*/
ods html body='c:\test.html'
         gpath='c:\'
         (url=none) ;
proc gchart data=sashelp.shoes ;
  vbar3d product / sumvar=sales ;
run ;
ods html close ;



__________Using a web browser to view HTML ODS output__________
ods html body='c:\body.html'
         contents='c:\contents.html'
         page='c:\page.html' 
         frame='c:\frame.html' ;
proc sort data=sashelp.prdsale ;
  by country region ;
proc print data=sashelp.prdsale ;
  by country region ;
run ;
ods html close ;
dm "wbrowse 'c:\frame.html'" ;



__________Using multiple orientations in ODS__________
Options orientation=landscape ;
Ods rtf file='c:\test.rtf' ;
Proc print data=sashelp.vmacro ;
Run ;
Options orientation=portrait ;
Ods rtf ; * notify rtf that orientation changed ;
Proc print data=sashelp.vmacro ;
Run ;
Ods rtf close ;



__________Generating graphs automatically for some procedures__________
ods listing close ;
ods html file='lifetest.html' ;
ods graphics on;
proc lifetest data=sashelp.class;
  time age;
  survival confband=all plots=(hwb);
run;
ods graphics off;
ods html close;



__________Page x of y in RTF & PDF__________
ods escapechar = '\';
title 'This document will have page x of y '
      j=r 'Page \{pageof}' ;
ods rtf file='c:\test.rtf' ;
proc print data=sashelp.prdsale;
run;
ods rtf close;
ods escapechar = '\';
title 'This document will have page x of y '
      j=r 'Page \{thispage} of \{lastpage}' ;
ods pdf file='c:\test.pdf' ;
proc print data=sashelp.prdsale;
run;
ods pdf close;



__________Page x of y in RTF ? SAS 8__________
ODS ESCAPECHAR="^";
footnote J=R "^R/RTF'{PAGE \field {\*\fldinst PAGE\*\MERGEFORMAT}} { OF  \field {\*\fldinst 
NUMPAGES \*\MERGEFORMAT} }'"; 



__________Sending data to excel__________
ods html file='c:\html.xls' ;
ods phtml file='c:\phtml.xls' ;
ods htmlcss file='c:\htmlcss.xls' ;
proc print data=sashelp.class ;
run ;
ods _all_ close ;
ods listing;



__________Using native EXCEL formatting from ODS__________
ods html file='c:\both.xls' ;
data x ;
  do value=.1 to 1 by .1 ;
    fraction=value ;
    output ;
  end ;
run ;
proc print ;
  var value ;
  var fraction / style(data)={htmlstyle="mso-number-format:\#\/\#"};
run ;
ods html close ;
8    ods html file='c:\both.xls' ;
NOTE: Writing HTML Body file: c:\both.xls
9    data x ;
10     do value=.1 to 1 by .1 ;
11       fraction=value ;
12       output ;
13     end ;
14   run ;

NOTE: The data set WORK.X has 10 observations and 2 variables.
NOTE: DATA statement used (Total process time):
      real time           0.04 seconds
      cpu time            0.04 seconds


15   proc print ;
16     var value ;
17     var fraction / style(data)={htmlstyle="mso-number-format:\#\/\#"};
18   run ;

NOTE: There were 10 observations read from the data set WORK.X.
NOTE: PROCEDURE PRINT used (Total process time):
      real time           0.50 seconds
      cpu time            0.09 seconds


19	ods html close ;



__________Page x of y in EXCEL reports__________
ods htmlcss file='c:\temp.xls' 
            stylesheet="c:\temp.css"
  	     headtext='<style> @Page {mso-header-data:"Page &P of &N";
                                      mso-footer-data:"&Lleft text &Cpage &P&R&D&T"} ;
		        </style>' ;
proc print data=sashelp.prdsale ;
run ;
ods htmlcss close ;



__________Useful attributes with ODS in titles & footnotes__________
ods rtf file='c:\test.rtf' ;
Title1 justify=l bold 'Left'
      justify=c h=2 'Centre'
      f=arial j=right 'Right' ;
Title2 link='www.sas.com' 'SAS web site' ;
proc print data=sashelp.class ; 
run ;
ods rtf close ;



__________Producing a spreadsheet for each BY group__________
ods listing close;
ods html path="c:\temp\"
         body="body.xls"
         contents="contents.html"
         newfile=page;
proc sort data=sashelp.prdsale ;
  by product ;
run ;
proc tabulate data=sashelp.prdsale ;
  by product ;
  class country region ;
  var actual predict ;
  table country all,
        region all,
		(actual predict)*sum ;
run ;
ods html close ;
dm "wbrowse 'c:\temp\contents.html'" wbrowse ;



__________Producing multi-column reports__________
%let dest=rtf; * pdf, ps or rtf ;
%let cols=2 ;
ods &dest columns=&cols file="c:\test.&dest" ;
goptions rotate=landscape ;
proc print data=sashelp.shoes ;
  var region stores sales ;
run ;
ods &dest close ;



__________Finding & using available ODS styles__________
ods html file='test.html' style=default ;
Proc print data=sashelp.class ;
run ;
ods html close ;
proc template ;
  list styles ;
run ;



__________Changing attributes in Proc Tabulate__________
data;
  input region $ citysize $ pop product $ saletype $
        quantity amount;
  datalines;
 NC S   25000 A100 R 150   3750.00
 NE S   37000 A100 R 200   5000.00
 SO S   48000 A100 R 410  10250.00
 WE S   32000 A100 R 180   4500.00
 NC M  125000 A100 R 350   8750.00
 NE M  237000 A100 R 600  15000.00
 SO M  348000 A100 R 710  17750.00
 WE M  432000 A100 R 780  19500.00
 NE L  837000 A100 R 800  20000.00
 SO L  748000 A100 R 760  19000.00
 WE L  932000 A100 R 880  22000.00
 NC S   25000 A100 W 150   3000.00
 NE S   37000 A100 W 200   4000.00
 WE S   32000 A100 W 180   3600.00
 NC M  125000 A100 W 350   7000.00
 NE M  237000 A100 W 600  12000.00
 SO M  348000 A100 W 710  14200.00
 WE M  432000 A100 W 780  15600.00
 NC L  625000 A100 W 750  15000.00
 NE L  837000 A100 W 800  16000.00
 SO L  748000 A100 W 760  15200.00
 WE L  932000 A100 W 880  17600.00
 NC S   25000 A200 R 165   4125.00
 NE S   37000 A200 R 215   5375.00
 SO S   48000 A200 R 425  10425.00
 WE S   32000 A200 R 195   4875.00
 NC M  125000 A200 R 365   9125.00
 NE M  237000 A200 R 615  15375.00
 SO M  348000 A200 R 725  19125.00
 WE M  432000 A200 R 795  19875.00
 NE L  837000 A200 R 815  20375.00
 SO L  748000 A200 R 775  19375.00
 WE L  932000 A200 R 895  22375.00
 NC S   25000 A200 W 165   3300.00
 NE S   37000 A200 W 215   4300.00
 WE S   32000 A200 W 195   3900.00
 NC M  125000 A200 W 365   7300.00
 NE M  237000 A200 W 615  12300.00
 SO M  348000 A200 W 725  14500.00
 WE M  432000 A200 W 795  15900.00
 NC L  625000 A200 W 765  15300.00
 NE L  837000 A200 W 815  16300.00
 SO L  748000 A200 W 775  15500.00
 WE L  932000 A200 W 895  17900.00
 NC S   25000 A300 R 157   3925.00
 NE S   37000 A300 R 208   5200.00
 SO S   48000 A300 R 419  10475.00
 WE S   32000 A300 R 186   4650.00
 NC M  125000 A300 R 351   8725.00
 NE M  237000 A300 R 610  15250.00
 SO M  348000 A300 R 714  17850.00
 WE M  432000 A300 R 785  19625.00
 NE L  837000 A300 R 806  20150.00
 SO L  748000 A300 R 768  19200.00
 WE L  932000 A300 R 880  22000.00
 NC S   25000 A300 W 157   3140.00
 NE S   37000 A300 W 208   4160.00
 WE S   32000 A300 W 186   3720.00
 NC M  125000 A300 W 351   7020.00
 NE M  237000 A300 W 610  12200.00
 SO M  348000 A300 W 714  14280.00
 WE M  432000 A300 W 785  15700.00
 NC L  625000 A300 W 757  15140.00
 NE L  837000 A300 W 806  16120.00
 SO L  748000 A300 W 768  15360.00
 WE L  932000 A300 W 880  17600.00
 ;
run;
proc format;
  value $salefmt 'R'='Retail'
                 'W'='Wholesale';
  value $salecol 'R'='red'
                 'W'='yellow';
  value $regcol  'NC'='CX00C400'
                 'NE'='white'
                 'SO'='CX00C400'
                 'WE'='white';
  value cellcol  0-40000      = 'blue'
                 40001-90000  = 'purple'
                 other        = 'brown';
run;
ods html ;
proc tabulate s={foreground=green}; 
  class region citysize saletype            / s={foreground=blue};
  classlev region citysize saletype         / s={foreground=yellow};
  var quantity amount                       / s={foreground=black};
  keyword all sum                           / s={foreground=white};
  format saletype $salefmt.;
  label region="Region" citysize="Citysize" saletype="Saletype";
  label quantity="Quantity" amount="Amount";
  keylabel all="Total";
  table all={label = "All Products" s={foreground=orange}},
       (region all)*(citysize all*{s={foreground=#002288}}),
       (saletype all)*(quantity*f=COMMA6. amount*f=dollar10.) /
          s={background=red}
          misstext={label="Missing" s={foreground=brown}}
          box={label="Region by Citysize by Saletype"
               s={foreground=purple}};
run;
ods html close ;



__________Changing the look & feel of a Proc Report__________
proc report nowd
            style(REPORT)={background=red} style(HEADER)={foreground=blue font_weight=bold}
            style(COLUMN)={foreground=green};
   column Region citysize saletype,(quantity amount) comments;
   define region / group 'Region' style(COLUMN)={foreground=yellow  font_weight=bold};
   define citysize / group 'Citysize' style(COLUMN)={foreground=yellow font_weight=bold};
   define saletype / across 'Saletype' format=$salefmt. style(COLUMN)={foreground=yellow};
   define quantity / sum 'Quantity' format=comma6. style(HEADER)={foreground=blue};
   define amount / sum 'Amount' format=dollar10. style(HEADER)={foreground=black};
   define comments / 'Comments' computed style(HEADER)={foreground=white};

   compute before _page_ / style={background=#005585 foreground=white} LEFT;
   line 'Retail and Wholesale Amounts per Region';
   endcomp;


   break after region / summarize style(SUMMARY)={foreground=#002288 font_weight=bold};

   compute after region / style(LINES)={background=#B0B0B0};
   length txt $35;
   length lr $5.;

   lr = region;

   if _C4_ > 140000 then
      txt = "Well Done!";
   else if _C4_ < 100000 then
      txt = "Sales Need Improvement";
   else
      txt = "Keep up the Good Work";
   line lr $3. "Region -- " txt $35.;

   region = "TOTAL";

   endcomp;

   rbreak after / summarize style(SUMMARY)={foreground=#008888 font_weight=bold};

   compute after / style(LINES)={background=orange foreground=black};
   line '';
   endcomp;




        /*------------------------------------------------------------*/
        /*-- These statements are an example of how you can use     --*/
        /*-- PROC REPORTS language to set attributes of cells in    --*/
        /*-- your report based on the values of the data...         --*/
        /*------------------------------------------------------------*/

   compute comments /character length=78;
   if _C4_ = . then
      do;
         comments = "Retail amount is missing.";
         call define(_COL_,"STYLE","style(CALLDEF)={background=pink foreground=black}");
         call define('_C4_',"STYLE","style(CALLDEF)={background=pink foreground=black}");
      end;

   else if _C6_ = . then
      do;
         comments = "Wholesale amount is missing.";
         call define(_COL_,"STYLE","style={background=pink foreground=black}");
         call define('_C6_',"STYLE","style={background=pink foreground=black}");
         end;

   else if _C4_ < _C6_ then
      do;
         comments = "Wholesale amount greater than retail. Needs inspection";
         call define(_COL_,"STYLE","style={background=purple foreground=white}");
      end;

   else
      comments="";

   endcomp;


run;



__________ODS:  Expanding your tagsets__________
5    ods markup tagset=html4 file='test.html' ;
WARNING: MARKUP is experimental in this release.
NOTE: Writing MARKUP file: test.html
6    proc means data=sashelp.class nway ;
7    run ;

NOTE: There were 19 observations read from the data set SASHELP.CLASS.
NOTE: PROCEDURE MEANS used:
      real time           0.05 seconds
      cpu time            0.01 seconds


ods markup close ;



__________Making a template to add a graphic__________
filename gsffile "test.jpg";
goptions gsfname=gsffile gsfmode=replace device=jpeg 
         hsize=9cm vsize=6cm;
proc gplot data=sashelp.class;
 plot height*weight=sex;
run;

proc template;
  define style myRTF / store=work.templates;
    parent=styles.rtf;
    style table from table/
      preimage="test.jpg";
  end;
run;

ods path (prepend) work.templates;
ods rtf file="test.rtf" style=myRTF;
proc print data=sashelp.class;
run;
ods rtf close;



__________Write to many ODS destinations at once__________
ods html    file='c:\1.htm' ;
ods rtf     file='c:\2.rtf' ;
ods pdf     file='c:\3.pdf' ;
ods listing ;
proc print data=sashelp.class ;
run ;
ods _all_ close ;
ods html(x)     file='c:\1.html' ;
ods html(1)     file='c:\2.html' ;
ods html(id=1)  file='c:\3.html' ;
ods html(sales) file='c:\4.html' ;
proc print data=sashelp.class ;
run ;
ods _all_ close ;



__________Exporting to EXCEL using ODS__________
Ods csv file='name.csv' ;
Ods csvall file='name2.csv' ; 
Ods html file='name.xls' ;
Proc print data=sashelp.class ;
Run ;
Ods _all_ close ;
Ods listing;



__________Horizontal Hi-Lo Chart__________ 
goptions reset=all ;
axis1 major=none minor=none label=none value=none;
axis2 value=(angle=90) label=none;
axis3 value=(angle=90);
symbol1 i=none;
symbol2 i=hilot;
proc gplot data=sasuser.houses;
   plot price*style=1 / vaxis=axis1 haxis=axis2;
   plot2 price*style=12 / vaxis=axis3;
run;
quit;



__________Getting the right special character in a graph__________
goptions reset=all;
GOPTIONS device=cgm gsfmode=replace gsfname=graph ;
filename graph "c:\test.cgm";

*---------------------------------------------;
*** This *does not* produce my plus/minus sign ***;
TITLE j=c "Intent-to-Treat, Survivial ± 1.5" ;
proc gchart data=sashelp.class ;
  vbar sex ;
run ;

*---------------------------------------------;
*** This *does* produce my plus/minus sign ***;
TITLE f=hwcgm005 j=c "Intent-to-Treat, Survivial ± 1.5" ;
proc gchart data=sashelp.class ;
  vbar sex ;
run ;



__________Hardware vs. Software fonts in graphs__________
filename sw 'c:\software font.png' ; * file to save graph using software font ;
filename hw 'c:\hardware font.png' ; * file to save graph using hardware font ;
goptions reset=all gsfname=sw dev=png xmax=6 ymax=4;
proc gchart data=sashelp.class;
vbar sex / sumvar=height ;
run;
* produce second graph using the Arial Font with text height set to 6% of total ;
goptions gsfname=hw ftext='Arial' htext=6pct ;
vbar sex / sumvar=height ;
run;
quit;



__________Graph & table in a Word document__________
goptions reset=all device=jpeg ;
Ods rtf file='gt.rtf' startpage=no ;
proc gchart data=sashelp.class ;
  vbar3d age;
run;
proc print data=sashelp.class ;
run;
ods rtf close ;



__________Animated GIFs__________
ods listing ;
filename anim 'c:\anim.gif' ;  /* file to create */
goptions device=gifanim        /* animated GIF driver */
         gsfname=anim          /* fileref to save file to */
         delay=100             /* 1/100s of a second between each image */
         gsfmode=replace       /* wipe over previous file */
         disposal=background ; /* when graph is erased background color returns */
proc gchart data=sashelp.prdsale ;
  vbar3d prodtype ;
run ;

goptions gsfmode=append ;      /* append the next graph to existing image */
proc gplot data=sashelp.class ;
  plot height*weight ;
run ;

goptions gepilog='3b'x;        /* write end-of-file character after next graph */
proc gchart data=sashelp.prdsale ;
  hbar3d country ;
run;



__________Adding space at start & end of cells in PROC REPORT__________
<TD ALIGN=CENTER bgcolor="#B0B0B0"><PRE>
<font  face="Arial, Helvetica, sans-serif" size="4" color="#0033AA"><b>   Name   </b></font></PRE>
</TD>



__________Area charts which can compare magnitudes of variables in categories__________
goptions reset=all device=activex ;
 
ods html file='c:\test.html' ;

data totals; 
   input Site $ Quarter $ Sales Salespersons; 
datalines; 
Lima    1 4043.97    4 
NY      1 4225.26   12 
Rome    1 16543.97   6 
Lima    2 3723.44    5 
NY      2 4595.07   18 
Rome    2 2558.29   10 
Lima    3 4437.96    8 
NY      3 5847.91   24 
Rome    3 3789.85   14 
Lima    4 6065.57   10 
NY      4 23388.51  26 
Rome    4 1509.08   16 
; 
proc gareabar data=totals;
   hbar site*salespersons /sumvar=sales
                           subgroup=quarter
                           rstat=SUM
                           wstat=PCT;
run ; quit ;
 
ods html close;



__________Make the right sized ActiveX for your resolution__________
* Define your preferred settings for various resolutions ;
%let qvga=xpixels=320 ypixels=240 ;
%let vga=xpixels=640  ypixels=480 ;
%let svga=xpixels=800 ypixels=600 ;
%let xga=xpixels=1024 ypixels=768 ;

* Select the resolution you want to use ;
%let resolution=vga;

ods html file='graph.htm' gpath='c:\' ;
* Choose the ACTIVEX driver with the appropriate resolution ;
goptions device=ActiveX &&&resolution ;
proc gchart data=sashelp.class ;
  vbar3d age / subgroup=sex ;
run ;
ods html close ;



__________Plot details of slices in a Pie Graph__________
In SAS 9 there is a new parameter in PROC GCHART that can be used when making PIE charts. It 
allows you to produce an inner pie overlay, showing major components that make up outer pie 
slices. This can be useful to get even more information into your chart. See the exods html 
file='c:\test.html' gpath='c:\' ;
goptions reset=all device=png
         xmax=10 ymax=6          /* make PNG bigger */
         ftext='Arial' htext=4pct /* use some nice looking text */;

data countries;
  input country $ 1-14 region $16-26 Machinery;
  datalines;
Taiwan         Asia       6.1
Korea          Asia       4.6
Malaysia       Asia       4.4
Malaysia2      Asia       3.9
Malaysia4      Asia       3.9
Malaysia5      Asia       1.5
U.S.           U.S.       39.1
Belgium        Europe     2.6
Germany        Europe     7.8
United Kingdom Europe     3.9
France         Europe     3.9
Santa          Antarctica 1.1
Bob            Antarctica 1.0
Cydonia        Mars       1.1
Tims House     Mars       1.0
China          Asia       10.2
Malaysia3      Asia       3.9
;
run;
proc gchart;
  pie region / angle=320
               slice=outside
               percent=inside
               value=none
               sumvar=Machinery
               detail_percent=best
               detail=country
               descending ;
run; quit;
ods html close ;
; quit;
ods html close ;



__________Changing resolution of graphs__________
%macro testres(x,y,dpi) ;
 * x   ... number of inches across graphic ;
 * y   ... number of inches across graphic ;
 * dpi ... resolution in dots per inch ;
  filename out "c:\test&dpi..png" ;
  goptions reset=all                  /* reset everything first */
           dev=png                    /* driver to use */
     	     xmax=&x in
           ymax=&y in
   	     xpixels=%sysevalf(&x*&dpi)
           ypixels=%sysevalf(&y*&dpi)
           ftext="SAS Monospace"      /* choose a nice font */
           htext=3 pct                /* make font a good size */
           gsfname=out                /* where to save graphic */ ;
  proc gchart data=sashelp.class ;
    hbar3d age / discrete ;
  run ; quit ;
%mend testres ;
%testres(6,4,600) ;
%testres(6,4,50) ;



__________Putting interactive graphs on web pages__________
ods html file='c:\active.html' ;
goptions reset=all device=activex ;
proc gchart data=sashelp.prdsale ;
  vbar3d country / group=region subgroup=prodtype sumvar=actual ;
run ; quit ;
ods html close ;

ods html file='c:\java.html' ;
goptions reset=all device=java ;
proc gchart data=sashelp.prdsale ;
  vbar3d country / group=region subgroup=prodtype sumvar=actual ;
run ; quit ;
ods html close ;



__________Using flyover text in PROC REPORT__________
ods html3 file='c:\test.html' ;
data class ;
  retain fmtname '$full' ;
  length first last $ 20 sex $ 1 age 4 ;
  input first last sex age ;
  label=trim(first)||' '||last ;
cards ;
fred flintstone M 21
wilma flintstone F 19
ronald reagan M 99
barney rubble M 33
john thomas M 50 
jenny thompson F 4
;
run ;
* Make a format to show full name when given first name ;
proc format cntlin=class(rename=(first=start)) ;
run ;
proc report data=class nowd ;
  columns first sex age ;
  define sex / order ;
  define age / order ;
  compute first ;
   * create flover text which will be full name, based on first name ;
    call define(_col_, "style","style=[flyover="||quote(trim(put(first,$full.)))||"]");
  endcomp ;
run ;
ods html3 close ;



__________Useful symbols in ODS__________
ods html file='test.html' ;
data useful_symbols ;
Copyright='01'x ;
RegisteredTM='02'x;
Trademark='04'x;
run ;
proc print ;
run;
ods html close ;



__________Make combined Bar chart and plot the easy way__________
319  goptions reset=all device=activex ;
NOTE: Some of your options or statements may not be supported with the Activex or Java series of devices.  Graph defaults for these
      drivers may be different from other SAS/GRAPH device drivers.  For further information, please contact Technical Support.
320
321  ods html file='c:\test.html' ;
NOTE: Writing HTML Body file: c:\test.html
322
323  proc gbarline data=sashelp.prdsale;
324    bar product / sumvar=actual ;
325    plot / sumvar=predict ;
326  run;

327  quit;

NOTE: There were 1440 observations read from the data set SASHELP.PRDSALE.
NOTE: PROCEDURE GBARLINE used (Total process time):
      real time           0.61 seconds
      cpu time            0.15 seconds


328
ods html close;



__________Changing procedure titles in ODS__________
ods html body='c:\test.html'
         contents='c:\contents.html'
         frame='c:\frame.html' ;
ods noptitle ; * turn off procedure title in body ;
ods proclabel ' ' ; * turn off procedure title in contents ;
title 'Sales frequencies' ;
proc freq data=sashelp.prdsale ; 
  table country ; 
run ;
ods html close ;



__________Using ODS Markup to create datastep code__________
proc template;
 define tagset Tagsets.datastep;
  notes "This is the Datastep definition";
  define event table;
   start:
    put "data;" NL;
   finish:
    put "run;" NL;
  end;
  define event row;
   finish:
    put NL;
  end;
  define event table_head;
   start:
    put "input ";
   finish:
    put ";";
  end;
  define event table_body;
   start:
    put "datalines;" NL;
  end;
  define event header;
   start:
    trigger data;
   finish:
    trigger data;
  end;
  define event data;
   start:
    put " " VALUE;
  end;
 end;
run;

ods markup type=datastep 
           file="b_out.sas" ;
proc print data=sashelp.class ;
run ;
ods markup close ;
data;
input  Obs Name Sex Age Height Weight
;datalines;
  1 Alfred M 14 69.0 112.5
  2 Alice F 13 56.5  84.0
  3 Barbara F 13 65.3  98.0
  4 Carol F 14 62.8 102.5
  5 Henry M 14 63.5 102.5
  6 James M 12 57.3  83.0
  7 Jane F 12 59.8  84.5
  8 Janet F 15 62.5 112.5
  9 Jeffrey M 13 62.5  84.0
 10 John M 12 59.0  99.5
 11 Joyce F 11 51.3  50.5
 12 Judy F 14 64.3  90.0
 13 Louise F 12 56.3  77.0
 14 Mary F 15 66.5 112.0
 15 Philip M 16 72.0 150.0
 16 Robert M 12 64.8 128.0
 17 Ronald M 15 67.0 133.0
 18 Thomas M 11 57.5  85.0
 19 William M 15 66.5 112.0
run;




