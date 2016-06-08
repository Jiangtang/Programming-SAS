%macro setup(status=draft,maclib=,drive=,username=,password=,proxy=);
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
                               If DRIVE = webdav, then webdev libnames will be 
                                issued.
  PROXY    optional            Name of proxy server if you are executing SAS
                                outside of SDD and behind a VPN.
  -----------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

    %setup

    This simple call issues LIBNAMEs to the draft directories and SAS options.


    %setup(status=final)

    This call issues LIBNAMEs to the final directories and issues SAS options.


  -----------------------------------------------------------------------------
  Ver#  Author           Broad-Use MODULE History Description
  ----  ---------------- ------------------------------------------------------
  1.0   Gregory Steffens Original version of the macro
  **eoh************************************************************************/

%let status = %upcase(&status);
%local dir dirnum librc proxyoption;

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
    %let dir26 = &drive:\cdisc_pilot\DATA\ZERO_OBS\SDTM_wo_derived\;
    %let dir27 = &drive:\cdisc_pilot\DATA\ZERO_OBS\SDTM\;
    %let dir28 = &drive:\cdisc_pilot\DATA\ZERO_OBS\ADAM\;
    %let dir29 = &drive:\cdisc_pilot\PROGRAMS\DRAFT\sas_macros\;
    %let dir30 = &drive:\cdisc_pilot\PROGRAMS\FINAL\sas_macros\;
    %let dir31 = &drive:\cdisc_pilot\METADATA\DRAFT\SDTM_wo_derived\;
    %let dir32 = &drive:\cdisc_pilot\METADATA\FINAL\SDTM_wo_derived\;
    %do dirnum = 1 %to 32;
      %if ^ %sysfunc(fileexist(&&dir&dirnum)) %then %do;
        x "mkdir &&dir&dirnum";
      %end;
    %end;
    %if %bquote(&maclib) = %then %let maclib = "&dir29" "&dir30";
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
    *--------------------------------------------------------------------------;
    * Metadata in Greg Steffens format for SDTM_wo_derived data sets;
    *--------------------------------------------------------------------------;
    libname metasdtw "&drive:\cdisc_pilot\METADATA\&status\SDTM_wo_derived\";
    *--------------------------------------------------------------------------;
    * SDTM structured data without derivations - Zero Obs;
    *--------------------------------------------------------------------------;
    libname sdtm_wo0  "&drive:\cdisc_pilot\DATA\ZERO_OBS\SDTM_wo_derived\";
    *--------------------------------------------------------------------------;
    * ADAM structured data with derivations - Zero obs;
    *--------------------------------------------------------------------------;
    libname adam0     "&drive:\cdisc_pilot\DATA\ZERO_OBS\ADAM\";
    *--------------------------------------------------------------------------;
    * SDTM structured data with derivations - Zero obs;
    *--------------------------------------------------------------------------;
    libname sdtm0     "&drive:\cdisc_pilot\DATA\ZERO_OBS\SDTM\";
  %end;
  %else %if ^ %sysfunc(fileexist(&drive:\cdisc_pilot\)) &
   %bquote(%upcase(&drive)) ^= WEBDAV %then %do;
    %put UNOTE: cdisc_pilot directory not found on drive &drive:;
    %goto endmac;
  %end;
