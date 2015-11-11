*-<pre><b> 
*- Note that this is a WINDOWS autoexec member meant to be stored at -;
*- a high level location such as the folder that contains the sas    -;
*- executable or the C: drive. You can have simpler autoexec members -;
*- stored in the study programs folders but what they SHOULD ALWAYS  -;
*- DO is assign all needed macro directories in the correct order if -;
*- you are initiating sas from the Clinical reporting area. You      -;
*- should NOT allocate any study libraries in this member.           -;

*- these options are always needed for Spectre (center optional) -;
options noovp nodate nonumber center xsync noxwait;

*- assign spectre macros to sasautos -;
options sasautos=("C:\spectre\macros" SASAUTOS);

%*- Allocate study reporting macros if in the reporting area -;
%*- (second part of the path name will be "pharma" if so).   -; 
%macro allocmac;
  %local path bitpath macros3 macros4 macros5 macros6 macros7;
  %let path=%qreadpipe(cd);
  %if "%scan(&path,2,\)"="pharma" %then %do;
    %let bitpath=C:\pharma;
    %*- CLIENT MACROS -;
    %if %length(%scan(&path,3,\)) %then %do;
      %let bitpath=&bitpath.\%scan(&path,3,\);
      %let macros3="&bitpath.\macros";
    %end;
    %*- OFFICE MACROS -;
    %if %length(%scan(&path,4,\)) %then %do;
      %let bitpath=&bitpath.\%scan(&path,4,\);
      %let macros4="&bitpath.\macros";
    %end;
    %*- DRUG MACROS -;
    %if %length(%scan(&path,5,\)) %then %do;
      %let bitpath=&bitpath.\%scan(&path,5,\);
      %let macros5="&bitpath.\macros";
    %end;
    %*- PROTOCOL MACROS -;
    %if %length(%scan(&path,6,\)) %then %do;
      %let bitpath=&bitpath.\%scan(&path,6,\);
      %let macros6="&bitpath.\macros";
    %end;
    %*- INCREMENT MACROS -;
    %if %length(%scan(&path,7,\)) %then %do;
      %let bitpath=&bitpath.\%scan(&path,7,\);
      %let macros7="&bitpath.\macros";
    %end;
    %*- Reset sasautos to include extra macro libraries with -;
    %*- the lowest level macros defined first in the path.   -;
    options sasautos=(&macros7 &macros6 &macros5 &macros4 &macros3 
    "C:\spectre\macros" SASAUTOS);
  %end;
%mend allocmac;
%allocmac;

%*- Put an entry in the log so the user has a record -;
%*- of what macros are on their sasautos path and    -;
%*- what order they will be called in.               -;
%put NOTE: sasautos=%sysfunc(getoption(sasautos));
