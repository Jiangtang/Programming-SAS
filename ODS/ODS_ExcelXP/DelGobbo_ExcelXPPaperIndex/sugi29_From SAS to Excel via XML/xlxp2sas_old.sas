%macro xlxp2sas(excelfile=,
                mapfile=,
                library=work,
                haslabels=y,
                cleanup=y,
                verbose=n,
                excelfileref=_xlfref,
                mapfileref=_mapfref,
                tempfileref=_tmpfref,
                excelfrefopts=,
                mapfrefopts=,
                sxlelrefopts=,
                tempfrefopts=,
                showver=n);

%*********************************************************************;
%*
%*  MACRO: XLXP2SAS
%*
%*  USAGE: %xlxp2sas(arg1=value, arg2=value, ... argN=valueN);
%*
%*  DESCRIPTION:
%*    This macro is used to import an Excel XP workbook that has been
%*    saved in the Excel Stylesheet Specification XML format.
%*
%*  NOTES:
%*    None.
%*
%*  SUPPORT: sasvcd, sasalf
%*
%*  VERSION: 9.1.3 pre-release
%*
%*********************************************************************;

%local CLEANUP EXCELFILE EXCELFILEREF EXCELFREFFLAG EXCELFREFOPTS 
       HASLABELS I LIBRARY MAPFILEREF MAPFILEREF MAPFREFFLAG 
       MAPFREFOPTS MSGLEVEL N_TABLES NOTES SHOWVER SOURCE2 
       SXLELREFOPTS TEMPDSN1 TEMPDSN2 TEMPDSN3 TEMPFILEREF 
       TEMPFREFOPTS TEMPSTR1 TEMPSTR2 VERBOSE;

%*  Save current option settings;

%let NOTES   = %sysfunc(getoption(notes));
%let SOURCE2 = %sysfunc(getoption(source2));

%let VERBOSE = %substr(%qupcase(&VERBOSE), 1, 1);

%*  Change some options based on the VERBOSE setting;

%if (&VERBOSE eq Y or &VERBOSE eq 1)
  %then %let MSGLEVEL = options notes source2;
  %else %let MSGLEVEL = options nonotes nosource2;

&MSGLEVEL;

%*  Perform some error checking before going further;

%if (%qcmpres(&EXCELFILE) eq ) %then %do;
  %put;
  %put ERROR: You must specify a value for the Excel file to be
%str(imported.);
  %put;
  %goto exit;
%end;

%if (%qcmpres(&MAPFILE) eq ) %then %do;
  %put;
  %put ERROR: You must specify a value for the SAS Libname Engine
%str(Map file to be used.);
  %put;
  %goto exit;
%end;

%if (%qcmpres(&LIBRARY) eq ) %then %do;
  %put;
  %put ERROR: You must specify an output library for the SAS
%str(table.);
  %put;
  %goto exit;
%end;

%if (%qcmpres(&EXCELFILEREF) eq ) %then %do;
  %put;
  %put ERROR: You must specify a value for the FILEREF to use to
%str(import the Excel file.);
  %put;
  %goto exit;
%end;

%if (%qcmpres(&MAPFILEREF) eq ) %then %do;
  %put;
  %put ERROR: You must specify a value for the FILEREF to use to
%str(access the SAS Libname Engine Map file.);
  %put;
  %goto exit;
%end;

%if (%qcmpres(&TEMPFILEREF) eq ) %then %do;
  %put;
  %put ERROR: You must specify a value for the FILEREF to use for
%str(temporary files.);
  %put;
  %goto exit;
%end;

%*  Determine whether files or filerefs have been specified;

%if (%lowcase(%qsubstr(&EXCELFILE, 1, 8)) EQ fileref:) %then %do;
  %let EXCELFREFFLAG = 1;
  %let EXCELFILEREF = %qsubstr(&EXCELFILE, 9);
%end;

%if (%lowcase(%qsubstr(&MAPFILE, 1, 8)) EQ fileref:) %then %do;
  %let MAPFREFFLAG = 1;
  %let MAPFILEREF = %qsubstr(&MAPFILE, 9);
%end;

%*  Set up various option flags;

