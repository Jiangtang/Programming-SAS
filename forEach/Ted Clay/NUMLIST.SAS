%MACRO NUMLIST(listwithdash); 
  /* 
                                                           72nd col -->|
    Function: Generate the elements of a numbered list.

              For example, AA1-AA3 generates AA1 AA2 AA3
              No prefix is necessary -- 1-3 generates 1 2 3.

      Author: Ted Clay, M.S.
            Clay Software & Statistics
            tclay@ashlandhome.net  (541) 482-6435
      "Please keep, use and share this macro with this authorship note."

   Parameter: 
       ListWithDash -- text string containing a dash.  
           The text before the dash, and the text after the dash, 
           usually begin with a the same character string, called the
           stem.  (The stem could be blank or null, as is the case of 
           number-dash-number.) After the common stem must be two 
           numbers.  The first number must be less than the second 
           number.  Leading zeroes on the numbers are preserved.

  How it works: The listwithdash is parsed into _before and _after.
         _before and _after are compared equal up to the length of the
         "stem".  What is after the "stem" is assigned to _From and _to,
         which must convert to numerics. Finally, the macro generates 
         stem followed by all the numbers from _from through _to

  Examples:
     %numlist(3-6) generates 3 4 5 6.
     %numlist(1993-2004) generates 1993 1994 1995 1996 1997 1998 1999
                                   2000 2001 2002 2003 2004.
     %numlist(var8-var12) generates var8 var9 var10 var11 var12.
     %numlist(var08-var12) generates var08 var09 var10 var11 var12.

  */

%local _before _after _length1 _length2 minlength samepos _pos 
       _from _to i;

  %let _before = %scan(%quote(&listwithdash),1,-);
  %let _after  = %scan(%quote(&listwithdash),2,-);
  %let _length1 = %length(%quote(&_before));
  %let _length2 = %length(%quote(&_after));
  %let minlength=&_length1;
  %if &_length2 < &minlength %then %let minlength=&_length2;

%*put before is &_before;
%*put after is &_after;
%*put minlength is &minlength;
  %* Stemlength should be just before the first number or the first 
      unequal character;
  %let stemlength=0;
  %let foundit=0;
  %do _pos = 1 %to &minlength;
    %LET CHAR1=%upcase(%substr(%quote(&_before),&_pos,1));
    %LET CHAR2=%upcase(%substr(%quote(&_after ),&_pos,1));
    %if %index(1234567890,%QUOTE(&CHAR1)) GE 1 %then %let ISANUMBER=Y;
    %else %let isanumber=N;

    %if &foundit=0 and 
         ( &isanumber=Y OR %quote(&CHAR1) NE %QUOTE(&CHAR2) )
         %then %do;
             %let stemlength=%EVAL(&_pos-1);
             %*put   after assignment stemlength is &stemlength;
             %let foundit=1;
          %end;
  %end; 

  %if &stemlength=0 %then %let stem=;
  %else %let stem = %substr(&_before,1,&stemlength);

  %let _from=%substr(&_before,%eval(&stemlength+1));
  %let _to  =%substr(&_after, %eval(&stemlength+1));

%IF %verify(&_FROM,1234567890)>0 or
    %verify(&_TO  ,1234567890)>0 %then 
  %PUT ERROR in NUMLIST macro: Alphabetic prefixes are different;
 
%else %if &_from <= &_to %then
%do _III_=&_from %to &_to;
    %LET _XXX_=&_iii_;
    %do _JJJ_=%length(&_iii_) %to %eval(%length(&_from)-1);
        %let _XXX_=0&_XXX_;
    %end;
%TRIM(&stem&_XXX_)
%end; 
%else %PUT ERROR in NUMLIST macro: From "&_from" not <= To "&_to";

%MEND; 
