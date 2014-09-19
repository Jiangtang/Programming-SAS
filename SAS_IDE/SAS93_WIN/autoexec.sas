%put call C:\Users\jhu\Documents\GitHub\Programming-SAS\SAS_IDE\DMS_Util\DMS_setup.sas;
%put ;

/*SAS AF Utilities*/
%let _dir=%str(C:\Users\jhu\Documents\GitHub\Programming-SAS\SAS_IDE\DMS_Util);
%inc "&_dir.\DMS_setup.sas";

options EXTENDOBSCOUNTER=NO;
options mautosource sasautos=(sasautos,"C:\Users\jhu\Documents\GitHub\Programming-SAS\SAS_IDE\sasauto"); 


