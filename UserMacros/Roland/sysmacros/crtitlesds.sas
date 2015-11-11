/*<pre><b>
/ Program      : crtitlesds.sas
/ Version      : 1.2
/ Author       : Roland Rashleigh-Berry
/ Date         : 30-Jul-2007
/ Purpose      : Spectre (Clinical) macro to create a titles dataset from a
/                titles flat file.
/ SubMacros    : none
/ Notes        : The titles flat file must have a specific form for this macro to
/                work correctly. Actions are driven by special labels starting in
/                the first column, as shown below. Except for lines in the titles
/                and footnotes section, lines that do not follow this pattern
/                will be ignored and treated as comment lines. At the very least,
/                there must be one title specified for a program.
/
/ program: ----- program name without the .sas ending. Case must match with the
/                real code member.
/ label: --      An optional two character identifier to identify the correct
/                set of titles when there is more than one output per program.
/                This will be converted to lower text.
/ lisfile: ---   Optional name for the final lisfile if this is required to be
/                different from the derived lis file name which is the program
/                name with a ".lis"(label) extension.
/ layout: ----   Code to say whether landscape or portrait and whether the lines
/                are tight, followed by the point size. The following
/                examples are all valid: l9 lt9 p10 pt11 lt8.5 p10.5
/                If left blank then the study default is used.
/ population: ---  FAS, PPS EVAL etc. population abbreviation. A title line will
/                be generated on the basis of this setting and placed correctly.
/ titles below:  Titles are put underneath this marker. All titles will be
/                centered unless it starts with a space in which case it is
/                left-aligned with the first space removed. A blank line will
/                create a blank title line. No comment lines are allowed in this
/                section.
/ footnotes below:  Footnotes are put underneath this marker. All footnotes will
/                be left-aligned. Leading spaces are allowed. A blank line will
/                result in a blank footnote. No comment lines are allowed in
/                this section.
/ endxxx:        Marker to tell it it has come to the end. Do not specify a
/                value beside this.
/ 
/ Usage        : %crtitlesds(flatfile,der.titles)
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ flatfile          (pos) File name of flat file containing titles and footnotes
/ dsout             (pos) Output dataset containing titles and footnotes.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  25Feb07         Remove progname >32 error reporting to stderr
/ rrb  19Jul07         Add "lisfile" variable
/ rrb  30Jul07         Header tidy
/===============================================================================
/ No guarantee as to the suitability or accuracy of this code is given or
/ implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: crtitlesds v1.2;

%macro crtitlesds(flatfile,dsout);

  data &dsout;
    length program $ 32 filename $ 36 lisfile $ 38 layout $ 8 population $ 8 
           text sascode $ 200 type $ 1 label $ 2 longprog $ 80;
    infile "%sysfunc(compress(&flatfile,%str(%'%")))" pad eof=eof;
  getprog:
    input @1 text $char200.;
    if upcase(text) NE: "PROGRAM:" then goto getprog;
  program:
    longprog=left(scan(text,2,':'));
    program=longprog;
    filename=trim(program)||".sas";
    lisfile=" ";
    layout=" ";
    population=" ";
    label="  ";
    sascode=" ";
  pretitles:
    input @1 text $char200.;
    if upcase(text) EQ: "TITLES BELOW:" then goto titles;
    if upcase(text) EQ: "LAYOUT:" then do;
      layout=upcase(left(scan(text,2,':')));
      goto pretitles;
    end;
    if upcase(text) EQ: "POPULATION:" then do;
      population=upcase(left(scan(text,2,':')));
      goto pretitles;
    end;
    if upcase(text) EQ: "SASCODE:" then do;
      sascode=left(substr(text,index(text,":")+1));
      goto pretitles;
    end;
    if upcase(text) EQ: "LABEL:" then do;
      label=lowcase(left(scan(text,2,':')));
      goto pretitles;
    end;
    if upcase(text) EQ: "LISFILE:" then do;
      lisfile=left(scan(text,2,':'));
      goto pretitles;
    end;
    goto pretitles;
  titles:
    type='T';
    number=0;
  titleloop:
    input @1 text $char200.;
    if upcase(text) EQ: "ENDXXX:" then goto endxxx;
    if upcase(text) EQ: "FOOTNOTES BELOW:" then goto footnotes;
    number=number+1;
    output;
    goto titleloop;
  footnotes:
    type='F';
    number=0;
  footloop:
    input @1 text $char200.;
    if upcase(text) EQ: "ENDXXX:" then goto endxxx;
    if upcase(text) EQ: "PROGRAM:" then goto program;
    number=number+1;
    output;
    goto footloop;
  endxxx:
    return;
  eof:
    label program="Program name"
          filename"Program file name"
          lisfile="Lis file name"
          layout="Layout of report"
          population="Population"
          sascode="SAS code to run"
          label="Label identifier"
          type="T (title) or F (footnote)"
          number="Title or footnote number"
          text="Text of title or footnote"
          ;
    drop longprog lenprog;
  run;

%mend crtitlesds;

