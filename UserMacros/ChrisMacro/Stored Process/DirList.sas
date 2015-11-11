%macro DirList(PATH,MAXDATE=,MINDATE=,MAXSIZE=,MINSIZE=,OUT=,REPORT=N,REPORT1=N,SUBDIR=N,TIME=C,EXT=)
    / des='Create a list of files in a directory';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       DirList
        Author:     Ross Bettinger
        Created:    2004-10-11
        Source:     http://support.sas.com/kb/24/820.html
        Revisions:  Chris Swenson (http://www.cswenson.com/)
        Version:    2011-02-16

        OS:         Microsoft Windows
        SAS:        8+
        Language:   English

        Purpose:    Obtain a listing of files in a directory, including subdirectories
                    if specified. If the macro is used successively in the same job,
                    then the report (if specified) will contain the cumulative
                    directory listing of all directories searched. A separate output
                    data set will be created for each DIRLIST invocation.

        Arguments:  path     - Valid Windows path of directory to examine (use
                               additional Windows pipe options on the file reference).
                    maxdate= - [optional] Maximum date/time of file to report.
                    mindate= - [optional] Minimum date/time of file to report.
                               Note: The MAXDATE and MINDATE must be SAS date/time
                               constants in one of the following formats:
                               - 'ddMONyy:HH:MM'dt
                               - 'ddMONyy'd
                               - 'HH:MM't
                    maxsize= - [optional] Maximum size of file to report (bytes).
                    minsize= - [optional] Minimum size of file to report (bytes).
                    out=     - [optional] Name of output file containing results.
                    report=  - [optional] Flag controlling report creation, defaulted
                               to N.
                    report1= - [optional] Flag controlling 1-line report creation,
                               defaulted to N.
                    subdir=  - [optional] Flag to include subdirectories in directory
                               processing, defaulted to N. If set to Y then all
                               subdirectories of PATH will be searched. Otherwise,
                               only the path named in PATH will be searched. (Note:
                               the process may run slower if subdirectories are included)
                    time=    - [optional] Modify type of time reported, either
                               C (created), A (accessed), or W (written), defaulted
                               to C.
                    ext=     - [optional] Extension to filter output files.

        Usage:      %DIRLIST(c:/data1)
                    %DIRLIST(c:/data1, MINDATE='01JAN04:00:00:00'dt, MAXDATE='16MAR04:23:59:59'dt)
                    %DIRLIST(c:/data1, MINDATE='00:00:00't, MAXDATE='23:59:59't, MINSIZE=1000000)
                    %DIRLIST(d:/data2, REPORT=Y)
                    %DIRLIST(d:, OUT=LIBNAME.DSNAME, REPORT=N)
                    %DIRLIST(d:/documents and settings/robett/my documents/my sas files/v8)

        Method:     - Use Windows pipe with file reference to execute 'dir' command to
                      obtain directory contents
                    - Parse pipe output as if it were a file to extract file names
                      and other info
                    - [optional] Select files that are within the time interval
                    - [optional] Select files that are at least as large as MINSIZE
                      bytes and no larger than MAXSIZE
                    - Sort records by owner, path, filename
                    - [optional] Create report of files per owner/path if requested
                    - [optional] Create 1-line report of files per owner/path if requested

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2011-02-16  CAS     Revised parsing process for filename, as it was causing
                            issues by stripping too much because of the TRANWRD
                            function. Simplified the code for easier readability.
                            Updated and combined documentation into header. Added
                            the EXT argument for filtering extensions.

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/


    /********************************************************************************
       Settings
     ********************************************************************************/

    %local delim;
    %let delim=' ';
    %let report=%eval(%upcase(&REPORT)=Y);
    %let report1=%eval(%upcase(&REPORT1)=Y);
    %let subdir=%upcase(&SUBDIR);

    /* Check and modify arguments */
    %if %superq(PATH)=%str() %then %do;
        %put %str(E)RROR: No PATH specified.;
        %return;
    %end;
    %if &SUBDIR=Y %then %let SUBDIR=/s;
    %else %let SUBDIR=;
    %if %index(*A*C*W*,*%upcase(&TIME)*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid TIME argument. Please use C (created), A (accessed), or W (written).;
        %return;
    %end;


    /********************************************************************************
       Parse Listing
     ********************************************************************************/

    /* Use Windows pipe to recursively find all files in PATH, and parse out
       extraneous data, including unreadable directory paths. */

    /* Directory list structure:
       "Directory of" record precedes listing of contents of directory:

        Directory of <volume:> \ <dir1> [ \ <dir2>\... ]
        mm/dd/yy hh:mm:ss [AM|PM] ['<DIR>' | size ] filename.type

        Example:

            Volume in drive C is WXP
            Volume Serial Number is 18C2-3BAA

            Directory of C:\Documents and Settings\robett\My Documents\My SAS Files\V8\Test
      
            05/21/03  10:58 AM    <DIR>          CARYNT\robett          .
            05/21/03  10:58 AM    <DIR>          CARYNT\robett          ..
            12/24/03  10:22 AM    <DIR>          CARYNT\robett          Codebook
            04/23/01  02:42 PM               387 CARYNT\robett          printCharMat.sas
            10/09/03  11:35 AM             20582 CARYNT\robett          test.log
            10/28/03  08:02 AM             58682 CARYNT\robett          test.lst
            10/09/03  11:35 AM              1575 CARYNT\robett          test.sas
     */

    /* Run Windows "dir" DOS command as pipe to get contents of data directory */
    filename DIRLIST pipe "dir /-c /q &SUBDIR /t:&TIME ""&PATH""";

    /* Parse listing */
    data dirlist;
        length path filename $255 line $1024 owner $50 temp $16;
        format date mmddyy10. time time8.;
        retain path;

        infile DIRLIST length=reclen;
        input line $varying1024. reclen;
        line=compbl(line);

        /* Delete extra lines */
        if reclen=0
        or scan(line, 1, &DELIM)='Volume'
        or scan(line, 1, &DELIM)='Total'
        or scan(line, 2, &DELIM)='File(s)'
        or scan(line, 2, &DELIM)='Dir(s)'
        or scan(line, 6, &DELIM) in ('.' '..')
        then delete;

        /* Identify directory line */
        dir_rec=upcase(scan(line, 1, &DELIM))='DIRECTORY';

        /* Parse directory, date, time, size, and owner */
        if dir_rec then path=left(substr(line, length("Directory of")+2));
        else do;

            /* Date */
            date=input(scan(line, 1, &DELIM), mmddyy10.);

            /* Time */
            time=input(scan(line, 2, &DELIM), time5.);
            /* Add 12 hours to represent on 24-hour clock */
            post_meridian=scan(line, 3, &DELIM)='PM';
            if post_meridian and substr(put(time, time5.), 1, 2) ne '12'
                then time=time+'12:00:00'T;

            /* Size */
            temp=scan(line, 4, &DELIM);
            if temp='<DIR>' then size=0;
            else size=input(temp, best.);

            /* Owner */
            owner=trim(scan(line, 5, &DELIM));

            /* Remove date, time, size, and owner */
            format find 8.;
            find=find(trim(line), trim(owner)) + length(owner);
            substr(line, 1, find)='';
            filename=trim(left(line));

        end;

    /* Date filters */
    %if %eval(%length(&MAXDATE) + %length(&MINDATE) > 0) %then %do;

        if not dir_rec then do;
            datetime=input(put(date, date7.) || ':' || put(time, time5.), datetime13.) ;

        %if %length(&MAXDATE) > 0 %then %do;
            if datetime <= &MAXDATE;
        %end;
        %if %length(&MINDATE) > 0 %then %do;
            if datetime >= &MINDATE;
        %end;

        end;

    %end;

    /* Size filter */
    %if %length(&MAXSIZE) > 0 %then %do;
        if size <= &MAXSIZE;
    %end;
    %if %length(&MINSIZE) > 0 %then %do;
        if size >= &MINSIZE;
    %end;

    /* Extension filter */
    %if %superq(EXT) ne %str() %then %do;
        if find(filename, '.') and scan(upcase(filename), -1, '.')=upcase("&EXT");
    %end;

        drop dir_rec line find post_meridian temp;
    run;

    proc sort data=dirlist out=dirlist;
        by owner path filename;
    run;

    /* Break association to previous path prior to next DIRLIST invocation */
    filename DIRLIST clear;

    /* Create output data set if requested */
    %if %length(&OUT) > 0 %then %do;
        data &OUT;
            set dirlist;
        run;
    %end;


    /********************************************************************************
       Reporting
     ********************************************************************************/

    /* Create report of files by owner, if requested */

    %if &REPORT %then %do;

        /* Add data for current directory path to cumulative report data set */
        proc append base=report data=dirlist;
        run;

        title "Directory Listing";
        title1 "Path: &PATH";

        proc report center data=report headskip nowindows spacing=1 split='\';
            column owner path size date time filename;

            define owner    / order   width=17        'Owner';
            define path     / order   width=32 flow   'Path';
            define size     / display format=comma19. 'Size/(bytes)';
            define date     / display format=mmddyy10. 'Date';
            define time     / display format=time5.   'Time';
            define filename / display width=32 flow   'File Name';
        run;

        title;

    %end;

    %if &REPORT1 %then %do;

        /* Create 1-line report: truncate path to fit landscape layout */
        data report1(keep= owner path1 size);
            /* Path1 is 255 chars from above + 32 chars max filename */
            length path1 $287;
            set report;

            path1=catx('\', path, filename);

            path1=left(reverse(substr(left(reverse(path1)), 1, 80)));
        run;

        title "Directory Listing";
        title1 "Path: &PATH";

        proc report nocenter data=report1 headskip nowindows spacing=1 split='/';
            column owner path1 size;

            define owner / order width=17 'Owner';
            define path1 / order width=80 'Path';
            define size  / display format=comma19. 'Size/(bytes)';
        run;

        title;

    %end;

    /********************************************************************************
       END OF MACRO
     ********************************************************************************/

%mend DirList;
