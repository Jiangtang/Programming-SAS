/*
http://blogs.sas.com/content/graphicallyspeaking/2015/03/21/sankey-diagrams/
*/
%let gpath='.';
%let dpi 200;

data sankey;
  input id x y thickness y2 y3 xl xh llabel $46-48 hlabel $50-52;
  datalines;
1  0.1  0.8    1   .      .    .     .                
1  0.15 0.8    1   .      .    .     .                
1  0.2  0.76   1   .      .    .     .                
1  0.3  0.44   1   .      .    .     .                
1  0.4  0.4    1   .      .    .     .                
1  0.5  0.4    1   .      .    .     .                
1  0.5  0.4    1   .      .    .     .                
1  0.7  0.4    1   .      .    .     .                

2  0.1  0.2    5   .      .    .     .                
2  0.18 0.2    5   .      .    .     .                
2  0.25 0.25   5   .      .    .     .                
2  0.3  0.50   5   .      .    .     .                
2  0.4  0.53   5   .      .    .     .                
2  0.5  0.53   5   .      .    .     .                
2  0.7  0.53   5   .      .    .     .                

3  0.1  0.55   1   .      .    .     .                
3  0.15 0.55   1   .      .    .     .                
3  0.2  0.56   1   .      .    .     .                
3  0.3  0.64   1   .      .    .     .                
3  0.4  0.66   1   .      .    .     .                
3  0.5  0.66   1   .      .    .     .                
3  0.9  0.66   1   .      .    .     .               

1   .   .      .   0.8    .    0.1   0.12         3
1   .   .      .   0.4    .    0.35  0.37    3    
1   .   .      .   0.4    .    0.38  0.40         3
1   .   .      .   0.4    .    0.62  0.64    3    
1   .   .      .   0.4    .    0.65  0.67         3

2   .   .      .   .    0.2    0.1   0.12         18
2   .   .      .   .    0.535  0.35  0.37    18   
2   .   .      .   .    0.535  0.38  0.40         18
2   .   .      .   .    0.535  0.62  0.64    18   
2   .   .      .   .    0.535  0.65  0.67         18

3   .   .      .   0.55   .    0.1   0.12         3
3   .   .      .   0.66   .    0.35  0.37    3    
3   .   .      .   0.66   .    0.38  0.40         3
3   .   .      .   0.66   .    0.62  0.64    3    
3   .   .      .   0.66   .    0.65  0.67         3
3   .   .      .   0.66   .    0.88  0.90    3    
;
run;

/*--Break up links by group for different thickness--*/
data sankey2;
  length label $10;
  retain del 0.02;
  set sankey end=last;
  if id=2 then do;
    id2=id; id=.;
  end;
  output;

  /*--Add additional items--*/
  if last then do;
    /*--Labels--*/
    xlbl=0.1; ylbl=0.8+del; label='Index'; output;
        xlbl=0.1; ylbl=0.55+del; label='Item'; output;
        xlbl=0.35; ylbl=0.66+del; label='Item'; output;
        xlbl=0.62; ylbl=0.66+del; label='Item'; output;
        xlbl=0.85; ylbl=0.66+del; label='Checkout'; output;
        xlbl=0.1 ; ylbl=0.2+0.11; label='Search'; output;

        /*--Annoation--*/
        xa=0.05; ya=0.83; anno='1'; output;
        xa=0.77; ya=0.77;  anno='2'; output;
        xa=0.77; ya=0.5;  anno='3'; output;

        /*--Lines--*/
        lid=1; xln=0.085; yln=0.75; output;
        lid=1; xln=0.08;  yln=0.75; output;
        lid=1; xln=0.08;  yln=0.83; output;
        lid=1; xln=0.075; yln=0.83; output;
        lid=1; xln=0.08;  yln=0.83; output;
        lid=1; xln=0.08;  yln=0.90; output;
        lid=1; xln=0.085; yln=0.90; output;

        lid=2; xln=0.71; yln=0.71; output;
        lid=2; xln=0.71; yln=0.72; output;
        lid=2; xln=0.77; yln=0.72; output;
        lid=2; xln=0.77; yln=0.73; output;
        lid=2; xln=0.77; yln=0.72; output;
        lid=2; xln=0.82; yln=0.72; output;
        lid=2; xln=0.82; yln=0.71; output;

        lid=3; xln=0.7; yln=0.5;   output;
        lid=3; xln=0.75;  yln=0.5; output;
  end;
run;

ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Render the Diagram--*/
ods graphics / reset attrpriority=color width=5in height=3in imagename='Sankey_2_940';
footnote j=l 'SAS 9.40';
proc sgplot data=sankey2 noborder noautolegend nocycleattrs;
  styleattrs datacontrastcolors=(darkred  blue cx5f9f1f)
             datacolors=(darkred  blue cx5f9f1f);
  series x=x y=y / group=id lineattrs=(pattern=solid thickness=12) 
         nomissinggroup transparency=0.8 smoothconnect;
  series x=x y=y / group=id2 lineattrs=(pattern=solid  thickness=62 color=cx5f9f1f) 
         nomissinggroup transparency=0.8 smoothconnect;
  highlow y=y2 low=xl high=xh / highlabel=hlabel lowlabel=llabel type=bar 
          intervalbarwidth=10 group=id transparency=0.3 nooutline 
          labelattrs=(color=black size=10 weight=bold);
  highlow y=y3 low=xl high=xh / highlabel=hlabel lowlabel=llabel type=bar 
          intervalbarwidth=62 group=id2 transparency=0.3 nooutline
          fillattrs=(color=cx5f9f1f) labelattrs=(color=black size=10 weight=bold);
  scatter x=xlbl y=ylbl / datalabel=label datalabelpos=topright markerattrs=(size=0) 
          datalabelattrs=(size=12 weight=bold);
  series x=xln y=yln / group=lid nomissinggroup lineattrs=(color=black);
  scatter x=xa y=ya / datalabel=anno datalabelpos=center 
          markerattrs=(symbol=circlefilled color=lightblue size=18) 
          datalabelattrs=(size=12 weight=bold);
  xaxis min=0 max=1 offsetmin=0 offsetmax=0 display=none;
  yaxis min=0 max=1 offsetmin=0 offsetmax=0 display=none;
run;
footnote;
