%macro varlist(prefix=,prefnum=,prenstrt=1,prewidth=,prefmt=z,
 suffix=,sufixnum=,sufnstrt=1,sufwidth=,suffmt=z,dlm=%str( ),debug=0);
/*==============================================================================
  Eli Lilly and Company
  PROGRAM NAME: varlist.sas         Temporary Object Prefix: none needed
  PROGRAMMER: Greg Steffens
  DESCRIPTION: This macro generates a list of variable names
               that contain numbers in the middle and/or the end.
               This is a stronger form of the SAS variable list in that the
               numbers can be embedded or contain leading zeros in the name.
  LANGUAGE/VERSION: SAS/8
  INITIATION DATE: 
  VALIDATOR:
  INPUT FILE(S): none
  OUTPUT FILE(S): none
  EXTERNAL PROGRAM CALLS: %ut_logical
==============================================================================*/
/*                              REVISION HISTORY                              */
/*==============================================================================
 PROGRAMMER:                              DATE: date9.
 REASON:
==============================================================================*/
/* *****************************************************************************
  Parameters:
   Name     Type     Default  Description
   -------- -------- -------- -------------------------------------------------
   PREFIX   optional          The characters which start the element names.
                              A list of blank delimited suffixes results
                              in a list with elements ending in these suffixes.
   PRENSTRT optional 1        The start of the prefix numbers which follow 
                              the PREFIX component.
   PREFNUM  optional          The number which follows the PREFIX - starting 
                              at PRENSTRT and continuing by 1 to PREFNUM.  If
                              set to 0 or null no prefnum component is
                              generated.
   PREWIDTH optional see note The width of the PREFNUM component
   PREFMT   optional z        The format to use when generating PREFNUM
                              numbers.  Default is z. format so that
                              leading zeros are used and the width of each
                              numeric component is the same.
   SUFFIX   optional          The characters which follow the PREFNUM.
                              A list of blank delimited suffixes results
                              in a list with elements ending in these suffixes.
   SUFNSTRT optional 1        The start of the suffix numbers which follow the
                              SUFFIX component.
   SUFIXNUM optional          The number which follows the SUFFIX - starting 
                              at 1 and continuing by 1 to SUFIXNUM.  If
                              set to 0 or null no sufixnum component is
                              generated.
   SUFWIDTH optional see note The width of SUFIXNUM
   SUFFMT   optional z        The format to use when generating SUFIXNUM
                              numbers.  Default is z. format so that
                              leading zeros are used and the width of each
                              numeric component is the same.
   DLM      required  space   The delimiter to use if PREFIX or SUFFIX 
                              are more than one text string.  DLM is used
                              by the %scan function.
   DEBUG    required  0       %ut_logical value to turn debug mode on/off


  Usage Notes:

  VARLIST will generate a list of variable names - elements - each of which 
  has four optional components: prefix, prefixnum, suffix and suffixnum.
  The resulting elements are of the format: PREnSUFm, where PRE is the 
  prefix text(s), n is an integer ranging from 1 to prefnum, SUF is the suffix
  text(s) and m is an integer ranging from 1 to sufixnum.  Any component is
  optional but you should specify at least one of them.

  Both PREFIX and SUFFIX can be one or more text strings.  If more than 
  one is specified then each is used to generate elements, e.g. 

  %put %varlist(prefix=p q,prefnum=4,suffix=s t u,sufixnum=2);

  p1s1  p1s2  p1t1  p1t2  p1u1  p1u2  p2s1  p2s2  p2t1  p2t2
  p2u1  p2u2  p3s1  p3s2  p3t1  p3t2  p3u1  p3u2  p4s1  p4s2
  p4t1  p4t2  p4u1  p4u2  q1s1  q1s2  q1t1  q1t2  q1u1  q1u2
  q2s1  q2s2  q2t1  q2t2  q2u1  q2u2  q3s1  q3s2  q3t1  q3t2
  q3u1  q3u2  q4s1  q4s2  q4t1  q4t2  q4u1  q4u2


  PREWIDTH and SUFWIDTH have a default value of the length of PREFNUM and
  SUFIXNUM, respectivey.

  If you specify a PREWIDTH or a SUFWIDTH other than 0 then the NUMFMT will
  be set to Z.

  Typical calls:

  data _null_;
    array test1
     %varlist(prefix=abc,prefnum=10,suffix=x,sufixnum=4)
    ;
    array test2
     %varlist(prefix=abc,prefnum=10,suffix=x,sufixnum=0)
    ;
    .
    .
    .
  run;

  Which results in this log extract:

   data _null_;
     array test1
      %varlist(prefix=abc,prefnum=10,prewidth=2,suffix=x,sufixnum=4,sufwidth=1)
MPRINT(VARLIST):   ABC01X1 ABC01X2 ABC01X3 ABC01X4 ABC02X1 ABC02X2 ABC02X3
 ABC02X4 ABC03X1 ABC03X2 ABC03X3 ABC03X4 ABC04X1
 ABC04X2 ABC04X3 ABC04X4 ABC05X1 ABC05X2 ABC05X3 ABC05X4 ABC06X1 ABC06X2
 ABC06X3 ABC06X4 ABC07X1 ABC07X2 ABC07X3 ABC07X4
 ABC08X1 ABC08X2 ABC08X3 ABC08X4 ABC09X1 ABC09X2 ABC09X3 ABC09X4 ABC10X1
 ABC10X2 ABC10X3
     ;
     array test2
      %varlist(prefix=abc,prefnum=10,prewidth=2,suffix=x,sufixnum=0,sufwidth=0)
MPRINT(VARLIST):   ABC01X ABC02X ABC03X ABC04X ABC05X ABC06X ABC07X ABC08X
 ABC09X
     ;
     .
     .
     .
   run;

***************************************************************************** */
%ut_logical(debug)
%local i j k w numprefx numsufx sufxnext return pi prfxnext;
%if %bquote(&prewidth) ^= & %bquote(&prewidth) ^= 0 %then %let prefmt = z;
%if %bquote(&sufwidth) ^= & %bquote(&sufwidth) ^= 0 %then %let suffmt = z;
%*============================================================================;
%* Verify prefix width parameter;
%*============================================================================;
%if %bquote(&prewidth) = %then %let prewidth = %length(&prefnum);
%else %if &prewidth < %length(&prefnum) & &prefnum ^= 0 %then %do;
  %errmsg(PREWIDTH of &prewidth is not enough to accomodate PREFNUM of &prefnum,
   macronam=varlist,print=0)
  %let prewidth = %length(&prefnum);
  %put prewidth reset to &prewidth;