%let HASLABELS = %substr(%qupcase(&HASLABELS), 1, 1);

%let CLEANUP = %substr(%qupcase(&CLEANUP), 1, 1);

%let SHOWVER = %substr(%qupcase(&SHOWVER), 1, 1);

%*  Assign FILEREFs and LIBREFs if needed;

%if (&EXCELFREFFLAG NE 1) %then %do;
  filename  &EXCELFILEREF "&EXCELFILE" &EXCELFREFOPTS;
  %if (&SYSFILRC NE 0) %then %do;
    %put;
    %put ERROR: Unable to assign a FILEREF for the Excel XML file.;
    %put;
    %goto exit;
  %end;
%end;

libname &EXCELFILEREF xml xmlmap=&MAPFILEREF access=readonly &SXLELREFOPTS;

%if (&SYSLIBRC NE 0) %then %do;
  %put;
  %put ERROR: Unable to assign a LIBREF for the XML file.;
  %put;
  %goto exit;
%end;

%if (&MAPFREFFLAG NE 1) %then %do;
  filename &MAPFILEREF "&MAPFILE" &MAPFREFOPTS;
  %if (&SYSFILRC NE 0) %then %do;
    %put;
    %put ERROR: Unable to assign a FILEREF for the XML map file.;
    %put;
    %goto exit;
  %end;
%end;

%*  Determine the number of tables (worksheets) in the workbook;

proc sql noprint;
  select count(Name) into: N_TABLES from
  &EXCELFILEREF.._Table;
quit;

%if (&SYSERR GT 4) %then %do;
  %put;
  %put ERROR: Unable to determine the number of tables in the
%str(workbook.);
  %put;
  %goto exit;
%end;

%let N_TABLES = %qcmpres(&N_TABLES);

%*  Declare local variables that will hold the table names;

%let TEMPSTR1=;
%let TEMPSTR2=;
%do I = 1 %to &N_TABLES;
  %let TEMPSTR1 = &TEMPSTR1 TABNAME_&I;
  %let TEMPSTR2 = &TEMPSTR2 TABLABEL_&I;
%end;

%local &TEMPSTR1 &TEMPSTR2;

%*  Workaround for sequential access problem;

%let TEMPDSN1 = _Table;

proc datasets nodetails nolist library=&EXCELFILEREF;
  copy out=work;
    select &TEMPDSN1;
run; quit;

%if (&SYSERR GT 4) %then %do;
  %put;
  %put ERROR: Unable to copy the Excel table data to the WORK table.;
  %put;
  %goto exit;
%end;

%*;
%*  Determine the table names by converting worksheet names to 
%*  valid SAS table names as needed.
%*;

data _null_;  set &TEMPDSN1;

length MvarName $45;

*  Store the label;

MvarName = 'TABLABEL_' || compress(put(_N_, best32.));
call symput(MvarName, strip(Name));

*  Change invalid chars to '_';

patternid = prxparse('s/[^\w]/_/');  
call prxchange(patternid, -1, strip(Name), Name);

*  Change first character to '_' if it is numeric;

patternid = prxparse('s/^[\d]/_/');
call prxchange(patternid, 1, Name);

*  Store the name;

MvarName = 'TABNAME_' || compress(put(_N_, best32.));
call symput(MvarName, strip(Name));
run;

%if (&SYSERR GT 4) %then %do;
  %put;
  %put ERROR: Unable to determine the table names from the workbook.;
  %put;
  %goto exit;
%end;

filename &TEMPFILEREF temp &TEMPFREFOPTS;

%if (&SYSFILRC GT 1) %then %do;
  %put;
  %put ERROR: Unable to assign a temporary FILEREF for the
%str(intermediate import code.);
  %put;
  %goto exit;
%end;

%*  Workaround for sequential access problem;

proc datasets nodetails nolist library=&EXCELFILEREF;
  copy out=work;
    select _ExcelData;
run; quit;

%if (&SYSERR GT 4) %then %do;
  %put;
  %put ERROR: Unable to copy the Excel data to the WORK table.;
  %put;
  %goto exit;
%end;

%let TEMPDSN2 = _ExcelData;
%let TEMPDSN3 = _ExcelData2;

