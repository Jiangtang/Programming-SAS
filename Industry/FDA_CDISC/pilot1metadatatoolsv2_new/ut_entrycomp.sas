%macro ut_entrycomp(cat1=_default_,cat2=_default_,select=_default_,
 printdif=_default_,cat1label=_default_,cat2label=_default_,mode=_default_,
 out=_default_,compmeth=_default_,verbose=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME   : ut_entrycomp
TYPE                    : utility
DESCRIPTION             : Compares two SAS catalogs and reports the
                           differences
REQUIREMENTS            : https://sddchippewa.sas.com/webdav/lillyce/qa/general/
                           bums/mdmoddt/documentation/ut_entrycomp_rd.doc
SOFTWARE/VERSION#       : SAS/Version 8 and 9
INFRASTRUCTURE          : MS Windows, MVS
BROAD-USE MODULES       : ut_parmdef ut_logical ut_titlstrt ut_errmsg
                           ut_quote_token
INPUT                   : As defined by the CAT1 and CAT2 parameters
OUTPUT                  : As defined by the OUT parameter
                          One output file containing the differences
                           listing - the name of the file is in the title
                           of the entry status listing and follows the
                           naming convention of Compare.<cat1 libref>
                          Printed report in the SAS listing file
                          Temporary files created (not deleted when DEBUG
                           is true):
                           file containing contents of each catalog entry
                           file containing differences of each pair of
                            catalog entried from CAT1 and CAT2
VALIDATION LEVEL        : 6
REGULATORY STATUS       : GCP
TEMPORARY OBJECT PREFIX : _ec
--------------------------------------------------------------------------------
Parameters:
 Name     Type     Default Description and Valid Values
--------- -------- ------- -----------------------------------------------------
CAT1      required          2-level SAS name of catalog member libref.catalog
CAT2      required          2-level SAS name of catalog member libref.catalog
SELECT    optional          A list of catalog entries to compare.
                            If not specified all entries are compared
                            The entries should be specified as 2-level names
                            name.type e.g. resproj.source
CAT1LABEL optional &cat1   Label to use in titles when referring to CAT1
CAT2LABEL optional &cat2   Label to use in titles when referring to CAT2
PRINTDIF  required 1000     Maximum number of lines to print of the
                            differences between catalog entries when COMPMETH
                            is OS.
MODE      required LISTALL  LISTALL LISTBASE LISTCOMP
OUT       optional          Name of output data set written (one or two level
                            SAS data set name).  A null value indicates that
                            no output data set will be created.
COMPMETH  required os       Method to use when comparing catalog entry contents.
                             OS = use the operating system command
                                  MS windows uses fc
                                  MVS uses proc isrsupc (ispf comparison)
                                  unix uses diff
                                  SDD uses compmeth=proc (proc compare)
                             PROC = use proc compare
                             If running in SDD COMPMETH is forced to PROC.
VERBOSE   required 0        %ut_logical value specifying whether verbose mode
                            is on or off
DEBUG     required 0        %ut_logical value specifying whether debug mode
                            is on or off
--------------------------------------------------------------------------------
Usage Notes:

  This macro compares entries in catalog CAT1 with the entries in catalog CAT2.
  It reports entries in one catalog but not both as well as the entries in
  common (by name and type).  For the entries in common the content of the
  entries are compared to each other and a listing is generated of the 
  entries that are the same and that are not the same.  A flat file is 
  created listing all the differences in all the files.  The name of the flat 
  file is COMPARE.&CAT1 where &CAT1 is the catalog name of the CAT1
  parameter.  The format of this flat file depends on the operating system it
  is run on.  On windows the FC command is used.  On MVS the ISPF file 
  comparison is used.

  This macro compares the contents of catalog entry types only of
  source, program, scl and cbt - other types are binary files that cannot be
  compared.
--------------------------------------------------------------------------------
Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

  libname libref1 'path-name' access=readonly;
  libname libref2 'path-name' access=readonly;
  %ut_entrycomp(cat1=libref1.descriptions,cat2=libref2.descriptions)
--------------------------------------------------------------------------------
     Author &
Ver# Peer Reviewer    Request #        Broad-Use MODULE History Description
---- ---------------- ---------------- -----------------------------------------
1.0  Gregory Steffens BMRGCS07Jun2005A Original version of the broad-use module
1.1  Gregory Steffens BMRMSR21FEB2007A SAS version 9 migration
2.0  Gregory Steffens BMR              Added a linefeed prior to message
      Russ Newhouse                     Comparing catlogs cat1label and
                                        cat2label
                                       Print a message that further lines are
                                        not printed and where the full
                                        differences file can be found when
                                        PRINTDIF line is reached.
                                       Fixed problem with length of macro
                                        variable value exceeding 65k by 
                                        printing arrays same and notsame rather
                                        than creating a scaler variable with a
                                        a value of the full list of entry names.
                                       Changed put function call to use 
                                        format of 32.0 instead of 4.0
                                        to increase the maximum number of
                                        catalog entries.
                                       Added COMPMETH parameter
  **eoh************************************************************************/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%local nument i equal titlstrt compent compcat compsame
 catentry1 catentry2 parentdir first_unequal cat1path cat2path
 rc msg ls compent_infile xopts selectq unix sdd comprc2;
%ut_parmdef(cat1,_pdmacroname=ut_entrycomp,_pdrequired=1)
%ut_parmdef(cat1label,&cat1,_pdmacroname=ut_entrycomp,_pdrequired=0)
%ut_parmdef(cat2,_pdmacroname=ut_entrycomp,_pdrequired=1)
%ut_parmdef(cat2label,&cat2,_pdmacroname=ut_entrycomp,_pdrequired=0)
%ut_parmdef(select,_pdmacroname=ut_entrycomp,_pdrequired=0)
%ut_parmdef(printdif,1000,_pdmacroname=ut_entrycomp,_pdrequired=1)
%ut_parmdef(mode,listall,listall listbase listcomp LISTALL LISTBASE LISTCOMP,
 _pdmacroname=ut_entrycomp,_pdrequired=1)
%ut_parmdef(out,_pdmacroname=ut_entrycomp,_pdrequired=0)
%ut_parmdef(compmeth,os,os proc,_pdmacroname=ut_entrycomp,_pdrequired=1)
%ut_parmdef(verbose,0,_pdmacroname=ut_entrycomp,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=ut_entrycomp,_pdrequired=1)
%ut_logical(verbose)
%ut_logical(debug)
%let mode = %upcase(&mode);
%let compmeth = %sysfunc(lowcase(&compmeth));
%let ls = %sysfunc(getoption(linesize));
%if &sysscp = WIN %then %do;
  %let xopts = %sysfunc(getoption(xwait));
  %let xopts = &xopts %sysfunc(getoption(xmin));
  options noxwait xmin;
%end;
%if %bquote(%scan(&cat1,2,%str(.))) = %then %let cat1 = work.&cat1;
%if %bquote(%scan(&cat2,2,%str(.))) = %then %let cat2 = work.&cat2;
%if %bquote(%upcase(%scan(&cat1,1,%str(.)))) ^= WORK %then %let cat1path =
 %sysfunc(pathname(%scan(&cat1,1,%str(.)))) (%scan(&cat1,2,%str(.)));
%else %let cat1path = &cat1;
%if %bquote(%upcase(%scan(&cat2,1,%str(.)))) ^= WORK %then %let cat2path =
 %sysfunc(pathname(%scan(&cat2,1,%str(.)))) (%scan(&cat2,2,%str(.)));
%else %let cat2path = &cat2;
%let select = %upcase(&select);
%ut_quote_token(inmvar=select,outmvar=selectq,dlm=_default_,debug=&debug)
%ut_titlstrt
%if %bquote(&cat1label) = & %bquote(&cat2label) = %then %do;
  title&titlstrt "(ut_entrycomp) Comparing catalogs &cat1path and &cat2path";
%end;
%else %do;
  title&titlstrt "(ut_entrycomp) Comparing catalogs &cat1label and &cat2label";
%end;
%let sdd = 0;
%if &sysver ^= 8.2 %then %do;
  %if %symglobl(_sddusr_) | %symglobl(_sddprc_) | %symglobl(sddparms) %then
   %let sdd = 1;
%end;
%if %upcase(&sysscpl) = SUNOS | &sysscp = SUN 4 | &sysscp = SUN 64 |
 &sysscp = RS6000 | &sysscp = ALXOSF | &sysscp = HP 300 | &sysscp = HP 800 |
 &sysscp = LINUX  | &sysscp = RS6000 | &sysscp = SUN 3  | &sysscp = ALXOSF %then
 %let unix = 1;
%else %let unix = 0;
%if &sdd | (&compmeth ^= os & &compmeth ^= proc) %then %let compmeth = proc;
%if &compmeth = os %then %do;
  %if &sysscp = WIN %then %do;
    %if %sysfunc(fileexist(d:\)) %then %let parentdir = d:;
    %else %if %sysfunc(fileexist(c:\)) %then %let parentdir = c:;
    %else %if %sysfunc(fileexist(h:\)) %then %let parentdir = h:;
    %else %let parentdir = %sysfunc(sysget(temp));
    %let parentdir = &parentdir\ut_entrycomp\%sysfunc(translate(%sysfunc(datetime(),datetime16.),_,:));
    %sysexec mkdir &parentdir\;
    %ut_errmsg(msg=parentdir=&parentdir sysrc=&sysrc,macroname=ut_entrycomp,
     type=note,print=0)
  %end;
  %else %if &unix %then %do;
    %let parentdir = ~/ut_entrycomp/%sysfunc(translate(%sysfunc(datetime(),datetime16.),_,:));
    %sysexec mkdir -p &parentdir/;
    %ut_errmsg(msg=parentdir=&parentdir mkdir sysrc=&sysrc,macroname=ut_entrycomp,
     type=note,print=0,macroname=ut_entrycomp)
    %if &sysrc ^= 0 %then %do;
      %ut_errmsg(msg=Could not create directory &parentdir.
       type=warning,print=0,ut_entrycomp);
    %end;
  %end;
%end;
*==============================================================================;
* Create data sets describing catalog entry names and types in CAT1 and CAT2;
*==============================================================================;
proc catalog catalog = &cat1;
  contents out=_ecatcont1;
run; quit;
data _ecatcont1;
  set _ecatcont1;
  name = upcase(name);
  type = upcase(type);
run;
proc sort data = _ecatcont1;
  by name type;
run;
proc catalog catalog = &cat2;
  contents out=_ecatcont2;
run; quit;
data _ecatcont2;
  set _ecatcont2;
  name = upcase(name);
  type = upcase(type);
run;
proc sort data = _ecatcont2;
  by name type;
run;
*==============================================================================;
* Merge catalog description data sets to see what entries exist in both;
* If user did not select entries select all entries in both catalogs;
* and put entries in macro array;
*==============================================================================;
%let nument = 0;
data _ecnotn1 (keep=name type libname2 memname2 desc2 date2 crdate2 moddate2)
     _ecnotn2 (keep=name type libname  memname  desc  date  crdate  moddate)
     _ecnboth;

  if eof then call symput('nument',trim(left(put(max(nument,0),32.0))));

  merge _ecatcont1 (in=a)
        _ecatcont2 (in=b rename = (libname=libname2 memname=memname2 desc=desc2
                    date=date2 crdate=crdate2 moddate=moddate2))
   end = eof;
  by name type;
  %if %nrbquote(&select) ^= %then %do;
    length nametype $ 65;
    nametype = trim(left(name)) || '.' || trim(left(type));
    if nametype in ( %unquote(&selectq) );
    drop nametype;
  %end;
  if ^ a then output _ecnotn1;
  else if ^ b then output _ecnotn2;
  if a & b;
  if desc ^= desc2 then descdiff = '1';
  if upcase(type) in ('SOURCE' 'PROGRAM' 'SCL' 'CBT') then do;
    nument + 1;
    call symput('entry' || trim(left(put(nument,5.0))),
     trim(left(name)) || '.' || trim(left(type)));
  end;
  drop nument;
  output _ecnboth;
  retain nument 0;
run;
*==============================================================================;
* Report entries in one catalog but not both;
*  and the entries in both when DEBUG is true;
*==============================================================================;
%if &mode = LISTALL | &mode = LISTBASE %then %do;
  proc print data = _ecnotn1 n width=minimum;
    id name type;
    var crdate2 moddate2 desc2;
    title%eval(&titlstrt+1)
     "(ut_entrycomp) Entries in &cat2label but not in &cat1label";
  run;
%end;
%if &mode = LISTALL | &mode = LISTCOMP %then %do;
  proc print data = _ecnotn2 n width=minimum;
    id name type;
    var crdate moddate desc;
    title%eval(&titlstrt+1)
     "(ut_entrycomp) Entries in &cat1label but not &cat2label";
  run;
%end;
%if &debug %then %do;
  proc print data = _ecnboth n;
    by libname memname;
    id name;
    title%eval(&titlstrt+1)
     "(ut_entrycomp) Entries in both catalogs &cat1label and &cat2label";
  run;
%end;
title%eval(&titlstrt+1);
%ut_errmsg(msg=&nument Entries being compared between &cat1label and &cat2label,
 macroname=ut_entrycomp,type=note,print=0)
*==============================================================================;
* Compare entry contents between catalogs;
*==============================================================================;
%if &nument > 0 %then %do;
  %if &compmeth = os %then %do;
    %*-------------------------------------------------------------------------;
    %* Assign macro variables COMPCAT COMPENT and COMPENT_INFILE;
    %* Delete the COMPCAT file if it already exists;
    %* Assign _ECOMPCA fileref to point to file named in COMPCAT;
    %*-------------------------------------------------------------------------;
    %if &sysscp = WIN %then %do;
      %let compcat = &parentdir\compare.%scan(&cat1,1,%str(.));
      %if %sysfunc(fileexist(&compcat)) %then %do;
        x erase &compcat;
        %ut_errmsg(msg=Comparison results file already exists - erase sysrc=&sysrc
         &compcat,macroname=ut_entrycomp,type=warning,print=0)
      %end;
      filename _ecompca "&compcat";
      %let compent = &parentdir\compare.listing;
      %let compent_infile = "&compent";
    %end;
    %else %if &sysscp = OS %then %do;
      %let compcat=&sysuserid..compare.%substr(%sysfunc(compress(%scan(&cat1,1,
       %str(.)),%str(_)))%str(       ),1,8);
      %if %sysfunc(fileexist(&compcat)) %then %do;
        x "delete '&compcat'";
        %ut_errmsg(msg=Comparison results file already exists-delete sysrc=&sysrc
         &compcat,macroname=ut_entrycomp,type=warning,print=0)
      %end;

      filename _ecompca "&compcat" disp=(mod,catlg) space=(trk,(4,4));

      %let compent = &sysuserid..compare.listing;
      %let compent_infile = outdd;
    %end;
    %else %if &unix %then %do;
      %let compcat = &parentdir/compare.%scan(&cat1,1,%str(.));
      %if %sysfunc(fileexist(&compcat)) %then %do;
        x rm &compcat;
        %ut_errmsg(msg=Comparison results file already exists - rm sysrc=&sysrc
         &compcat,macroname=ut_entrycomp,type=warning,print=0)
      %end;
      filename _ecompca "&compcat";
      %let compent = &parentdir/compare.listing;
      %let compent_infile = "&compent";
    %end;
  %end;
  %let first_unequal = 1;
  %do i = 1 %to &nument;
    *--------------------------------------------------------------------------;
    %bquote(* &i Processing Entry &&entry&i;)
    *--------------------------------------------------------------------------;
    %local stat&i;
    %if &compmeth = os %then %do;
      *------------------------------------------------------------------------;
      * Assign macro variables CATENTRY1 CATENTRY2 with current entry file names;
      * Assign filenames _ECOUT1 to CATENTRY1 and _ECOUT2 to CATENTRY2;
      * Write catalog entries from _ECAT1 to _ECOUT1 and _ECAT2 to _ECOUT2;
      *------------------------------------------------------------------------;
      %if &sysscp = WIN %then %do;
        %let catentry1  = &parentdir\%scan(&&entry&i,1,str(.)).entcmp1;
        %let catentry2  = &parentdir\%scan(&&entry&i,1,str(.)).entcmp2;
        filename _ecout1 "&catentry1";
        filename _ecout2 "&catentry2";
      %end;
      %else %if &sysscp = OS %then %do;
        %let catentry1 =
         &sysuserid..entcmp1.%substr(%sysfunc(compress(%scan(&&entry&i,1,
          %str(.)),%str(_)))%str(       ),1,8);
        %let catentry2 =
         &sysuserid..entcmp2.%substr(%sysfunc(compress(%scan(&&entry&i,1,
         %str(.)),%str(_)))%str(       ),1,8);
        filename _ecout1 "&catentry1" disp=(new,catlg) space=(trk,(4,4));
        filename _ecout2 "&catentry2" disp=(new,catlg) space=(trk,(4,4));
      %end;
      %else %if &unix %then %do;
        %let catentry1  = &parentdir/%scan(&&entry&i,1,str(.)).entcmp1;
        %let catentry2  = &parentdir/%scan(&&entry&i,1,str(.)).entcmp2;
        filename _ecout1 "&catentry1";
        filename _ecout2 "&catentry2";
      %end;
      %if &debug %then %do;
        %ut_errmsg(msg=temp file for cat1 entry catentry1=&catentry1,
         macroname=ut_entrycomp,type=note,print=0)
        %ut_errmsg(msg=temp file for cat2 entry catentry2=&catentry2,
         macroname=ut_entrycomp,type=note,print=0)
      %end;
      filename _ecat1 catalog "&cat1..&&entry&i";
      data _null_;
        infile _ecat1;
        input;
        file _ecout1;
        put _infile_;
      run;
      filename _ecat1 clear;
      filename _ecat2 catalog "&cat2..&&entry&i";
      data _null_;
        infile _ecat2;
        input;
        file _ecout2;
        put _infile_;
      run;
      filename _ecat2 clear;
      *------------------------------------------------------------------------;
      * Compare the catalog entry files in _ECOUT1 and _ECOUT2;
      *  and write result to COMPENT file;
      *------------------------------------------------------------------------;
      %if &sysscp = WIN %then %do;
        %* sysexec fc /c /w /n &catentry1 &catentry2 > &compent;
        %* x "fc /c /w /n &catentry1 &catentry2 > &compent";
        x "cmd /c fc /c /w /n &catentry1 &catentry2 > &compent";
        %ut_errmsg(msg=i=&i sysrc=&sysrc         &catentry1 &catentry2,
         macroname=ut_entrycomp,type=note,print=0)
        %let equal = 0;
        %if %sysfunc(fileexist(&compent)) %then %do;
          %* sysrc 0=compared equal  1=compared unequal  2=a file does not exist;
          %if &sysrc = 0 %then %let equal = 1;
          %else %let equal = 0;
          %ut_errmsg(msg=i=&i sysrc=&sysrc equal=&equal &catentry1 &catentry2,
           macroname=ut_entrycomp,type=note,print=0)
        %end;
        %else %ut_errmsg(msg=fc command did not create &compent,
         macroname=ut_entrycomp,type=warning,print=0);
        %if &debug %then %do;
          %ut_errmsg(msg="cmd /c fc /c /w &catentry1 &catentry2 > &compent"
           sysrc=&sysrc equal=&equal,macroname=ut_entrycomp,type=note,print=0)
        %end;
      %end;
      %else %if &sysscp = OS %then %do;
        filename newdd "&catentry1"  disp=shr;
        filename olddd "&catentry2"  disp=shr;
        filename outdd "&compent" disp=(new,catlg) space=(trk,(4,4));
        proc isrsupc;
        run;
        %ut_errmsg(msg=i=&i compare sysrc=&sysrc &catentry1 &catentry2,
         macroname=ut_entrycomp,type=note,print=0)
        %let equal = 0;
        %if %sysfunc(fileexist(&compent)) %then %do;
          %* sysrc 0=compared equal  4=  8=  24=;
          %if &sysrc = 0 %then %let equal = 1;
          %else %let equal = 0;
          %ut_errmsg(msg=i=&i sysrc=&sysrc equal=&equal &catentry1 &catentry2,
           macroname=ut_entrycomp,type=note,print=0)
        %end;
        %else %ut_errmsg(msg=compare did not create &compent,
         macroname=ut_entrycomp,type=warning,print=0);
        %if &debug %then %do;
          %ut_errmsg(msg="proc isrsupc &catentry1 with &catentry2"
           sysrc=&sysrc equal=&equal,macroname=ut_entrycomp,type=note,print=0)
        %end;
        filename newdd clear;
        filename olddd clear;
      %end;
      %else %if &unix %then %do;
        x "diff -bics &catentry1 &catentry2 > &compent";
        %ut_errmsg(msg=i=&i sysrc=&sysrc         &catentry1 &catentry2,
         macroname=ut_entrycomp,type=note,print=0)
        %let equal = 0;
        %if %sysfunc(fileexist(&compent)) %then %do;
          %* sysrc 0=compared equal  1=compared unequal  2=error;
          %if &sysrc = 0 %then %let equal = 1;
          %else %let equal = 0;
          %ut_errmsg(msg=i=&i sysrc=&sysrc equal=&equal &catentry1 &catentry2,
           macroname=ut_entrycomp,type=note,print=0)
        %end;
        %else %ut_errmsg(msg=diff command did not create &compent,
         macroname=ut_entrycomp,type=warning,print=0);
        %if &debug %then %do;
          %ut_errmsg(msg="diff -bics &catentry1 &catentry2 > &compent"
           sysrc=&sysrc equal=&equal,macroname=ut_entrycomp,type=note,print=0)
        %end;
      %end;
      *------------------------------------------------------------------------;
      %* Assign array macro variable STAT<i>;
      * Concatenate differences file COMPENT to _ECOMPCA fileref;
      *------------------------------------------------------------------------;
      %if &equal ^= 1 %then %do;
        %let stat&i = NOT SAME;
        %if ^ &first_unequal %then %do;
          data _null_;
            infile &compent_infile;
            file _ecompca mod;
            if _n_ = 1 then put // &ls*'=' / @10 "Comparison of &&entry&i" /
             &ls*'=' //;
            input;
            put _infile_;
          run;
          %ut_errmsg(msg=Concatenating &compcat with &&entry&i,
           macroname=ut_entrycomp,type=note,print=0);
        %end;
        %else %do;
          data _null_;
            infile &compent_infile;
            file _ecompca mod;
            if _n_ = 1 then put 
             // "(ut_entrycomp) Comparing catalogs:" / "&cat1path" / "&cat2path"
             %if (%bquote(&cat1label) ^= | %bquote(&cat2label) ^=) &
              (%bquote(&cat1label) ^= %bquote(&cat1) |
               %bquote(&cat2label) ^= %bquote(&cat2)) %then %do;
               / "(ut_entrycomp) Comparing catalogs &cat1label and &cat2label"
             %end;
             / &ls*'=' / @10 "Comparison of &&entry&i" / &ls*'=' //;
            input;
            put _infile_;
          run;
          %let first_unequal = 0;
          %ut_errmsg(msg=Creating &compcat with &&entry&i,
           macroname=ut_entrycomp,type=note,print=0);
        %end;
      %end;
      %else %do;
        %let stat&i = SAME;
      %end;
      %*-----------------------------------------------------------------------;
      %* Delete temporary files CATENTRY1 CATENTRY2 COMPENT;
      %*-----------------------------------------------------------------------;
      %if &sysscp = WIN %then %do;
        %if ^ &debug %then %do;
          %if %sysfunc(fileexist(&catentry1)) %then %do;
            %sysexec erase &catentry1;
          %end;
          %else %ut_errmsg(msg=file not found to be deleted &catentry1,
           macroname=ut_entrycomp,type=warning,print=0);
          %if %sysfunc(fileexist(&catentry2)) %then %do;
            %sysexec erase &catentry2;
          %end;
          %else %ut_errmsg(msg=file not found for deletion &catentry2,
           macroname=ut_entrycomp,type=warning,print=0);
          %if %sysfunc(fileexist(&compent))  %then %do;
            %sysexec erase &compent;
          %end;
          %else %ut_errmsg(msg=file not found for deletion &compent,
           macroname=ut_entrycomp,type=warning,print=0);
        %end;
      %end;    /* os = WIN loop */
      %else %if &sysscp = OS %then %do;
        %if %sysfunc(fileexist(&catentry1)) %then %do;
          x "delete '&catentry1'";
          %let msg = %sysfunc(sysmsg());
          %if &sysrc ^= 0 | &debug %then
           %ut_errmsg(msg=_ecout1 delete sysrc=&sysrc msg=&msg,
           macroname=ut_entrycomp,type=note,print=0);
        %end;
        %else %ut_errmsg(msg=file not found for deletion &catentry1,
         macroname=ut_entrycomp,type=warning,print=0);
        %if %sysfunc(fileref(_ecout1)) <= 0 %then %do;
          filename _ecout1 clear;
        %end;
        %if %sysfunc(fileexist(&catentry2)) %then %do;
          %let rc = %sysfunc(fdelete(_ecout2));
          %let msg = %sysfunc(sysmsg());
          x "delete '&catentry2'";
          %if &sysrc ^= 0 | &debug %then
           %ut_errmsg(msg=_ecout2 delete sysrc=&sysrc msg=&msg,
           macroname=ut_entrycomp,type=note,print=0);
        %end;
        %else %ut_errmsg(msg=file not found for deletion &catentry2,
         macroname=ut_entrycomp,type=warning,print=0);
        %if %sysfunc(fileref(_ecout2)) <= 0 %then %do;
          filename _ecout2 clear;
        %end;
        %if %sysfunc(fileexist(&compent))  %then %do;
          %let rc = %sysfunc(fdelete(outdd));
          %let msg = %sysfunc(sysmsg());
          %if &rc ^= 0 | &debug %then
           %ut_errmsg(msg=outdd fdelete rc=&rc msg=&msg,macroname=ut_entrycomp,
           type=note,print=0);
        %end;
        %else %ut_errmsg(msg=file not found for deletion &compent,
         macroname=ut_entrycomp,type=warning,print=0);
        %if %sysfunc(fileref(outdd)) <= 0 %then %do;
          filename outdd clear;
        %end;
      %end;              /* os=os loop */
      %else %if &unix %then %do;
        %if ^ &debug %then %do;
          %if %sysfunc(fileexist(&catentry1)) %then %do;
            %sysexec rm &catentry1;
          %end;
          %else %ut_errmsg(msg=file not found to be deleted &catentry1,
           macroname=ut_entrycomp,type=warning,print=0);
          %if %sysfunc(fileexist(&catentry2)) %then %do;
            %sysexec rm &catentry2;
          %end;
          %else %ut_errmsg(msg=file not found for deletion &catentry2,
           macroname=ut_entrycomp,type=warning,print=0);
          %if %sysfunc(fileexist(&compent))  %then %do;
            %sysexec rm &compent;
          %end;
          %else %ut_errmsg(msg=file not found for deletion &compent,
           macroname=ut_entrycomp,type=warning,print=0);
        %end;
      %end;
    %end;    /* compmeth = os */
    %else %do;
      filename _ecat1 catalog "&cat1..&&entry&i";
      data _ecentry_base;
        infile _ecat1 length=reclength;
        input line $varying400. reclength;
      run;
      filename _ecat1 clear;
      filename _ecat2 catalog "&cat2..&&entry&i";
      data _ecentry_compare;
        infile _ecat2 length=reclength;
        input line $varying400. reclength;
      run;
      filename _ecat2 clear;
      proc compare base=_ecentry_base  compare=_ecentry_compare  noprint;
      run;
      %if &sysinfo ^= 0 %then %do;
        %let stat&i = not same;
        %let equal = 0;
        %ut_errmsg(msg=Entries are not the same,type=note,print=0,
         macroname=ut_entrycomp)
      %end;
      %else %do;
        %let stat&i = same;
        %let equal = 1;
        %ut_errmsg(msg=Entries are the same,type=note,print=0,
         macroname=ut_entrycomp)
      %end;
      %if &debug %then %do;
        %let comprc2 = %sysfunc(putn(&sysinfo,binary16.));
        %ut_errmsg(msg="proc compare &cat1..&&entry&i &cat2..&&entry&i "
         sysinfo=&sysinfo equal=&equal comprc2=&comprc2,
         macroname=ut_entrycomp,type=note,print=0)
        %if %substr(&comprc2,16,1) = 1 %then
         %put (ut_entrycomp) UNOTE data set labels differ;
        %if %substr(&comprc2,15,1) = 1 %then
         %put (ut_entrycomp) UNOTE data set types differ;
        %if %substr(&comprc2,14,1) = 1 %then
         %put (ut_entrycomp) UNOTE variable has different informat;
        %if %substr(&comprc2,13,1) = 1 %then
         %put (ut_entrycomp) UNOTE variable has different format;
        %if %substr(&comprc2,12,1) = 1 %then
         %put (ut_entrycomp) UNOTE variable has different length;
        %if %substr(&comprc2,11,1) = 1 %then
         %put (ut_entrycomp) UNOTE variable has different label;
        %if %substr(&comprc2,10,1) = 1 %then
         %put (ut_entrycomp) UNOTE &base has observation not in &compare;
        %if %substr(&comprc2,9,1)  = 1 %then
         %put (ut_entrycomp) UNOTE &compare has observation not in &base;
        %if %substr(&comprc2,8,1)  = 1 %then
         %put (ut_entrycomp) UNOTE &base has BY group not in &compare;
        %if %substr(&comprc2,7,1)  = 1 %then
         %put (ut_entrycomp) UNOTE &compare has BY group not in &base;
        %if %substr(&comprc2,6,1)  = 1 %then
         %put (ut_entrycomp) UNOTE &base has variable not in &compare;
        %if %substr(&comprc2,5,1)  = 1 %then
         %put (ut_entrycomp) UNOTE &compare has variable not in &base;
        %if %substr(&comprc2,4,1)  = 1 %then
         %put (ut_entrycomp) UNOTE a value comparison was unequal;
        %if %substr(&comprc2,3,1)  = 1 %then
         %put (ut_entrycomp) UNOTE conflicting variable types;
        %if %substr(&comprc2,2,1)  = 1 %then
         %put (ut_entrycomp) UNOTE BY variables do not match;
        %if %substr(&comprc2,1,1)  = 1 %then
         %put (ut_entrycomp) UNOTE Fatal error: comparison not done;
      %end;
    %end;
  %end;                /* iterative nument loop */
  %if %sysfunc(fileref(outdd)) <= 0 %then %do;
    filename _ecompca clear;
  %end;
  *============================================================================;
  * Add comparison result variable to entry description data set;
  * and report results of comparisons;
  *============================================================================;
  data _ecstat;
    length name $ 32 type $ 8 status $ 9;
    %do i = 1 %to &nument;
      name = "%scan(&&entry&i,1,%str(.))";
      type = "%scan(&&entry&i,2,%str(.))";
      status = "&&stat&i";
      output;
    %end;
  run;
  proc sort data = _ecstat;
    by name type;
  run;
  proc sort data = _ecnboth;
    by name type;
  run;
  data _ecstat;
    merge _ecstat (in=a)
          _ecnboth (in=b);
     by name type;
     if ^ a & b & status = ' ' then status = 'nocompare';
  run;
  proc sort data = _ecstat;
    by status name;
  run;
  proc print data = _ecstat (drop = libname memname libname2 memname2
   %if &verbose = 0 %then %do;
     where = (upcase(status) ^= 'SAME')
   %end;
   ) N;
    by status;
    id name;
    title%eval(&titlstrt+1)
    "(ut_entrycomp) Requested entries in both &cat1label (1) and &cat2label (2)";
    %if &verbose = 1 %then %do;
      title%eval(&titlstrt+2) "with comparison status flag";
    %end;
    %else %do;
      title%eval(&titlstrt+2) "Only entries that are not the same are listed";
    %end;
    title%eval(&titlstrt+3)
     "(ut_entrycomp) See &compcat for file comparison details"
     %if &printdif > 0 %then %do;
       " and the SAS print file"
     %end;
     ;
  run;
  title%eval(&titlstrt+1);
  data _null_;
    if eof & _n_ = 1 then do;
      file print;
      put #10 @20 "All &nument compared entries are the same";
    end;
    set _ecstat (where = (upcase(status) ^= 'SAME')) end=eof;
    stop;
  run;
  %if &printdif & %bquote(&compcat) ^= %then %do;
    %if %sysfunc(fileexist(&compcat)) %then %do;
      title%eval(&titlstrt + 1)
       "(ut_entrycomp) First &printdif lines of differences";
      data _null_;
        infile "&compcat" length=l;
        length line $ 200;
        input line $varying200. l;
        file print;
        actl = length(line);
        put line $varying200. actl;
        if _n_ > &printdif then do;
          put //// &ls*'=' / "Further lines not printed - see &compcat for full "
           "report" / &ls*'=' ////;
          stop;
        end;
      run;
      title%eval(&titlstrt + 1);
    %end;
  %end;
  %if %bquote(&out) ^= %then %do;
    proc sort data = _ecstat;
      by name type;
    run;
    data &out (label =
     %if %bquote(&cat1label) = & %bquote(&cat2label) = %then %do;
       "Comparison of catalogs &cat1path and &cat2path"
     %end;
     %else %do;
       "Comparison of catalogs &cat1label and &cat2label"
     %end;
    );
      set _ecstat (in=nboth drop=descdiff)
       %if &mode = LISTALL | &mode = LISTCOMP %then %do;
         _ecnotn1 (in=notn1)
       %end;
       %if &mode = LISTALL | &mode = LISTBASE %then %do;
         _ecnotn2 (in=notn2)
       %end;
      ;
      by name type;
      %if &mode = LISTALL | &mode = LISTCOMP %then %do;
        if notn1 then status = 'NOENTRY1';
      %end;
      %if &mode = LISTALL | &mode = LISTBASE %then %do;
        if notn2 then status = 'NOENTRY2';
      %end;
    run;
  %end;
%end;    /* numents > 0 loop */
%else %do;
  %if %bquote(&out) ^= %then %do;
    data &out (label =
     %if %bquote(&cat1label) = & %bquote(&cat2label) = %then %do;
       "Comparison of catalogs &cat1path and &cat2path"
     %end;
     %else %do;
       "Comparison of catalogs &cat1label and &cat2label"
     %end;
     );
      length name $ 32 type $ 8 status $ 9;
      set _ecnboth (drop=descdiff);
      status = ' ';
      stop;
    run;
  %end;
%end;
%if &verbose %then %do;
  *============================================================================;
  * List in SAS log the entries that are the same and different;
  *============================================================================;
  %put ------------------------------------------------------------------------;
  %put Entries that did not compare equal by ut_entrycomp are:;
  %do i = 1 %to &nument;
    %if %str(&&stat&i) = %str(NOT SAME) %then %put &&entry&i;
  %end;
  %put ------------------------------------------------------------------------;
  %put ------------------------------------------------------------------------;
  %put Entries that did compare equal by ut_entrycomp are:;
  %do i = 1 %to &nument;
    %if %str(&&stat&i) = SAME %then %put &&entry&i;
  %end;
  %put ------------------------------------------------------------------------;
%end;
%if ^ &debug %then %do;
  proc datasets nolist lib = work;
    delete _ec:;
  quit;
%end;
%if &sysscp = WIN & %bquote(&xopts) ^= %then %do;
  options &xopts;
%end;
title&titlstrt;
%mend;
