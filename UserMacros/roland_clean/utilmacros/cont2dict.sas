/*<pre><b>
/ Program   : cont2dict.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 17-Jun-2014
/ Purpose   : To change proc contents output variable characteristics to match
/             those from dictionary.columns.
/ SubMacros : %words
/ Notes     : The variables FORMAT, INFORMAT and TYPE are changed to match the
/             column characteristics in dictionary.columns. You can use the
/             _all_ notation for running proc contents on an entire library
/             (see usage notes).
/ Usage     : %cont2dict(_mydset,_mycont);
/             %cont2dict(mylib._all_,_mycont);
/             %cont2dict(%suffix(._all_,&liblist),_mybigcont);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Dataset(s) (separated by spaces) to run proc contents
/                   on. Using the _all_ notation is allowed.
/ dsout             (pos) Output dataset containing proc contents output but
/                   with variable characteristics changed.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26May14         New (v1.0)
/ rrb  17Jun14         Multiple input datasets allowed (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: cont2dict v2.0;

%macro cont2dict(dsin,dsout);

  %local i savopts ndsets dset;
  %let savopts=%sysfunc(getoption(notes));

  options nonotes;

  %let ndsets=%words(%superq(dsin));

  %do i=1 %to &ndsets;
    %let dset=%scan(&dsin,&i,%str( ));
    proc contents data=&dset out=_cont&i noprint;
    run;
  %end;

  data &dsout;
    length format2 informat2 $ 49 type2 $ 4;
    set
    %do i=1 %to &ndsets;
      _cont&i
    %end;
    ;
    if type=1 then type2='char';
    else type2='num';
    format2=' ';
    if format NE ' ' then do;
      format2=cats(format,formatl,'.');
      if formatd>0 then format2=cats(format2,formatd);
    end;
    informat2=' ';
    if informat NE ' ' then do;
      informat2=cats(informat,informl,'.');
      if informd>0 then informat2=cats(informat2,informd);
    end;
    drop format formatl formatd type
         informat informl informd;
    rename type2=type format2=format informat2=informat;
  run;

  proc datasets nolist memtype=data;
    delete
    %do i=1 %to &ndsets;
      _cont&i
    %end;
    ;
  quit;

  options &savopts;

%mend cont2dict;
