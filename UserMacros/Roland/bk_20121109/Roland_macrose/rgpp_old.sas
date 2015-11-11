*- Assign the macro store library and set options to use it -; 
libname _mstore "C:\mstored"; 
options mstored mcompilenote=all sasmstore=_mstore ;


%macro rgpp(giveinfo) / store secure;

*- Copyright © Roland Rashleigh-Berry, 2008 -;
*- Version 4.0, 02Jan2009 -;

/* possible hack negation */
macro nomprint NOMPRINT %
macro nomlogic NOMLOGIC %
macro nosource NOSOURCE %


%local storeopts;


                /*=====================================*
                 *=====================================*
                          Source code protection
                 *=====================================*
                 *=====================================*/

%let storeopts=
%sysfunc(getoption(source,keyword)) %sysfunc(getoption(source2,keyword))
%sysfunc(getoption(mprint,keyword)) %sysfunc(getoption(macrogen,keyword)) 
%sysfunc(getoption(symbolgen,keyword)) %sysfunc(getoption(mlogic,keyword))
;

options nosource nosource2 nomprint nomacrogen nosymbolgen nomlogic;

run;

%local i patient;



                /*=====================================*
                 *=====================================*
                            Macro information
                 *=====================================*
                 *=====================================*/

%if %length(&giveinfo) %then %do;
  %put NOTE: (rgpp) This is version 4.0 of RGPP. Make sure you are using version 4.0 of;
  %put NOTE: (rgpp) rgpp_style template code which can be found on the RGPP main page. ;
  %put;
  %put NOTE: (rgpp) Terms for use of this software is set out on the following page: ;
  %put NOTE: (rgpp) http://www.datasavantconsulting.com/roland/rgpp_terms.html ;
%end;



/**
This is Rolands Graphical Patient Profiler main macro.
It relies on there being datasets it can read in by the
names of rgpp_style, rgpp_global, rgpp_patients and
rgpp_data. The first two datasets are effectively macro
parameter datasets and their contents will be turned
into local macro variables. This will be done next.
Note that the %rgpp macro has one macro parameter. This
single positional parameter that is set to give macro
information also serves to allow "call symput" to
create local macro variables rather than global ones.
**/


                /*=====================================*
                 *=====================================*
                      Create local macro variables
                 *=====================================*
                 *=====================================*/


/* Turn rgpp_style and rgpp_global into local macro variables.
   For a list of what these are, refer to the documentation. */
data _null_;
  *- "merge", not "set", is used as we want only one observation -;
  merge rgpp_style rgpp_global; 
  array _num {*} _numeric_; 
  array _char {*} _character_; 
  length __y $ 32; 
  do __i=1 to dim(_char); 
    __y=vname(_char(__i)); 
    call symput(__y,trim(left(_char(__i)))); 
  end; 
  do __i=1 to dim(_num); 
    __y=vname(_num(__i)); 
    call symput(__y,trim(left(_num(__i)))); 
  end; 
run; 


                /*=====================================*
                 *=====================================*
                    Declare some needed minor macros
                 *=====================================*
                 *=====================================*/

/**
  %rgpp calls several other macros to do work for it. These
  are all "Rolands sas macros" that have been copied and
  stripped of their headers. Enclosing these macros ensures
  that nobody can mess around with the macros it needs that
  results in errors that can not be traced.
**/



              /*------------------------------------------*
                        declare annotate variables
               *------------------------------------------*/

%macro dclannovars;

  LENGTH html $ 1024 text $ 200;
  LENGTH function color $ 8;
  LENGTH style $ 32;
  LENGTH xsys ysys zsys hsys $ 1;
  LENGTH when position $ 1;

  LENGTH line size angle rotate x y z 8;

  RETAIN xsys '4' ysys '4' zsys '2' hsys '4';
  RETAIN position '+' when 'B';

  line=1;
  size=1;
  angle=0;
  rotate=0;
  x=0;
  y=0;
  z=0;
  html=' ';
  text=' ';
  function=' ';
  color=' ';

  KEEP html text function color style xsys ysys zsys hsys when position
       line size angle rotate x y z;

%mend dclannovars;



              /*------------------------------------------*
                        xyzhsys macro definition
               *------------------------------------------*/

%macro xyzhsys(xsys='4',
               ysys='4',
               zsys='2',
               hsys='4');
  xsys=&xsys;
  ysys=&ysys;
  zsys=&zsys;
  hsys=&hsys;

