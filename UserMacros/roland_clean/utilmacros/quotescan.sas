/*<pre><b>
/ Program   : quotescan.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to scan for a quoted string in a macro
/             expression.
/ SubMacros : none
/ Notes     : The quoted string will still have its quote marks around it.
/             A null string will be returned if there is nothing quoted.
/             Note that any string returned will be macro-quoted so you should
/             put it inside %unquote() if using the output in normal sas code.
/ Usage     : %let scan=%quotescan(&str,2);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) String
/ pos               (pos) Position
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  28May07         Header tidy
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: quotescan v1.0;

%macro quotescan(str,pos);

  %local i pos1 pos2 qtype tempstr count qstr;
  %let tempstr=&str;
  %let count=0;
  %if not %length(&pos) %then %let pos=1;
  %redo:

  %let pos1=0;
  %let pos2=0;
  %let qtype=;

  %do i=1 %to %length(&tempstr);
    %if &pos1 EQ 0 %then %do;
      %if %qsubstr(&tempstr,&i,1) EQ %str(%')
       or %qsubstr(&tempstr,&i,1) EQ %str(%") %then %do;
        %let pos1=&i;
        %let qtype=%qsubstr(&tempstr,&i,1);
      %end;
    %end;
    %else %if (&pos1 GT 0) and (&pos2 EQ 0) %then %do;
      %if %qsubstr(&tempstr,&i,1) EQ %str(&qtype) %then %let pos2=&i;
    %end;
  %end; 

  %if (&pos1 GT 0) and (&pos2 GT 0) %then %do;
    %let count=%eval(&count + 1);
    %let qstr=%qsubstr(&tempstr,&pos1,%eval(&pos2-&pos1+1));
    %if (&pos1 GT 1) and (&pos2 LT %length(&tempstr)) %then
      %let tempstr=%qsubstr(&tempstr,1,&pos1-1)%qsubstr(&tempstr,&pos2+1);
    %else %if (&pos1 EQ 1) and (&pos2 LT %length(&tempstr)) %then
      %let tempstr=%qsubstr(&tempstr,&pos2+1);
    %if (&pos1 GT 1) and (&pos2 EQ %length(&tempstr)) %then
      %let tempstr=%qsubstr(&tempstr,1,&pos1-1);
    %else %if (&pos1 EQ 1) and (&pos2 EQ %length(&tempstr)) %then
      %let tempstr=;
    %if (&count LT &pos) and %length(&tempstr) %then %goto redo;
  %end;

  %if &count EQ &pos %then &qstr;

%mend quotescan;  