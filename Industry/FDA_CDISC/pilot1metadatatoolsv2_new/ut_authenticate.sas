%macro ut_authenticate(object=_default_,user=_default_,pass=_default_,
 authfile=_default_,prompt=_default_,debug=_default_);
  /*soh*************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : ut_authenticate
   TYPE                     : utility
   DESCRIPTION              : Reads user id and password from a file for a
                               specified object or prompts the user if this file
                               is not found.  Used to provide authentication
                               information to calling macros so userid and
                               password do not need to be hardcoded in SAS
                               programs.
   DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\General\
                               Broad_use_modules\SAS\ut_authenticate\
                               ut_authenticate DL.doc
   SOFTWARE/VERSION#        : SAS/Version 8 and 9
   INFRASTRUCTURE           : MS Windows, MVS, Unix
   BROAD-USE MODULES        : %ut_logical, %ut_errmsg, %ut_parmdef
   INPUT                    : as defined by the AUTHFILE parameter
   OUTPUT                   : N/A
   VALIDATION LEVEL         : 6
   REGULATORY STATUS        : GCP
   TEMPORARY OBJECT PREFIX  : _au
  ------------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
  --------- -------- -------- --------------------------------------------------
   OBJECT   optional          Name of object to authenticate to.  This can be
                               the name of a server or an IP address or anything
                               else.  The value of OBJECT must match the first
                               token of a line in AUTHFILE, if the AUTHFILE
                               is used.  If AUTHFILE is not used then this
                               macro will prompt for userid and password for
                               the object specfied with the OBJECT parameter.
   USER     required username Name of macro variable in the calling macro that
                               this macro will place the username in.
                               A userid can also be passed into this macro by
                               by assigning a userid to the macro variable 
                               whose name is specified by the USER parameter.
   PASS     required password Name of macro variable in the calling macro that
                               this macro will place the password in.
                               A password can be passed into this macro by
                               by assigning a password to the macro variable 
                               whose name is specified by the PASS parameter.
   AUTHFILE optional see note Name of the file containing the OBJECT, USER and
                               PASS information.  AUTHFILE can be used to store
                               userids and passwords for any number of objects.
                               If the AUTHFILE is not found then this macro will
                               prompt the user for this information.
   PROMPT   required 1        %ut_logical value specifying whether to prompt for
                               the userid if it is not specified with the 
                               USER parameter or found in AUTHFILE and 
                               the password if it is not specified with the 
                               PASS parameter or found in AUTHFILE.
   DEBUG    required 0        %ut_logical value specifying whether to turn debug 
                               mode on or off
  ------------------------------------------------------------------------------
  Usage Notes:

  This macro is recommended to be used when you need to put a userid/password
  into a SAS program, such as when accessing oracle, establishing remote
  sessions with SAS/Connect and when issuing ftp filenames.  This will allow
  you to avoid placing userid/passwords in your program files.  It also helps
  when rerunning a program over a period of time when you have changed your
  password - no change to the program is required when a password is changed
  because the password is looked up in AUTHFILE each time it is executed or
  the password is prompted for if AUTHFILE is not used.

  Default AUTHFILE is the home directory .netrc for unix, for MS windows
  searches d:\ c:\ h:\ for a file named netrc, for MVS <userid>.netrc.  If
  this default AUTHFILE is not found then a message is displayed in the log
  file and the macro continues.  The user is prompted for userid and password
  if PROMPT is true.

  This macro ignores the keywords "machine", "login" and "password", to be
  compatible with the unix standard for this file.  But this macro requires
  that the machine/object be first, the login/userid be second and the password
  be third in one line of AUTHFILE.

  The format of the lines in AUTHFILE are therefore:
      mvs rmxxxxx mymvspassword
      OR
      machine mvs login rmxxxxx password mymvspassword
  Multiple lines in AUTHFILE may exist to allow for different objects and
  userids.  The first token of the line is the OBJECT, the second the USER and
  the third is the PASS.

  It is recommended that the macro variables specified in the USER and PASS 
  parameters be set to null after the macro calling ut_authenticate is finished
  with them.  This will ensure that the password does not exist in temporary 
  macro variables after their use.

  It is recommended to enter the PROC PWENCODE encoded password in the netrc
  file to enhance security.

  Note that SAS version 8 on MVS does not find the default AUTHFILE of .netrc.
  This is due to a bug with the fileexist function in SAS.  To use an AUTHFILE
  on MVS, use SAS version 9 or specify the AUTHFILE without a leading dot.
  ------------------------------------------------------------------------------
  Assumptions:

  ------------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

  %ut_authenticate(object=mvs)

  ------------------------------------------------------------------------------
     Author	&							Broad-Use MODULE History
Ver#  Peer Reviewer   Request #       Description
---- ---------------- --------------- ------------------------------------------
1.0  Gregory Steffens BMRMSR17JUL2007 Original version of the broad-use module
      
  **eoh************************************************************************/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%ut_parmdef(object,_pdmacroname=ut_authenticate,_pdrequired=0)
