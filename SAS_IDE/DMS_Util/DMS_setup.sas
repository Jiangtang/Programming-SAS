%put **************************************************************;
%put **** 2 SAS AF applications:                               ****;
%put ****     --Log Filter                                     ****;
%put ****     --Format Viewer                                  ****;
%put ****                                                      ****;
%put **** 5 SAS Explore actions for Member 'table':            ****;
%put ****     --Copy Variable Names to Clipboard               ****;
%put ****     --proc freq     - _character_                    ****;
%put ****     --proc contents - details                        ****;
%put ****     --proc means    - _numeric_                      ****;
%put ****     --FSVIEW                                         ****;
%put ****                                                      ****;
%put **** Keys (DM):                                           ****;
%put ****     --F9:    KEYS                                    ****;
%put ****     --F3:    RUN                                     ****;
%put ****     --F5:    EDITOR                                  ****;
%put ****     --F6:    LOG    SHF+F6: CLEAR LOG                ****;
%put ****     --F7:    OUTPUT SHF+F7: CLEAR ODSRESULTS         ****;
%put ****     --CTL+W: EXPLORE                                 ****;
%put ****     --CTL+B: LIBNAME                                 ****;
%put ****     --CTL+Q: FILENAME                                ****;
%put ****     --CTL+I: OPTIONS                                 ****;
%put ****     --CTL+T: TITLE                                   ****;
%put ****     --CTL+E: CLEAR                                   ****;
%put ****     --CTL+F: FIND                                    ****;
%put ****     --CTL+H: REPLACE                                 ****;
%put ****     --CTL+G: GOTO LINE                               ****;
%put ****                                                      ****;
%put **** Keys (ENHANCED):                                     ****;
%put ****     --CTL+/:       COMMENTS    CTL+SHF+/: REMOVE COMMENTS;
%put ****     --CTL+F2:      MARK/UNMARK F2/SHF+F2: NAVIGATE MAKRS*;
%put ****     --CTL+SHF+W:   CLEAN UP WHITESPACES              ****;
%put ****     --CTL+SHF+A:   ADD A NEW ABBREVIATION            ****;
%put ****     --CTL+SHF+M:   EDIT KEYBORAD MACROS              ****;
%put ****     --CTL+SHF+L/U: LOWERCASE /UPPERCASE              ****;
%put ****     --CTL+[/]:     MATCHING BRACE/PAREN              ****;
%put ****     --ATL+[/]:     MATCHING DO-END                   ****;
%put ****     --CTL+SHF+S:   SORT SELECT LINES                 ****;
%put **************************************************************;

/*0.registry backup: Customize
gsubmit 'proc registry export="SAS_registry_&sysdate..reg";run;'
*/



/*SAS AF Utilities*/
%let _dir=%str(C:\Users\jhu\Documents\GitHub\Programming-SAS\SAS_IDE\DMS_Util);

/*1. edit_format by Frank Poppe*/
libname edit_fmt "&_dir.\edit_format";

/*2. LogFilter by RTSL.eu*/
/*
AFA C=RTSLTOOL.TOOLS.STARTUP.SCL
*/
libname rtsltool  "&_dir.\LogFilter";

/*3. add "Copy Variable Names to Clipboard"

http://support.sas.com/resources/papers/proceedings10/046-2010.pdf

gsubmit "filename _cb clipbrd;data _null_;file _cb; dsn='%8b'||'.'||'%32b';length name $32;do dsid = open(dsn,'I') while(dsid ne 0);do i = 1 to attrn(dsid,'NVARS');name = varname(dsid,i);put name @;end;dsid = close(dsid);end;run;filename _cb clear;"; 

*/

/*4. add "proc freq - _character_"

gsubmit "proc freq data=%8b.%32b NLEVELS;tables _character_/list nopercent nocol norow nocum;run;"; 

*/



/*5. add "proc contents - details"

gsubmit "proc contents data=%8b.%32b ;quit;"; 

*/

/*6. add "proc means - _numeric_"

gsubmit "proc means data=%8b.%32b N MEAN STD MIN MAX  RANGE  MODE  Q1 MEDIAN Q3 ndec=2;var _numeric_;run;"; 

*/

/*7.FSVIEW
FSVIEW %8b.%32b
*/




