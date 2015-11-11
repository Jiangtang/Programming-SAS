%let pgm=oto_voodoo;

/*
data _null_;
infile "c:\utl\oto_voodoo.sas" lrecl=300 recfm=v;
input;
if index(lowcase(_infile_),'%macro')>0 then do;
 macro=scan(left(_infile_ ),1,'(');
 put @5 _n_ @15 macro $32.;
end;
run;quit;
*/

/* for easy editing here are the locations macros
prefix area helps

17     %macro    utlfkil
66     %macro    nobs
107    %macro    nvar

175    %macro    _vdo_cdedec
207    %macro    _vv_annxtb
319    %macro    _vdo_basic
2949   %macro    _vdo_optlen
3039   %macro    _vdo_getmaxmin
3132   %macro    _vdo_begmidend
3226   %macro    _vdo_clean
3297   %macro    _vdo_chartx
3495   %macro    _vdo_mispop
3542   %macro    _vdo_keyunq
3623   %macro    _vdo_dupcol
3708   %macro    _vdo_cor
3771   %macro    _vdo_mnymny
3786   %macro    _vdo_relhow
3906   %macro    _vdo_cmh
3980   %macro    _vdo_tabone
4043   %macro    _vdo_taball

4204   %macro    utl_getstm
4217   %macro    DirExist
4229   %macro    utlvdoc
4491   %macro    delvars;
*/

*   *   ***    ***   ****    ***    ***
*   *  *   *  *   *   *  *  *   *  *   *
*   *  *   *  *   *   *  *  *   *  *   *
*   *  *   *  *   *   *  *  *   *  *   *
*   *  *   *  *   *   *  *  *   *  *   *
 * *   *   *  *   *   *  *  *   *  *   *
  *     ***    ***   ****    ***    ***;
%macro utlnopts(note2err=nonote2err,nonotes=nonotes)
    / des = "rock solid code fast and clean";

OPTIONS
     &nonotes
     FIRSTOBS=1
     NONUMBER
     lrecl=384
     NOFMTERR     /* turn  Format Error off                           */
     NOMACROGEN   /* turn  MACROGENERATON off                         */
     NOSYMBOLGEN  /* turn  SYMBOLGENERATION off                       */
     &NONOTES     /* turn  NOTES off                                  */
     NOOVP        /* never overstike                                  */
     NOCMDMAC     /* turn  CMDMAC command macros on                   */
     NOSOURCE    /* turn  source off * are you sure?                 */
     NOSOURCE2    /* turn  SOURCE2   show gererated source off        */
     NOMLOGIC     /* turn  MLOGIC    macro logic off                  */
     NOMPRINT     /* turn  MPRINT    macro statements off             */
     NOCENTER     /* turn  NOCENTER  I do not like centering          */
     NOMTRACE     /* turn  MTRACE    macro tracing                    */
     NOSERROR     /* turn  SERROR    show unresolved macro refs       */
     NOMERROR     /* turn  MERROR    show macro errors                */
     OBS=MAX      /* turn  max obs on                                 */
     NOFULLSTIMER /* turn  FULLSTIMER  give me all space/time stats   */
     NODATE       /* turn  NODATE      suppress date                  */
     DSOPTIONS=&NOTE2ERR
     ERRORCHECK=STRICT /*  syntax-check mode when an error occurs in a LIBNAME or FILENAME statement */
     DKRICOND=ERROR    /*  variable is missing from input data during a DROP=, KEEP=, or RENAME=     */

     /* NO$SYNTAXCHECK  be careful with this one */
;

RUN;quit;

%MEND UTLNOPTS;

%macro utlfkil
    (
    utlfkil
    ) / des="delete an external file";


    /*-------------------------------------------------*\
    |                                                   |
    |  Delete an external file                          |
    |   From SAS macro guide
    |  Sample invocations                               |
    |                                                   |
    |  WIN95                                            |
    |  %utlfkil(c:\dat\utlfkil.sas);                    |
    |                                                   |
    |                                                   |
    |  Solaris 2.5                                      |
    |  %utlfkil(/home/deangel/delete.dat);              |
    |                                                   |
    |                                                   |
    |  Roger DeAngelis                                  |
    |                                                   |
    \*-------------------------------------------------*/

    %local urc;

    /*-------------------------------------------------*\
    | Open file   -- assign file reference              |
    \*-------------------------------------------------*/

    %let urc = %sysfunc(filename(fname,%quote(&utlfkil)));

    /*-------------------------------------------------*\
    | Delete file if it exits                           |
    \*-------------------------------------------------*/

    %if &urc = 0 and %sysfunc(fexist(&fname)) %then
        %let urc = %sysfunc(fdelete(&fname));

    /*-------------------------------------------------*\
    | Close file  -- deassign file reference            |
    \*-------------------------------------------------*/

    %let urc = %sysfunc(filename(fname,''));

  run;

%mend utlfkil;

%macro nobs( libname= , data= );

proc sql noprint;select count(*) into :nobs separated by ' ' from &libname..&data;quit;

%mend nobs;

%*---------------------------------------
%*  Program:        nvar.sasmac
%*  Author:         Karsten Self
%*  Date:           2/8/96
%*
%*  copyright (c) 1996 Karsten M. Self
%*
%*  Rights for free redistribution granted if copied in whole and copyright
%*  notice is maintained.
%*
%*  THIS CODE IS PROVIDED ON AN 'AS IS' BASIS WITH NO WARRANTEE WHATSOEVER.
%*
%*  Description:    returns &nvar as observations in a dataset.
%*
%*  Bugs + quirks:
%*                  - behavior with tape data libraries is unknown, probably
%*                   does not work.
%*
%* --------------------
%*  Revised by:     KMS
%*  Revision Date:  2/13/96
%*  Version:       0.2b
%*
%* --------------------
%*  Modification log:
%*
%*  date        pgmr    ver     notes
%* -------      ----    ----    -----
%*  2/8/96      kms     0.2a    Created (do not ask me how it got to be 0.2a)
%*
%*  2/13/96     kms     0.2b    Modified NOTE/WARNING/ERROR messages to refer to this macro;
%*
%*---------------------------------------
;

%macro nvar( libname= , data= );

    /*
      %let libname=work;
      %let data=tstdatchr;
    */

    %let nvar = ;
    %let exit = 0;

    %if %length( &libname ) gt 32 %then
        %do;
        %put ERROR{} (NVAR macro) The libname %upcase( &libname ) contains more than 8 characters.;
        %let exit = 1;
        %end;

    %if %length( &data ) gt 32 %then
        %do;
        %put ERROR{} (NVAR macro) The dataset name %upcase( &data ) contains more than 8 characters.;
        %let exit = 1;
        %end;

    %if &exit gt 0 %then
        %goto exit;

    options nonotes;
    data _vvnumchr;
        set _vvtable(
            where=(
                libname= %upcase( "&libname" ) and memname eq %upcase ( "&data" )
                )
            keep= nvar libname memname num_numeric num_character
            )
        ;

        format = 'F';
        if nvar gt 1 then
            width  = ceil( log( nvar ) );

        else
            width = 1;

        call symput( 'nvar', putn( nvar, format, width ));
        output;
        stop;
        run;quit;

        options notes;
        %if &nvar eq %then
            %do;
            %put WARNING: (NVAR macro) dataset %upcase( &libname ).%upcase( &data ) does not exist;
            %end;

        %exit:


%mend nvar;


 ***    ***   ****   *****         ****   *****   ***    ***   ****   *****
*   *  *   *   *  *  *              *  *  *      *   *  *   *   *  *  *
*      *   *   *  *  *              *  *  *      *      *   *   *  *  *
*      *   *   *  *  ****           *  *  ****   *      *   *   *  *  ****
*      *   *   *  *  *              *  *  *      *      *   *   *  *  *
*   *  *   *   *  *  *              *  *  *      *   *  *   *   *  *  *
 ***    ***   ****   *****         ****   *****   ***    ***   ****   *****;


%macro _vdo_cdedec(dummy);
  /*
     data classchk;
       set sashelp.class(rename=(weight=sex_cd height=name_cd));
     run;

     %let libname=WORK;
     %let data=zip;
  */
     options nonotes;
     proc sql;
       create
         table _vv_two(where=(index(upcase(name),'_CD')=0)) as
       select
         name
        ,type
       from
         _vvcolumn
       where
         upcase(libname) = upcase("&libname") and
         upcase(memname) = upcase("&data")
       group
         by prxchange('s/_CD//',99,upcase(name))
       having
         count(prxchange('s/_CD//',99,upcase(name)))=2
     ;quit;
      options notes;

     proc format;
       value $best
     ;run;

     %macro _vv_annxtb(var);

          /* %let var=SEX; */

          /* code decode pairs have to have names like sex sex_cd */

          proc datasets nolist;
             delete _vv_nrm _vv_sec _vv_cut;
          run;quit;

          data _vv_nrm (keep=nam &var._cd &var rename=(&var._cd=cde &var=des ));
             length &var $80 &var._cd $32;
             set &libname..&data (
                  where=(s&var._cd ne '')
                  rename=(&var._cd=s&var._cd)
                  keep=&var &var._cd);
             array cd s&var._cd;
             nam   =substr(vname(cd[1]),2);;
             typ=vtype(cd[1]);
             if typ='N' then &var._cd=put(cd[1],best.);
             else &var._cd=s&var._cd;
          run;

          proc freq data=_vv_nrm order=freq noprint;
             tables nam*cde*des/missing list out=_vv_sec;
          run;

          %let nobs=%utl_nobs(_vv_sec);
          %let end=%eval(&nobs - 49);

          %put &nobs &end;

          %if &nobs > 0 %then %do;

              data _vv_cut (keep=nam grp cut cde des count percent cut);
                retain a b 0;
                %sysfunc(ifc ( (&nobs le 100),
                         %str(set _vv_sec;grp='ALL';),
                         %str(set _vv_sec(obs=50 in=a) _vv_sec(in=b firstobs=%eval(&end));grp='CUT';) ));
                select;
                  when (grp='CUT' and a ) cut='BEG';
                  when (grp='CUT' and b ) cut='END';
                  when (grp='ALL'       ) cut='ALL';
                end;
              run;

              proc append data=_vv_cut base=_vv_bascde;
              run;

          %end;

     %mend _vv_annxtb;

     proc datasets library=work nolist;
       delete _vv_bascde;
     run;

     %let fyl=%sysfunc(pathname(work))/cmd1.sas;

     data _null_;
       file "&fyl";
       set _vv_two;
       cmd=cats('%_vv_annxtb(',name,');');
       put cmd;
       putlog cmd;
       *call execute(cmd);
     run;

     %include "&fyl";

     proc format;
       value $top
      'ALL' = 'All'
      'BEG' = 'Top 30'
      'END' = 'Bottom 30'
     ;
     run;
     title;footnote;
     title "A given code should one and only one decode - one - one";
     proc report data=_vv_bascde nowd split='#';
     cols
      ( "Are Codes and Description All non-missing and one to one "
      nam
      grp
      cut
      cde
      des
      count
      percent
     )
     ;
     define nam     / order   order=data "Variable" style={just=left} width=10 flow;
     define grp     / order   order=data noprint;
     define cut     / order   order=data "Highest#Lowest 30#Frequency" format=$top. width=10;
     define cde     / display "Code"  width=16;
     define des     / display "Description"  width=55 flow;
     define count   / display order=data format=comma12. 'Count'  width=16;
     define percent / display order=data format=5.1 'Percent' width=16;
     run; quit;

%mend _vdo_cdedec;


****     *     ***   *****   ***
 *  *   * *   *   *    *    *   *
 *  *  *   *   *       *    *
 ***   *****    *      *    *
 *  *  *   *     *     *    *
 *  *  *   *  *   *    *    *   *
****   *   *   ***   *****   ***;


