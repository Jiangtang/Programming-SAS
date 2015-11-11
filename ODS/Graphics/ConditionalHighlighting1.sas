/*
http://blogs.sas.com/content/graphicallyspeaking/2012/11/19/condtional-highlighting/

*/

data conditional;
  length Group $10 Drug $6;
  label group='Sample Size:';
  input Year Drug $ Value samplesize;
  Group='>= 30';
  if samplesize < 30 then do;
    Value2=value; 
	Group='< 30';
  end;
  if drug='A' then Drug='Drug A';
  else Drug='Drug B';
  datalines;
2009  A  90  50
2010  A  75  25
2011  A 100  60
2012  A  70  55
2009  B  80  50
2010  B  65  35
2011  B  90  60
2012  B  60  25
;
run;
/*ods html;*/
/*proc print;run;*/
/*ods html close;*/

%let gpath='.';
ods html close;

/*--Add patterns to style--*/
proc template;
  define style conditional;
  parent=styles.htmlblue;
  style Graph from Graph /                                                
    attrpriority = "None"; 
  style GraphBar from GraphComponent /                                    
     displayopts = "fill outline fillpattern";
  style GraphData1 from GraphData1 / 
    fillpattern="E";
  style GraphData2 from GraphData2 / 
    fillpattern="L2";
  end;
  run;

/*--SGPLOT Grouped Bar Chart--*/
ods listing gpath=&gpath style=conditional;
ods graphics / reset width=5in height=3in imagename='GroupBySampleSize';
title 'Response by Year';
proc sgplot data=conditional(where=(drug='Drug A'));
  vbarparm category=year response=value / group=group fillattrs=(color=cxdfdff0) 
    dataskin=pressed;
  xaxis display=(nolabel);
  yaxis display=(nolabel) grid;
  run;

/*--GTL Clustered Bar chart--*/
proc template;
  define statgraph BarChart;
    begingraph;
      entrytitle 'Response by Year and Drug';
      layout overlay / xaxisopts=(display=(ticks tickvalues))
                       yaxisopts=(display=(ticks tickvalues) griddisplay=on offsetmax=0.1);
	    barchart x=year y=value / group=drug name='a' groupdisplay=cluster datatransparency=0.2;
        discretelegend 'a' / location=inside valign=top halign=right across=1;
	  endlayout;
	endgraph;
  end;
run;

ods listing gpath=&gpath style=htmlblue;
ods graphics / reset width=5in height=3in imagename='BarChart';
proc sgrender data=conditional template=BarChart;
run;


/*--GTL Clustered Bar chart with Conditional Highlighting --*/
proc template;
  define statgraph ConditionalHighlighting;
    begingraph;
      entrytitle 'Response by Year and Drug';
      layout overlay / xaxisopts=(display=(ticks tickvalues))
                       yaxisopts=(display=(ticks tickvalues) griddisplay=on offsetmax=0.1);
	    barchart x=year y=value / group=drug name='a' groupdisplay=cluster datatransparency=0.2;
		barchart x=year y=value2 /  group=drug display=(fillpattern) groupdisplay=cluster 
           fillpatternattrs=(pattern=L2);
		barchart x=year y=value2 /  display=(fillpattern) groupdisplay=cluster barwidth=0 
           fillpatternattrs=(pattern=l1) name='b' legendlabel='Sample Size < 30';
        discretelegend 'a' / location=inside valign=top halign=right across=1;
		discretelegend 'b' / location=inside valign=top halign=left;
	  endlayout;
	endgraph;
  end;
run;

ods listing gpath=&gpath style=htmlblue;
ods graphics / reset width=5in height=3in imagename='ConditionalHighlighting';
proc sgrender data=conditional template=ConditionalHighlighting;
run;

/*--GTL Clustered Bar chart With Skin--*/
proc template;
  define statgraph ConditionalHighlightingSkin;
    begingraph;
      entrytitle 'Response by Year and Drug';
      layout overlay / xaxisopts=(display=(ticks tickvalues))
                       yaxisopts=(display=(ticks tickvalues) griddisplay=on offsetmax=0.1);
	    barchart x=year y=value / group=drug name='a' groupdisplay=cluster 
                 dataskin=matte datatransparency=0.2;
		barchart x=year y=value2 /  group=drug display=(fillpattern) groupdisplay=cluster 
           fillpatternattrs=(pattern=L2);
		barchart x=year y=value2 /  display=(fillpattern) barwidth=0 
           fillpatternattrs=(pattern=l1) name='b' legendlabel='Sample Size < 30';
        discretelegend 'a' / location=inside valign=top halign=right across=1;
		discretelegend 'b' / location=inside valign=top halign=left;
	  endlayout;
	endgraph;
  end;
run;

ods listing gpath=&gpath style=htmlblue;
ods graphics / reset width=5in height=3in imagename='ConditionalHighlightingSkin';
proc sgrender data=conditional template=ConditionalHighlightingSkin;
run;

