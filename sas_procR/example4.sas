
ODS HTML FILE="c:\test\example.html"(title="SAS/R result integration") STYLE=minimal gpath= "c:\test" GTITLE GFOOTNOTE;
proc print data=sashelp.company(obs=10); run;
ods _all_ close;

%include "C:\test\Proc_R.sas";

%Proc_R(SAS2R=,R2SAS=);
cards4;

## load required packages

#setwd("c:/test")
library("IDPmisc")
library("SwissAir") # data for the example

## prepare the data

Ox <- AirQual[,c("ad.O3","lu.O3","sz.O3")] +
  AirQual[,c("ad.NOx","lu.NOx","sz.NOx")] -
  AirQual[,c("ad.NO","lu.NO","sz.NO")]
names(Ox) <- c("ad","lu","sz")

## draw graph

ipairs(Ox, ztransf = function(x){x[x<1] <- 1; log2(x)})

;;;;

%quit;

data html;
     infile "c:\test\example.html" truncover lrecl=256;
	 input raw $ 1-200;
run;
data html;
     set html;
	 output;
	 if raw="<br>" then do;
	    output;
	    raw='<div align="center">'; output;
        raw= "<img src=&inhtml border='0' class='c'>"; output;
	 end;
run;
data _null_;
    set html;
    file "c:\test\example.html";
	put raw;
run;
dm "wbrowse 'c:\test\example.html'";
