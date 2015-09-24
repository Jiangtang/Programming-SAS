%MACRO DO_OVER(arraypos, array=, 
               values=, delim=%STR( ),
               phrase=?, escape=?, between=, 
               macro=, keyword=);

 /*  Last modified: 8/4/2006
                                                           72nd col -->|
  Function: Loop over one or more arrays of macro variables 
           substituting values into a phrase or macro.

  Authors: Ted Clay, M.S.  
              Clay Software & Statistics
              tclay@ashlandhome.net  (541) 482-6435
           David Katz, M.S. www.davidkatzconsulting.com
         "Please keep, use and pass on the ARRAY and DO_OVER macros with
               this authorship note.  -Thanks "
          Send any improvements, fixes or comments to Ted Clay.

  Full documentation with examples appears in 
     "Tight Looping with Macro Arrays".SUGI Proceedings 2006, 
       The keyword parameter was added after the SUGI article was written.

  REQUIRED OTHER MACROS:
        NUMLIST -- if using numbered lists in VALUES parameter.
        ARRAY   -- if using macro arrays.

  Parameters:

     ARRAYPOS and 
     ARRAY are equivalent parameters.  One or the other, but not both, 
             is required.  ARRAYPOS is the only position parameter. 
           = Identifier(s) for the macro array(s) to iterate over. 
             Up to 9 array names are allowed. If multiple macro arrays
             are given, they must have the same length, that is, 
             contain the same number of macro variables.

     VALUES = An explicit list of character strings to put in an 
             internal macro array, VALUES may be a numbered lists of 
             the form 3-15, 03-15, xx3-xx15, etc.

     DELIM = Character used to separate values in VALUES parameter.  
             Blank is default.

     PHRASE = SAS code into which to substitute the values of the 
             macro variable array, replacing the ESCAPE
             character with each value in turn.  The default
             value of PHRASE is a single <?> which is equivalent to
             simply the values of the macro variable array.
             The PHRASE parameter may contain semicolons and extend to
             multiple lines.
             NOTE: The text "?_I_", where ? is the ESCAPE character, 
                   will be replaced with the value of the index variable
                   values, e.g. 1, 2, 3, etc. 
             Note: Any portion of the PHRASE parameter enclosed in 
               single quotes will not be scanned for the ESCAPE.
               So, use double quotes within the PHRASE parameter. 

             If more than one array name is given in the ARRAY= or 
             ARRAYPOS parameter, in the PHRASE parameter the ESCAPE 
             character must be immediately followed by the name of one 
             of the macro arrays, using the same case.

     ESCAPE = A single character to be replaced by macro array values.
             Default is "?".  

     BETWEEN = code to generate between iterations of the main 
             phrase or macro.  The most frequent need for this is to
             place a comma between elements of an array, so the special
             argument COMMA is provided for programming convenience.
             BETWEEN=COMMA is equivalent to BETWEEN=%STR(,).

     MACRO = Name of an externally-defined macro to execute on each 
             value of the array. It overrides the PHRASE parameter.  
             The parameters of this macro may be a combination of 
             positional or keyword parameters, but keyword parameters
             on the external macro require the use of the KEYWORD=
             parameter in DO_OVER.  Normally, the macro would have 
             only positional parameters and these would be defined in
             in the same order and meaning as the macro arrays specified
             in the ARRAY or ARRAYPOS parameter. 
             For example, to execute the macro DOIT with one positional
             parameter, separately define
                      %MACRO DOIT(STRING1); 
                          <statements>
                      %MEND;
             and give the parameter MACRO=DOIT.  The values of AAA1, 
             AAA2, etc. would be substituted for STRING.
             MACRO=DOIT is equivalent to PHRASE=%NRQUOTE(%DOIT(?)).
             Note: Within an externally defined macro, the value of the 
             macro index variable would be coded as "&I".  This is 
             comparable to "?_I_" within the PHRASE parameter.

    KEYWORD = Name(s) of keyword parameters used in the definition of 
             the macro refered to in the MACRO= parameter. Optional.  
             This parameter controls how DO_OVER passes macro array 
             values to specific keyword parameters on the macro.
             This allows DO_OVER to execute a legacy or standard macro.
             The number of keywords listed in the KEYWORD= parameter
             must be less than or equal to the number of macro arrays 
             listed in the ARRAYPOS or ARRAY parameter.  Macro array 
             names are matched with keywords proceeding from right 
             to left.  If there are fewer keywords than macro array 
             names, the remaining array names are passed as positional 
             parameters to the external macro.  See Example 6.

  Rules:
      Exactly one of ARRAYPOS or ARRAY or VALUES is required.
      PHRASE or MACRO is required.  MACRO overrides PHRASE.
      ESCAPE is used when PHRASE is used, but is ignored with MACRO.
      If ARRAY or ARRAYPOS have multiple array names, these must exist 
          and have the same length.  If used with externally defined 
          MACRO, the macro must have positional parameters that 
          correspond 1-for-1 with the array names.  Alternatively, one 
          can specify keywords which tell DO_OVER the names of keyword 
          parameters of the external macro.
 
  Examples:
     Assume macro array AAA has been created with 
             %ARRAY(AAA,VALUES=x y z)
      (1) %DO_OVER(AAA) generates: x y z;
      (2) %DO_OVER(AAA,phrase="?",between=comma) generates: "x","y","z"
      (3) %DO_OVER(AAA,phrase=if L="?" then ?=1;,between=else) generates:
                    if L="x" then x=1;
               else if L="y" then y=1;
               else if L="z" then z=1;
 
      (4) %DO_OVER(AAA,macro=DOIT) generates:
                %DOIT(x) 
                %DOIT(y)
                %DOIT(z)
          which assumes %DOIT has a single positional parameter.
          It is equivalent to:
          %DO_OVER(AAA,PHRASE=%NRSTR(%DOIT(?)))

      (5) %DO_OVER(AAA,phrase=?pct=?/tot*100; format ?pct 4.1;) 
            generates: 
                xpct=x/tot*100; format xpct 4.1;
                ypct=y/tot*100; format ypct 4.1;
                zpct=z/tot*100; format zpct 4.1;
      (6) %DO_OVER(aa bb cc,MACRO=doit,KEYWORD=borders columns)
         is equivalent to %DO_OVER(aa,bb,cc,
                  PHRASE=%NRSTR(%doit(?aa,borders=?bb,columns=?cc)))
         Either example would generate the following internal do-loop:
         %DO I=1 %to &AAN;
           %doit(&&aa&I,borders=&&bb&I,columns=&&cc&I)
         %END;
         Because we are giving three macro array names, the macro DOIT 
         must have three parameters.  Since there are only two keyword
         parameters listed, the third parameter is assumed to be 
         positional.  Positional parameters always preceed keyword
         parameters in SAS macro definitions, so the first parameter
         a positional parameter, which is given the values of first 
         macro array "aa".  The second is keyword parameter "borders=" 
         which is fed the values of the second array "bb".  The third 
         is a keyword parameter "columns=" which is fed the values of
         the third array "cc".  

  History
    7/15/05 changed %str(&VAL) to %quote(&VAL).          
    4/1/06 added KEYWORD parameter
    4/9/06 declared "_Intrnl" array variables local to remove problems
            with nesting with VALUES=.
    8/4/06 made lines 72 characters or less to be mainframe compatible
*/