%ut_parmdef(user,username,_pdmacroname=ut_authenticate,_pdrequired=1)
%put (ut_authenticate) &user=&&&user;
%ut_parmdef(pass,password,_pdmacroname=ut_authenticate,_pdrequired=1)
%ut_parmdef(authfile,_pdmacroname=ut_authenticate,_pdrequired=0)
%ut_parmdef(prompt,1,_pdmacroname=ut_authenticate,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=ut_authenticate,_pdrequired=1)
%local authfile_name rc fid found obj userid pswd fileref line_start;
%ut_logical(prompt)
%ut_logical(debug)
%if &sysver ^= 8.2 %then %do;
  %if ^ %sysfunc(symexist(&user)) %then %do;
    %ut_errmsg(msg=the macro variable specified to the user parameter does not
     exist user=&user,type=warning,macroname=ut_authenticate)
    %goto termmac;
  %end;
  %if ^ %sysfunc(symexist(&pass)) %then %do;
    %ut_errmsg(msg=the macro variable specified to the pass parameter does not
     exist pass=&pass,
     type=warning,macroname=ut_authenticate)
    %goto termmac;
  %end;
%end;
%* ============================================================================;
%*  Assign default to AUTHFILE parameter;
%*=============================================================================;
%if %bquote(&authfile) = %then %do;
  %let authfile_name = netrc;
  %if %upcase(&sysscp) = WIN %then %do;
    %if %sysfunc(fileexist(d:\&authfile_name)) %then
     %let authfile = d:\&authfile_name.;
    %else %if %sysfunc(fileexist(c:\&authfile_name)) %then
     %let authfile = c:\&authfile_name;
    %else %if %sysfunc(fileexist(h:\&authfile_name)) %then
     %let authfile = h:\&authfile_name;
    %else %do;
      %ut_errmsg(msg="authentication file &authfile_name not in d:\ c:\ h:\",
       macroname=ut_authenticate,print=0)
    %end;
  %end;
  %else %if &sysscp = SUN 4 | &sysscp = SUN 64 | &sysscp = RS6000 |
   &sysscp = ALXOSF | &sysscp = HP 300 | &sysscp = HP 800 | &sysscp = LINUX |
   &sysscp = RS6000 | &sysscp = SUN 3 | &sysscp = ALXOSF %then %do;
    %if %sysfunc(fileexist(~/.&authfile_name)) %then
     %let authfile = ~/.&authfile_name;
    %else %do;
      %ut_errmsg(msg=authentication file (~/.&authfile_name) not  found,
       macroname=ut_authenticate,print=0)
    %end;
  %end;
  %else %if &sysscp = OS %then %do;
    %if %sysfunc(fileexist(.&authfile_name)) %then
     %let authfile = .&authfile_name;
    %else %do;
      %ut_errmsg(msg=authentication file (.&authfile_name) not  found,
       macroname=ut_authenticate,print=0)
    %end;    
  %end;
  %else %do;
    %ut_errmsg(msg="Operating system not recognised &sysscp (&sysscpl)",
     macroname=ut_authenticate)
  %end;
%end;
%else %if ^ %sysfunc(fileexist(&authfile)) %then %do;
  %ut_errmsg(msg=Specified authentication file (&authfile) not found,
   macroname=ut_authenticate,print=0)
  %let authfile =;
