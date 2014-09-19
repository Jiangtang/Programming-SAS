/******************************************************************************\
* $Id:$
*
* Copyright(c) 2013 SAS Institute Inc., Cary, NC, USA. All Rights Reserved.
*
* Name:     reSizeChars.sas
*
* Purpose:  re-size character fields to fit their longest value
*
* Author:   Frank Roediger
*
* Support:  SAS(r) Solutions OnDemand
*
* Input:    &DOMAIN data set with padded char vars in srceLib library
*
* Output:   &DOMAIN data set with re-sized char vars in trgtLib library
*
* Parameters: 
*              domain      -- the name of the data set to be re-sized
*              srceLibPath -- the path to the source library, where &DOMAIN 
*                             exists with the original sized fields 
*              trgtLibPath -- the path to the target library, where &DOMAIN 
*                             exists with the re-sized fields 
*
* Dependencies/Assumptions:
*
* Usage:       %reSizeChars(srceLibPath=C:\PharmaSUG2013\Data\Ocean
*                          ,trgtLibPath=C:\PharmaSUG2013\Data\Pool
*                          ,domain     =Z9
*                          );
*
*
* History:
* ddmmmyyyy userid description (Change Code)
\******************************************************************************/

%macro reSizeChars(domain=
                  ,srceLibPath=
                  ,trgtLibPath=
                  ); 
   %****************************************************************************
   %* Initialization
   %***************************************************************************;
   libname srceLib "&srceLibPath";
   libname trgtLib "&trgtLibPath";
   dm odsresults 'clear';


   %****************************************************************************
   %* Inventory all the character fields in the source domain
   %***************************************************************************;
   proc sql;
      create table charCols as
         select *
               ,upcase(name) as column
         from dictionary.columns 
            where libname         eq 'SRCELIB'  and
                  upcase(memname) eq "&domain"  and
                  type            eq 'char'
         order by column;
      create table allCols as
         select *
               ,upcase(name) as column
         from dictionary.columns 
            where libname         eq 'SRCELIB'  and
                  upcase(memname) eq "&domain"  
         order by varnum;   
   quit;

   %****************************************************************************
   %* Create one macro variable for each character field
   %***************************************************************************;
   %let charCol_Cnt=0;
   data _null_;
      set charCols 
         end=eof;
      call symput('charCol_' || strip(put(_n_,5.))
                 ,strip(column)
                 );
      put column=;
      if eof then 
         call symput('charCol_Cnt',strip(put(_n_,5.)));
   run;

   %****************************************************************************
   %* Branch to macro exit if there are no char fields in &DOMAIN
   %***************************************************************************;
   %if &charCol_Cnt eq 0 %then %do;
      %put %sysfunc(compress(ERR OR:)) There are no re-sizable %qCmpres(
         character) fields.  Please confirm that &domain exists in %qCmpres(
         the) &srceLibPath folder and that it has at least one character field.;
      %goto ERREXIT;
   %end;

   %****************************************************************************
   %* Build the parallel data set with an 'x' field for each character field
   %*    and assign the LENGTHN value of the character field to it
   %***************************************************************************;
   data parallel_&domain;
      set srceLib.&domain; 
      %do i=1 %to &charCol_Cnt;
         &&charCol_&i..x=lengthn(&&charCol_&i);
      %end;
   run;

   %****************************************************************************
   %* Determine the length of the largest string in each character field from 
   %*    the maximum value in its corresponding 'x' field
   %***************************************************************************;
   proc summary data=parallel_&domain;
      var 
         %do i=1 %to &charCol_Cnt;
            &&charCol_&i..x
         %end;
         ;
      output out=maxLengths (drop=_type_ _freq_) max=;
   run;

   %****************************************************************************
   %* Create a macro variable with the longest string length for each char field
   %***************************************************************************;
   data _null_;
      set maxLengths;
      %do i=1 %to &charCol_Cnt;
         call symput('maxLength_' || strip(put(&i,5.))
                    ,strip(put(&&charCol_&i..x,3.))
                    );
      %end;
   run;

   %****************************************************************************
   %* Create the target domain with the re-sized character lengths
   %****************************************************************************
   %* Set the VARLENCHK option to 'NOWARN' to avoid a WARNING: message for  
   %*    each re-sized field
   %***************************************************************************;
   options varlenchk=nowarn;

   data &domain;
      length 
         %do i=1 %to &charCol_Cnt;
            &&charCol_&i $ &&maxLength_&i
         %end;
            ;
      set srceLib.&domain;
   run;


   %****************************************************************************
   %* make sure that the columns are in the same order that they originally 
   %*    occurred
   %****************************************************************************
   %* Create one macro variable for each field (in the original column sequence)
   %***************************************************************************;
   data _null_;
      set allCols 
         end=eof;
      call symput('allCol_' || strip(put(_n_,5.))
                 ,strip(column)
                 );
      put column=;
      if eof then 
         call symput('allCol_Cnt',strip(put(_n_,5.)));
   run;

   proc sql;
      create table trgtlib.&domain as
         select &allCol_1
            %do i=2 %to &allCol_Cnt;
               ,&&allCol_&i
            %end;
         from &domain;
   quit; 

   %****************************************************************************
   %* Reset the VARLENCHK option to 'WARN' (its default value)
   %***************************************************************************;
   options varlenchk=warn;

   %*******************************************************************************
   %* Verify that the submission domain is identical to the source domain
   %*    (if the Results window is empty, there are no value differences)
   %******************************************************************************;
   title1 'Report of Fields Whose Values Changed During Re-Sizing';
   proc compare data   =srceLib.&domain
                compare=trgtLib.&domain
                nosummary;        /* no output if no diffs in matching values */
   run;
   title1;

   %*******************************************************************************
   %* Exit point when fatal errors encountered
   %******************************************************************************;
   %ERREXIT:;

%mend reSizeChars;