%LOCAL 
  _IntrnlN
  _Intrnl1  _Intrnl2  _Intrnl3  _Intrnl4  _Intrnl5  
  _Intrnl6  _Intrnl7  _Intrnl8  _Intrnl9  _Intrnl10
  _Intrnl11 _Intrnl12 _Intrnl13 _Intrnl14 _Intrnl15 
  _Intrnl16 _Intrnl17 _Intrnl18 _Intrnl19 _Intrnl20
  _Intrnl21 _Intrnl22 _Intrnl23 _Intrnl24 _Intrnl25
  _Intrnl26 _Intrnl27 _Intrnl28 _Intrnl29 _Intrnl30
  _Intrnl31 _Intrnl32 _Intrnl33 _Intrnl34 _Intrnl35
  _Intrnl36 _Intrnl37 _Intrnl38 _Intrnl39 _Intrnl40
  _Intrnl41 _Intrnl42 _Intrnl43 _Intrnl44 _Intrnl45
  _Intrnl46 _Intrnl47 _Intrnl48 _Intrnl49 _Intrnl50
  _Intrnl51 _Intrnl52 _Intrnl53 _Intrnl54 _Intrnl55
  _Intrnl56 _Intrnl57 _Intrnl58 _Intrnl59 _Intrnl60
  _Intrnl61 _Intrnl62 _Intrnl63 _Intrnl64 _Intrnl65
  _Intrnl66 _Intrnl67 _Intrnl68 _Intrnl69 _Intrnl70
  _Intrnl71 _Intrnl72 _Intrnl73 _Intrnl74 _Intrnl75
  _Intrnl76 _Intrnl77 _Intrnl78 _Intrnl79 _Intrnl80
  _Intrnl81 _Intrnl82 _Intrnl83 _Intrnl84 _Intrnl85
  _Intrnl86 _Intrnl87 _Intrnl88 _Intrnl89 _Intrnl90
  _Intrnl91 _Intrnl92 _Intrnl93 _Intrnl94 _Intrnl95
  _Intrnl96 _Intrnl97 _Intrnl98 _Intrnl99 _Intrnl100
 _KEYWRDN _KEYWRD1 _KEYWRD2 _KEYWRD3 _KEYWRD4 _KEYWRD5 
 _KEYWRD6 _KEYWRD7 _KEYWRD8 _KEYWRD9
 _KWRDI
 ARRAYNOTFOUND CRC CURRPREFIX DELIMI DID FRC I ITER J KWRDINDEX MANUM
 PREFIXES PREFIXN PREFIX1 PREFIX2 PREFIX3 PREFIX4 PREFIX5 
 PREFIX6 PREFIX7 PREFIX8 PREFIX9
 SOMETHINGTODO TP VAL VALUESGIVEN
 ;