%macro _vdo_basic(dummy);

    * Date formats -- used for identifying date numeric variables later;
    %let dateFmt =
        %str(
        'DATE',
        'DAY',
        'DDMMYY',
        'DOWNAME',
        'JULDAY',
        'JULIAN',
        'MMDDYY',
        'MMYY',
        'MMYYC',
        'MMYYD',
        'MMYYN',
        'MMYYP',
        'MMYYS',
        'MONNAME',
        'MONTH',
        'MONYY',
        'NENGO',
        'QTR',
        'QTRR',
        'WEEKDATE',
        'WEEKDATEX',
        'WEEDKAY',
        'WORDDATE',
        'WORDDATEX',
        'YEAR',
        'YYMM',
        'YYMMC',
        'YYMMD',
        'YYMMN',
        'YYMMP',
        'YYMMS',
        'YYMMDD',
        'YYMON',
        'YYQ',
        'YYQR'
        );

    %let dttimFmt =
        %str(
        'DATETIME',
        'TOD'
        );

    %let timeFmt =
        %str(
        'HHMM',
        'HOUR',
        'MMSS',
        'MSEC',
        'PDTIME',
        'RMFDUR',
        'RMFSTAMP',
        'SMFSTAMP',
        'TIME',
        'TODSTAMP',
        'TU'
        );

    %let dtFmts=
        %str( &dateFmt., &dttimFmt., &timeFmt. );


    %*---------------
    %* Internal macros;


    *---------------
    * Get obs option setting for current session.  Save.  Reset to max for VV and restore on exit;
    proc sql noprint;
        create table work._vvRSOpt( label= "VV - SAS Options Reset Values" ) as
        select optname, setting
        from dictionary.options
        ;

        quit;

    options
        obs= max
        firstobs= 1
        compress= no
        pagesize= &PageSize.
        linesize= &LineSize.
        ;



    *----------------
    * Records and variables on requested dataset;

    /*
      %let libname=sashelp;
      %let data=class;
    */

    %let nobs = test;
    %nobs( Libname= &libname., Data= &data. );

    %let nvar = test;
    %nvar( Libname= &libname., Data= &data. );


    * No records? Quit;
    %if &nobs. lt 1 %then
            %do;
            %put ERROR: (VV macro) the dataset %upcase( &libname..&data. ) has zero records.;
            %put ERROR: (VV macro) Further processing halted.;
            %let exit = 1;
            %end;

    * No variables? Quit;
    %if &nvar. lt 1 %then
        %do;
        %put ERROR: (VV macro) the dataset %upcase( &libname..&data. ) has zero variables.;
        %put ERROR: (VV macro) Further processing halted.;
        %let exit = 1;
        %end;

    * Exit if flagged;
    %if &exit. gt 0 %then
        %goto exit;



    * ----------------
    * Parameter parsing;

    * ...FreqOrdr - change to default if illegal, with warning;

    %let FreqOrdr = %lowcase( &FreqOrdr. );

    %if &FreqOrdr. ne data       and
        &FreqOrdr. ne formatted  and
        &FreqOrdr. ne freq       and
        &FreqOrdr. ne internal      %then
        %do;
        %put WARNING: (VV macro)  invalid FreqOrdr &FreqOrdr. selected.  Using 'Freq' instead;
        %let FreqOrdr = freq;
        %end;


    * ...UniPlot - change to false if illegal, with warning;

    %let UniPlot = %lowcase( &UniPlot. );

    %if &UniPlot. ne true  and  &UniPlot. ne false %then
        %do;
        %put WARNING: (VV macro)  invalid UniPlot value &UniPlot. selected.  Using 'false' instead;
        %let UniPlot = false;
        %end;


    * ...Cleanup - change to false if illegal, with warning;


    %let Cleanup = %lowcase( &Cleanup. );

    %if &Cleanup. ne true  and  &Cleanup. ne false %then
        %do;
        %put WARNING: (VV macro)  invalid Cleanup value &Cleanup. selected.  Using 'false' instead;
        %let Cleanup = false;
        %end;



    * ...Title - trunc to 200 characters if too long;
    %if %length( &title. ) gt 200 %then
        %do;
        %let title = %substr( &title, 1, 200 );
        %end;



    * ----------------
    * Else, get serious;


    title;     * Clear titles;
    options nonotes;
    * Generate sql for query.  This is run immediately following data step;
    data _null_;

        length text $ 200;

        set _vvcolumn(
            where= ( libname = "%upcase( &libname. )" and memname = "%upcase( &data. )" ))
            end = last
            ;

        * First -- open sql statment;
        if _n_ = 1 then
            do;

            text = "proc sql noprint; " ;
            call execute( text );

            text = "create table work._vv1M( label= 'VV - Master - distinct values') as" ;
            call execute( text );

            text = "   select" ;
            call execute( text );

            text = "   count ( * ) as records, " ;
            call execute( text );

            end;


        * First and all but last -- generate query statment for variable counts;
        if not last then
            do;

            text = "count ( distinct " || name || ") as " || name || " , ";
            call execute( text );

            end;


        * Last -- close sql statement;
        else if last then
            do;
            text = "count ( distinct " || name || ") as " || name ;
            call execute( text );

            text = "from &libname..&data. " ;
            call execute( text );

            text = "; " ;
            call execute( text );

            text = "quit; " ;
            call execute( text );

            end;

        run;
    options notes;

    title "DATA VERIFICATION + VALIDATION FOR %upcase( &libname. ).%upcase( &data. )";

    %if %length( &title. ) gt 0 %then
        %do;
        title2 "&title.";
        %end;


    * Generate a dataset with variable names, labels, and counts;

    * ...transpose what you have ;
    proc transpose
        data= work._vv1M
        out= work._vv1M(
            label= "VV - SQL results - transposed"
            )
        prefix= col
        name= _name_
        ;
    run;

    options nonotes;
    * ...get more info.  Label, type, length, format;
    data _vv1D(
        label= "VV - Master - Dictionary "
        rename= ( name = variable )
        )
        ;

        keep name label type length format;

        set _vvcolumn (
            where= ( libname = "%upcase( &libname. )" and memname = "%upcase( &data. )" )
            );


        run;
    options notes;

    * join them in...;
    proc sql noprint;
        create table _vv1M(
            compress = no
            label= 'VV - Master - merge '
            ) as
        select
            M._name_ as variable label= "Variable Name",
            M.col1   as values   label= "# of Distinct Values" format= comma10. ,
            D.label  as label    label= "Label",
            D.type   as type     label= "Type",
            D.length as length   label= "Length",
            D.format as format   label= "Format"

        from
            work._vv1M as M,
            work._vv1D as D

        where
            M._name_ = D.variable
        order by D.variable
        ;
        quit;



    * More stuff to do;
    * ...identify character and numeric types for further analysis;
    *    character...
    *          ...if less than &ValCtOff values, proc freq in frequency order;
    *         ...if more than &ValCtOff values, 10 most frequent, 10 least frequent values;
    *    numeric
    *    ...if not a date....
    *            ...all - proc univariate
    *            ...less than &ValCtOff values, proc freq
    *    ...if a date
    *            proc freq on mm/yy format or something similar
    *    ...by number of values
    *       - none (null)
    *       - one (n_one) -- these guys need more looking at to see if there is just
    *         one value, or if sometimes there are missing values.  Keep them only if
    *         there is one and only one value, none missing
    ;


    * Get nobs count again, just to be sure;
    %nobs( libname= &libname., data= &data. );

    data
        _vv1M( label  = "VV - Master - classed" )

            _vvch1(
            label = "VV - Char <= &ValCtOff. values"
            drop=
                nNumA
                nNum
                nDate
                nNul
                nulls
                n_One
                n_One0
                n_One1
                 )

            _vvch2(
            label = "VV - Char  > &ValCtOff. values"
            drop=
                nNumA
                nNum
                nDate
                nNul
                nulls
                n_One
                n_One0
                n_One1
                )

        _vvNumA(
            label = "VV - Num - All quantity + date/time"
            drop=
                nChar
                nDate
                nNul
                nulls
                n_One
                n_One0
                n_One1
                )

            _vvNum1(
            label = "VV - Num <= &ValCtOff. values "
            drop=
                nChar
                nDate
                nNul
                nulls
                n_One
                n_One0
                n_One1
                )

            _vvNum2(
            label = "VV - Num  > &ValCtOff. values "
            drop=
                nChar
                nDate
                nNul
                nulls
                n_One
                n_One0
                n_One1
                )

            _vvDt(
            label  = "VV - Date/Time variables"
            drop=
                nChar
                nNumA
                nNum
                nNul
                nulls
                n_One
                n_One0
                n_One1
                )


        _vvNul(
            label  = "VV - Not evaluated"
            drop=
                nChar
                nNumA
                nNum
                nDate
                nulls
                n_One
                n_One0
                n_One1
                )

        _vvOne(
            label  = "VV - Ones vars"
            drop=
                nChar
                nNumA
                nNum
                nDate
                nNul
                n_One0
                n_One1
                )

        _vvErr(label  = "VV - Error output" )
        ;

        * Redundant and overkill, but what the hey;
        length
            nObs
            nVar
            nChar
            nNum
            nDate
            nNul
            n_One
                 8.
            label
                 $40
        ;


        retain

            /* Tabulation counters */

            nObs
            nVar
            nChar
            nNum
            nDate
            nNul
            n_One

            /* Null and One counts (values supplied in later data step) */

            nulls
            n_One0
            n_One1

            /* Initial value */

                0
            ;

        keep
            /* Info fields */
            variable
            label
            values
            format
            type
            length

            /* Dataset counts */
            _n
            nObs
            nVar

            /* Var counts */
            nChar
            nNumA
            nNum
            nDate
            nNul
            n_One

            /* Sepcial cases */

            nulls
            n_One0
            n_One1

            ;



        * Initial pass through data to pick up summary tabulations;
        if _n_ eq 1 then
            do;

            do point = 1 to _vars;

                set _vv1M
                    nobs= _vars
                    point= point
                    ;

                if _error_ then abort;

                nObs = &nobs.;
                nVar = _vars;

                select( type );
                    when( "char" )
                        nChar + 1;

                    when( "num" )
                        do;

                        nNumA + 1;

                        if upcase( compress( format, '0123456789. ' )) in( &dtFmts. ) then
                            nDate + 1;

                        else
                            nNum + 1;

                        end;

                    otherwise
                        put "ERROR: (VV macro) unexpected 'type' value:  " type= variable= _n_=;

                    end;   * select(type) processing;

                if values eq 0 then
                    nNul + 1;

                if values eq 1 then
                    n_One + 1;



                * While we are here, generate some width formatting variables;
                if point eq 1 then
                    do;
                    wnObs = max( 5, round( 1 + ( log10( nobs ) + floor( log10( nobs ) / 3 ))));
                    call symput( 'wnObs', put( wnObs, f. ) );
                    end;


                end;   * do point= processing;
            end;   * if _n_ eq 1 processing;


        set _vv1M;



        * Output, continue process;
        if values eq 1 then
            do;
            cvvOne + 1;
            _n = cvvOne;
            output _vvOne;
            end;


        * Output all;
        cvv1M + 1;
        _n = cvv1M;
        output _vv1M;


        * Output;
        if values eq 0 then
            do;
            cvvNul + 1;
            _n = cvvNul;
            output _vvNul;
            end;


        select( type );

            when( "char" )
                do;
                if values le &ValCtOff. then
                    do;
                    cvvCh1 + 1;
                    _n = cvvCh1;
                    output _vvch1;
                    end;

                else
                    do;
                    cvvCh2 + 1;
                    _n = cvvCh2;
                    output _vvch2;
                    end;
                end;  * 'char' processing;

            when( "num" )
                do;
                cvvNumA + 1;
                _n = cvvNumA;
                output _vvNumA;

                * Date type data;
                if upcase( compress( format, '0123456789. ' )) in( &dtFmts. ) then
                    do;
                    cvvDt + 1;
                    _n = cvvDt;
                    output _vvDt;
                    end;

                else
                    do;
                    if values le &ValCtOff. then
                        do;
                        cvvNum1 + 1;
                        _n = cvvNum1;
                        output _vvnum1;
                        end;
                    else
                        do;
                        cvvNum2 + 1;
                        _n = cvvNum2;
                        output _vvnum2;
                        end;
                    end;  * numerics;

                end;

            otherwise
                do;

                error;
                put "ERROR: (VV macro) Unexpected data type " type " in %upcase( &libname. ).%upcase( &data. )";
                cvvErr + 1;
                _n = cvvErr;
                output _vverr;

                end;

            end;   * select(type);

        run;


    * Index numeric datasets by variable (to allow sequential processing later);

    proc datasets lib= work nolist;

        modify _vvNum1;
        index create variable;

        modify _vvNum2;
        index create variable;

        run;
        quit;



    *----------------------------------------
    *
    *        Beginning of 'Ones' variable processing
    *
    *----------------------------------------
    *
    *
    * If there are any 'Ones' variables, find out their null counts and the single value, use to
    *  update Master and Ones datasets.
    *
    * Because of CALL EXECUTE processing, this processing cannot be run if there are no 'Ones'
    *  variables -- much unhappiness results.
    *
    * I am breaking this up into several smaller chunks in order to avoid having a macro do loop
    *   spanning pages of code
    *
    *  Process:
    *
    *     - Find out if there are any 'Ones' records (by obs count)
    *     - Set test variable (doOnes)
    *     - Execute each step if true
    ;

    %nobs( libname= work, data= _vvOne );

    %let doOnes = false;

    %if &nObs. gt 0 %then
        %let doOnes= true;



    %* ----------------;
    %if &doOnes. eq true %then
        %do;

        * Generate SQL to find number of nulls for 'Ones' variables;

        data _null_;

            length text $ 200;

            set work._vvOne
                end = last
                ;

            * First -- open sql statment;
            if _n_ = 1 then
                do;

                text = "proc sql noprint; " ;
                call execute( text );

                text = "create table work._vvOneS1(label= 'VV - Ones vars - nulls') as" ;
                call execute( text );

                text = "   select" ;
                call execute( text );

                end;


            * First and all but last -- generate query statment for variable counts;
            if not last then
                do;

                text = "nmiss( " || variable || ") as " || variable || " , ";
                call execute( text );

                end;


            * Last -- close sql statement;
            else if last then
                do;
                text = "nmiss( " || variable || ") as " || variable ;
                call execute( text );

                text = "from &libname..&data. " ;
                call execute( text );

                text = "; " ;
                call execute( text );

                text = "quit; " ;
                call execute( text );

                end;

        run;

        %end;  * doOnes processing step;
        %* ----------------;




    %* ----------------;
    %if &doOnes. eq true %then
        %do;


        * Transpose to turn variables as variables to records with variable names;

        proc transpose
            data= work._vvOneS1
            out= work._vvOneS1( label= 'VV - Ones - nulls Transposed' );
        run;

        proc datasets lib= work
            nolist
            ;

            modify _vvOneS1;
            rename
                _name_= variable
                col1  = nulls
                ;
        run;quit;

        %end;  * doOnes processing step;
        %* ----------------;




    %* ----------------;
    %if &doOnes. eq true %then
        %do;


        * Get data value associated with each 'Ones' variable;
        * ...efficiently, even (maybe)

        * ...first want to get max width of 'value';
        options nonotes;
        proc sql noprint;
            select max( length )
                into :MaxLen
                from _vvcolumn
                where libname= "%upcase( &libname. )" and memname= "%upcase( &data. )"
                ;

            quit;
        options notes;

        * ...code-generating datastep;
        data _null_;

            length   text   $ 200;

            array PutFmt{ &nVar. }   $ 16 _temporary_;   * Formatting for each variable;
            array Alignmnt{ &nVar. } $ 5  _temporary_;   * Alignment for each variable;

            set work._vvOne
                end  = last
                nobs = _nvar
                ;

            * First -- open data step;
            if _n_ eq 1 then
                do;

                * Initializaitons;
                MaxLen = min( 30, &MaxLen. );   * Maximum data length (restricted to 30);
                retain MaxLen;


                text= "    data work._vvOneV1(label= 'VV - Ones values') ;" ;
                call execute( text );

                text= "    keep variable value;" ;
                call execute( text );

                * Added put statement to solve numeric-to-char conversion problem (kms 2/7/96);
                text= "    length value $ " || put( MaxLen, f4. ) || "; " ;
                call execute( text );

                text= "    if _n_ eq 1 then do; " ;
                call execute( text );

                end;  * _n_ eq  processing;


            * Accumulate non-null value of each variable - using multiple set statements with 'where'
            *  processing to eliminate nulls
            ;

            * ...set up options for char/num processing -- format, alignment;
            select( type );

                    * Character processing;
                when( "char" )
                    do;

                    * Used to align formatted value for output;
                    Alignmnt{ _n_ } = 'left';

                    * Display format;
                    if format ne ' ' then
                        PutFmt{ _n_ } = format;

                    else
                        PutFmt{ _n_ } = compress( '$F' || ( put( MaxLen, best. )) || '.' );

                    * Missing values test;
                    MissVal = "' '";

                    end;  * type(char) processing;


                * Numeric processing;
                when( "num" )
                    do;

                    * Several possibilities: date, time, datetime, or quantity.  Question is whether
                    * or not there is a format to use.  If there is, use it.
                    ;

                    * Used to align formatted value for output;
                    Alignmnt{ _n_ } = 'right';

                    * Display format;
                    if format ne ' ' then
                        PutFmt{ _n_ } = format;

                    else
                        PutFmt{ _n_ } = compress( 'best' || ( put( MaxLen, best.)) || '.' );


                    * Missing values test;
                    MissVal = ".";

                    end;  * type(num) processing;


                otherwise
                    do;

                    * Bad type variable;
                    error "ERROR: (VV macro) bad variable TYPE value: %upcase( &libname. ).%upcase( &data. )"
                        variable= type= ;
                    stop;

                    end;

                end;  * select(type) processing;


            text= "    do i = 1 to 2; ";
            call execute( text );

            text= "        set &libname..&data.(keep= " || variable ||
                " where=( " || variable || " gt " || MissVal || " )) ; "
                ;
            call execute( text );

            text= "        retain " || variable || "; " ;
            call execute( text );

            text= "        if " || variable || " gt " || MissVal || "  then leave; " ;
            call execute( text );

            text= "        end; ";
            call execute( text );



            * Now we have a bunch of variables in one record.  Put to multiple records for each
            *  of the 'singles' vars (sounds like a bad place to meet a desperate programmer);
            if last then
                do;

                text= "    end;  * if _n_ = 1 procesing;" ;
                call execute( text );

                do _i2 = 1 to _nvar;

                    set work._vvOne;

                    text= "    variable = '" || variable || "';" ;
                    call execute( text );

                    text= "    value = " || Alignmnt{ _i2 } ||
                        " ( trim( put( " || variable || ", " || PutFmt{ _i2 } || " )));"
                        ;
                    call execute( text );

                    text= "    output;";
                    call execute( text );


                    if _i2 eq ( _nvar ) then
                        do;

                        text= "    stop; " ;
                        call execute( text );

                        text= "    run; " ;
                        call execute( text );

                        end;  * if (_i2 ) processing;
                    end;  * do ( _i2 ) processing;
                end;  * if (last) processing;
            run;

        %end;  * doOnes processing step;
        %* ----------------;




    %* ----------------;
    %if &doOnes. eq true %then
        %do;


        *----------------
        * Update the Ones dataset
        ;

        * Sort.  Nodupkey is a 'just in case';

        proc sort data= work._vvOneS1;
            by variable;
        run;


        proc sort data= work._vvOneV1  nodupkey;
            by variable value;
        run;



        data work._vvOne(
            compress= no
            label= 'VV - Ones master w/ Nulls'
            )
            ;

            merge
                work._vvOne (
                    drop= nulls
                    in= o
                )
                work._vvOneS1 (in = n)
                work._vvOneV1 (in = v)
                ;

            by variable;
            if n;

            * number 1 and 0 stuff;
            if nulls eq 0 then
                do;
                _n0 + 1;
                end;

            else
                do;
                _n1 + 1;
                end;
        run;


        * Add labels;
        proc datasets lib= work nolist;
            modify _vvOne;
            label
                nulls = '# of Missing Values'
                value = 'Data Value'
                ;

        run;
        quit;

        %end;  * doOnes processing step;
        %* ----------------;




    %* ----------------;
    %if &doOnes. eq true %then
        %do;

        *---------------
        * Update the Master dataset.  This is a majorly backass way to do things.
        * ...populate:
        *    - nulls   -- null count (global) from _vvOneS1
        *    - n_One1  -- One w/o nulls count (global)
        *    - n_One0  -- One w/ nulls count (global)
        *
        ;

        * Merge with Ones SQL for nulls -- only need 'variable' (for merge),
        * 'nulls', and 'values' (for n_One1 and n_One0 processing)
        ;

        data work._vv1M(label=  "VV - Master - %upcase( &libname. ).%upcase( &data. )" );

            merge
                work._vv1M(
                in= m
                )

                work._vvOneS1(
                in= s
                )
                ;

            by variable;
            if m;

            run;


        *--------
        * Generate totals for n_One1 and n_One0 to carry with all records
        ;
        data work._vv1M(
            label= "VV - Master - %upcase( &libname. ).%upcase( &data. )"
            )
            ;

            set work._vv1M(
                drop=
                    n_One1
                    n_One0
                )
                ;

            retain
                n_One1
                n_One0
                    0
                ;

            drop point;


            if values eq 1 then
                do;

                * Count single value guys with and without nulls;
                if nulls eq 0 then
                    do;

                    * with nulls;
                    n_One1 + 1;
                    end;

                else
                    do;

                    * without nulls;
                    n_One0 + 1;
                    end;
                end;  * if (values) processing;


            * Point processing to generate totals to carry with all records of dataset
            * ...all we need to keep is 'values' -- we just generated 'nulls'
            * ...on last, re re-read the input dataset, keeping, say, variable, and;
            * create the output dataset
            ;

            if _n_ eq _vars then
                do;

                do point= 1 to _vars;

                    set _vv1M(
                        drop=
                            n_One1
                            n_One0
                        )
                        nobs= _vars
                        ;

                    output;
                    end;  * point= processing;
                end;  * last processing;


            label
                nulls = "# Missing obs for Var"
                n_One0= "# of Unique Vars w/missing"
                n_One1= "# of Unique non-Missing Vars"
                ;
        run;


        %end;  * doOnes processing;
        %* ----------------;

    *----------------------------------------
    *
    *        End of 'Ones' variable processing
    *
    *----------------------------------------
    ;




    *--------------------------------------------------------------------------------
    *
    *  Start of reports
    *
    *--------------------------------------------------------------------------------
    * Initial reports:
    * ...all variables + dataset summary
    *    breakout by
    *       character
    *       numeric
    *          - numeric
    *          - data + time
    *
    *       unevaluated
    *       single (nonmissing) value
    ;


    data _null_;

        file print
            linesleft= remain
            ;

        set _vv1M;

        * column variables;
        y_n_  = 1;
        yVar  = y_n_  + 7;
        yVal  = yVar  + 40;
        yLabl = yVal  + 20;
        yType = yLabl + 40;
        yLen  = yType + 8;
        yFmt  = yLen  + 8;



        if _n_ eq 1 then
            do;


            put
                "Dataset summary for %upcase( &libname. ).%upcase( &data. )"
                //
                @5  "Observations: " @%eval( 5 + 12 + 3 + &wnObs. ) nObs comma&wnObs..-r /
                @5  "Variables:    " @%eval( 5 + 12 + 3 + &wnObs. ) nVar comma&wnObs..-r /
                @5  40*'-' /
                /
                @5  "Variables by type:" /
                @5  19*'-' /
                @8  "Numeric:   " @20 nNumA comma5. /
                @10 "Quantity:  " @25 nNum comma5./
                @10 "Date/Time: " @25 nDate comma5./
                /
                @8  "Character: " @20 nChar comma5./
                @5  25*'=' /
                /
                /
                @5  "Missing or uniformly evaluated variables:" /
                @5  42*'-' /
                @7  "- missing for all observations: "    @40 nNul comma5. /
                @7  "- uniformly evaluated -- all: "      @40 n_One comma5. /
                @11  "with one or more missing values:"  @45 n_One0 comma5. /
                @11  "with no missing values:"           @45 n_One1 comma5. /
                @5  50*'=' /

                ;

            link title;

            end;

        if remain le 1 then
            do;
            put _page_;
            goto title;
            end;


        put
            @y_n_  _n_          3.0
            @yVar  variable     $32.
            @yVal  values  comma12.
            @yLabl label       $40.
            @yType type         $4.
            @yLen  length        3.
            @yFmt  format      $10.
            ;

        return;

        title:
            put /
            @y_n_  " #"
            @yVar  "Variable"
            @yVal  "Unique Values"
            @yLabl "Label"
            @yType "Type"
            @yLen  "Length"
            @yFmt  "Format"
            ;

        put
            @y_n_ "---"
            @yVar "--------"
            @yVal "-------------"
            @yLabl "-----"
            @yType "----"
            @yLen  "------"
            @yFmt  "------"
            /
            ;

        return;

        run;


    *----------------------------------------------------------------------------------------
    *    character...
    *          ...if less than &ValCtOff values, proc freq in frequency order
    ;

    * first get nvar again to do some formatting - width of 'obs' count in report.  Min 3;

    %nvar( libname= &libname, data= &data );

    data _null_;
        nvar= "&nvar";
        Width= length( compress( nvar ));
        Width= max( width, 3 );
        call symput( 'Width', put( Width, best. ));
        run;



    title3 "The following variables are missing or unevaluated for all occurances";

    proc report data= work._vvNul
        nowindows
        headskip
        spacing= 4
        ;

        column    _n variable label nNul;

        define   _n       / analysis width= &width '#' '--';
        define   variable / display 'Variable Name' '--';
        define   label    / display 'Label' '--';
        define   nNul     / analysis noprint;

        run;



    title3 "The following variables are uniformly evaluated with NO missing values";
    title4 "a single non-missing value is present for all observations";

    proc report data= work._vvOne(
        where= ( nulls eq 0 )
        )

        nowindows
        headskip
        spacing= 4
        ;

        column  _n0 variable value label;

        define   _n0     / analysis width= &width '#' '--';
        define variable  / display 'Variable' '--';
        define value     / display 'Value' '--';
        define label     / display 'Label' '--';

        run;



    title3 "The following variables are uniformly evaluated with SOME missing values";

    proc report data= work._vvOne(
        where=( nulls gt 0 )
        )

        nowindows
        headskip
        spacing= 4
        ;

        column  _n1 variable value nulls label;

        define   _n1     / analysis width= &width '#' '--';
        define variable  / display 'Variable' '--';
        define value     / display 'Value' '--';
        define nulls     / display '# of Missing Values' '--';
        define label     / display 'Label' '--';

        run;



    *----------------------------------------------------------------------------------------
    * Character variables -- frequencies
    ;

    title3 "Frequency tabulations of Character variables with <= &ValCtOff. discrete values";
    title4 "non-evaluated variables excluded";

    data _null_;
        file print
            linesleft= remain
            ;

        set _vvch1(where= ( values gt 1 ));


        if _n_ eq 1 then
            link title;

        if remain le 1 then
            do;
            put _page_;
            goto title;
            end;


        put
            @15 _n_ 3.0
            @20 20*'.'
            @19 variable
            @53 label
            @107 values comma6.
            ;

        file log;

        return;

        title:
            put /
                @15 " # "
                @20 "Variables listed:"
                @40 "Label"
                @85 "# of Values"
                /
                @15 3*'-'
                @20 18*'-'
                @40 40*'-'
                @85 15*'-'
                /
                ;
        return;


        run;


    data _null_;

        length text $ 200;
        set _vvch1(where= (values gt 1))
            end= last
            ;

        if _n_ eq 1 then
            do;

            text = "proc freq data= &libname..&data.";
            call execute( text );

            text = "order= &FreqOrdr.";
            call execute( text );

            text = ";";
            call execute( text );

            text = "tables ";
            call execute( text );

            end;

        call execute( variable );

        if last then
            do;

            text = "/ missing nocum ;";
            call execute( text );

            text = "run;";
            call execute( text );

            end;

        run;


    *----------------------------------------------------------------------------------------
    *         ...if more than &ValCtOff values, 10 most frequent, 10 least frequent values;

    title3 "&ExtrmVal. most frequent + &ExtrmVal. least frequent values";
    title4 "For Character variables with > &ValCtOff. discrete values";


    data _null_;
        file print
            linesleft= remain
            ;

        set _vvch2(where= ( values gt 1 ));

        if _n_ eq 1 then
            link title;

        if remain le 1 then
            do;
            put _page_;
            goto title;
            end;


        put
            @15 _n_ 3.0
            @20 20*'.'
            @19 variable
            @53 label
            @88 values comma12.
            ;

        file log;

        return;

        title:
            put /
                @15 " # "
                @20 "Variables listed:"
                @40 "Label"
                @85 "# of Values"
                /
                @15 3*'-'
                @20 18*'-'
                @40 40*'-'
                @85 15*'-'
                /
                ;

        return;

        run;


    * Generate frequency data;
    data _null_;

        length text $ 200;

        set _vvch2(where= ( values gt 1 ));

        * If fewer than &MaxFreq results then use proc freq, else, sql;
        * &MaxFreq is the SAS system maximum number of levels for a value;
        * allowed by Proc Freq, = 32,767 as of 1/18/96 (emperically determined :-);
        * ...Order here MUST be freq -- not parameterized
        ;

        if values le &MaxFreq. then
            do;

            text = "proc freq data= &libname..&data.";
            call execute( text );

            text = "order= freq;";
            call execute( text );

            text = "tables ";
            call execute( text );

            call execute( variable );

            text = "/ missing noprint out= " || variable || "( label= 'VV - Char Extremes Freq - " || variable || "' );";
            call execute( text );

            text = "run;";
            call execute( text );

            end;

        else
            do;

            text = "proc sql noprint; " ;
            call execute( text );

            text = "create table " || variable || " as" ;
                call execute( text );

            text = "select " || variable || " as " || variable || ", count( * ) as count" ;
            call execute( text );

            text = "from &libname..&data." ;
            call execute( text );

            text = "group by " || variable ;
            call execute( text );

            text = " ; " ;
            call execute( text );

            call execute( text );
            text = "quit; " ;

            end;

        run;


    * Sort that stuff;
    data _null_;

        length text $ 200;

        set _vvch2(where= ( values gt 1 ));

        text = "proc sort data= " || variable || " nodupkey; by descending count " || variable || " ; run; ";
        call execute( text );

        run;



    * Print it;
    data _null_;

        length text $ 200;
        retain extreme;
        extreme = "&ExtrmVal.";

        set _vvch2(where= ( values gt 1 ));

        text = "data _null_ ; " ;
        call execute( text );

            text = "set " || variable || " nobs= recs ; " ;
            call execute( text );

            text = "file print;" ;
            call execute( text );

            * Report title and header;
            text = "if _n_ eq 1 then do; " ;
            call execute( text );

            text = "put // @10 ' " || extreme || " most frequent values of " || variable ||
                "   (" || trim( label ) || ") ' / ; " ;
            call execute( text );

            text = "put @20 recs comma9. ' distinct values in total' / ; " ;
            call execute ( text );

            text = "put @11 'Rank' @20 'Value' @ 100 'Frequency' ; ";
            call execute( text );

            text = "put @11 '----' @20 '-----' @ 100 '---------' //; ";
            call execute( text );

            text = "end;";
            call execute( text );


            * Report data;
            text = "if ( _n_ ge 1 and _n_ le &ExtrmVal. ) or ( _n_ le recs and _n_ ge ( recs - &ExtrmVal. )) then do; " ;
            call execute( text );

            text = "put @5 _n_ comma9. @18 " || variable ||  " @99 count comma9.; " ;
            call execute( text );

            text = "end; " ;
            call execute( text );


            * Low 10;
       /*   text = "if _n_ = 11 then " ;  * rjd */
            text = "if _n_ = %eval(&ExtrmVal. + 1) then " ;  /* rjd */
            call execute( text );

            text = "    put // @10 ' " || extreme || "  least frequent values' / ;" ;
            call execute( text );

            text= "run; " ;

        * Run Cleanup;

        if "&Cleanup." eq "true" then
            do;
            text = "proc delete data= " || variable || " ; ";
            call execute( text );

            text = "run; " ;
            call execute( text );

            end;

        run;

    * where univariate uses to be title3 Univar;

    * end where univariate used to be;

    *----------------------------------------------------------------------------------------
    *            ...less than &ValCtOff values, proc freq;
    title3 "Frequency tabulations of numeric variables with <= &ValCtOff. discrete values";
    title4 "non-evaluated variables excluded";


    data _null_;
        file print
            linesleft= remain
            ;

        set _vvnum1(where= ( values gt 1 ))
            _vvnum2(where= ( values gt 1 ))
       ;

        if _n_ eq 1 then
            link title
            ;

        if remain le 1 then
            do;
            put _page_;
            goto title;
            end;

        put
            @15 _n_ 3.0
            @20 20*'.'
            @19 variable
            @53 label
            @107 values  comma6.
            ;

        file log;

        return;

        title:
            put /
                @15 " # "
                @20 "Variables listed:"
                @40 "Label"
                @85 "# of Values"
                /
                @15 3*'-'
                @20 18*'-'
                @40 40*'-'
                @85 15*'-'
                /
                ;

        return;

        run;


    data _null_;


        length text $200;

        set
            _vvnum1(where= ( values gt 1 ))
            _vvnum2(where= ( values gt 1 ))
            end= last;

        if _n_ eq 1 then
            do;

            text = "proc freq data= &libname..&data.";
            call execute( text );

            text = "order= &FreqOrdr.";
            call execute( text );

            text = ";";
            call execute( text );

        end;

            text = "tables ";
            call execute( text );

            text = variable||"/ missing noprint out= " || variable || "( label= 'VV - Num  Extremes Freq - " || variable || "' );";
            call execute( text );

         if last then do;
            text = "run;quit;";
            call execute( text );
         end;

        run;


    * Sort that stuff;
    data _null_;

        length text $ 200;

        set _vvnum1(where= ( values gt 1 ))
          _vvnum2(where= ( values gt 1 ))
        ;

        text = "proc sort data= " || variable || " nodupkey; by descending count " || variable || " ; run; ";
        call execute( text );

        run;



    * Print it;
    data _null_;

        length text $ 200;
        retain extreme;
        extreme = "&ExtrmVal.";

        set _vvnum1(where= ( values gt 1 ))
            _vvnum2(where= ( values gt 1 ))
       ;

        text = "data _null_ ; " ;
        call execute( text );

            text = "set " || variable || " nobs= recs ; " ;
            call execute( text );

            text = "file print;" ;
            call execute( text );

            * Report title and header;
            text = "if _n_ eq 1 then do; " ;
            call execute( text );

            text = "put // @10 ' " || extreme || " most frequent values of " || variable ||
                "   (" || trim( label ) || ") ' / ; " ;
            call execute( text );

            text = "put @20 recs comma9. ' distinct values in total' / ; " ;
            call execute ( text );

            text = "put @11 'Rank' @20 'Value' @ 100 'Frequency' ; ";
            call execute( text );

            text = "put @11 '----' @20 '-----' @ 100 '---------' //; ";
            call execute( text );

            text = "end;";
            call execute( text );


            * Report data;
            text = "if ( _n_ ge 1 and _n_ le &ExtrmVal. ) or ( _n_ le recs and _n_ ge ( recs - &ExtrmVal. )) then do; " ;
            call execute( text );

            text = "put @5 _n_ comma9. @18 " || variable ||  " @99 count comma9.; " ;
            call execute( text );

            text = "end; " ;
            call execute( text );


            * Low 10;
            text = "if _n_ = 11 then " ;
            call execute( text );

            text = "    put // @10 ' " || extreme || "  least frequent values' / ;" ;
            call execute( text );

            text= "run; " ;

        * Run Cleanup;

        if upcase("&Cleanup.") eq upcase("true") then
            do;
            text = "proc delete data= " || variable || " ; ";
            call execute( text );

            text = "run; " ;
            call execute( text );

            end;

        run;


    data _null_;
        set
            _vvnum1(where= ( values gt 1 ))
            _vvnum2(where= ( values gt 1 ))   /* rjd 2/1/2015 */
            _vvDt(where= ( values gt 1 ))
            end= last
            ;

        by variable;

        if _n_ eq 1 then
            do;

            text = "proc means data= &libname..&data. n min max mean median std sum";
            call execute( text );

            text = "; ";
            call execute( text );

            text = "var ";
            call execute( text );

            end;

        call execute( variable );

        if last then
            do;

            text = ";";
            call execute( text );

            text = "run;";
            call execute( text );

            end;

        run;



    *----------------------------------------------------------------------------------------
    *    numeric
    *    ...if not a date....
    *            ...all - proc univariate;



    title3 "Date/Time/Datetime Variables";
    title4 "non-evaluated variables excluded";

    data _null_;
        file print
            linesleft= remain
            ;

        set _vvDt(where= ( values gt 0 ));

        if _n_ eq 1 then
            link title;

        if remain le 1 then
            do;
            put _page_;
            goto title;
            end;

        put
            @15 _n_ 3.0
            @20 20*'.'
            @19 variable
            @53 label
            @107 values
            ;

        file log;

        return;

        title:
            put /
                @15 " # "
                @20 "Variables listed:"
                @40 "Label"
                @85 "# of Values"
                /
                @15 3*'-'
                @20 18*'-'
                @40 40*'-'
                @85 15*'-'
                /
                ;

        return;

        run;



    *----------------------------------------------------------------------------------------
    * 2/14/96 -- Date/Time/Datetime processing --
    *    Changing this to provide Univariate data and maybe a plot
    *
    * ...General structure:
    *    Get Univariate statistics for each date/time/datetime variable
    *    Format the output accordingly for date, time, or datetime
    *    Data _null_ to output Univariate statistics and percentile values.
    ;

    data _null_;

        length
            text     $ 200
            DispFmt  $ 20
            _format  $ 20
            timetype $ 8
            ;

        set _vvDt(where= ( values gt 0 ));

        * Assign display format according to assigned format;
        *    - DispFmt --  display format
        *    - DispUnt -- unit text (days, mins, secs)
        *    - DispAgr -- aggregate text (years, days, hours)
        *    - DispFact-- conversion factor from display unit to aggregate unit
        ;

            * ...temp value for testing;
        _format = upcase( compress( format, '0123456789. ' ));

        * dateFmt dttimFmt timeFmt;

        select( _format );

            when( &DateFmt. )
                do;

                TimeType= "date";
                DispFmt= "mmddyy10.";
                DispUnt= "days";
                DispAgr= "years";
                DispFact= 365.25;

                end;  * date formats processing;

            when( &dttimFmt. )
                do;

                TimeType= "datetime";
                DispFmt= "datetime7.";
                DispUnt= "secs";
                DispAgr= "days";
                DispFact= 60 * 60 * 24 ;  * Seconds by minutes by hours per day;

                end;  * datetime formats processing;

            when( &timeFmt. )
                do;

                TimeType= "time";
                DispFmt= "time5.";
                DispUnt= "secs";
                DispAgr= "hours";
                DispFact= 60 * 60 ;   * Seconds per minute per hour;

                end;  * time formats processing;

            otherwise
                do;

                error "ERROR: (VV macro) bad format value encountered, contact developer -- Karsten Self";
                error "ERROR: (VV macro) email to:  kmself@ix.netcom.com";
                error "ERROR: (VV macro) Date/Time/Datetime variable processing" variable= format= ;
                stop;

                end;  * Otherwise (format) processing;


            end; * Select processing;


        * Generate proc univariate for each variable (do this for all _n_);

        text= "proc univariate data= &libname..&data. noprint; " ;
        call execute( text );

        text= "   var " || variable || " ; " ;
        call execute( text );

        text= "    output " ;
        call execute( text );

        text= "        out= " || variable || "( label= 'VV - Date Univariate - " || variable || "' ) " ;
        call execute( text );

        text= "        n        = n ";
        call execute( text );

        text= "        nmiss        = nmiss ";
        call execute( text );

        text= "        mean        = mean ";
        call execute( text );

        text= "        std        = std ";
        call execute( text );

        text= "        max        = max ";
        call execute( text );

        text= "        min        = min ";
        call execute( text );

        text= "        range        = range ";
        call execute( text );

        text= "        qrange        = qrange ";
        call execute( text );

        text= "        p1        = p1 ";
        call execute( text );

        text= "        p5        = p5 ";
        call execute( text );

        text= "        p10        = p10 ";
        call execute( text );

        text= "        q1        = q1 ";
        call execute( text );

        text= "        median        = median ";
        call execute( text );

        text= "        q3        = q3 ";
        call execute( text );

        text= "        p90        = p90 ";
        call execute( text );

        text= "        p95        = p95 ";
        call execute( text );

        text= "        p99        = p99 ";
        call execute( text );

        text= "        ; " ;
        call execute( text );



        text= "   run; " ;
        call execute( text );



        * Generate proc datasets to modify formats -- this is done according to
        *  date/time/datetime format;

        text= "proc datasets lib= work nolist; " ;
        call execute( text );

        text= "    modify " || variable || " ; " ;
        call execute( text );

        text= "    format " ;
        call execute( text );

        text= "        n nmiss     comma10. " ;
        call execute( text );



        * ...the next bit depends on the kind of data;

        text= "        mean min max median q1 q3 p99 p95 p90 p10 p5 p1 " || DispFmt ;
        call execute( text );

        text= "        range qrange comma12. " ;
        call execute( text );

        text= "        std comma12.2 " ;
        call execute( text );

        text= "        ; " ;
        call execute( text );


        text= "    run; " ;
        call execute( text );

        text= "    quit; " ;
        call execute( text );




        * Generate data _null_ for report;
        * ...setups and initalizations;
        *    specify n= pagesize to allow relocation over page;


        text= "title3 'Date/Time/Datetime Variables';" ;
        call execute( text );

        text= "title4 'non-evaluated variables excluded'; ";
        call execute( text );



        text= "data _null_; ";
        call execute( text );

        text= "    set " || variable || "; " ;
        call execute( text );

        text= "    file print  n= pagesize; " ;
        call execute( text );


        text= "    format dRange dQrange   comma12.2  dStd comma12.2; " ;
        call execute( text );


        text= "    dStd  = std  / " || put( DispFact, 8. ) || " ; " ;
        call execute( text );

        text= "    dRange  = range  / " || put( DispFact, 8. ) || " ; " ;
        call execute( text );

        text= "    dQRange = qrange / " || put( DispFact, 8. ) || " ; " ;
        call execute( text );


        * Define postional column and row variables -- as text, since we are just writing them out;
        yTitle=  '4';    * Vertical position of first row of titles;
        yData=   '9';   * Vertical position of first row data output;

        xTitle=  '5';   * Horizontal position titles;

        xTtl1=  '5';    * Position first title column;


        * Following is depending on date, time, or datetime;

        select( TimeType );

            when( 'date' )
                do;

                xVal1a=  '10';   * Position first values column 'a' (n, nmiss);
                xVal1b=  '29';   * Position first values column 'b' (  );
                xVal1c=  '26';   * Position first values column 'c' (mean);
                xVal1d=  '27';   * Position first values column 'd' (std, decimal range);
                xVal1e=  '24';   * Position first values column 'e' (range);

                xTtl2=  '50';   * Position second title column;
                xVal2=  '60';   * Position second values column;

                end;  * date;

            when( 'time' )
                do;

                xVal1a=  '10';   * Position first values column 'a' (n, nmiss);
                xVal1b=  '29';   * Position first values column 'b' (  );
                xVal1c=  '30';   * Position first values column 'c' (mean);
                xVal1d=  '26';   * Position first values column 'd' (std, decimal range);
                xVal1e=  '23';   * Position first values column 'e' (range);

                xTtl2=  '50';   * Position second title column;
                xVal2=  '60';   * Position second values column;

                end;  * time;

            when( 'datetime' )
                do;

                xVal1a=  '10';   * Position first values column 'a' (n, nmiss);
                xVal1b=  '26';   * Position first values column 'b' (  );
                xVal1c=  '28';   * Position first values column 'c' (mean);
                xVal1d=  '26';   * Position first values column 'd' (std, decimal range);
                xVal1e=  '23';   * Position first values column 'e' (range);

                xTtl2=  '50';   * Position second title column;
                xVal2=  '60';   * Position second values column;

                end;  * datetime;

            otherwise
                do;
                error "ERROR: (VV macro) %upcase( &libname. ).%upcase( &data. )  invalid time time "
                    TimeType= format= variable= ;
                end;

            end;  * select( TimeType );


        * ...report put statements;

        *    titles;

        text= "    if _n_ eq 1 then";
        call execute( text );

        text= "        do; ";
        call execute( text );

        text= "        put ";
        call execute( text );

        text= "           #" || yTitle || " @" || xTitle ;
        call execute( text );

        text= "         'Univariate distribution of " || trim( variable ) || " ( " || trim( label ) || " ) values' /";
        call execute( text );

        text= "           @"|| xTitle || " 'Distinct values: " || trim( left( put( values, comma10.-l))) || "' /" ;
        call execute( text );

        text= "           @"|| xTitle || " 'Format in dataset:  " || trim( left( format ) ) || "' /";
        call execute( text );

        text= "           @"|| xTitle || " 65*'-' /";
        call execute( text );

        text= "           ;" ;
        call execute( text );

        text= "        end;" ;
        call execute( text );




        *    data;

        *    ...title 1;

        text= "    put // ";
        call execute( text );

        text= "    #" || yData || " @" || xTtl1 || " 'n'      / ";
        call execute( text );

        text= "                     @" || xTtl1 || " 'nmiss'  / ";
        call execute( text );

        text= "    / ";
        call execute( text );

        text= "                     @" || xTtl1 || " 'mean'   / ";
        call execute( text );

        text= "                     @" || xTtl1 || " 'std - " || DispUnt || "'    / ";
        call execute( text );

        text= "                     @" || xTtl1 || " 'std - " || DispAgr || "'    / ";
        call execute( text );

        text= "    / ";
        call execute( text );

        text= "                     @" || xTtl1 || " 'range - " || DispUnt || "' / " ;
        call execute( text );

        text= "                     @" || xTtl1 || " 'range - " || DispAgr || "' / " ;
        call execute( text );

        text= "    / ";
        call execute( text );

        text= "                     @" || xTtl1 || " 'Q1-Q3 - " || DispUnt || "' / ";
        call execute( text );

        text= "                     @" || xTtl1 || " 'Q1-Q3 - " || DispAgr || "' / ";
        call execute( text );



        *    ...value 1;

        text= "           #" || yData || " @" || xVal1a || " n comma10.-r     / " ;
        call execute( text );

        text= "                            @" || xVal1a || " nmiss comma10.-r / " ;
        call execute( text );

        text= "    / ";
        call execute( text );

        text= "                            @" || xVal1c || " mean " || DispFmt ||"-r  / " ;
        call execute( text );

        text= "                            @" || xVal1d || " std  comma12.2-r  / " ;
        call execute( text );

        text= "                            @" || xVal1d || " dStd  comma12.2-r  / " ;
        call execute( text );

        text= "    / ";
        call execute( text );

        text= "                            @" || xVal1e || " Range comma12.-r / " ;
        call execute( text );

        text= "                            @" || xVal1d || " dRange comma12.2-r / " ;
        call execute( text );

        text= "    / ";
        call execute( text );

        text= "                            @" || xVal1e || " QRange comma12.-r / " ;
        call execute( text );

        text= "                            @" || xVal1d || " dQRange comma12.2-r / " ;
        call execute( text );


        *    ...title 2;

        text= "           #" || yData || " @" || xTtl2 || " 'min'    / " ;
        call execute( text );

        text= "                            @" || xTtl2 || " 'P1'     / " ;
        call execute( text );

        text= "                            @" || xTtl2 || " 'P5'     / " ;
        call execute( text );

        text= "                            @" || xTtl2 || " 'P10'    / " ;
        call execute( text );

        text= "                            @" || xTtl2 || " 'Q1'     / " ;
        call execute( text );

        text= "                            @" || xTtl2 || " 'median' / " ;
        call execute( text );

        text= "                            @" || xTtl2 || " 'Q3'     / " ;
        call execute( text );

        text= "                            @" || xTtl2 || " 'P90'    / " ;
        call execute( text );

        text= "                            @" || xTtl2 || " 'P95'    / " ;
        call execute( text );

        text= "                            @" || xTtl2 || " 'P99'    / " ;
        call execute( text );

        text= "                            @" || xTtl2 || " 'max'    " ;
        call execute( text );



        *    ...value 2;

        text= "           #" || yData || " @" || xVal2 || " min    / " ;
        call execute( text );

        text= "                            @" || xVal2 || " P1     / " ;
        call execute( text );

        text= "                            @" || xVal2 || " P5     / " ;
        call execute( text );

        text= "                            @" || xVal2 || " P10    / " ;
        call execute( text );

        text= "                            @" || xVal2 || " Q1     / " ;
        call execute( text );

        text= "                            @" || xVal2 || " median / " ;
        call execute( text );

        text= "                            @" || xVal2 || " Q3     / " ;
        call execute( text );

        text= "                            @" || xVal2 || " P90    / " ;
        call execute( text );

        text= "                            @" || xVal2 || " P95    / " ;
        call execute( text );

        text= "                            @" || xVal2 || " P99    / " ;
        call execute( text );

        text= "                            @" || xVal2 || " max    " ;
        call execute( text );



        *    end of put statement;

        text= ";";
        call execute( text );



        * Close out data step;

        text= "run;";
        call execute( text );


    * moved univariate to here;

    *----------------------------------------------------------------------------------------
    *    numeric
    *    ...if not a date....
    *            ...all - proc univariate;

    title3 "Univariate tabulations non-date/time/datetime Numeric variables";
    title4 "includes only variables with TWO or more values";


    * order by variable utilizing index;

    data _null_;
        file print
            linesleft= remain
            ;

        set
            _vvnum1(where= ( values gt 1 ))
            _vvnum2(where= ( values gt 1 ))
            ;

        by variable;

        if _n_ eq 1 then
            link title;

        if remain le 1 then
            do;
            put _page_;
            goto title;
            end;


        put
            @15 _n_ 3.0
            @20 20*'.'
            @19 variable
            @53 label
            ;

        file log;

        return;

        title:
            put /
                @15 " # "
                @20 "Variables listed:"
                /
                @15 3*'-'
                @20 18*'-'
                /
                ;

        return;

        run;





    data _null_;
        set
            _vvnum1(where= ( values gt 1 ))
            _vvnum2(where= ( values gt 1 ))  /* rjd 2/1/2015 */
            end= last
            ;

        by variable;

        if _n_ eq 1 then
            do;

            text = "proc univariate data= &libname..&data.";
            call execute( text );

            if "&UniPlot." eq "true" then
                do;

                text= "plot";
                call execute ( text );

                end;  * UniPlot processing;


            text = "; ";
            call execute( text );

            text = "var ";
            call execute( text );

            end;

        call execute( variable );

        if last then
            do;

            text = ";";
            call execute( text );

            text = "run;";
            call execute( text );

            end;

        run;

        * end univariate;


        /* Cleanup, if selected

        data _null_;

          set _vvnum1
              _vvmum2;   * rjd 2/1/2015 ;

          if upcase("&Cleanup.") eq upcase("true") then
            do;

            text= "proc delete data= work." || variable || " ; " ;
            call execute( text );

            text= "run; " ;
            call execute( text );

            end;  * Cleanup processing;

        * We are done here;

        run;
        */

   %exit:

