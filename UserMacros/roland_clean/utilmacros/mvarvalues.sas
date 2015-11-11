/*<pre><b>
/ Program      : mvarvalues.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : Lists and resolves macro variables one per line for a supplied
/                macro variable list.
/ SubMacros    : %words
/ Notes        : On each line, a macro variable name will be shown followed by
/                " = " followed by the resolved macro variable. You have the
/                option to place the characters you define to the quotewithin=
/                parameter both before and after every resolved value for
/                greater clarity, especially where there is the possibility of
/                leading and trailing spaces. If you put the value of mvarlist
/                in single quotes then these quotes will be stripped
/                automatically by this macro. Single quotes should be used if
/                what you supply to mvarlist= is a macro expression. See usage
/                notes.
/ Usage        : %mvarvalues(&mvarlist,*);
/                %mvarvalues('%mvarlist(dummy9,a)',**);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ mvarlist          (pos) List of macro variables separated by spaces. You can
/                   put the whole thing in single quotes and you should use
/                   single quotes if what you supply to this parameter is a
/                   macro expression. See usage notes. 
/ quotewithin       (pos) Character or string of characters to surround the 
/                   resolved macro variable value.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: mvarvalues v1.0;

%macro mvarvalues(mvarlist,quotewithin);

  %*- strip start and trailing single quotes of mvarlist if present -;
  %if %length(&mvarlist) %then %do;
    %if %qsubstr(&mvarlist,1,1) EQ %str(%') 
    and %qsubstr(&mvarlist,%length(&mvarlist),1) EQ %str(%') %then %do;
      %let mvarlist=%unquote(%qsubstr(&mvarlist,2,%length(&mvarlist)-2));
    %end;
  %end;

  %local i name;

  %do i=1 %to %words(&mvarlist);
    %let name=%scan(&mvarlist,&i,%str( ));
    %put &name = %str(&quotewithin)%superq(&name)%str(&quotewithin);
  %end;

%mend mvarvalues;
