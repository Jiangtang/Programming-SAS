/*

http://blogs.sas.com/content/graphicallyspeaking/2015/03/10/a-3d-scatter-plot-macro/
*/

options cmplib=sasuser.funcs;


proc fcmp outlib=sasuser.funcs.mat;
  subroutine MatInv(Mat[*,*], InvMat[*,*]);
  outargs InvMat;
  call inv(Mat, InvMat);
  endsub;

  subroutine MatMult(A[*,*], B[*,*], C[*,*]);
  outargs C;
  call mult(A, B, C);
  endsub;

  subroutine MatIdent(A[*,*]);
  outargs A;
  call identity(A);
  endsub;
run;
quit;



options cmplib=sasuser.funcs;
%let gpath='.';
%let dpi=200;



%macro Ortho3D_Macro (Data=, WallData=, X=, Y=, Z=, Group=, Size=, Lblx=X, Lbly=Y, Lblz=Z, 
                      Tilt=65, Rotate=-55, Attrmap=, Title=);

%let A=&Tilt;
%let B=0;
%let C=&Rotate;

/*--Project the walls and axes--*/
data projected_walls;
  keep id group xw yw zw xw2 yw2 zw2 xl yl zl lbx lby lbz label;
  array u[4,4] _temporary_;  /*--Intermediate Matrix--*/
  array v[4,4] _temporary_;  /*--Intermediate Matrix--*/
  array w[4,4] _temporary_;  /*--Final View Matrix--*/
  array m[4,4] _temporary_;  /*--Projection Matrix--*/
  array rx[4,4] _temporary_; /*--X rotation Matrix--*/
  array ry[4,4] _temporary_; /*--Y rotation Matrix--*/
  array rz[4,4] _temporary_; /*--Z rotation Matrix--*/
  array d[4,1] _temporary_;  /*--World Data Array --*/
  array p[4,1] _temporary_;  /*--Projected Data Array --*/
  retain r t f n;
  r=1; t=1; f=1; n=-1;
  pi=constant("PI");
  fac=pi/180;
  A=&A*fac; B=&B*fac; C=&C*fac;

  /*--Set up projection matrix--*/
  m[1,1]=1/r;   m[1,2]=0.0;  m[1,3]=0.0;      m[1,4]=0.0;
  m[2,1]=0.0;   m[2,2]=1/t;  m[2,3]=0.0;      m[2,4]=0.0;
  m[3,1]=0.0;   m[3,2]=0.0;  m[3,3]=-2/(f-n); m[3,4]=-(f+n)/(f-n);
  m[4,1]=0.0;   m[4,2]=0.0;  m[4,3]=0.0;      m[4,4]=1.0;

  /*--Set up X rotation matrix--*/
  rx[1,1]=1;     rx[1,2]=0.0;     rx[1,3]=0.0;      rx[1,4]=0.0;
  rx[2,1]=0.0;   rx[2,2]=cos(A);  rx[2,3]=-sin(A);  rx[2,4]=0.0;
  rx[3,1]=0.0;   rx[3,2]=sin(A);  rx[3,3]=cos(A);   rx[3,4]=0.0;
  rx[4,1]=0.0;   rx[4,2]=0.0;     rx[4,3]=0.0;      rx[4,4]=1.0;

  /*--Set up Y rotation matrix--*/
  ry[1,1]=cos(B);  ry[1,2]=0.0;  ry[1,3]=sin(B);  ry[1,4]=0.0;
  ry[2,1]=0.0;     ry[2,2]=1.0;  ry[2,3]=0.0;     ry[2,4]=0.0;
  ry[3,1]=-sin(B); ry[3,2]=0.0;  ry[3,3]=cos(B);  ry[3,4]=0.0;
  ry[4,1]=0.0;     ry[4,2]=0.0;  ry[4,3]=0.0;     ry[4,4]=1.0;

  /*--Set up Z rotation matrix--*/
  rz[1,1]=cos(C);  rz[1,2]=-sin(C); rz[1,3]=0.0;  rz[1,4]=0.0;
  rz[2,1]=sin(C);  rz[2,2]=cos(C);  rz[2,3]=0.0;  rz[2,4]=0.0;
  rz[3,1]=0.0;     rz[3,2]=0.0;     rz[3,3]=1.0;  rz[3,4]=0.0;
  rz[4,1]=0.0;     rz[4,2]=0.0;     rz[4,3]=0.0;  rz[4,4]=1.0;
  
  /*--Build transform matris--*/
  call MatMult(rz, m, u);
  call MatMult(ry, u, v);
  call MatMult(rx, v, w);

  set &WallData;

  /*--Set axis labels--*/
  if label eq 1 then lbx="&Lblx";
  if label eq 2 then lby="&Lbly";
  if label eq 3 then lbz="&Lblz";

  /*--Transform walls--*/
  d[1,1]=xw; d[2,1]=yw; d[3,1]=zw; d[4,1]=1;
  call MatMult(w, d, p);
  xw=p[1,1]; yw=p[2,1]; zw=p[3,1];

  /*--Transform axes--*/
  d[1,1]=xw2; d[2,1]=yw2; d[3,1]=zw2; d[4,1]=1;
  call MatMult(w, d, p);
  xw2=p[1,1]; yw2=p[2,1]; zw2=p[3,1];

  /*--Transform labels--*/
  d[1,1]=xl; d[2,1]=yl; d[3,1]=zl; d[4,1]=1;
  call MatMult(w, d, p);
  xl=p[1,1]; yl=p[2,1]; zl=p[3,1];