%mend _vdo_basic;


 ***   ****   *****  *      *****  *   *
*   *  *   *    *    *      *      **  *
*   *  *   *    *    *      *      * * *
*   *  ****     *    *      ****   *  **
*   *  *        *    *      *      *   *
*   *  *        *    *      *      *   *
 ***   *        *    *****  *****  *   *;

%macro _vdo_optlen(
        lib=&libname
       ,mem=&data
       ,out=_vdo_maxmin
       );

  /*
  %let lib=sashelp;
  %let mem=zipcode;
  %let out=_vdo_maxmin;
  */

  data _vdo_nummax /view=_vdo_nummax ;
      * Rick Langstoon;
      set %str(&lib).%str(&mem)(drop=_character_);
      retain __typ 'N';
      length __nam $32;
      keep __typ __nam __len __vlen;
      array num[*] _numeric_;
      do i=1 to dim(num);
         __nam=vname(num[i]);
         __vlen=vlength(num[i]);
         if num[i]=. then __len=3;
         else do;
            if num[i] ne trunc( num[i], 7 ) then __len = 8 ; else
            if num[i] ne trunc( num[i], 6 ) then __len = 7 ; else
            if num[i] ne trunc( num[i], 5 ) then __len = 6 ; else
            if num[i] ne trunc( num[i], 4 ) then __len = 5 ; else
            if num[i] ne trunc( num[i], 3 ) then __len = 4 ; else __len=3;
            output;
         end;
       end;
   run;quit;

   * long and skinny for char vars;
   data _vdo_chrmaxmin/view=_vdo_chrmaxmin;
      do until(dne);
         set %str(&lib).%str(&mem)(drop=_numeric_) end=dne;
         array chr[*] _character_;
         retain __typ 'C';
         length __nam $32;
         keep __typ __nam __len __vlen;
         do i=1 to dim(chr);
            __nam  = vname(chr[i]);
            __vlen = vlength(chr[i]);
            __len  = length(chr[i]);
            output;
         end;
      end;
      dne=0;
      do until(dne);
        set _vdo_nummax;
        output;
      end;
      stop;
   run;

   proc sql;
      create
         table &out as
      select
         __typ
        ,case (__typ)
           when ('C') then 'Character'
           else            'Numeric'
         end as Variable_Type
        ,__nam      as Name
        ,max(__len)  as New_Length
        ,max(__vlen) as Original
        ,max(__vlen) - max(__len)  as Savings
      from
        _vdo_chrmaxmin
      group
        by __typ, __nam
   ;quit;

    title;footnote;
    title1 ' ';title2 ' ';title3 ' ' ;
    title4 "Maximum Number of Bytes to hold Character and Numeric Vales Exactly";

    proc print data=&out width=min;
    var name __typ max_lengths;
    run;quit;

