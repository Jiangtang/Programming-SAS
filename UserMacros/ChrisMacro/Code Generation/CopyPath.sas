%macro CopyPath(ref) / des='Copy the path of a libname or filename';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       CopyPath
        Author:     Chris Swenson
        Created:    2011-07-15

        Purpose:    Copy the path of a libname or filename to the clipboard

        Arguments:  ref - either the libref or fileref to copy

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %if %superq(REF)=%str() %then %do;
        %put %str(E)RROR: No argument specified for REF.;
        %return;
    %end;

    %local path;
    %let path=%sysfunc(pathname(%superq(REF)));

    %if %superq(REF)=%str() %then %do;
        %put %str(W)ARNING: The path does not exist.;
        %return;
    %end;

    filename _cb_ clipbrd;

    data _null_;
        file _cb_;
        put "%superq(PATH)";
    run;

    filename _cb_ clear;

    %put NOTE: The path was copied to the clipboard.;

%mend CopyPath;
