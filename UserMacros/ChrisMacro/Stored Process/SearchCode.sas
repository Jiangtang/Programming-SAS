%macro SearchCode(code,term,out=Code_results,subdir=N,subex=,pm=Y) / des='Search code for term';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       SearchCode
        Author:     Christopher A. Swenson
        Created:    2009-10-05
        Version:    2010-08-12

        Purpose:    Search SAS code or directory of code for specified term

        Arguments:  code    - specific code or directory of code to search
                    term    - term to search for within code
                    out=    - name of output data set
                    subdir= - Y/N whether to search subdirectories
                    subex=  - subdirectories to exclude
                    pm=     - Y = Yes, display the pop-up message
                              N = No, do not display the pop-up message
                              R = Display the pop-up message only with results

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2010-05-03  CAS     Updated to match changes to CheckLog macro
        2010-12-08  CAS     Added out= option to rename final output
        2011-01-27  CAS     Modified behavior when searching multiple code to add
                            the code name to the OUT_all data set.
        2011-06-15  CAS     Fixed a quoting problem.
        2011-07-13  CAS     Added check for OUT table.

        YYYY-MM-DD  III     Please use this format and insert new entries above.

     *********************************************************************************
      END MACRO HEADER
     *********************************************************************************/


    /********************************************************************************
       Settings
     ********************************************************************************/

    /* The following line tricks the editor into thinking the macro has ended,
       allowing readers to see the rest of the code in the usual SAS colors. */
    %macro dummy; %mend dummy;

    /* Manage macro variable scope */
    %global results;    /* Code results message */
    %local
        _EFIERR_        /* (E)RROR detection macro (indirect reference) */
        ervar           /* (E)RROR variable for import (indirect reference) */
        code_init       /* Initial code argument */
        codecount       /* Count of code to check*/
        codenumber      /* Code check variables */
        multi           /* Multiple-code flag */
        outobs          /* Record count of output */
        prxflag         /* Flag to identify regular expression search */
        prxterm         /* Term for regular expression search */
    ;

    /* Modify arguments */
    /* Note: These are modified to avoid using upcase and lowcase repeatedly */
    %let pm=%upcase(&pm);

    %if %superq(term)=%str() %then %do;
        %put %str(E)RROR: No term specified.;
        %return;
    %end;

    /* Set default */
    /* Note: These variables are modified when a directory is submitted */
    %let multi=0;
    %let codecount=1;
    %let prxflag=0;

    /* Check if the term is a regular expression and set flag */
    %if "%substr(%superq(TERM), 1, 1)"="/" %then %do;
        %let prxflag=1;
        %let prxterm=%unquote(%superq(TERM));
        %let term=%unquote(%sysfunc(compress(%superq(TERM), %str(%'))));
    %end;


    /********************************************************************************
       Determine Code to Check
     ********************************************************************************/

    %let code_init=&code;

    /* Check that the argument is populated */
    %if "&code"="" %then %do;

        %put %str(E)RROR: No code or directory specified.;
        %return;

    %end;

    /* Single code */
    /* Check that the code location and file exist */
    %else %if %index(&code,%str(.)) ge 1 %then %do;

        /* Check that the directory exists */
        /* Note: The following functions remove the file from the directory to
           check if the directory exists. */
        %if %sysfunc(fileexist( %substr(&code, 1, %eval( %length(&code) - %length( %scan(&code, -1, %str(\)) ) )) ))
            %then %put NOTE: The specified directory exists.;
        %else %do;

            %put %str(E)RROR: The specified directory does not exist.;
            %return;

        %end;

        /* Check that the code exists */
        %if %sysfunc(fileexist(&code)) %then %put NOTE: The specified code exists.;
        %else %do;

            %put %str(E)RROR: The specified code does not exist.;
            %return;

        %end;

    %end;

    /* Multiple code */
    /* Check that the directory exists */
    %else %if %sysfunc(fileexist(&code))=1 %then %do;

        /* Add extra slash if necessary */
        %if %substr(&code, %length(&code), 1) ne \ %then %do;
            %let code=&code.\;
        %end;

        %dirlist(&code, subdir=&subdir, subex=&subex, report=N, minsize=1);

        /* Modify the directory listing output */
        data DirList;
            set dirlist;
            format code $1000. out $30.;
            retain repeat 0 code;

            /* Keep only code */
            if scan(upcase(filename), 2, '.')="SAS";

            /* Remove blanks */
            filename=strip(filename);

            /* Create the full code path */
            code=compbl(cats(path, '\', filename));

            /* Trim the length of the filename for the output */
            if length(scan(filename, -2, '.')) ge 30 then do;
                repeat+1;
                out=compress(substr(scan(filename, -2, '.'), 1, 25) || "_I" || put(repeat, 8.));
            end;
            else out=scan(filename, -2, '.');

            /* Set first character to uppercase */
            substr(out,1,1)=upcase(substr(out,1,1));

            /* Modify out variable to remove spaces */
            out=tranwrd(compbl(trim(out)), " ", "_");
        run;

        /* If the directory listing was succesful, set code count, and multi flag */
        %if %nobs(dirlist) ge 1 %then %do;

            %let codecount=%nobs(dirlist);
            %let multi=1;

        %end;
        %else %do;

            %put %str(E)RROR: The directory does not contain code.;
            proc sql; drop table dirlist; quit;
            %return;

        %end;

    %end;

    /* Otherwise, exit */
    %else %do;

        %put %str(E)RROR: The directory does not exist.;
        %return;

    %end;

    /* Drop the code and output if they exist */
    proc sql;
    %if %sysfunc(exist(code)) %then %do;
        drop table code;
    %end;
    %if %sysfunc(exist(code_search))=1 %then %do;
        drop table code_search;
    %end;
    %if %sysfunc(exist(&OUT))=1 %then %do;
        drop table &OUT;
    %end;
    quit;

    /* Check for the existence of the tables in case they could not be dropped */
    /* REVISION 2011-07-13 CAS: Added check for OUT table */
    %if %sysfunc(exist(code))
     or %sysfunc(exist(code_search)) 
     or %sysfunc(exist(&OUT))
    %then %do;

        %put %str(E)RROR: The output table(s) could not be dropped.;
        %put %str(E)RROR- Check whether any of the output tables are open.;
        %return;

    %end;


    /********************************************************************************
       Import and Check Code
     ********************************************************************************/

    %if %sysfunc(exist(&OUT._all)) %then %do;
        proc sql; drop table &OUT._all; quit;
    %end;

    /* Beginning of code processing loop */
    %do codenumber=1 %to &codecount;

        /* Process multiple code */
        %if &multi=1 %then %do;

            data _null_;
                set dirlist(firstobs=&codenumber obs=&codenumber);
                call symputx('code', code);
                /* REVISION 2010-12-08 CAS: Removed 'out' macro variable */
                /*call symputx('out', out);*/
            run;

        %end;

        /* Import the code */
        %let _EFIERR_=0;
        %let ervar=%str(_E)RROR_;
        data Code;
            format CodeLine 20.;

            /* The following delimiter, the cedilla, should not be common in American
               English code or data sets. The intent is to not delimit the data at all. */
            /* REVISION 2011-06-15 CAS: Fixed a quoting problem */
            infile %unquote(%str(%')%superq(code)%str(%')) delimiter='¸' MISSOVER DSD lrecl=32767;

            informat CodeText $1000.;
            format CodeText $1000.;
            input CodeText $;

            /* Format the code text */
            CodeText=compbl(upcase(CodeText));

            /* Set line number for each code line and upcase the code text */
            CodeLine=_n_;

            /* set (E)RROR detection macro variable */
            if &ervar then call symputx('_EFIERR_',1);
        run;

        %if &_EFIERR_=1 or &SYSERR>3 or %nobs(code)=0 %then %do;

            %put %str(E)RROR: %str(E)rrors were encountered during import.;
            %return;

        %end;


        /********************************************************************************
           Search Code
         ********************************************************************************/

        /* Find term within code */
        /* REVISION 2011-01-27 CAS: Modified behavior during multi code search to insert
           name of code into OUT_all data set */
        %let codename=%scan(%scan(%superq(code), -2, %str(.)), -1, %str(\));
        data code_search(label=%unquote(%str(%')Search %superq(CODENAME) for %superq(TERM)%str(%')));
    %if &MULTI=1 %then %do;
            format Code $1000.;
    %end;
            set code;
    %if &MULTI=1 %then %do;
            Code="%superq(code)";
    %end;
    %if &PRXFLAG=1 %then %do;
            where prxmatch("%superq(PRXTERM)", Codetext)>0;
    %end;
    %else %do;
            where find(CodeText, upcase("%superq(TERM)"))>0;
    %end;
        run;

        proc append base=&OUT._all data=code_search;
        run;

        /* Check if any results exist */
        %let outobs=%nobs(code_search);
        %if &outobs ge 1 %then %do;
            %let results=Results: The term %superq(term) was found in %superq(codename). See Work.Code_search for more details.;
        %end;
        %else %do;
            %let results=No results: The term %superq(term) was not found in %superq(codename).;
        %end;

        /* Output message when processing multiple code */
        %if &multi=1 %then %do;

            data _temp_(where=(found=1));
                format Code $500. Found 8.;
                code="%superq(code)";
                if &outobs ge 1 then found=1;
                else found=0;
            run;

            proc append base=&OUT data=_temp_;
            run;

            %put ;
            %put NOTE: The following code was searched: %superq(code);
            %put NOTE: &results;

            /* Drop the output if there are no results */
            %if &outobs=0 %then %do;

                proc sql; drop table code_search; quit;

            %end;

            %if &codenumber=&codecount %then %do;

                %let outobs=%nobs(&OUT);

                %if &outobs ge 1 %then %do;
                    %let results=Results: The term %superq(term) was found in the code. See Work.&OUT for more details.;
                %end;
                %else %do;
                    %let results=No results: The term %superq(term) was not found in the code.;
                %end;

            %end;

            /* Drop temporary table */
            proc sql;
                drop table _temp_;
            quit;

        %end;

    %end;
    /* End of code processing loop */


    /********************************************************************************
       Report Results
     ********************************************************************************/

    /* Put code results in pop-up window */
    %if &pm=Y %then %do;
        dm "postmessage %bquote(')&results%bquote(')";
    %end;

    %else %if &pm=R and &outobs ge 1 %then %do;
        dm "postmessage %bquote(')&results%bquote(')";
    %end;

    %put ;
    %put NOTE: The following code or directory was checked: &code_init;
    %put NOTE: &results;
    %put ;


    /********************************************************************************
       END OF MACRO
     ********************************************************************************/

%mend SearchCode;
