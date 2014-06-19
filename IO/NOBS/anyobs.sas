/*******************************************************************************
Program    :
Parameters :
SAS Version: 9.2
Purpose    :
Developer  :
Modified   :

Notes      :

*******************************************************************************/

%macro anyobs(data);
%*http://www2.sas.com/proceedings/sugi26/p095-26.pdf;
%* This macro returns 1 if there are any observations in a data set,
0 if the data set is empty, or . if the data set does not exist or
cannot be opened.
- The macro first opens the data set. An error message is displayed
and processing stops if the dataset cannot be opened.
- It next checks the values of the data set attributes
ANOBS (does SAS know how many observations there are?) and
WHSTMT (is a where statement in effect?).
- If SAS knows the number of observations and there is no
where clause, the data set attribute ANY is used to determine
whether there are any observations.
- If SAS does not know the number of observations (a view or transport
data set) or if a where clause is in effect, the macro tries to read
the first observation. If a record is found, the macro returns 1,
otherwise it returns 0.
This macro requires the data set information functions,
which are available in SAS version 6.09 and greater. ;
%* By Jack Hamilton, First Health, January 2001. ;
%local dsid anobs whstmt hasobs rc;
%let DSID = %sysfunc(open(&DATA., IS));
%if &DSID = 0 %then
%do;
%put %sysfunc(sysmsg());
%let hasobs = .;
%goto mexit;
%end;
%else
%do;
%let anobs = %sysfunc(attrn(&DSID, ANOBS));
%let whstmt = %sysfunc(attrn(&DSID, WHSTMT));
%end;
%if &anobs=1& &whstmt = 0 %then
%do;
%let hasobs = %sysfunc(attrn(&DSID, ANY));
%if &hasobs = -1 %then
%let hasobs = 0;
%end;
%else
%do;
%if %sysfunc(getoption(msglevel)) = I %then
%put INFO: First observation in "&DATA." must be fetched.;
%let hasobs = 0;
%if %sysfunc(fetch(&DSID)) = 0 %then
%let hasobs = 1;
%end;
%let rc = %sysfunc(close(&DSID));
%MEXIT:
&HASOBS.
%mend anyobs;

