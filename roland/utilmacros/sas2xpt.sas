/*<pre><b>
/ Program      : sas2xpt.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 10-Aug-2012
/ Purpose      : Create multiple transport files from sas datasets
/ SubMacros    : %prxnames
/ Notes        : Normal practice is to include multiple sas datasets in a
/                transport file and this is easily achieved using a single call
/                to 'proc copy'. This macro was written for those cases where
/                there must be separate transport files corresponding to each
/                sas dataset (which is typical for FDA electronic submissions).
/
/                Paths specified must end in a slash and must be enclosed in
/                double quotes. If the path name contains special characters
/                such as '&' or '%' then the double-quoted path name should be
/                enclosed in %nrstr( ) to stop sas trying to resolve these
/                symbols.
/
/                Note that transport files in SAS must match SAS version 6
/                restrictions such as character variables having a maximum
/                length of 200, variable names limited to eight characters and
/                variable labels limited to 40 characters. Your input datasets
/                must also abide by these restrictions even if created with
/                later versions of SAS. You might find the %checkv6 macro useful
/                for checking your datasets for compatibility.
/
/                Pay careful attention to any warning or error messages that
/                may appear in the log as well as note statements about the
/                truncation of variable labels where features of the input
/                datasets may be incompatible with transport file restrictions.
/
/ Usage        : %sas2xpt((INDSLIB),%nrstr("V:\SAS\Two Parts\X&Y\temp\"));
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ in                (pos) Either the full path name of the input folder
/                   containing the sas datasets (same naming rules as below) or
/                   an existing libref contained in round brackets such as
/                   (WORK) (no quotes)
/ outfolder         (pos) Full path name of output folder to hold created .xpt
/                   files (must end in a slash, must be enclosed in double
/                   quotes and if containing special characters such as "&" or
/                   "%" must also be enclosed by %nrstr( )  )
/ dslist            Optional list of datasets separated by spaces (no quotes)
/                   to create transport files from. You can use the end colon
/                   notation to denote datasets beginning with the preceding
/                   characters. Default is to use all datasets found so this can
/                   be left blank.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  02Feb11         New (v1.0)
/ rrb  10Aug12         Header update
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%macro sas2xpt(in,outfolder,dslist=);

  libname _sas2xpt &in;

  proc sql noprint;
    create table _sas2cont as
    (select memname from dictionary.tables
     where libname="_SAS2XPT" and memtype="DATA"
     %if %length(&dslist) %then %do;
       and prxmatch(%prxnames(&dslist),memname)
     %end;
     ) order by memname;
  quit;

  data _null_;
    retain outxpt &outfolder;
    set _sas2cont;
    call execute("libname _xptout xport %nrstr('"||trim(outxpt)||trim(memname)||".xpt');");
    call execute('proc copy in=_sas2xpt out=_xptout;select '||trim(memname)||';run;');
    call execute('libname _xptout clear;');
  run;

  libname _sas2xpt clear;

  proc datasets nolist memtype=data;
    delete _sas2cont;
  run;
  quit;

%mend sas2xpt;