%mend _vdo_optlen;

*   *    *    *   *  *   *  *****  *   *
** **   * *   *   *  ** **    *    **  *
* * *  *   *   * *   * * *    *    * * *
*   *  *****    *    *   *    *    *  **
*   *  *   *   * *   *   *    *    *   *
*   *  *   *  *   *  *   *    *    *   *
*   *  *   *  *   *  *   *  *****  *   *;

%macro _vdo_getmaxmin(
       lib=&libname
      ,mem=&data
      ,out=_vdo_jst
      ) /DES= "Used by utl_voodoo for max mins";

    %local lst mx n ;

    /*
    * for testing;
    %let lib=sashelp;
    %let mem=shoes;
    */

    options nonotes;

    proc sql noprint;
       select name into :lst separated by ' ' from _vvcolumn
       where upcase(libname)=upcase("&lib.") and upcase(memname)=upcase("&mem.");
    quit;

    options notes;

    %put lst=&lst;

    %macro _vdo_getmaxmin001;

       proc sql;
         create table _vdo_getmax(drop=done) as
         %let n=1;
         select
           'max' as typ,
           %do %until (%scan(&lst,&n)=);
             %let mx=%scan(&lst,&n);
             %str(max(&mx) as &mx,)
             %let n=%eval(&n + 1);
           %end;
             1 as done
         from
             %str(&lib.).%str(&mem.)
      ;
         create table _vdo_getmin(drop=done) as
         %let n=1;
         select
           'min' as typ,
           %do %until (%scan(&lst,&n)=);
             %let mx=%scan(&lst,&n);
             %str(min(&mx) as &mx,)
             %let n=%eval(&n + 1);
           %end;
             1 as done
         from
             %str(&lib.).%str(&mem.)
      ;
      quit;

    %mend _vdo_getmaxmin001;

    %_vdo_getmaxmin001;

    data _vdo_bth;
       set _vdo_getmax _vdo_getmin;
    run;

    proc transpose data=_vdo_bth out=_vdo_bthxpo;
    var _character_ _numeric_;
    id typ;
    run;

    data &out(rename=_name_=variable where=(upcase(variable) ne 'TYP'));
      retain min max;
      set _vdo_bthxpo;
      min=left(min);
      max=left(max);
    run;

    title;footnote;
    title1 ' ';title2 ' ';title3 ' ' ;
    title4 "Maximums and Minimums %str(&lib.).%str(&mem.)";
    proc print data=&out noobs width=min uniform;
    var variable min max;
    run;