%let somethingtodo=Y;

%* Get macro array name(s) from either keyword or positional parameter;
%if       %str(&arraypos) ne %then %let prefixes=&arraypos;
%else %if %str(&array)    ne %then %let prefixes=&array;
%else %if %quote(&values) ne %then %let prefixes=_Intrnl;
%else %let Somethingtodo=N;

%if &somethingtodo=Y %then
%do;

%* Parse the macro array names;
%let PREFIXN=0;
%do MAnum = 1 %to 999; 
 %let prefix&MANUM=%scan(&prefixes,&MAnum,' ');
 %if &&prefix&MAnum ne %then %let PREFIXN=&MAnum;
 %else %goto out1;
%end; 
%out1:

%* Parse the keywords;
%let _KEYWRDN=0;
%do _KWRDI = 1 %to 999; 
 %let _KEYWRD&_KWRDI=%scan(&KEYWORD,&_KWRDI,' ');
 %if &&_KEYWRD&_KWRDI ne %then %let _KEYWRDN=&_KWRDI;
 %else %goto out2;
%end; 
%out2:

%* Load the VALUES into macro array 1 (only one is permitted);
%if %length(%str(&VALUES)) >0 %then %let VALUESGIVEN=1;
%else %let VALUESGIVEN=0;
%if &VALUESGIVEN=1 %THEN 
%do;
         %* Check for numbered list of form xxx-xxx and expand it 
            using NUMLIST macro.;
         %IF (%INDEX(%STR(&VALUES),-) GT 0) and 
             (%SCAN(%str(&VALUES),2,-) NE ) and 
             (%SCAN(%str(&VALUES),3,-) EQ ) 
           %THEN %LET VALUES=%NUMLIST(&VALUES);

%do iter=1 %TO 9999;  
  %let val=%scan(%str(&VALUES),&iter,%str(&DELIM));
  %if %quote(&VAL) ne %then
    %do;
      %let &PREFIX1&ITER=&VAL;
      %let &PREFIX1.N=&ITER;
    %end;
  %else %goto out3;
%end; 
%out3:
%end;

%let ArrayNotFound=0;
%do j=1 %to &PREFIXN;
  %*put prefix &j is &&prefix&j;
  %LET did=%sysfunc(open(sashelp.vmacro 
                    (where=(name eq "%upcase(&&PREFIX&J..N)")) ));
  %LET frc=%sysfunc(fetchobs(&did,1));
  %LET crc=%sysfunc(close(&did));
  %IF &FRC ne 0 %then 
    %do;
       %PUT Macro Array with Prefix &&PREFIX&J does not exist;
       %let ArrayNotFound=1;
    %end;
%end; 

%if &ArrayNotFound=0 %then %do;

%if %quote(%upcase(&BETWEEN))=COMMA %then %let BETWEEN=%str(,);

%if %length(%str(&MACRO)) ne 0 %then 
  %do;
     %let TP = %nrstr(%&MACRO)(;
     %do J=1 %to &PREFIXN;
         %let currprefix=&&prefix&J;
         %IF &J>1 %then %let TP=&TP%str(,);
            %* Write out macro keywords followed by equals. 
               If fewer keywords than macro arrays, assume parameter 
               is positional and do not write keyword=;
            %let kwrdindex=%eval(&_KEYWRDN-&PREFIXN+&J);
            %IF &KWRDINDEX>0 %then %let TP=&TP&&_KEYWRD&KWRDINDEX=;
         %LET TP=&TP%nrstr(&&)&currprefix%nrstr(&I);
     %END;
     %let TP=&TP);  %* close parenthesis on external macro call;
  %end; 
%else
  %do;
     %let TP=&PHRASE;
     %let TP = %qsysfunc(tranwrd(&TP,&ESCAPE._I_,%nrstr(&I.)));
     %let TP = %qsysfunc(tranwrd(&TP,&ESCAPE._i_,%nrstr(&I.)));
     %do J=1 %to &PREFIXN;
         %let currprefix=&&prefix&J;
         %LET TP = %qsysfunc(tranwrd(&TP,&ESCAPE&currprefix,
                                 %nrstr(&&)&currprefix%nrstr(&I..))); 
         %if &PREFIXN=1 %then %let TP = %qsysfunc(tranwrd(&TP,&ESCAPE,
                                 %nrstr(&&)&currprefix%nrstr(&I..)));
     %end;
  %end;

%* resolve TP (the translated phrase) and perform the looping;
%do I=1 %to &&&prefix1.n;
%if &I>1 and %length(%str(&between))>0 %then &BETWEEN;
%unquote(&TP)
%end;  

%end;
%end;

%MEND;
