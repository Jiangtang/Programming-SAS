/*<pre><b>
/ Program      : latitle.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : To create a left-aligned title
/ SubMacros    : none
/ Notes        : The title must be in quotes. Leading spaces are allowed.
/ Usage        : %latitle(2,"  second title indented two spaces")
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ num               (pos) title number
/ string            (pos) (in quotes) Title to left-align
/ pagemark=no       By default, do not add a page marker (to receive the Page x
/                   of Y label) in the rightmost column
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19Oct05         Add pagemark= parameter
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: latitle v1.0;

%macro latitle(num,string,pagemark=no);
  %local ls;
  %let ls=%sysfunc(getoption(linesize));

  %if not %length(&pagemark) %then %let pagemark=no;
  %let pagemark=%upcase(%substr(&pagemark,1,1));

  %if "&pagemark" EQ "Y" %then %do;
    title&num &string "%sysfunc(repeat(%str( ),&ls-%length(&string)))" 'FF'x;
  %end;
  %else %do;
    title&num &string "%sysfunc(repeat(%str( ),199))";
  %end;
%mend latitle;
