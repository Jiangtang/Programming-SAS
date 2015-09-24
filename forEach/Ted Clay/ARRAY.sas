%MACRO ARRAY(arraypos, array=, data=, var=, values=,
                       delim=%STR( ), debug=N, numlist=Y);

 /* last modified 8/4/2006                    a.k.a. MACARRAY( ).  
                                                           72nd col -->|
 Function: Define one or more Macro Arrays
     This macro creates one or more macro arrays, and stores in them 
     character values from a SAS dataset or view, or an explicit list 
     of values.

     A macro array is a list of macro variables sharing the same prefix
     and a numerical suffix.  The suffix numbers run from 1 up to a 
     highest number.  The value of this highest number, or the length 
     of the array, is stored in an additional macro variable with the 
     same prefix, plus the letter “N”.  The prefix is also referred to
     as the name of the macro array. For example, "AA1", "AA2", "AA3", 
     etc., plus "AAN".  All such variables are declared GLOBAL.

 Authors: Ted Clay, M.S.   tclay@ashlandhome.net  (541) 482-6435
          David Katz, M.S. www.davidkatzconsulting.com
      "Please keep, use and pass on the ARRAY and DO_OVER macros with
          this authorship note.  -Thanks "

 Full documentation with examples appears in SUGI Proceedings, 2006, 
     "Tight Looping With Macro Arrays" by Ted Clay
 Please send improvements, fixes or comments to Ted Clay.

 Parameters: 
    ARRAYPOS and 
    ARRAY are equivalent parameters.  One or the other, but not both, 
             is required.  ARRAYPOS is the only position parameter. 
           = Identifier(s) for the macro array(s) to be defined. 
    DATA = Dataset containing values to load into the array(s).  Can be
              a view, and dataset options such as WHERE= are OK.
    VAR  = Variable(s) containing values to put in list. If multiple 
              array names are specified in ARRAYPOS or ARRAY then the 
              same number of variables must be listed.  
    VALUES  = An explicit list of character strings to put in the list 
              or lists.  If present, VALUES are used rather than DATA 
              and VAR.  VALUES can be a numbered list, eg 1-10, a01-A20, 
              a feature which can be turned of with NUMLIST=N.
              The VALUES can be used with one or more array names 
              specified in the ARRAYPOS or ARRAY parameters.  If more 
              than one array name is given, the values are assigned to
              each array in turn.  For example, if arrays AA and BB 
              are being assigned values, the values are assigned to 
              AA1, BB1, AA2, BB2, AA3, BB3, etc.  Therefore the number
              of values must be a multiple of the number of arrays. 

    DELIM = Character used to separate values in VALUES parameter.  
              Blank is default.

    DEBUG = N/Y. Default=N.  If Y, debugging statements are activated.

    NUMLIST = Y/N.  Default=Y.  If Y, VALUES may be a number list.

 REQUIRED OTHER MACRO: Requires NUMLIST if using numbered lists are used
              in the VALUES parameter.

 How the program works.
    When the VALUES parameter is used, it is parsed into individual 
    words using the scan function. With the DATA parameter, each 
    observation of data to be loaded into one or more macro
    arrays, _n_ determines the numeric suffix.  Each one is declared
    GLOBAL using "call execute" which is acted upon by the SAS macro 
    processor immediately. (Without this "global" setting, "Call symput" 
    would by default put the new macro variables in the local symbol 
    table, which would not be accessible outside this macro.)  Because 
    "call execute" only is handling macro statements, the following 
    statement will normally appear on the SAS log: "NOTE: CALL EXECUTE 
    routine executed successfully, but no SAS statements were generated."

 History
  7/14/05 handle char variable value containing single quote
  1/19/06 VALUES can be a a numbered list with dash, e.g. AA1-AA20 
  4/1/06 simplified process of making variables global.
  4/12/06 allow VALUES= when creating more than one macro array.

    */

%LOCAL prefixes PREFIXN manum _VAR_N iter i J val VAR WHICH MINLENG
   PREFIX1 PREFIX2 PREFIX3 PREFIX4 PREFIX5 PREFIX6 PREFIX7 PREFIX8 
   PREFIX9 PREFIX10 PREFIX11
   var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 ;

