
options nosource2 nosource;

%let ___dir1=A:\sasDoc\SAS_TransportFile_V5;

libname test "&___dir1";

%inc "&___dir1\FDA_SAS.sas";

%inc "&___dir1\xptcommn.sas";
%inc "&___dir1\loc2xpt.sas";
%inc "&___dir1\xpt2loc.sas";




%put SAS 9.3 in Win_64 for Transport Format V5 processing;

%put FDA_SAS.sas;
%put xptcommn.sas;
%put loc2xpt.sas;
%put xpt2loc.sas;

%put http://support.sas.com/kb/46/944.html;
%put http://www.sas.com/industry/government/fda/index.html;
