/*
http://blogs.sas.com/content/graphicallyspeaking/2015/08/24/a-macro-for-polygon-area-and-center/
*/

%let gpath='.';
%let dpi=200;

ods html close;
ods listing style=htmlblue gpath=&gpath image_dpi=&dpi;

/*--Define some random polygons--*/
data polygons;
  PI=constant("PI");
  xmin=1e6; ymin=1e6; 
  npoly=3;
  do pid=1 to npoly;
        r=10+10*ranuni(3);
    nodes=int(3+3*ranuni(2));
        xoff=ifn(xmax ne ., xmax, 0)+r;
        yoff=ifn(ymax ne ., ymax, 0)+r;
        step=360/(nodes);
        nid=0;
    do deg=0 to 359 by step;
          nid=nid+1;
          x=xoff+(r*(1+ranuni(2))*cos(deg*pi/180));
          y=yoff+(r*(1+ranuni(2))*sin(deg*pi/180));
          xmax=max(x, xmax);
          ymax=max(y, ymax);
          xmin=min(x, xmin);
          ymin=min(y, ymin);
          output;
        end;
  end;

  /*--Hand build a "L" polygon--*/
  pid=npoly+1;
  nodes=6;
  id=1;
  nid=1; x=50; y=30; xmin=min(x, xmin); ymin=min(y, ymin); output;
  nid=2; x=50; y= 0; xmin=min(x, xmin); ymin=min(y, ymin); output;
  nid=3; x=70; y= 0; xmin=min(x, xmin); ymin=min(y, ymin); output;
  nid=4; x=70; y=10; xmin=min(x, xmin); ymin=min(y, ymin); output;
  nid=5; x=60; y=10; xmin=min(x, xmin); ymin=min(y, ymin); output;
  nid=6; x=60; y=30; xmin=min(x, xmin); ymin=min(y, ymin); output;

  /*--Hand build a Right Triangle--*/
  pid+1;
  nodes=3;
  id=2;
  nid=1; x=80; y=50; xmin=min(x, xmin); ymin=min(y, ymin); output;
  nid=2; x=80; y=10; xmin=min(x, xmin); ymin=min(y, ymin); output;
  nid=3; x=120; y=10; xmin=min(x, xmin); ymin=min(y, ymin); output;

  call symput ("XMin", xmin);
  call symput ("YMin", ymin);
run;

/*%put &xmin  &ymin;*/
/*ods html;*/
/*proc print data=polygons;*/
/*var pid nodes nid x y;*/
/*run;*/
/*ods html close;*/

/*--Plot polygons--*/
ods graphics / reset width=4in height=3in imagename='polyAreaSG';
title 'Polygons';
proc sgplot data=polygons noborder noautolegend;
  polygon id=pid x=x y=y / fill group=pid dataskin=sheen;
  xaxis display=none min=&xmin;
  yaxis display=none;
  run;

/*--Define Macro to compute polygonal area and center of area--*/
%macro polyarea (ds=, xmin=, ymin=, out=, Id=, X=, Y=);
  data &out;
    retain xp yp ax ay xm ym xfirst yfirst n;
    set &ds(keep=&id &x &y);
    by &id;

    area=.; xc=.; yc=.; xo=.; yo=.;

        /*--Process first node--*/
    if first.&id then do;
      n=1;                /*--Node id --*/
      ax=0;               /*--Sum area for x--*/
      ay=0;               /*--Sum area for y--*/
          dax=0;              /*--Area of segment for x--*/
          day=0;              /*--Area of segment for y--*/
          xm=0;               /*--Moment of segment area about minx--*/
          ym=0;               /*--Moment of segment area about miny--*/
      xfirst=&x; yfirst=&y;
          output;
    end; 

        /*--Process each polygon segment--*/
    else do;
          /*--Area of segment based on X parallelogram, Moment about XMin & sum of X areas--*/
          dax=(&x-&xmin+xp-&xmin)*(&y-yp)/2;
          a=&x-&xmin;
      b=xp-&xmin;
          v=a+b;
      h=&y-yp;
          dx=0; y1=0;

          /*--Compute height of centroid from base of trapezoid--*/
          if h ne 0 and v ne 0 then do;
        y1=h*(2*a+b)/(3*(a+b));
            dx=a/2+(b-a)*(h-y1)/(2*h);
          end;

          /*--Compute moment for atea about xmin--*/
      xm=xm+dax*dx;
      ax=ax+dax;

          /*--Compute moment for atea about ymin--*/
          dy=yp+y1-&ymin;
          ym=ym+dax*dy;

          n+1;
          output;
    end;

    xp=&x; yp=&y;

        /*--Process final polygon segment--*/
    if last.&id then do;
          dax=(xfirst-&xmin+&x-&xmin)*(yfirst-&y)/2;
          a=xfirst-&xmin;
      b=&x-&xmin;
          v=a+b;
      h=yfirst-&y;
          dx=0; y1=0;

          /*--Compute height of centroid from base of trapezoid--*/
          if h ne 0 and v ne 0 then do;
        y1=h*(2*a+b)/(3*(a+b));
            dx=a/2+(b-a)*(h-y1)/(2*h);
      end;

          /*--Compute moment for atea about xmin--*/
      xm=xm+dax*dx;
      ax=ax+dax;

          /*--Compute moment for atea about ymin--*/
          dy=&y+y1-&ymin;
          ym=ym+dax*dy;

      area=abs(ax);

          /*--Compute (x, y) of centroid--*/ 
      xc=abs(xm)/ area + &xmin;
      yc=abs(ym)/ area + &ymin;
          xp=&x; yp=&y;
          &x=xfirst; &y=yfirst;
          output;
    end;

  run;
%mend;

/*--Invoce macro--*/
%polyarea (ds=polygons, xmin=&xmin, ymin=&ymin, out=area, id=pid, x=x, y=y);

/*proc print data=area;*/
/*var pid xp yp x y ax ay area dx dy dax day xm ym xc yc y1;*/
/*run;*/

/*--Add x and y values for labels--*/
data arealbl;
  set area;
  xl=xc; yl=yc+4;
run;

/*--Draw polygons with labeled area and CG--*/
ods graphics / reset width=4in height=3in imagename='polyAreaCentroidSG';
title 'Polygons with Area and Centroid';
proc sgplot data=arealbl noborder noautolegend;
  format area f5.0;
  polygon id=pid x=x y=y / fill group=pid  dataskin=sheen;
  text x=xl y=yl text=area / group=pid strip;
  scatter x=xc y=yc / markerattrs=(symbol=circle size=3);
  xaxis display=none;
  yaxis display=none;
  run;
title;

proc template;
  define statgraph polygons;
    begingraph;
      entrytitle 'Polygons with Area and Centroid';
      layout overlayequated / walldisplay=none cycleattrs=false
                              xaxisopts=(display=none) yaxisopts=(display=none);
        polygonplot id=pid x=x y=y / display=(fill) group=pid dataskin=sheen;
        textplot x=xl y=yl text=eval("A=" || put(area,4.0)) / group=id strip=true;
        scatterplot x=xc y=yc / markerattrs=(symbol=circle size=3) group=pid;
          endlayout;
        endgraph;
  end;
run;

ods graphics / reset width=4in height=3in imagename='polyAreaCentroidEqGTL';
proc sgrender data=arealbl template=polygons;
format area 4.0;
run;
