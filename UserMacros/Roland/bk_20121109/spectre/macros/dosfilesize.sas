/*<pre><b>
/ Program      : dosfilesize.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 30-Jul-2007
/ Purpose      : Function-style macro to return a DOS file size
/ SubMacros    : %dosfileinfo
/ Notes        : This is a shell macro for calling the %dosfileinfo macro to get
/                a DOS file size. See the %dosfileinfo macro for other
/                information you can extract about a DOS file.
/ Usage        : %let filesize=%dosfilesize(C:\spectre\unistats.html);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dosfile           (pos) DOS file name
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  30Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dosfilesize v1.0;

%macro dosfilesize(dosfile);
%dosfileinfo(&dosfile,z)
%mend;
