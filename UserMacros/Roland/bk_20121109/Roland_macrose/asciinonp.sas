/*<pre><b>
/ Program   : asciinonp.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 29-Mar-2007
/ Purpose   : To show up ascii non-printables characters in a flat file by
/             displaying their hex codes.
/ SubMacros : none
/ Notes     : 
/ Usage     : %asciinonp(infile,outfile)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ infile            (pos) Input file
/ file              (pos) Output file
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: asciinonp v1.0;

%macro asciinonp(infile,file);

data _null_;
  length linein $ 200 newline $ 400 char $ 1;
  retain outpos 0 ;
  infile "&infile" pad;
  file "&file" notitles noprint;
  input linein $char200.;
  outpos=1;
  if linein ne ' ' then do;
    do i=1 to length(linein);
      char=substr(linein,i,1);
      rank=rank(char);
      if 32 <= rank <= 126 then do;
        substr(newline,outpos,1)=char;
        outpos=outpos+1;
      end;
      else do;
        substr(newline,outpos,4)='<'||put(rank,hex2.)||'>';
        outpos=outpos+4;
      end;
    end;
    put @(length(newline)-length(left(newline))+1) newline;
  end;
  else put;
run;

%mend;
