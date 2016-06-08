/*<pre><b>
/ Program      : xlblocks.sas
/ Version      : 2.2
/ Author       : Roland Rashleigh-Berry
/ Date         : 14-Sep-2014
/ Purpose      : Read an Excel spreadsheet sheet containing blocks of
/                information using DDE with each block output as a numbered
/                dataset.
/ SubMacros    : %xl2sas %attrn %getvalue
/ Notes        : This is meant to be run interactively. The maximum end columns
/                and end rows you specify are those required to read the grid
/                of spreadsheet cells you are interested in, leaving at least
/                one completely blank column and one completely blank row
/                at the end. Numeric integer values must be given for these.
/                You must have Excel for this to work. This was especially
/                written for Excel spreadsheets that contain blocks of
/                information at different locations.
/
/                The different blocks must be separated from the other blocks
/                by blank columns or blank rows but they can touch at the
/                corners.
/
/                information in single separated cells will not be read.
/
/                Note that because of rules for rendering html, double spaces
/                in cell values in the html spreadsheet file will, by default,
/                be compressed to single spaces unless the value is protected
/                by tags or the spaces are non-breaking spaces ("A0"x) or
/                compression disabled using compbl=no.
/
/                By specifying readblocks=no you will just keep the blocks work
/                dataset _xlblocks (that is normally used to subsequently read
/                the blocks) plus the _xl2sas dataset (used to determine where
/                the blocks are). Using this option allows you to make changes
/                to the _xlblocks dataset to tailor the calls to %xl2sas for
/                each block number in a following step, depending on the
/                information given for each block. The variables kept in the 
/                _xlblocks dataset are as follows:
/                   Numeric variables:
/                   BLOCKNO: The block number (1,2,3,etc.)
/                   STARTROW, STARTCOL: Block start row and column
/                   ENDROW, ENDCOL:     Block end row and column          
/                   Character variables:
/                   GETNAMES: "no" or "yes" to get variable names and labels
/                             from the first row.
/                   DSNAME:   Low level name of the dataset to output
/                   OUTLIB:   Library to store the dataset in
/
/ Usage        : %xlblocks(xlfile=C:\myfiles\My Sheet.xls,sheetname=Sheet One,
/                       dspref=sasuser.myspread,compress=no,vpref=col,vlen=40);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ xlfile            (no quotes) Full path name of spreadsheet file (will accept
/                   file name with spaces).
/ sheetname         (no quotes) Name of spreadsheet sheet you want to read in.
/                   This will be visible as the bottom tag name when you open
/                   the spreadsheet in Excel (or you can use %xlsheets to write
/                   this list of sheet names to a global macro variable but
/                   you must remove the quotes added by the %xlsheets macro for
/                   sheet names containing spaces (use %dequote)).
/ secswait=2        Number of seconds to wait for the spreadsheet to open
/ dspref            Output dataset name prefix (no modifiers)
/ compress=no       (no quotes) Set to "yes" to compress for all spaces. This
/                   will include the non-breaking space character "A0"x .
/                   Note this this action, if set to "yes", will effectively
/                   override the actions of compbl= and left= .
/ compbl=yes        (no quotes) By default, compress multiple spaces into single
/                   spaces. This will include the non-breaking space character
/                   "A0"x . Even if you set this to "no" then Excel itself will
/                   compress multiple spaces into single spaces unless the tags
/                   in the html file protect the values or the spaces are non-
/                   breaking spaces ("A0"x).
/ left=yes          (no quotes) By default, left-align fields by removing
/                   leading spaces. Leading spaces include the non-breaking
/                   space character "A0"x . Even if you set this to "no" then
/                   Excel itself will left-align text by dropping leading
/                   spaces unless the tags in the html file protect the values
/                   or the spaces are non-breaking spaces ("A0"x).
/ vpref=C           Prefix for the numbered variables created in the sas dataset
/ vlen=80           Length of the sas dataset variables (they are all character)
/ maxcols=50        Maximum columns (must include a blank column at the end)
/ maxrows=3000      Maximum rows (must include a blank row at the end)
/ quit=yes          By default, close the spreadsheet file after reading the
/                   spreadsheet sheet.
/ closesheet=yes    By default, close the sheet after reading it
/ getnames=no       By default, do not use what is in the first row read in for
/                   the variable names and their labels.
/ outlib=work       Library to store the numbered block datasets in
/ readblocks=yes    By default, read the blocks once found. Set this to no to
/                   just keep the _xlblocks dataset for later processing.
/ probelen=8        Length of character variables when reading in the
/                   spreadsheet for the first time to determine where the blocks
/                   are (gets written to _xl2sas).
/ filtercode        Code to run against the _xlblocks dataset to change its
/                   values if need be. You might want to changes the value of
/                   getnames, for example, for some of the blocks.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04May11         Code tidy
/ rrb  26Jun11         Remove quotes from xlfile if supplied (v1.1)
/ rrb  24Sep11         Block detection logic completely changed (v2.0)
/ rrb  15Sep12         Call to %getvalue simplified for new version (v2.1)
/ rrb  14Sep14         Use of "keyword" dropped for boolean options (v2.2)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/
 
%put MACRO CALLED: xlblocks v2.2;
 
%macro xlblocks(xlfile=,
             sheetname=,
              secswait=2,
                dspref=_xblock,
              compress=no,
                compbl=yes,
                  left=yes,
                 vpref=C,
                  vlen=80,
               maxcols=50,
               maxrows=3000,
              getnames=no,
                  quit=yes,
            closesheet=yes,
            readblocks=yes,
              probelen=8,
                outlib=WORK,
            filtercode=,
                 debug=no
                );

  %local errflag err i blocknobs startcol startrow endcol endrow savopts getn outl;
  %let err=ERR%str(OR);
  %let errflag=0;
  %if %length(&xlfile) %then %let xlfile=%sysfunc(dequote(&xlfile));


      /*----------------------------------*
              Check input parameters
       *----------------------------------*/

  %if not %length(&outlib) %then %let outlib=WORK;

  %if not %length(&probelen) %then %let probelen=8;
 
  %if not %length(&readblocks) %then %let readblocks=yes;
  %let readblocks=%upcase(%substr(&readblocks,1,1));

  %if not %length(&getnames) %then %let getnames=no;

  %if not %length(&debug) %then %let debug=no;
  %let debug=%upcase(%substr(&debug,1,1));

  %if not %length(&dspref) %then %let dspref=_xlblock;
 
  %if not %length(&quit) %then %let quit=yes;
  %let quit=%upcase(%substr(&quit,1,1));
 
  %if not %length(&closesheet) %then %let closesheet=yes;
  %let closesheet=%upcase(%substr(&closesheet,1,1));

  %if not %length(&compress) %then %let compress=no;
  %let compress=%upcase(%substr(&compress,1,1));
 
  %if not %length(&compbl) %then %let compbl=yes;
  %let compbl=%upcase(%substr(&compbl,1,1));
 
  %if not %length(&left) %then %let left=yes;
  %let left=%upcase(%substr(&left,1,1));
 
  %if not %length(&vpref) %then %let vpref=C;
 
  %if not %length(&vlen) %then %let vlen=80;



    %if not %length(&xlfile) %then %do;
      %let errflag=1;
      %put &err: (xlblocks) No Excel spreadsheet file name supplied to xlfile=;
    %end;
    %else %do;
      %if not %sysfunc(fileexist(&xlfile)) %then %do;
        %let errflag=1;
        %put &err: (xlblocks) xlfile=&xlfile can not be found;
      %end;
    %end;
 
    %if not %length(&sheetname) %then %do;
      %let errflag=1;
      %put &err: (xlblocks) No Excel spreadsheet sheet name supplied to sheetname=;
    %end;
 
    %if not %length(&secswait) %then %let secswait=2;
    %else %do;
      %if %length(%sysfunc(compress(&secswait,1234567890))) %then %do;
        %let errflag=1;
        %put &err: (xlblocks) An integer number of seconds is required. You specified secswait=&secswait;
      %end;
    %end;
 
    %if not %length(&maxrows) %then %let maxrows=1500;
    %else %do;
      %if %length(%sysfunc(compress(&maxrows,1234567890))) %then %do;
        %let errflag=1;
        %put &err: (xlblocks) An integer is required. You specified maxrows=&maxrows;
      %end;
    %end;
  
    %if not %length(&maxcols) %then %let maxcols=99;
    %else %do;
      %if %length(%sysfunc(compress(&maxcols,1234567890))) %then %do;
        %let errflag=1;
        %put &err: (xlblocks) An integer is required. You specified maxcols=&maxcols;
      %end;
    %end;



 
  %if &errflag %then %goto exit;


       /*---------------------------------*
              Store current options
       *---------------------------------*/


    %*- store current xwait and xsync settings -;
    %let savopts=%sysfunc(getoption(xwait)) %sysfunc(getoption(xsync)); 

    *- set required options for dde to work correctly -;
    options noxwait noxsync;



      /*---------------------------------*
              Open the spreadsheet
       *---------------------------------*/

    *- start up Excel by opening the spreadsheet -;
    %sysexec "&xlfile";

    %if &secswait GT 0 %then %do;
      *- wait for Excel to finish starting up -;
      data _null_;
        x=sleep(&secswait);
      run;
    %end;


 
      /*---------------------------------*
              Read the spreadsheet
       *---------------------------------*/

  %xl2sas(xlfile=&xlfile,sheetname=&sheetname,vpref=C,vlen=&probelen,
          startcol=1,endcol=&maxcols,startrow=1,endrow=&maxrows,dsout=,
          secswait=0,quit=no,closesheet=no,xlisopen=yes,compress=no,
          left=yes,compbl=yes,dropblanklines=no,getnames=no);



      /*---------------------------------*
                Find the blocks
       *---------------------------------*/

  data _xlblocks(keep=blockno outlib dsname getnames  
                      startrow startcol endrow endcol);
    length dsname $ 32 outlib $ 16 getnames $ 3;
    retain outlib "&OUTLIB" getnames "&getnames" blockno 0;
    array x{&maxcols,&maxrows} _temporary_;
    set _xl2sas end=last;
    array cra{*} c1-c&maxcols;
    *- fill up temporary array -;
    do i=1 to &maxcols;
      if not missing(cra(i)) then x{i,_n_}=1;
      else x{i,_n_}=0;
    end;
    *- look for blocks after temporary array is filled -;
    if last then do;
      link maxrow;
      link maxcol;
      link fillcorners;
      link delsingles;
      link getblocks;
      stop;
    end;
  return;

  maxrow:
  do row=&maxrows to 1 by -1;
    do col=1 to &maxcols;
      if x(col,row)=1 then do;
        maxrow=row;
        col=&maxcols;
        row=1;
      end;
    end;
  end;
  return;

  maxcol:
  do col=&maxcols to 1 by -1;
    do row=1 to maxrow;
      if x(col,row)=1 then do;
        maxcol=col;
        col=1;
        row=maxrow;
      end;
    end;
  end;
  return;

  fillcorners:
  gotone=1;
  do while(gotone);
    gotone=0;
    col=1;
    do row=1 to maxrow;
      if x(col,row)=0 and x(col+1,row)=1 then do;
        gotone=1;
        x(col,row)=1;
      end;
    end;
    do col=maxcol to 2 by -1;
      do row=1 to (maxrow-1);
        if x(col,row)=0 then do;
          if x(col,row+1)=1
          and x(col-1,row+1)=1
          and x(col-1,row)=1 then do;
            gotone=1;
            x(col,row)=1;
          end;
        end;
      end;
    end;
    do col=maxcol to 2 by -1;
      do row=2 to maxrow;
        if x(col,row)=0 then do;
          if x(col,row-1)=1
          and x(col-1,row-1)=1
          and x(col-1,row)=1 then do;
            gotone=1;
            x(col,row)=1;
          end;
        end;
      end;
    end;
    do col=(maxcol-1) to 1 by -1;
      do row=2 to maxrow;
        if x(col,row)=0 then do;
          if x(col,row-1)=1
          and x(col+1,row-1)=1
          and x(col+1,row)=1 then do;
            gotone=1;
            x(col,row)=1;
          end;
        end;
      end;
    end;
    row=maxrow;
    do col=1 to (maxcol-1);
      if x(col,row)=0 and x(col+1,row)=1 then do;
        gotone=1;
        x(col,row)=1;
      end;
    end;
  end; 
  return;

  delsingles:
    row=1;
    do col=1 to (maxcol-1);
      if x(col,row)=1 then do;
        if x(col,row+1)=0
        and x(col+1,row)=0
        then x(col,row)=0;
      end;
    end;
    do row=2 to (maxrow-1);
      do col=1 to (maxcol-1);
        if x(col,row)=1 then do;
          if x(col,row+1)=0
          and x(col,row-1)=0
          and x(col+1,row)=0
          then x(col,row)=0;
        end;
      end;
    end;
    row=maxrow;
    do col=1 to (maxcol-1);
      if x(col,row)=1 then do;
        if x(col+1,row)=0
        and x(col,row-1)=0
        then x(col,row)=0;
      end;
    end;
    col=maxcol;
    do row=2 to (maxrow-1);
       if x(col,row)=1 then do;
         if x(col-1,row)=0
         and x(col,row-1)=0
         and x(col,row+1)=0
         then x(col,row)=0;
       end;
    end;
    row=1;
    col=maxcol;
    if x(col,row)=1 then do;
      if x(col-1,row)=0
      and x(col,row+1)=0
      then x(col,row)=0;
    end;
    row=maxrow;
    if x(col,row)=1 then do;
      if x(col-1,row)=0
      and x(col,row-1)=0
      then x(col,row)=0;
    end;
  return;

  getblocks:
    gotblock=1;
    do while(gotblock);
      gotblock=0;
      startcol=0;
      endcol=0;
      startrow=0;
      endrow=0;
      do row=1 to maxrow;
        do col=1 to maxcol;
          if x(col,row)=1 then do;
            startrow=row;
            startcol=col;
            do col=startcol to maxcol;
              if x(col,row)=0 or col=maxcol then do;
                if col<maxcol then endcol=col-1;
                else endcol=maxcol;
                do row=startrow to maxrow;
                  if x(endcol,row)=0 or row=maxrow then do;
                    if row<maxrow then endrow=row-1;
                    else endrow=maxrow;
                    do col=startcol to endcol;
                      do row=startrow to endrow;
                        x(col,row)=0;
                      end;
                    end;
                    gotblock=1;
                    blockno=blockno+1;
                    dsname="&dspref"||compress(put(blockno,6.));
                    output;
                    row=maxrow;
                    col=maxcol;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  return;

  run;


 
      /*---------------------------------*
                Apply filtercode
       *---------------------------------*/
 
  %if %length(&filtercode) %then %do;
    data _xlblocks;
      set _xlblocks;
      &filtercode;
    run;
  %end;



      /*---------------------------------*
                 Read each block
       *---------------------------------*/

  %if &readblocks EQ Y %then %do;
    %let blocknobs=%attrn(_xlblocks,nobs);
    %do i=1 %to &blocknobs;
      %*- numeric variables -;
      %let startcol=%getvalue(_xlblocks,startcol,&i);
      %let startrow=%getvalue(_xlblocks,startrow,&i);
      %let endcol=%getvalue(_xlblocks,endcol,&i);
      %let endrow=%getvalue(_xlblocks,endrow,&i);
      %*- character variables -;
      %let getn=%getvalue(_xlblocks,getnames,&i);
      %let outl=%getvalue(_xlblocks,outlib,&i);
      %let dsname=%getvalue(_xlblocks,dsname,&i);
      %if &i EQ &blocknobs %then %do;
        %*- Use quit and closesheet parameter settings only in the last case   -;
        %xl2sas(xlfile=&xlfile,sheetname=&sheetname,vpref=&vpref,vlen=&vlen,
                startcol=&startcol,endcol=&endcol,startrow=&startrow,
                endrow=&endrow,secswait=0,quit=&quit,closesheet=&closesheet,
                compress=&compress,compbl=&compbl,left=&left,dsout=&outl..&dsname,
                dropblanklines=yes,getnames=&getn,xlisopen=yes);
      %end;
      %else %do;
        %xl2sas(xlfile=&xlfile,sheetname=&sheetname,vpref=&vpref,vlen=&vlen,
                startcol=&startcol,endcol=&endcol,startrow=&startrow,
                endrow=&endrow,secswait=0,quit=no,closesheet=no,
                compress=&compress,compbl=&compbl,left=&left,dsout=&outl..&dsname,
                dropblanklines=yes,getnames=&getn,xlisopen=yes);
      %end;
    %end;
  %end;



      /*---------------------------------*
                 Restore options
       *---------------------------------*/

  %if &debug NE Y %then %do;
    *- restore previous xwait and xsync settings -;
    options &savopts;
  %end;



      /*---------------------------------*
                Tidy up and Exit
       *---------------------------------*/

  %if &debug NE Y and &readblocks NE N %then %do;
    proc datasets nolist memtype=data;
      delete _xlblocks _xl2sas;
    run;
    quit;
  %end;

  %goto skip;
  %exit: %put &err: (xlblocks) Leaving macro due to problem(s) listed;
  %skip:
 
%mend xlblocks;
