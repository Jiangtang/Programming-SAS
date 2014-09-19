/*
1. edit_format by Frank Poppe
2. LogFilter by RTSL.eu
*/


%let _dir=%str(C:\Users\jhu\Documents\GitHub\Programming-SAS\SAS_IDE\DMS_Util);


/*1. edit_format by Frank Poppe*/
libname edit_fmt "&_dir.\edit_format";;
%let libref = edit_fmt ;
%let catname = edit_fmt ;


filename catalog "&_dir.\edit_format\edit_format.trp" ;

proc cimport
    infile = catalog
    catalog = &libref..&catname
	;
run ;

filename edit_fmt temp ;

data _null_ ;
	length key $ 8 string $ 999 ;
    file edit_fmt ;
    do key = 'FORMAT' , 'FORMATC' , 'INFMT' , 'INFMTC' ;
        string = '[CORE\EXPLORER\MENUS\ENTRIES\' || trim ( key ) || ']'  ;
        put string ;
        string = '"1;&Open"="afa catalog=' || "&libref..&catname" || '.edit_format.frame entryName=%8b.%32b.%32b.%8b"'  ;
        put string ;
        string = '"@"="afa catalog=' || "&libref..&catname" || '.edit_format.frame entryName=%8b.%32b.%32b.%8b"' ;
        put string ;
    end ;
run ;

proc registry
    import=edit_fmt
	;
run ;


/*2. LogFilter by RTSL.eu*/

libname rtsltool  "&_dir.\LogFilter";

proc cimport infile="&_dir.\LogFilter\logChecker23x_v8.stc" lib=rtsltool;
run;

/*
AFA C=RTSLTOOL.TOOLS.STARTUP.SCL
*/
