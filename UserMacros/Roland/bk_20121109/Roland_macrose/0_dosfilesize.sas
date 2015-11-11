/*<pre><b>
/ Program      : dosfilesize.sas
/ Version      : 1.1
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : Function-style macro to return a DOS file size
/ SubMacros    : %qdosfileinfo
/ Notes        : This is a shell macro for calling the %qdosfileinfo macro to
/                get a DOS file size. See the %qdosfileinfo macro for other
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
/ rrb  12Oct09         Call to %dosfileinfo changed to call to %qdosfileinfo due
/                      to macro renaming plus the %unquote() function used
/                      (v1.1)
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dosfilesize v1.1;

%macro dosfilesize(dosfile);
%unquote(%qdosfileinfo(&dosfile,z))
%mend dosfilesize;
