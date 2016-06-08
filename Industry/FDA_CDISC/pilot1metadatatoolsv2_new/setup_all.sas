%macro setup(status=draft,maclib=,drive=,rtf_file=,username=,password=);
  /*soh*************************************************************************
   Macro Name               : setup
   Description              : Creates a standard program execution environment
                               for SAS programs created in the CDISC SDTM/ADAM
                               pilot project.  Standard librefs and SAS options
                               are defined which are the same for off-line
                               programming and SDD programming.  This minimizes
                               the amount of code that needs to be changed when
                               moving the code from off-line to SDD.
  -----------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
  --------- -------- -------- -------------------------------------------------
  STATUS    optional DRAFT    The validation status of the code -
                               DRAFT or FINAL
                               This determines whether the draft or final 
                               directories are used in the LIBNAMEs.
  RTF_FILE  optional          If specified this defines the filename of the 
                               rtf file specified in the ODS statement.  The
                               directory path and filetype should not be
                               specified - these are derived from the STATUS
                               parameter and an assumption of a standard
                               directory tree that includes a TFLs directory.
                               If the RTF_FILE parameter is not specified in
                               the macro call then an ODS statement is not
                               issued.
  MACLIB    optional          The macro library directory or directories.  If
                               specified, an OPTIONS SASAUTOS statment is 
                               issued.
  USERNAME  optional          Username of SDD account
  PASSWORD  optional          Password of SDD account for user USERNAME
  DRIVE     optional  C       This macro will create the standard directory
                               tree on your C drive when calling the macro
                               outside of SDD.  The DRIVE parameter allows you
                               to write the directory tree to another drive
                               letter.
  -----------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

    %setup

    This simple call issues LIBNAMEs to the draft directories and SAS options.


    %setup(status=final)

    This call issues LIBNAMEs to the final directories and issues SAS options.


    %setup(rtf_file=ae_severity)

    This call ads an ODS statment to the rtf destination and defines the output
     filename to be ae_severity.  The full destination is 
     &drive:\cdisc_pilot\PROGRAMS\&status\TFLs\ae_severity.rtf
     Where status is the value of the status parameter.
  -----------------------------------------------------------------------------
  Ver#  Author           Broad-Use MODULE History Description
  ----  ---------------- ------------------------------------------------------
  1.0   Gregory Steffens Original version of the macro
  **eoh************************************************************************/

%let status = %upcase(&status);
%local dir dirnum librc;

options mprint;

%if &sysscp = WIN %then %do;
  %if %bquote(&drive) = %then %do;
    %if %sysfunc(fileexist(c:\)) %then %let drive = c;
    %else %do;
      %put UWARNING: Cannot locate a drive - ending macro;
	  %goto endmac;
    %end;
  %end;
  options xmin noxwait;
  %if %bquote(&drive) ^= & %bquote(%upcase(&drive)) ^= WEBDAV %then %do;
    %let dir1  = &drive:\cdisc_pilot\;
    %let dir2  = &drive:\cdisc_pilot\DATA\;
    %let dir3  = &drive:\cdisc_pilot\DATA\DRAFT\;
    %let dir4  = &drive:\cdisc_pilot\DATA\FINAL\;
    %let dir5  = &drive:\cdisc_pilot\DATA\DRAFT\SDTM_wo_derived\;
    %let dir6  = &drive:\cdisc_pilot\DATA\FINAL\SDTM_wo_derived\;
    %let dir7  = &drive:\cdisc_pilot\DATA\DRAFT\ADAM\;
    %let dir8  = &drive:\cdisc_pilot\DATA\FINAL\ADAM\;
    %let dir9  = &drive:\cdisc_pilot\DATA\DRAFT\SDTM\;
    %let dir10 = &drive:\cdisc_pilot\DATA\FINAL\SDTM\;
    %let dir11 = &drive:\cdisc_pilot\METADATA\DRAFT\;
    %let dir12 = &drive:\cdisc_pilot\METADATA\FINAL\;
    %let dir13 = &drive:\cdisc_pilot\METADATA\DRAFT\ADAM\;
    %let dir14 = &drive:\cdisc_pilot\METADATA\FINAL\ADAM\;
    %let dir15 = &drive:\cdisc_pilot\METADATA\DRAFT\SDTM\;
    %let dir16 = &drive:\cdisc_pilot\METADATA\FINAL\SDTM\;
    %let dir17 = &drive:\cdisc_pilot\PROGRAMS\;
    %let dir18 = &drive:\cdisc_pilot\PROGRAMS\DRAFT\;
    %let dir19 = &drive:\cdisc_pilot\PROGRAMS\FINAL\;
    %let dir20 = &drive:\cdisc_pilot\PROGRAMS\DRAFT\ADAM\;
    %let dir21 = &drive:\cdisc_pilot\PROGRAMS\FINAL\ADAM\;
    %let dir22 = &drive:\cdisc_pilot\PROGRAMS\DRAFT\SDTM\;
    %let dir23 = &drive:\cdisc_pilot\PROGRAMS\FINAL\SDTM\;
    %let dir24 = &drive:\cdisc_pilot\PROGRAMS\DRAFT\TFLs\;
    %let dir25 = &drive:\cdisc_pilot\PROGRAMS\FINAL\TFLs\;
    %do dirnum = 1 %to 25;
      %if ^ %sysfunc(fileexist(&&dir&dirnum)) %then %do;
        x "mkdir &&dir&dirnum";
      %end;
    %end;
    *--------------------------------------------------------------------------;
    * STEP 1: SDTM structured data without derivations;
    *--------------------------------------------------------------------------;
    libname sdtm_wo  "&drive:\cdisc_pilot\DATA\&status\SDTM_wo_derived\"
     access=readonly;
    *--------------------------------------------------------------------------;
    * STEP 2: ADAM structured data with derivations;
    *--------------------------------------------------------------------------;
    libname adam     "&drive:\cdisc_pilot\DATA\&status\ADAM\";
    *--------------------------------------------------------------------------;
    * STEP 3: SDTM structured data with derivations;
    *--------------------------------------------------------------------------;
    libname sdtm     "&drive:\cdisc_pilot\DATA\&status\SDTM\";
    *--------------------------------------------------------------------------;
    * Metadata in Greg Steffens format for ADAM data sets;
    *--------------------------------------------------------------------------;
    libname metaadam "&drive:\cdisc_pilot\METADATA\&status\ADAM\";
    *--------------------------------------------------------------------------;
    * Metadata in Greg Steffens format for SDTM data sets;
    *--------------------------------------------------------------------------;
    libname metasdtm "&drive:\cdisc_pilot\METADATA\&status\SDTM\";
  %end;
  %else %if ^ %sysfunc(fileexist(&drive:\cdisc_pilot\)) &
   %bquote(%upcase(&drive)) ^= WEBDAV %then %do;
    %put UNOTE: cdisc_pilot directory not found on drive &drive:;
    %goto endmac;
  %end;
