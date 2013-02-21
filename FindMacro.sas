/*
http://www.lexjansen.com/pharmasug/2005/coderscorner/cc11.pdf

Weiqin Pan,BMS
*/

%MACRO findMacro(macroName=);

	%LOCAL nFName iFName macroFind i thisMacName macroFileName
	l_macName l_FlName l_more msg total_len;

/*	STEP 1 - GET THE SASAUTOS SPECIFICATIONS*/

	DATA _fileRef_;
		KEEP fileRef ord filename;
		LENGTH SASautoList $400
				fileRef $100
				fileName $100
				macroName $20;
				
		SASautoLib = "'!SASROOT/SASAUTOS'";

/*		Get SAS autocall info*/
		SASautoList = TRIM(LEFT(COMPBL(TRANSLATE(GETOPTION("SASAUTOS"),' ',',()'))));
		SASautoList = TRANSLATE(SASautoList, "'", '"');

/*		Exclude SAS Supplied macro library*/
		i = INDEX(UPCASE(SASautoList), SASautoLib);
		IF i > 0 THEN DO;
			l = LENGTH(SASautoLib);
			IF i = 1 THEN SASautoList = SUBSTR(SASautoList,i+l);
			ELSE SASautoList = SUBSTR(SASautoList,1,i-1)||SUBSTR(SASautoList,i+l);
		END;

/*		If autocall libraries are assigned, create macro variables having*/
/*		information of each library’s fileref, or filename and total number of libraries*/
		IF SASautoList > '' THEN DO;
			l1 = LENGTH(SASautoList);
			l2 = LENGTH(COMPRESS(SASautoList));
			nLib = l1 - l2 +1;
			
			DO ord = 1 TO nLib;
				fileref = SCAN(SASautoList, ord, " ");
				
				IF INDEX(fileRef, "'") THEN DO;
					filename = TRANSLATE(fileRef, "", "'");
					l_ref = LENGTH(fileName);
					IF SUBSTR(fileName, l_ref, 1) = "/" THEN
					fileName = SUBSTR(fileName, 1, l_ref -1);
					fileRef = '';
				END;
				ELSE filename = '';
				
				fileRef = UPCASE(fileRef);
				OUTPUT;
			END;
			
			CALL SYMPUT('nFName', TRIM(LEFT(PUT(nLib, 2.))));

			macroName = TRIM(LEFT("&macroName"));
			i = INDEX(LOWCASE(macroName),'.sas');
			IF i > 0 THEN macroName = SUBSTR(macroName, 1, i-1);
			CALL SYMPUT('macroName', macroName);
		END;
	RUN;


	%LET macroFind = 0;
	%LET macroName = &macroName;
	
	%IF %BQUOTE(&nFName) ^= %THEN %DO;
		PROC SORT DATA = _fileRef_;
			BY fileRef;
		RUN;

/*STEP 2 - GET THE FILEREF FROM SASHELP.VEXTFL*/
		PROC SORT DATA = sashelp.vextfl(KEEP = fileRef xpath) OUT = vextfl;
			BY fileRef;
		RUN;
		
		%DO iFName = 1 %TO &nFName;
			%LOCAL flRef&iFName;
		%END;

/*		STEP 3 Get physical location of autocall fileref*/
		DATA _NULL_;
			MERGE _fileRef_(IN = a) vextfl(IN = b);
			BY fileRef;
			IF a;
			LENGTH cN $2;
			cN = PUT(ord, 2.);
			IF b THEN CALL SYMPUT('flRef'||TRIM(LEFT(cN)), TRIM(LEFT(xpath)));
			ELSE CALL SYMPUT('flRef'||TRIM(LEFT(cN)), TRIM(LEFT(filename)));
		RUN;
		
		%LET thisMacName = %UPCASE(&macroName);
		%LET l_macName = %LENGTH(&thisMacName);

/*		STEP 4: Search autocall libraries for specified macro*/
		%DO iFName = 1 %TO &nFName;
			%LET macrofilename = %STR("&&flRef&iFName../&macroName..sas");
			FILENAME macrofl &macrofilename;

/*			STEP 5 - WRITE THE FINDING NOTE ON THE LOG*/
			%IF %SYSFUNC(FEXIST(macrofl)) %THEN %DO;
				%LET macroFind = 1;
				%LET iFName = &nFName;
				%LET l_FlName = %LENGTH(&macrofilename);
				%LET total_len = %EVAL(&l_macName + &l_FlName + 26);
				%LET msg = %STR(|| The macro &thisMacName is from &macrofilename.. ||);
			%END;
		%END;

/*		According to result of searching, assign macro variables &msg and &total_len forfinding note	*/
		%IF &macroFind = 0 %THEN %DO;
			%LET total_len = 58;
			%LET l_more = %EVAL(&total_len - &l_macName - 54);
			%LET msg=%STR(|| The macro &thisMacName is not found in any path of SASAUTOS.);
			%DO i = 1 %TO &l_more;
				%LET msg = %STR(&msg)%STR( );
			%END;
			%LET msg = %STR(&msg)%STR(||);
		%END;	
	%END;
	
	%ELSE %DO;
		%LET total_len = 61;
		%LET msg=%STR(|| No autocall library is specified by the SASAUTOS option. ||);
	%END;

/*	Get the macro option settings:*/
/*	SYMBOLGEN,MLOGIC, and MPRINT*/

	%LOCAL mOpt1 mOpt2 mOpt3 optionOld optionNew _line;
	
	%LET mOpt1 = %SYSFUNC(GETOPTION(SYMBOLGEN));
	%LET mOpt2 = %SYSFUNC(GETOPTION(MLOGIC));
	%LET mOpt3 = %SYSFUNC(GETOPTION(MPRINT));
	%LET optionOld = OPTIONS;
	%LET optionNew = OPTIONS;
	
	%DO i = 1 %TO 3;
		%IF %SUBSTR(&&mOpt&i, 1, 2) ^= NO %THEN %DO;
			%LET optionOld = &optionOld &&mOpt&i;
			%LET optionNew = &optionNew NO&&mOpt&i;
		%END;
	%END;

/*	1. Turn off the macro options;*/
/*	2. Write out finding note on the log;*/
/*	3. Set back the originalmacro options*/
	&optionNew;
	
	%LET _line = %STR(**);
	
	%DO i = 1 %TO &total_len;
		%LET _line = &_line.%STR(-);
	%END;
	
	%LET _line = &_line.%STR(**);
	
	%PUT &_line;
	%PUT &msg;
	%PUT &_line;
	&optionOld;
%MEND findMacro;




%xlog(dir);

proc print data=sashelp.iris;run;

%findMacro(macroName=adam_validate);


%findMacro(macroName=mdval);



%findMacro(macroName=xlog);
