/*<pre><b>
/ Program   : mkdir.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 19-Jun-2014
/ Purpose   : To create a directory
/ SubMacros : none
/ Notes     : You might have to surround the path with %nrbquote() or mask
/             special characters another way.
/ Usage     : %mkdir(full-path-name);
/             %mkdir(full-path-name,remote);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ path              (pos) Full path of directory to create (quoted or unquoted)
/ remote            (pos) If not null then create the directory inside an
/                   RSUBMIT block in a current remote session.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19Jun14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: mkdir v1.0;

%macro mkdir(path,remote);
  %let path=%sysfunc(dequote(&path));
  %if %length(&remote) %then %do;
    %syslput rempath=&path;
    RSUBMIT;
      %put NOTE: (mkdir) Running remotely;
      %macro _mkdir;
        %local err;
        %let err=ERR%str(OR);
        %if %sysfunc(fileexist(&rempath)) %then
         %put NOTE: (mkdir) File &rempath already exists;
        %else %do;
          systask command "mkdir ""&rempath"" " wait 
                  taskname=_mkdir status=_mkdir;
          %if &sysrc>0 %then 
            %put &err: (mkdir) "mkdir" command could not be invoked;
          %else %if &_mkdir>0 %then
            %put &err: (mkdir) Failure to create "&rempath";
        %end;
      %mend _mkdir;
      %_mkdir;
      proc catalog catalog=work.sasmacr entrytype=macro;
        delete _mkdir;
      quit;
    ENDRSUBMIT;
  %end;
  %else %do;
    %macro _mkdir;
      %local err;
      %let err=ERR%str(OR);
      %if %sysfunc(fileexist(&path)) %then
       %put NOTE: (mkdir) File &path already exists;
      %else %do;
        systask command "mkdir ""&path"" " wait 
                taskname=_mkdir status=_mkdir;
        %if &sysrc>0 %then 
          %put &err: (mkdir) "mkdir" command could not be invoked;
        %else %if &_mkdir>0 %then
          %put &err: (mkdir) Failure to create "&path";
      %end;
    %mend _mkdir;
    %_mkdir;
    proc catalog catalog=work.sasmacr entrytype=macro;
      delete _mkdir;
    quit;
  %end;
%mend mkdir;
