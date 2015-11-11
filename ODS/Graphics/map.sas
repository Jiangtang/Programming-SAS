/*
http://blogs.sas.com/content/graphicallyspeaking/2015/04/19/micro-maps/

*/

%let gpath='.';
%let dpi=200;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Fips data--*/
data FipsUsa;
  input Fips StateCode $4-5 StateFull $7-30 Region $31-40;
  datalines;
 1 AL Alabama                 South 
 2 AK Alaska                  NorthWest
 4 AZ Arizona                 SouthWest 
 5 AR Arkansas                South 
 6 CA California              SouthWest 
 8 CO Colorado                SouthWest 
 9 CT Connecticut             NorthEast 
10 DE Delaware                NorthEast
11 DC District of Columbia    NorthEast 
12 FL Florida                 South
13 GA Georgia                 South
15 HI Hawaii                  West 
16 ID Idaho                   NorthWest 
17 IL Illinois                MidWest 
18 IN Indiana                 MidWest 
19 IA Iowa                    MidWest 
20 KS Kansas                  MidWest  
21 KY Kentucky                SouthEast
22 LA Louisiana               South
23 ME Maine                   NorthEast 
24 MD Maryland                NorthEast 
25 MA Massachusetts           NorthEast 
26 MI Michigan                MidWest 
27 MN Minnesota               MidWest 
28 MS Mississippi             South
29 MO Missouri                MidWest 
30 MT Montana                 NorthWest 
31 NE Nebraska                MidWest
32 NV Nevada                  SouthWest 
33 NH New Hampshire           NorthEast
34 NJ New Jersey              NorthEast
35 NM New Mexico              SouthWest
36 NY New York                NorthEast
37 NC North Carolina          SouthEast 
38 ND North Dakota            MidWest
39 OH Ohio                    MidWest 
40 OK Oklahoma                South 
41 OR Oregon                  NorthWest 
42 PA Pennsylvania            NorthEast
44 RI Rhode Island            NorthEast 
45 SC South Carolina          South 
46 SD South Dakota            MidWest 
47 TN Tennessee               SouthEast
48 TX Texas                   South
49 UT Utah                    SouthWest 
50 VT Vermont                 NorthEast 
51 VA Virginia                SouthEast 
53 WA Washington              NorthWest
54 WV West Virginia           SouthEast 
55 WI Wisconsin               MidWest
56 WY Wyoming                 NorthWest 
72 PR Puerto Rico             Pacific
;
run;

/*--Remove Alsaka, Hawaii & Puerto Rico--*/
data usa;
  set maps.states(where=(density<=1 and (state not in(2, 15, 72))));
  length pid $8;
  keep state segment x y pid fips;
  by state segment;
  
  /*--Make unique Id for each state+segment combination--*/ 
  pid=put(state, 3.0) || put(segment, 3.0);
  Fips=state;

  run;
proc print;run;

proc sort data=usa;
  by fips segment;
  run;

data usa1;
  keep state segment x y pid fips StateCode StateFull Region;
  merge usa fipsusa;
  by fips;
run;
/*proc print data=usa1(obs=1000);run;*/

/*--Blank out state code and name for secondary segments--*/
data usa1a;
  set usa1;
  if segment ne 1 then do;
    statecode='';  statefull='';
  end;
  if region='South' then south='South';
  if region='NorthWest' then northwest='NorthWest';
  if region='SouthWest' then southwest='SouthWest';

  if region ne 'Pacific';
run;
proc print;run;

proc gproject data=usa1a out=usap;
   id state;
run;

data bar;
  input Reg $1-10 Product $12-19 Revenue;
  datalines;
NorthWest  Desks   25000 
NorthWest  Chairs  15000 
NorthWest  Lamps   10000 
SouthWest  Desks   20000 
SouthWest  Chairs  25000 
SouthWest  Lamps   15000 
South      Desks   15000 
South      Chairs  20000 
South      Lamps   30000
run;
/*proc print;run;*/

