%macro CheckLog(log,ext=LOG,keyword=,exclude=,out=Log_issues,pm=Y,sound=N,to=,cc=,relog=N,dirext=N,shadow=Y,abort=N,test=)
    / des='Check the current log, an external log, or a directory of logs for issues';

    /*  Quick Argument Reference:

        Input:
        log      - Item to check, either blank (current), a file, or a directory
        ext=     - Extension of files to identify for checking in a directory, defaulted to LOG
        keyword= - Additional keyword(s) to search for
        exclude= - A data set with messages (in a column called LogText) to exclude

        Reporting:
        out=     - Output data set name, defaulted to Log_issues
        pm=      - Pop-up message behavior control, either Yes, No, or E (when issues found)
        sound=   - Sound behavior control, either Yes, No, or E (when issues found)
        relog=   - Recreate the log in the current interactive SAS session (Yes, No), defaulted to No
        to=      - Email address to send a report to
        cc=      - Email address to copy a report to (TO= required first)

        Operational:
        dirext=  - Use the full filename when checking a directory (Yes, No), defaulted to No
        shadow=  - Copy the log before importing it (Yes, No), defaulted to Yes
        abort=   - Abort SAS if issues are detected (Yes, No), defaulted to No
        test=    - Set to 'test' to enter test mode

    */

    /********************************************************************************
       BEGIN MACRO HEADER
     ********************************************************************************

        Name:       CheckLog
        Author:     Christopher A. Swenson
        Contact:    Chris@CSwenson.com
        Created:    2009-08-28
        Version:    3 (2011-09-09)

        OS:         Microsoft Windows, UNIX, OpenVMS, z/OS
        SAS:        9.1.3+
        Language:   English

        Sections:   0) Macro Header                     4) Internal Macro Programs
                    1) Log Settings                     5) Determine Log(s) to Check
                    2) Macro Variables                  6) Import and Check Log(s)
                    3) Check Arguments                  7) Report Issues

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
                    an issue. Otherwise, the Log data set contains all lines with the
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

        Batch Mode: During batch mode, be sure to execute a DATA step or a procedure
                    before using CheckLog. Otherwise, the log will not be written out
                    when CheckLog tries to make a copy of it.

        Log names:  The names of the logs should be valid SAS names, so as to name
                    the data sets of the imported text.

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

                    %put %str(E)RROR: This is a custom message.;

        Arguments:  All arguments are optional. If no options are specified, the
                    macro checks the current log and outputs issues to Log_issues.

                    Input:

                    log     - Directory of logs or full pathname of a log. Do not use
                              single or double quotes. Note that the names of the
                              logs in a directory should be valid SAS names.

                    ext=    - Extension to search for when looking for logs in a
                              directory of log, defaulted to LOG.

                    keyword=- A list of word or words to search for in the log text,
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

                    exclude=- A data set containing issues to exclude. Include the
                              name of the variable after the data set name if it is
                              not LogText (e.g., work.exclusions list). This can be
                              used when non-issues are encountered that cannot be
                              filtered based on a simple rule (e.g., a data set name
                              unavoidably contains the word '(e)rror'). It is not
                              recommended that this feature be used to circumvent
                              code revision for easily-avoided issues. Note that data
                              set options can be applied with this argument, so a
                              master file with exclusions can be used and filtered.

                    Reporting:

                    out=    - Name of the output issues data set (default: Log_issues).
                              Note: This is automatically set when checking a
                              directory of logs.

                    pm=     - Determines whether or not the pop-up message is used:
                              N = No, never display a pop-up message
                              Y = Yes, always display a pop-up message (default)
                              E = (E)rror only pop-up message

                    sound=  - Determines whether or not a sound is played:
                              N = No, never play a sound (default)
                              Y = Yes, always play a sound
                              E = (E)rror only sound

                    to=     - Email address(es) to send the results to.
                              Note: Email support must be set up in SAS to use
                              this function.

                    cc=     - Email address(es) to carbon copy the results to.
                              Note: CC will not work without the TO argument.

                    relog=  - Overwrites the current log with the imported log, after
                              the CheckLog outputs notes regarding the status of the
                              log. Best used for testing and reviewing logs.
                              N = Do not overwrite the current log
                              Y = Overwrite the current log with the imported log
                              E = (E)rror only overwrite

                    Operational:

                    dirext= - When checking a directory of logs, it adds the directory
                              and extension to the log name.
                              N = No, do not add directory and extension
                              Y = Yes, add directory and extension

                    shadow= - Make a copy of the log before checking it, useful when
                              the program is still running and generating the log.
                              N = No, do not make a copy of the log (default)
                              Y = Yes, make a copy of the log

                    abort=  - Determines whether or not the following program is
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

                              %if &ISSUES>0 %then %return;

                    test=   - Set to 'test' (i.e., test=test) to test CheckLog
                              without turning off the log within the macro.
                              Additionally, the data set log_keywords is output
                              for troubleshooting.

        Issues:     The following statements are considered issues. Note that the
                    statements have been broken up to avoid detecting them within
                    this program.

                    Keywords:
                    - (E)RROR (macro variable: iss1)
                    - (W)ARNING (macro variable: iss2)
                    - (I)NVALID (macro variable: iss3)
                    - (U)NINITIALIZED (macro variable: iss4)

                    Conversion:
                    - CHARACTER VALUES HAVE BEEN CON-VERTED TO NUMERIC VALUES
                    - NUMERIC VALUES HAVE BEEN CON-VERTED TO CHARACTER VALUES

                    Format:
                    - AT LEAST ONE W.D FOR-MAT

                    Input:
                    - LOST CA-RD (input/infile data step)
                    - NEW LI-NE WHEN INPUT
                    - ONE OR MORE LINES WERE TRUNC-ATED (PROC IMPORT issue)

                    Math:
                    - DIVISION BY ZE-RO DETECTED
                    - MATHEMATICAL OPER-ATIONS COULD NOT BE PERFORMED
                    - MIS-SING VALUES WERE GENERATED

                    Merge:
                    - ME-RGE STATEMENT HAS MORE THAN ONE DATA SET WITH RE-PEATS
                      OF BY VALUES

                    SQL:
                    - THE EXECUTION OF THIS QUERY INVOLVES PERFORMING ONE OR
                      MORE CAR-TESIAN PRODUCT JOINS THAT CAN NOT BE OPTIMIZED.
                    - THE QUERY REQUIRES RE-MERGING SUMMARY STATISTICS BACK WITH
                      THE ORIGINAL DATA

                    Syntax:
                    - A CASE EXPRE-SSION HAS NO ELSE CLAUSE
                    - THE MEANING OF AN IDENT-IFIER AFTER A QUOTED STRING MAY CHANGE

                    Additional phrases for review are listed below.

                    - "NO TOOLS DEFINED"
                    - "UNABLE TO ACCESS SPECIFIED PRINTER DRIVER"
                    - "UNABLE TO FIND THE PRINTER NAME"
                    - "HAS 0 OBSERVATIONS" (Note: This could be intended.)
                    - "INPUT DATA SET IS EMPTY" (Note: This could be intended.)
                    - "OUTSIDE THE AXIS RANGE" (Graph?)
                    - "MULTIPLE LENGTH" (I think this is usually an (e)rror.)
                    - "A MISSING EQUAL SIGN HAS BEEN INSERTED"
                    - "A GROUP BY CLAUSE HAS BEEN DISCARDED"
                    - "DUPLICATE BY VARIABLE(S) SPECIFIED"
                    - "DUPLICATION OF BY VARIABLE" (Note: See phrase above.)

                    Check the following pages:
                    - http://tinyurl.com/3wrvozg (sas.com)
                    - http://tinyurl.com/3qe2ugs (sas.com)
                    - http://tinyurl.com/3bn7h3n (sas.com)

        Ignored:    The following statements are ignored. These statements are either
                    common or are not always issues. For example, issues generated
                    from libname statements may or may not affect the current code.
                    These issues are ignored since they will present other issues if
                    necessary for the current code. Note that the statements have been
                    broken up to avoid detecting them within this program.

                    Variable messages:
                    - _(E)RROR_=0
                    - IF _(E)RROR_
                    - SET (E)RROR DETECTION MACRO
                    - SET THE (E)RROR DETECTION MACRO

                    Library messages:
                    - (E)RROR IN THE LIBNAME STATEMENT
                    - ONLY AVAILABLE TO USERS WITH RE-STRICTED SESSION PRIVILEGE
                    - THE AC-COUNT IS LOCKED
                    - UN-ABLE TO CLEAR OR RE-ASSIGN THE LIBRARY
                    - UNABLE TO COPY SAS-USER REGISTRY TO WORK REGISTRY
                    - USER DOES NOT HAVE APP-ROPRIATE AUTHORIZATION LEVEL FOR

                    SAS messages:
                    - THE MACRO ***** COMPLETED COMPILATION WITHOUT (E)RRORS
                    - YOUR SYS-TEM IS SCHEDULED TO EXPIRE ON
                    - (E)RROR(S) PRINTED ON PAGE

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
        2010-06-07  CAS     Revised logic to correctly check output data set when
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
                            to the Log data set.
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
        2010-11-15  CAS     Reduced the number of macro variables by using the COUNTW
                            function instead of an iterative macro loop and by
                            by making most iteration variable the same variable.
        2010-11-15  CAS     Added section numbers for easier reading and revision.
        2010-11-15  CAS     Added an option to exclude phrases from a data set
                            containing multiple phrases (e.g., from a previous check).
        2010-12-30  CAS     Added a feature to play a sound to communicate results.
        2011-04-15  CAS     Added new argument for the extension to search for when
                            searching a directory for logs, defaulted to LOG.
        2011-04-25  CAS     Recalled that COUNTW is not available in SAS 9.1.3, so
                            I created a sub-macro of the same name to use to
                            dynamically choose the COUNTW function or a sub-process
                            that does the same thing.
        2011-04-25  CAS     Added additional information to the output email in case
                            the user needs to re-run the CheckLog macro in SAS.
        2011-05-12  CAS     Changed the categories of some of the issue statements and
                            updated documentation above.
        2011-05-16  CAS     Added issue regarding the meaning of and identifier after
                            quoted text. See Samples section of sas.cswenson.com for
                            an example.
        2011-05-16  CAS     Added excluded phrase regarding SAS license expiration.
                            This has nothing to do with the successful functioning
                            of the code.
        2011-05-16  CAS     Added exclusion for EXT= option when outputting the line
                            regarding replicating the CheckLog macro in the output
                            email.
        2011-05-16  CAS     Added exclusion for batch job message, which can be
                            misleading, especially if a user uses the - after the
                            issue word to hide if from being output in the log.
        2011-05-17  CAS     Added a new output macro variable called ISSUES, which
                            contains the number of issues detected in the log, 1 when
                            an issue occurs with using the macro (e.g., (i)nvalid
                            argument), or 0 when there are no issues. This can help
                            when writing dynamic code to continue or end depending
                            on whether issues are detected. Updated the documentation
                            above, using '%if &ISSUES>0 %then %return;' instead for
                            aborting macro programs.
        2011-06-01  CAS     Added exclusion for default OUT= option for email.
        2011-06-29  CAS     Revised how test and summary mode are handled in the macro
                            logic in the section where the various output data sets
                            are created.
        2011-06-29  CAS     Added new argument to add the directory and extension to
                            the output when checking a directory of logs, with the
                            default set to No. Set DIREXT=Y to add the directory and
                            extension to the LOGS_W_ISSUES data set.
        2011-07-14  CAS     Added the DIRDLM variable to switch the directory
                            delimiter in other operating systems.
        2011-07-14  CAS     Added a step to identify the type of log argument
                            specified (blank, log, directory).
        2011-07-14  CAS     Replaced SAS_EXECFILEPATH with LOG option during batch
                            mode to identify the location of the log.
        2011-07-14  CAS     Removed the PIPE method of accessing the directory in
                            favor of native SAS code.
        2011-07-15  CAS     Changed the way issues are handled after importing a log
                            to output more specific issue messages.
        2011-07-15  CAS     Excluded SYMBOLGEN messages from the checks.
        2011-07-15  CAS     Added checks for valid output names during directory mode.
        2011-07-15  CAS     Added RELOG argument to overwrite the current log with the
                            imported log. Also added it to the email sent.
        2011-07-15  CAS     Modified reporting in directory mode to use the original
                            filename.
        2011-07-15  CAS     Removed the upper-case function on the LogText variable
                            and instead applied the function during comparison. The
                            result is that the log looks like the original.
        2011-07-18  CAS     Removed delimiters on the import in favor of simpler code.
        2011-07-19  CAS     Added format for filename to avoid truncation.
        2011-07-20  CAS     Upgraded the macro to version 3. (Note: Version 2 was when
                            I added email capabilities and some other features.)
        2011-08-08  CAS     Corrected operating system macro variable reference.
        2011-08-09  CAS     Added exclusion for (e)rorrs= option and for (e)rror and
                            (w)arning options in PROC COMPARE.
        2011-08-15  CAS     Set the log exclusion messages to upper case.
        2011-09-01  CAS     Added another value for the RELOG argument: E - to
                            overwrite the log with the imported log only when issues
                            occur.
        2011-09-01  CAS     Moved section that drops tables to the first section in
                            order to avoid confusion when tables already exist. Also
                            revised RELOG section to only execute when the LOG data
                            set exists.
        2011-09-09  CAS     Added a new argument, SHADOW=, which forces CheckLog to
                            make a copy of the log before importing it. This helps
                            when another instance of SAS is still generating the log,
                            and it would cause problems to directly import it.
        2011-09-09  CAS     Added "else" to if/then section for processing messages.
                            This should help speed up really big logs.
        2011-10-07  CAS     Modified section that checks what type of log is specified
                            to work with shadow mode (copying the file first).
        2011-10-19  CAS     Moved the code to drop pre-existing tables again due to
                            macro variable issues. This code appears to be difficult to
                            find a place for.
        2011-11-23  CAS     Modified behavior during directory mode to ignore blank
                            files. This allows the search to continue with other files.
        2012-02-24  CAS     Set SHADOW=Y by default. This should result in better
                            processing at all times and not interfere when it really
                            is not necessary.

        YYYY-MM-DD  III     Please use this format and insert new entries above.

     *********************************************************************************
       END MACRO HEADER
     *********************************************************************************/


    /* The following line tricks the editor into thinking the macro has ended,
       allowing readers to see the rest of the code in the usual SAS colors. */
    %macro dummy; %mend dummy;


    /********************************************************************************
       Section 1: Log Settings
     ********************************************************************************/

    /* Turn off mprint, notes, and the log */
    %if %lowcase(&TEST) ne test %then %do;

        /* Obtain option and temporarily turn off */
        %local user_mprint user_notes;
        %let user_mprint=%sysfunc(getoption(mprint));
        %let user_notes=%sysfunc(getoption(notes));
        option nomprint;
        option nonotes;

        /* Completely turn off these options */
        /* REVISION 2010-10-13 CAS: Tweaked the options turned off */
        option nomlogic nosymbolgen nomacrogen;

        /* Temporarily turn the log off */
        filename junk dummy;
        proc printto log=junk; run;

    %end;


    /********************************************************************************
       Section 2: Macro Variables
     ********************************************************************************/

    /* Manage macro variable scope */
    /* REVISION 2010-08-06 CAS: Added scope for variables used with KEYWORD argument */
    %global
        logmsg                  /* Log issues message */
        issues                  /* Count of issues in log */
    ;
    %local
        _EFIERR_                /* (E)RROR detection macro (indirect reference) */
        ervar                   /* (E)RROR variable for import (indirect reference) */
        key_wrd                 /* Variable used to store scan of KEYWORD argument */
        iss1 iss2 iss3 iss4     /* Issue word variables */
        log_init                /* Initial log argument */
        logcount                /* Count of logs to check*/
        lognumber               /* Index variable used to check multiple logs */
        logsummary              /* Flag to summarize multiple logs */
        msg                     /* Pop-up message */
        multi                   /* Multiple-log flag */
        outobs                  /* Record count of output */
        i                       /* Iteration variable */
        excludeds               /* Data set that contains phrases to exclude */
        excludevar              /* Variable in exclude data set that contains phrases */
        dirdlm                  /* Variable to set the directory delimiter */
        filedir                 /* Retains type of log specified */
        copylog                 /* Path and filename of the copied log (shadow mode */
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
    %let log_init=%superq(LOG);

    /* List of words to check */
    /* Note: These are listed here to avoid writing them to the log upon inclusion
       of the macro program. */
    %let iss1=%str(E)RROR;
    %let iss2=%str(W)ARNING;
    %let iss3=%str(I)NVALID;
    %let iss4=%str(U)NINITIALIZED;

    /* Determine the directory delimiter */
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

    /* Log Type */
    /* Determine if argument is a directory or a file */
    /* REVISION 2011-07-14 CAS: Added the following section to check log type */
    /* REVISION 2011-07-18 CAS: Promoted section to Macro Variables */
    /* REVISION 2011-10-07 CAS: Modified the process of checking the log type */
    %if %superq(LOG)=%str() %then %let FILEDIR=BLANK;
    %else %do;

        %local fileref file id rc;

        /* Check that the file or directory exists */
        /* REVISION 2011-10-07 CAS: Added check to see if the file exists */
        %if %sysfunc(fileexist(%superq(LOG)))=0 %then %do;
            %let msg=The specified file/directory does not exist.;
            %let logmsg=%str(E)RROR: &MSG;
            %let issues=1;
            %goto exit;
        %end;

        /* Attempt to assign a fileref */
        %let fileref=fileref;
        %let file=%sysfunc(filename(FILEREF, %superq(LOG)));
        %if &FILE ne 0 %then %do;
            %let msg=Filename association during check of directory/file status failed.;
            %let logmsg=%str(E)RROR: &MSG;
            %let issues=1;
            %goto exit;
        %end;

        /* Attempt to open fileref as a directory */
        %let id=%sysfunc(dopen(FILEREF));
        %if &ID ne 0 %then %do;
            %let rc=%sysfunc(dclose(&ID));
            %let FILEDIR=DIR;
        %end;

        /* Otherwise, assume it is a file, especially since it exists and is not
           a directory. */
        %else %let FILEDIR=FILE;

        %let file=%sysfunc(filename(FILEREF));
        %symdel fileref file id rc / nowarn;

        /*%if &FILEDIR=NA %then %do;*/
        /*    %let msg=%str(I)nvalid log specified.;*/
        /*    %let logmsg=%str(E)RROR: &MSG;*/
        /*    %let issues=1;*/
        /*    %goto exit;*/
        /*%end;*/

    %end;


    /********************************************************************************
       Section 3: Check Arguments
     ********************************************************************************/

    /* Drop the log and output if they exist */
    /* REVISION 2010-05-06 CAS: Added logs_w_issues to drop */
    /* REVISION 2011-09-01 CAS: Moved to first section */
    /* REVISION 2011-09-09 CAS: Set to be mode dependent for some tables */
    /* REVISION 2011-10-19 CAS: Moved the drop code again to avoid macro variable issues */
    proc sql;
    %if %sysfunc(exist(log)) %then %do;
        drop table log;
    %end;
    %if %sysfunc(exist(&OUT)) %then %do;
        drop table &OUT;
    %end;
    %if %sysfunc(exist(log_keywords)) and %lowcase(&TEST)=test %then %do;
        drop table log_keywords;
    %end;
    %if %sysfunc(exist(logs_w_issues)) and %superq(LOG)=%str() %then %do;
        drop table logs_w_issues;
    %end;
    %if %sysfunc(exist(log_summary)) %then %do;
        drop table log_summary;
    %end;
    quit;

    /* Check for the existence of the tables in case they could not be dropped */
    /* REVISION 2010-04-01 CAS: Added step to identify when a table is open. */
    %if %sysfunc(exist(log)) or %sysfunc(exist(&OUT)) %then %do;
        %let msg=The log and/or &OUT table could not be dropped. Check whether either table is open.;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;
    %end;

    /* REVISION 2010-05-21 CAS: Added the following checks of the arguments */

    /* Modify arguments */
    /* Note: These are modified to avoid using upcase and lowcase repeatedly */
    /* REVISION 2010-08-06 CAS: Added a new argument: keyword */
    /* REVISION 2010-12-30 CAS: Added a new argument: sound */
    /* REVISION 2011-04-15 CAS: Added a new argument: ext */
    /* REVISION 2011-09-09 CAS: Added a new argument: shadow */
    %let pm=%substr(%upcase(&PM), 1, 1);
    %let sound=%substr(%upcase(&SOUND), 1, 1);
    %let keyword=%upcase(%superq(KEYWORD));
    %let abort=%substr(%upcase(&ABORT), 1, 1);
    %let test=%lowcase(&TEST);
    %let ext=%upcase(&EXT);
    %let dirext=%substr(%upcase(&DIREXT), 1, 1);
    %let relog=%substr(%upcase(&RELOG), 1, 1);
    %let shadow=%substr(%upcase(&SHADOW), 1, 1);

    /* OUT */
    %if %index(*0*1*2*3*4*5*6*7*8*9*, *%substr(&OUT, 1, 1)*) ne 0 %then %do;

        %let msg=%str(I)nvalid value for the OUT argument. Use a data set name beginning with a non-numeric character.;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;

    %end;

    %if %length(&OUT)>32 %then %do;

        %let msg=%str(I)nvalid value for the OUT argument. Use a data set name less than 32 characters.;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;

    %end;

    /* PM */
    /* Note: Checks for Y (Yes), N (No), and E ([E]rror only) */
    %if "&PM" ne "" and %index(*Y*N*E*,*&PM*)=0 %then %do;

        %let msg=%str(I)nvalid value for the PM argument. Use Y (Yes), N (No), or E (%str(E)rror only).;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;

    %end;

    /* DIREXT */
    /* Note: Checks for Y (Yes) and N (No) */
    %if %index(*Y*N*,*&DIREXT*)=0 %then %do;

        %let msg=%str(I)nvalid argument specified for DIREXT. Use Y (Yes) or N (No).;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;

    %end;

    /* ABORT */
    /* Note: Checks for Y (Yes) and N (No) */
    %if "&ABORT" ne "" and %index(*Y*N*,*&ABORT*)=0 %then %do;

        %let msg=%str(I)nvalid value for the ABORT argument. Use Y (Yes) or N (No).;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;

    %end;

    /* RELOG */
    /* Check for argument values in (Y N) */
    /* REVISION 2011-08-18 CAS: Added the following check */
    /* REVISION 2011-09-01 CAS: Added new value for RELOG and corrected check */
    %if %index(*Y*N*E*,*&RELOG*)=0 %then %do;

        %let msg=%str(I)nvalid argument specified for RELOG. Use Y (Yes), N (No), or E (%str(E)rror only).;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;

    %end;

    /* Shadow */
    /* REVISION 2011-09-09 CAS: Added check for new argument */
    %if %index(*Y*N*,*&SHADOW*)=0 %then %do;

        %let msg=%str(I)nvalid argument specified for SHADOW. Use Y (Yes) or N (No).;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;

    %end;

    /* EXCLUDE */
    /* REVISION 2010-11-15 CAS: Added EXCLUDE processing */
    %if %superq(EXCLUDE) ne %str() %then %do;

        /* Check for data set options by looking for parentheses */
        %if "%sysfunc( compress( %superq(EXCLUDE), %str(%(), %str(k) ) )" ne "" %then %do;

            /* Define length and location of last end parenthesis */
            %local excludelen excludepar;
            %let excludelen=%length(%superq(EXCLUDE));
            %let excludepar=%sysfunc( findc( %superq(EXCLUDE), %str(%)), , -%length(%superq(EXCLUDE)) ) );

            %let excludeds=%substr(%superq(EXCLUDE), 1, &EXCLUDEPAR);

            /* If the length of the argument is the same as the position of the last
               parenthesis, then no variable is specified so set it to the default */
            %if &EXCLUDELEN=&EXCLUDEPAR %then %let excludevar=LOGTEXT;

            /* Otherwise, find the next word after the parenthesis */
            %else %let excludevar=%substr(%superq(EXCLUDE), %eval(&EXCLUDEPAR+1), %eval(&EXCLUDELEN-&EXCLUDEPAR));

        %end;

        /* Otherwise, simply scan the argument for the parts */
        %else %do;
            %let excludeds=%scan(%superq(EXCLUDE), 1, %str( ));
            %let excludevar=%scan(%superq(EXCLUDE), -1, %str( ));
        %end;

        /* Check if the variable is blank or the same, change to default */
        %if "&EXCLUDEVAR"="" or %superq(EXCLUDEDS)=%superq(EXCLUDEVAR) %then %let excludevar=LOGTEXT;

        %put ;
        %put NOTE: Exclude Data Set: %superq(EXCLUDEDS);
        %put NOTE: Exclude Variable: &EXCLUDEVAR;
        %put ;

        /* Check if the data set exists */
        %if %sysfunc(exist( %scan(%superq(EXCLUDE), 1, %str( %()) ))=0 %then %do;

            %let msg=The specified data set for the EXCLUDE argument does not exist.;
            %let logmsg=%str(E)RROR: &MSG;
            %let issues=1;
            %goto exit;

        %end;

        /* Check if variable exists */
        %local open varnum close;
        %let open=%sysfunc(open(%scan(%superq(EXCLUDE), 1, %str( %())));
        %let varnum=%sysfunc(varnum(&OPEN, &EXCLUDEVAR));
        %let close=%sysfunc(close(&OPEN));
        %if &VARNUM=0 %then %do;

            %let msg=The specified variable &EXCLUDEVAR in the data set %scan(%superq(EXCLUDE), 1, %str( %()) does not exist.;
            %let logmsg=%str(E)RROR: &MSG;
            %let issues=1;
            %goto exit;

        %end;

        /* Set variables */
        /* REVISION 2011-08-15 CAS: Set exclusion messages to upper case */
        %else %do;

            data _null_;
                set &EXCLUDEDS end=end;
                if missing(&EXCLUDEVAR) then delete;
                call symputx(compress('exclude' || put(_n_, 8.)), upcase(&EXCLUDEVAR), 'l');
                if end then call symputx('excludecnt', put(_n_, 8.));
            run;

        %end;

    %end;


    /********************************************************************************
       Section 4: Internal Macro Programs
     ********************************************************************************/

    /* CheckLog NOBS macro: Returns the number of records in a SAS table. */
    %macro CLNOBS(dsn) / des='Copy of NOBS macro for CheckLog macro';

        /* Define these variables locally */
        %local dsid anobs rc;

        /* Check if the table exists */
        %if %sysfunc(exist(&DSN))=0 %then %do;
            %put %str(W)ARNING: %sysfunc(compbl(The &DSN data set does not exist)).;
            %let num=;
        %end;
        %else %do;

            /* Open the data set */
            %let dsid=%sysfunc(open(&DSN));

            /* Check to see if SAS can obtain the observations */
            %let anobs=%sysfunc(attrn(&DSID, anobs));
            %if &ANOBS=0 %then %do;
                %put %str(W)ARNING: The macro NOBS is unable to obtain the number of observations from this engine (e.g., Oracle, Sybase).;
            %end;

            /* ATTRN will not work correctly against Sybase and Oracle tables */
            %let num=%sysfunc(attrn(&DSID, nobs));

            /* Close the data set */
            %let rc=%sysfunc(close(&DSID));

        %end;

        /* Lack of semi-colon makes this value the output from this macro. */
        &NUM

    %mend CLNOBS;

    %macro COUNTW(args, dlm) / des='Uses COUNTW in SAS 9.2+, alternative in prior versions';

        %if %substr(&SYSVER, 1, 3)=9.1 %then %do;

            %local countw arg;
            %let countw=1;
            %let arg=%scan(%superq(ARGS), &COUNTW, &DLM);

            %do %while("&ARG" ne "");
                %let countw=%eval(&COUNTW+1);
                %let arg=%scan(&ARGS, &COUNTW, &DLM);
            %end;

            %let countw=%eval(&countw-1);

            &COUNTW

        %end;
        %else %do;
            %sysfunc(countw(&ARGS, &DLM))
        %end;

    %mend COUNTW;


    /********************************************************************************
       Section 5: Determine Log(s) to Check
     ********************************************************************************/

    /***** Section 5a: Current Log *****/
    /* Save the current log in the work directory */
    /* REVISION 2010-10-01 CAS: Modified behavior in batch mode */
    %if &FILEDIR=BLANK %then %do;

        /* Obtain the work directory */
        /* REVISION 2010-09-03 CAS: Revised log_init variable */
        %let log=%sysfunc(pathname(work))&DIRDLM.Work.log;
        %let log_init=Work.log;

        /* Delete the log if it already exists */
        %if %sysfunc(fileexist(%superq(LOG)))=1 %then %do;

            filename log "%superq(LOG)";

            %local fd;
            %let fd=%sysfunc(fdelete(log));

            %if &FD ne 0 %then %do;
                %let msg=Unable to delete the log prior to exporting the current log.;
                %let logmsg=%str(E)RROR: &MSG;
                %let issues=1;
                %goto exit;
            %end;

            filename log clear;

        %end;

        /* Output log from window */
        dm log "file %bquote(')%superq(LOG)%bquote(') replace;" wpgm;

        /* If the log does not exist, assume batch mode and try copying log to work */
        /* REVISION 2010-10-18 CAS: Revised name of work log for batch mode */
        %if %sysfunc(fileexist(%superq(LOG)))=0 %then %do;

            %local batchlog user_xsync user_xwait;

            /* Obtain name for batch log */
            /* REVISION 2011-07-14 CAS: Replaced SAS_EXECFILEPATH with LOG option */
            /* REVISION 2011-07-18 CAS: Changed the order of the process. */
            %let batchlog=%sysfunc(getoption(log));
            %if "%superq(BATCHLOG)"="" %then %do;
                %let batchlog=%sysfunc(getoption(SYSIN));
                %let batchlog=%substr(%superq(BATCHLOG), 1, %length(%superq(BATCHLOG))-4).log;
            %end;

            /* Set name for copied log */
            %let log=%sysfunc(pathname(work))&DIRDLM.%scan(%superq(BATCHLOG), -1, &DIRDLM.);
            %let log_init=%superq(BATCHLOG);

            /* Temporarily modify options */
            %let user_xsync=%sysfunc(getoption(xsync));
            %let user_xwait=%sysfunc(getoption(xwait));
            options xsync noxwait;

            /* Copy batch log to work */
            /* Windows */
            %if %upcase("&SYSSCP")="WIN" %then %do;
                %sysexec copy "%superq(BATCHLOG)" "%superq(LOG)";
            %end;
            /* z/OS */
            /* REVISION 2011-08-08 CAS: Not sure if the $ is needed in z/OS */
            %else %if %upcase("&SYSSCP")="OS" %then %do;
                %sysexec copy "%superq(BATCHLOG)" "%superq(LOG)";
                %if %sysfunc(fileexist(%superq(LOG)))=0 %then %do;
                    %sysexec $ copy "%superq(BATCHLOG)" "%superq(LOG)";
                %end;
            %end;
            /* OpenVMS */
            %else %if %upcase("&SYSSCPL")="OPENVMS" %then %do;
                %sysexec copy "%superq(BATCHLOG)" "%superq(LOG)";
            %end;
            /* Unix */
            %else %if %index(*AIX*HP-UX*LINUX*OSF1*SUNOS*,%upcase(*&SYSSCPL*))>0
            %then %do;
                %sysexec cp "%superq(BATCHLOG)" "%superq(LOG)";
            %end;

            /* Restore options */
            options &USER_XSYNC &USER_XWAIT;

        %end;

        /* If all else fails, quit the macro */
        %if %sysfunc(fileexist(%superq(LOG)))=0 %then %do;

            %let msg=Unable to export the log.;
            %let logmsg=%str(E)RROR: &MSG;
            %let issues=1;
            %goto exit;

        %end;

    %end;

    /***** Section 5b: Single Log *****/
    /* Check for a dot signifying a file and a slash signifying a directory */
    /* REVISION 2010-05-06 CAS: Added another requirement to enter this loop: a slash */
    %else %if &FILEDIR=FILE %then %do;

        /* Check that the directory exists */
        /* Note: The following functions remove the file from the directory to
           check if the directory exists. */
        %if %sysfunc(fileexist( %substr(%superq(LOG), 1, %eval( %length(%superq(LOG)) - %length( %scan(%superq(LOG), -1, &DIRDLM.) ) )) ))=0
        %then %do;

            %let msg=The specified directory does not exist.;
            %let logmsg=%str(E)RROR: &MSG;
            %let issues=1;
            %goto exit;

        %end;

        /* Check that the log exists */
        %if %sysfunc(fileexist(%superq(LOG)))=0 %then %do;

            %let msg=The specified log does not exist.;
            %let logmsg=%str(E)RROR: &MSG;
            %let issues=1;
            %goto exit;

        %end;

    %end;

    /***** Section 5c: Multiple Logs *****/
    /* Check that the directory exists */
    %else %if &FILEDIR=DIR %then %do;

        /* Add extra slash if necessary */
        %if %qsubstr(&LOG, %length(&LOG), 1) ne %superq(DIRDLM) %then %do;
            %let log=%superq(LOG)&DIRDLM.;
            %let log_init=%superq(LOG);
        %end;

        /* REVISION 2011-07-14 CAS: Begin Revision */
        /* REVISION 2011-07-19 CAS: Added format for filename to avoid truncation */
        data _DirList_;
            format Filename $1000.;
            %local filrf rc did memcnt i name;

            %let filrf=mydir;

            /* Assigns the fileref of mydir to the directory and opens the directory */
            %let rc=%sysfunc(filename(filrf,%superq(LOG)));
            %let did=%sysfunc(dopen(&filrf));

            /* Returns the number of members in the directory */
            %let memcnt=%sysfunc(dnum(&did));

            /* Loops through entire directory */
            %do i=1 %to &memcnt;

                /* Returns the extension from each file */
                %let name=%qscan(%qsysfunc(dread(&DID, &I)),-1,.);

                /* Checks to see if file contains an extension */
                %if %qupcase(%qsysfunc(dread(&DID, &I))) ne %qupcase(&NAME) %then %do;

                    /* Checks to see if the extension matches the parameter value */
                    /* If condition is true prints the full name to the log       */
                    %if (%superq(ext) ne %str() and %qupcase(&NAME) eq %qupcase(&EXT))
                     or (%superq(ext) eq %str() and %superq(name)   ne %str())
                    %then %do;
                        filename="%qsysfunc(dread(&DID, &I))";
                        output;
                    %end;

                %end;

            %end;

            /* Closes the directory */
            %let rc=%sysfunc(dclose(&DID));

            %symdel filrf rc did memcnt i name / nowarn;
        run;

        /* REVISION 2011-07-15 CAS: Added steps to correct for (i)nvalid SAS data set names */
        data _dirlist_(drop=repeat);
            format log $1000. out $30.;
            retain repeat 0 log;

            set _dirlist_;

            if index(upcase(filename), ".&EXT");

            filename=strip(filename);

            log=compbl(cats("%superq(LOG)", filename));

            /* Set output data set name */
            out=strip(trim(scan(filename, -2, '.')));

            /* Check for names starting with numbers */
            if compress(substr(out, 1, 1), '', 'kd') ne ''
            then out='N'||out;

            /* Remove special characters */
            if find(strip(out), ' ')>0 then out=tranwrd(strip(out), ' ', '_');
            if find(strip(out), '-')>0 then out=tranwrd(strip(out), '-', '_');
            if compress(strip(out), '_', 'kda') ne ''
            then out=compress(strip(out), '_', 'kda');

            /* Check for names that are too long */
            if length(out) ge 30 then do;
                repeat+1;
                out=compress(substr(out, 1, 25) || "_I" || put(repeat, 8.));
            end;

            substr(out,1,1)=upcase(substr(out,1,1));
        run;
        /* REVISION 2011-07-14 CAS: End Revision */

        /* If the directory listing was succesful, set log count and multi flag */
        %if %clnobs(_dirlist_) ge 1 %then %do;

            %let logcount=%eval(%clnobs(_dirlist_)+1);
            %let multi=1;

        %end;
        %else %do;

            %let msg=The directory does not contain logs.;
            %let logmsg=%str(E)RROR: &MSG;
            %let issues=1;

            proc sql;
                drop table _dirlist_;
            quit;

            %goto exit;

        %end;

    %end;

    /***** Section 5d: (I)nvalid Arguments *****/
    /* Otherwise, exit */
    /* REVISION 2010-05-06 CAS: Added more detail to the (e)rror messages */
    %else %if %index(%superq(LOG), %str(.))>0 %then %do;

        %let msg=Please specify a directory with the filename.;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;

    %end;

    %else %if %index(%superq(LOG), &DIRDLM.)>0 %then %do;

        %let msg=The directory does not exist.;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;

    %end;

    %else %do;

        %let msg=The log argument was %str(i)nvalid.;
        %let logmsg=%str(E)RROR: &MSG;
        %let issues=1;
        %goto exit;

    %end;


    /********************************************************************************
       Section 6: Import and Check Log(s)
     ********************************************************************************/

    /* Beginning of log processing loop */
    /* REVISION 2011-06-29 CAS: Revised how LOGS_W_ISSUES data set is populated */
    /* REVISION 2011-07-15 CAS: Created LOGFILE macro variable for directory reporting */
    %do lognumber=1 %to &LOGCOUNT;

        /* Process multiple logs */
        %if &MULTI=1 %then %do;

            /* Set each log and output */
            %if &LOGNUMBER<&LOGCOUNT %then %do;

                data _null_;
                    set _dirlist_(firstobs=&LOGNUMBER obs=&LOGNUMBER);
                    call symput('log', compbl(log));
                    call symputx('out', out);
                    call symputx('logfile', filename, 'L');
                run;

            %end;

            /* At the end, export the current log to display list of logs with
               issues for easier review. */
            %else %if &LOGNUMBER=&LOGCOUNT %then %do;

                /* Obtain the work directory */
                %let log=%sysfunc(pathname(work))&DIRDLM.Work.log;

                /* Output log */
                /*dm log "file %bquote(')%superq(LOG)%bquote(') replace;" wpgm;*/

                /* Reset variables */
                %let out=Logs_w_issues;
                %let multi=0;
                %let logsummary=1;

                /* Drop directory listing table */
                %if &TEST ne test %then %do;
                    proc sql;
                        drop table _dirlist_;
                    quit;
                %end;

            %end;

        %end;


        /********************************************************************************
           Section 6a: Import Log
         ********************************************************************************/

        /* Make a copy first, if specified */
        /* Note: The current log or batch mode are already copies */
        /* REVISION 2011-09-09 CAS: Added shadow process */
        %if &SHADOW=Y and &FILEDIR ne BLANK %then %do;

            %local user_xsync user_xwait;

            /* Temporarily modify options */
            %let user_xsync=%sysfunc(getoption(xsync));
            %let user_xwait=%sysfunc(getoption(xwait));
            options xsync noxwait;

            /* Set name for copied log */
            %let copylog=%sysfunc(pathname(work))&DIRDLM.%scan(%superq(LOG), -1, &DIRDLM.);

            /* Windows */
            %if %upcase("&SYSSCP")="WIN" %then %do;
                %sysexec copy "%superq(LOG)" "%superq(COPYLOG)";
            %end;
            /* z/OS */
            /* REVISION 2011-08-08 CAS: Not sure if the $ is needed in z/OS */
            %else %if %upcase("&SYSSCP")="OS" %then %do;
                %sysexec copy "%superq(LOG)" "%superq(COPYLOG)";
                %if %sysfunc(fileexist(%superq(COPYLOG)))=0 %then %do;
                    %sysexec $ copy "%superq(LOG)" "%superq(COPYLOG)";
                %end;
            %end;
            /* OpenVMS */
            %else %if %upcase("&SYSSCPL")="OPENVMS" %then %do;
                %sysexec copy "%superq(LOG)" "%superq(COPYLOG)";
            %end;
            /* Unix */
            %else %if %index(*AIX*HP-UX*LINUX*OSF1*SUNOS*,%upcase(*&SYSSCPL*))>0
            %then %do;
                %sysexec cp "%superq(LOG)" "%superq(COPYLOG)";
            %end;

            /* Restore options */
            options &USER_XSYNC &USER_XWAIT;

        %end;

        %let _EFIERR_=0;
        %let ervar=%str(_E)RROR_;
        data Log;
            format LogLine 20.;

            /* Import the log without delimiting into columns */
            /* REVISION 2010-10-25 CAS: Expanded the delimiter to be even more unlikely,
               using a string instead of a single character for version 9.2. */
            /* REVISION 2010-10-27 CAS: Masked the delimiters using the STR function. */
            /* REVISION 2011-07-18 CAS: Removed delimiters in favor of simpler code. */
        %if &SHADOW=Y and &FILEDIR ne BLANK %then %do;
            infile "%sysfunc(compbl(%superq(COPYLOG)))" length=linelength lrecl=32767;
        %end;
        %else %do;
            infile "%sysfunc(compbl(%superq(LOG)))" length=linelength lrecl=32767;
        %end;

            informat LogText $1000.;
            format LogText $1000.;
            input LogText $varying1000. linelength;

            /* Format the log text */
            LogText=compbl(strip(LogText));

            /* Set line number for each log line and upcase the log text */
            LogLine=_n_;

            /* set (E)RROR detection macro variable */
            /* REVISION 2010-06-03 CAS: Corrected the symput to avoid conversion */
            if &ERVAR then call symputx('_EFIERR_','1');
        run;

        %if &SHADOW=Y and &FILEDIR ne BLANK %then %do;
            filename copylog "%superq(COPYLOG)";
            %local fd;
            %let fd=%sysfunc(fdelete(COPYLOG));
            filename copylog clear;
        %end;

        /* REVISION 2010-04-06 CAS: Added step to check for issues on log import */
        /* REVISION 2010-04-21 CAS: Added step to check if the log is empty or the system
           encountered an issue. */
        /* REVISION 2011-07-15 CAS: Split statements to make more sense of issues. */
        /* REVISION 2011-11-23 CAS: Modified behavior during directory mode */
        %if &_EFIERR_=1 %then %do;

            %let msg=Record %str(e)rrors were encountered during import.;
            %let logmsg=%str(E)RROR: &MSG;
            %let issues=1;
            %goto exit;

        %end;
        %else %if &SYSERR>3 %then %do;

            %let msg=System %str(e)rrors were encountered during import.;
            %let logmsg=%str(E)RROR: &MSG;
            %let issues=1;
            %goto exit;

        %end;
        %else %if %clnobs(log)=0 and &FILEDIR ne DIR %then %do;

            %let msg=No record found in the imported file.;
            %let logmsg=%str(E)RROR: &MSG;
            %let issues=1;
            %goto exit;

        %end;


        /********************************************************************************
           Section 6b: Check Log
         ********************************************************************************/

        /* REVISIONS: Changed the order of the output to allow opening of final output
           rather than the keywords output (2010-08-06). Added Ignore and Found variables
           to Log data set (2010-08-06). Revised how test and summary mode are handled in
           the macro logic (2011-06-29). */
        data
        %if %eval(&MULTI + &LOGSUMMARY + 0)=0 %then %do;
            Log
        %end;
        %if &TEST=test %then %do;
            Log_keywords
        %end;
            &OUT
        %if &LOGSUMMARY=1 %then %do;
            (drop=ignore logline found rename=(LogText=Logs))
        %end;
        %else %if &TEST ne test %then %do;
            (drop=ignore)
        %end;
        ;
            set log;
            format Ignore 8. Found $30.;
            Ignore=0;


            /***** Section 6b1: Identify Issues *****/

            /* User-specified Issue Words */
            /* Loop through each argument in KEYWORD */
            /* REVISION 2010-08-06 CAS: Added use of KEYWORD argument */
            /* REVISION 2010-11-15 CAS: Moved scan of keywords to this location */
    %if %superq(KEYWORD) ne %str() %then %do;

        %do i=%countw(%superq(KEYWORD), %str( )) %to 1 %by -1;

            %local key_wrd&I;
            %let key_wrd&I=%scan(%superq(KEYWORD), &I, %str( ));
            if find(LogText, "&&KEY_WRD&I")>0 then Found="&&KEY_WRD&I";

        %end;

    %end;

            /* Issue Words */
            if find(upcase(LogText), "&ISS1")>0 then Found="&ISS1";
            else if find(upcase(LogText), "&ISS2")>0 then Found="&ISS2";
            else if find(upcase(LogText), "&ISS3")>0 then Found="&ISS3";
            else if find(upcase(LogText), "&ISS4")>0 then Found="&ISS4";

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
            2011-05-12  CAS     Updated the categories of some statements.
            2011-05-16  CAS     Added a new phrase regarding spacing.

            YYYY-MM-DD  III     Please use this format and insert new entries above

            */
            else if find(upcase(LogText), "CHARACTER VALUES HAVE BEEN CONV"||"ERTED TO NUMERIC VALUES")>0 then Found="CONVERSION";
            else if find(upcase(LogText), "NUMERIC VALUES HAVE BEEN CONV"||"ERTED TO CHARACTER VALUES")>0 then Found="CONVERSION";
            else if find(upcase(LogText), "AT LEAST ONE W.D FOR"||"MAT")>0 then found="FORMAT";
            else if find(upcase(LogText), "NEW LI"||"NE WHEN INPUT")>0 then found="INPUT";
            else if find(upcase(LogText), "NOTE: LOST CA"||"RD")>0 then found="INPUT";
            else if find(upcase(LogText), "ONE OR MORE LINES WERE TRUNC"||"ATED")>0 then found="INPUT";
            else if find(upcase(LogText), "DIVISION BY ZE"||"RO DETECTED")>0 then found="MATH";
            else if find(upcase(LogText), "MATHEMATICAL OPER"||"ATIONS COULD NOT BE PERFORMED")>0 then found="MATH";
            else if find(upcase(LogText), "MIS"||"SING VALUES WERE GENERATED")>0 then found="MATH";
            else if find(upcase(LogText), "MER"||"GE STATEMENT HAS MORE THAN ONE DATA SET WITH RE"||"PEATS OF BY VALUES")>0 then found="MERGE";
            else if find(upcase(LogText), "THE EXECUTION OF THIS QUERY INVOLVES PERFORMING ONE OR MORE CART"||"ESIAN PRODUCT JOINS THAT CAN NOT BE OPTIMIZED.")>0 then found="SQL";
            else if find(upcase(LogText), "THE QUERY REQUIRES RE"||"MERGING SUMMARY STATISTICS BACK WITH THE ORIGINAL DATA")>0 then Found="SQL";
            else if find(upcase(LogText), "A CASE EXPRE"||"SSION HAS NO ELSE CLAUSE")>0 then found="SYNTAX";
            else if find(upcase(LogText), "THE MEANING OF AN IDENT"||"IFIER AFTER A QUOTED STRING MAY CHANGE")>0 then found="SYNTAX";

            /***** Section 6b2: Ignored Phrases *****/
            /* REVISIONS: Added exclusions for _ISSUE1_=0, which can be output for
               normal data (2010-05-10). Removed concept of ignoring line following
               the issue (2010-06-21). Added the KEYWORD=KEYWORD phrase to ignore
               (2010-08-06). Combined check for keyword exclusions and added exclusion
               for the other comment style (2010-08-06). Added exclusion for macro
               compilation note (2010-09-01). Added exclusions specified by the user
               (2010-11-15). Added exclusion for system expiration (2011-05-16).
               Added exclusion for batch job message (2011-05-16). Added exclusion for
               SYMBOLGEN (2011-07-15).
            */
            if not missing(Found) then do;

                if find(upcase(LogText),"THE ACC"||"OUNT IS LOCKED")>0
                or find(upcase(LogText),"UNABLE TO CLEAR OR RE-AS"||"SIGN THE LIBRARY")>0
                or find(upcase(LogText),"USER DOES NOT HAVE AP"||"PROPRIATE AUTHORIZATION LEVEL FOR")>0
                or find(upcase(LogText),"UNABLE TO COPY SAS"||"USER REGISTRY TO WORK REGISTRY")>0
                or find(upcase(LogText),"ONLY AVAILABLE TO USERS WITH RE"||"STRICTED SESSION PRIVILEGE")>0
                or find(upcase(LogText),"ER"||"ROR IN THE LIBNAME STATEMENT")>0
                or find(upcase(LogText),"KEY"||"WORD=%superq(KEYWORD)")>0

                /* Exclude these phrases with keywords included */
                or find(upcase(LogText),"IF _&ISS1._")>0
                or find(upcase(LogText),"_&ISS1._=0")>0
                or find(upcase(LogText),"_&ISS1._ = 0")>0
                or find(upcase(LogText),"SET &ISS1. DET"||"ECTION MACRO")>0
                or find(upcase(LogText),"SET THE &ISS1. DET"||"ECTION MACRO")>0
                or find(upcase(LogText),"WIT"||"HOUT &ISS1.")>0
                or find(upcase(LogText),"&ISS2.: YOUR SYS"||"TEM IS SCHEDULED TO EXPIRE ON")>0
                or find(upcase(LogText),"&ISS1. PRINTED ON PAGE")>0
                or find(upcase(LogText),"&ISS1.S PRINTED ON PAGE")>0
                or find(upcase(LogText),"SYMBOLGEN:")>0

                /* Exclude specified phrases */
        %if %superq(EXCLUDE) ne %str() %then %do;

            %do i=1 %to &EXCLUDECNT;
                or find(upcase(LogText),"%nrbquote(&&EXCLUDE&I)")>0
            %end;

        %end;

                /* Exclude keywords in put statements, comments, quotes, and options */
                /* REVISION 2011-08-09 CAS: Added exclusion for (e)rorrs= option */
                /* REVISION 2011-08-09 CAS: Added exclusion for (e)rror and (w)arning
                   option in PROC COMPARE */
                or prxmatch('/OPTION[|S].*' || "&&ISS1.S=" || '/', upcase(LogText))
                or prxmatch('/PROC\s*COMPARE.*' || "&ISS1." || '/', upcase(LogText))
                or prxmatch('/PROC\s*COMPARE.*' || "&ISS2." || '/', upcase(LogText))

            %do i=1 %to 4;
                or prxmatch('/%PUT.*' || "&&ISS&I" || '.*/', upcase(LogText))
                or prxmatch('/\/\*.*' || "&&ISS&I" || '.*\//', upcase(LogText))
                or prxmatch('/\*.*' || "&&ISS&I" || '.*;/', upcase(LogText))
                or prxmatch('/' || '"' || '.*' || "&&ISS&I" || '.*' ||  '"' || '/', upcase(LogText))
                or prxmatch('/' || "'" || '.*' || "&&ISS&I" || '.*' ||  "'" || '/', upcase(LogText))
            %end;

        %if %superq(KEYWORD) ne %str() %then %do;

            %do i=1 %to %countw(%superq(KEYWORD), %str( ));
                or prxmatch('/%PUT.*' || "&&KEY_WRD&I" || '.*/', upcase(LogText))
                or prxmatch('/\/\*.*' || "&&KEY_WRD&I" || '.*\//', upcase(LogText))
                or prxmatch('/\*.*' || "&&KEY_WRD&I" || '.*;/', upcase(LogText))
                or prxmatch('/' || '"' || '.*' || "&&KEY_WRD&I" || '.*' ||  '"' || '/', upcase(LogText))
                or prxmatch('/' || "'" || '.*' || "&&KEY_WRD&I" || '.*' ||  "'" || '/', upcase(LogText))
            %end;

        %end;

                then Ignore=1;


            /***** Section 6b3: Output *****/
            /* REVISION 2011-06-29 CAS: Added option for adding directory and extension */

            %if &TEST=test %then %do;

                /* Output all key words in test mode */
                output log_keywords;

            %end;

                /* Output only if the record is not flagged to be ignored */
                if Ignore=0 then do;

                %if &LOGSUMMARY=1 %then %do;

                    /* Summarize the logs with issues */
                    if substr(upcase(LogText), 1, 5)="&ISS1" then do;
                        LogText=substr(LogText, 50);
                        LogText=substr(LogText, 1, length(LogText)-1);

                  %if &DIREXT=Y %then %do;
                        LogText="%superq(LOG_INIT)" || LogText;
                  %end;
                    end;
                    else delete;

                %end;

                    output &OUT;

                end;
                /* End of 'Ignore=0' condition */

            end;
            /* End of 'not missing(Flagged)' condition */

        /* Output to the log data set if not a multiple-log review or the log summary. */
        %if %eval(&MULTI + &LOGSUMMARY + 0)=0 %then %do;
            output log;
        %end;

        run;

        /* Check if any issues exist */
        /* REVISION 2011-07-15 CAS: Modified reporting in directory mode. */
        %let outobs=%clnobs(&OUT);
        %if &OUTOBS ge 1 %then %do;

            %if &LOGSUMMARY=0 and &FILEDIR ne DIR %then %do;

                %let msg=There are issues in the log. Please check &OUT..;
                %let logmsg=%str(E)RROR: &MSG;
                %let issues=%clnobs(&OUT);

            %end;
            %else %if &LOGSUMMARY=0 and &FILEDIR=DIR %then %do;

                %if &DIREXT=Y %then %let msg=There are issues in the log. Please check &LOGFILE..;
                %else %let msg=There are issues in the log. Please check &OUT..;
                %let logmsg=%str(E)RROR: &MSG;
                %let issues=%clnobs(&OUT);

            %end;
            %else %if &LOGSUMMARY=1 %then %do;

                %let msg=There are issues in the logs. Please check &OUT. for a list of logs with issues.;
                %let logmsg=%str(E)RROR: &MSG;
                %let issues=%clnobs(&OUT);

            %end;

        %end;
        %else %do;

            %let msg=There are no issues in the log.;
            %let logmsg=NOTE: &MSG;
            %let issues=0;

        %end;

        /* Output message when processing multiple logs */
        %if &MULTI=1 %then %do;

            proc printto log="%sysfunc(pathname(work))&DIRDLM.Work.log"
            %if &LOGNUMBER=1 %then %str( NEW );
            ;
            run;
            option notes;

            %put ;
            %put NOTE: The following log was checked: %superq(LOG);
            %put &LOGMSG;

            /* Turn off log to continue */
            %if &TEST ne test %then %do;

                filename junk dummy;
                proc printto log=junk; run;
                option nonotes;

            %end;

            %else %if &TEST=test %then %do;

                proc printto; run;
                option notes;

            %end;

            /* Drop the output if there are no issues */
            %if &OUTOBS=0 %then %do;

                proc sql;
                    drop table &OUT;
                quit;

            %end;

        %end;

    %end;
    /* End of log processing loop */


    /********************************************************************************
       Section 7: Report Issues
     ********************************************************************************/

    /* Exit here when issues occur within macro (e.g., bad log location) */
    %exit:

    /* Email */
    /* REVISION 2010-09-03 CAS: Added email capability */
    %if %superq(TO) ne %str() %then %do;

        %if %sysfunc(exist(&OUT)) and %upcase(&OUT) ne LOGS_W_ISSUES and &OUTOBS>0 %then %do;

            /* Summary */
            proc sql;
                create table Log_summary as
                select Found as Issue, sum(1) as Count format=8.
                from &OUT
                group by Found
                order by
                      case when found="&ISS1" then 1
                           when found="&ISS2" then 2
                           when found="&ISS3" then 3
                           when found="&ISS4" then 4
                           else 5 end
                    , found
                ;
            quit;

        %end;

        /* Set up email document */
        filename mymail email "NULL"

            to=(
        %do i=1 %to %countw(%superq(TO), %str( ));
            "%scan(%superq(TO), &I, %str( ))"
        %end;
               )

        %if %superq(CC) ne %str() %then %do;
            cc=(
        %do i=1 %to %countw(%superq(CC), %str( ));
            "%scan(%superq(CC), &I, %str( ))"
        %end;
               )
        %end;

        %if &OUTOBS>0 %then %do;
            subject="CheckLog: Issues Detected"
        %end;
        %else %do;
            subject="CheckLog: No Issues Detected"
        %end;
        ;

        /* Send email with issues if necessary */
        /* REVISION 2011-04-25 CAS: Added info to email regarding how to replicate
           the results in SAS. */
        /* REVISION 2011-05-16 CAS: Added exclusion for default EXT= option */
        /* REVISION 2011-06-01 CAS: Added exclusion for default OUT= option */

        /* Determine the current arguments for the macro */
        proc sql;
            create table _args_ as
            select name, value
            from sashelp.vmacro
            where scope='CHECKLOG'
              and value not in ('' ' ')
              and substr(name, 1, 3) not in ('SQL' 'SYS')
              and name in ('EXT' 'OUT' 'KEYWORD' 'EXCLUDE')
              and not (name='EXT' and upcase(value)='LOG')
              and not (name='OUT' and upcase(value) in ('LOG_ISSUES' 'LOGS_W_ISSUES'))
            ;
        quit;

        /* Set arguments as macro variables */
        %local argcnt;
        %let argcnt=0;
        data _null_;
            set _args_ end=end;
            call symputx(compress('arg' || put(_n_, 8.)), name, 'L');
            call symputx(compress('val' || put(_n_, 8.)), value, 'L');
            if end then do;
                call symputx('argcnt', put(_n_, 8.));
            end;
        run;

        proc sql;
            drop table _args_;
        quit;

        /* Set the text of the email */
        /* REVISION 2011-07-15 CAS: Added RELOG=Y argument in email. */
        %local a;
        %if %sysfunc(exist(log_summary))=1 %then %do;

            data _null_;
                set log_summary end=end;
                file mymail;
                if _n_=1 then do;
                    put "The following log or directory was checked: %superq(LOG_INIT)";
                    put "&MSG" // "Summary:" / ;
                end;
                put %str("    ") Issue Count=;
                if end then do;
                    put / "To review the code in SAS, submit the following program:" / ;
                    put '    %CheckLog(' "%superq(LOG_INIT)"
                %do a=1 %to &ARGCNT;
                        ", %superq(ARG&A)=%superq(VAL&A)"
                %end;
                        ", RELOG=Y);"
                    ;
                    put / "Note: The RELOG=Y argument will overwrite the current log.";
                end;
            run;

            /* REVISION 2011-09-09 CAS: Added step to drop temporary table */
            %if &TEST ne test %then %do;
                proc sql;
                    drop table log_summary;
                quit;
            %end;

        %end;

        %else %if %sysfunc(exist(logs_w_issues)) %then %do;

            data _null_;
                set logs_w_issues end=end;
                file mymail;
                if _n_=1 then do;
                    put "The following log or directory was checked: %superq(LOG_INIT)";
                    put "&MSG" // "Logs with issues:" / ;
                end;
                put %str("    ") Logs;
                if end then do;
                    put / "To review the code in SAS, submit the following program:" / ;
                    put '    %CheckLog(' "%superq(LOG_INIT)"
                %do a=1 %to &ARGCNT;
                        ", %superq(ARG&A)=%superq(VAL&A)"
                %end;
                        ");"
                    ;
                end;
            run;

        %end;

        %else %do;

            data _null_;
                file mymail;
                put "The following log or directory was checked: %superq(LOG_INIT)";
                put "&MSG";
                put / "To review the code in SAS, submit the following program:" / ;
                put '    %CheckLog(' "%superq(LOG_INIT)"
            %do a=1 %to &ARGCNT;
                    ", %superq(ARG&A)=%superq(VAL&A)"
            %end;
                    ", RELOG=Y);"
                ;
                put / "Note: The RELOG=Y argument will overwrite the current log.";
            run;

        %end;

        %let syslast=&OUT;

        /* Clear email filename */
        filename mymail clear;

    %end;

    /* Play a sound, which depends on the status */
    /* REVISION 2010-12-30 CAS: Added sound feature */
    %if &SYSSCP=WIN %then %do;
      %if &SOUND=E %then %do;

        %if &OUTOBS ge 1 %then %do;
            data _null_;
                call sound(87*2*2, .5*160*1);
                call sound(65*2*2, 1*160*1);
            run;
        %end;

      %end;

      %else %if &SOUND ne N %then %do;

        %if &OUTOBS ge 1 %then %do;
            data _null_;
                call sound(87*(2**3), .5*160*1);
                call sound(65*(2**3), 1*160*1);
            run;
        %end;
        %else %do;
            data _null_;
                call sound(98*(2**2), .5*160*1);
                call sound(65*(2**3), 1*160*1);
            run;
        %end;

      %end;
    %end;

    /* Put log issues in pop-up window */
    /* REVISION 2010-05-21 CAS: Added steps to handle (i)nvalid values of PM argument */
    /* REVISION 2010-06-07 CAS: Subset the logic to check the ouput observations
       to correctly implement logic. */
    %if &PM=E %then %do;

        %if &OUTOBS ge 1 %then %do;
            dm "postmessage %bquote(')&MSG%bquote(')" log;
        %end;

    %end;

    %else %if &PM ne N %then %do;
        dm "postmessage %bquote(')&MSG%bquote(')" log;
    %end;

    /* Restore mprint and log */
    %if &TEST ne test %then %do;

        /* Turn the log back on */
        proc printto; run;

        /* REVISION 2010-09-07 CAS: Added step to clean up file references */
        filename junk clear;

        /* Reset mprint option to original setting */
        option &USER_NOTES;
        option &USER_MPRINT;

    %end;

    /* REVISION 2011-09-01 CAS: Revised with new RELOG parameter */
    %if ((&RELOG=Y and &FILEDIR ne DIR) or (&RELOG=E and &FILEDIR ne DIR and &OUTOBS ge 1))
    and %sysfunc(exist(log))
    %then %do;
      %if &TEST ne test %then %do;
        dm log 'clear';
      %end;
    %end;

    /* REVISION 2010-05-03 CAS: Changed log reference to initial argument */
    %put ;
    %put NOTE: The following log or directory was checked: %superq(LOG_INIT);
    %put &LOGMSG;
    %put ;

    /* REVISION 2011-09-01 CAS: Revised with new RELOG parameter */
    %if ((&RELOG=Y and &FILEDIR ne DIR) or (&RELOG=E and &FILEDIR ne DIR and &OUTOBS ge 1))
    and %sysfunc(exist(log))
    %then %do;

        %put NOTE: The log will be recreated below.;
        %put ;

        data _null_;
            set log;
            put logtext;
        run;

    %end;

    /* Abort program if specified */
    /* REVISION 2010-04-13 CAS: Shifted the abort statement to a do loop.
       This was an attempt to correct an issue that arises when the macro
       is called with abort=Y and then subsequently called by a keyboard
       shortcut. This is a known issue and appears to be a glitch in SAS. */
    /* REVISION 2010-07-29 CAS: Discovered that the abort option does not work the
       same in version 9.2, requiring a version-specific modification. It was also
       discovered that the glitch causing SAS to crash is also version-specific, and
       it is resolved in 9.2. */
    %if &ABORT=Y and &OUTOBS ge 1 %then %do;

        %if %substr(&SYSVER, 1, 3)=9.1 %then %do;
            dm "postmessage '&ISS2.: Aborting program. Do not use CheckLog in a keyboard shortcut.'" log;
            %abort;
        %end;

        %else %do;
            %abort cancel;
        %end;

    %end;

    /********************************************************************************
       END OF MACRO
     ********************************************************************************/

%mend CheckLog;
