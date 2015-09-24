dm 'log; clear; output; clear';
*ODS_Style_Output.sas -- program to create examples of all SAS ODS styles;
*modified by Elizabeth A. Swoope, Louisiana State University;
*last modified 9/23/2011;

*source of original program lost;
*found at sastips.com, which is no longer a SAS web site;

*create a folder for the files, then put the folder name in the first call execute statement
 if you use a folder name that's different from the one in the statement;

filename list catalog 'work.temp.temp.source' ;

proc printto print=list new ;
run;

ODS listing;

proc template ;
     list styles ;
run ;

ODS listing close;

proc printto ;
run;

data _null_ ;  
     length style $ 17 ; 
     infile list missover ;
     input @'Styles.' style ;
     if style>' ' ;
	 
	 * create a folder for the files, then change the drive/folder below;

     call execute('ods html file="c:\ODS_test\'||strip(style)||'.html" style='||style||';') ;
     call execute('title "'||style||'";') ;
     call execute('proc means data=sashelp.class maxdec=2; run ;') ;
     call execute('ods html close'||';') ;
run ;
