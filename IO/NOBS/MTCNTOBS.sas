%macro MTCNTOBS(data=_last_);
%* This macro returns the number of observations in a data set,
or . if the data set does not exist or cannot be opened.
- It first opens the data set. An error message is returned
and processing stops if the dataset cannot be opened.
- It next checks the values of the data set attributes
ANOBS (does SAS know how many observations there are?) and
WHSTMT (is a where statement in effect?).
- If SAS knows the number of observations and there is no
where clause, the value of the data set attribute NLOBS
(number of logical observations) is returned.
- If SAS does not know the number of observations (perhaps
this is a view or transport data set) or if a where clause
is in effect, the macro iterates through the data set
in order to count the number of observations.
The value returned is a whole number if the data set exists,
or a period (the default missing value) if the data set
cannot be opened.
This macro requires the data set information functions,
which are available in SAS version 6.09 and greater. ;
%* By Jack Hamilton, First Health, January 2001. ;
%local dsid anobs whstmt counted rc;
%let DSID = %sysfunc(open(&DATA., IS));
%if &DSID = 0 %then
%do;
%put %sysfunc(sysmsg());
%let counted = .;
%goto mexit;
%end;
%else
%do;
%let anobs = %sysfunc(attrn(&DSID, ANOBS));
%let whstmt = %sysfunc(attrn(&DSID, WHSTMT));
%end;
%if &anobs=1& &whstmt = 0 %then
%let counted = %sysfunc(attrn(&DSID, NLOBS));
%else
%do;
%if %sysfunc(getoption(msglevel)) = I %then
%put INFO: Observations in "&DATA." must be counted by iteration.;
%let counted = 0;
%do %while (%sysfunc(fetch(&DSID)) = 0);
%let counted = %eval(&counted. + 1);
%end;
%end;
%let rc = %sysfunc(close(&DSID));
%MEXIT:
&COUNTED.
%mend MTCNTOBS;