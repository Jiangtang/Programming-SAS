  /*------------------------------------------------------------------*
   | The documentation and code below is supplied by HSR CodeXchange.             
   |              
   *------------------------------------------------------------------*/
                                                                                      
                                                                                      
                                                                                      
  /*------------------------------------------------------------------*
   | MACRO NAME  : plotmat
   | SHORT DESC  : Create a matrix of multiple scatterplots,
   |               may also print correlations
   *------------------------------------------------------------------*
   | CREATED BY  : Vierkant, Rob                 (04/09/2004 16:41)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | This macro will create a scatterplot matrix graphically
   | displaying the bivariate relationships between a number
   | of variables. The macro is similar to %SCATMAT but with
   | certain enhancements.
   |
   |
   | Author: Rob Vierkant
   |         email: vierknt@mayo.edu
   |         phone: 4-8993
   |
   | Input parameters:
   |
   | %plotmat(ds= dataset
   |          numvars= number of variables to be in matrix
   |                   (2 to 10)
   |          var1--var10= names of variables in the matrix.
   |                       If less than 10, then leave values
   |                       of remaining variables null
   |          title= title of scatterplot matrix
   |                 Default is null
   |          corr= option to print correlations with
   |                scatterplots. Options are YES or Y,
   |                and NO or N. Default is NO
   |         );
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :
   | MVS SAS v8    :
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :
   *------------------------------------------------------------------*
   | Copyright 2004 Mayo Clinic College of Medicine.
   |
   | This program is free software; you can redistribute it and/or
   | modify it under the terms of the GNU General Public License as
   | published by the Free Software Foundation; either version 2 of
   | the License, or (at your option) any later version.
   |
   | This program is distributed in the hope that it will be useful,
   | but WITHOUT ANY WARRANTY; without even the implied warranty of
   | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   | General Public License for more details.
   *------------------------------------------------------------------*/
 
%macro plotmat(ds=,numvars=,var1=,var2=,
               var3=,var4=,var5=,var6=,
               var7=,var8=,var9=,var10=,
               title=,corr=N);
 
****generate means and correlations;
proc corr data=&ds out=tmp noprint;
   var &var1 &var2 &var3 &var4 &var5
       &var6 &var7 &var8 &var9 &var10;
run;
data tmp; set tmp;
 
  ****create macro variables for all means;
  if _TYPE_='MEAN' then do;
    %do i=1 %to &numvars;
      call symput("m&i",trim(left
                  (put(&&var&i,10.2))));
    %end;
  end;
 
  ****create macro variables for all correlations;
  %do i=1 %to &numvars;
    if upcase(_NAME_)=upcase("&&var&i") then do;
    %do j=1 %to &numvars;
      %let k=%eval((&i-1)*&numvars+&j);
      call symput("c&k",trim(left
                  (put(&&var&j,10.2))));
    %end;
    end;
  %end;
run;
 
****create annotate data sets used to place
    correlation on scatterplot;
%if %upcase(&corr)=Y or %upcase(&corr)=YES
%then %do;
  %do i=1 %to &numvars;
    %do j=1 %to &numvars;
      %let k=%eval((&i-1)*&numvars+&j);
      data annot&k; function='label';
         xsys='3'; ysys='3'; y=96; x=50;
         hsys='3'; size=8; style='centx';
         text="correlation:  &&c&k"; output;
      run;
    %end;
  %end;
%end;
 
****graphic options;
goptions reset=global device=xcolor nodisplay
         gunit=pct border rotate=landscape;
 
****scatterplots for the off-diagonal;
symbol1 h=2 value=dot;
axis1 label=none minor=none
      value=(h=3 f=simplex);
axis2 label=none minor=none;
proc gplot data=&ds gout=plotmat;
 
   ****title if correlation=yes is specified;
   title;
   %if %upcase(&corr)=Y or %upcase(&corr)=YES
   %then %do;
      title h=8 f=centx ' ';
   %end;
   %do i=1 %to &numvars;
     %do j=1 %to &numvars;
       %let k=%eval((&i-1)*&numvars+&j);
       plot &&var&i*&&var&j / vaxis=axis1
                              haxis=axis1
                              name="g&i._&j"
       %if %upcase(&corr)=Y
       or %upcase(&corr)=YES %then %do;
          anno=annot&k
       %end;
       ;
     %end;
   %end;
run; quit;
 
****variable names and means for diagonal elements;
%do l=1 %to &numvars;
  proc gslide gout=plotmat name="m&l";
    title1 h=10 f=centx lspace=30
           "&&var&l";
    title2 h=10 f=centx lspace=8
           "Mean=&&m&l";
  run; quit;
%end;
 
****graph for the title;
proc gslide gout=plotmat name='title';
   title h=4 f=centx &title;
run; quit;
 
****create template;
goptions display;
proc greplay igout=plotmat tc=tempcat nofs;
 
   ****assign the x and y coordinates
       within the template for each graph
       that is to be represented;
   tdef m&numvars
   %let num=%eval(&numvars-1);
   %if &title= %then %let totpct=100;
   %else %let totpct=95;
   %do i=0 %to &num;
      %do j=1 %to &numvars;
         %let t=%eval(&i*&numvars+&j);
         %let lx=%eval(100*(&j-1)
                 /&numvars);
         %let ly=%eval(&totpct*
                 (&numvars-&i-1)/&numvars);
         %let uy=%eval(&totpct*
                 (&numvars-&i)/&numvars);
         %let rx=%eval(100*&j/&numvars);
 
         %let x=&t. / llx=&lx. lly=&ly.
                ulx=&lx. uly=&uy. urx=&rx.
                ury=&uy. lrx=&rx. lry=&ly;
         &x
      %end;
   %end;
   %if title^= %then %do;
      %let t=%eval(&t+1);
      %let x=&t. / llx=0 lly=0 ulx=0 uly=100
             urx=100 ury=100 lrx=100 lry=0;
      &x
   %end;
   ;
   template m&numvars;
 
   ****place graphs in the boxes created
       for template defined above;
   treplay
   %do i=1 %to &numvars;
      %do j=1 %to &numvars;
         %let t=%eval((&i-1)*&numvars+&j;
         &t:
         %if &i=&j %then %do;
            m&i
         %end;
         %else %do;
            g&i._&j
         %end;
      %end;
   %end;
   %if title^= %then %do;
      %let t=%eval(&t+1);
      &t:title
   %end;
   ;
run; quit;
 
****delete graphs from temporary catalogs;
proc catalog c=plotmat kill; run; quit;
%mend plotmat;
 