%mend xyzhsys;



              /*------------------------------------------*
                         drawline macro definition
               *------------------------------------------*/

%macro drawline(x1=,
                x2=,
                y1=,
                y2=,
         linecolor='black',
         linewidth=1);

x=&x1;y=&y1;line=1;color=&linecolor;size=&linewidth;function="move";output;
x=&x2;y=&y2;function="draw";output;

%mend drawline;



              /*------------------------------------------*
                         fillbar macro definition
               *------------------------------------------*/

%macro fillbar(x1=,
               x2=,
               y1=,
               y2=,
        fillcolor='beige');

x=&x1;y=&y1;line=3;color=&fillcolor;style="solid";function="move";output;
x=&x2;y=&y2;function="bar";output;
line=1;

%mend fillbar;



              /*------------------------------------------*
                           text macro definition
               *------------------------------------------*/

%macro text(x=,
            y=,
         text=' ',
        color=' ',
         font=' ',
       height=.,
         html=' ',
        angle=0,
       rotate=0,
     position='+');

  html=&html;
  x=&x;y=&y;color=&color;style=&font;text=&text;size=&height;
  angle=&angle;rotate=&rotate;position=&position;function="label";output;
  html=' ';

%mend text;



              /*------------------------------------------*
                          bigbox macro definition
               *------------------------------------------*/

%macro bigbox(x1=,
              x2=,
              y1=,
              y2=,
       linecolor='black',
       linewidth=1);

    x=&x1;y=&y1;function="poly";style="mempty";size=&linewidth;line=1;output;
    y=&y2;color=&linecolor;function="polycont";output;
    x=&x2;function="polycont";output;
    y=&y1;function="polycont";output;
    x=&x1;function="polycont";output;

%mend bigbox;



              /*------------------------------------------*
                           box macro definition
               *------------------------------------------*/

%macro box(x=,
           y=,
   fillcolor='green',
   linecolor='black',
   linewidth=1,
      height=0.4,
        html=' ',
       width=0.2,
 fillpattern="mempty");


  *- First time draw using "fillcolor" -;
  html=' ';
  x=&x-&width/2;y=&y-&height/2;function="poly";color=&fillcolor;style="msolid";size=&linewidth;output;
  x=&x+&width/2;line=1;color=&linecolor;function="polycont";output;
  y=&y+&height/2;function="polycont";output;
  x=&x-&width/2;function="polycont";output;
  y=&y-&height/2;function="polycont";output;

  *- Second time draw using "fillpattern" with pattern color same as line color. -;
  *- If you dont want a fill pattern then use fillpattern="mempty" -;
  html=&html;
  x=&x-&width/2;y=&y-&height/2;function="poly";color=&linecolor;style=&fillpattern;
line=1;output;
  html=' ';
  x=&x+&width/2;color=&linecolor;function="polycont";output;
  y=&y+&height/2;function="polycont";output;
  x=&x-&width/2;function="polycont";output;
  y=&y-&height/2;function="polycont";output;

%mend box;



              /*------------------------------------------*
                           rod macro definition
               *------------------------------------------*/

%macro rod(y=,
          x1=,
          x2=,
   fillcolor="green",
   linecolor="black",
   linewidth=1,
      height=0.4,
        html=' ',
  headfactor=1.5,
 fillpattern="mempty");

  *- First time draw using "fillcolor" -;
  html=' ';
  x=&x1;y=&y-&height/2;function="poly";color=&fillcolor;style="msolid";size=&linewidth;output;
  x=&x2;line=1;color=&linecolor;function="polycont";output;
  y=&y+&height/2;function="polycont";output;
  x=&x1;function="polycont";output;
  y=&y-&height/2;function="polycont";output;

  *- Second time draw using "fillpattern" with pattern color same as line color. -;
  *- If you dont want a fill pattern then use fillpattern="mempty" -;
  html=&html;
  x=&x1;y=&y-&height/2;function="poly";color=&linecolor;style=&fillpattern;line=1;output;
  html=' ';
  x=&x2;color=&linecolor;function="polycont";output;
  y=&y+&height/2;function="polycont";output;
  x=&x1;function="polycont";output;
  y=&y-&height/2;function="polycont";output;

%mend rod;



              /*------------------------------------------*
                   rarrow (right arrow) macro definition
               *------------------------------------------*/
 
