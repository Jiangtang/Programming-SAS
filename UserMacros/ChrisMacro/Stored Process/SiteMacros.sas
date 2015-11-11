%macro SiteMacros(macro,source,type=INCLUDE,lib=) / des="Include macros from Chris's website";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       SiteMacros
        Author:     Chris Swenson
        Created:    2011-02-03

        Purpose:    Include macros from Chris's website

        Arguments:  macro  - Optional argument to include only one or more macros.
                             If blank, all macros will be included.
                    source - Optional argument to force the source of the macros to
                             be printed. Note that this may slow processing. If
                             blank, the source will only be displayed when including
                             one macro.
                    type=  - Either INCLUDE, SAVE, or STORE. This specifies whether
                             to compile the macro just for your session (INCLUDE), to
                             copy the source to an autocall library (SAVE), or to
                             compile the macro in a catalog (STORE). The last option
                             requires that the MSTORED and SASMSTORE macro options
                             are set.
                    lib=   - The library to save the autocall macros or store the
                             compiled macros. Used when TYPE= is set to SAVE or STORE.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2011-02-04  CAS     Removed circular reference to SiteMacros macro. Modified
                            how the macro filter is applied. Added a final message to
                            note that the macro is complete.
        2011-06-06  CAS     Added additional filters to avoid other links, including
                            only keeping those with "DOWNLOAD" as the hypertext link,
                            only keeping those with the "TD-FILE" class in the table
                            cell, and removing those that start with "HTTP://", since
                            those links with the parent link in place.
        2011-06-07  CAS     Updated the macro to not only include but save or store
                            the macros to an autocall or compiled macro library.
        2011-08-08  CAS     Added code to identify the operating system directory
                            delimiter. Modified processing in UNIX, since autocall
                            macro names and file names should be all lower case.

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/


    /********************************************************************************
       Settings
     ********************************************************************************/

    /* Check for blank arguments */
    %if %superq(TYPE)=%str() %then %do;
        %put %str(E)RROR: No argument specified for TYPE.;
        %return;
    %end;

    /* Set to upper case */
    %let macro=%upcase(&MACRO);
    %let type=%substr(%upcase(&TYPE), 1, 3);

    /* Check for argument values in (INC, SAV, STO) */
    %if %index(*INC*SAV*STO*,*&TYPE*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid argument specified for TYPE.;
        %put %str(E)RROR- Please use one of the following: INC (INCLUDE), SAV (SAVE), or STO (STORE).;
        %return;
    %end;

    /* Set additional macro variables as local */
    %local argcnt codecnt i m msg nosource user_mprint;

    /* Count number of macros specified */
    %let argcnt=%sysfunc(countw(&MACRO, %str( )));

    /* Default for count of code */
    %let codecnt=0;

    /* Determine whether to output source or not */
    %if &ARGCNT=0 or &ARGCNT>1 %then %let nosource=/ nosource2;
    %if %upcase(&SOURCE)=SOURCE %then %let nosource=;

    /* Determine the directory delimiter */
    /* REVISION 2011-08-08 CAS: Added this section */
    %local dirdlm;
    /* Windows */
    %if %upcase("&SYSSCP")="WIN" %then %let dirdlm=\;
    /* z/OS and OpenVMS */
    %else %if %upcase("&SYSSCP")="OS" or %upcase("&SYSSCPL")="OPENVMS" %then %let dirdlm=.;
    /* Unix */
    %else %if %index(*AIX*HP-UX*LINUX*OSF1*SUNOS*,%upcase(*&SYSSCPL*))>0
    %then %let dirdlm=/;
    /* Unknown */
    %else %do;
        %let msg=Unable to determine the operating system. Please update the macro for your environment.;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;
    %end;


    /********************************************************************************
       Import Webpage
     ********************************************************************************/

    /* Associate with URL */
    filename site url "http://sas.cswenson.com/macros/";

    /* Import URL, keeping only SAS code files */
    /* Output a code variable with filename */
    /* REVISION 2011-06-06 CAS: Added additional filters to avoid other links, */
    /* including DOWN, TDFILE, and HTTP. */
    data code;
        format TEXT $1500. HREF DOWN SAS TDFILE HTTP 8.;
        infile site length=length lrecl=2500 truncover;
        input text $varying2500. length;

        href=find(upcase(text), upcase('A HREF="'));
        down=find(upcase(text), upcase('>DOWNLOAD</A>'));
        tdfile=find(upcase(text), upcase('<TD CLASS="TD-FILE">'));
        sas=find(upcase(text), upcase('.SAS'), href);
        http=find(upcase(text), upcase('HTTP://'));

        /* Filters */
        /* Keep */
        if href>0 and down>0 and tdfile>0 and sas>0
        /* Delete */
        and http=0;

        code=substr(text, href+8, sas-href-4);
    run;

    /* Set code to macro variables, along with a count */
    /* REVISION 2011-02-04 CAS: Added filter for SiteMacros macro, as including it
       would cause a circular reference. Modified how the other filters are added. */
    data _null_;
        set code end=end;
        where scan(upcase(code), -1, '/') not in ("SITEMACROS.SAS")
    %if %superq(MACRO) ne %str() %then %do;
          and scan(upcase(code), -1, '/') in (
        %do m=1 %to &ARGCNT;
              "%scan(&MACRO, &M, %str( )).SAS"
            %if &M ne &ARGCNT %then %str( );
        %end;
          )
    %end;
        ;

        code=compress("http://sas.cswenson.com" || code);

        call symputx(compress('code' || put(_n_, 8.)), code, 'L');
        if end then call symputx('codecnt', put(_n_, 8.));
    run;

    /* End macro if no code is found */
    %if &CODECNT=0 %then %do;
        %put %str(W)ARNING: No macro(s) found.;
        %return;
    %end;
    %else %if &ARGCNT ne 0 %then %do;
        %if &CODECNT ne &ARGCNT
        %then %let msg=%str(W)ARNING: Not all specified macros were found.;
    %end;


    /********************************************************************************
       Include Macros
     ********************************************************************************/

    %if &TYPE=INC %then %do;

        /* Loop through each macro and include */
        %let i=0;
        %do i=1 %to &CODECNT;

            filename code url "&&CODE&I";

            %include code &NOSOURCE;

            %put NOTE: The following macro was included:;
            %put NOTE- &&CODE&I;
            %put ;

        %end;

    %end;


    /********************************************************************************
       Save Macros
     ********************************************************************************/

    %if &TYPE=SAV %then %do;

        %if "&LIB"="" %then %do;
            %put %str(E)RROR: No library (LIB=) specified.;
            %return;
        %end;
        %if %sysfunc(libref(&LIB)) ne 0 %then %do;
            %put %str(E)RROR: Speicified library &LIB does not exist.;
            %return;
        %end;

        /* Loop through each macro and include */
        %let i=0;
        %do i=1 %to &CODECNT;

            %let cur=&&CODE&I;
            %let out=%scan(&CUR, -1, %str(/));

            /* Modify OUT for UNIX */
            /* REVISION 2011-08-08 CAS: Added UNIX change */
            %if %index(*AIX*HP-UX*LINUX*OSF1*SUNOS*,%upcase(*&SYSSCPL*))>0
            %then %let out=%lowcase(&OUT);

            filename code url "&CUR";

            data Code;
                infile code length=length;
                input @01 Code $varying1000. length;
            run;

            /* Modify macro name for UNIX */
            /* REVISION 2011-08-08 CAS: Added UNIX change */
          %if %index(*AIX*HP-UX*LINUX*OSF1*SUNOS*,%upcase(*&SYSSCPL*))>0
          %then %do;

            data code;
                set code;
                if _n_=1 then do;
                    substr(code, 7, length(scan(code, 2)))
                    =lowcase(substr(code, 7, length(scan(code, 2))));
                end;
            run;

          %end;

          %if "&NOSOURCE"="" %then %do;
            data _null_;
                set code;
                put "MACRO: " code;
            run;
          %end;

            /* REVISION 2011-08-08 CAS: Updated to OS directory delimiter */
            filename codeout "%sysfunc(pathname(&LIB))%superq(DIRDLM)&OUT";

            data _null_;
                file codeout;
                set code;
                format point 8.;
                point=length(code)-length(left(code));
                put +point code;
            run;

            /* Verify file */
            %if %sysfunc(fileref(codeout)) ne 0 %then %do;
                %put %str(W)ARNING: The following macro was not saved:;
                %put %str(W)ARNING- &&CODE&I;
            %end;
            %else %do;
                %put NOTE: The following macro was saved in %sysfunc(pathname(&LIB)):;
                %put NOTE- &&CODE&I;
            %end;
            %put ;

            filename codeout clear;

        %end;

    %end;


    /********************************************************************************
       Store Macros
     ********************************************************************************/

    %if &TYPE=STO %then %do;

        %if %superq(LIB) ne %str() %then %do;
            options mstored sasmstore=&LIB;
        %end; 

        /* Check for correct options */
        %if %sysfunc(getoption(mstored)) ne MSTORED
         and %sysfunc(getoption(SASMSTORE))=%str()
        %then %do;
            %put %str(E)RROR: The MSTORED and SASMSTORE options are not set.;
            %goto exit;
        %end;

        /* Loop through each macro and include */
        %let i=0;
        %do i=1 %to &CODECNT;

            %let cur=&&CODE&I;
            %let out=%scan(&CUR, -1, %str(/));

            /* Modify OUT for UNIX */
            /* REVISION 2011-08-08 CAS: Added UNIX change */
            %if %index(*AIX*HP-UX*LINUX*OSF1*SUNOS*,%upcase(*&SYSSCPL*))>0
            %then %let out=%lowcase(&OUT);

            filename code url "&CUR";

            /* Import code */
            data Code;
                infile code length=length;
                input @01 Code $varying1000. length;
            run;

            /* Search for slash, except for comments */
            data code;
                set code;
                format slash 8.;
                if prxmatch('/[^\*]\/[^\*]/', code) then slash=1;
                else slash=0;
            run;

            /* Replace FIRST slash with slash followed by STORE */
            data code;
                set code;
                format found 8.;
                retain found 0;
                if slash=1 and found=0 then do;
                    code=prxchange('s/[^\*](\/)[^\*]/ \/ STORE /', 1, code);
                    found=1;
                end;
            run;

            /* REVISION 2011-08-08 CAS: Updated to OS directory delimiter */
            filename codeout "%sysfunc(pathname(WORK))%superq(DIRDLM)&OUT";

            data _null_;
                file codeout;
                set code;
                format point 8.;
                point=length(code)-length(left(code));
                put +point code;
            run;

            /* Verify file */
            %if %sysfunc(fileref(codeout)) ne 0 %then %do;
                %put %str(W)ARNING: The following macro was not saved:;
                %put %str(W)ARNING- &&CODE&I;
            %end;
            %else %do;
                %put NOTE: The following macro was saved:;
                %put NOTE- &&CODE&I;
            %end;
            %put ;

            %include codeout &NOSOURCE;

            /* Verify that the macro compiled */
            %local check;
            %let check=0;
            proc sql noprint;
                select 1
                into :check
                from sashelp.vcatalg
                where libname=upcase("%sysfunc(getoption(SASMSTORE))")
                  and objtype='MACRO'
                  and objname=upcase("%scan(&OUT, 1, %str(.))")
                ;
            quit;

            %if &CHECK=0 %then %do;
                %put %str(W)ARNING: The following macro was not stored:;
                %put %str(W)ARNING- &&CODE&I;
            %end;
            %else %do;
                %put NOTE: The following macro was stored in %sysfunc(getoption(SASMSTORE)):;
                %put NOTE- &&CODE&I;
            %end;
            %put ;

            filename codeout clear;

        %end;

    %end;


    /********************************************************************************
       Cleanup
     ********************************************************************************/

    %exit:

    /* Temporarily turn off NOTES */
    %let user_notes=%sysfunc(getoption(notes));
    option nonotes;

    /* Drop temporary table */
    proc sql;
        drop table code;
    quit;

    /* Clear associations */
    filename code clear;
    filename site clear;

    /* Restore options */
    option &USER_NOTES;

    %if "&MSG" ne "" %then %put &MSG;
    %put NOTE: Inclusion of site macros complete.;

%mend SiteMacros;
