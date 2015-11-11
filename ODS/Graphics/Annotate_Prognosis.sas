/*
http://blogs.sas.com/content/graphicallyspeaking/2015/06/08/is-that-annotate/

*/

%let gpath='.';
%let dpi=200;

ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

proc format;
  value sev
    1='Minimally Aggressive'
    2='Moderately Aggressive'
    3='Highly Aggressive'
    ;
run;

/*--Prognosis data--*/
data prognosis;
  label Alive='Percent of Patients Alive Without Treatment';
  label Time='Time Elapsed After Diagnosis (Months)';
  format Alive percent5.0 Severity sev.;
  input Time Severity Alive;
  datalines;
  0  1  1.0
  0  2  1.0
  0  3  1.0
 12  1  0.98
 12  2  0.84
 12  3  0.78
 24  1  0.92
 24  2  0.72
 24  3  0.56
 36  1  0.86
 36  2  0.63
 36  3  0.36
 48  1  0.82
 48  2  0.57
 48  3  0.24
 60  1  0.80
 60  2  0.52
 60  3  0.18
 72  1  0.79
 72  2  0.49
 72  3  0.17
;
run;
proc print; run;

/*--Define arrows--*/
data arrows;
  length Label Label1 Label2 $100;
  input id x y;
  if id=1 then Label='Further out from diagnosis'; 
  if id=2 then Label='More, aggressive, cancers are, more likely to, cause death, over time'; 
  datalines;
1   3  0.06
1  59  0.06
1  59  0.02
1  62  0.10
1  59  0.18
1  59  0.14
1   3  0.14
2  62  0.19
2  54  0.36
2  56  0.36
2  56  0.80
2  68  0.80
2  68  0.36
2  70  0.36
;
run;
/*proc print; run;*/

/*--Merge data--*/
data both;
  set prognosis arrows;
run;
/*proc print; run;*/

/*--Prognosis--*/
ods graphics / reset attrpriority=color width=5in height=3in imagename='Propnosis';
title 'Cancer Prognosis'; 
proc sgplot data=both;
  series x=time y=alive / group=severity smoothconnect lineattrs=(thickness=4) 
         nomissinggroup name='a';
  polygon id=id x=x y=y / fill outline label=label labelpos=center nomissinggroup splitjustify=center 
          fillattrs=(color=lightblue transparency=0.5) labelattrs=(size=8) splitchar=',';
  xaxis grid values=(0 to 72 by 12) offsetmin=0 offsetmax=0;
  yaxis grid values=(0 to 1.0 by 0.2) offsetmin=0 offsetmax=0.01;
  keylegend 'a' / title='' position=top linelength=20 noborder;
  run;
title;

/*--Prognosis curvelabel--*/
ods graphics / reset attrpriority=color width=5in height=3in imagename='PropnosisLbl';
title 'Cancer Prognosis'; 
proc sgplot data=both noautolegend;
  series x=time y=alive / group=severity smoothconnect lineattrs=(thickness=4) 
         nomissinggroup name='a' curvelabel splitchar=' ' curvelabelattrs=(size=6 weight=bold);
  polygon id=id x=x y=y / fill outline label=label labelpos=center nomissinggroup splitjustify=center 
          fillattrs=(color=lightblue transparency=0.5) labelattrs=(size=8) splitchar=',';
  xaxis grid values=(0 to 72 by 12) offsetmin=0;
  yaxis grid values=(0 to 1.0 by 0.2) offsetmin=0 offsetmax=0.01;
  run;
title;