%macro rarrow(y=,
             x1=,
             x2=,
      fillcolor="green",
      linecolor="black",
      linewidth=1,
         height=0.4,
           html=' ',
     headfactor=1.5,
    fillpattern="mempty");

  *- First time draw using "fillcolor" -;
  html=' ';
  x=&x1;y=&y-&height/2;function="poly";color=&fillcolor;style="msolid";
  size=&linewidth;line=1;output;
  x=&x2-&height*&headfactor;color=&linecolor;function="polycont";output;
  y=&y-&height;function="polycont";output;
  x=&x2;y=&y;function="polycont";output;
  x=&x2-&height*&headfactor;y=&y+&height;function="polycont";output;
  y=&y+&height/2;function="polycont";output;
  x=&x1;function="polycont";output;
  y=&y-&height/2;function="polycont";output;

  *- Second time draw using "fillpattern" with pattern color same as line color. -;
  *- If you dont want a fill pattern then use fillpattern="mempty" -;
  html=&html;
  x=&x1;y=&y-&height/2;function="poly";color=&linecolor;style=&fillpattern;line=1;output;
  html=' ';
  x=&x2-&height*&headfactor;color=&linecolor;function="polycont";output;
  y=&y-&height;function="polycont";output;
  x=&x2;y=&y;function="polycont";output;
  x=&x2-&height*&headfactor;y=&y+&height;function="polycont";output;
  y=&y+&height/2;function="polycont";output;
  x=&x1;function="polycont";output;
  y=&y-&height/2;function="polycont";output;

%mend rarrow;



              /*------------------------------------------*
                   larrow (left arrow) macro definition
               *------------------------------------------*/
 
%macro larrow(y=,
             x1=,
             x2=,
      fillcolor="green",
      linecolor="black",
      linewidth=1,
         height=0.4,
           html=' ',
     headfactor=1.5,
    fillpattern="mempty");


  *- First time draw using "fillcolor" -;
  html=' ';
  x=&x1;y=&y;function="poly";style="msolid";color=&fillcolor;size=&linewidth;line=1;output;
  x=&x1+&height*&headfactor;y=&y-&height;color=&linecolor;function="polycont";output;
  y=&y-&height/2;function="polycont";output;
  x=&x2;function="polycont";output;
  y=&y+&height/2;function="polycont";output;
  x=&x1+&height*&headfactor;function="polycont";output;
  y=&y+&height;function="polycont";output;
  x=&x1;y=&y;function="polycont";output;
  
  *- Second time draw using "fillpattern" with pattern color same as line color. -;
  *- If you dont want a fill pattern then use fillpattern="mempty" -;
  html=&html;
  x=&x1;y=&y;function="poly";color=&linecolor;style=&fillpattern;line=1;output;
  html=' ';
  x=&x1+&height*&headfactor;y=&y-&height;color=&linecolor;function="polycont";output;
  y=&y-&height/2;function="polycont";output;
  x=&x2;function="polycont";output;
  y=&y+&height/2;function="polycont";output;
  x=&x1+&height*&headfactor;function="polycont";output;
  y=&y+&height;function="polycont";output;
  x=&x1;y=&y;function="polycont";output;

%mend larrow;



              /*------------------------------------------*
                 dblarrow (double arrow) macro definition
               *------------------------------------------*/
 
%macro dblarrow(y=,
               x1=,
               x2=,
        fillcolor="green",
        linecolor="black",
        linewidth=1,
           height=0.4,
             html=' ',
       headfactor=1.5,
      fillpattern="mempty");


  *- First time draw using "fillcolor" -;
  html=' ';
  x=&x1;y=&y;function="poly";style="msolid";color=&fillcolor;size=&linewidth;line=1;output;
  x=&x1+&height*&headfactor;y=&y-&height;color=&linecolor;function="polycont";output;
  y=&y-&height/2;function="polycont";output;
  x=&x2-&height*&headfactor;function="polycont";output;
  y=&y-&height;function="polycont";output;
  x=&x2;y=&y;function="polycont";output;
  x=&x2-&height*&headfactor;y=&y+&height;function="polycont";output;
  y=&y+&height/2;function="polycont";output;
  x=&x1+&height*&headfactor;function="polycont";output;
  y=&y+&height;function="polycont";output;
  x=&x1;y=&y;function="polycont";output;

  *- Second time draw using "fillpattern" with pattern color same as line color. -;
  *- If you dont want a fill pattern then use fillpattern="mempty" -;
  html=&html;
  x=&x1;y=&y;function="poly";color=&linecolor;style=&fillpattern;line=1;output;
  html=' ';
  x=&x1+&height*&headfactor;y=&y-&height;color=&linecolor;function="polycont";output;
  y=&y-&height/2;function="polycont";output;
  x=&x2-&height*&headfactor;function="polycont";output;
  y=&y-&height;function="polycont";output;
  x=&x2;y=&y;function="polycont";output;
  x=&x2-&height*&headfactor;y=&y+&height;function="polycont";output;
  y=&y+&height/2;function="polycont";output;
  x=&x1+&height*&headfactor;function="polycont";output;
  y=&y+&height;function="polycont";output;
  x=&x1;y=&y;function="polycont";output;

