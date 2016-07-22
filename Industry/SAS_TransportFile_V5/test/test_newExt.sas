
/* Test case */
/* Build a format whose name is greater than 8 characters. */

proc format;
   value testfmtnamethatislongerthaneight 100='numeric has been formatted';
run;

/* Build a data set with > 8-character data set name, variable name, and > 40-character label */

data test.Thisisalongdatasetname;
   varnamegreaterthan8=100;
   label varnamegreaterthan8='jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj';
/* Assign permanent format */
   format varnamegreaterthan8 testfmtnamethatislongerthaneight.;
run;


/* Use the %LOC2XPT macro to create a V9 transport file */

/* libref= points to a directory containing datasets specified in memlist=     */
/* filespec= specifies path and name of transport file we are creating         */
/*    name and extension can be anything but we are using trans.v9xpt -        */
/*    to remind us it contains a data set with features specific to v9 and     */
/*    we should use a SAS 9 session to read it.                                */

%loc2xpt(libref=test,memlist=Thisisalongdatasetname,filespec='a:\trans.v9xpt')

/* Use the %XPT2LOC to convert V9 transport file to a SAS data set. */
/* Note that data set features are retained in the PROC COMPARE output. */

/* libref= points to target folder where data sets will be stored              */
/* filespec= points to existing transport file                                 */

%xpt2loc(libref=work, memlist=Thisisalongdatasetname, filespec='a:\trans.v9xpt')

/* Compare data sets before and after the transport operations */

title 'Compare before and after data set attributes';
proc compare base=test.Thisisalongdatasetname compare=work.Thisisalongdatasetname;
run;