%mend _vdo_getmaxmin;

****   *****   ***          *   *  *****  ****          *****  *   *  ****
 *  *  *      *   *         ** **    *     *  *         *      **  *   *  *
 *  *  *      *             * * *    *     *  *         *      * * *   *  *
 ***   ****   * ***         *   *    *     *  *         ****   *  **   *  *
 *  *  *      *   *         *   *    *     *  *         *      *   *   *  *
 *  *  *      *   *         *   *    *     *  *         *      *   *   *  *
****   *****   ***          *   *  *****  ****          *****  *   *  ****;

%macro _vdo_begmidend(dummy);

    *----------------------------------
    * Contents and prints;

    * ...clear all secondary titles;
    title3;

    proc contents data= &libname..&data.
        position
        details
        ;
        run;

    title3 "Sample observations";

    * We need to get this again, polluted the value above;
    %nobs( libname= &libname., data= &data. );

    * If less than 60 records, print them all;
    %if &nobs. le 60 %then
        %do;

        title5 "The following is a complete listing of %upcase( &libname. ).%upcase( &data. )";
        proc print data= &libname..&data.
            rows= page
            label
            uniform
            n
            ;

            run;

        %end;

    %else
        %do;

        title3 "Sample observations  --  showing first, last, and middle 20 records";

        title5 "Records 1 - 20";
        proc print data= &libname..&data.( obs= 20 )
            rows= page
            label
            uniform
            n
            ;

            run;

        title5 "Last 20 Records  --  %eval( &nobs. - 19) - &nobs.";
        proc print data= &libname..&data.(
            firstobs= %eval( &nobs. - 19)
            )

            rows= page
            label
            uniform
            n
            ;

            run;


        %let Middle = %eval( &nobs. / 2 );

        title5 "Middle 20 Records  --  %eval( &Middle. - 9 ) - %eval( &Middle. + 10 )";
        proc print data= &libname..&data.(
            firstobs= %eval( &Middle. - 9 )
            obs     = %eval( &Middle. + 10 )
            )

            rows= page
            label
            uniform
            n
            ;

            run;


        %end;


 %mend _vdo_begmidend;

 ***   *      *****    *    *   *