%mend dblarrow;



              /*------------------------------------------*
                           attrn macro definition
               *------------------------------------------*/

%macro attrn(ds,attrib);
%local dsid rc;
%let dsid=%sysfunc(open(&ds,is));
%if &dsid EQ 0 %then %do;
  %put ERROR: (attrn) Dataset &ds not opened due to the following reason:;
  %put %sysfunc(sysmsg());
%end;
%else %do;
%sysfunc(attrn(&dsid,&attrib))
  %let rc=%sysfunc(close(&dsid));
%end;
%mend;

              /*------------------------------------------*
                           nobs macro definition
               *------------------------------------------*/

%macro nobs(ds);
%local nobs;
%let nobs=%attrn(&ds,nobs);
%if &nobs LT 0 %then %let nobs=0;
&nobs
%mend;


              /*------------------------------------------*
                           words macro definition
               *------------------------------------------*/

%macro words(str,delim=%str( ));
%local i;
%let i=1;
%do %while(%length(%qscan(&str,&i,&delim)) GT 0);
  %let i=%eval(&i + 1);
%end;
%eval(&i - 1)
%mend;

              /*------------------------------------------*
                        getvalue macro definition
               *------------------------------------------*/

%macro getvalue(ds,var,obs);
%local dsid rc varnum value;
%if not %length(&obs) %then %let obs=1;
%let dsid=%sysfunc(open(&ds,is));
%if &dsid EQ 0 %then %do;
  %put ERROR: (getvalue) Dataset &ds not opened due to the following reason:;
  %put %sysfunc(sysmsg());
%end;
%else %do;
  %let varnum=%sysfunc(varnum(&dsid,&var));
  %if &varnum LT 1 %then %put ERROR: (getvalue) Variable &var not in dataset
&ds;
  %else %do;
    %let rc=%sysfunc(fetchobs(&dsid,&obs));
    %if &rc = -1 %then %put ERROR: (getvalue) Observation &obs is beyond dataset end;
    %else %do;
      %if "%sysfunc(vartype(&dsid,&varnum))" EQ "C" %then %do;
        %let value=%sysfunc(getvarc(&dsid,&varnum));
"&value"
      %end;
      %else %do;
        %let value=%sysfunc(getvarn(&dsid,&varnum));
&value
      %end;
    %end;
  %end;
  %let rc=%sysfunc(close(&dsid));
%end;
%mend;



                /*=====================================*
                 *=====================================*
                   Define the graphics annotate macro 
                 *=====================================*
                 *=====================================*/

%macro rgpp_anno(dsin=,
             htmlfile=,
              gifname=,
          minscaleday=,
           mindataday=,
           maxdataday=,
          maxscaleday=
                );

*- select only the data in range for non-demog data -;
data _rgpp_render_data;
  set &dsin;
  *- reject or alter non-demography data not in range -;
  if not blockisdemog and missing(pctdata1) and missing(pctdata2) then do;
    if .<day2<&mindataday then delete;
    if .<day1<&mindataday and missing(day2) then delete;
    if day1>&maxdataday then delete;
    *- impute day1 where it is less than start day -;
    if day1<&minscaleday then do;
      day1=&minscaleday;
      day1_imp=1;
    end;
    *- impute day2 where it is greater than end day -;
    if day2>&maxscaleday then do;
      day2=&maxscaleday;
      day2_imp=1;
    end;
  end;
run;

*- prepare the ods html output file -;
ods html path=_webout body="&htmlfile..html";

