/*<pre><b>
/ Program      : rannomac.sas
/ Version      : 2.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : Compile Roland's annotate macros
/ SubMacros    : none
/ Notes        : This is Roland's version of the SI supplied macro %annomac that
/                makes available the annotate macros for use in a data step to
/                help create an annotate dataset.
/
/                Note that except for %drawline the macros defined below draw
/                shapes that lie parallel to the x-axis only hence all the
/                macros use a single "y" parameter but use two "x" parameters
/                "x1" and "x2" to indicate the start and end x coordinates
/                (except for the %text and %box macros which only have one x
/                coordinate).
/
/                This macro must be used like %annomac in that it should be
/                called outside a data step to compile the macros whose macros
/                definitions are contained within before they can be used in a
/                data step.
/
/                The macros defined below do not call any of the SI supplied
/                annotate macros but you are expected to mix use with the SI
/                supplied annotate macros as needed (see usage notes below).
/
/                All macro parameters are named parameters, unlike the SI
/                supplied annotate macros which use positional parameters.
/
/                The values supplied to the parameters can be VARIABLE NAMES in
/                all cases in which case you have to make sure they are of the
/                correct type (numeric or character) and if character then of
/                sufficient length. The variable names you supply and use to
/                hold the values should be named differently to the annotate
/                dataset variable names (see the %dclannovars macro below for
/                a list of these variable names).
/
/                In your annotate data step you must define a length for the
/                "HTML" character variable long enough to contain your longest
/                assignment (if you are using this variable for html
/                "hotspots"). Recommended is the maximum allowed length of
/                1024. This is automatically set in the %dclannovars macro if
/                you call that macro. This length should also be applied to
/                your own variables you set up whose values you will pass to
/                html= as a variable name. 
/
/                Note that the variable named HTML is strictly an output
/                variable to be used in the output annotate dataset. You must
/                not treat this as a working variable as the macros defined
/                below will often reset the value of HTML to a space to ensure
/                that the scope of the instructions contained in the HTML
/                variable are limited to only the intended function. You will
/                typically require a working html variable (maybe named
/                HTMLWORK) and it is likely you have another html variable
/                in a dataset you are using for input. You must not name this
/                variable HTML in your input dataset nor use the HTML variable
/                as a working variable. You should make sure you set the
/                length of these other html variables to something suitable.
/                The maximum allowed length of 1024 is recommended. Note that
/                the %dclannovars macro contains a "keep" statement that will
/                only keep true annotate variables. If you want to keep more
/                variables then you will have to add another "keep" statement
/                to do this.
/
/                Most of these macros draw polygons. The shape is drawn twice
/                to allow you to define a both a fill color and additionally a
/                fill pattern drawn in the same color as the outline. This is
/                to allow you to use both the fill color and the fill pattern
/                to mean different things. For example, fill colors of "yellow"
/                "green" and "red" might indicate the severity of an AE and
/                the fill pattern might indicate relationship to study drug.
/                For the %box macro you should be aware that in most cases the
/                box will be too small for the fill pattern to be visible.
/
/                The thickness (or fatness) of the shapes drawn is controlled
/                by the "height" parameter. A "width" parameter additionally
/                applies to the box shape drawn by the %box macro.
/
/                If you do not want a fill pattern then specify
/                fillpattern="mempty". Note that the fill patterns are "map"
/                fill patterns (they begin with an "m"). See the SAS
/                documentation for how to correctly specify these patterns.
/
/                Macros definitions contained in this macro are as follows:
/                %rannomac: Dummy macro that does nothing
/                %dclannovars:  Declare the annotate variables
/                %xyzhsys:  Macro to define coordinate system to use
/                %text:     Like %label except all parameters are named
/                %box:      Draw a small box that is centered
/                %rod:      Like %rect except you can fill it
/                %rarrow:   Right arrow (arrow head points right)
/                %larrow:   Left arrow (arrow head points left)
/                %dblarrow: Double arrow (arrow heads on both ends)
/                %drawline: Draw a line
/                %bigbox:   Draw a big (empty) box
/                %fillbar:  Draw a fill bar (solid color - no outline)
/
/                You should use %fillbar before you draw a shape in the area
/                it fills otherwise it will overwrite your shape.
/
/                Note that for the %text macro, color=' ' and font=' '. This
/                is so it can pick up these values from the goptions statement
/                and hence lead to a consistency of fonts and text colors.
/                For font it will use what you define to ftext= and for color
/                it will use ctext= and if this is not set then it will use
/                the first color defined to the color list color=(). Note that
/                for annotate datasets, you are limited to an eight character
/                color name, even if a goptions statement can work with a
/                longer color name so if color=' ' then it will only accept
/                what is defined in a goptions statement if the color name
/                used is eight characters or less. You can always use the RGB
/                version of a long color name. For example, if you enter the
/                command "regedit" in an interactive sas session you will be
/                able to look at the list of colors in
/                SAS_REGISTRY\COLORNAMES\HTML. AntiqueWhite is near the top
/                of the list and its hex codes are displayed as FA,EB,D7
/                which means you could define it in the goptions statement as
/                ctext=CXFAEBD7 (no quotes required) and the annotate dataset
/                could accept this as the default color for text. Also the
/                default for height is height=. so that it will use what is
/                defined to the goptions statement hsize= or if not set then
/                it will use the SAS default of "1 cell".
/
/                If you use the html variable with the %text macro then the
/                hotspot is only correctly aligned for left-aligned text. If
/                you use position='<' then the hotspot is to the immediate
/                left of the displayed text. If you use "+" the hotspot is to
/                the left of the exact center of the displayed text. This is
/                a SAS bug that exists in sas v8.2 and sas v9.1.3 but should
/                be fixed in sas v9.2 . In the meantime, you will just have
/                to remember where to put your mouse cursor to pick up the
/                hotspot. The sas bug is reported at
/                http://support.sas.com/kb/12/377.html
/
/                The intention is for you to use both the SI supplied annotate
/                macros plus Roland's annotate macros together as needed.
/                However, it should be possible to use only Roland's annotate
/                macros in simple cases where you are only displaying shapes
/                defined in macros below that lie parallel to the x axis. These
/                macros were specifically written for use with a graphical
/                patient profiler and to provide a complete set for this. If
/                the need for more macros for this purpose are identified then
/                the extra macros will be added. If you are using this set of
/                macros for graphical patient profiling and you identify more
/                macros that are needed then tell the author.
/
/                In the usage notes below you will see a typical situation
/                where you use goptions to create a "long" html page that you
/                would typically use for graphical patient profiling. The
/                number of xpixels and ypixels will give you that area for
/                graphics. This is only accepted by a few devices such as
/                dev=gif and dev=html. hpos and vpos effectively give you the
/                number of columns (hpos=horizontal positions) and the number
/                of rows (vpos=vertical positions). Since cell size is the
/                default coordinate system then the top y position will be 300
/                if vpos=300. In the example below the first line used is
/                y=298 which leaves a two-row gap at the top. If the figures
/                and text look too big then you can reduce the height of them
/                using the height= parameters. If you have done that but the
/                rows seem too far apart then increase the hpos and vpos
/                values to divide up the graphics area up into smaller cells.
/
/                Note that v8.2 of SAS does not handle hotspots correctly.
/                If you run the code below using SAS v8.2 then the 
/                "Third Box" hotspot will also be active for the second box.
/                This problem does not occur for SAS v9.1.3 so if you are
/                writing annotate datasets that use hotspots then you MUST
/                use SAS v9.1.3 or later.
/               
/ Usage        : filename webout "C:\spectre\";
/
/                goptions reset=all xpixels=1000 ypixels=6000 hpos=50 vpos=300
/                dev=gif gsfmode=replace transparency border
/                ftext='Arial' htext=1 cell ctext=CX483D8C; * DarkSlateBlue ;
/
/                ods listing close;
/                ods html path=webout body="annotest.html";
/
/                %rannomac
/
/                data test;
/                  %dclannovars
/                  %rarrow(y=298,x1=20,x2=48)
/                  %text(y=298,x=19,position='<',text="right-aligned text") 
/                  %rarrow(y=297,x1=20,x2=48,fillcolor='green',
/                          linecolor='black',fillpattern='mempty')
/                  %text(y=297,x=19,position='<',text="next line of text")
/                  %text(y=296,x=19,position='<',
/                        text="This has a hotspot but misaligned on the left",
/                        color='maroon',
/               html="alt='This hotspot is misaligned on the left of the text'")
/                  %box(y=295,x=25)
/                  %box(y=295,x=35)
/                  %box(y=295,x=45,html="alt='Third Box Hotspot'")
/                  %text(y=295,x=19,position='<',
/                        text="The third box ONLY should have a hotspot")
/                  %bigbox(x1=20,y1=294.5,x2=50,y2=298.5,linecolor="brown")
/                run;
/
/                *- Set description to a space to stop whole output area -;
/                *- from having a hotspot and give the gif the same name -;
/                *- as the html body file. -;
/                proc ganno annotate=test description=" " name="annotest";
/                run;
/
/                *- If you rerun this code then you need to delete the -;
/                *- "annotest" grseg member in work.gseg so it can be  -;
/                *- reused as a name in the "proc ganno" step.  -;
/                proc greplay igout=gseg nofs;
/                  delete annotest;
/                  run;
/                quit;
/
/                ods html close;
/                ods listing;
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ x1                x coordinate start value
/ x2                x coordinate end value
/ x                 x coordinate (%box and %text only)
/ y                 y coordinate value
/ y1                y coordinate start value (%drawline, %bigbox and %fillbar)
/ y2                y coordinate end value (%drawline, %bigbox and %fillbar)
/ fillcolor="green"   Color to fill the inside of the shape with (not used for
/                   %bigbox). Default is "beige" for %fillbar.
/ linecolor="black"   Color of line to use for the outline of the shape
/ linewidth=1       Width of the line used to draw the outline
/ height=0.4        Height or fatness of the shape drawn (not %bigbox)
/ width=0.2         Width of the box shape (only used for %box)
/ html=' '          Used to assign html hotspots for the shapes drawn (not
/                   %bigbox). The %dclannovars macro will assign it the maximum
/                   allowed length of $ 1024. Note that this is an output
/                   variable. You must not use it as a working variable.
/ headfactor=1.5    Used to define the length of the arrow head in relation to
/                   the shaft fatness (not used for %rod even though defined).
/ fillpattern="mempty"  Default "map" pattern used to fill the shape is to have
/                   no pattern. Other recommended patterns are "m5n135", "m5n45"
/                   and "m5x45".
/--------------- These parameters apply to the %text macro only ----------------
/ text=' '          Text to display
/ font=' '          Font to use for the text is by default missing so that it
/                   uses what is defined to ftext= in the goptions statement.
/                   (note that non-SAS fonts must be enclosed in single quotes.
/                   If supplied as a variable they must also be enclosed in
/                   single quotes so they would have to be defined to a variable
/                   something like userfont="'Arial'". To specify a modified
/                   font such as "bold" then specify the modifier after a slash
/                   such as "'Arial / Bold'").
/ rotate=0          Rotation angle for the line of text relative to being
/                   parallel to the x axis.
/ angle=0           Angle of rotation of every text letter relative to the 
/                   perpendicular of the line of text.
/ position='+'      Default position of the text is CENTERED relative to the x,y
/                   coordinate. Use "<" for right-aligned and ">" for left-
/                   aligned, if you use "+" for centered. If you change this
/                   from your required default then you must reset it back
/                   manually afterwards.
/-------------- These parameters apply to the %xyzhsys macro only --------------
/  (Note that the following default values are also assigned in %dclannovars)
/ xsys='4'          Default for x coordinate system is '4' which is for
/                   multiples of cell height.
/ ysys='4'          Default for y coordinate system is '4' which is for 
/                   multiples of cell height.
/ zsys='2'          Default z coordinate system is to use data values
/ hsys='4'          Default for height coordinate system is '4' which is for
/                   multiples of cell height.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  03Mar08         Header update
/ rrb  04Mar08         "Keep" list added to %dclannovars macro
/ rrb  04Mar08         xsys='4', ysys='4', hsys='4' (cell based) now same as SAS
/                      defaults. Height changed to half cell height for shape
/                      thickness.
/ rrb  05Mar08         Header update. New usage example added that shows how to
/                      use ODS to create output.
/ rrb  05Mar08         Defaults changed to font=' ' and color=' ' for %text
/ rrb  05Mar08         Default changed to height=. for %text
/ rrb  06Mar08         Header example code updated
/ rrb  06Mar08         %drawline and %bigbox macros added and some defaults
/                      changed. Example code in header updated.
/ rrb  07Mar08         header tidy plus some defaults changed
/ rrb  11Mar08         %fillbar macro added and line=1 moved to "poly" obs
/ rrb  01Jan09         %text macro changed to accept a sas variable name for the
/                      font= parameter.
/ rrb  02Jan09         The %box macro now works the same way as the other filled
/                      shape macros in that it is a two-pass draw. All filled
/                      shape macros now do a two pass draw. These major changes
/                      implemented for version 2.0
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: rannomac v2.0;

%macro rannomac;
%mend rannomac;



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
  x=&x-&width/2;y=&y-&height/2;function="poly";color=&linecolor;style=&fillpattern;line=1;output;
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