*   *  *      *       * *   **  *
*      *      *      *   *  * * *
*      *      ****   *****  *  **
*      *      *      *   *  *   *
*   *  *      *      *   *  *   *
 ***   *****  *****  *   *  *   *;

 %macro _vdo_clean(dummy);

    *--------------------------------;
    %exit:

    * Clear titles;
    title;

    * Reset obs to its default;
    data _null_;
        set work._vvRSOpt;

        select( optname );
        when( 'OBS' )
            call execute( 'options obs= ' || trim( setting ) || ';' );
        when( 'FIRSTOBS' )
            call execute( 'options firstobs= ' || trim( setting ) || ';' );
        when( 'LINESIZE' )
            call execute( 'options linesize= ' || trim( setting ) || ';' );
        when( 'PAGESIZE' )
            call execute( 'options pagesize= ' || trim( setting ) || ';' );

        otherwise
            do;
            * nothing;
            end;

        end; * select;

        run;

    proc delete  data= work._vvRSOpt;
    run;quit;

    * Clear temp datasets if they exist;
    proc datasets lib= work nolist;


        %if %upcase(&Cleanup.) eq %upcase(TRUE) %then
            %do;
            delete
                _vv1M
                _vv1D
                _vvCh1
                _vvCh2
                _vvNumA
                _vvDt
                _vvNum1
                _vvNum2
                _vvOne
                _vvOneS1
                _vvOneV1
                _vvErr
                _vvNul
                ;

            %end;
    run;
    quit;

%mend _vdo_clean;

 ***   *   *    *    ****   *****
*   *  *   *   * *   *   *    *
*      *   *  *   *  *   *    *
*      *****  *****  ****     *
*      *   *  *   *  * *      *
*   *  *   *  *   *  *  *     *
 ***   *   *  *   *  *   *    *;


%macro _vdo_chartx(var,typ,val,lbl,fmt,lib=&libname,mem=&data)/minoperator;

  %if &xeqcnt = 0 %then %do;

     proc sql;
       create
       table _vv_tic (tic num);
       insert into _vv_tic values(1000000000  );
       insert into _vv_tic values(100000000  );
       insert into _vv_tic values(10000000  );
       insert into _vv_tic values(1000000  );
       insert into _vv_tic values(500000  );
       insert into _vv_tic values(250000  );
       insert into _vv_tic values(100000  );
       insert into _vv_tic values(50000  );
       insert into _vv_tic values(10000  );
       insert into _vv_tic values(5000  );
       insert into _vv_tic values(1000  );
       insert into _vv_tic values(500   );
       insert into _vv_tic values(200   );
       insert into _vv_tic values(100   );
       insert into _vv_tic values(80    );
       insert into _vv_tic values(70    );
       insert into _vv_tic values(60    );
       insert into _vv_tic values(50    );
       insert into _vv_tic values(40    );
       insert into _vv_tic values(30    );
       insert into _vv_tic values(20    );
       insert into _vv_tic values(10    );
       insert into _vv_tic values(5     );
       insert into _vv_tic values(2     );
       insert into _vv_tic values(1     );
       insert into _vv_tic values(0.5   );
       insert into _vv_tic values(0.2   );
       insert into _vv_tic values(0.1   );
       insert into _vv_tic values(0.05  );
       insert into _vv_tic values(0.02  );
       insert into _vv_tic values(0.01  );
       insert into _vv_tic values(0.005 );
       insert into _vv_tic values(0.002 );
       insert into _vv_tic values(0.001 );
       insert into _vv_tic values(0.0005);
       insert into _vv_tic values(0.0002);
       insert into _vv_tic values(0.0001);
    ;quit;

  %end;

  %let xeqcnt=%eval(&xeqcnt + 1);

  title "Variable=&var Type=%upcase(&typ) label=&lbl";

  /* turn into macro if you like
    %let lib=qhp;
    %let mem=qhp.QHP_200DEM_CATOLDNEWFIX;
    %let mem=QHP_200DEM_CATOLDNEWFIX;
    %let var=coverage_level;

  %let skp1=%sysfunc(reverse(&var));
  %put &=skp1;
  %let skp2=%substr(&skp1,1,1);
  %let skp=%eval(1 - (&skp2 in 2 3 4 5 6 7 8 9 ));

  %put *** &var ** &skp ****;
  run;quit;
  */

  %if (&val le 100) and %upcase(&typ)=%upcase(char)  %then %do;

    /* Produce the chart  %let var=drg2_cd; %let libname=work; %let data=tstdat;  */
    %put *** <= 90 ***;
    proc sql;
       create table _vv_unqdes as select distinct &var as maxis1 from %str(&lib).%str(&mem)
    ;quit;

    proc sql;
       create
         table _vv_odr as
       select
        substr(&var,1,16) as sixtee
       ,&var
       ,length(&var) as len
       ,count(*)  as wgt
       from
        %str(&lib).%str(&mem)(keep=&var)
       group
        by substr(&var,1,16), &var, length(&var)
       order
        by sixtee, &var
    ;quit;

    data _vv_uplo(keep=sixtee &var wgt idx);
      set _vv_odr;
      by sixtee &var;
      if first.sixtee and last.sixtee then output;
      else do;
        idx=int(16*uniform(len))+1;
        slg=substr(sixtee,idx,1);
        if slg=upcase(slg) then substr(sixtee,idx,1)=lowcase(slg);
        else substr(sixtee,idx,1)=upcase(slg);
        output;
      end;
    run;

    proc datasets nolist ; delete _vv_h;run;quit;
    options ls=116;
    ods output hbar=_vv_h;
    ods listing close;
    proc chart data=_vv_uplo;
         label &var="";
         hbar sixtee/type=freq discrete descending freq=wgt;
    run;
    ods output close;
    ods listing;
    options ls=171;

         proc print data=_vv_h width=min label split='#' noobs;
         title1 ' ';title2 ' ';title3 ' ' ;
         title4 "Histogram for character variable &var";
          label batch="#";
          var batch;
         run;

    %end;
    /* Produce the chart  %let var=water; %let libname=work; %let data=tstdat;  */
    %else %do;
      %if %upcase(&typ)=%upcase(num) /* and &skp=1 and &val<3000*/ %then %do;

       %put &=val;

       proc sql noprint;
        select
             min(&var), max(&var)
        into
             :min,   :max
        from
            %str(&lib).%str(&mem)
       ;quit;

       /* do not use datastep so user can turn into macro if he likes */

       %let finmax=;

       data _null_;
         retain range %sysevalf(&max - &min);
         set  _vv_tic end=dne;
         seq=_n_;
         max    = ceil (&max/tic)*tic;
         min    = floor(&min/tic)*tic;
         ceilmax  = max - &max;
         floormin = min - &min;
         *put _all_;
         if (( ceilmax > tic       or  floormin  <  -tic )    or
             ( ceilmax > .1*range  or  floormin  <= -.1*range or tic > .2 *range)) then flg=1;
         else do;
             call symputx('finmax',put(max,best14.));
             call symputx('finmin',put(min,best14.));
             call symputx('finint',put(tic,best14.));
             stop;
         end;
       run;

     %put finmax=&finmax finmin=&finmin finint=&finint;

     %if &finmax ne %then %do;

       proc datasets nolist; delete _vv_h9 nolist;run;quit;

       ods listing close;
       ods output hbar=_vv_h9;
       proc chart data=%str(&lib).%str(&mem);
          %if %upcase(&fmt)=%upcase(date7,) %then %do; %str(format &var date7.;); %end;
          hbar &var/midpoints=(&finmin to &finmax by &finint) type=freq;
       run;
       ods listing;

       proc print data=_vv_h9(where=(not (SCAN(batch,-4) = '0' or substr(batch,40)='')))  noobs label split='#';

        title1 ' ';title2 ' ';title3 ' ';
        title4 "Histogram for numeric variable &var";
        label batch="#";
        var batch;
       run;quit;

     %end;

     %end;
   %end;
%mend _vdo_chartx;

*   *  *****   ***   ****    ***   ****
** **    *    *   *  *   *  *   *  *   *
* * *    *     *     *   *  *   *  *   *
*   *    *      *    ****   *   *  ****
*   *    *       *   *      *   *  *
*   *    *    *   *  *      *   *  *
*   *  *****   ***   *       ***   *;

%macro _vdo_mispop(lib=&libname,mem=&data);

    title1 "Missing vs Populated Frequencies";

    Proc format;
         value msspop
          . = 'Missing'
          0 = 'Zero'
          0<-high = "Positive"
          low-<0 = 'Negative'
          other='Special Missing'
    ;
         value $mscpop
          'Unknown',' ','NAN','UNK','U','NA','UNKNOWN',
          'Miss','Mis'
          'Missing','MISSING','MISS','MIS'
             ='Missing'
          other='Populated'
    ;
    run;

    proc freq
              compress
                data=%str(&lib).%str(&mem)
    ;
    format  _character_ $mscpop.;
      tables _character_ / missing ;
    run;

    proc freq
              compress
                data=%str(&lib).%str(&mem)
    ;
    format _numeric_ msspop. ;
      tables _numeric_ / missing ;
    run;

%mend _vdo_mispop;

*   *  *****  *   *  *   *  *   *   ***
*  *   *      *   *  *   *  **  *  *   *
* *    *       * *   *   *  * * *  *   *
**     ****     *    *   *  *  **  *   *
* *    *        *    *   *  *   *  * * *
*  *   *        *    *   *  *   *  *  **
*   *  *****    *     ***   *   *   ****;

%macro _vdo_keyunq(
       lib=&libname
      ,mem=&data
      ,key=_all_
       );
  /*
   %let lib=work ;
   %let mem=tstdat    ;
   %let key=_all_    ;
  */

  %local obsdup;

  proc sort data=%str(&lib).%str(&mem) out=_vdo_dup nouniquekey;
     by &key;
  run;quit;

  proc sql noprint;select count(*) into :obsdup separated by ' ' from _vdo_dup;quit;

  %If &obsdup ne 0 %Then %do;

    * need a key for transpose;
    data _vdo_addkey;
       set _vdo_dup;
       rec=_n_;
    run;quit;

    Proc Transpose Data=_vdo_addkey Out=_vdo_addkeyxpo;
    Var _all_;
    id rec;
    run;

    Data _vdo_addkeyfix;

      length _character_ $16.;

      Set _vdo_addkeyxpo;

      Array chr[*] _character_;

      Do i=1 to dim(Chr);

        Chr[i]=Left(Chr[i]);

      End;
      drop i;

    Run;

    Proc Print data=_vdo_addkeyfix width=min;
    title1 ' ';title2 ' ';title3 ' ' ;
    title4 "Vertical List of Duplicates (&key -- &obsdup duplicates)";
    run;quit;

    Proc Print data=_vdo_dup width=min;
    title1 ' ';title2 ' ';title3 ' ' ;
    title4 "Horizontal List of Duplicates (&key -- &obsdup duplicates)";
    run;

  %end;
  %else %do;
    data _null_;
     file print;
     put "******************************************************************";
     put "*                                                                *";
     put "* No duplicates in &key in &lib &mem"                              ;
     put "*                                                                *";
     put "******************************************************************";
   run;
 %end;

%mend _vdo_keyunq;

****   *   *  ****    ***    ***   *
 *  *  *   *  *   *  *   *  *   *  *
 *  *  *   *  *   *  *      *   *  *
 *  *  *   *  ****   *      *   *  *
 *  *  *   *  *      *      *   *  *
 *  *  *   *  *      *   *  *   *  *
****    ***   *       ***    ***   *****;

%macro _vdo_dupcol(
       lib=&libname
      ,mem=&data
      ,typ=Char
      );

     /* %let typ=num;  */
      options nonotes;
      data _vvren;
         retain _vvvls;
         length _vvvls $32560;
         set _vvcolumn (where=( upcase(type)=%upcase("&typ") and
           libname=%upcase("&lib") and memname = %upcase("&mem"))) end=dne;
           _vvvls=catx(' ',_vvvls,quote(strip(name)));
         if dne then call symputx('_vvvls',_vvvls);
      run;quit;
      option notes;

      %put &_vvvls;
      %let _vvdim=%sysfunc(countw(&_vvvls));
      %*put &=_vvdim;

      data _null_;;
       length var wth $32560;
       array nam[&_vvdim]  $32 (&_vvvls);
       do i=1 to (dim(nam)-1);
         do j=i+1 to dim(nam);
          var=catx(' ',var,nam[i]);
          wth=catx(' ',wth,nam[j]);
        end;
       end;
       call symputx('_vvtop',var);
       call symputx('_vvbot',wth);
      run;

      %put &_vvtop;
      %put &_vvbot;

      ods listing close;
      ods output comparesummary=_vvcmpsum;
      proc compare data=%str(&lib).%str(&mem) compare=%str(&lib).%str(&mem) listequalvar novalues;
         var &_vvtop;
         with &_vvbot;
      run;quit;
      ods listing;

      data _vveql(keep=batch);
        retain flg 0;
        set _vvcmpsum;
        if index(batch,'Variables with All Equal Values')>0 then flg=1;
        if index(batch,'Variables with Unequal Values'  )>0 then flg=0;
        if flg=1;
      run;quit;

      proc sql noprint;select count(*) into :_vvcntstar from _vveql;quit;
      title;footnote;
      %put &=_vvcntstar;

      %if &_vvcntstar ^= 0 %then %do;
         proc print data=_vveql;
         title1 ' ';title2 ' ';title3 ' ' ;
         title4 "These &typ variables have equal values for all observations";
         run;quit;
      %end;
      %else %do;
         data _null_;
           file print;
           put //;
           put "Comparison of Numeric variables to see if a variable is duplicated exactly";
           put //;
           put "*** NO equal &typ Variables with All Equal Values found ***";
           put //;
         run;
      %end;

%mend _vdo_dupcol;

 ***    ***   ****
*   *  *   *  *   *
*      *   *  *   *
*      *   *  ****
*      *   *  * *
*   *  *   *  *  *
 ***    ***   *   *;