data _rgpp_anno;
  length day1 day2 pctdata1 pctdata2 8;
  array tickdays {20} _temporary_ (20*999999);
  array ticklabels {20} $ 24 _temporary_ (20*" ");
  retain lowtickx hightickx maxticks tickspacing maxletters 0 ;
  retain holdy itemcount holdx1 0;
  retain scale "&scale" siteno "&syssite";
  length workhtml $ 1024 worktext $ 32 bit $ 40 workcolor $ 8;
  %dclannovars
  KEEP day1 day2 pctdata1 pctdata2;
  set _rgpp_render_data;
  by blockseq itemseq;

  *====================== FIRST TIME THROUGH =================;

  *- Do for first time through, fill the tick arrays and draw the patient number -;
  if _n_=1 then do;
    storeday1=day1;
    link filltickra;
    day1=storeday1;
    holdy=&vpos;
    if siteno ne "0042234001x" then do;
      holdy=&vpos-1;
      %text(x=&hposdmean,y=holdy,color="gray",height=0.8,font="'Arial / bold'",
            text="Roland's Graphical Patient Profiler (version 4.0)",
            html='ALT="" TITLE="Click here for the main RGPP page" HREF="http://www.datasavantconsulting.com/roland/rgpp.html"');
      holdy=holdy-0.8;
      %text(x=&hposdmean,y=holdy,color="gray",height=0.7,font="'Arial'",
            text="Copyright © Roland Rashleigh-Berry, 2008 (rolandberry@hotmail.com)",
            html='ALT="" TITLE="Click here for terms of use" HREF="http://www.datasavantconsulting.com/roland/rgpp_terms.html"');
      holdy=holdy-0.4;
    end;
    holdy=holdy-0.5;
    %fillbar(y1=holdy,x1=&hposdmean-(&wpatientbg/2),
             y2=holdy-&hpatientbg,x2=&hposdmean+(&wpatientbg/2),
             fillcolor="&cpatientbg");
    %text(x=&hposdmean,y=holdy-(&hpatientbg/2),
          text=trim(left(&patvar)),height=&hpatient,
          color="&cpatient",font="&fpatient");
    holdy=holdy-&hpatientbg+1;
  end;
  *- End of do-for-first-time-through -;

  *===================== FIRST IN THE BLOCK ===================;

  *- Do for first blockseq - draw the block description -;
  if first.blockseq then do;
    holdy=holdy-2;
    *- leave an extra blank line for a message block -;
    if blockismsg then holdy=holdy-1;
    %fillbar(y1=holdy,x1=&hposdmean-(&wblockdescbg/2),
             y2=holdy-&hblockdescbg,x2=&hposdmean+(&wblockdescbg/2),
             fillcolor="&cblockdescbg");
    %text(x=&hposdmean,y=holdy-(&hblockdescbg/2),
          text=trim(left(blockdesc)),height=&hblockdesc,
          color="&cblockdesc",html=blockhtml,font="&fblockdesc");
    itemcount=0;
    holdy=holdy-&hblockdescbg-2;
  end;
  *- End of do-for-first-blockseq -;


  *- Do if not blockismsg -;
  if not blockismsg then do;

    *============== FIRST OF AN ITEM SEQUENCE NUMBER ============;

    *- Do for first item in itemseq, draw a striping bar and   -;
    *- write the item description to the left of the date area. -;
    if first.itemseq then do;

      itemcount=itemcount+1;

      *- set holdx1 to a low value -;
      holdx1=-99;

      *- for alternate lines, stripe across -;
      *- Do for stripeonfirst -;
      if &stripeonfirst then do;
        if mod(itemcount,2) EQ 1 then do;
          %fillbar(y1=holdy-0.5,x1=&hposdmin,
                   y2=holdy+0.5,x2=&hposdmax,
                   fillcolor="&cstripe");
        end;
      end;
      *- end of do-for-stripe-on-first -;
      *- Do for if not stripeonfirst -;
      else do;
        if mod(itemcount,2) EQ 0 then do;
          %fillbar(y1=holdy-0.5,x1=&hposdmin,
                   y2=holdy+0.5,x2=&hposdmax,
                   fillcolor="&cstripe");
        end;
      end;
      *- end of do-for-if-not-stripeonfirst -;

      *- Check against the maximum number of characters that can -;
      *- be displayed in the space available. For text all in    -;
      *- upper case, a smaller number is appropriate. -;
      if scan(itemdesc,1,"(")=upcase(scan(itemdesc,1,"(")) then maxletters=&maxucletters;
      else maxletters=&maxmcletters;

      if missing(fitemdesc) then fitemdesc="&fitemdesc";
      if missing(citemdesc) then citemdesc="&citemdesc";
      if missing(hitemdesc) then hitemdesc=&hitemdesc;

      *- If the text is too long to fit then put the full text  -;
      *- in an html hotspot and display the truncated text from -;
      *- the left (which helps the hotspot to be located). -;
      *- do for length(itemdesc) GT maxletters -;
      if length(itemdesc) GT maxletters then do;
        workhtml='ALT="" TITLE="'||trim(itemdesc)||'"';
        %text(y=holdy,x=0,position=">",html=workhtml,
              text=substr(itemdesc,1,maxletters-2)||"...",
              height=hitemdesc,color="&citemdesctrunc",
              font=fitemdesc);
      end;
      *- end of do-for-if-length(itemdesc)-GT-maxletters -;
      *- do if not length(itemdesc) GT maxletters -;
      else do;
        %text(y=holdy,x=&hposdmin-0.3,position="<",text=itemdesc,
             height=hitemdesc,color=citemdesc,font=fitemdesc);
      end;
      *- end of do-if-not-length(itemdesc)-GT-maxletters -;
    end;

    *=============================================================;
    *=================== DEAL WITH ITEM DATA =====================;
    *=============================================================;


    if citemline=" " then citemline="&citemline";
    if missing(witemline) then witemline=&witemline;
    if mitemfill=" " then mitemfill="mempty";

                 *============ PERIOD DATA ===========;

    *- Do if not missing(day2) -;
    if not missing(day2) then do;
      if citemtext=" " then citemtext="&cfigure";
      link calcx1;
      link calcx2;
      *- do if (x2-x1) LE hposmingap -;
      if (x2-x1) LE &hposmingap then do;
        x1=(x1+x2)/2;
        link doabox;
      end;
      *- end of do-if-(x2-x1)-LE-hposmingap -;
      *- do if (x2-x1) not LE hposmingap -;
      else do;
        *- do if usearrows -;
        if &usearrows then do;
          *- Use an arrow head to signify an imputed day. -;

          *- if day1 and day2 are imputed then use a double arrow shape -;
          if day1_imp and day2_imp then do;
            %dblarrow(y=holdy,x1=x1,x2=x2,height=&hfigure,linewidth=witemline,
                      fillcolor=citemtext,linecolor=citemline,html=itemhtml,
                      fillpattern=mitemfill);
          end;
          *- else if just day1 is imputed then use a left arrow shape -;
          else if day1_imp then do;
            %larrow(y=holdy,x1=x1,x2=x2,height=&hfigure,linewidth=witemline,
                    fillcolor=citemtext,linecolor=citemline,html=itemhtml,
                    fillpattern=mitemfill);
          end;
          *- else if just day2 is imputed then use a right arrow shape -;
          else if day2_imp then do;
            %rarrow(y=holdy,x1=x1,x2=x2,height=&hfigure,linewidth=witemline,
                    fillcolor=citemtext,linecolor=citemline,html=itemhtml,
                    fillpattern=mitemfill);
          end;
          else do;
            %rod(y=holdy,x1=x1,x2=x2,height=&hfigure,linewidth=witemline,
                 fillcolor=citemtext,linecolor=citemline,html=itemhtml,
                 fillpattern=mitemfill);
          end;
        end;
        *- end of do-if-usearrows -;
        *- do if not usearrows -;
        else do;
          %rod(y=holdy,x1=x1,x2=x2,height=&hfigure,linewidth=witemline,
               fillcolor=citemtext,linecolor=citemline,html=itemhtml,
               fillpattern=mitemfill);
        end;
        *- end of do-if-not-usearrows -;
      end;
      *- end of do-if-(x2-x1)-not-LE-hposmingap -;
    end;

              *========== DEMOGRAPHY DATA ===========;

    *- do if blockisdemog -;
    else if blockisdemog then do;
      if citemtext=" " then citemtext="&citemtext";
      if missing(hitemtext) then hitemtext=&hitemtext;
      if missing(fitemtext) then fitemtext="&fitemtext";

      *- Demography data is handled differently in that itemtext -;
      *- needs to be left aligned within the date area. -;
      %text(y=holdy,x=&hposdmin+0.3,text=trim(left(itemtext)),font=fitemtext,
            position=">",color=citemtext,html=itemhtml,height=hitemtext);
    end;
    *- end of do-if-block-is-demog -;

              *========== TIMEPOINT DATA ============;

    *- do if not blockisdemog -;
    else do;
      if missing(hitemtext) then hitemtext=&hitemtext;
      if missing(fitemtext) then fitemtext="&fitemtext";
      link calcx1;
      *- do if text exists draw the text -;
      if not missing(itemtext) then do;
        *- if far enough away from previous one then show as text -;
        if (x1-holdx1) GT &hposmingap then do;
          if citemtext=" " then citemtext="&citemtext";
          %text(y=holdy,x=x1,text=trim(itemtext),height=hitemtext,
                position="+",color=citemtext,html=itemhtml,
                font=fitemtext);
        end;
        *- else if too close to previous one then show as a box -;
        else do;
          if citemtext=" " then citemtext="&cfigure";
          link doabox;
        end;
      end;
      *- end of do-if-text-exists-draw-the-text -;
      else do;
        if citemtext=" " then citemtext="&cfigure";
        link doabox;
      end;
    end;
    *- end of do-if-not-blockisdemog -;

    /*==============================================================*/
    /*================ END OF DEAL-WITH-ITEM-DATA ==================*/
    /*==============================================================*/

    holdx1=x1;

    *- Decrement "holdy" after all the items have been -;
    *- displayed for an item sequence number. -;
    if last.itemseq then do;
      holdy=holdy-1;
    end;
 
    *- Once a block of items is finished then draw a box around it -;
    if last.blockseq then do;
      if not blockismsg then do;
        if &drawblockbox then do;
          %bigbox(linecolor="&cblockbox",x1=&hposdmin,y1=holdy,
                  x2=&hposdmax,y2=holdy+itemcount+1);
        end;
        *- additionally, draw a date scale if the flag variable is set -;
        if blockscale then do;
          link drawscale;
        end;
      end;
    end;

  end;
  *- end of do-if-block-is-msg -;  

  return;


  /*===============================================================*/
  /*========================= LINK ROUTINES =======================*/
  /*===============================================================*/

  doabox:
    %box(y=holdy,x=x1,width=&hposminfigwidth,height=&hfigure,
         linewidth=witemline,fillcolor=citemtext,linecolor=citemline,
         html=itemhtml,fillpattern=mitemfill);
  return;

  propx1:
    *- calculate x1 for proportional time ticks -;
    x1=((day1-&minscaleday)/(&maxscaleday-&minscaleday))*(&hposdmax-&hposdmin)+&hposdmin; 
  return; 

  propx2:
    *- calculate x2 for proportional time ticks -;
    x2=((day2-&minscaleday)/(&maxscaleday-&minscaleday))*(&hposdmax-&hposdmin)+&hposdmin; 
  return; 

  equalx1:
    *- calculate x1 for equi-distant time ticks -;
    i=1;
    do while(day1 GE tickdays(i));
      i=i+1;
    end;
    if i<2 or i>maxticks then link propx1;
    else x1=lowtickx+(i-2)*tickspacing+
      (day1-tickdays(i-1))/(tickdays(i)-tickdays(i-1))*tickspacing;
  return;

  equalx2:
    *- calculate x2 for equi-distant time ticks -;
    i=1;
    do while(day2 GE tickdays(i));
      i=i+1;
    end;
    if i<2 or i>maxticks then link propx2;
    else x2=lowtickx+(i-2)*tickspacing+
      (day2-tickdays(i-1))/(tickdays(i)-tickdays(i-1))*tickspacing;
  return;

  calcx1:
    *- calculate x1 depending on the tick scaling -;
    if not missing(pctdata1) then x1=(&hposdmax-&hposdmin)*pctdata1/100+&hposdmin;
    else do;
      if &uniformscale then link equalx1;
      else link propx1;
    end;
  return;

  calcx2:
    *- calculate x2 depending on the tick scaling -;
    if not missing(pctdata2) then x2=(&hposdmax-&hposdmin)*pctdata2/100+&hposdmin;
    else do;
      if &uniformscale then link equalx2;
      else link propx2;
    end;
  return;

  filltickra:
    *- Fill the tick arrays with information in the scale and  -;
    *- calculate other useful information concerning the ticks -;
    i=1;
    maxticks=0;
    bit=scan(scale,i,"|");
    do while(bit ne " ");
      day1=input(scan(bit,1,"#"),6.); 
      worktext=left(scan(bit,2,"#")); 
      if day1 LE &maxdataday then do;
        link propx1;
        maxticks=maxticks+1;
        if i=1 then lowtickx=x1;
	else hightickx=x1;
        tickdays(i)=day1;
        ticklabels(i)=worktext;
      end;
      i=i+1;
      bit=scan(scale,i,"|");
    end;
    tickspacing=(hightickx-lowtickx)/(maxticks-1);
  return;

  drawscale:
    *- Routine to draw a date scale below the block box -;
    workcolor="&cblockbox";
    if not &drawblockbox then do;
      workcolor="&cscale";
      *- we have to draw the axis line if drawblockbox ne 1 -;
      %drawline(x1=&hposdmin,x2=&hposdmax,y1=holdy,y2=holdy,
                linecolor=workcolor);
    end;
    *- drop a line for the the scale text -;
    holdy=holdy-1;
    *- do for each of the tick labels -;
    pctdata1=.;
    pctdata2=.;
    do j=1 to maxticks;
      day1=tickdays(j);
      link calcx1;
      *- draw the tick label -;
      %text(y=holdy,x=x1,position="+",text=trim(ticklabels(j)),
            color=workcolor,height=&hscaletext,font="&fscaletext");
      *- draw the tick drop line -;
      %drawline(x1=x1,x2=x1,y1=holdy+0.6,y2=holdy+1,linecolor=workcolor);
    end;
    *- end of do-for-each-of-the-tick-labels -;
  return;
  *================================================================;
  *====================== END OF LINK ROUTINES ====================;
  *================================================================;
