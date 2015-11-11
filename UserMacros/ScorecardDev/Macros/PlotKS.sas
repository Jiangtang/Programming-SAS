/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro PlotKS */
/*******************************************************/
%macro PlotKS(DSKS);
/* Plotting the KS curve using gplot using simple options */

 symbol1 value=dot color=red   interpol=join  height=1;
 legend1 position=top;
 symbol2 value=dot color=blue  interpol=join  height=1;
 symbol3 value=dot color=green interpol=join  height=1;

proc gplot data=&DSKS;

  plot( NPer PPer KS)*Tile / overlay legend=legend1;
 run;
quit;
 
	goptions reset=all;
%mend;

