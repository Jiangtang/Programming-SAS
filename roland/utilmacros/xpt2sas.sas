/*<pre><b>
/ Program      : xpt2sas.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 02-Feb-2011
/ Purpose      : Convert all the .xpt files in a folder to sas datasets
/ SubMacros    : none
/ Notes        : Paths specified must end in a slash and must be enclosed in
/                double quotes. If the path name contains special characters
/                such as '&' or '%' then the double-quoted path name should be
/                enclosed in %nrstr( ) to stop sas trying to resolve these
/                symbols.
/
/                This was written for a Windows platform and uses the "dir" DOS
/                command to list the .xpt files.
/
/ Usage        : %xpt2sas(%nrstr("V:\SAS\Two Parts\X&Y\"),
/                         %nrstr("V:\SAS\Two Parts\X&Y\temp\"));
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ infolder          (pos) Full path name of input folder containing .xpt files
/                   (must end in a slash, must be enclosed in double quotes and
/                   if containing special characters such as "&" or "%" must
/                   also be enclosed by %nrstr( )  )
/ out               (pos) Either the full path name of the output folder for the
/                   created sas datasets (same naming rules as above) or an
/                   existing libref contained in round brackets such as (WORK)
/                   (no quotes)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%macro xpt2sas(infolder,out);

  %local pipestr;
  %let pipestr=%str(%')dir &infolder.*.xpt%str(%');

  filename _inpipe pipe %unquote(&pipestr);
  libname _outsas &out;

  data _null_;
    retain inxpt &infolder;
    length xptname $ 40;
    infile _inpipe;
    input;
    if index(_infile_,".xpt") then do;
      xptname=scan(_infile_,countw(substr(_infile_,1,index(_infile_,".xpt"))," ")," ");
      call execute("libname _xptin xport %nrstr('"||trim(inxpt)||trim(xptname)||"');");
      call execute('proc copy in=_xptin out=_outsas;run;');
      call execute('libname _xptin clear;');
    end;
  run;

  filename _inpipe clear;
  libname _outsas clear;

%mend xpt2sas;
