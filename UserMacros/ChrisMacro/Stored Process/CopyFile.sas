%macro CopyFile(infile,srcdir,tgtdir) / des='Copy a file from source to target directory';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       CopyFile
        Author:     Chris Swenson
        Created:    2011-05-24

        Purpose:    Copy a file from a source directory to a target directory

        Arguments:  infile - filename of file to copy, not including the directory
                    srcdir - source directory of file to copy
                    tgtdir - target directory of file to copy

        CAUTION:    This macro overwrites the target file if it exists. Use caution!

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check that arguments exist */
    %if %superq(INFILE)=%str() %then %do;
        %put %str(E)RROR: No argument specified for INFILE.;
        %return;
    %end;
    %if %superq(SRCDIR)=%str() %then %do;
        %put %str(E)RROR: No argument specified for source directory SRCDIR.;
        %return;
    %end;
    %if %superq(TGTDIR)=%str() %then %do;
        %put %str(E)RROR: No argument specified for target directory TGTDIR.;
        %return;
    %end;

    /* Determine the directory delimiter */
    %local dirdlm;
    /* Windows */
    %if %upcase("&SYSSCP")="WIN" %then %let dirdlm=\;
    /* z/OS and OpenVMS */
    %else %if %upcase("&SYSSCP")="OS" or %upcase("&SYSSCP")="OPENVMS" %then %let dirdlm=.;
    /* Unix */
    %else %if %index(*AIX*HP-UX*LINUX*OSF1*SUNOS*,%upcase(*&SYSSCPL*))>0
    %then %let dirdlm=/;
    /* Unknown */
    %else %do;
        %put %str(E)RROR: Unable to determine the operating system. Please update the macro for your environment.;
        %return;
    %end;

    /* Add backslashes at end */
    %if %substr(%superq(SRCDIR), %length(%superq(SRCDIR)), 1) ne %superq(DIRDLM)
    %then %let srcdir=%unquote(%superq(SRCDIR)%superq(DIRDLM));
    %if %substr(%superq(TGTDIR), %length(%superq(TGTDIR)), 1) ne %superq(DIRDLM)
    %then %let tgtdir=%unquote(%superq(TGTDIR)%superq(DIRDLM));

    /* Check that referenced files exist */
    %if %sysfunc(fileexist(%superq(SRCDIR))) ne 1 %then %do;
        %put %str(E)RROR: The source directory SRCDIR does not exist.;
        %return;
    %end;
    %if %sysfunc(fileexist(%superq(SRCDIR)%superq(INFILE))) ne 1 %then %do;
        %put %str(E)RROR: The INFILE does not exist.;
        %return;
    %end;
    %if %sysfunc(fileexist(%superq(TGTDIR))) ne 1 %then %do;
        %put %str(E)RROR: The target directory TGTDIR does not exist.;
        %return;
    %end;

    /* Manage options */
    %let user_xwait=%sysfunc(getoption(xwait));
    %let user_xsync=%sysfunc(getoption(xsync));
    options noxwait xsync;

    /* Copy file */
    /* Windows */
    %if "&SYSSCP"="WIN" %then %do;
        %sysexec copy "%superq(SRCDIR)%superq(INFILE)" "%superq(TGTDIR)";
    %end;
    /* z/OS */
    %else %if "&OpenVMS"="z/OS" %then %do;
        %sysexec $ copy "%superq(SRCDIR)%superq(INFILE)" "%superq(TGTDIR)";
    %end;
    /* OpenVMS */
    %else %if "&SYSSCP"="OpenVMS" %then %do;
        %sysexec copy "%superq(SRCDIR)%superq(INFILE)" "%superq(TGTDIR)";
    %end;
    /* Unix */
    %else %if %index(*HP-UX*LINUX*AIX*SUNOS*,*&SYSSCPL*)>0
     or %substr(%upcase(&SYSSCPL), 1, 5)="SUNOS"
    %then %do;
        %sysexec cp "%superq(SRCDIR)%superq(INFILE)" "%superq(TGTDIR)";
    %end;

    /* Restore options */
    options &USER_XWAIT &USER_XSYNC;

    %if %sysfunc(fileexist(%superq(TGTDIR)%superq(INFILE)))=1
    %then %put NOTE: The file was successfully copied.;
    %else %do;
        %put %str(W)ARNING: The file was not copied.;
        %put %str(W)ARNING- %superq(SRCDIR)%superq(INFILE);
    %end;

%mend CopyFile;
