/*<pre><b>
/ Program   : titlelen.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To create a copy of sashelp.vtitle but with the length added.
/ SubMacros : %casestrvar
/ Notes     : The orginal length of titles and footnotes is unknown since the
/             original trailing spaces are not shown in sashelp.vtitle. This
/             macro will generate a dummy report and work out the original
/             length of the titles and footnotes to the nearest multiple of 2.
/             If any mixed-case form of "#byvar" or "#byval" is detected in a
/             title line then these strings (only) will be converted to
/             uppercase.
/
/ Usage     : %titlelen
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsout=titlelen    Name of the output dataset.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Jan06         Extensively rewritten for version 2.0
/ rrb  13Feb07         "macro called" message added
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: titlelen v2.0;

%macro titlelen(dsout=titlelen);

  %*- store "center" option for restore at end -;
  %local opts;
  %let opts=%sysfunc(getoption(center));


  *- set options to center -;
  options center;


  *- save the titles file -;
  proc sort data=sashelp.vtitle out=_titles;
    by type number;
  run;


  *- set up temporary file -;
  filename titlelen TEMP;


  *- print to the temporary file to put the titles and footnotes there -;
  data _null_;
    file titlelen print titles footnotes ls=200 ps=21;
    put 'xxxxxxxxxx';
  run;


  *- Read in the titles and footnotes from the temporary -;
  *- file to find the start position of the text. -;
  data _ltitles;
    retain type 'T' number 0;
    infile titlelen pad;
    input text $char200.;
    if text='xxxxxxxxxx' then do;
      type='F';
      number=0;
    end;
    else do;
      number=number+1;
      start=verify(text,' ');
      output;
    end;
    drop text;
  run;


  *- clear the temporary file -;
  filename titlelen clear;


  *- sort ready for a merge with the original titles -;
  proc sort data=_ltitles;
    by type number;
  run;


  *- merge with the original titles and calculate length -;
  data _titles;
    merge _titles(in=_orig) _ltitles;
    by type number;
    if _orig;
    if type='T' and text ne ' ' then do;
      %casestrvar(text,'#BYVAR');
      %casestrvar(text,'#BYVAL');
    end;
    length=2*(100-(start-verify(text,' ')));
    if (length-length(text)) EQ 1 then length=length-1;
    drop start;
  run;


  *- sort out to a titles dataet -;
  proc sort data=_titles out=&dsout;
    by descending type number;
  run;


  *- tidy up -;
  proc datasets nolist;
    delete _titles _ltitles;
  run;
  quit;


  *- restore the saved option -;
  options &opts;


%mend titlelen;