options notes;
%put;
%if (&HASLABELS eq Y or &HASLABELS eq 1)
  %then %put NOTE: Column labels in the first row of the
%str(worksheet(s) will be used.);
  %else %put NOTE: There are no column labels in the first row
%str(of the worksheet(s), so generic column labels will be generated.);
%put;

&MSGLEVEL;

%*  Create data and code needed to do the import;

data work.&TEMPDSN3;

set work.&TEMPDSN2; by WorksheetIndex rowIndex;

length ColumnName TempStr $32 TableName $41 TableLabel $256;
length FirstObs i LastObs NCols PatternID 8;

retain FirstObs 0 LastObs 0 NCols 0 NRecords;

*  Excel worksheets are limited to 256 columns;

array ColLabel(256) $256;
array ColLen(256)   8;
array ColName(256)  $32;
array ColType(256)  $6;

retain ColLabel ColLen ColName ColType;

keep ColumnName RowIndex Value WorksheetIndex;

*;
*  Set the value to be used with the FIRSTOBS option.  NRecords
*  will contain the number of records read from the worksheet.
*;

if (first.WorksheetIndex) then do;
  FirstObs = LastObs + 1;
  NRecords = 0;
end;

NRecords + 1;

*;
*  Read the column names and labels one time, and initialize 
*  the data type and length.
*;

if (RowIndex EQ 1 and last.RowIndex) 
  then NCols = ColumnIndex;

*  Make sure column names are valid. Change invalid chars to '_';

if (RowIndex EQ 1) then do;

  ColType(ColumnIndex) = 'Number';
  ColLen(ColumnIndex)  = 0;


  if ("&HASLABELS" in ("Y" "1")) then do; *  Use label cells;

    if (compress(Value) eq '') then do; *  Empty cell;
      ColName(ColumnIndex)  = '_' || 
          substr(translate(uuidgen(), '_', '-'), 1, 31);
      ColLabel(ColumnIndex) = '.';
    end;
    else do;
      ColLabel(ColumnIndex) = Value;

      PatternID = prxparse('s/[^\w]/_/');  
      call prxchange(PatternID, -1, strip(Value), TempStr);

      *  Change first character to '_' if it is numeric;

      PatternID = prxparse('s/^[\d]/_/');
      call prxchange(PatternID, 1, TempStr);
      
      ColName(ColumnIndex) = TempStr;

      *  Check to see if this is a duplicate name, and change if so;
      
      do i = 1 to ColumnIndex-1;
        if (lowcase(TempStr) EQ lowcase(ColName(i))) then do;
          ColName(ColumnIndex)  = '_' || 
              substr(translate(uuidgen(), '_', '-'), 1, 31);
          leave;
        end;
      end;
    end;
    return;
  end;
  else do; *  Define arbitrary column names and labels;
    ColName(ColumnIndex)  = 'COLUMN'  || 
                            left(trim(put(ColumnIndex,z3.)));
    ColLabel(ColumnIndex) = 'Column ' || 
                            left(trim(put(ColumnIndex,z3.)));
  end;
end;

ColumnName = ColName(ColumnIndex);

*;
*  If any cell in a column is tagged as a string, set 
*  the column type to string;
*;

if lowcase(Type) EQ 'string' then do;
  ColType(ColumnIndex) = 'String';
  ColLen(ColumnIndex)  = max(ColLen(ColumnIndex), length(Value));
end;
else
  ColLen(ColumnIndex) = max(ColLen(ColumnIndex), 
                            length(input(Value, $256.)));

output;

if (last.WorksheetIndex);

*  Account for column headings if they are in the worksheet;

if ("&HASLABELS" in ("Y" "1"))
  then LastObs = LastObs + NRecords - NCols;
  else LastObs = LastObs + NRecords;

file &TEMPFILEREF;

TableName = "&LIBRARY.." || 
            symget('TABNAME_' || 
                   compress(put(WorksheetIndex, best32.)));

TableLabel = symget('TABLABEL_' || 
                    compress(put(WorksheetIndex, best32.)));

