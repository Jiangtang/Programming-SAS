%macro File_or_Dir(arg,mvar=TYPE) / des='Determine if a file or directory';

    %global &MVAR;
    %local file fileref dir;

    %let fileref=fileref;
    %let file=%sysfunc(filename(FILEREF, %superq(ARG)));
    %if &FILE ne 0 %then %do;
        %put %str(E)RROR: Filename association failed.;
        %goto exit;
    %end;

    %let id=%sysfunc(dopen(FILEREF));
    %if &ID ne 0 %then %do;
        %put NOTE: The argument is a directory.;
        %let rc=%sysfunc(dclose(&ID));
        %let &MVAR=DIR;
        %goto exit;
    %end;
    %else %do;

        %put NOTE: The argument is not a directory.;

        %let id=%sysfunc(fopen(FILEREF));
        %if &ID ne 0 %then %do;
            %put NOTE: The argument is a file.;
            %let rc=%sysfunc(fclose(&ID));
            %let &MVAR=FILE;
        %end;
        %else %do;
            %put NOTE: The argument is not a file.;
            %let &MVAR=NA;
        %end;

    %end;

    %exit:
    %let file=%sysfunc(filename(FILEREF));

%mend File_or_Dir;

/*
%file_or_dir(c:\);
%put &TYPE;

%file_or_dir(c:\test.txt);
%put &TYPE;

%file_or_dir(asdf);
%put &TYPE;
*/