%end;
%if %bquote(&authfile) ^= %then %do;
  %if %bquote(&object) = %then %do;
    %ut_errmsg(msg="the OBJECT parameter is null and AUTHFILE is &authfile - "
     "ending macro",macroname=ut_authenticate,type=warning,print=0)
    %let authfile =;
    %goto endmac;
  %end;
  %* ==========================================================================;
  %*  Read file containing authentication information in tcp/ip netrc format;
  %*===========================================================================;
  %let fileref = _authent;
  %if &debug %then %put (ut_authenticate) fileref=&fileref authfile=&authfile;
  %let rc = %sysfunc(filename(fileref,&authfile));
  %if &debug %then
   %put (ut_authenticate) fileref (&fileref) filename on &authfile rc=&rc;
  %if &rc ^= 0 %then %do;
    %ut_errmsg(msg="&authfile filename statement failed rc=&rc",
     macroname=ut_authenticate)
  %end;
  %let fid = %sysfunc(fopen(&fileref));
  %if &debug %then %put (ut_authenticate) file open of fileref=&fileref id=&fid;
  %if &fid > 0 %then %do;
    %let found = 0;
    %do %while (%sysfunc(fread(&fid)) = 0 & &found = 0);
      %let rc = (%sysfunc(fget(&fid,obj)) = 0);
      %if &debug %then %put (ut_authenticate) obj=&obj;
      %if %bquote(%upcase(&obj)) = MACHINE %then %do;
        %let rc = (%sysfunc(fget(&fid,obj)) = 0);
        %if &debug %then %put (ut_authenticate) obj=&obj after machine keyword;
      %end;
      %if %bquote(%upcase(&obj)) = %bquote(%upcase(&object)) %then %do;
        %let rc = (%sysfunc(fget(&fid,userid)) = 0);
        %if %bquote(%upcase(&userid)) = LOGIN %then %do;
          %let rc = (%sysfunc(fget(&fid,userid)) = 0);
          %if &debug %then
           %put UNOTE (ut_authenticate) userid=&userid after login keyword;
        %end;
        %if %bquote(%upcase(&userid)) = %bquote(%upcase(&&&user)) |
         %bquote(&&&user) = %then %do;
          %let rc   = (%sysfunc(fget(&fid,pswd)) = 0);
          %if %bquote(%upcase(&pswd)) = PASSWORD %then %do;
            %let rc = (%sysfunc(fget(&fid,pswd)) = 0);
            %if &debug %then
             %put (ut_authenticate) pswd=&pswd after password keyword;
          %end;
          %let found = 1;
        %end;
        %else %let userid=;
        %if &debug %then
         %put (ut_authenticate) obj=&obj userid=&userid pswd=&pswd;
      %end;
    %end;
    %let rc = %sysfunc(fclose(&fid));
    %if ^ &found %then %do;
      %ut_errmsg(
       msg="object &object not  found in authfile:&authfile user:&&&user",
       macroname=ut_authenticate,print=0)
    %end;
  %end;
  %else %do;
    %put (ut_authenticate) unable to open authentication file &authfile
     fid=&fid;
  %end;
  %if &debug %then %put (ut_authenticate) fid=&fid;
  %let rc = %sysfunc(filename(fileref));
  %if &debug %then %put (ut_authenticate) filename clear rc = &rc;
  %* ==========================================================================;
  %* Place userid and password information in macro variables whose;
  %*  names are defined by the parameters user and pass;
  %*===========================================================================;
  %if %bquote(&&&user) = %then %let &user = &userid;
  %if %bquote(&&&pass) = %then %let &pass = &pswd;
  %if &debug %then %put (ut_authenticate) &user=&&&user  &pass=&&&pass;
%end;
%if &sysver = 8.2 & %bquote(&&&pass) ^= & %substr(%str(&&&pass ),1,1) = { %then
 %do;
  %ut_errmsg(msg=PWENCODE passwords are not supportable in version 8 of SAS,
   macroname=ut_authenticate,print=0)
 %let &pass=;
%end;
%endmac:
%* ============================================================================;
%* Prompt user for userid and password if not found in netrc file;
%*  Assign default userid as current userid if userid not specified in call;
%* ============================================================================;
%if &prompt & (%bquote(&&&user) = | %bquote(&&&pass) =) %then %do;
  %* change following condition to if batch in list when not possible
   instead of not in list of when prompt is possible
   or just prompt and let sas issue message if not possible;
  %if %upcase(&sysprocessname) ^= DMS PROCESS &
   %upcase(&sysprocessname) ^= PROGRAM WINDOW &
   %upcase(&sysprocessname) ^= PROGRAM SYSIN &
   %scan(%upcase(&sysprocessname),1,%str( )) ^= PROGRAM
   %then %do;
    %ut_errmsg(msg=PROMPT is true but SAS cannot display a prompt for
     userid/password in sysprocessname = &sysprocessname,
     macroname=ut_authenticate,print=0)
  %end;
  %else %do;
    %if %bquote(&&&user) = %then %let &user = &sysuserid;
    %if %bquote(&object) ^= %then %do;
      %window ut_authenticate columns=40 rows=18 icolumn=10 irow=10 color=grey
       #2 @3 "Authentication Information for" color=black
       #3 @3 "&object" color=black
       #5 @3 "Userid:" color=black
       #7 @3 &user 32 display=yes attr=underline color=blue
       #10 @3 "Password:" color=black
       #12 @3 &pass 32 display=no attr=underline color=blue
      ;
    %end;
    %else %do;
      %window ut_authenticate columns=40 rows=18 icolumn=10 irow=10 color=grey
       #2 @3 "No OBJECT specified" color=black
       #5 @3 "Userid:" color=black
       #7 @3 &user 32 display=yes attr=underline color=blue
       #10 @3 "Password:" color=black
       #12 @3 &pass 32 display=no attr=underline color=blue
      ;
    %end;
    %display ut_authenticate;
  %end;
%end;
%* ============================================================================;
%* Display user and pass only when debug is true;
%* ============================================================================;
%if &debug %then %do;
  %put (ut_authenticate) &user=&&&user  &pass=&&&pass;
%end;
%termmac:
%mend;