put 'data ' TableName +(-1) "(label='" TableLabel +(-1) "');";
put "  set &TEMPDSN3.(firstobs=" FirstObs 'obs=' LastObs +(-1) 
    '); by WorksheetIndex RowIndex;';

put '  keep   ' @;
do i = 1 to NCols;
  put ColName(i) @;
end;
put +(-1) ';';

put '  retain ' @;
do i = 1 to NCols;
  put ColName(i) @;
end;
put +(-1) ';';

put ' ';
do i = 1 to NCols;
  put '  attrib ' ColName(i) "label='" ColLabel(i) +(-1) 
      "' length=" @;
  if lowcase(ColType(i)) EQ 'string'
    then put '$' ColLen(i) +(-1) ';';
    else put '8;';
end;

put ' ';
put '  if (first.RowIndex) then do;';
do i = 1 to NCols;
  if lowcase(ColType(i)) EQ 'string'
    then put '    ' ColName(i) " = '';";
    else put '    ' ColName(i) ' = .;';
end;
put '  end;';

put ' ';
put "  if (ColumnName EQ '" ColName(1) +(-1) "')";
if (lowcase(ColType(1)) EQ 'string')
  then put '    then ' ColName(1) '= Value;';
  else put '    then ' ColName(1) '= input(Value, best32.);';
do i = 2 to NCols;
  put "  else if (ColumnName EQ '" ColName(i) +(-1) "')";
  if (lowcase(ColType(i)) EQ 'string')
    then put '    then ' ColName(i) '= Value;';
    else put '    then ' ColName(i) '= input(Value, best32.);';
end;

put ' ';
put '  if (last.RowIndex) then output;';
put 'run;';
put ' ';
  
put '%let TEMPSTR1=&SYSERR;';

put 'options notes;';
put 'data _null_;';
put '  if (&TEMPSTR1 GT 4) then do;';
put '    put " ";';
put '    put "ERROR: A problem was encountered when attempting to ' @;
put 'create table ' TableName 'from worksheet number ' @;
put WorksheetIndex +(-1) '.";';
put '    put " ";';
put '  end;';
put '  else do;';
put '    put " ";';
put '    put "NOTE: Table ' TableName 'successfully created from ' @;
put 'worksheet number ' WorksheetIndex +(-1) '.";';
put '    put " ";';
put '  end;';
put 'run;';
put ' ';
put "&MSGLEVEL" ';';
put ' ';
run;

%if (&SYSERR GT 4) %then %do;
  %put;
  %put ERROR: A problem was encountered when attepmting to generate
%str(the intermediate import code.);
  %put;
  %goto exit;
%end;

%*  Run the code that will import the data;

%include &TEMPFILEREF;

%exit:

%*  Clean up, but do not deassign user-assigned filerefs;

%if (&CLEANUP eq Y or &CLEANUP eq 1) %then %do;
  %if (&EXCELFREFFLAG NE 1 and %sysfunc(fileref(&EXCELFILEREF)) LE 0) %then %do;
    filename &EXCELFILEREF;
  %end;

  %if (%sysfunc(libref(&EXCELFILEREF)) EQ 0) %then %do;
    libname &EXCELFILEREF;
  %end;

  %if (&MAPFREFFLAG NE 1 and %sysfunc(fileref(&MAPFILEREF)) LE 0) %then %do;
    filename  &MAPFILEREF;
  %end;

  %if (%sysfunc(fileref(&TEMPFILEREF)) LE 0) %then %do;
    filename &TEMPFILEREF;
  %end;
  
  proc datasets nodetails nolist library=work;
  %if (&TEMPDSN1 ne ) %then %do;
    delete &TEMPDSN1;
  %end;
  %if (&TEMPDSN2 ne ) %then %do;
    delete &TEMPDSN2;
  %end;
  %if (&TEMPDSN3 ne ) %then %do;
    delete &TEMPDSN3;
  %end;
  run; quit;
%end;

%*  Display the version number for this code, if requested;

%if (&SHOWVER eq Y or &SHOWVER eq 1) %then %do;
  options notes;
  %put NOTE: XLXP2SAS Macro Version: 9.1.3 pre-release;
%end;

%*  Restore the original option settings;

options &NOTES &SOURCE2;

%mend xlxp2sas;