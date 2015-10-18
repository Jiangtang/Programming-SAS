/*proc template;     
 source  Base.Freq.CrossTabFreqs
 / file="C:\Users\jhu\Documents\GitHub\Programming-SAS\ODS\stat\procFreq_CrossTabFreqs.tpl";
run;
*/

proc template;
define crosstabs Base.Freq.CrossTabFreqs;
   notes "Crosstabulation table";
   cellvalue Frequency Expected Deviation CellChiSquare TotalPercent Percent RowPercent ColPercent CumColPercent;
   header TableOf ControllingFor;
   footer NoObs Missing;

   define TableOf;
      dynamic StratNum NoTitle;
      text "Table " StratNum 10. " of " _ROW_NAME_ " by " _COL_NAME_ / (NoTitle=0) and (StratNum>0);
      text "Table of " _ROW_NAME_ " by " _COL_NAME_ / NoTitle=0;
   end;

   define ControllingFor;
      dynamic StratNum StrataVariableNames StrataVariableLabels;
      text "Controlling for" StrataVariableNames / StratNum>0;
   end;

   define header RowsHeader / nolist;
      text _ROW_NAME_ "(;" _ROW_LABEL_ ")" / _ROW_LABEL_ not = '';
      text _ROW_NAME_;
      cindent = ";";
      space = 0;
   end;

   define header ColsHeader / nolist;
      text _COL_NAME_ "(;" _COL_LABEL_ ")" / _COL_LABEL_ not = '';
      text _COL_NAME_;
      cindent = ";";
      space = 1;
   end;

   define Missing;
      dynamic FMissing;
      text "Frequency Missing = " FMissing -12.99 / FMissing not = 0;
      space = 1;
   end;

   define NoObs;
      dynamic SampleSize;
      text "Effective Sample Size = 0" / SampleSize=0;
      space = 1;
   end;

   define Frequency;
      header = "Frequency";
      format = BEST7.;
      label = "Frequency Count";
      print;
      data_format_override;
   end;

   define Expected;
      header = "Expected";
      format = BEST6.;
      label = "Expected Frequency";
      print;
      data_format_override;
   end;

   define Deviation;
      header = "Deviation";
      format = BEST6.;
      label = "Deviation from Expected Frequency";
      print;
      data_format_override;
   end;

   define CellChiSquare;
      header = "Cell Chi-Square";
      format = BEST6.;
      label = "Cell Chi-Square";
      print;
   end;

   define TotalPercent;
      header = "Tot Pct";
      format = 6.2;
      label = "Percent of Total Frequency";
      print;
   end;

   define Percent;
      header = "Percent(joint proportion)";
      format = 6.2;
      label = "Percent of Two-Way Table Frequency";
      print;
   end;

   define RowPercent;
      header = "Row Pct(conditional)";
      format = 6.2;
      label = "Percent of Row Frequency";
      print;
   end;

   define ColPercent;
      header = "Col Pct(marginal?)";
      format = 6.2;
      label = "Percent of Column Frequency";
      print;
   end;

   define CumColPercent;
      header = %nrstr("Cumulative Col%%");
      format = 6.2;
      label = "Cumulative Percent of Column Frequency";
      print;
   end;
   cols_header = ColsHeader;
   rows_header = RowsHeader;
end;
run;
