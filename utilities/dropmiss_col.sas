%macro dropmiss_col( DSNIN=
               , DSNOUT=
               , NODROP= 
               ) ;


    %local I ;

    proc contents data=&DSNIN( drop=&NODROP ) memtype=data noprint out=_cntnts_( keep=
name type ) ; run ;
    %let N_CHAR = 0 ;
%let N_NUM  = 0 ;
 data _null_ ;
       set _cntnts_ end=lastobs nobs=nobs ;
 if nobs = 0 then stop ;
       n_char + ( type = 2 ) ;
       n_num  + ( type = 1 ) ;
       /* create macro vars containing final # of char, numeric variables */
       if lastobs
       then do ;
          call symput( 'N_CHAR', left( put( n_char, 5. ))) ;
          call symput( 'N_NUM' , left( put( n_num , 5. ))) ;
       end ;
    run ;
    /*===================================================================*/
    /* if there are no variables in dataset, stop further processing
    /*===================================================================*/
    %if %eval( &N_NUM + &N_CHAR ) = 0
    %then %do ;
       %put /----------------------------------\ ;
%put | ERROR from DROPMISS:              | ;
%put | No variables in dataset.         | ;
%put | Execution terminating forthwith. | ;
%put \----------------------------------/ ;
%goto L9999 ;
    %end ;
    /*===================================================================*/
    /* put global macro names into global symbol table for later retrieval
    /*===================================================================*/
%LET NUM0 =0;
%LET CHAR0 = 0;
%IF &N_NUM >0 %THEN %DO;
    %do I = 1 %to &N_NUM ;
       %global NUM&I  ;
    %end ;
%END;
%if &N_CHAR > 0 %THEN %DO;
    %do I = 1 %to &N_CHAR ;
       %global CHAR&I  ;
    %end ;
%END;
/*===================================================================*/
/* create macro vars containing variable names
    /* efficiency note: could compute n_char, n_num here, but must declare macro names
to be
       global b4 stuffing them
    /*
    /*===================================================================*/
    proc sql noprint ;
       %if &N_CHAR > 0 %then %str( select name into :CHAR1 - :CHAR&N_CHAR from
_cntnts_ where type = 2 ; ) ;
       %if &N_NUM  > 0 %then %str( select name into :NUM1  - :NUM&N_NUM   from
_cntnts_ where type = 1  ; ) ;
    quit ;

    /*===================================================================*/
    /* Determine the variables that are missing
  /*
    /*===================================================================*/
%IF &N_CHAR > 1 %THEN %DO;
      %let N_CHAR_1 = %EVAL(&N_CHAR - 1);
    %END;
    Proc sql ;
       select %do I= 1 %to &N_NUM; max (&&NUM&I) , %end; %IF &N_CHAR > 1 %THEN %DO;
              %do I= 1 %to &N_CHAR_1; max(&&CHAR&I), %END; %end; MAX(&&CHAR&N_CHAR)
into
              %do I= 1 %to &N_NUM; :NUMMAX&I , %END; %IF &N_CHAR > 1 %THEN %DO;
              %do I= 1 %to &N_CHAR_1; :CHARMAX&I,%END; %END; :CHARMAX&N_CHAR
              from &DSNIN;
    quit;

    /*===================================================================*/
/* initialize DROP_NUM, DROP_CHAR global macro vars
    /*===================================================================*/
    %let DROP_NUM      =  ;
%let DROP_CHAR     =  ;

%if &N_NUM > 0 %THEN %DO;
DATA _NULL_;

     %do I = 1 %to &N_NUM ;
   %IF &&NUMMAX&I =. %THEN %DO;
        %let DROP_NUM = &DROP_NUM %qtrim( &&NUM&I ) ;
    %END;
%end ;
RUN;
%END;
%IF &N_CHAR > 0 %THEN %DO;
DATA _NULL_;
     %do I = 1 %to &N_CHAR ;
   %IF "%qtrim(&&CHARMAX&I)" eq ""  %THEN %DO;
          %let DROP_CHAR     = &DROP_CHAR %qtrim( &&CHAR&I )  ;
     %END;
    %end ;
   RUN;
%END;

    /*===================================================================*/
/* Create output dataset
    /*===================================================================*/
    data &DSNOUT ;

       %if &DROP_CHAR ^=  %then %str(DROP &DROP_CHAR ;     ) ; /* drop char variables
that
              have only missing values      */
       %if  &DROP_NUM ^=   %then %str(DROP  &DROP_NUM ;      ) ; /* drop num variables
that
              have only missing values  */

       set &DSNIN ;
%if &DROP_CHAR ^=  or &DROP_NUM ^=   %then %do;

%put /----------------------------------\ ;
%put | Variables dropped are &DROP_CHAR &DROP_NUM | ;
%put \----------------------------------/ ;
         %end;
  %if &DROP_CHAR =  and &DROP_NUM =   %then %do;
            %put /----------------------------------\ ;
         %put  |     No variables are dropped  |;
%put \----------------------------------/ ;
         %end;
    run ;
 %L9999:
%mend dropmiss_col ;
