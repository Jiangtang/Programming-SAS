%macro CheckLog(log,out=Log_issues,pm=Y,keyword=,abort=N,to=,cc=,test=) / des='Check log for issues';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       CheckLog
        Author:     Christopher A. Swenson
        Contact:    Chris@CSwenson.com
        Created:    2009-08-28
        Version:    2010-10-27

        OS:         Microsoft Windows
        SAS:        9.1.3+
        Language:   English

        Purpose:    Check log(s) for issues, including lines with (e)rror, (w)arning,
                    (i)nvalid, or (u)ninitialized messages. Additionally, other
                    phrases associated with issues are checked, and specific phrases
                    are ignored. The macro can also be used with non-SAS logs, as
                    long as the log uses the same issue keywords.

        Disclaimer: This program is provided "as-is". The user is responsible for
                    testing the software on their platform and selecting appropriate
                    recipients for email output. The user agrees that the author
                    will not, under any circumstances, be held accountable for any
                    damages of any type that result from using this software.

        Usage:      The output of the macro can provide information about where to
                    find issues in the log. When issues are identified, it is best
                    to open the original log and program to identify the source of
                    an issue. Otherwise, the Log dataset contains all lines with the
                    Ignore and Found variables.

                    It is suggested that the user saves the log at about the same time
                    as using the CheckLog macro, especially if relying on the email
                    function for communication. The original log can then be reviewed
                    at a later time. This can be accomplished by using a DM statement
                    (see below) or copying the Work.log file from the work directory
                    to a permanent directory once CheckLog has run.

                    dm log "file 'C:\Example\Log_20100801.log' replace;" wpgm;

                    This macro can be set to a keyboard shortcut in SAS to check the
                    current log. It has worked most consistently on F5-F8 combinations.
                    I suggest setting it to SHF + F6, since F6 is the key for the
                    log window. Type the following text in the keyboard shortcut
                    definition: gsubmit '%checklog;'

        Output:     Log             - The imported log (named according to code
                                      if reviewing a directory)
                    Log_Issues      - The log filtered for identified issues.
                    Log_Keywords    - The log with keywords, including ignored
                                      messages. Only output during testing.
                    Log_Summary     - A summmary of the issues in a log.
                    Logs_w_Issues   - A list of all the logs checked in a directory
                                      that contained issues.

        (C)aution:  Do not directly use the issue words that the macro is looking for.
                    Mask these words by using parentheses, underscores, character
                    replacement, or some other technique. If a conditional (E)RROR
                    or (W)ARNING is necessary, use the %str() function. Here are some
                    examples:

                    * Comment: Check for (e)rrors before continuing. ;
                    * Sometimes w_arnings are generated here. ;

                    data _null_;
                        [other statements]
                        if problem=1 then put "%str(E)RROR: There are problems.";
                    run;

        Arguments:  All arguments are optional. If no options are specified, the
                    macro checks the current log and outputs issues to Log_issues.

                    log     - Directory of logs or full pathname of a log

                    out     - Name of the output issues dataset (default: Log_issues)
                              Note: This is automatically set when checking a
                              directory of logs. For one log, the output can be set
                              to "Log", overwriting the original log in order to save
                              space.

                    pm      - Determines whether or not the pop-up message is used.
                              N = No, never display a pop-up message
                              Y = Yes, always display a pop-up message (default)
                              E = (E)rror only pop-up message

                    keyword - A list of word or words to search for in the log text,
                              which identify issues beyond those already identified
                              in this macro. This can be used to add words for non-
                              SAS logs that may use additionally words to indicate
                              issues, for example, (C)AUTION or (A)LERT. This could
                              also be used to differentiate user-specified issues
                              from system-generated issues.

                              NOTE: The order of the words listed matters. The words
                              listed first will be searched for last, and will
                              overwrite any other words found prior. Thus, the
                              first word should have the highest priority. Of course,
                              the original keywords will overwrite user-specified
                              keywords.

                    abort   - Determines whether or not the following program is
                              aborted. This is useful to halt a long program and
                              (a)lert the user that there are issues.
                              N = No, do not abort program when issues occur (default)
                              Y = Yes, abort program when issues occur

                              (C)AUTION: This option may have undesirable results.
                              Please use it with care and thorough testing. In version
                              9.1.3, it has been identified that when the abort option
                              is specified and used in a program, then the CheckLog
                              macro is used from a keyboard shortcut, SAS crashes.
                              There is no known workaround and it appears to be a bug
                              in SAS 9.1.3.

                              MACROS: For use in macros, it is much more stable to
                              use the following statement to end the program
                              immediately after using the CheckLog macro:

                              %if %nobs(log_issues)>0 %then %return;

                              where the NOBS macro program returns the number of
                              observations in a data set. See the CLNOBS macro
                              below for an example.

                    to      - Email address(es) to send the results to.
                              Note: Email support must be set up in SAS to use
                              this function.

                    cc      - Email address(es) to carbon copy the results to.
                              Note: CC will not work without the TO argument.

                    test    - Set to 'test' (i.e., test=test) to test CheckLog
                              without turning off the log within the macro.
                              Additionally, the dataset log_keywords is output
                              for troubleshooting.

        Issues:     The following statements are considered issues. Note that the
                    statements have been broken up to avoid detecting them within
                    this program.

                    - (E)RROR (macro variable: iss1)
                    - (W)ARNING (macro variable: iss2)
                    - (I)NVALID (macro variable: iss3)
                    - (U)NINITIALIZED (macro variable: iss4)
                    - AT LEAST ONE W.D FOR-MAT
                    - CHARACTER VALUES HAVE BEEN CON-VERTED TO NUMERIC VALUES
                    - DIVISION BY ZE-RO DETECTED
                    - MATHEMATICAL OPER-ATIONS COULD NOT BE PERFORMED
                    - MIS-SING VALUES WERE GENERATED
                    - NUMERIC VALUES HAVE BEEN CON-VERTED TO CHARACTER VALUES
                    - ONE OR MORE LINES WERE TRUNC-ATED (PROC IMPORT issue)
                    - THE QUERY REQUIRES RE-MERGING SUMMARY STATISTICS BACK WITH
                      THE ORIGINAL DATA (SQL issue)
                    - THE EXECUTION OF THIS QUERY INVOLVES PERFORMING ONE OR
                      MORE CARTESIAN PRODUCT JOINS THAT CAN NOT BE OPTIMIZED.
                      (SQL issue)
                    - ME-RGE STATEMENT HAS MORE THAN ONE DATA SET WITH RE-PEATS
                      OF BY VALUES
                    - LOST CA-RD (input/infile data step)

                    Additional phrases for review are listed below.

                    - "HAS 0 OBSERVATIONS" (Note: This could be intended.)
                    - "INPUT DATA SET IS EMPTY" (Note: This could be intended.)
                    - "OUTSIDE THE AXIS RANGE" (Graph?)
                    - "MULTIPLE LENGTH" (I think this is usually an (e)rror.)
                    - "A MISSING EQUAL SIGN HAS BEEN INSERTED"
                    - "A GROUP BY CLAUSE HAS BEEN DISCARDED"
                    - "DUPLICATE BY VARIABLE(S) SPECIFIED"
                    - "DUPLICATION OF BY VARIABLE" (Note: See phrase above.)

        Ignored:    The following statements are ignored. These statements are either
                    common or are not always issues. For example, issues generated
                    from libname statements may or may not affect the current code.
                    These issues are ignored since they will present other issues if
                    necessary for the current code. Note that the statements have been
                    broken up to avoid detecting them within this program.

                    Variable messages:
                    - _(E)RROR_=0
                    - IF _(E)RROR_
                    - THE MACRO ***** COMPLETED COMPILATION WITHOUT (E)RRORS

                    Comment messages:
                    - SET (E)RROR DETECTION MACRO
                    - SET THE (E)RROR DETECTION MACRO

                    Library messages:
                    - (E)RROR IN THE LIBNAME STATEMENT
                    - ONLY AVAILABLE TO USERS WITH RE-STRICTED SESSION PRIVILEGE
                    - THE AC-COUNT IS LOCKED
                    - UN-ABLE TO CLEAR OR RE-ASSIGN THE LIBRARY
                    - UNABLE TO COPY SAS-USER REGISTRY TO WORK REGISTRY
                    - USER DOES NOT HAVE APP-ROPRIATE AUTHORIZATION LEVEL FOR

        Variables:  The following selected macro variables are used, excluding the
                    arguments for the macro. The variable scope is noted in parentheses.

                    - _EFIERR_ (local) = the (E)RROR detection macro (an indirect
                      reference), used to avoid detecting the issue word
                    - ervar (local) = (E)RROR variable for import (an indirect
                      reference), used to avoid detecting the issue word
                    - iss1, iss2, iss3, iss4 (local) = Issue word variables used to
                      mask issue words
                    - log_init (local) = Initial log argument, used for the final
                      output since the log macro variable could change when checking
                      multiple logs
                    - logcount (local) = Count of logs to check, used when checking
                      multiple logs
                    - logmsg (global) = the final output message from the macro,
                      containing the message (msg) of the status of the log(s)
                    - lognumber (local) = Index variable used to check multiple logs,
                      used in a do loop and commonly defined as i
                    - logsummary (local) = Flag to summarize multiple logs, used
                      when checking multiple logs
                    - msg (local) = Log status message, which populates the logmsg
                      macro variable
                    - multi (local) = Flag that determines the path of the macro, used
                      when checking multiple logs
                    - outobs (local) = Record count of output, used to define whether
                      or not there is an issue in the log
                    - user_mprint (local) = macro to store the user's mprint setting
                    - user_notes (local) = macro to store the user's notes setting

        References
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Augustine, Aaron. (2010). SAS® Code Validation: L.E.T.O Method [PDF].
            http://support.sas.com/resources/papers/proceedings10/083-2010.pdf

        Foley, Malachy J. (2005). MERGING vs. JOINING: Comparing the DATA Step with
            SQL [PDF].
            http://support.sas.com/resources/papers/proceedings09/036-2009.pdf

        Kuligowski, Andrew T. (2005). In Search of the LOST CARD [PDF].
            http://www2.sas.com/proceedings/sugi30/058-30.pdf

        Slaughter, Susan J. & Delwiche, Lora D. (1997). (E)rrors, (W)arnings, and
            Notes (Oh My): A Practical Guide to Debugging SAS Programs [PDF].
            http://www2.sas.com/proceedings/sugi22/BEGTUTOR/PAPER68.PDF

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2010-04-01  CAS     Added step to identify when an output table is open.
        2010-04-06  CAS     Split phrases in order to avoid discovery from the macro.
                            Added step to check for issues on log import. Removed
                            DirList macro in favor of simpler code.
        2010-04-21  CAS     Added issue that occurs from proc import. Added additional
                            steps to check for issues with log import.
        2010-04-23  CAS     Peer reviewed by Iryna (Deyneha) Feldman.
        2010-04-27  CAS     Added a copy of the NOBS macro specifically for CheckLog
        2010-05-03  CAS     Added reference to initial log argument, instead of the
                            last log checked.
        2010-05-06  CAS     Added another requirement to enter the single log check
                            loop: A slash within the log name. This corrected an
                            issue when (i)nvalid paths were specified that contained
                            a dot (that is, just a filename), with no slash
                            (no directory). Added more detail to some (e)rror messages.
                            Added logs_w_issues to drop.
        2010-05-10  CAS     Added new statements to identify as issues. Also added
                            a new statement to ignore: _ISSUE1_=0.
        2010-05-19  CAS     Added issue phrase regarding missing values.
        2010-05-21  CAS     Added steps to check arguments to the CheckLog macro and
                            output messages regarding correct usage. Additionally
                            modified how the PM option works, setting the default to
                            pop-up the message when (i)nvalid values of PM are used.
        2010-05-26  CAS     Added documentation regarding the use of issue keywords
                            in comments and put statements (above).
        2010-05-27  CAS     Added issue phrase regarding Cartesian products in SQL.
        2010-06-03  CAS     Corrected a call symput that could generate a conversion
                            issue.
        2010-06-07  CAS     Revised logic to correctly check output dataset when
                            following the PM argument.
        2010-06-21  CAS     Removed concept of ignoring line following the issue. This
                            could cause issues with back-to-back issues.
        2010-07-21  CAS     Changed final focus to log, since in SAS 9.2 it appears to
                            jump around.
        2010-07-29  CAS     Discovered that the abort option does not work the same in
                            version 9.2, requiring a version-specific modification. It
                            was also discovered that the glitch causing SAS to crash
                            is also version-specific, and it is resolved in 9.2.
        2010-08-04  CAS     Removed spaces from log output name for multiple logs.
        2010-08-04  CAS     Added message regarding merge with repeats of by statement.
        2010-08-06  CAS     Added a new argument: keyword. See more details in the
                            documentation above.
        2010-08-06  CAS     Modified the order of the log output so the last table
                            created is the final output. This maintains that the
                            system macro variable SYSLAST will be the final output
                            (by default, Log_Issues or Logs_w_Issues).
        2010-08-06  CAS     Updated the output to add the Ignore and Found variables
                            to the Log dataset.
        2010-09-01  CAS     Added exclusion for the macro compilation note, which
                            unfortunately includes the word (e)rror.
        2010-09-03  CAS     Revised initial log variable for current log.
        2010-09-07  CAS     Added email reporting capability. Added step to clean up
                            file references. Added default for outobs macro variable
                            in order to correctly identify issues with running
                            this macro.
        2010-09-14  CAS     Added messages regarding INPUT issues, including "LOST
                            CA-RD" and "NEW LINE". Changed the truncation FOUND value
                            to match the above INPUT types.
        2010-10-01  CAS     Tested the CheckLog macro in batch mode, and discovered
                            some issues. Revised how the log is output during batch
                            mode and included some other checks for the macro when
                            no log is specified.
        2010-10-13  CAS     Tweaked the options turned off: dropped MFILE since it is
                            useless without MPRINT, added NOMACROGEN, since it can
                            still be used to resolve macro variables.
        2010-10-18  CAS     Updated the name of the copied log during batch mode,
                            which should provide more information about the program
                            that was reviewed, especially when using the email
                            function. I also updated the foolishly included (e)rror
                            and (w)arning text from the references above.
        2010-10-25  CAS     Replaced the delimiter for the import of the SAS log to 
                            use an even more unlikely delimiter, only for version 9.2.
                            Added case statement issue regarding the missing ELSE
                            clause.
        2010-10-27  CAS     Masked the delimiters using the STR function.

        YYYY-MM-DD  III     Please use this format and insert new entries above.

     *********************************************************************************
      END MACRO HEADER
     *********************************************************************************/


    /* The following line tricks the editor into thinking the macro has ended,
       allowing readers to see the rest of the code in the usual SAS colors. */
    %macro dummy; %mend dummy;


    /********************************************************************************
       Log Settings
     ********************************************************************************/

    /* Turn off mprint, notes, and the log */
    %if %lowcase(&test) ne test %then %do;

        /* Obtain option and temporarily turn off */
        %local user_mprint user_notes;
        %let user_mprint=%sysfunc(getoption(mprint));
        %let user_notes=%sysfunc(getoption(notes));
        option NOMPRINT;
        option NONOTES;

        /* Completely turn off these options */
        /* REVISION 2010-10-13 CAS: Tweaked the options turned off */
        option nomlogic nosymbolgen nomacrogen;

        /* Temporarily turn the log off */
        filename junk dummy;
        proc printto log=junk; run;

    %end;


    /********************************************************************************
       Macro Variables
     ********************************************************************************/

    /* Manage macro variable scope */
    /* REVISION 2010-08-06 CAS: Added scope for variables used with KEYWORD argument */
    %global logmsg;              /* Log issues message */
    %local
        _EFIERR_                 /* (E)RROR detection macro (indirect reference) */
        ervar                    /* (E)RROR variable for import (indirect reference) */
        key_num                  /* Variable used to scan KEYWORD argument */
        key_wrd                  /* Variable used to store scan of KEYWORD argument */
        iss1 iss2 iss3 iss4      /* Issue word variables */
        log_init                 /* Initial log argument */
        logcount                 /* Count of logs to check*/
        lognumber                /* Index variable used to check multiple logs */
        logsummary               /* Flag to summarize multiple logs */
        msg                      /* Pop-up message */
        multi                    /* Multiple-log flag */
        outobs                   /* Record count of output */
    ;

    /* Set defaults */
    /* Note: These variables are modified when a directory is submitted */
    /* REVISION 2010-09-07 CAS: Set default for outobs to detect various
       issues with using the macro or imports */
    %let multi=0;
    %let logcount=1;
    %let logsummary=0;
    %let outobs=1;

    /* Set initial log argument */
    /* REVISION 2010-05-03 CAS: Added initial log variable */
    %let log_init=&log;

    /* List of words to check */
    /* Note: These are listed here to avoid writing them to the log upon inclusion
       of the macro program. */
    %let iss1=%str(E)RROR;
    %let iss2=%str(W)ARNING;
    %let iss3=%str(I)NVALID;
    %let iss4=%str(U)NINITIALIZED;

    /* Set initial scan of KEYWORD argument and create KEY_WRD macro variables */
    %if "&KEYWORD" ne "" %then %do;

        %let key_num=1;
        %let key_wrd=%scan(&keyword, &key_num, %str( ));
        %let key_wrd&key_num=%scan(&keyword, &key_num, %str( ));

        %do %while("&key_wrd" ne "");

            /* Increment scan */
            %let key_num=%eval(&key_num+1);
            %let key_wrd=%scan(&keyword, &key_num, %str( ));
            %let key_wrd&key_num=%scan(&keyword, &key_num, %str( ));

        %end;

    %end;

    %let key_num=%eval(&key_num-1);


    /********************************************************************************
       Check Arguments
     ********************************************************************************/
    /* REVISION 2010-05-21 CAS: Added the following checks of the arguments */

    /* Modify arguments */
    /* Note: These are modified to avoid using upcase and lowcase repeatedly */
    /* REVISION 2010-08-06 CAS: Added a new argument: keywords */
    %let pm=%upcase(&pm);
    %let keyword=%upcase(&keyword);
    %let abort=%upcase(&abort);
    %let test=%lowcase(&test);

    /* OUT */
    %if %index(*0*1*2*3*4*5*6*7*8*9*, *%substr(&out, 1, 1)*) ne 0 %then %do;

        %let msg=YOU FOOL! THERE IS NO ESCAPE!;
        %let logmsg=%str(E)RROR: &msg;
        %goto exit;

    %end;

    %if %length(&out)>32 %then %do;

        %let msg=YOU FOOL! THERE IS NO ESCAPE!;
        %let logmsg=%str(E)RROR: &msg;
        %goto exit;

    %end;

    /* PM */
    /* Note: Checks for Y (Yes), N (No), and E ([E]rror only) */
    %if "&PM" ne "" and %index(*Y*N*E*,*&PM*)=0 %then %do;

        %let msg=UNGH. Zombies ate your brain.;
        %let logmsg=%str(E)RROR: &msg;
        %goto exit;

    %end;

    /* ABORT */
    /* Note: Checks for Y (Yes) and N (No) */
    %if "&ABORT" ne "" and %index(*Y*N*,*&ABORT*)=0 %then %do;

        %let msg=UNGH. Zombies ate your brain.;
        %let logmsg=%str(E)RROR: &msg;
        %goto exit;

    %end;


    /********************************************************************************
       Internal Macro Programs
     ********************************************************************************/

    /* CheckLog NOBS macro: Returns the number of records in a SAS table. */
    %macro CLNOBS(dsn) / des='Copy of NOBS macro for CheckLog macro';

        /* Define these variables locally */
        %local dsid anobs rc;

        /* Check if the table exists */
        %if %sysfunc(exist(&dsn))=0 %then %do;
            %put %str(W)ARNING: %sysfunc(compbl(The &dsn dataset does not exist)).;
            %let num=;
        %end;
        %else %do;

            /* Open the dataset */
            %let dsid=%sysfunc(open(&dsn));

            /* Check to see if SAS can obtain the observations */
            %let anobs=%sysfunc(attrn(&dsid,anobs));
            %if &anobs=0 %then %do;
                %put %str(W)ARNING: The macro NOBS is unable to obtain the number of observations from this engine (e.g., Oracle, Sybase).;
            %end;

            /* ATTRN will not work correctly against Sybase and Oracle tables */
            %let num=%sysfunc(attrn(&dsid,nobs));

            /* Close the dataset */
            %let rc=%sysfunc(close(&dsid));

        %end;

        /* Lack of semi-colon makes this value the output from this macro. */
        &num

    %mend CLNOBS;


    /********************************************************************************
       Determine Log(s) to Check
     ********************************************************************************/

    /***** Current log *****/
    /* Save the current log in the work directory */
    /* REVISION 2010-10-01 CAS: Modified behavior in batch mode */
    %if "&log"="" %then %do;

        /* Obtain the work directory */
        /* REVISION 2010-09-03 CAS: Revised log_init variable */
        %let log=%sysfunc(pathname(work))\Work.log;
        %let log_init=Work.log;

        /* Delete the log if it already exists */
        %if %sysfunc(fileexist(&log))=1 %then %do;

            filename log "&log";

            %local fd;
            %let fd=%sysfunc(fdelete(log));

            %if &fd ne 0 %then %do;
                %let msg=The undead rise!;
                %let logmsg=%str(E)RROR: &msg;
                %goto exit;
            %end;

            filename log clear;

        %end;

        /* Output log from window */
        dm log "file %bquote(')&log%bquote(') replace;" wpgm;

        /* If the log does not exist, assume batch mode and try copying log to work */
        /* REVISION 2010-10-18 CAS: Revised name of work log for batch mode */
        %if %sysfunc(fileexist(&log))=0 %then %do;

            %local batchlog user_xsync user_xwait;

            /* Obtain name for batch log */
            %let batchlog=%sysfunc(getoption(SYSIN));
            %if "%superq(batchlog)"="" %then %let batchlog=%sysget(SAS_EXECFILEPATH);
            %let batchlog=%substr(%superq(batchlog), 1, %length(%superq(batchlog))-4).log;

            /* Set name for copied log */
            %let log=%sysfunc(pathname(work))\%scan(%superq(batchlog), -1, %str(\));
            %let log_init=%superq(batchlog);

            /* Temporarily modify options */
            %let user_xsync=%sysfunc(getoption(xsync));
            %let user_xwait=%sysfunc(getoption(xwait));
            options xsync noxwait;

            /* Copy batch log to work */
            x "%str(copy %"&batchlog%" %"&log%")";

            /* Restore options */
            options &user_xsync &user_xwait;

        %end;

        /* If all else fails, quit the macro */
        %if %sysfunc(fileexist(&log))=0 %then %do;

            %let msg=There is no escape. The winged monkeys have captured you.;
            %let logmsg=%str(E)RROR: &msg;
            %goto exit;

        %end;

    %end;

    /***** Single log *****/
    /* Check for a dot signifying a file and a slash signifying a directory */
    /* REVISION 2010-05-06 CAS: Added another requirement to enter this loop: a slash */
    %else %if (%index(&log, %str(.)) ge 1) and (%index(&log, %str(\)) ge 1) %then %do;

        /* Check that the directory exists */
        /* Note: The following functions remove the file from the directory to
           check if the directory exists. */
        %if %sysfunc(fileexist( %substr(&log, 1, %eval( %length(&log) - %length( %scan(&log, -1, %str(\)) ) )) ))=0
        %then %do;

            %let msg=The floor disappears beneath you. AAAUGH!;
            %let logmsg=%str(E)RROR: &msg;
            %goto exit;

        %end;

        /* Check that the log exists */
        %if %sysfunc(fileexist(&log))=0 %then %do;

            %let msg=A witch casts an amnesia spell on you. You have a vague feeling of losing something.;
            %let logmsg=%str(E)RROR: &msg;
            %goto exit;

        %end;

    %end;

    /***** Multiple logs *****/
    /* Check that the directory exists */
    %else %if %sysfunc(fileexist(&log))=1 %then %do;

        /* Add extra slash if necessary */
        %if %substr(&log, %length(&log), 1) ne \ %then %do;
            %let log=&log.\;
            %let log_init=&log;
        %end;

        /* REVISION 2010-04-06 CAS: Removed DirList macro in favor of simpler code */
        /* Note: The following code executes a DOS command that lists the contents
           of the directory. /B removes the heading and summary. /ON sorts by name.
           /A:-D removes the empty directory listing. */
        filename DirList pipe %unquote(%str(%'dir "&log" /B /A:-D /ON %'));

        /* Modify the directory listing output */
        data _DirList_(drop=filename repeat);
            infile DirList length=length;
            input @01 filename $varying1000. length;
            format log $1000. out $30.;
            retain repeat 0 log;

            /* Keep only logs */
            if index(upcase(filename),'.LOG');

            /* Remove blanks */
            filename=strip(filename);

            /* Create the full log path */
            log=compbl(cats("&log", filename));

            /* Trim the length of the filename for the output */
            if length(scan(filename, -2, '.')) ge 30 then do;
                repeat+1;
                out=compress(substr(scan(filename, -2, '.'), 1, 25) || "_I" || put(repeat, 8.));
            end;
            else out=scan(filename, -2, '.');

            /* Set first character to uppercase */
            substr(out,1,1)=upcase(substr(out,1,1));

            /* Modify out variable to remove spaces */
            /* REVISION 2010-08-04 CAS: Removing spaces from output name */
            out=tranwrd(compbl(trim(out)), " ", "_");
        run;

        filename DirList clear;
        /* REVISION 2010-04-06 CAS: End Revision */

        /* If the directory listing was succesful, set log count and multi flag */
        %if %clnobs(_dirlist_) ge 1 %then %do;

            %let logcount=%eval(%clnobs(_dirlist_)+1);
            %let multi=1;

        %end;
        %else %do;

            %let msg=The treasure chest opens, but is empty. Someone got here first!;
            %let logmsg=%str(E)RROR: &msg;

            proc sql; drop table _dirlist_; quit;

            %goto exit;

        %end;

    %end;

    /***** (I)nvalid Arguments *****/
    /* Otherwise, exit */
    /* REVISION 2010-05-06 CAS: Added more detail to the (e)rror messages */
    %else %if %index(&log, %str(.))>0 %then %do;

        %let msg=UNGH. Zombies ate your brain.;
        %let logmsg=%str(E)RROR: &msg;
        %goto exit;

    %end;

    %else %if %index(&log, %str(\))>0 %then %do;

        %let msg=UNGH. Zombies ate your brain.;
        %let logmsg=%str(E)RROR: &msg;
        %goto exit;

    %end;

    %else %do;

        %let msg=UNGH. ZOmbies ate your brain.;
        %let logmsg=%str(E)RROR: &msg;
        %goto exit;

    %end;

    /***** Cleanup *****/
    /* Drop the log and output if they exist */
    /* REVISION 2010-05-06 CAS: Added logs_w_issues to drop */
    proc sql;
    %if %sysfunc(exist(log)) %then %do;
        drop table log;
    %end;
    %if %sysfunc(exist(&out))=1 %then %do;
        drop table &out;
    %end;
    %if %sysfunc(exist(log_keywords)) %then %do;
        drop table log_keywords;
    %end;
    %if %sysfunc(exist(logs_w_issues)) %then %do;
        drop table logs_w_issues;
    %end;
    %if %sysfunc(exist(log_summary)) %then %do;
        drop table log_summary;
    %end;
    quit;

    /* Check for the existence of the tables in case they could not be dropped */
    /* REVISION 2010-04-01 CAS: Added step to identify when a table is open. */
    %if %sysfunc(exist(log)) or %sysfunc(exist(&out)) %then %do;
        %let msg=The dead rise!;
        %let logmsg=%str(E)RROR: &msg;
        %goto exit;
    %end;


    /********************************************************************************
       Import and Check Log(s)
     ********************************************************************************/

    /* Beginning of log processing loop */
    %do lognumber=1 %to &logcount;

        /* Process multiple logs */
        %if &multi=1 %then %do;

            /* Set each log and output */
            %if &lognumber<&logcount %then %do;

                data _null_;
                    set _dirlist_(firstobs=&lognumber obs=&lognumber);
                    call symput('log', compbl(log));
                    call symputx('out', out);
                run;

            %end;

            /* At the end, export the current log to display list of logs with
               issues for easier review. */
            %else %if &lognumber=&logcount %then %do;

                /* Obtain the work directory */
                %let log=%sysfunc(pathname(work))\Work.log;

                /* Output log */
                dm log "file %bquote(')&log%bquote(') replace;" wpgm;

                /* Reset variables */
                %let out=Logs_w_issues;
                %let multi=0;
                %let logsummary=1;

                /* Drop tables from directory listing */
                proc sql;
                    drop table _dirlist_;
                quit;

            %end;

        %end;

        /* Import the log */
        %let _EFIERR_=0;
        %let ervar=%str(_E)RROR_;
        data Log;
            format LogLine 20.;

            /* The following delimiter, the cedilla, should not be common in American
               English code or datasets. The intent is to not delimit the data at all. */
            /* REVISION 2010-10-25 CAS: Expanded the delimiter to be even more unlikely,
               using a string instead of a single character for version 9.2. */
            /* REVISION 2010-10-27 CAS: Masked the delimiters using the STR function. */
        %if %substr(&SYSVER, 1, 3)=9.1 %then %do;
            infile "%sysfunc(compbl(&log))" delimiter='%str(¸)' MISSOVER DSD lrecl=32767;
        %end;
        %else %if %substr(&SYSVER, 1, 3)=9.2 %then %do;
            infile "%sysfunc(compbl(&log))" dlmstr='%str({[¸])(,)}' MISSOVER DSD lrecl=32767;
        %end;

            informat LogText $1000.;
            format LogText $1000.;
            input LogText $;

            /* Format the log text */
            LogText=compbl(upcase(LogText));

            /* Set line number for each log line and upcase the log text */
            LogLine=_n_;

            /* set (E)RROR detection macro variable */
            /* REVISION 2010-06-03 CAS: Corrected the symput to avoid conversion */
            if &ervar then call symputx('_EFIERR_','1');
        run;

        /* REVISION 2010-04-06 CAS: Added step to check for issues on log import */
        /* REVISION 2010-04-21 CAS: Added step to check if the log is empty or the system
           encountered an issue. */
        %if &_EFIERR_=1 or &SYSERR>3 or %clnobs(log)=0 %then %do;

            %let msg=The pirates mutiny against you! You are forced to walk the plank!;
            %let logmsg=%str(E)RROR: &msg;
            %goto exit;

        %end;


        /********************************************************************************
           Check Log
         ********************************************************************************/

        /* REVISIONS: Changed the order of the output to allow opening of final output
           rather than the keywords output (2010-08-06). Added Ignore and Found variables
           to Log dataset (2010-08-06). */
        data
        %if %eval(&multi + &logsummary + 0)=0 %then %do;
            Log
        %end;
        %if &test=test %then %do;
            Log_keywords
        %end;
            &out
        %if &test ne test %then %do;
            (drop=ignore)
        %end;
        %else %if &logsummary=1 %then %do;
            (drop=ignore logline found rename=(LogText=Logs))
        %end;
        ;
            set log;
            format Ignore 8. Found $30.;
            Ignore=0;


            /***** Identify Issues *****/

            /* User-specified Issue Words */
            /* Loop through each argument in KEYWORD */
            /* REVISION 2010-08-06 CAS: Added use of KEYWORD argument */
    %if "&KEYWORD" ne "" %then %do;

        %local k;
        %do k=&KEY_NUM %to 1 %by -1;

            if find(LogText, "&&key_wrd&k")>0 then Found="&&key_wrd&k";

        %end;

    %end;

            /* Issue Words */
        %local z;
        %do z=4 %to 1 %by -1;

            if find(LogText, "&&iss&z")>0 then Found="&&iss&z";

        %end;

            /* Issue Phrases

            Revisions
            ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            Date        Author  Comments
            ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
            2010-04-06  CAS     Split the phrases in order to avoid discovery from the
                                macro.
            2010-04-21  CAS     Added new message for trunc-ated records during import.
            2010-05-10  CAS     Added message regarding formats being too small.
            2010-05-10  CAS     Added messages regarding math problems.
            2010-05-27  CAS     Added message regarding Cartesian product.
            2010-08-04  CAS     Added message regarding merge with repeats of by statement.
            2010-09-14  CAS     Added messages regarding INPUT issues, including "LOST CA-RD"
                                and "NEW LINE". Changed the truncation FOUND value to match
                                the above INPUT types.
            2010-10-25  CAS     Added the phrase regarding the SQL case expression without
                                the else clause.
            YYYY-MM-DD  III     Please use this format and insert new entries above

            */
            if find(LogText, "THE QUERY REQUIRES RE"||"MERGING SUMMARY STATISTICS BACK WITH THE ORIGINAL DATA")>0 then Found="REMERGE";
            if find(LogText, "NUMERIC VALUES HAVE BEEN CONV"||"ERTED TO CHARACTER VALUES")>0 then Found="CONVERSION";
            if find(LogText, "CHARACTER VALUES HAVE BEEN CONV"||"ERTED TO NUMERIC VALUES")>0 then Found="CONVERSION";
            if find(LogText, "ONE OR MORE LINES WERE TRUNC"||"ATED")>0 then found="INPUT";
            if find(LogText, "AT LEAST ONE W.D FOR"||"MAT")>0 then found="FORMAT";
            if find(LogText, "DIVISION BY ZE"||"RO DETECTED")>0 then found="MATH";
            if find(LogText, "MATHEMATICAL OPER"||"ATIONS COULD NOT BE PERFORMED")>0 then found="MATH";
            if find(LogText, "MIS"||"SING VALUES WERE GENERATED")>0 then found="MATH";
            if find(LogText, "THE EXECUTION OF THIS QUERY INVOLVES PERFORMING ONE OR MORE CART"||"ESIAN PRODUCT JOINS THAT CAN NOT BE OPTIMIZED.")>0 then found="CARTESIAN";
            if find(LogText, "MER"||"GE STATEMENT HAS MORE THAN ONE DATA SET WITH RE"||"PEATS OF BY VALUES")>0 then found="MERGE";
            if find(LogText, "NOTE: LOST CA"||"RD")>0 then found="INPUT";
            if find(LogText, "NEW LI"||"NE WHEN INPUT")>0 then found="INPUT";
            if find(LogText, "A CASE EXPRE"||"SSION HAS NO ELSE CLAUSE")>0 then found="SYNTAX";


            /***** Ignored Phrases *****/
            /* REVISIONS: Added exclusions for _ISSUE1_=0, which can be output for
               normal data (2010-05-10). Removed concept of ignoring line following
               the issue (2010-06-21). Added the KEYWORD=KEYWORD phrase to ignore
               (2010-08-06). Combined check for keyword exclusions and added exclusion
               for the other comment style (2010-08-06). Added exclusion for macro
               compilation note (2010-09-01).
            */
            if not missing(Found) then do;

                if find(LogText,"THE ACC"||"OUNT IS LOCKED")>0
                or find(LogText,"UNABLE TO CLEAR OR RE-AS"||"SIGN THE LIBRARY")>0
                or find(LogText,"USER DOES NOT HAVE AP"||"PROPRIATE AUTHORIZATION LEVEL FOR")>0
                or find(LogText,"UNABLE TO COPY SAS"||"USER REGISTRY TO WORK REGISTRY")>0
                or find(LogText,"ONLY AVAILABLE TO USERS WITH RE"||"STRICTED SESSION PRIVILEGE")>0
                or find(LogText,"ER"||"ROR IN THE LIBNAME STATEMENT")>0
                or find(LogText,"KEY"||"WORD=&KEYWORD")>0

                /* Exclude these phrases with keywords included */
                or find(LogText,"IF _&iss1._")>0
                or find(LogText,"_&iss1._=0")>0
                or find(LogText,"_&iss1._ = 0")>0
                or find(LogText,"SET &iss1. DET"||"ECTION MACRO")>0
                or find(LogText,"SET THE &iss1. DET"||"ECTION MACRO")>0
                or find(logtext,"WIT"||"HOUT &iss1.")>0

                /* Exclude keywords in put statements, comments, and quotes */
            %local x;
            %do x=1 %to 4;
                or prxmatch('/%PUT.*' || "&&iss&x" || '.*/', LogText)
                or prxmatch('/\/\*.*' || "&&iss&x" || '.*\//', LogText)
                or prxmatch('/\*.*' || "&&iss&x" || '.*;/', LogText)
                or prxmatch('/' || '"' || '.*' || "&&iss&x" || '.*' ||  '"' || '/', LogText)
                or prxmatch('/' || "'" || '.*' || "&&iss&x" || '.*' ||  "'" || '/', LogText)
            %end;

        %if "&KEYWORD" ne "" %then %do;

            %local y;
            %do y=1 %to &KEY_NUM;
                or prxmatch('/%PUT.*' || "&&key_wrd&y" || '.*/', LogText)
                or prxmatch('/\/\*.*' || "&&key_wrd&y" || '.*\//', LogText)
                or prxmatch('/\*.*' || "&&key_wrd&y" || '.*;/', LogText)
                or prxmatch('/' || '"' || '.*' || "&&key_wrd&y" || '.*' ||  '"' || '/', LogText)
                or prxmatch('/' || "'" || '.*' || "&&key_wrd&y" || '.*' ||  "'" || '/', LogText)
            %end;

        %end;

                then Ignore=1;


            /***** Output *****/

            %if &test=test %then %do;

                /* Output all key words in test mode */
                output log_keywords;

            %end;

                /* Output only if the record is not flagged to be ignored */
                if Ignore=0 then do;

                %if &logsummary=1 %then %do;

                    /* Summarize the logs with issues */
                    if substr(LogText, 1, 5)="&iss1" then do;
                        LogText=substr(LogText, 50);
                        LogText=substr(LogText, 1, length(LogText)-1);
                    end;
                    else delete;

                %end;

                    output &out;

                end;
                /* End of 'Ignore=0' condition */

            end;
            /* End of 'not missing(Flagged)' condition */

        /* Output to the log dataset if not a multiple-log review or the log summary. */
        %if %eval(&multi + &logsummary + 0)=0 %then %do;
            output log;
        %end;

        run;

        /* Check if any issues exist */
        %let outobs=%clnobs(&out);
        %if &outobs ge 1 %then %do;

            %if &logsummary=0 %then %do;

                %let msg=MWA HA HA! You fool! You are cursed with leprosy!;
                %let logmsg=%str(E)RROR: &msg;

            %end;
            %else %if &logsummary=1 %then %do;

                %let msg=MWA HA HA! You fools! You have all been enslaved by a demon!;
                %let logmsg=%str(E)RROR: &msg;

            %end;

        %end;
        %else %do;

            %let msg=EEE HEE HEE HEE HEE! You may have escaped this time, but I will get you! AH HA HA HA!;
            %let logmsg=NOTE: &msg;

        %end;

        /* Output message when processing multiple logs */
        %if &multi=1 %then %do;

            /* Temporarily restore log */
            %if &test ne test %then %do;

                proc printto; run;
                option notes;

            %end;

            %put ;
            %put NOTE: The following filth was sifted through: &log;
            %put &logmsg;

            /* Turn off log to continue */
            %if &test ne test %then %do;

                filename junk dummy;
                proc printto log=junk; run;
                option nonotes;

            %end;

            /* Drop the output if there are no issues */
            %if &outobs=0 %then %do;

                proc sql; drop table &out; quit;

            %end;

        %end;

    %end;
    /* End of log processing loop */


    /********************************************************************************
       Report Issues
     ********************************************************************************/

    /* Exit here when issues occur within macro (e.g., bad log location) */
    %exit:

    /* Email */
    /* REVISION 2010-09-03 CAS: Added email capability */
    %if "%superq(to)" ne "" %then %do;

        %if %sysfunc(exist(&out)) and %upcase(&out) ne LOGS_W_ISSUES and &outobs>0 %then %do;

            /* Summary */
            proc sql;
                create table Log_summary as
                select Found as Issue, sum(1) as Count format=8.
                from &out
                group by Found
                order by
                      case when found="&iss1" then 1
                           when found="&iss2" then 2
                           when found="&iss3" then 3
                           when found="&iss4" then 4
                           else 5 end
                    , found
                ;
            quit;

        %end;

        /* Determine number of email addresses specified in to and cc fields */
        %local tonum tovar toi tonext ccnum ccvar cci ccnext;
        %let tonum=1;
        %let ccnum=1;
        %let tovar=%scan(%superq(to), &tonum, %str( ));
        %let ccvar=%scan(%superq(to), &ccnum, %str( ));

        /* Scan and increment the counter */
        %do %while(%superq(tovar) ne %str());
            %let tonum=%eval(&tonum+1);
            %let tovar=%scan(%superq(to), &tonum, %str( ));
        %end;
        %do %while(%superq(ccvar) ne %str());
            %let ccnum=%eval(&ccnum+1);
            %let ccvar=%scan(%superq(cc), &ccnum, %str( ));
        %end;

        /* Susbtract 1 since the scan completes an extra time */
        %let tonum=%eval(&tonum-1);
        %let ccnum=%eval(&ccnum-1);

        /* Set up email document */
        filename mymail email "NULL"

            to=(
        %do toi=1 %to &tonum;
            %let tonext=%scan(%superq(to), &toi, %str( ));
            "&tonext"
        %end;
               )

        %if "%superq(cc)" ne "" %then %do;
            cc=(
        %do cci=1 %to &ccnum;
            %let ccnext=%scan(%superq(cc), &cci, %str( ));
            "&ccnext"
        %end;
               )
        %end;

        %if &outobs>0 %then %do;
            subject="CheckLog: A Foul Stench Arises"
        %end;
        %else %do;
            subject="CheckLog: You Have Escaped... for NOW!"
        %end;
        ;

        /* Send email with issues if necessary */
        %if %sysfunc(exist(log_summary))=1 %then %do;

            data _null_;
                set log_summary;
                file mymail;
                if _n_=1 then do;
                    put "The following filth was sifted through: &log_init";
                    put "&msg";
                    put " ";
                    put "Summary:";
                    put " ";
                end;
                put %str("    ") Issue Count=;
            run;

        %end;

        %else %do;

            data _null_;
                file mymail;
                put "The following filth was sifted through: &log_init";
                put "&msg";
            run;

        %end;

        /* Clear email filename */
        filename mymail clear;

    %end;

    /* Put log issues in pop-up window */
    /* REVISION 2010-05-21 CAS: Added steps to handle (i)nvalid values of PM argument */
    /* REVISION 2010-06-07 CAS: Subset the logic to check the ouput observations
       to correctly implement logic. */
    %if &PM=E %then %do;

        %if &outobs ge 1 %then %do;
            dm "postmessage %bquote(')&msg%bquote(')" log;
        %end;

    %end;

    %else %if &pm ne N %then %do;
        dm "postmessage %bquote(')&msg%bquote(')" log;
    %end;

    /* Restore mprint and log */
    %if &test ne test %then %do;

        /* Turn the log back on */
        proc printto; run;

        /* REVISION 2010-09-07 CAS: Added step to clean up file references */
        filename junk clear;

        /* Reset mprint option to original setting */
        option &user_notes;
        option &user_mprint;

    %end;

    /* REVISION 2010-05-03 CAS: Changed log reference to initial argument */
    %put ;
    %put NOTE: The following filth was sifted through: &log_init;
    %put &logmsg;
    %put ;

    /* Abort program if specified */
    /* REVISION 2010-04-13 CAS: Shifted the abort statement to a do loop.
       This was an attempt to correct an issue that arises when the macro
       is called with abort=Y and then subsequently called by a keyboard
       shortcut. This is a known issue and appears to be a glitch in SAS. */
    /* REVISION 2010-07-29 CAS: Discovered that the abort option does not work the 
       same in version 9.2, requiring a version-specific modification. It was also 
       discovered that the glitch causing SAS to crash is also version-specific, and 
       it is resolved in 9.2. */
    %if &abort=Y and &outobs ge 1 %then %do;

        %if %substr(&SYSVER, 1, 3)=9.1 %then %do;
            dm "postmessage '&iss2.: YOU HAVE FAILED! Do not use CheckLog in a keyboard shortcut.'" log;
            %abort;
        %end;

        %else %if %substr(&SYSVER, 1, 3)=9.2 %then %do;
            %abort cancel;
        %end;

    %end;

    /********************************************************************************
       END OF MACRO
     ********************************************************************************/

%mend CheckLog;
