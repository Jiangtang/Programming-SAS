%* cstutilcomparedatasets                                                         *;
%*                                                                                *;
%* Compares two libraries with SAS data sets.                                     *;
%*                                                                                *;
%* @macvar _cstDebug Turns debugging on or off for the session. Set _cstDebug=1   *;
%*             before this macro call to retain work files created in this macro. *;
%* @macvar _cst_rc Task error status                                              *;
%* @macvar _cst_rcmsg Message associated with _cst_rc                             *;
%* @macvar _cstResultSeq Results: Unique invocation of macro                      *;
%* @macvar _cstSeqCnt Results: Sequence number within _cstResultSeq               *;
%*                                                                                *;
%* @param _cstLibBase - required - The reference library of SAS data sets.        *;
%* @param _cstLibComp - required - The library of SAS data sets that is compared  *;
%*            against the reference library.                                      *;
%* @param _cstCompareLevel - required - The minimum PROC COMPARE return code      *;
%*            which is considered to be an error condition.                       *;
%*            Values greater than 0, but below the _cstCompareLevel value, are    *;
%*            considered warning conditions.                                      *;
%*            Default: 16                                                         *;
%* @param _cstCompOptions - optional - Extra options to be added to PROC COMPARE. *;
%*            Here is an example:                                                 *;
%*               _cstCompOptions=%str(criterion=0.00000000000001)                 *;
%*                   to perform a less than exact compare                         *;
%* @param _cstCompDetail - optional - Perform a detailed PROC COMPARE for a SAS   *;
%*            data set that did not compare equal ().                             *;
%*            Values: Y | N                                                       *;
%*            Default:  Y                                                         *;
%*                                                                                *;
%* @since 1.7                                                                     *;
%* @exposure external                                                             *;