%end;
%*============================================================================;
%* Verify suffix width parameter;
%*============================================================================;
%if %bquote(&sufwidth) = %then %let sufwidth = %length(&sufixnum);
%else %if &sufwidth < %length(&sufixnum) & &sufixnum ^= 0 %then %do;
  %errmsg(SUFWIDTH of &sufwidth is not enough to accomodate SUFIXNUM of 
   &sufixnum,macronam=varlist,print=0)
  %let sufwidth = %length(&sufixnum);
  %put sufwidth reset to &sufwidth;
%end;
%*============================================================================;
%* Generate prefix component of variable list elements;
%*============================================================================;
%let pi = 0;
%do %until (&prfxnext =);
  %let pi= %eval(&pi + 1);
  %let prfxnext = %scan(&prefix,&pi,&dlm);
  %if %bquote(&prfxnext) ^= | %bquote(&prefix) = %then %do;
    %if %bquote(&prefnum) > 0 %then %do i = &prenstrt %to &prefnum;
      %if &debug %then %put (varlist) top of prefnum loop i=&i;
      %let numprefx = %sysfunc(putn(&i,&prefmt&prewidth..));
      %let return = haspref;
      %goto suffix;
      %haspref:
    %end;
    %else %do;
      %if &debug %then %put (varlist) top of no prefnum loop;
      %let return = nopref;
      %goto suffix;
      %nopref:
    %end;
  %end;
%end;
%goto endmac;
%*============================================================================;
%* Subroutine to generate suffix component of variable list elements;
%*============================================================================;
%suffix:
  %if &debug %then %put (varlist) top of no sufixnum loop i=&i suffix=&suffix;
  %let k = 0;
  %do %until (&sufxnext =);
    %let k = %eval(&k + 1);
    %let sufxnext = %scan(&suffix,&k,&dlm);
    %if &debug %then %put (varlist) i=&i j=&j k=&k sufxnext=&sufxnext 
     prefix=&prefix numprefx=&numprefx;
    %if %bquote(&sufxnext) ^= | %bquote(&suffix) = %then %do;
      %if %bquote(&sufixnum) > 0 %then %do j = &sufnstrt %to &sufixnum;
        %if &debug %then %put (varlist) top of sufixnum loop i=&i
         numprefx=&numprefx;
        %let numsufx = %sysfunc(putn(&j,&suffmt&sufwidth..));
        &prfxnext&numprefx&sufxnext&numsufx
      %end;
      %else %do;
        &prfxnext&numprefx&sufxnext&numsufx
      %end;
    %end;
  %end;
%goto &return;
%*============================================================================;
%* End macro;
%*============================================================================;
%endmac:
%mend;
