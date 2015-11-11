/*<pre><b>
/ Program   : mksharemac.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 02-Jun-2014
/ Purpose   : To create a shared macro catalog under the WORK library location
/             with the libref SHAREMAC and catalog name SASMACR and optionally
/             copy a list of compiled macros across from WORK.SASMACR to this
/             library.
/ SubMacros : none
/ Notes     : This macro follows the convention for sharing resources with
/             remote sessions as explained on the web site where this macro is
/             stored (see the page on "Managing your Multiprocessing Sessions").
/             You are expected to pass the libref SHAREMAC over to the remote
/             session in the INHERITLIB() option either by using the %rsubmitter
/             macro or by following the same conventions in that macro.
/
/             The list of macros to copy is optional. This can be done manually
/             at a later stage instead.
/
/ Usage     : %mksharemac(mymac1 mymac2)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ copy              (pos - optional) List of compiled macro names separated by
/                   spaces that you want to copy to the shared macro library.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  02Jun14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: mksharemac v1.0;

%macro mksharemac(copy);

  %local path;

  *- Create a directory under WORK to store shared macros in   -;
  *- (use a different slash depending on the operating system) -;

  %if %sysfunc(subpad(&sysscp,1,3)) EQ WIN %then
    %let path=%sysfunc(pathname(work))\macros; 
  %else %let path=%sysfunc(pathname(work))/macros; 


  *- issue command to create the directory and wait -;
  systask command "mkdir ""&path"" " taskname=mkdir; 


  *- make sure the shared macros directory creation has ended -; 
  waitfor mkdir; 

  
  *- give the shared macros library the libref "sharemac" -; 
  libname sharemac "&path"; 


  *- Copy the list of macros from WORK.SASMACR to SHAREMAC.SASMACR   -;
  *- (this is an optional step - you might want to do this manually) -;
  %if %length(&copy) %then %do;
    *- copy locally compiled macros to the shared macros catalog -; 
    proc catalog c=work.sasmacr et=macro; 
      copy out=sharemac.sasmacr; 
      select &copy; 
    quit; 
  %end;

%mend mksharemac;
