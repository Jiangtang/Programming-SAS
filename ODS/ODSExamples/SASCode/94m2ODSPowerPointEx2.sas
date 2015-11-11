ods html close;
title1 'PowerPoint - Various Layouts and Styles';
footnote 'The PowerPoint Destination';
proc template; 
   define style styles.test; 
      parent= styles.powerpointlight; 
      class body / 
         backgroundimage="radial-gradient(40%, lightblue 40%, 
         yellow 30%, blue)"; 
      style graphbackground / image='c:\ODSExamples\Images\foldedblends.bmp';
   end; 
run;
ods escapechar = "^"; 
ods PowerPoint file="powerptOptions.ppt" layout=titleslide 
     style=styles.test nogtitle nogfootnote;
proc odstext; 
p "The ODS Destination for PowerPoint" / style=presentationtitle; 
p "9.4 - The Power to Know ^{super ^{unicode 00AE}} " / 
    style=presentationtitle2; 
run; 
ods powerpoint layout=_null_; 
ods text=
'^{style[fontsize=28pt color=#cd5b45 ] What   
^{style[font_style=italic fontweight=bold] Output} is Produced by the ODS Destination for PowerPoint?}';
proc odstext;
p 'Graphics output' / style=[color=#191970];
p 'SAS procedure output' / style=[color=#191970];
p 'ODS procedure output' / style=[color=#191970];
p 'ODS TEXT= output' / style=[color=#191970];
p 'LAYOUT output' / style=[color=#191970];
run;
title1 "^{style [font_size=30pt] PowerPoint - Various Layouts and Styles }";
proc odstext;
  p 'New features include:' / style=[color=#236b8e fontsize=24pt 
     textdecoration=underline];
  list / style=[fontsize=24pt];
    item 'Light and dark styles';
    item;
        p 'Gradients: ';
        list / style=[fontsize=24pt];
            item/style=[color=darkgreen];
                p 'Linear: '; 
                  list/style=[color=darkred fontsize=24pt];
                    item 'Angles';
                    item 'Opacity';
                end;
            end;
            item 'Radial'/style=[color=darkgreen];
        end;
    end;

    item;
        p 'Template layout: ' /style=[color=darkgreen fontsize=24pt];
        list/style=[color=darkgreen fontsize=24pt];
            item 'Titleslide';
            item 'TitleandContent';
            item 'TwoContent';
        end;
    end;
    item 'Graphics support';
    item 'Layout Support';
    item 'Images';
  end;
run;
title1 "^{style [font_size=36pt] Column Layout with Proc and Graphics }";
ods powerpoint layout=twocontent; 
proc means data=sashelp.class min max ; 
run; 
 
goptions hsize=3in vsize=3in dev=png;
pattern color="#a78d84";

proc gchart data=sashelp.class;
  vbar age / name='pptall0'
  ctext="#fba16c"
  coutline="red";
run;
quit;
ods powerpoint close; 
