%macro ut_truncate_long_chars(inlib=_default_,outlib=_default_,select=_default_,
 exclude=_default_,maxlength=_default_,verbose=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : ut_truncate_long_Chars
TYPE                     : data transformation
DESCRIPTION              : Truncates character variables to the minimum length
                            required to hold the longest actual value.
                            All character variables with an allocated length
                            greater than a length specified by a parameter are
                            processed.
DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\General\
                            Broad_use_modules\SAS\ut_truncate_long_chars\
                            ut_truncate_long_chars DL.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : MS Windows, MVS
BROAD-USE MODULES        : ut_parmdef ut_logical ut_titlstrt
                           ut_find_long_chars ut_errmsg
INPUT                    : data sets in library specified by the INLIB parameter
OUTPUT                   : data sets written to the library specified by the
                            OUTLIB parameter
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _tc
--------------------------------------------------------------------------------
Parameters:
Name      Type     Default  Description and Valid Values
--------- -------- -------- -------------------------------------------------
INLIB     required          Libref of the input library
OUTLIB    required work     Libref of the output library.
SELECT    optional          This is passed to ut_find_long_chars
EXCLUDE   optional          This is passed to ut_find_long_chars
MAXLENGTH required see note The maximum length of a variable that will not be
                             truncated.  Variables with a length greater than
                             this value will be reported and truncated.
                             Variables with a length less than this will not
                             be reported or truncated.  A MAXLENGTH of 0 will
                             cause all character variables to be truncated.
                             This is passed to ut_find_long_chars and uses
                             the default defined in ut_find_long_chars.
VERBOSE  required 1         %ut_logical value specifying whether verbose mode
                             is on or off
DEBUG    required 0         %ut_logical value specifying whether debug mode
                             is on or off

--------------------------------------------------------------------------------
Usage Notes:

--------------------------------------------------------------------------------
Assumptions:

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

  %ut_truncate_long_chars(inlib=a,outlib=b)

  This will truncate variables with allocated lengths greater than 200 down to
  the minimum length required to hold the longest actual value.


  %ut_truncate_long_chars(inlib=a,outlib=b,maxlength=0)

  This will truncate all character variables down to the minimum length required
  to hold the longest actual value.

--------------------------------------------------------------------------------
      Author &
Ver#   Peer Reviewer   Request #        Broad-Use MODULE History Description
----  ---------------- ---------------- ----------------------------------------
1.0   Gregory Steffens BMRMRM16DEC2005C Original version of the broad-use
       Vijay Sharma                       module  December 2005
1.1 Gregory Steffens BMRMRM21FEB2007E   Migration to SAS version 9
     Michael Fredericksen
2.0   Gregory Steffens                  Added redefinition of format and
                                         informat variables when their
                                         length is changed.
                                        Added where clause so as to truncate
                                         variable lengths only when the actual
                                         length is less than the allocated
                                         length.
 **eoh*************************************************************************/
%ut_parmdef(inlib,_pdmacroname=ut_truncate_long_chars,_pdrequired=1)
%ut_parmdef(outlib,work,_pdmacroname=ut_truncate_long_chars,_pdrequired=1)
%ut_parmdef(select,_pdmacroname=ut_truncate_long_chars)
%ut_parmdef(exclude,_pdmacroname=ut_truncate_long_chars)
%ut_parmdef(maxlength,_default_,_pdmacroname=ut_truncate_long_chars,_pdrequired=1)
%ut_parmdef(verbose,1,_pdmacroname=ut_truncate_long_chars,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=ut_truncate_long_chars,_pdrequired=1)
%ut_logical(verbose)
%ut_logical(debug)
%local numdsns;
%if %bquote(&outlib) = %then %let outlib = work;
*==============================================================================;
* Call ut_find_long_chars macro;
*==============================================================================;
%ut_find_long_chars(lib=&inlib,out=_tclongchars,select=&select,
 exclude=&exclude,maxlength=&maxlength,verbose=&verbose,debug=&debug)
*==============================================================================;
* Read data set created by ut_find_long_chars and create macro variable arrays;
* DSN:     One element per data set name;
* NUMVARS: Number of long variables in each data set in DSN array;
* VAR:     2-dimensional array of the name of each long variable in each DSN;
* VAR_LEN: 2-dimensional array of the maximum actual length of each long;
*           variable in each DSN;
*==============================================================================;
%let numdsns = 0;
data _null_;
  if eof then do;
    if memname_num > 0 then
     call symput('numdsns',trim(left(put(memname_num,6.0))));
  end;
  set _tclongchars (where = (name ^=: 'no long chars' & maxlen_actual < length))
   end = eof;
  by memname;
  if first.memname then do;
    memname_num + 1;
    call symput('dsn' || trim(left(put(memname_num,6.0))),left(memname));
    var_num = 0;
  end;
  var_num + 1;
  call symput('var' || trim(left(put(memname_num,6.0))) || '_' ||
   trim(left(put(var_num,6.0))),trim(left(name)));
  call symput('var_len' || trim(left(put(memname_num,6.0))) || '_' ||
   trim(left(put(var_num,6.0))),trim(left(put(maxlen_actual,6.0))));
  if last.memname then call symput('numvars' ||
   trim(left(put(memname_num,6.0))),trim(left(put(var_num,6.0))));
run;
%if &numdsns > 0 %then %do;
  *============================================================================;
  * Process each data set with long variable lengths;
  *============================================================================;
  %do dsn_num = 1 %to &numdsns;
    *--------------------------------------------------------------------------;
    %bquote(* &dsn_num of &numdsns;)
    %bquote(* Truncating character variables in data set &&dsn&dsn_num;)
    *--------------------------------------------------------------------------;
    data &outlib..&&dsn&dsn_num;
      length
       %do var_num = 1 %to &&numvars&dsn_num;
         &&var&dsn_num._&var_num $ &&var_len&dsn_num._&var_num
       %end;
      ;
      set &inlib..&&dsn&dsn_num;
      %do var_num = 1 %to &&numvars&dsn_num;
        format &&var&dsn_num._&var_num;
        informat &&var&dsn_num._&var_num;
      %end;
    run;
  %end;
%end;
%else %ut_errmsg(msg="No long variables found",macroname=ut_truncate_long_chars,
 print=0);
%if %bquote(%upcase(&outlib)) ^= %bquote(%upcase(&inlib)) %then %do;
  *============================================================================;
  * Copy each data set with no long variable lengths;
  *============================================================================;
  %let numdsns = 0;
  data _null_;
    if eof then do;
      if memname_num > 0 then
       call symput('numdsns',trim(left(put(memname_num,6.0))));
    end;
    set _tclongchars (where = (name =: 'no long chars')) end = eof;
    by memname;
    if first.memname then do;
      memname_num + 1;
      call symput('dsn' || trim(left(put(memname_num,6.0))),left(memname));
      var_num = 0;
    end;
  run;
  %if &numdsns > 0 %then %do;
    %do dsn_num = 1 %to &numdsns;
      *------------------------------------------------------------------------;
      %bquote(* &dsn_num of &numdsns Copying data set &&dsn&dsn_num;)
      *------------------------------------------------------------------------;
      data &outlib..&&dsn&dsn_num;
        set &inlib..&&dsn&dsn_num;
      run;
    %end;
  %end;
  %else %ut_errmsg(msg="No data set without long variables found",
   macroname=ut_truncate_long_chars,print=0);
%end;
*==============================================================================;
* Clean-up at end of ut_truncate_long_chars macro;
*==============================================================================;
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _tc:;
  run; quit;
%end;
%mend;