%end;
%* sysscp = WIN or sysscp = SUN or _sddusr_ ^= to determine if in SDD;
%if &sysscp ^= WIN | %bquote(%upcase(&drive)) = WEBDAV %then %do;
  %if %bquote(&username) = | %bquote(&password) = %then %do;
    %window pw 
     columns=45 rows=15 icolumn=5 irow=20
     #4 @15 'SDD Authentication' attr=highlight
     #6 @10 'Username:' 
     #6 @20 username 15 required=yes attr=underline
     #8 @10 'Password:' 
     #8 @20 password 15 display=no required=yes attr=underline
    ;
    %display pw;
  %end;
  %put username=&username password=&password;
  *----------------------------------------------------------------------------;
  * STEP 1: SDTM structured data without derivations;
  *----------------------------------------------------------------------------;
  %bquote(* libname sdtm_wo BASE 
   "https://sddsazerac.sas.com/webdav/DATA/&status/SDTM_wo_derived/"
   webdav user="&username" password="password" access=readonly;)
  %let librc = %sysfunc(libname(sdtm_wo,
   https://sddsazerac.sas.com/webdav/DATA/&status/SDTM_wo_derived/,base,
   webdav user="&username" password="&password" access=readonly));
  %if &librc ^= 0 %then %put %sysfunc(sysmsg());
  *----------------------------------------------------------------------------;
  * STEP 2: ADAM structured data with derivations;
  *----------------------------------------------------------------------------;
  %bquote(* libname adam BASE 
   "https://sddsazerac.sas.com/webdav/DATA/&status/ADAM/"
   webdav user="&username" password="password";)
  %let librc = %sysfunc(libname(adam,
   https://sddsazerac.sas.com/webdav/DATA/&status/ADAM/,base,
   webdav user="&username" password="&password"));
  %if &librc ^= 0 %then %put %sysfunc(sysmsg());
  *----------------------------------------------------------------------------;
  * STEP 3: SDTM structured data with derivations;
  *----------------------------------------------------------------------------;
  %bquote(* libname sdtm BASE 
   "https://sddsazerac.sas.com/webdav/DATA/&status/SDTM/"
   webdav user="&username" password="password";)
  %let librc = %sysfunc(libname(sdtm,
   https://sddsazerac.sas.com/webdav/DATA/&status/SDTM/,base,
   webdav user="&username" password="&password"));
  %if &librc ^= 0 %then %put %sysfunc(sysmsg());
  *----------------------------------------------------------------------------;
  * Metadata in Greg Steffens format for ADAM data sets;
  *----------------------------------------------------------------------------;
  %bquote(* libname metaadam BASE 
   "https://sddsazerac.sas.com/webdav/METADATA/&status/ADAM/"
   webdav user="&username" password="password";)
  %let librc = %sysfunc(libname(metaadam,
   https://sddsazerac.sas.com/webdav/METADATA/&status/ADAM/,base,
   webdav user="&username" password="&password"));
  %if &librc ^= 0 %then %put %sysfunc(sysmsg());
  *----------------------------------------------------------------------------;
  * Metadata in Greg Steffens format for SDTM data sets;
  *----------------------------------------------------------------------------;
  %bquote(* libname metasdtm BASE 
   "https://sddsazerac.sas.com/webdav/METADATA/&status/SDTM/"
   webdav user="&username" password="password";)
  %let librc = %sysfunc(libname(metasdtm,
   https://sddsazerac.sas.com/webdav/METADATA/&status/SDTM/,base,
   webdav user="&username" password="&password"));
  %if &librc ^= 0 %then %put %sysfunc(sysmsg());
%end;

%if %bquote(&rtf_file) ^= %then %do;
  ods rtf file="&drive:\cdisc_pilot\PROGRAMS\&status\TFLs\&rtf_file..rtf";
%end;

%if %bquote(&maclib) ^= %then %do;
  options sasautos=(&maclib);
%end;

%endmac:
%mend;
