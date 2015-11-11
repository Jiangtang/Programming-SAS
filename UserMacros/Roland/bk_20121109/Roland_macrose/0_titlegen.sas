/*<pre><b>
/ Program   : titlegen.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 28-Sep-2008
/ Purpose   : Spectre (Clinical) macro to generate titles and footnotes from a
/             dataset of the style created by the %crtitlesds macro.
/ SubMacros : none
/ Notes     : You would normally select from the dataset created by %crtitlesds
/             macro and add special headers and footnotes if required and then
/             pass the resulting dataset to this macro so that the titles and
/             footnote statements get generated.
/
/             If there is a variable named "length" in the input dataset then
/             the value in it will be assumed to be the text length. This is
/             useful when there are deliberate trailing spaces in titles and
/             footnotes.
/
/ Usage     : %titlegen(dsname)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) SAS dataset containing titles and footnotes
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  28Sep08         Header changed to classify this macro as belonging to
/                      Spectre (Clinical).
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: titlegen v1.0;

%macro titlegen(ds);

  data _null_;
    set &ds;
    if length=. then length=.;
    if length ne . then do;
      if type EQ 'T' then do;
        if length>length(text) then call execute('title'||compress(put(number,2.))||' "'||
            trim(text)||repeat(' ',length-length(text)-1)||'";');
        else call execute('title'||compress(put(number,2.))||' "'||trim(text)||'";');
      end;
      else if type EQ 'F' then do;
        if length>length(text) then call execute('footnote'||compress(put(number,2.))||' "'||
            trim(text)||repeat(' ',length-length(text)-1)||'";');
        else call execute('footnote'||compress(put(number,2.))||' "'||trim(text)||'";');
      end;
    end;
    else do;
      if type EQ 'T' then do;
        if substr(text,1,1) EQ ' ' then call execute('title'||compress(put(number,2.))||
          ' "'||substr(text,2)||'";');
        else call execute('title'||compress(put(number,2.))||' "'||trim(text)||'";');
      end;
      else if type EQ 'F' then 
        call execute('footnote'||compress(put(number,2.))||' "'||trim(text)||
        '" "%sysfunc(repeat(%str( ),199))" ;');
    end;
  run;

%mend titlegen;
