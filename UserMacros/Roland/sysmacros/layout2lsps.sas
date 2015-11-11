/*<pre><b>
/ Program   : layout2lsps.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 30-Jul-2007
/ Purpose   : Spectre (Clinical) macro to calculate sas linesize and pagesize
/             values based on paper type, margins and layout.
/ SubMacros : %verifyb
/ Notes     : This is the macro version of the script "layout2lsps" written so
/             it could be Windows compliant. Margins apply to a portrait page.
/             Results are written to the global macro variables _ls_ and _ps_.
/ Usage     : %layout2lsps(lmargin=1.0,rmargin=0.75,tmargin=1.0,bmargin=1.0,
/                          paper=A4,layout=L10);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ lmargin           Left margin (inches)
/ rmargin           Right margin (inches)
/ tmargin           Top margin (inches)
/ bmargin           Bottom margin (inches)
/ paper             Paper size (A4, Letter or A4Letter)
/ layout            Layout such as P10 (portrait 10 point)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  30Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: layout2lsps v1.0;

%macro layout2lsps(lmargin=,
                   rmargin=,
                   tmargin=,
                   bmargin=,
                   paper=,
                   layout=
                   );

  %global _ls_ _ps_;
  %local errflag err orient lspac psz pos ;
  %let errflag=0;
  %let err=ERR%str(OR);

     /*---------------------*
         Check parameters
      *---------------------*/

  %if not %length(&lmargin) %then %do;
    %let errflag=1;
    %put &err: (layout2lsps) Left margin in inches not supplied to lmargin=;
  %end;

  %if not %length(&rmargin) %then %do;
    %let errflag=1;
    %put &err: (layout2lsps) Right margin in inches not supplied to rmargin=;
  %end;

  %if not %length(&tmargin) %then %do;
    %let errflag=1;
    %put &err: (layout2lsps) Top margin in inches not supplied to tmargin=;
  %end;

  %if not %length(&bmargin) %then %do;
    %let errflag=1;
    %put &err: (layout2lsps) Bottom margin in inches not supplied to bmargin=;
  %end;

  %let paper=%upcase(&paper);
  %if "&paper" NE "A4" and "&paper" NE "LETTER" and "&paper" NE "A4LETTER" %then %do;
    %let errflag=1;
    %put &err: (layout2lsps) Only paper=A4, paper=Letter or paper=A4Letter allowed paper=&paper;
  %end;

  %let layout=%upcase(&layout);

  %let orient=%substr(&layout,1,1);
  %if "&orient" NE "L" and "&orient" NE "P" %then %do;
    %let errflag=1;
    %put &err: (layout2lsps) Layout= value must start with a "L" or "P";
  %end;

  %let pos=%verifyb(&layout,.0123456789);
  %if &pos GT 3 %then %do;
    %let errflag=1;
    %put &err: (layout2lsps) Layout not recognised for layout=&layout;
  %end;

  %else %if &pos GT 1 %then %do;
    %let lspac=%substr(&layout,2,&pos-1);
    %if "&lspac" NE "C" and "&lspac" NE "CT" and "&lspac" NE "CW" and 
        "&lspac" NE "T" and "&lspac" NE "W" and "&lspac" NE "TC" and
        "&lspac" NE "WC" and %then %do;
      %let errflag=1;
      %put &err: (layout2lsps) Line spacing not recognised for layout=&layout;
    %end;
  %end;

  %let psz=%substr(&layout,&pos+1);
  %if "&psz" NE "7" and "&psz" NE "7.5" and "&psz" NE "8" and "&psz" NE "8.5" and 
      "&psz" NE "9" and "&psz" NE "9.5" and "&psz" NE "10" and "&psz" NE "10.5" and 
      "&psz" NE "11" and "&psz" NE "11.5" and "&psz" NE "12" %then %do;
    %let errflag=1;
    %put &err: (layout2lsps) Point size not 7-12 (by 0.5) for layout=&layout;
  %end;

  %if &errflag %then %goto exit;


    /*-----------------------*
       Calculate ls= and ps=
     *-----------------------*/

  data _null_;
    retain paper "&paper" orient "&orient" lspac "&lspac" 
           pointsz &psz papero "&paper.&orient" ;

    *- width and height of the page in inches -;
    if papero="A4P" then do;
      width=8.2677;
      height=11.6929;
    end;
    else if papero="A4L" then do;
      height=8.2677;
      width=11.6929;
    end;
    else if papero="LETTERP" then do;
      width=8.5;
      height=11;
    end;
    else if papero="LETTERL" then do;
      height=8.5;
      width=11;
    end;
    else if papero="A4LETTERP" then do;
      width=8.2677;
      height=11;
    end;
    else if papero="A4LETTERL" then do;
      height=8.2677;
      width=11;
    end;

    *- ratio of font width to font height -;
    ratio=0.6;
    *- "condensed" font widths are half font height -;
    if index(lspac,"C") then ratio=0.5;
  
    *- line spacing (ratio to font height) -;
    spacing=1.1;
    if index(lspac,"T") then spacing=1.0;
    else if index(lspac,"W") then spacing=1.2;

    *- margins -;
    %if "&orient" EQ "P" %then %do;
      *- portrait margins -;
      lmargin=&lmargin;
      rmargin=&rmargin;
      tmargin=&tmargin;
      bmargin=&bmargin;
    %end;
    %else %do;
      *- landscape margins -;
      lmargin=&bmargin;
      rmargin=&tmargin;
      tmargin=&lmargin;
      bmargin=&rmargin;
    %end;

    *- do calculation -;
    usewidth=width-lmargin-rmargin;
    linesize=int((120.450*0.6*usewidth+0.0001)/(pointsz*ratio));

    useheight=height-tmargin-bmargin;
    pagesize=int((72.27*useheight+0.0001)/(pointsz*spacing));

    *- output the results to the global macro variables -;
    call symput("_ls_",compress(put(linesize,6.)));
    call symput("_ps_",compress(put(pagesize,6.)));
  run;


     /*---------------------*
               Exit
      *---------------------*/

  %goto skip;

  %exit:
  %*- set to impossible values for exit condition -;
  %let _ls_=&err;
  %let _ps_=0;
  %put &err: (layout2lsps) Leaving macro due to problem(s) listed;

  %skip:

%mend layout2lsps;
