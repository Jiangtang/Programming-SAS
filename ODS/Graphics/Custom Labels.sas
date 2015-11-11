
/*http://blogs.sas.com/content/graphicallyspeaking/2015/01/03/custom-labels/*/

%let gpath='.';
%let dpi=200;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Macro by Perry Watts--*/
%macro RGBHex(rr,gg,bb);
  %sysfunc(compress(CX%sysfunc(putn(&rr,hex2.))
  %sysfunc(putn(&gg,hex2.))
  %sysfunc(putn(&bb,hex2.))))
%mend RGBHex;

/*--Make data set--*/
data Russia;
  length Label $30;
  input From $1-15 value;
  Cat='A';
  if value ge 1.0 then Label=strip(strip(from) || ' = ' || put(value, dollar5.1) || ' billion');
  else Label=strip(strip(from) || ' = ' || put(value*1000, dollar6.1) || ' million');
  datalines;
European Union  15.8
United States   1.3
Norway          1.3
Canada          0.5152
Australia       0.104
;
run;
proc print;run;

data _null_;
  retain sum 0;
  set russia end=last;
  sum=sum+value;
  if last then call symput("Offset", sum/100);
run;

%put "Offset=&Offset";

ods graphics / reset width=5in height=1.5in imagename='Russia_Legend';
title j=l 'Agricultural Trade with Russia';
title2 h=0.5 j=l 'In US Dollars';
proc sgplot data=russia noborder nocycleattrs;
  styleattrs datacolors=(%rgbhex(207, 49, 36) %rgbhex(225, 100, 50) gold yellow lightgreen);
  hbarparm  category=cat response=value / group=label groupdisplay=stack outlineattrs=(color=lightgray) 
            baselineattrs=(thickness=0) barwidth=0.5 grouporder=data;
  keylegend / title='' noborder location=inside position=top;
  yaxis display=none  colorbands=odd offsetmin=0.3;
  xaxis display=none;
run;

/*--Add custom labels positions to data--*/
data russia_labels;
  retain xpos 0;
  drop xpos;
  set russia;
  xpos=xpos+value;
  if value ge 1.0 then Label=strip(strip(from) || '=' || put(value, dollar5.1) || ' billion');
  else Label=strip(strip(from) || '=' || put(value*1000, dollar6.1) || ' million');

  if _n_=1 then do; xlbl1=xpos-value/2; tlbl1=xlbl1-&offset; end;
  else if _n_=2 then do; xlbl2=xpos-value; tlbl2=xlbl2-&offset; end;
  else if _n_=3 then do; xlbl1=xpos-value; tlbl1=xlbl1-&offset; end;
  else if _n_=4 then do; xlbl2=xpos-value; tlbl2=xlbl2-&offset; end;
  else if _n_=5 then do; xlbl1=xpos+5*value; tlbl1=xlbl1-&offset; end;
run;
/*proc print;run;*/

/*--Graph with custom labels--*/
ods graphics / reset width=5in height=1.5in imagename='Russia_Labels_3';
title j=l 'Agricultural Trade with Russia';
title2 h=0.5 j=l 'In US Dollars';
proc sgplot data=russia_labels noborder noautolegend nocycleattrs;
  styleattrs datacolors=(%rgbhex(207, 49, 36) %rgbhex(225, 100, 50) gold yellow lightgreen)
             datacontrastcolors=(%rgbhex(207, 49, 36) %rgbhex(225, 100, 50) gold yellow lightgreen)
             datasymbols=(squarefilled);
  hbarparm  category=cat response=value / group=label groupdisplay=stack outlineattrs=(color=lightgray) 
            baselineattrs=(thickness=0) barwidth=0.4 grouporder=data;
  scatter x=xlbl1 y=cat / discreteoffset=-0.35 group=label;
  text x=tlbl1 y=cat text=label / discreteoffset=-0.35 position=left contributeoffsets=none 
       splitpolicy=splitalways splitchar='=' textattrs=(weight=bold);

  scatter x=xlbl2 y=cat / discreteoffset= 0.35 group=label;
  text x=tlbl2 y=cat text=label / discreteoffset= 0.35 position=left contributeoffsets=none
       splitpolicy=splitalways splitchar='=' textattrs=(weight=bold);
  
  yaxis display=none  colorbands=odd;
  xaxis display=none;
run;
title;

/*--2013 Expiorts Data--*/
data Exports;
  label value='Value (canadian dollars)' pct='Share of Canadian exports by product';
  format value inlabel outlabel dollar12.0 pct percent8.2;
  input item $1-45 value pct;
  if value > 100000000 then do; grp=1; inlabel=value; end; 
     else do; grp=2; outlabel=value; end;
  datalines;
Swine meat                                   253944057  .0965
Crustaceans                                   74652372  .0353
Fish                                          32633585  .0338
Pig and poultry fat                            3764318  .0642
Edible offal                                   3568222  .0089
Fish fillets                                   1289590  .0047
Bovine animal meat                              715479  .0006
Meat and edible offal of domestic poultry       201423  .0007
Equine meat                                      67639  .0008
Live fish                                        24161  .0008
;
run;
proc print;run;

ods graphics / reset width=5in height=3in imagename='Exports';
title j=l 'Some Canadian agricultural exports to Russia in 2013';
proc sgplot data=Exports noborder noautolegend nocycleattrs;  
  styleattrs datacolors=(%rgbhex(207, 49, 36) %rgbhex(233, 122, 102));
  hbarparm category=item response=value / group=grp barwidth=0.7 datalabel=outlabel 
           datalabelattrs=(size=6 weight=bold) nooutline;
  yaxistable item / location =inside position=left valuehalign=right valuejustify=right 
           valueattrs=(size=6 weight=bold);
  yaxistable pct / location =inside position=right valueattrs=(size=6 weight=bold) 
           labelattrs=(size=6 weight=bold) nolabel;
  text x=inlabel y=item text=inlabel /  position=left
       textattrs=(color=white size=6 weight=bold) contributeoffsets=none;
  yaxis splitchar=' ' colorbands=odd display=none colorbandsattrs=(transparency=0.3);
  xaxis display=none;
run;