run;
/**/
/*ods html;*/
/*proc print;run;*/
/*ods html close;*/

/*--Compute data ranges--*/
data _null_;
  retain xmin 1e10 xmax -1e10 ymin 1e10 ymax -1e10 zmin 1e10 zmax -1e10;
  set &Data end=last;
  xmin=min(xmin, &X);
  xmax=max(xmax, &X);
  ymin=min(ymin, &Y);
  ymax=max(ymax, &Y);
  zmin=min(zmin, &Z);
  zmax=max(zmax, &Z);
  if last then do;
    call symput("xmin", xmin); call symput("xmax", xmax);
        call symput("ymin", ymin); call symput("ymax", ymax);
        call symput("zmin", zmin); call symput("zmax", zmax);
  end;
run;

/*--Normalize the data to -1 to +1 ranges--*/
data normalized;
  keep &Group &Size x y z xf yf zf xb yb zb xb2 yb2 zb2 xs ys zs xs2 ys2 zs2;
  xrange=&xmax-&xmin;
  yrange=&ymax-&ymin;
  zrange=&zmax-&zmin;
  set &data;

  /*--data points--*/
  x=2*(&X-&xmin)/xrange -1;
  y=2*(&Y-&ymin)/yrange -1;
  z=2*(&Z-&zmin)/zrange -1;

  /*--Floor--*/
  xf=x; yf=y; zf=-1;
  
  /*--Back Wall--*/
  xb=-1; yb=y; zb=z;
  xb2=-1; yb2=y; zb2=-1;

  /*--Side Wall--*/
  xs=x; ys=1; zs=z;
  xs2=x; ys2=1; zs2=-1;
run;

/*ods html;*/
/*proc print;run;*/
/*ods html close;*/

/*--Project the data--*/
data projected_data;
  keep &Group &Size xd yd zd xf yf zf xb yb zb xb2 yb2 zb2 xs ys zs xs2 ys2 zs2;
  array u[4,4] _temporary_;  /*--Intermediate Matrix--*/
  array v[4,4] _temporary_;  /*--Intermediate Matrix--*/
  array w[4,4] _temporary_;  /*--Final View Matrix--*/
  array m[4,4] _temporary_;  /*--Projection Matrix--*/
  array rx[4,4] _temporary_; /*--X rotation Matrix--*/
  array ry[4,4] _temporary_; /*--Y rotation Matrix--*/
  array rz[4,4] _temporary_; /*--Z rotation Matrix--*/
  array d[4,1] _temporary_;  /*--World Data Array --*/
  array p[4,1] _temporary_;  /*--Projected Data Array --*/
  retain r t f n;
  r=1; t=1; f=1; n=-1;
  pi=constant("PI");
  fac=pi/180;