%end;
%* sysscp ^= WIN or sysscp = SUN or _sddusr_ ^= to determine if in SDD;
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
  %if %bquote(&proxy) ^= %then %let proxyoption = proxy=&proxy;
  *----------------------------------------------------------------------------;
  * STEP 1: SDTM structured data without derivations;
  *----------------------------------------------------------------------------;
  %bquote(* libname sdtm_wo BASE 
   "https://sddsazerac.sas.com/webdav/DATA/&status/SDTM_wo_derived/"
   webdav user="&username" password="password" access=readonly &proxyoption;)
  %let librc = %sysfunc(libname(sdtm_wo,
   https://sddsazerac.sas.com/webdav/DATA/&status/SDTM_wo_derived/,base,
   webdav user="&username" password="&password" access=readonly &proxyoption));
  %if &librc ^= 0 %then %do;
    %put %sysfunc(sysmsg());
    %put ending setup macro;
    %goto endmac;
  %end;
  *----------------------------------------------------------------------------;
  * STEP 2: ADAM structured data with derivations;
  *----------------------------------------------------------------------------;
  %bquote(* libname adam BASE 
   "https://sddsazerac.sas.com/webdav/DATA/&status/ADAM/"
   webdav user="&username" password="password" &proxyoption;)
  %let librc = %sysfunc(libname(adam,
   https://sddsazerac.sas.com/webdav/DATA/&status/ADAM/,base,
   webdav user="&username" password="&password" &proxyoption));
  %if &librc ^= 0 %then %do;
    %put %sysfunc(sysmsg());
    %put ending setup macro;
    %goto endmac;
  %end;
  *----------------------------------------------------------------------------;
  * STEP 3: SDTM structured data with derivations;
  *----------------------------------------------------------------------------;
  %bquote(* libname sdtm BASE 
   "https://sddsazerac.sas.com/webdav/DATA/&status/SDTM/"
   webdav user="&username" password="password" &proxyoption;)
  %let librc = %sysfunc(libname(sdtm,
   https://sddsazerac.sas.com/webdav/DATA/&status/SDTM/,base,
   webdav user="&username" password="&password" &proxyoption));
  %if &librc ^= 0 %then %do;
    %put %sysfunc(sysmsg());
    %put ending setup macro;
    %goto endmac;
  %end;
  *----------------------------------------------------------------------------;
  * Metadata in Greg Steffens format for ADAM data sets;
  *----------------------------------------------------------------------------;
  %bquote(* libname metaadam BASE 
   "https://sddsazerac.sas.com/webdav/METADATA/&status/ADAM/"
   webdav user="&username" password="password" &proxyoption;)
  %let librc = %sysfunc(libname(metaadam,
   https://sddsazerac.sas.com/webdav/METADATA/&status/ADAM/,base,
   webdav user="&username" password="&password" &proxyoption));
  %if &librc ^= 0 %then %do;
    %put %sysfunc(sysmsg());
    %put ending setup macro;
    %goto endmac;
  %end;
  *----------------------------------------------------------------------------;
  * Metadata in Greg Steffens format for SDTM data sets;
  *----------------------------------------------------------------------------;
  %bquote(* libname metasdtm BASE 
   "https://sddsazerac.sas.com/webdav/METADATA/&status/SDTM/"
   webdav user="&username" password="password" &proxyoption;)
  %let librc = %sysfunc(libname(metasdtm,
   https://sddsazerac.sas.com/webdav/METADATA/&status/SDTM/,base,
   webdav user="&username" password="&password" &proxyoption));
  %if &librc ^= 0 %then %do;
    %put %sysfunc(sysmsg());
    %put ending setup macro;
    %goto endmac;
  %end;
  *----------------------------------------------------------------------------;
  * Metadata in Greg Steffens format for SDTM_wo_derived data sets;
  *----------------------------------------------------------------------------;
  %bquote(* libname metasdtw BASE 
   "https://sddsazerac.sas.com/webdav/METADATA/&status/SDTM_wo_derived/"
   webdav user="&username" password="password" &proxyoption;)
  %let librc = %sysfunc(libname(metasdtw,
   https://sddsazerac.sas.com/webdav/METADATA/&status/SDTM_wo_derived/,base,
   webdav user="&username" password="&password" &proxyoption));
  %if &librc ^= 0 %then %do;
    %put %sysfunc(sysmsg());
    %put ending setup macro;
    %goto endmac;
  %end;
  *----------------------------------------------------------------------------;
  * SDTM structured data without derivations - Zero observations;
  *----------------------------------------------------------------------------;
  %bquote(* libname sdtm_wo0 BASE 
   "https://sddsazerac.sas.com/webdav/DATA/ZERO_OBS/SDTM_wo_derived/"
   webdav user="&username" password="password" &proxyoption;)
  %let librc = %sysfunc(libname(sdtm_wo0,
   https://sddsazerac.sas.com/webdav/DATA/ZERO_OBS/SDTM_wo_derived/,base,
   webdav user="&username" password="&password" &proxyoption));
  %if &librc ^= 0 %then %do;
    %put %sysfunc(sysmsg());
    %put ending setup macro;
    %goto endmac;
  %end;
  *----------------------------------------------------------------------------;
  * ADAM structured data with derivations - Zero observations;
  *----------------------------------------------------------------------------;
  %bquote(* libname adam0 BASE 
   "https://sddsazerac.sas.com/webdav/DATA/ZERO_OBS/ADAM/"
   webdav user="&username" password="password" &proxyoption;)
  %let librc = %sysfunc(libname(adam0,
   https://sddsazerac.sas.com/webdav/DATA/ZERO_OBS/ADAM/,base,
   webdav user="&username" password="&password" &proxyoption));
  %if &librc ^= 0 %then %do;
    %put %sysfunc(sysmsg());
    %put ending setup macro;
    %goto endmac;
  %end;
  *----------------------------------------------------------------------------;
  * SDTM structured data with derivations - Zero observations;
  *----------------------------------------------------------------------------;
  %bquote(* libname sdtm0 BASE 
   "https://sddsazerac.sas.com/webdav/DATA/ZERO_OBS/SDTM/"
   webdav user="&username" password="password" &proxyoption;)
  %let librc = %sysfunc(libname(sdtm0,
   https://sddsazerac.sas.com/webdav/DATA/ZERO_OBS/SDTM/,base,
   webdav user="&username" password="&password" &proxyoption));
  %if &librc ^= 0 %then %do;
    %put %sysfunc(sysmsg());
    %put ending setup macro;
    %goto endmac;
  %end;
%end;

%endmac:

%if %bquote(&maclib) ^= %then %do;
  options sasautos=(&maclib);
%end;

%global g_drive g_status;
%let g_drive = &drive;
%let g_status = &status;

%mend;
