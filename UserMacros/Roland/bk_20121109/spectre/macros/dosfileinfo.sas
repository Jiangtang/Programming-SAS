/*<pre><b>
/ Program      : dosfileinfo.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 30-Jul-2007
/ Purpose      : Function-style macro to return information about a DOS file
/ SubMacros    : %readpipe
/ Notes        : A list of modifiers that give different pieces of DOS file
/                information can be got by typing in the command "for /?".
/                Use the single character modifier immediately following the "~"
/                to give you the piece of file information that you need such as
/                "z" for file size.
/                %~I         - expands %I removing any surrounding quotes (")
/                %~fI        - expands %I to a fully qualified path name
/                %~dI        - expands %I to a drive letter only
/                %~pI        - expands %I to a path only
/                %~nI        - expands %I to a file name only
/                %~xI        - expands %I to a file extension only
/                %~sI        - expanded path contains short names only
/                %~aI        - expands %I to file attributes of file
/                %~tI        - expands %I to date/time of file
/                %~zI        - expands %I to size of file
/ Usage        : %let filesize=%dosfileinfo(C:\spectre\unistats.html,z);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dosfile           (pos) DOS file name
/ modifier          (pos) Modifier (single character no quotes) to give the
/                   piece of file information that you need.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  30Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dosfileinfo v1.0;

%macro dosfileinfo(dosfile,modifier);
%local A;
%let A=%nrstr(%A);
%readpipe(for &A in (&dosfile) do @echo %~&modifier.A)
%mend;