%macro cstutilcomparedatasets(
  _cstLibBase=, 
  _cstLibComp=, 
  _cstCompareLevel=16, 
  _cstCompOptions=,
  _cstCompDetail=Y
  ) / des='CST: Compare two libraries of data sets'; 

  %local 
    _cstRandom 
    _cstSrcMacro 
    i 
    nds 
    compinfo 
    _cstThisMacroRC
    _cstCompDetail
    _cstBaseSortedBy
    _cstCompSortedBy
    ;
    
  %************************;
  %*  Parameter checking  *;
  %************************;

  %if %length(&_cstLibBase) < 1 or %length(&_cstLibComp) < 1 or %length(&_cstCompareLevel) < 1 %then
  %do;
    %put ERR%STR(OR): [CSTLOG%str(MESSAGE).&sysmacroname] _cstLibBase, _cstLibComp parameter and _cstCompareLevel values are required.;
    %goto exit_error;
  %end;

  %if %sysfunc(libref(&_cstLibBase)) %then
  %do;
    %put ERR%STR(OR): [CSTLOG%str(MESSAGE).&sysmacroname] The libref _cstLibBase=&_cstLibBase has not been pre-allocated.;
    %goto exit_error;
  %end;

  %if %sysfunc(libref(&_cstLibComp)) %then
  %do;
    %put ERR%STR(OR): [CSTLOG%str(MESSAGE).&sysmacroname] The libref _cstLibComp=&_cstLibComp has not been pre-allocated.;
    %goto exit_error;
  %end;
  %************************;


  %let _cstRandom=%sysfunc(putn(%sysevalf(%sysfunc(ranuni(0))*10000,floor),z4.));
  
  %let _cstResultSeq=1;
  %let _cstSeqCnt=0;
  %let _cstSrcMacro=&SYSMACRONAME;
  %let _cstThisMacroRC=0;
  %let _cstDiffList=;

  %*************************************************;
  %*  Check for existence of _cst_rc and _cstDebug *;
  %*************************************************;
  %if ^%symexist(_cst_rc) %then
  %do;
    %global _cst_rc;
    %let _cst_rc=0;
  %end;
  %if ^%symexist(_cstDeBug) %then
  %do;
    %global _cstDeBug;
    %let _cstDebug=0;
  %end;

    %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
    %do;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
                  _cstResultId=DATA0097
                  ,_cstResultParm1=Base library: &_cstLibBase (%sysfunc(pathname(&_cstLibBase)))
                  ,_cstResultSeqParm=&_cstResultSeq
                  ,_cstSeqNoParm=&_cstSeqCnt
                  ,_cstSrcDataParm=&_cstSrcMacro
                  ,_cstResultFlagParm=&_cst_rc
                  ,_cstRCParm=&_cst_rc
                  );
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
                  _cstResultId=DATA0097
                  ,_cstResultParm1=Comp library: &_cstLibComp (%sysfunc(pathname(&_cstLibComp)))
                  ,_cstResultSeqParm=&_cstResultSeq
                  ,_cstSeqNoParm=&_cstSeqCnt
                  ,_cstSrcDataParm=&_cstSrcMacro
                  ,_cstResultFlagParm=&_cst_rc
                  ,_cstRCParm=&_cst_rc
                  );
    %end;

   proc sql;
    create table _cstDS_&_cstRandom as
    select unique memname from sashelp.vtable
    where (upcase(libname)="%upcase(&_cstLibBase)") or (upcase(libname)="%upcase(&_cstLibComp)")
    ;
    quit;


  data _null_;
    length mvname $8;
    set _cstDS_&_cstRandom end=end;
    i+1;
    mvname="ds"||left(put(i,2.));
    call symput(mvname,compress(lowcase(memname)));
    if end then call symput('nds',left(put(_n_,2.)));
  run;
  
   proc datasets lib=work nolist;
     delete _cstDS_&_cstRandom;
   quit;
   run;

  %let _cstSeqCnt=0;
  %do i=1 %to &nds;
      
     %if %sysfunc(exist(&_cstLibBase..&&ds&i))=0 %then 
     %do;
        %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
        %do;
          %put WARN%str(ING): [CSTLOG%str(MESSAGE).&sysmacroname] No compare: Data set &_cstLibBase..&&ds&i does not exist;
          %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
          %cstutil_writeresult(
                      _cstResultId=DATA0098
                      ,_cstResultParm1=No compare: Data set &_cstLibBase..&&ds&i does not exist
                      ,_cstResultSeqParm=&_cstResultSeq
                      ,_cstSeqNoParm=&_cstSeqCnt
                      ,_cstSrcDataParm=&_cstSrcMacro
                      ,_cstResultFlagParm=-1
                      ,_cstRCParm=-1
                      );
        %end;
       %goto exit_nocompare;
     %end;  

     %if %sysfunc(exist(&_cstLibComp..&&ds&i))=0 %then 
     %do;
        %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
        %do;
          %put WARN%str(ING): [CSTLOG%str(MESSAGE).&sysmacroname] No compare: Data set &_cstLibComp..&&ds&i does not exist;
          %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
          %cstutil_writeresult(
                      _cstResultId=DATA0098
                      ,_cstResultParm1=No compare: Data set &_cstLibComp..&&ds&i does not exist
                      ,_cstResultSeqParm=&_cstResultSeq
                      ,_cstSeqNoParm=&_cstSeqCnt
                      ,_cstSrcDataParm=&_cstSrcMacro
                      ,_cstResultFlagParm=-1
                      ,_cstRCParm=-1
                      );
        %end;
       %goto exit_nocompare;
     %end;  
     
     proc compare base=&_cstLibBase..&&ds&i compare=&_cstLibComp..&&ds&i noprint &_cstCompOptions;
     run; 
     %let compinfo=&sysinfo;
     %if &compinfo %then %let _cstThisMacroRC = %eval(&_cstThisMacroRC + 1);

     data _null_;
       length result 8 resultc restmp $200;
       array r(*) 8 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 r16;
       result=&compinfo;
       resultc="";
       restmp='/DSLABEL/DSTYPE/INFORMAT/FORMAT/LENGTH/LABEL/BASEOBS/COMPOBS'||
              '/BASEBY/COMPBY/BASEVAR/COMPVAR/VALUE/TYPE/BYVAR/ER'||'ROR';
       do i=1 to 16;
         if result >= 0 then do;
           if band(result, 2**(i-1)) then do;
             resultc=trim(resultc)||'/'||scan(restmp,i,'/'); 
             r(i) = 1;
           end;
         end;  
       end;
       if result=0 then resultc="NO DIFFERENCES";
       resultc=left(resultc);
       if index(resultc,'/')=1 then resultc=substr(resultc,2);
       call symputx ('resultc', resultc);
     run;

     %if %eval(&compinfo) gt 0 %then 
     %do;
       %* Add data set to the difference list;
       %let _cstDiffList=&_cstDiffList &&ds&i;

       %if %eval(&compinfo) gt &_cstCompareLevel %then
       %do;
         %let _cstMessID=DATA0099;
         %let _cstMessSev=ERROR;
       %end;
       %else
       %do;
         %let _cstMessID=DATA0098;
         %let _cstMessSev=WARNING;
       %end;
       %put &_cstMessSev: [CSTLOG%str(MESSAGE).&sysmacroname] Comparing &_cstLibBase..&&ds&i and &_cstLibComp..&&ds&i %str
            () - Differences: &resultc (SysInfo=&compinfo);
     %end;
     %else %do;
       %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Comparing &_cstLibBase..&&ds&i and &_cstLibComp..&&ds&i - %str
            ()No differences;
     %end;
      
     %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
     %do;
       %if &compinfo %then 
       %do;
         %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
         %cstutil_writeresult(
                     _cstResultId=&_cstMessID
                     ,_cstResultParm1=Comparing &_cstLibBase..&&ds&i and &_cstLibComp..&&ds&i  - Differences
                     ,_cstResultSeqParm=&_cstResultSeq
                     ,_cstSeqNoParm=&_cstSeqCnt
                     ,_cstSrcDataParm=&_cstSrcMacro
                     ,_cstResultFlagParm=&compinfo
                     ,_cstRCParm=&compinfo
                     ,_cstResultDetails=&resultc
                     );
       %end;
       %else %do;
         %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
         %cstutil_writeresult(
                     _cstResultId=DATA0097
                     ,_cstResultParm1=Comparing &_cstLibBase..&&ds&i and &_cstLibComp..&&ds&i - No differences
                     ,_cstResultSeqParm=&_cstResultSeq
                     ,_cstSeqNoParm=&_cstSeqCnt
                     ,_cstSrcDataParm=&_cstSrcMacro
                     ,_cstResultFlagParm=&compinfo
                     ,_cstRCParm=&compinfo
                     ,_cstResultDetails=
                     );
       %end;
     %end;

  %exit_nocompare:
  %end;

  %* Do a detailed compare for the data set that had a difference;
  %if %upcase(%substr(&_cstCompDetail,1,1)) = Y %then 
  %do;
    %local _cstCounter _cstListItem;
  
    %do _cstCounter=1 %to %sysfunc(countw(&_cstDiffList, %str( )));

      %let _cstListItem=%scan(&_cstDiffList, &_cstCounter, %str( ));
      %let _cstBaseSortedBy=%cstutilgetattribute(_cstDataSetName=&_cstLibBase..&_cstListItem, _cstAttribute=SORTEDBY);
      %let _cstCompSortedBy=%cstutilgetattribute(_cstDataSetName=&_cstLibComp..&_cstListItem, _cstAttribute=SORTEDBY);
      proc compare base=&_cstLibBase..&_cstListItem comp=&_cstLibComp..&_cstListItem &_cstCompOptions;

      %if %upcase(&_cstBaseSortedBy) eq %upcase(&_cstCompSortedBy) and
          not %sysevalf(%superq(_cstBaseSortedBy)=, boolean) %then
          id &_cstBaseSortedBy;
      ;

      run;
    %end;
  %end;


  %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Number of SAS data sets that had differences: &_cstThisMacroRC;

  %exit_error:

%mend cstutilcomparedatasets;

