/*<pre><b>
/ Program   : scanlog.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Apr-2008
/ Purpose   : To scan a sas log file for important messages
/ SubMacros : %dequote
/ Notes     : This was written especially for sas programmers who develop their
/             programs interactively and use a "dm 'log; file ..." statement to
/             copy the contents of their log window to a file. After the copy is
/             done, this macro can be run to scan the log file created for all
/             important messages. It will write them to the log between an
/             obvious start and end line. This start and end line will always be
/             written, even if there are no messages, as proof that the scan was
/             done. If you wish to keep this output in the log then use 
/             "dm 'log; file ..." for a second time after running this macro.
/
/             You can either supply a full file name in quotes or an unquoted
/             fileref. See usage notes.
/
/ Usage     : %scanlog("full-file-path-name")
/             or
/             %scanlog(fileref)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ file              (pos) File to scan
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: scanlog v1.0;

%macro scanlog(file);
data _null_;
  infile &file eof=eof;
  input;
  if _n_=1 then
put / "============== scanning log file %dequote(&file) for important messages ==============";
  if (
     index(_infile_,"ERROR")=1
  or index(_infile_,"WARNING")=1
  or index(_infile_,"MERGE statement has more ")
  or index(_infile_,"W.D format")
  or index(_infile_," truncated ")
  or index(_infile_," has 0 observations ")
  or index(_infile_," outside the axis range ")
  or index(_infile_," Invalid")
  or index(_infile_," uninitialized")
     )
  and not (
    index(_infile_,"BY-line has been truncated")
	or index(_infile_,"The length of data column ")
	or index(_infile_,"Errors printed on")
	or index(_infile_,"scheduled to expire on")
	or index(_infile_,"product with which")
	or index(_infile_,"representative to have")
	or index(_infile_,"WORK._UNISTATM")
	)
	then put _infile_;
return;
eof:
put "=================================== Finished scanning log file ==================================";
return;
run;
%mend;
