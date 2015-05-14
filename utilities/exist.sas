/*
http://www.sascommunity.org/wiki/Macro_Exist
*/
%macro exist
      (data    = /*    exist */
      ,catalog = /*   cexist */
      ,filename= /*fileexist */
      ,fileref = /*   fexist */
      ,libref  = /*   libref */
      ,testing = 0
      )
/des = 'demo: exist(any object)?'
;
%let testing = %eval(not(0 eq &testing)
     or %sysfunc(getoption(mprint)) eq MPRINT);
 
%**  description: assertions;
%**  purpose    : if fail then exit;
%if %length(&catalog) %then
	  %let return_code = %sysfunc(cexist(&catalog));
%else
%if %length(&data) %then
	  %let return_code = %sysfunc(exist(&data));
%else
%if %length(&filename) %then
	  %let return_code = %sysfunc(fileexist(&filename));
%else
%if %length(&fileref) %then
	  %let return_code = %sysfunc(fexist(&fileref));
%else
%if %length(&libref) %then %do;
    %*The LIBREF function returns 0
          if the libref has been assigned,
      or returns a nonzero value
          if the libref has not been assigned.;
	  %let return_code = %eval(not %sysfunc(libref(&libref)));
    %end;
&return_code
%mend;

options mprint;
%let in_data = sashelp.class;
%put %exist(data=&in_data);
 
%let in_data = work.class;
%put %exist(data=&in_data);
 
%let in_filename= autoexec;
%put %exist(filename=&in_filename);
 
%let in_filename= autoexec.sas;
%put %exist(filename=&in_filename);
 
%let in_fileref = work;
%put %exist(fileref=&in_fileref);
 
%let in_fileref = project;
%put %exist(fileref=&in_fileref);
 
%let in_fileref = site_inc;
%put %exist(fileref=&in_fileref);
 
%let in_lib = work;
%put %exist(libref=&in_lib);
 
%let in_lib = workx;
%put %exist(libref=&in_lib);
 
%let in_lib = library;
%put %exist(libref=&in_lib);
 
%let in_fmtlib = library.formats;
%put %exist(catalog=&in_fmtlib);
 
%let in_fmtlib = work.formats;
%put %exist(catalog=&in_fmtlib);
 
proc format;value x 1='one';
run;
%let in_fmtlib = work.formats;
%put %exist(catalog=&in_fmtlib);
 
%let in_macrolib = work.sasmacr;
%put %exist(catalog=&in_macrolib);
 
%let lib_mac =
%sysfunc(ifc(%sysfunc(getoption(mstored)) eq MSTORED
            ,%nrstr(%sysfunc(getoption(sasmstore)))
            ,%nrstr(work)
        )   );
%put lib_mac=&lib_mac;
 
%let in_macrolib = &lib_mac..sasmacr;
%put %exist(catalog=&in_macrolib);