/*  call symput ("X", A); call symput ("Y", B); call symput ("Z", C);*/
  A=&A*fac; B=&B*fac; C=&C*fac;

  /*--Set up projection matrix--*/
  m[1,1]=1/r;   m[1,2]=0.0;  m[1,3]=0.0;      m[1,4]=0.0;
  m[2,1]=0.0;   m[2,2]=1/t;  m[2,3]=0.0;      m[2,4]=0.0;
  m[3,1]=0.0;   m[3,2]=0.0;  m[3,3]=-2/(f-n); m[3,4]=-(f+n)/(f-n);
  m[4,1]=0.0;   m[4,2]=0.0;  m[4,3]=0.0;      m[4,4]=1.0;

  /*--Set up X rotation matrix--*/
  rx[1,1]=1;     rx[1,2]=0.0;     rx[1,3]=0.0;      rx[1,4]=0.0;
  rx[2,1]=0.0;   rx[2,2]=cos(A);  rx[2,3]=-sin(A);  rx[2,4]=0.0;
  rx[3,1]=0.0;   rx[3,2]=sin(A);  rx[3,3]=cos(A);   rx[3,4]=0.0;
  rx[4,1]=0.0;   rx[4,2]=0.0;     rx[4,3]=0.0;      rx[4,4]=1.0;

  /*--Set up Y rotation matrix--*/
  ry[1,1]=cos(B);  ry[1,2]=0.0;  ry[1,3]=sin(B);  ry[1,4]=0.0;
  ry[2,1]=0.0;     ry[2,2]=1.0;  ry[2,3]=0.0;     ry[2,4]=0.0;
  ry[3,1]=-sin(B); ry[3,2]=0.0;  ry[3,3]=cos(B);  ry[3,4]=0.0;
  ry[4,1]=0.0;     ry[4,2]=0.0;  ry[4,3]=0.0;     ry[4,4]=1.0;

  /*--Set up Z rotation matrix--*/
  rz[1,1]=cos(C);  rz[1,2]=-sin(C); rz[1,3]=0.0;  rz[1,4]=0.0;
  rz[2,1]=sin(C);  rz[2,2]=cos(C);  rz[2,3]=0.0;  rz[2,4]=0.0;
  rz[3,1]=0.0;     rz[3,2]=0.0;     rz[3,3]=1.0;  rz[3,4]=0.0;
  rz[4,1]=0.0;     rz[4,2]=0.0;     rz[4,3]=0.0;  rz[4,4]=1.0;
  
  /*--Build transform matris--*/
  call MatMult(rz, m, u);
  call MatMult(ry, u, v);
  call MatMult(rx, v, w);

  set normalized;

  /*--Transform data--*/
  d[1,1]=x; d[2,1]=y; d[3,1]=z; d[4,1]=1;
  call MatMult(w, d, p);
  xd=p[1,1]; yd=p[2,1]; zd=p[3,1]; wd=p[4,1];

  /*--Transform floor drop shadow--*/
  d[1,1]=xf; d[2,1]=yf; d[3,1]=zf; d[4,1]=1;
  call MatMult(w, d, p);
  xf=p[1,1]; yf=p[2,1]; zf=p[3,1]; wf=p[4,1];

  /*--Transform back wall shadow--*/
  d[1,1]=xb; d[2,1]=yb; d[3,1]=zb; d[4,1]=1;
  call MatMult(w, d, p);
  xb=p[1,1]; yb=p[2,1]; zb=p[3,1]; wb=p[4,1];

  d[1,1]=xb2; d[2,1]=yb2; d[3,1]=zb2; d[4,1]=1;
  call MatMult(w, d, p);
  xb2=p[1,1]; yb2=p[2,1]; zb2=p[3,1]; wb2=p[4,1];

  /*--Transform side wall shadow--*/
  d[1,1]=xs; d[2,1]=ys; d[3,1]=zs; d[4,1]=1;
  call MatMult(w, d, p);
  xs=p[1,1]; ys=p[2,1]; zs=p[3,1]; ws=p[4,1];

  d[1,1]=xs2; d[2,1]=ys2; d[3,1]=zs2; d[4,1]=1;
  call MatMult(w, d, p);
  xs2=p[1,1]; ys2=p[2,1]; zs2=p[3,1]; ws2=p[4,1];
run;

/*--Combine data with walls--*/
data combined;
  merge projected_walls projected_data;
run;

/*ods html;*/
/*proc print;run;*/
/*ods html close;*/

%let h=_; 
%let suf=&a&h&c;

/*--Draw the graph--*/
title "&Title";
footnote j=l  h=0.7 "X-Rotation=&A  Y-Rotation=&B  Z-Rotation=&C";
proc sgplot data=combined nowall noborder aspect=1 noautolegend dattrmap=&Attrmap;
  polygon id=id x=xw y=yw / fill lineattrs=(color=lightgray) 
          group=id transparency=0 attrid=walls;
  vector x=xw2 y=yw2 / xorigin=xw yorigin=yw group=group noarrowheads attrid=Axes;
  text x=xl y=yl text=lbx / position=bottomleft;
  text x=xl y=yl text=lby / position=bottomright;
  text x=xl y=yl text=lbz / position=left;

  /*--Back wall shadow--*/
  vector x=xb y=yb / xorigin=xb2 yorigin=yb2 noarrowheads lineattrs=(color=gray) transparency=0.9;
  scatter x=xb y=yb / markerattrs=(symbol=circlefilled size=5) group=&group transparency=0.9;
  
  /*--Side wall shadow--*/
  vector x=xs y=ys / xorigin=xs2 yorigin=ys2 noarrowheads lineattrs=(color=gray) transparency=0.9;
  scatter x=xs y=ys / markerattrs=(symbol=circlefilled size=5) group=&group transparency=0.9;
  
  /*--Floor shadow--*/
  vector x=xd y=yd / xorigin=xf yorigin=yf noarrowheads lineattrs=(color=gray) transparency=0.7;
  scatter x=xf y=yf / markerattrs=(symbol=circlefilled size=5) group=&group transparency=0.7;

  /*--Data--*/
