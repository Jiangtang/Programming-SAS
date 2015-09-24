/*************************************************************************************
* MRTF_TPL.SAS -   a macro to create RTF template for CDISC SDTM/ADaM pilot
* Author:          Aileen Yam
* Date:            MAY 2006
* USAGE NOTES:
*     ORIENT  - report orientation, key words can be landscape or portrait.
*     FONTYPE - font type, default is Courier New for body of report.
*               Default header and footer fonts are specified in the proc template.
*     PROJECT - default project name is CDISCPILOT01 for the first pilot.
*     LEFTM, RIGHTM, TOPM, BOTM - margins, default is 1 on all sides.
*     MODE    - keywords are interactive or batch.  Default is interactive.
*
* There is a default date and time from the SAS system.
* The first default title is page x of y.
* The second default title is the project name. 
* The first default footnote is the program name and location.
* All these defaults have been automated in this macro without the need of user input.
* Thus, your titles and footnotes start with title3 and footnote2, respectively.
*
* There is no need to type in output name, it is automated to take your program name.
* If there are multiple output from the same program, add a %let statement before your 
*     report macro call, so the output will have 1 or 2 or 3, etc. added to
*     your output name.  For example:
*    %let outnum=1; 
*    %rptxx(title3=This is the first output of a program,footnote2=yyy);
*    %let outnum=2; 
*    %rptxx(title3=This is the second output from the same program,footnote2=yyy);
* If there is one output per program, the %let statment is not needed:
*    %rptxx(title3=This is the only output and the let statement is not needed,footnote2=yyy);
*
* This macro works with SAS version 8.2 and higher.  The code can be further streamlined
*     if all of us have SAS version 9x.  Invoke this macro for each proc report output.
*--------------------------------------------------------------------------------------
* Validated by Yuguang Zhao
**************************************************************************************/


%macro mrtf_tpl(orient=landscape,fontype=%str(Courier New),project=CDISCPILOT01,
                leftm=1,rightm=1,topm=1,botm=1,mode=interactive);

options orientation=&orient nocenter nonumber;

***Check if OUTNUM exist.  If it does not, initialize it to missing.  If it does,
   apply the value of OUTNUM;
%global outnum;
%if %nrquote(&&outnum)=%nrstr(&)outnum %then %let outnum=;

***Automate the retrieval of program name and directory name;
%global pgname dpname; 
%if %upcase(&mode)=BATCH %then %do;
    data _null_;
        dirprog="%sysfunc(getoption(print))";
	    progname=scan(dirprog,-1,'\');
	    tempname=substr(progname,1,index(progname,'.')-1);
        %if %length(&outnum)=0 %then %do;
            pgname=left(trim(scan(tempname,1,'.')))||'.rtf';
	    %end;
        %if %length(&outnum)>0 %then %do;
            pgname=left(trim(scan(tempname,1,'.')))||&outnum||'.rtf';
        %end;
        call symput('pgname',compress(pgname));
	    %let dpname = %sysfunc(getoption(SYSIN));
run;
%end;
%if %upcase(&mode)=INTERACTIVE %then %do;
    data _null_;
         set sashelp.vextfl;
    if (substr(fileref,1,3)='_LN' or substr(fileref,1,3)='#LN' or substr(fileref,1,3)='SYS') 
       and index(upcase(xpath),'.SAS')>0 then do;
       call symput("xpg",trim(xpath));
       stop;
    end;
	run;
	data _null_;
	dirprog="&xpg";
    %let dpname=&xpg; 
    progname=scan(dirprog,-1,'\');
	tempname=substr(progname,1,index(progname,'.')-1);
    %if %length(&outnum)=0 %then %do;
        pgname=left(trim(scan(tempname,1,'.')))||'.rtf';
	%end;
    %if %length(&outnum)>0 %then %do;
        pgname=left(trim(scan(tempname,1,'.')))||&outnum||'.rtf';
    %end;
    call symput('pgname',compress(pgname));
run;
%end;

proc template;
     define style pilot;
            parent=styles.rtf;
            style body from document /
                  leftmargin=&leftm.in
                  rightmargin=&rightm.in
                  topmargin=&topm.in
                  bottommargin=&botm.in;
            style systemtitle /
                  font_face="Times New Roman"
                  font_size=11pt font_weight=bold font_style=italic;
			style SystemFooter from systemtitle /
                  font_size=9pt font_weight=medium;
            style header from header /
                  background=white just=left font_face="&fontype" 
                  font_size=10pt font_weight=bold;
            style data from data /
                  font_size=9pt font_face="&fontype" font_weight=medium;
			style notecontent from note /
                  just=left font_face="&fontype" cellwidth=1.5in;  
			style Table from Output /
			      frame=VOID
			      rules=groups
			      cellpadding=3pt;
      end;
run;

***Default titles and footnotes;
title1 j=r h=9pt " {Page } {\field {\*\fldinst {PAGE }}}\~{\b\i of}\~{\field{\*\fldinst{\b\i NUMPAGES}}}";	
title2 "Protocol: &project";
footnote1 "Source: &dpname";

ods listing close;
ods rtf file="&g_drive:\cdisc_pilot\PROGRAMS\&g_status\TFLs\&pgname" style=pilot;

%mend mrtf_tpl;