data usapb;
  set usap bar;
run;
/*proc print;run;*/


/*--Simple Choro Map by Region--*/
proc template;
  define statgraph Map;
  dynamic _skin _color;
    begingraph / designwidth=6in designheight=4.5in subpixel=on;
      entrytitle 'USA Map by Region';
        layout overlayEquated / walldisplay=none
                            xaxisopts=(display=none)
                            yaxisopts=(display=none)
                            ;
          polygonPlot x=x y=y id=pid / group=region display=(fill outline) 
                    outlineattrs=(color=black) dataskin=_skin labelattrs=(color=black size=5) 
                    label=statecode includemissinggroup=false name='map';
                  discretelegend 'map' / location=inside across=1 halign=right valign=bottom
                         valueattrs=(size=7) border=false;
                endlayout;
          entryfootnote halign=left 'Using Polygon Plot in an Layout OverlayEquated';
        endgraph;
  end;
run;

ods graphics / reset width=4in height=3in imagename='Map_940M2'
               attrpriority=color antialiasmax=4000 dataskinmax=2200;
proc sgrender data=usapb template=Map;
 dynamic _skin="sheen" _color='Black';
run;


/*--Micro Maps--*/
proc template;
  define statgraph MicroMaps;
  dynamic _skin _color;
    begingraph / designwidth=4in designheight=6in subpixel=on;
      entrytitle 'Revenues by Region and Product';
           discreteattrmap name="states" / ignorecase=true;
         value "NorthWest"  / fillattrs=graphdata1; 
                 value "SouthWest"  / fillattrs=graphdata2;
         value "South"      / fillattrs=graphdata3;
       enddiscreteattrmap;
      discreteattrvar attrvar=southfill var=south attrmap="states";
          discreteattrvar attrvar=northwestfill var=northwest attrmap="states";
          discreteattrvar attrvar=southwestfill var=southwest attrmap="states";

          layout lattice / columns=1;
        layout overlayEquated / walldisplay=none
                            xaxisopts=(offsetmin=0.0 offsetmax=0.0 display=none)
                            yaxisopts=(offsetmin=0.0 offsetmax=0.0 display=none)
                            ;
          polygonPlot x=x y=y id=pid / group=northwestfill display=(fill outline) 
                    outlineattrs=(color=black) dataskin=_skin labelattrs=(color=black size=5) 
                    label=eval(ifc(region='NorthWest',statecode,''));
                  entry halign=right 'NorthWest' / textattrs=(size=7); 
                endlayout;

        layout overlayEquated / walldisplay=none
                            xaxisopts=(offsetmin=0.0 offsetmax=0.0 display=none)
                            yaxisopts=(offsetmin=0.0 offsetmax=0.0 display=none)
                            ;
          polygonPlot x=x y=y id=pid / group=southwestfill display=(fill outline) 
                    outlineattrs=(color=black) dataskin=_skin labelattrs=(color=black size=5) 
                    label=eval(ifc(region='SouthWest',statecode,''));
                  entry halign=right 'SouthWest' / textattrs=(size=7); 
                endlayout;

        layout overlayEquated / walldisplay=none
                            xaxisopts=(offsetmin=0.0 offsetmax=0.0 display=none)
                            yaxisopts=(offsetmin=0.0 offsetmax=0.0 display=none)
                            ;
          polygonPlot x=x y=y id=pid / group=southfill display=(fill outline) 
                    outlineattrs=(color=black) dataskin=_skin labelattrs=(color=black size=5) 
                    label=eval(ifc(region='South',statecode,''));
                  entry halign=right 'South' / textattrs=(size=7); 
                endlayout;

      endlayout;
          entryfootnote halign=left 'Using Polygon in a Layout Lattice' / 
                    textattrs=(size=6);
        endgraph;
  end;
run;

ods graphics / reset width=3in height=4in imagename='MicroMaps_940M2'
               attrpriority=color antialiasmax=4000 dataskinmax=2200;