%macro _vdo_cor(
       lib=&libname
      ,mem=&data
      );


    data _vcor0th/view=_vcor0th;
      set %str(&lib).%str(&mem) (keep=_numeric_);
      _rec=_n_;
      if _n_=1 then _rec=.;
    run;

    ods exclude all;
    ods output spearmancorr=_vvcor1st;
    proc corr data=_vcor0th (keep=_numeric_) spearman;
       var _numeric_;
       with _numeric_;
    run;
    ods selecet all;

    proc sql noprint;select count(*) into :_vv_num separated by ' ' from _vvcor1st;quit;

    %put &=_vv_num;

    data _vvcor2nd;
      keep var wth n val;
      set _vvcor1st(drop=label );
      array num[*] _numeric_;
      do _i_=1 to &_vv_num;
        if num[_i_] ne . then do;
           var=variable;
           wth=vname(num[_i_]);
           n=num[_i_+ %eval(2 * &_vv_num)];
           val=abs(num[_i_]);
           if (_i_ < _n_  /*and index(variable,'_CD')=0 and index(wth,'_CD')=0 and n>299*/
          and not (var='_REC' or wth = '_REC')) then output;
        end;
      end;
    run;

    proc sort data=_vvcor2nd out=vv_corsrt;
    by descending val;
    run;

    title "Variable Correlations";
    proc print data=vv_corsrt(obs=50) noobs width=min label split='#';
    label
        var = "Variable"
        wth = "Correlated#With"
        val = "Correlation#Coef"
        n   = "Number of Obs";
    var var wth val n;
    run;
%mend _vdo_cor;

*   *  *   *  *   *  *   *  *   *  *   *
** **  **  *  *   *  ** **  **  *  *   *
* * *  * * *   * *   * * *  * * *   * *
*   *  *  **    *    *   *  *  **    *
*   *  *   *    *    *   *  *   *    *
*   *  *   *    *    *   *  *   *    *
*   *  *   *    *    *   *  *   *    *;

%macro _vdo_mnymny(
       lib=&libname
      ,mem=&data
      ,maxval=31
      ,maxvar=10
      )/des="Many to Many, One to Many, Many to One and Many to Many" ;

    /*
     %let maxval=11;
     %let maxvar=15;
     %let lib=work;
     %let mem=tstdat;
    */


    %macro _vdo_relhow(varlft=,varrgt=);

        /*
          %let varrgt=STATE;
          %let varlft=MONMON;
          %let lib=work;
          %let mem=tot_nrol;
        */

        proc sort data=%str(&lib).%str(&mem)(keep=&varlft &varrgt) out=__varlft nodupkey noequals;
        by  &varlft &varrgt;
        run;quit;

        data __onemny(keep=onemny);
          retain onemny "UNKNOW";
          do until (dne);
              set __varlft end=dne;
              by &varlft;
              if not (first.&varlft  and last.&varlft) then do;
                 onemny="ONEMNY";
                 leave;
              end;
          end;
          output;
          stop;
        run;quit;

        proc sort data=__varlft out=__varrgt nodupkey noequals;
        by  &varrgt &varlft;
        run;quit;

        data __mnyone(keep=mnyone);
          retain mnyone "UNKNOW";
          do until (dne);
              set __varrgt end=dne;
              by &varrgt;
              if not (first.&varrgt  and last.&varrgt) then do;
                 mnyone="MNYONE";
                 leave;
              end;
          end;
          output;
          stop;
        run;quit;

        data __mnymnytwo;
           length out $64;
           merge __onemny __mnyone;
           select;
              when ( mnyone="MNYONE" and onemny="ONEMNY" ) out = "Many to Many    &varlft to &varrgt";
              when ( mnyone="MNYONE" and onemny="UNKNOW" ) out = "Many to One     &varlft to &varrgt";
              when ( mnyone="UNKNOW" and onemny="ONEMNY" ) out = "One to Many     &varlft to &varrgt";
              when ( mnyone="UNKNOW" and onemny="UNKNOW" ) out = "One to One      &varlft to &varrgt";
           end; * leave off otherwise to force error;
           output;
        run;quit;

        proc append data=__mnymnytwo base=__basmnymny;
        run;quit;

     %mend _vdo_relhow;

    data _vvboth;

      set _vvnuma _vvch1;

      if 2 <  values < &maxval;

      keep variable values;

    run;

    proc sql noprint;
       select count(*) into :nobs separated by ' ' from _vvboth;
       select variable into :vars separated by ' ' from _vvboth;
    quit;

    %if &nobs. > &maxvar %then %let nbs=&maxvar;
    %else %let nbs=&nobs.;

    proc datasets nolist;
      delete __basmnymny;
    run;quit;

    %do i=1 %to %eval(&nbs.-1);

      %do j=2 %to %eval(&nbs.);

         %if &i ne &j %then %do;

           Data _null_;
             cmd=cats('%_vdo_relhow(varlft=',"%scan(&vars.,&i),",'varrgt=',"%scan(&vars.,&j));");
             put cmd;
             call execute(cmd);
           run;

         %end;

      %end;

    %end;

    title1 ' ';title2 ' ';title3 ' ' ;
    TITLE4 "Relationship OF VARIABLES WHERE MAX LEVELS IS &MAXVAL AND MAX NUMBER OF VARIABLES IS &MAXVAR";
    title5 "One to One  -- One to many  --  Many to One -- Many to Many ";
    proc print data=__basmnymny;
    var out;
    run;quit;

%mend _vdo_mnymny;


 ***   *   *  *   *
*   *  ** **  *   *
*      * * *  *   *
*      *   *  *****
*      *   *  *   *
*   *  *   *  *   *
 ***   *   *  *   *;

%macro _vdo_cmh(
       lib=&libname
      ,mem=&data
      ,maxval=31
      ,maxvar=10
      )/des="Defaults to all two way cross tabs forupto 10 variables with less than 11 levels 45 cross tabs 10 choose 2" ;


    /*
     %let maxval=11;
     %let maxvar=15;
     %let lib=work;
     %let mem=tstdat;
    */

    data _vvboth;

      set _vvnuma _vvch1;

      if 2 <=  values < &maxval;

      keep variable values;

    run;

    proc sql noprint;
       select count(*) into :nobs separated by ' ' from _vvboth;
       select variable into :vars separated by ' ' from _vvboth where upcase(variable) not in ("LIBREF","COUNT");
    quit;

    %if &nobs. > &maxvar %then %let nbs=&maxvar;
    %else %let nbs=&nobs.;

    %do i=1 %to %eval(&nbs.-1);

      %do j=2 %to %eval(&nbs.);

         %if &i ne &j %then %do;

           ods exclude all;
           ods output cmh=_vvz&i&j;
           proc freq data=%str(&lib).%str(&mem.);
           tables %scan(&vars.,&i) * %scan(&vars.,&j) / cmh missing;
           run;
           ods select all;

           title1 ' ';title2 ' ';title3 ' ' ;
           TITLE4 "Cochran-Mantel-Haenszel Statistics (Based on Table Scores)";
           TITLE5 "ALL PAIRS OF VARIABLES WHERE MAX LEVELS IS &MAXVAL AND MAX NUMBER OF VARIABLES IS &MAXVAR";
           title6 "%scan(&vars.,&i) * %scan(&vars.,&j) ";
           title7 "Cochran-Mantel-Haenszel - interpret with care when crosstab is sparse or large sample size";

           proc print data=_vvz&i&j width=min;
           run;quit;

           proc datasets nolist;
             delete _vvz&i&j;
           run;quit;
         %end;

      %end;

    %end;

%mend _vdo_cmh;

*****    *    ****    ***   *   *  *****
  *     * *    *  *  *   *  **  *  *
  *    *   *   *  *  *   *  * * *  *
  *    *****   ***   *   *  *  **  ****
  *    *   *   *  *  *   *  *   *  *
  *    *   *   *  *  *   *  *   *  *
  *    *   *  ****    ***   *   *  *****;

%macro _vdo_tabone(
       lib=&libname
      ,mem=&data
      ,maxval=31
      ,maxvar=20
      ,top=20
      ,tab=&tabone
      )/des="tab one variable versus all other variables - tab variable must have fewer than maxval levels " ;


    /*
     %let maxval=11;
     %let lib=work;
     %let mem=tstdat;
    */

    data _vvboth;

      set _vvnuma _vvch1(obs=&maxvar where=(1 <  values < &maxval));

      keep variable values;

    run;

    proc sql noprint;
       select count(*) into :nbs separated by ' ' from _vvboth;
       select variable into :vars separated by ' ' from _vvboth where upcase(variable) not in ("LIBREF","COUNT");;
    quit;

    %put &=vars;

    %do j=1 %to %eval(&nbs.);

         proc freq data=%str(&lib).%str(&mem.) noprint order=freq;
            title1 ' ';title2 ' ';title3 ' ' ;
            TITLE4 "TOP &TOP FOR &TAB WITH ALL OTHER VARIABLES WHERE MAX LEVELS IS &MAXVAL AND MAX NUMBER OF VARIABLES IS &MAXVAR";
            title5 " &tab with %scan(&vars.,&j) other variables ";
            tables %str(&tab) * %scan(&vars.,&j) / list nocol norow nopercent missing out=_vvx&j;
         run;

         proc sort data=_vvx&j out=_vvz&j noequals;
         by descending count;
         run;

         proc print data=_vvz&j(obs=&top) width=min;
         run;quit;

         proc datasets nolist;
           delete _vvx&j _vvz&j;
         run;quit;

    %end;

%mend _vdo_tabone;

*****    *    ****     *    *      *
  *     * *    *  *   * *   *      *
  *    *   *   *  *  *   *  *      *
  *    *****   ***   *****  *      *
  *    *   *   *  *  *   *  *      *
  *    *   *   *  *  *   *  *      *
  *    *   *  ****   *   *  *****  *****;

%macro _vdo_taball(
       lib=&libname
      ,mem=&data
      ,maxval=31
      ,maxvar=10
      ,top=20
      )/des="Defaults to all two way cross tabs forupto 10 variables with less than 11 levels 45 cross tabs 10 choose 2" ;


    /*
     %let maxval=11;
     %let maxvar=15;
     %let lib=work;
     %let mem=tstdat;
    */

    data _vvboth;

      set _vvnuma _vvch1;

      if 2 <  values < &maxval;

      keep variable values;

    run;

    proc sql noprint;
       select count(*) into :nobs separated by ' ' from _vvboth;
       select variable into :vars separated by ' ' from _vvboth where upcase(variable) not in ("LIBREF","COUNT");
    quit;

    %if &nobs. > &maxvar %then %let nbs=&maxvar;
    %else %let nbs=&nobs.;

    %do i=1 %to %eval(&nbs.-1);

      %do j=2 %to %eval(&nbs.);

         %if &i ne &j %then %do;

           proc freq data=%str(&lib).%str(&mem.) noprint order=freq;
              title1 ' ';title2 ' ';title3 ' ' ;
              TITLE4 "TOP &TOP ALL PAIRS OF VARIABLES WHERE MAX LEVELS IS &MAXVAL AND MAX NUMBER OF VARIABLES IS &MAXVAR";
              title5 " %scan(&vars.,&i) * %scan(&vars.,&j) top &top frequent ";
              tables %scan(&vars.,&i) * %scan(&vars.,&j) / list nocol norow nopercent missing out=_vvx&i&j;
           run;

           proc sort data=_vvx&i&j out=_vvz&i&j noequals;
           by descending count;
           run;

           proc print data=_vvz&i&j(obs=&top) width=min;
           run;quit;

           proc datasets nolist;
             delete _vvx&i&j _vvz&i&j;
           run;quit;

         %end;

      %end;

    %end;

%mend _vdo_taball;

*****  *   *  ****
*      **  *   *  *
*      * * *   *  *
****   *  **   *  *
*      *   *   *  *
*      *   *   *  *
*****  *   *  ****;

proc datasets kill nolist ;
run;quit;


/*

options fullstimer;run;
data tstdat (compress=binary);
  retain mis ' ' one '1' two '1' mismix ' ' onemix . misa 'A' misnum .;
  format date1-date10 date9.;
  array date[10] date1-date10;
  array bil[10] grocery electric water carpayment mortagepayment gas lunch dinner maint daycare;
  array codes{10]   $5 drg1-drg10;
  array decodes[3]  $5 drg1_cd drg2_cd drg3_cd;
  array age[10]  age1-age10;
  alpha='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    do rec=1 to 3000;
      if mod(rec,1000)=0 then do; mismix='A';onemix=32;end;
      else                    do; mismix=' ';onemix=. ;end;
      lvl10=mod(rec,10);
      lvl9 =mod(rec,9);
      do i=1 to 10;
         age[i]    =  mod(int(200*uniform(-1)),100);
         date[i]   =  mod(int(1000000*uniform(-1)),100000) - mod(int(1000000*uniform(-1)),100000);
         bil[i]    =  round(10000*uniform(-1),1);
         codes[i]  =  substr(alpha,int(20*uniform(-1))+1,2);
         if i<= 3 then decodes[i]=cats(codes[i],'-',codes[9]);
      end;
      drop alpha;
      recdup=rec;
      output;
    end;
run;

proc freq data=tstdat;
tables drg1_cd*drg1/ all missing;
run;quit;



*Here is what the Validation and Verification Tool can do(see below for
samples)

data best12;
 *infile "csv.txt";
 input num ;
 put num best.;
cards4;
300000000000
3000000000000
;;;;
run;quit;



1.   Dataset level summary -- ie number of obs, variable types, static data
2.   Cardinality page  (primary keys, codes/decodes  number of unique
     values for every variable - EG fails here)
3.   Complete frequency for all variables numeric and character with less
     than 200 levels
4.   For variables with over 200 levels top 100 most frequent and bottom
     100 least frequent
     Least frequent are the more interesting cases.
5.   Proc means on all numeric variables
6.   Proc univariate on all numeric variables
7.   Special datetime  analysis
9.   Histograms on all variables with less than 200 levels
10.  Proc contents
11.  Frequency of all numeric variables Missing, negative, zero and positive
12.  Duplicates on single or compound key. Output printed vertically for
     easy comparison
13.  Cross tabs of every variable with every other variable top 16 levels
     (if selecetd)
14.  You can also selecet one variable to cross tab with all other variables
     max top 16 levels
16.  Maximum and minimum lengths to hold all numeric and character variables
     exactly (optimize)
17.  Correlation of all pairs of numeric variables sorted by largest
    correlation to lowest.
18.  Nice display of max and mins for numeric and character in one table
19.  List of identical columns ie date and date1 have equal values on all
     observations
19   One to Many, Many to One, One to Many and Many to Many
20   Cochran-Mantel-Haenszel Statistics
20   Printout of first 20, middle 20 and last 20 observations.
*/