run;



*- Call proc ganno and set the description to a space to avoid -;
*- having a hotspot applied to the whole graphics output area. -;
proc ganno annotate=_rgpp_anno description=" " name="&gifname";
run;


*- Delete the grseg member so that a rerun can use the same name. -;
proc greplay igout=work.gseg nofs;
  delete &gifname;
  run;
quit;


%mend rgpp_anno;



                /*======================================*
                 *======================================*
                    Sort input data into correct order
                 *======================================*
                 *======================================*/


proc sort data=rgpp_patients;
  by &patvar;
run;

proc sort data=rgpp_data;
  by &patvar blockseq itemseq day1 day2 pctdata1 pctdata2;
run;


                /*=====================================*
                 *=====================================*
                    Create a patient-ids-only dataset
                 *=====================================*
                 *=====================================*/


*- This dataset will be used for selecting one obs at a  -;
*- time from rgpp_patients and symputting its variables. -;
proc sort nodupkey data=rgpp_patients(keep=&patvar)
                    out=_rgpp_patonly;
  by &patvar;
run;


            /*=============================================*
             *=============================================*
                Set up goptions and other graphics stuff
             *=============================================*
             *=============================================*/


*- set the goptions -;
goptions reset=all &transparency gsfmode=replace device=gif &border
         xpixels=&xpixels ypixels=&ypixels
	 hpos=&hpos vpos=&vpos cback=&cback
	 htext=&hitemdesc ftext=&fitemdesc ctext=&citemdesc
		 ;

