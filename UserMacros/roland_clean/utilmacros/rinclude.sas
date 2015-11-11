/*<pre><b>
/ Program   : rinclude.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 12-Jun-2011
/ Purpose   : To submit local sas code members in the remote session
/ SubMacros : none
/ Notes     : This macro works by placing local sas code members in a catalog as
/             "source" members and uploading them to the remote host where they
/             are extracted and submitted.
/
/             A mixed list of files (in quotes) and filerefs (not in quotes) can
/             be supplied (separated by spaces) much like how %include works.
/             It assumes you are already connected to the remote session.
/
/             No sas system options are set in this macro so if you want to
/             suppress notes in the log then submit the option "nonotes" in an
/             rsubmit block in the remote session as well as in your local
/             session before calling this macro. You may wish to set other sas
/             options in this way as well.
/
/             You would normally use this macro to compile macros in your local
/             session on the remote host so you can use them there. 
/
/             The macros %dirfpq (for Windows) and %lsfpq (for Unix) are useful
/             for creating a full-path quoted list of directory members for use
/             in the filelist= parameter when you have a large number of macros
/             to upload.
/
/ Usage     : %rinclude(mylib(mymacro1.sas) "C:\mylib\mymacro2.sas"
/                       %dirfpq(C:\macros\*.sas);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ filelist          (pos) Space-delimited list of mixed files (quoted) and
/                   filerefs (not quoted) as you would supply to %include
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Jun11         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: rinclude v1.0;

%macro rinclude(filelist);

  %local bit i;
  %let i=1;
  %let bit=%sysfunc(scan(&filelist,&i," ",q));

  %*- do for each file listed -;
  %do %while(%length(&bit));

    %*- do differently for file names and filerefs -;
    %if %qsubstr(&bit,1,1) EQ %str(%') 
     OR %qsubstr(&bit,1,1) EQ %str(%") %then %do;

      filename _rincin &bit;
      filename _rincout catalog "work._rinc._rinc.source";

      *- write to the catalog -;
      data _null_;
        infile _rincin;
        file _rincout;
        input;
        put _infile_;
      run;

      RSUBMIT;
        proc upload incat=work._rinc outcat=work._rinc status=no;
          select _rinc.source;
        quit;

        filename _rinc catalog "work._rinc._rinc.source";

        %include _rinc;

        *- delete the remote catalog -;
        proc datasets nolist memtype=catalog;
          delete _rinc;
        quit;
 
        filename _rinc clear;
      ENDRSUBMIT;

      *- delete the local catalog -;
      proc datasets nolist memtype=catalog;
        delete _rinc;
      quit;

      filename _rincin clear;
      filename _rincout clear;

    %end;

    %else %do;

      filename _rincout catalog "work._rinc._rinc.source";

      *- write to the catalog -;
      data _null_;
        infile &bit;
        file _rincout;
        input;
        put _infile_;
      run;

      RSUBMIT;
        proc upload incat=work._rinc outcat=work._rinc status=no;
          select _rinc.source;
        quit;

        filename _rinc catalog "work._rinc._rinc.source";

        %include _rinc;

        *- delete the remote catalog -;
        proc datasets nolist memtype=catalog;
          delete _rinc;
        quit;
 
        filename _rinc clear;

      ENDRSUBMIT;

      *- delete the local catalog -;
      proc datasets nolist memtype=catalog;
        delete _rinc;
      quit;

      filename _rincout clear;

    %end;

    %*- prepare for the next iteration -;
    %let i=%eval(&i+1);
    %let bit=%sysfunc(scan(&filelist,&i," ",q));

  %end;

%mend rinclude;
