/*<pre><b>
/ Program   : datanulldemo.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 28-Sep-2008
/ Purpose   : Clinical reporting sample code to do a stacked-column report using
/             data _null_ that does not leave line gaps like proc report does.
/ SubMacros : %titlelen %maxtitle %splitvar %titlegen
/ Notes     : This is an example of using data _null_ to produce a
/             stacked-column report without the weakness of proc report in
/             leaving line gaps. It can handle #byval and #byvar entries in the
/             titles, will generate or not a "by" line depending on the options
/             setting and will center or left-align depending on the "center"
/             option setting. The positioning of the report and titles is
/             dependent on the line size. Report titles are stored in arrays to
/             speed up multi-page reports.
/
/             This report shows subject/invid in the first column and
/             age/race/sex/weight in the second column. These will repeat if 
/             values flow onto a following page as will the current parameter
/             identifier which in many cases is so long that you are required to
/             "flow" it on a further line. There is a call to %titlegen at the
/             end to restore the titles that had to be nullified. This is an
/             educational tool, rather than a recommendation. Once you
/             understand how it works you should be able to handle data _null_
/             reports of any degree of complexity. 
/
/ Usage     : Ordinary SAS code.
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Header tidy
/ rrb  31Jul07         Renamed to datanulldemo.sas from fullmonty.sas
/ rrb  28Sep08         This is now classed as a "Clinical reporting" macro
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

options ls=90 ps=40 center nobyline;
title1 'First title';
title3 'Third title';
title5 '#byvar1 = #byval1';
footnote1 'First footnote';
footnote3 'Third footnote';

%titlelen(dsout=titles(where=(type='T')));

%maxtitle


         /*--------------------------------------------------*
                        Generate the dummy data
          *--------------------------------------------------*/

data test;
  length sex $ 6 param $ 80 race $ 10;
  year=2002;

  subj=1001;invid=10001;age=21;race='Asian';sex='Male';weight=60;
  param='AA This is a very long parameter and you will have to flow it';
  value=11;output;
  param='BB This is a short parameter';
  value=21;output;
  value=22;output;
  param='CC This is a very long parameter and you will have to flow it';
  do value=30 to 38;
    output;
  end;

  subj=2001;invid=20001;age=32;race='White';sex='Female';weight=55;
  param='AA This is a very long parameter and you will have to flow it';
  value=51;output;
  param='BB This is a short parameter';
  value=61;output;
  value=62;output;
  param='CC This is a very long parameter and you will have to flow it';
  do value=70 to 78;
    output;
  end;

  subj=3001;invid=30001;age=42;race='Black';sex='Female';weight=65;
  param='AA This is a very long parameter and you will have to flow it';
  value=51;output;
  /*
  param='BB This is a short parameter';
  value=61;output;
  */
run;


         /*--------------------------------------------------*
                          Produce the report
          *--------------------------------------------------*/

title1;

data _null_;
  length tempstr $ 200;
  retain ls 0 startcol titlestart 0 repwidth 60 count 0 byline 0 center 1;
  array ttext {&_maxtitle_} $ 200 _temporary_;
  array tlength {&_maxtitle_} 8 _temporary_;
  file print titles footnotes header=header linesleft=ll;
  set test end=last;
  by subj param;
  if _n_=1 then do;
    do tptr=1 to &_maxtitle_;
      set titles point=tptr;
      ttext(tptr)=text;
      tlength(tptr)=length;
    end;
    ls=getoption('ls');
    startcol=floor((ls-repwidth)/2)+1;
    if getoption('center')='NOCENTER' then do;
      startcol=1;
      center=0;
    end;
    if getoption('byline')='BYLINE' then byline=1;
  end;
  if ll<2 then put _page_;
  if first.subj then do;
    count=0;
    if ll<5 then put _page_;
  end;
  count=count+1;
  %splitvar(param,38,split='*');
  link flow;
  if first.param or count=1 then do;
    tempstr=scan(param,1,'*');
    put @startcol+18 tempstr @startcol+57 value 4.;
    i=2;
    do while(scan(param,i,'*') NE ' ');
      count=count+1;
      link flow;
      tempstr=scan(param,i,'*');
      put @startcol+18 tempstr;
      i=i+1;
    end;
  end;
  else put @startcol+57 value 4.;
  if last.param then do;
    count=count+1;
    link flow;
    if not last or count<5 then put;
  end;
  if last.subj then link lastsubj;
return;

header:
  do t=1 to &_maxtitle_;
    if ttext(t) EQ ' ' then put;
    else do;
      oldlen=length(ttext(t));
      if vlabel(year) ne ' ' then newtitle=tranwrd(ttext(t),'#BYVAR1',trim(vlabel(year)));
      else newtitle=tranwrd(ttext(t),'#BYVAR1','year');
      newtitle=tranwrd(newtitle,'#BYVAL1',left(year));
      newlen=length(newtitle);
      length=tlength(t)+newlen-oldlen;
      if length>ls then length=ls;
      titlestart=floor((ls-length)/2)+1;
      if not center then titlestart=1;
      put @ (titlestart+length(newtitle)-length(left(newtitle))) newtitle;
    end;
  end;
  if byline then do;
    put;
    _file_=repeat('-',ls-1);
    if vlabel(year) ne ' ' then newtitle=trim(vlabel(year))||'='||left(year);
    else newtitle='year='||left(year);
    substr(_file_,floor((ls-(length(newtitle)+2))/2)+1,length(newtitle)+2)=' '||trim(newtitle)||' ';
    put;
  end;
  put;
  put @startcol '           age/';
  put @startcol '          race/';
  put @startcol 'subject/   sex/';
  put @startcol 'invid.   weight   Lab parameter                          value';
  *              0         10        20        30        40        50        60;
  *              01234567890123456789012345678901234567890123456789012345678901;
  put @startcol '--------------------------------------------------------------';
  if _n_ ne 1 then count=0;
return;

flow:
  if count=1 then put @startcol subj 6. '/' @startcol+8 age 2. ' yrs/' @;
  else if count=2 then put @startcol invid 6. @startcol+8 race $char6. +(-1) '/' @;
  else if count=3 then put @startcol+8 sex $char6.  '/' @;
  else if count=4 then put @startcol+8 weight 3. ' kg' @;
return;

lastsubj:
  if count<4 then do;
    do count=(count+1) to 4;
      link flow;
      put;
    end;
    if not last then put;
  end;
return;

run;


%titlegen(titles)