*- This "ods listing close" prevents graphics output -;
*- being written to where we do not want it.    -;
ods listing close;


*- set up the fileref for the html and gif output folder -;
filename _webout "&webout";



          /*==================================================*
           *==================================================*
             Call the annotate macro for each of the patients
           *==================================================*
           *==================================================*/


%do i=1 %to %nobs(_rgpp_patonly);

  %let patient=%getvalue(_rgpp_patonly,&patvar,&i);

  data _null_;
    set rgpp_patients(where=(&patvar=&patient));
    call symput('htmlfile',trim(left(htmlfile)));
    call symput('gifname',trim(left(gifname)));
    call symput('minscaleday',trim(left(minscaleday)));
    call symput('mindataday',trim(left(mindataday)));
    call symput('maxdataday',trim(left(maxdataday)));
    call symput('maxscaleday',trim(left(maxscaleday)));
  run;

  %rgpp_anno(dsin=rgpp_data(where=(&patvar=&patient)),
         htmlfile=&htmlfile,
          gifname=&gifname,
      minscaleday=&minscaleday,
       mindataday=&mindataday,
       maxdataday=&maxdataday,
      maxscaleday=&maxscaleday
            );

%end;



            /*=============================================*
             *=============================================*
                          Close down and exit
             *=============================================*
             *=============================================*/


filename _webout clear;
ods html close;
ods listing;

%goto exit;

%check:
%if "%upcase(&giveinfo)" EQ "CHECK" %then %do;
%end;

%exit:

*- restore user system options -;
options &storeopts;

%mend rgpp;

run;
