%put NOTE:  SAS DMS AF utilities called C:\Users\jhu\Documents\GitHub\Programming-SAS\SAS_IDE\DMS_Util\DMS_setup.sas;
%put ;

%put NOTE: the current working folder is: ;
%xlog(cd)
%put ;

%put NOTE: a quick reference: ;
%put ;

/*SAS AF Utilities*/
%let _dir=%str(C:\Users\jhu\Documents\GitHub\Programming-SAS\SAS_IDE\DMS_Util);
%inc "&_dir.\DMS_setup.sas";

options EXTENDOBSCOUNTER=NO;
options cmdmac;
*options encoding="utf-8";

options mautosource sasautos=(sasautos,
	"C:\Users\jhu\Documents\GitHub\Programming-SAS\SAS_IDE\sasauto",
	"C:\Users\jhu\Documents\GitHub\Programming-SAS\roland\utilmacros",
	"C:\Users\jhu\Documents\GitHub\SAS_ListProcessing",
	"C:\Users\jhu\Documents\GitHub\Programming-SAS\utilities",
	"C:\Users\jhu\Documents\GitHub\Programming-SAS\SAS_IDE\sasauto"

); 

proc options option=config value; run;



