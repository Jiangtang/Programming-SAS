/**********************************************************************************************
Description
-----------
This macro will do a binary file copy from one fileref to another fileref
The filerefs need to be assigned outside of the macro.
No special RECFM settings are necessary.
The FILENAME statement can use special file-access-methods such as URL, FTP, WEBDAV

The code makes use of the FOPEN, FREAD, FGET, etc functions to do the processing,
as they support binary reading mode
             
Input Parameters
----------------
infile     : optional, contains the source fileref
             default = _BCIN

outfile    : optional, contains the target fileref
             default = _BCOUT

returnName : optional, the return code macro variable name can be specified
             here
             default = _BCRC

chunkSize  : optional, specify the number of bytes to be processed in one operation
             this will affect the time it takes to copy a file,
             smaller values mean longer process time             
             default = 8196
             max = 32767 (max length for var)

Global Macro Variables
----------------------
_BCRC      : 0 = successful, 4 = warning, 8 = error

Example
-------

filename _bcin "C:\temp\someName.ext";
filename _bcout webdav
  "http://serverName:8080/SASContentServer/repository/default/sasdav/someName.ext"
  user="user"
  pass="pass"
;

%binaryFileCopy()
%put NOTE: _bcrc=&_bcrc;

filename _bcin clear;
filename _bcout clear;


History
-------
29Jan2013 Bruno Mueller, Initial Coding
**********************************************************************************************/
%macro binaryFileCopy(
  infile=_bcin
  , outfile=_bcout
  , returnName=_bcrc
  , chunkSize=16392
);
  %local
    startTime
    endTime
    diffTime
  ;

  %let startTime = %sysfunc( datetime() );

  %if %sysevalf( &chunkSize > 32767 ) = 1 %then %do;
    %put NOTE: &sysMacroname chunksize > 32767, setting it to 32767;
    %let chunksize = 32767;
  %end; 

  %put NOTE: &sysMacroname start %sysfunc( putn(&startTime, datetime19.));
  %put NOTE: &sysMAcroname infile=&infile %qsysfunc(pathname(&infile));
  %put NOTE: &sysMAcroname outfile=&outfile %qsysfunc(pathname(&outfile));

  *
  * create global return var 
  *;
  %if %symexist(&returnName) = 0 %then %do;
    %global &returnName;
  %end;

  data _null_;
    length
      msg $ 1024
      rec $ &chunkSize
      outfmt $ 32
    ;

    *
    * open input and output file with binary mode
    *;
    fid_in = fopen("&infile", 'S', &chunkSize, 'B');

    *
    * check for unsuccessful open
    *;
    if fid_in <= 0 then do;
      msg = sysmsg();
      putlog "ERROR: &sysMacroname open failed for &infile";
      putlog msg;
      call symputx("&returnName",8);
      stop;
    end;

    fid_out = fopen("&outfile", 'O', &chunkSize, 'B');

    *
    * check for unsuccessful open
    *;
    if fid_out <= 0 then do;
      msg = sysmsg();
      putlog "ERROR: &sysMacroname open failed for &outfile";
      putlog msg;
      call symputx("&returnName",8);
      stop;
    end;

    *
    * we will keep track on the number of bytes processed
    *;
    bytesProcessed = 0;

    *
    * read loop on input file
    *;
    do while( fread(fid_in) = 0 );
      call missing(outfmt, rec);
      rcGet = fget(fid_in, rec, &chunkSize);

      *
      * need this information for write processing
      *;
      fcolIn = fcol(fid_in);

      *
      * need a format length to handle situations
      * where last chars in rec are blank
      * true: normal situation
      * false: last chunk of data at end of file
      *;
      if (fColIn - &chunkSize) = 1 then do;
        fmtLength = &chunkSize;
      end;
      else do;
        fmtLength = fColIn - 1;
      end;

      *
      * prepare the output format
      * and write rec
      *; 
      outfmt = cats("$char", fmtLength, ".");
      rcPut = fput(fid_out, putc(rec, outfmt));
      rcWrite = fwrite(fid_out);

      *
      * keep track of bytes
      *;
      bytesProcessed + fmtLength;    

      *
      * just in case
      *;
      maxRc = max(rcGet, rcPut, rcWrite);
      if maxRc > 0 then do;
        putlog "ERROR: &sysMacroname checklog " rcGet= rcPut= rcWrite=;
        call symputx("&returnName", 8);
      end;
    end;

    putlog "NOTE: &sysMacroname processed " bytesProcessed "bytes";
    rcInC = fclose(fid_in);
    rcOutC = fclose(fid_out);
    maxRc = max(rcInC, rcOutC);

    if maxRc > 0 then do;
      putlog "ERROR: &sysMacroname checklog " rcInC= rcOutC=;
      call symputx("&returnName", 8);
    end;
    else do;
      call symputx("&returnName", 0);
    end;
  run;

  %let endTime = %sysfunc( datetime() );
  %put NOTE: &sysMacroname end %sysfunc( putn(&endTime, datetime19.));
  %let diffTime = %sysevalf( &endTime - &startTime );
  %put NOTE: &sysMacroname processtime %sysfunc( putn(&diffTime, tod12.3));
%mend;