%macro utl_getstm(pth);
   %local revstr cutstr gotstm;
   %if %qupcase(&pth) = OUTPUT %then %do;%let gotstm=1;%end;
   %else %do;
      /* extract the path without the file name */
      %let revstr=%qleft(%qsysfunc(reverse(&pth)));
      %let cutstr=%qsubstr(&revstr,%qsysfunc(indexc(&revstr,%str(/\))));
      %let gotstm=%qleft(%qsysfunc(reverse(&cutstr)));
      %if &gotstm= %then %let gotstm=0;
   %end;
   %str(&gotstm)
%mend utl_getstm;

%macro DirExist(dir) ;
  /* directory exist */
  %LOCAL rc fileref return;
  %if &dir=1 or &dir=0 %then %let return=&dir;
  %else %do;
     %let rc = %sysfunc(filename(fileref,&dir)) ;
     %if %sysfunc(fexist(&fileref))  %then %let return=1;
     %else %let return=0;
  %end;
  &return
%mend DirExist;

%macro utlvdoc
    (
    libname        = work          /* libname of input dataset */

    ,data          = tstdat        /* name of input dataset */

    ,key           = rec           /* list of keys or empty for no key */

    ,ExtrmVal      = 10            /* number of high and low values to print for high cardinality variables */

    ,UniPlot       = true          /* 'true' enables ('false' disables) plot option on univariate output */

    ,ValCtOff      = 100           /* Levesl for switch to top extrmval and botton extrmval */

    ,chart         = true          /* proc chart for all variables with 100 or fewer levels */

    ,taball        = true          /* all pairwise crosstabs for up to 10 variables with less than 11 levels - can change */

    ,tabone        = fyl           /* blank if no tabulation variable */

    ,oneone        = true          /* fa;se if no tabulation variable */

    ,cmh           = true           /* fa;se if no tabulation variable */

    ,codedecode    = false         /* are the codes and decodes one to one */

    ,printto       = output        /* file or output if output window */

    ,Cleanup       = true          /* true= enable deletion of temporary working datasets */

    ) / minoperator  des = "Validate and verify your data";

    * Data step to generate SQL statements;
    * ..."vv" stands for "verify + validate";

    *--------------------

    proc optsave out=sasuser.optsave;
    run;quit;

    %local
        nobs
        nvar

        exit

        pagesize
        linesize


        MaxFreq

        doOnes    /* Boolean, enables 'Ones' variable processing if necessary */

        MaxLen
        Width
    ;


   %* Initialize internal macrovariables;

   %let title=&data;
   %*let ExtrmVal = 10;     * Number of high/low frequency values to show;
   %let MaxFreq  = 999999; * SAS system maximum number of freq levels in an dataset;
   %let PageSize = 56;     * Optimal pagesize setting (may parameterize later);
   %let LineSize = 183;    * Optimal linesize setting (may parameterize later);
   %let exit     = 0;      * Exit flag value;
   %let FreqOrdr = freq;   * display order of frequency output - see PROC FREQ for details ;

   %let outchk= %eval(%direxist(%utl_getstm(&printto.))=0) ; /* 0 if output or dir exists*/

   %put &=outchk;

    * Chang Chung;
   %put %sysfunc ( ifc ( %sysevalf ( %superq ( libname ) =,boolean )                  ,ERROR: Provide libname an Input Library Reference,                       ) );
   %put %sysfunc ( ifc ( %sysevalf ( %superq ( data    ) =,boolean )                  ,ERROR: Provide data    an Input dataset          ,                       ) );
   %put %sysfunc ( ifc ( %sysevalf ( %superq ( printto ) =,boolean )                  ,ERROR: Provide printto a file for printed output ,                       ) );
   %put %sysfunc ( ifc ( %eval ( %superq ( codedecode  ) in TRUE FALSE true false ) =0,ERROR: Provide codedecode true or false for code/decode crosstabs,       ) );
   %put %sysfunc ( ifc ( %eval ( %superq ( cleanup     ) in TRUE FALSE true false ) =0,ERROR: Provide cleanup    true or false cleanup of work library,         ) );
   %put %sysfunc ( ifc ( %eval ( %superq ( uniplot     ) in TRUE FALSE true false ) =0,ERROR: Provide uniplot    true or false plot option,                     ) );
   %put %sysfunc ( ifc ( %eval ( %superq ( chart       ) in TRUE FALSE true false ) =0,ERROR: Provide chart      true or false histogram options,               ) );
   %put %sysfunc ( ifc ( %eval ( %superq ( taball      ) in TRUE FALSE true false ) =0,ERROR: Provide taball     true or false upper limit for number of levels,) );
   %put %sysfunc ( ifc ( %eval ( %superq ( cmh         ) in TRUE FALSE true false ) =0,ERROR: Provide oneone     true or false text file for printed output,    ) );
   %put %sysfunc ( ifc ( %eval ( %superq ( oneone      ) in TRUE FALSE true false ) =0,ERROR: Provide oneone     true or false text file for printed output,    ) );
   %put %sysfunc ( ifc ( %eval ( %superq ( valctoff    )  < 2                     )   ,ERROR: Provide valctoff   max levels deault 120000,                      ) );
   %put %sysfunc ( ifc ( &outchk                          = 1                         ,ERROR: Printto directory does not exist,                                 ) );
   %if  %sysfunc (exist(&libname..&data))=0 %then %put ERROR: &libname..&data does not exist;


   %let res= %eval
    (
        %sysfunc ( ifc ( %sysevalf ( %superq ( libname ) =,boolean )                   ,1 ,0 ) )
      + %sysfunc (exist(&libname..&data)) = 0
      + %sysfunc ( ifc ( %sysevalf ( %superq ( printto ) =,boolean )                   ,1 ,0 ) )
      + %sysfunc ( ifc ( %sysevalf ( %superq ( data    ) =,boolean )                   ,1 ,0 ) )
      + %sysfunc ( ifc ( %eval ( %superq ( codedecode  ) in TRUE FALSE true false ) =0 ,1 ,0 ) )
      + %sysfunc ( ifc ( %eval ( %superq ( cleanup     ) in TRUE FALSE true false ) =0 ,1 ,0 ) )
      + %sysfunc ( ifc ( %eval ( %superq ( uniplot     ) in TRUE FALSE true false ) =0 ,1 ,0 ) )
      + %sysfunc ( ifc ( %eval ( %superq ( chart       ) in TRUE FALSE true false ) =0 ,1 ,0 ) )
      + %sysfunc ( ifc ( %eval ( %superq ( taball      ) in TRUE FALSE true false ) =0 ,1 ,0 ) )
      + %sysfunc ( ifc ( %eval ( %superq ( oneone      ) in TRUE FALSE true false ) =0 ,1 ,0 ) )
      + %sysfunc ( ifc ( %eval ( %superq ( cmh         ) in TRUE FALSE true false ) =0 ,1 ,0 ) )
      + %sysfunc ( ifc ( %eval ( %superq ( valctoff    )  < 2                     )    ,1 ,0 ) )
      + &outchk
    );

    %put &=res;

    /*
    %let libname  = work     ;
    %let data     = tstdatchr;
    */

    %if &res = 0 %then %do; * passed;

           proc sql;
              create
                view _vvtable as
              select
                *
              from
                sashelp.vtable
              where
                    libname= %upcase( "&libname" )
                and memname eq %upcase ( "&data" )
           ;quit;

           proc sql;
              create
                view _vvcolumn as
              select
                *
              from
                sashelp.vcolumn
              where
                    libname= %upcase( "&libname" )
                and memname eq %upcase ( "&data" )
           ;quit;


           %nvar(libname=&libname,data=&data);

           data _null_;
             set _vvnumchr;
             * need at least one numeric and one char;
             prb=min(num_numeric,num_character) = 0;
             call symputx( 'no_numchr', putn( prb, format, width ));
           run;quit;

           %if &no_numchr %then
               %do;
               %put ERROR{}  Not at least one character or numeric variable;
               %put ERROR{}  Not at least one character or numeric variable;
               %put ERROR{}  Not at least one character or numeric variable;
               %goto finish;
               %end;

           * because it taks so long to query the SAS dictionaries using a datastep
             lets use a view to get the data;

           * if output is a file then direct output to file;
           %if %qupcase(&printto) ne OUTPUT %then %do;
              proc printto print="&printto" new;
              run;quit;
           %end;

           %_vdo_basic;      /* Orginal program cardinality and frequencies */


           %If %Upcase(&codedecode) eq TRUE  %Then %Do;
              %_vdo_cdedec;     /* checks code/decode mappings but variables pairs have to have names like VAR and VRA_CD */
           %end;

           %_vdo_getmaxmin;  /* max and min listing */
           %_vdo_optlen;     /* optimum lengths */

           %If %Upcase(&Key) ne  %Then %Do;
               %_vdo_keyunq(key=&key);  /* is the key unique - print dups */
           %end;

           %if %upcase(&chart) = TRUE %then %do; /* proc chart variables */

               %let xeqcnt=0;

               %utlfkil(&pth/cmd.sas);
               %let pth=%sysfunc(pathname(work));
               %put &pth;

               options ls=171;
               ods listing;
               data _null_;
                file "&pth/cmd.sas";
                set _vv1m(where=(values>0));
                if substr(left(reverse(variable)),1,1) not in ("2","3","4","5","6","7","8","9")  then do;
                  lbl=cats("'",label,"'");
                  cmd=catx(',',cats('%_vdo_chartx(',variable),type,put(values,best.),lbl,cats(format,');'));
                  put cmd;
                  putlog cmd;
                end;
               run;

               %include "&pth/cmd.sas";

           %end;

           %_vdo_mispop ;run;         /* missing and populated */

           %_vdo_dupcol(typ=char);    /* duplicate character columns */
           %_vdo_dupcol(typ=num);     /* duplicate numeric columns */

           %_vdo_cor;


           %if %upcase(&oneone) eq TRUE %then %do; /* one to one -- many to one -- many to many */
              %_vdo_mnymny(
                 maxval=400
                ,maxvar=10
               );
           %end;


           %if %upcase(&tabone) eq TRUE %then %do;  /* one variable crossed with all others */
              %_vdo_tabone(
                  maxval=30
                 ,maxvar=10
                 ,top=10
                 );
           %end;

           %if %upcase(&cmh) eq TRUE %then %do;  /* one variable crossed with all others */
              %_vdo_cmh(
                  maxval=60
                 ,maxvar=5
                 );
           %end;

           %if %upcase(&taball) eq TRUE %then %do;   /* all pairwise cross tables with limits */
              %_vdo_taball(
                    maxval=60 /* max number of levels */
                   ,maxvar=5  /* max number of variables 10 10!/(8! * 2!)=4545 */
                   ,top=10  /* number of most frequent to print */
                  );
           %end;

           %_vdo_begmidend;  /* first 20 obs - middle 20 obs and last 20 obs */
           %_vdo_clean;      /* cleanup the work directory */

           * direct output back to the output window;
           %if %qupcase(&printto) ne OUTPUT %then %do;
              proc printto;
              run;quit;
           %end;

    %end; /* end verification and validation */

    proc optload data=sasuser.optsave;
    run;quit;

%finish:

%mend utlvdoc;

%macro delvars;
  data vars;
    set sashelp.vmacro;
  run;

  data _null_;
    set vars;
    temp=lag(name);
    if scope='GLOBAL' and substr(name,1,3) ne 'SYS' and temp ne name and upcase(name) not in
    ('FYL' '_Q', 'PGM', 'INPUT_FMT', 'INPUT_iafSD1' 'INPUT_iafFM1' '_R'
     'SD1', 'FM1','FMT') then
      call execute('%symdel '||trim(left(name))||';');
  run;

%mend;

%*delvars;

proc datasets nolist;
 delete _v:;
run;quit;

* testcases;
options fullstimer;run;
data tstdatx;
  array date[10] date1-date10;
  array bil[10] grocery electric water carpayment mortagepayment gas lunch dinner maint daycare;
  array codes{10] $5 drg1-drg10;
  array age[10]  age1-age10;
  alpha='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    do rec=1 to 30000;
      do i=1 to 10;
         age[i]    =  mod(int(200*uniform(-1)),100);
         date[i]   =  mod(int(1000000*uniform(-1)),100000) - mod(int(1000000*uniform(-1)),100000);
         bil[i]    =  round(100*round(10000*uniform(-1),.01),1);
         codes[i]  =  substr(alpha,int(20*uniform(-1))+1,5);
      end;
      drop alpha;
      output;
    end;
run;

* testcase no character;
data tstdatnum;
  set tstdatx(drop=_character_);
run;quit;

* testcase no numeric;
data tstdatchr;
  set tstdatx(drop=_numeric_);
run;quit;

proc sort data=sashelp.zipcode out=chrrelsrt noequals;
by statecode;
run;quit;

data chrrelfin;
  retain cnt 0 statecode rand_a rand_b;
  set chrrelsrt;
  rand_a=int(6*uniform(-1));
  rand_b=int(6*uniform(-1));
  by statecode;
  if first.statecode then do;
     cnt=_n_;
  end;
  if last.statecode then do;
     cnt=cnt+1;
  end;
  ziptwo=substr(put(zip,z5.),1,2);
run;quit;

%utlnopts;
%symdel libname;
%symdel data;
%utlvdoc
    (
    libname        = work                /* libname of input dataset */

    ,data          = chrrelfin                 /* name of input dataset */

    ,key           =    /* list of keys or empty for no key */

    ,ExtrmVal      = 10            /* number of high and low values to print for high cardinality variables */

    ,UniPlot       = true          /* 'true' enables ('false' disables) plot option on univariate output */

    ,ValCtOff      = 101           /* Levesl for switch to top extrmval and botton extrmval */

    ,chart         = true           /* proc chart for all variables with 100 or fewer levels */

    ,taball        = true          /* all pairwise crosstabs for up to 10 variables with less than 11 levels - can change */

    ,tabone        =               /* blank if no tabulation variable */

    ,oneone        = true        /* blank if not wanted */

    ,codedecode    = false         /* are the codes and decodes one to one */

    ,printto       = c:\fix\vdo\&data..txt

    ,Cleanup       = false         /* true= enable deletion of temporary working datasets */

    );