/*  bubble x=xd y=yd size=&Size / group=&Group name='s' nomissinggroup dataskin=gloss*/
/*         bradiusmax=10 bradiusmin=6;*/
  scatter x=xd y=yd / group=&Group name='s' nomissinggroup dataskin=gloss
         filledoutlinedmarkers markerattrs=(symbol=circlefilled size=12) dataskin=gloss;

  keylegend 's' / autoitemsize;
  xaxis display=none offsetmin=0.05 offsetmax=0.05 min=-1.8 max=1.8;
  yaxis display=none offsetmin=0.05 offsetmax=0.05 min=-1.8 max=1.8;
  run;
footnote;

%finished:
%mend Ortho3D_Macro;

/*--Define walls and axes--*/
data wall_Axes;
  input id $ group $ xw yw zw xw2 yw2 zw2 xl yl zl label;
/*  length lbx lby lbz $20;*/
/*  if id eq 'X1-Axis' then lbx='Ht (X)';*/
/*  if id eq 'Y3-Axis' then lby='Age (Y)';*/
/*  if id eq 'Z1-Axis' then lbz='Wt (Z)';*/
  datalines;
  X1-Axis  D -1  -1   -1     1  -1  -1     0   -1  -1  1
  X3-Axis  L -1  -1    1     1  -1   1     .    .   .  .
  X4-Axis  D -1   1    1     1   1   1     .    .   .  .
  Y2-Axis  D -1  -1    1    -1   1   1     .    .   .  .
  Y3-Axis  D  1  -1   -1     1   1  -1     1    0  -1  2
  Y4-Axis  L  1  -1    1     1   1   1     .    .   .  .
  Z1-Axis  D -1  -1   -1    -1  -1   1    -1   -1   0  3
  Z2-Axis  L  1  -1   -1     1  -1   1     .    .   .  .
  Z4-Axis  D  1   1   -1     1   1   1     .    .   .  .
  Bottom   D -1  -1   -1    .   .   .      .    .   .  .
  Bottom   D  1  -1   -1    .   .   .      .    .   .  .
  Bottom   D  1   1   -1    .   .   .      .    .   .  .
  Bottom   D -1   1   -1    .   .   .      .    .   .  .
  Back     D -1  -1   -1    .   .   .      .    .   .  .
  Back     D -1   1   -1    .   .   .      .    .   .  .
  Back     D -1   1    1    .   .   .      .    .   .  .
  Back     D -1  -1    1    .   .   .      .    .   .  .
  Right    D -1   1   -1    .   .   .      .    .   .  .
  Right    D  1   1   -1    .   .   .      .    .   .  .
  Right    D  1   1    1    .   .   .      .    .   .  .
  Right    D -1   1    1    .   .   .      .    .   .  .
;
run;
/*proc print;run;*/

/*--Define Attributes map for walls and axes--*/
data attrmap;
length ID $ 9 fillcolor $ 10 linecolor $ 10 linepattern $ 10;
input id $ value $10-20 fillcolor $ linecolor $ linepattern $;
datalines;
Walls    Bottom     cxdfdfdf   cxdfdfdf   Solid     
Walls    Back       cxefefef   cxefefef   Solid    
Walls    Right      cxffffff   cxffffff   Solid    
Axes     D          white      black      Solid
Axes     L          white      black      ShortDash
;
run;
/*proc print;run;*/

options mautosource mprint mlogic;
ods html close;

data sedans;
  set sashelp.cars(where=(type eq 'Sedan'));
  run;

ods listing gpath=&gpath image_dpi=&dpi;
ods graphics / reset attrpriority=color width=4in height=3in imagename="Class";
%Ortho3D_Macro (Data=sashelp.class, WallData=wall_Axes, X=height, Y=Age, Z=Weight,
          Lblx=Height, Lbly=Age, Lblz=Weight, Group=Sex, Attrmap=attrmap, Tilt=65, 
          Rotate=-55, Title=Plot of Weight by Height and Weight);

ods graphics / reset attrpriority=color width=4in height=3in imagename="Sedans";
%Ortho3D_Macro (Data=sedans, WallData=wall_Axes, X=horsepower, Y=Weight, Z=mpg_city,
          Lblx=Horsepower, Lbly=Weight, Lblz=Mileage, Group=origin, Attrmap=attrmap, 
          Tilt=65, Rotate=-55, Title=Plot of Mileage by Horsepower and Weight);

