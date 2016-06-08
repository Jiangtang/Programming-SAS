/*<pre><b>
/ Program   : subspace
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 27 November 2002
/ Contact   : rolandberry@hotmail.com
/ Purpose   : To replace a special character in a flat file with a space.
/ SubMacros : none
/ Notes     : THIS MACRO ISSUES WINDOWS commands. If you want to run this on a
/             different platform then you will have to change the commands. Where
/             you change it is clearly indicated in the code.
/ Usage     : %subspace(myfile.lst)
/ 
/================================================================================
/ PARAMETERS:
/-------name------- -------------------------description-------------------------
/ filename          (pos) Must be a file name and not a fileref.
/ subspace='FE'x    Special character to replace with a space.
/================================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description-------------------------
/ rrb  22Jul03         Version 2.0 uses _file_ and _infile_
/================================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/===============================================================================*/

%macro subspace(filename,subspace='FE'x);
%local tempname opts;
%let opts=%sysfunc(getoption(xwait,keyword)) %sysfunc(getoption(xsync,keyword));
%let filename=%sysfunc(compress(&filename,%str(%'%")));
%let tempname=%scan(&filename,1,.).tmp;
options noxwait xsync;

*- WINDOWS COMMAND. CHANGE FOR DIFFERENT OPERATING SYSTEM. -;
x "rename &filename &tempname";

data _null_;
  infile "&tempname";
  file "&filename";
  input;
  _file_=trim(translate(_infile_,' ',&subspace));
  put;
run;


*- WINDOWS COMMAND. CHANGE FOR DIFFERENT OPERATING SYSTEM. -;
x "erase &tempname";

options &opts;
%mend;