%* Get array names from either the keyword or positional parameter;
%if &ARRAY= %then %let PREFIXES=&ARRAYPOS;
%else %let PREFIXES=&ARRAY;

%* Parse the list of macro array names;
%do MANUM = 1 %to 999; 
 %let prefix&MANUM=%scan(&prefixes,&MAnum,' ');
 %if &&prefix&MANUM ne %then 
   %DO;
    %let PREFIXN=&MAnum;
    %global &&prefix&MANUM..N;
    %* initialize length to zero;
    %let &&prefix&MANUM..N=0;
   %END;
  %else %goto out1;
%end; 
%out1:

%if &DEBUG=Y %then %put PREFIXN is &PREFIXN;

%* Parse the VAR parameter;
%let _VAR_N=0;
%do MANUM = 1 %to 999; 
 %let _var_&MANUM=%scan(&VAR,&MAnum,' ');
 %if %str(&&_var_&MANUM) ne %then %let _VAR_N=&MAnum;
 %else %goto out2;
%end; 
%out2:

%IF &PREFIXN=0 %THEN 
    %PUT ERROR: No macro array names are given;
%ELSE %IF %LENGTH(%STR(&DATA)) >0 and &_VAR_N=0 %THEN
    %PUT ERROR: DATA parameter is used but VAR parameter is blank;
%ELSE %IF %LENGTH(%STR(&DATA)) >0 and &_VAR_N ne &PREFIXN %THEN
    %PUT ERROR: The number of variables in the VAR parameter is not 
 equal to the number of arrays;
%ELSE %DO;

%*------------------------------------------------------;
%*  CASE 1: VALUES parameter is used
%*------------------------------------------------------;

%IF %LENGTH(%STR(&VALUES)) >0 %THEN 
%DO;
     %IF &NUMLIST=Y %then
     %DO;
         %* Check for numbered list of form xxx-xxx and expand it using
             the NUMLIST macro.;
         %IF (%INDEX(%quote(&VALUES),-) GT 0) and 
             (%length(%SCAN(%quote(&VALUES),1,-))>0) and 
             (%length(%SCAN(%quote(&VALUES),2,-))>0) and 
             (%length(%SCAN(%quote(&VALUES),3,-))=0) 
           %THEN %LET VALUES=%NUMLIST(&VALUES);
     %END;

%LET MINLENG=99999;
%DO J=1 %TO &PREFIXN;
%DO ITER=1 %TO 9999;  
  %LET WHICH=%EVAL((&ITER-1)*&PREFIXN +&J); 
  %LET VAL=%SCAN(%STR(&VALUES),&WHICH,%STR(&DELIM));
  %IF %QUOTE(&VAL) NE %THEN
    %DO;
      %GLOBAL &&&&PREFIX&J..&ITER;
      %LET &&&&PREFIX&J..&ITER=&VAL;
      %LET &&&&PREFIX&J..N=&ITER;
    %END;
  %ELSE %goto out3;
%END; 
%out3: %IF &&&&&&PREFIX&J..N LT &MINLENG
          %THEN %LET MINLENG=&&&&&&PREFIX&J..N;
%END;

%if &PREFIXN >1 %THEN 
%DO J=1 %TO &PREFIXN;
    %IF &&&&&&PREFIX&J..N NE &MINLENG %THEN 
%PUT ERROR: Number of values must be a multiple of the number of arrays;
%END;

%END;
%ELSE %DO;

%*------------------------------------------------------;
%*  CASE 2: DATA and VAR parameters used
%*------------------------------------------------------;

%* Get values from one or more variables in a dataset or view;
  data _null_;
  set &DATA end = lastobs;
%DO J=1 %to &PREFIXN; 
  call execute('%GLOBAL '||"&&PREFIX&J.."||left(put(_n_,5.)) );
  call symput(compress("&&prefix&J"||left(put(_n_,5.))), 
              trim(left(&&_VAR_&J)));
  if lastobs then 
   call symput(compress("&&prefix&J"||"N"), trim(left(put(_n_,5.))));
%END;
  run ;

%* Write message to the log;
%IF &DEBUG=Y %then
%DO J=1 %to &PREFIXN;
 %PUT &&&&PREFIX&J..N is &&&&&&PREFIX&J..N;
%END;

%END;
%END;

%MEND;
