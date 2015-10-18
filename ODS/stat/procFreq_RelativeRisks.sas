/*
proc template;     
 source   Base.Freq.RelativeRisks

 / file="C:\Users\jhu\Documents\GitHub\Programming-SAS\ODS\stat\procFreq_RelativeRisks.tpl";
run;
*/

proc template; 
define table Base.Freq.RelativeRisks;
   notes "Relative Risk table, options MEASURES and RELRISK";
   dynamic needlines ts conflevel p2 p3 ndec ndecl ndecu pfoot footnote oldtable newtable;
   column StudyType Statistic Value LowerCL UpperCL;
   header h0 h1 h2 h3;
   footer f1;
   translate _val_=._ into "";

   define h0;
      text "Estimates of the Relative Risk (Row1/Row2)";
      space = 1;
      print = oldtable;
      spill_margin;
   end;

   define h1;
      text "Odds Ratio (div. by 2 Relative Risks) and Relative Risks (div. by 2 Row Pcts)";
      space = 1;
      print = newtable;
      spill_margin;
   end;

   define h2;
      text ";" conflevel BEST8. %nrstr("%% Confidence Limits");
      end = UpperCL;
      start = LowerCL;
      just = r;
      print = p2;
      spill_adj;
   end;

   define h3;
      text ";" conflevel BEST8. %nrstr("%%     ;Confidence Limits");
      end = UpperCL;
      start = LowerCL;
      just = r;
      print = p3;
   end;

   define StudyType;
      header = "Type of Study";
      style = RowHeader;
      print = oldtable;
      id;
   end;

   define Statistic;
      header = "Statistic";
      style = RowHeader;
      print = newtable;
      id;
   end;

   define Value;
      header = "Value";
      format_ndec = ndec;
      format_width = 10;
      id;
   end;

   define LowerCL;
      glue = 100;
      format_ndec = ndecl;
      format_width = 10;
      print_headers = OFF;
   end;

   define UpperCL;
      format_ndec = ndecu;
      format_width = 10;
      print_headers = OFF;
   end;

   define f1;
      text footnote;
      print = pfoot;
      spill_margin;
   end;
   top_space = ts;
   required_space = needlines;
   header_space = 0;
   underline;
end;
run;