proc sgrender data=usapb template=MicroMaps;
 dynamic _skin="sheen" _color='Black';
run;


/*--Micro Maps with Bar--*/
proc template;
  define statgraph MicroMapBar;
  dynamic _skin _color;
    begingraph / designwidth=6in designheight=6in subpixel=on;
      entrytitle 'Revenues by Region and Product';
           discreteattrmap name="states" / ignorecase=true;
         value "NorthWest"  / fillattrs=graphdata1; 
                 value "SouthWest"  / fillattrs=graphdata2;
         value "South"      / fillattrs=graphdata3;
       enddiscreteattrmap;
      discreteattrvar attrvar=southfill var=south attrmap="states";
          discreteattrvar attrvar=northwestfill var=northwest attrmap="states";
          discreteattrvar attrvar=southwestfill var=southwest attrmap="states";

          layout lattice / columns=2;
        layout overlayEquated / walldisplay=none
                            xaxisopts=(display=none)
                            yaxisopts=(offsetmax=0.1 display=none);
          polygonPlot x=x y=y id=pid / group=northwestfill display=(fill outline) 
                    outlineattrs=(color=black) dataskin=_skin labelattrs=(color=black size=5) 
                    label=eval(ifc(region='NorthWest',statecode,''));
                  entry 'NorthWest' / valign=top textattrs=(size=7); 
                endlayout;
                layout overlay / walldisplay=none
                         xaxisopts=(display=(tickvalues) tickvalueattrs=(size=7) griddisplay=on)
                         yaxisopts=(display=(ticks tickvalues) tickvalueattrs=(size=7));
                  barchart x=eval(ifc(reg='NorthWest', product, '')) y=revenue / 
                   orient=horizontal dataskin=gloss fillattrs=graphdata1;
                endlayout;

        layout overlayEquated / walldisplay=none
                            xaxisopts=(display=none)
                            yaxisopts=(offsetmax=0.1 display=none);
          polygonPlot x=x y=y id=pid / group=southwestfill display=(fill outline) 
                    outlineattrs=(color=black) dataskin=_skin labelattrs=(color=black size=5) 
                    label=eval(ifc(region='SouthWest',statecode,''));
                  entry 'SouthWest' / valign=top textattrs=(size=7); 
                endlayout;
                layout overlay / walldisplay=none
                         xaxisopts=(display=(tickvalues) tickvalueattrs=(size=7) griddisplay=on)
                         yaxisopts=(display=(ticks tickvalues) tickvalueattrs=(size=7));
                  barchart x=eval(ifc(reg='SouthWest', product, '')) y=revenue / 
                   orient=horizontal dataskin=gloss fillattrs=graphdata2;
                endlayout;

        layout overlayEquated / walldisplay=none
                            xaxisopts=(display=none)
                            yaxisopts=(offsetmax=0.1 display=none);
          polygonPlot x=x y=y id=pid / group=southfill display=(fill outline) 
                    outlineattrs=(color=black) dataskin=_skin labelattrs=(color=black size=5) 
                    label=eval(ifc(region='South',statecode,''));
                  entry 'South' / valign=top textattrs=(size=7); 
                endlayout;
                layout overlay / walldisplay=none
                         xaxisopts=(display=(tickvalues) tickvalueattrs=(size=7) griddisplay=on)
                         yaxisopts=(display=(ticks tickvalues) tickvalueattrs=(size=7));
                  barchart x=eval(ifc(reg='South', product, '')) y=revenue / 
                   orient=horizontal dataskin=gloss fillattrs=graphdata3;
                endlayout;

      endlayout;
          entryfootnote halign=left 'Using Polygon and Bar Chart in a Layout Lattice' / 
                    textattrs=(size=6);
        endgraph;
  end;
run;

ods graphics / reset width=4in height=4in imagename='MicroMapBar_940M2'
               attrpriority=color antialiasmax=4000 dataskinmax=2200;
proc sgrender data=usapb template=MicroMapBar;
 dynamic _skin="sheen" _color='Black';
run;






