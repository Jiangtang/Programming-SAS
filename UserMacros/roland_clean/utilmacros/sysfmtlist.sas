/*<pre><b>
/ Program      : sysfmtlist.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ SAS version  : 8.2
/ Purpose      : In-datastep macro to list all the system formats
/ SubMacros    : none
/ Notes        : S370 formats missed out. Do not add a semicolon at the end.
/                Currently there is no way to identify system formats by a field
/                created by proc contents but this may change in the future and
/                if so then that method should be used instead of this macro.
/ Usage        : if format in (" " %sysfmtlist) then _fmt="SYS";
/                else _fmt="USR";
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called2 message added
/ rrb  07Sep07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: sysfmtlist v1.0;

%macro sysfmtlist;
  "$ASCII" "$BINARY" "$CHAR" "$EBCDIC" "$HEX" "$KANJI" "$KANJIX"
  "$MSGCASE" "$OCTAL" "$QUOTE" "$REVERJ" "$REVERS" "UPCASE"
  "$VARYING" "$" "BEST" "BINARY" "COMMA" "COMMAX" "D" "DATE"
  "DATEAMP" "DATETIME" "DAY" "DDMMYY" "DOLLAR" "DOWNAME" "E"
  "EURDFDD" "EURDFDE" "EURDFDN" "EURDFDT" "EURDFDW" "EURDFMN"
  "EURDFMY" "EURDFWDX" "EURDFWKX" "F" "FLOAT" "FRACT" "HEX" "HHMM"
  "HOUR" "IB" "IBR" "IEEE" "JULDAY" "JULIAN" "MINGUO" "MMDDYY"
  "MMSS" "MMYY" "MONNAME" "MONTH" "MONYY" "NEGPAREN" "NENGO"
  "NUMX" "OCTAL" "PD" "PDJULG" "PERCENT" "PIB" "PIBR" "PK"
  "PVALUE" "QTR" "QTRR" "RB" "ROMAN" "SSN"
  /* S370 formats missed out as not required for Unix */
  "TIME" "TIMEAMPM" "TOD" "WEEKDATE" "WEEKDATX" "WEEKDAY"
  "WORDDATE" "WORDDATX" "WORDF" "WORDS" "YEAR" "YEN" "YYMM" 
  "YYMMDD" "YYMON" "YYQ" "YYQR" "Z" "ZD"
%mend sysfmtlist;
