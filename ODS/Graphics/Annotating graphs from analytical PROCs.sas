/*
http://blogs.sas.com/content/graphicallyspeaking/2015/08/10/annotating-graphs-from-analytical-procs/

http://blogs.sas.com/content/graphicallyspeaking/2015/08/17/annotating-multiple-panels/

http://blogs.sas.com/content/graphicallyspeaking/2015/07/31/modifying-dynamic-variables-in-ods-graphics/

*/


ods graphics on;
ods document name=MyDoc (write);
proc reg data=sashelp.class;
   ods select diagnosticspanel;
   ods output diagnosticspanel=dp;
   model weight = height;
quit;
ods document close;

data anno;
   length Label $ 40;
   Function = 'Text';     Label     = 'Saturday, July 25, 2015';
   Width    = 100;        x1        = 99;   y1 = .1;        
   Anchor   = 'Right';    TextColor = 'Red';
   output;
   
   Label = 'Confidential - Do Not Distribute';
   Width = 150;           x1        = 50;   y1     =  50;   Anchor = 'Center';
   Transparency = 0.8;    TextSize  = 40;   Rotate = -45;      
   output;
run;

%macro procanno(data=, template=, anno=anno, document=mydoc);
   proc document name=&document;
      ods exclude properties;
      ods output properties=__p(where=(type='Graph'));
      list / levels=all;
   quit;

   data _null_;
      set __p;
      call execute("proc document name=&document;");
      call execute("ods exclude dynamics;");
      call execute("ods output dynamics=__outdynam;");
      call execute(catx(' ', "obdynam", path, ';'));
   run;

   proc template; 
      source &template/ file='temp.tmp';
   quit;

   data _null_;
      infile 'temp.tmp';
      input;
      if _n_ = 1 then call execute('proc template;');
      call execute(_infile_);
      if _infile_ =: '   BeginGraph' then bg + 1;
      if bg and index(_infile_, ';') then do;
         bg = 0;
         call execute('annotate;');
      end;
   run;

   data _null_;
      set __outdynam(where=(label1 ne '___NOBS___')) end=eof;
      if nmiss(nvalue1) and cvalue1 = '.' then cvalue1 = ' ';
      if _n_ = 1 then do;
         call execute("proc sgrender data=&data sganno=&anno");
         call execute("template=&template;");
         call execute('dynamic');
      end;
      if cvalue1 ne ' ' then 
         call execute(catx(' ', label1, '=',
                      ifc(n(nvalue1), cvalue1, quote(trim(cvalue1)))));
      if eof then call execute('; run;');
   run;

   proc template; 
      delete &template;
   quit;
%mend;
       
%procanno(data=dp, template=Stat.REG.Graphics.DiagnosticsPanel)
