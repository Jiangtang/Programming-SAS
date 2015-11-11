/*<pre><b>
/ Program      : pagexofy.sas
/ Version      : 5.6
/ Author       : Roland Rashleigh-Berry
/ Date         : 12-Oct-2009
/ SAS version  : 8.2
/ Purpose      : Spectre (Clinical) macro to add "Page x of Y" labels where 
/                the 'FF'x character is found and to make other special
/                character substitutions.
/ SubMacros    : %qdequote %words
/ Notes        : The target character for page labels is 'FF'x and it is
/                assumed that there is only one of these characters per page.
/                The other substitutions made are in line with the Spectre
/                reporting system. 'A0'x will be changed into a space as well
/                as other substitutions made.
/
/                Note that the input file must be deassigned before this macro
/                is called. If you are writing to it using a "proc printto"
/                then make sure you cancel it before calling this macro by
/                issuing a fresh "proc printto print=print;".
/
/                If you do not specify an output file to the second parameter
/                then an internal copy is made of the input file and the
/                input file will be overwritten. For production running it
/                would be safer for you to specify the output file so that the
/                input file is retained.
/
/                Alignment of the "Page x of Y" labels depends on where the
/                target character is found. It is to the left of the target
/                if the target character is the last character in the line.
/                If the target character is the last character in the line bar
/                one then this is assumed to be a title line and it will be
/                recentred. Otherwise it will be to the right. If there are any
/                characters in the way then they will be overwritten.
/
/ Usage        : %pagexofy(myfile.lst)
/                %pagexofy(myfile.lst,style="Page x of Y")
/                %pagexofy(myfile.lst,style="Seite x von Y")
/                %pagexofy(myfile.lst,style="(PAGE X OF Y)")
/                %pagexofy(myfile.lst,style="SEITE x")
/                %pagexofy(myfile.lst,style="[SEITE x]"
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ infile            (pos) Input file name (must not be a fileref)
/ outfile           (pos) Output file name (must not be a fileref)
/ style="Page x of Y"    Use the default page label style "Page x of Y" (quoted)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  05Jul06         New version 3.0 for Spectre MS Windows users
/ rrb  06Jul06         Version 4.0 allows for an output file
/ rrb  13Feb07         "macro called" message added
/ rrb  07Mar07         Remove caps= parameter processing and add style=
/                      processing for defining style of "Page x of Y" label.
/ rrb  15Mar07         Check put in to make sure style has 4 parts (v 5.1)
/ rrb  19Mar07         Allow for a two part page label lacking the total number
/                      of pages (v5.2)
/ rrb  24Mar07         Replace "A0"x with a space as well as for "FE"x.
/ rrb  16May07         "FE"x no longer treated as a space.
/ rrb  26Jun07         Centering of titles added
/ rrb  30Jul07         Header tidy
/ rrb  28Sep08         Header changed to classify this macro as belonging to
/                      Spectre (Clinical).
/ rrb  12Oct09         Call to %dequote changed to call to %qdequote due to
/                      macro renaming (v5.6)
/===============================================================================
/ No guarantee as to the suitability or accuracy of this code is given or
/ implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: pagexofy v5.6;

%macro pagexofy(infile,outfile,style="Page x of Y");

  %global _ls_;
  %local errflag err totpages repwidth temp stywords;
  %let err=ERR%str(OR);
  %let errflag=0;
  %let temp=0;

  %if not %length(%qdequote(&style)) %then %let style="Page x of Y";
  %else %let style="%qdequote(&style)";

  %let stywords=%words(%qdequote(&style));
  %if (&stywords NE 4) and (&stywords NE 2) %then %do;
    %let errflag=1;
    %put &err: (pagexofy) Page label style must have 2 or 4 parts. You have style=&style;
  %end;

  %if not %length(&infile) %then %do;
    %let errflag=1;
    %put &err: (pagexofy) File name not specified as the first positional parameter;
  %end;

  %if &errflag %then %goto exit;


  %*- make sure input file is quoted -;
  %let infile="%qdequote(&infile)";

  %*- make sure "style" is quoted -;
  %let style="%qdequote(&style)";

  %*- if no output file specified then make internal copy -;
  %if not %length(&outfile) %then %do;
    %let outfile=&infile;
    filename pgxofycp TEMP;
    data _null_;
      file pgxofycp;
      infile &infile;
      input;
      put _infile_;
    run;
    %let infile=pgxofycp;
    %let temp=1;
  %end;
  %else %do;
    %*- make sure output file is quoted -;
    %let outfile=%sysfunc(compress(&outfile,%str(%'%")));
    %let outfile="&outfile";
  %end;


  %if &stywords EQ 4 %then %do;
    *- count the total number of pages -;
    data _null_;
      retain totpages repwidth 0;
      infile &infile eof=last;
      input;
      len=length(_infile_);
      if len>repwidth then repwidth=len;
      if index(_infile_,'FF'x) then totpages=totpages+1;
      return;
    last:
      call symput('totpages',compress(put(totpages,11.)));
      if totpages>1 then call symput('repwidth',compress(put(repwidth-1,11.)));
      else call symput('repwidth',compress(put(repwidth,11.)));
    run;
    %if %length(&_ls_) %then %let repwidth=&_ls_;
  %end;



  *- add page count labels and make substitutions -;
  data _null_;
    retain pagecnt 0 style &style;
    length endlab $ 4 label $ 40;
    infile &infile pad;
    file &outfile;
    input;
    *- make the standard Spectre character substitutions -;
    _file_=translate(_infile_,' &%"','A0FDF8F0'x);
    *- add the "Page x of Y" labels -;
    if index(_file_,'FF'x) then do;
      pagecnt=pagecnt+1;
      %if &stywords EQ 4 %then %do;
        label=scan(style,1," ")||" "||compress(put(pagecnt,11.))||" "||
              scan(style,3," ")||" &totpages";
        endlab=compress(scan(&style,4," "),'xXyYnN"');
      %end;
      %else %do;
        label=scan(style,1," ")||" "||compress(put(pagecnt,11.));
        endlab=compress(scan(&style,2," "),'xXyYnN"');
      %end;
      if endlab ne " " then label=trim(label)||trim(endlab);
      if index(_file_,'FF'x)=length(_file_) 
        then substr(_file_,length(_file_)-length(label)+1)=label;
      else if index(_file_,'FF'x)=length(_file_)-1 then do;
        substr(_file_,index(_file_,'FF'x))=label;
        if substr(_file_,1,2)="  " then
          _file_=repeat(" ",(&repwidth-length(trim(left(_file_))))/2-1)||trim(left(_file_));
      end;
      else substr(_file_,index(_file_,'FF'x),length(label))=label;
    end;
    _file_=trim(_file_);
    put;
  run;


  *- clear the temporary file -;
  %if &temp %then %do;
    filename pgxofycp clear;
  %end;


  %goto skip;
  %exit: %put &err: (pagexofy) Leaving macro due to problem(s) listed;
  %skip:

%mend pagexofy;
