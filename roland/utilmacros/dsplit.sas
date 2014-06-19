/*<pre><b>
/ Program   : dsplit.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 06-May-2013
/ Purpose   : To split up a space delimited list of datasets (with possible
/             complex modifiers involving nested and quoted brackets) into
/             individual datasets with their corresponding modifiers and write
/             them to global macro variables.
/ SubMacros : none
/ Notes     : Global macro variables _dsplit1_, _dsplit2_ etc. will be created 
/             to receive the dataset names and the total will be written to the
/             global macro variable _dsplitnum_ .
/
/             The idea of using a parmbuff macro to get sas to recognise
/             balanced brackets came from Jim Groeneveld from a SAS-L thread on
/             the subject entitled "Programmatically matching parentheses. How?"
/
/ Usage     : %let str=dset1  dset2( keep= aa bb cc ) dset3( drop = dd ee )
/             dset4;
/             %dsplit(%nrbquote(&str));
/             %put _dsplitnum_=&_dsplitnum_;
/             %put _dsplit1_=&_dsplit1_;
/             %put _dsplit2_=&_dsplit2_;
/             %put _dsplit3_=&_dsplit3_;
/             %put _dsplit4_=&_dsplit4_;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) List of dataset names seperated by spaces (enclose in
/                   %nrbquote() if it contains modifiers).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  06May13         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dsplit v1.0;

%macro dsplit(str);

  %local i numds strseg pos len1 len2 num dlm1 dlm2 matchbr dummy;
  %global _dsplitnum_;

  %*- The following macro is used to get a matching bracket -;
  %*- string which will be the value of &syspbuff. SAS will -;
  %*- know if any brackets are in quotes or nested and will -;
  %*- give you a correct balanced string in brackets.       -;

  %macro _dsplit / parmbuff;
    %let matchbr=&syspbuff;
  %mend _dsplit;

  %let strseg=&str;
  %let numds=0;
  %let pos=0;
  %let len1=88;
  %let len2=99;
  %let num=1;
  %let dlm1=%str(%();
  %let dlm2=%str(%));

  %do %while(&len1 NE &len2 AND %superq(strseg) NE );
    %syscall scan(strseg,num,pos,len1,dlm1);
    %syscall scan(strseg,num,pos,len2,dlm2);
    %let words=%words(%sysfunc(subpad(%nrbquote(&strseg),1,&len1)));
    %do i=1 %to &words;
      %let numds=%eval(&numds+1);
      %global _dsplit&numds._;
      %let _dsplit&numds._=%scan(%sysfunc(subpad(%nrbquote(&strseg),
      1,&len1)),&i,%str( ));
    %end;
    %if &len1 NE &len2 %then %do;
      %*- get ready to call the _dsplit macro -;
      %let dummy=%nrstr(%_dsplit) %substr(%nrbquote(&strseg),&len1+1);
      %*- call the _dplit macro for real to get the matching bracket string -;
      %let dummy=%unquote(&dummy);
      %*- add the matching bracket string on the end of the dataset name -;
      %let _dsplit&numds._=&&&_dsplit&numds._&matchbr;
      %*- go to the next part of the input string -;
      %let strseg=%sysfunc(subpad(%nrbquote(&strseg),&len1+%length(&matchbr)+1));
    %end;
  %end;

  %let _dsplitnum_=&numds;

%mend dsplit;

