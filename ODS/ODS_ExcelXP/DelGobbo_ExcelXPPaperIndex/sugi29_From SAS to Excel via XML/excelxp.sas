proc template;

define tagset Tagsets.ExcelXP;
   notes "http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnexcl2k2/html/odc_xlsmlinss.asp";
   mvar embedded_titles frozen_headers frozen_rowheaders autofilter width_points width_fudge default_column_width convert_percentages orientation;
   define event default;
      start:
         put "<" event_name ">" NL;

      finish:
         put "</" event_name ">" NL;
   end;
   define event documentation;
      break /if ^$options;

      trigger quick_reference /if cmp( $options["DOC"], "quick");

      trigger help /if cmp( $options["DOC"], "help");
   end;
   define event help;
      putlog "==============================================================================";
      putlog "The EXCELXP Tagset Help Text.";
      putlog " ";
      putlog "This Tagset/Destination creates Microsoft's spreadsheetML XML.";
      putlog "It is used specifically for importing data into Excel.";
      putlog " ";
      putlog "Each table will be placed in its own worksheet within a workbook.";
      putlog "This destination supports ODS styles, traffic lighting, and custom formats.";
      putlog " ";
      putlog "Numbers, Currency and percentages are correctly detected and displayed.";
      putlog "Custom formats can be given by supplying a style override on the tagattr";
      putlog "style element.";
      putlog " ";
      putlog "By default, titles and footnotes are part of the spreadsheet, but are part";
      putlog "of the header and footer.";
      putlog " ";
      putlog "Also by default, printing will be in 'Portrait'.";
      putlog "The orientation can be changed to landscape.";
      putlog " ";
      putlog "The specification for this xml is here.";
      putlog "http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnexcl2k2/html/odc_xlsmlinss.asp";
      putlog " ";
      putlog "See Also:";
      putlog "http://support.sas.com/rnd/base/topics/odsmarkup/";
      putlog "http://support.sas.com/rnd/papers/index.html#excelxml";
      putlog " ";

      trigger quick_reference;
   end;
   define event quick_reference;
      putlog "==============================================================================";
      putlog " ";
      putlog "These are the options supported by this tagset.";
      putlog " ";
      putlog "Sample usage:";
      putlog " ";
      putlog "ods tagsets.excelxp options(doc='Quick'); ";
      putlog " ";
      putlog "ods tagsets.excelxp options(embedded_titles='No' Orientation='Landscape'); ";
      putlog " ";
      putlog "Doc:  No default value.";
      putlog "     Help: Displays introductory text and options.";
      putlog "     Quick: Displays available options.";
      putlog " ";
      putlog "Orientation:   Default Value 'Portrait'";
      putlog "     Tells excel how to format the page when printing.";
      putlog "     The only other value is 'landscape'.";
      putlog "     Also available as a macro variable.";
      putlog " ";
      putlog "Embedded_Titles:   Default Value 'No'";
      putlog "     If 'Yes' titles and footnotes will appear in the worksheet.";
      putlog "     By default, titles and footnotes are a part of the header and footer.";
      putlog "     Also available as a macro variable.";
      putlog " ";
      putlog "Frozen_Headers:   Default Value 'No'";
      putlog "     If 'Yes' The rows down to the bottom of the headers will be frozen when";
      putlog "     the table data scrolls.  This includes any titles created with the";
      putlog "     embedded titles option.";
      putlog "     Also available as a macro variable.";
      putlog " ";
      putlog "Frozen_RowHeaders:   Default Value 'No'";
      putlog "     If 'Yes' The header columns on the left will be frozen when";
      putlog "     the table data scrolls.";
      putlog "     Also available as a macro variable.";
      putlog " ";
      putlog "AutoFilter:   Default Value 'none'";
      putlog "     Values: None, All, range.";
      putlog "     If 'all' An auto filter will be applied to all columns.";
      putlog "     If a range such as '3-5' The auto filter will be applied to the";
      putlog "          in that range of columns.";
      putlog " ";
      putlog "AutoFilter_Table:   Default Value '1'";
      putlog "     Values: Any number";
      putlog "     If sheet interval is anything but table or bygroup, this value";
      putlog "     Determines which table gets the autofilter applied.  If the sheet";
      putlog "     interval is table, or bygroup the only table get's the autofilter";
      putlog "     regardless of this setting.";
      putlog " ";
      putlog "Width_Fudge:   Default Value '0.75'";
      putlog "     Values: None, Number.";
      putlog "     By default this value is used along with Width_Points and column width";
      putlog "     to calculate an approximate width for the table columns.";
      putlog "     width = Data_Font_Points * number_Of_Chars * Width_Fudge.";
      putlog "     If 'none' this feature is turned off.";
      putlog " ";
      putlog "Width_Points:   Default Value 'None'";
      putlog "     Values: None, Number.";
      putlog "     By Default the point size from the data or header style";
      putlog "     elements are used to calculate a pseudo column width.";
      putlog "     The column width is calculated from the given column width or";
      putlog "     the length of the column's header text.  If the header is bigger.";
      putlog "     In the case the header length is used, so is the header's point size.";
      putlog "     This value overrides that point size.";
      putlog "     This value is used along with WidthFudge and column width";
      putlog "     to calculate an approximate width for the table columns.";
      putlog "     width = Width_Points * number_Of_Chars * Width_Fudge.";
      putlog " ";
      putlog "Default_Column_Width:   Default Value 'None'";
      putlog "     Values: None, Number, list of numbers.";
      putlog "     Most procedures provide column widths, but occasionally a column";
      putlog "     will not have a width.  Excel will resize the column to fit any";
      putlog "     numbers but will not auto-size for character string headings.";
      putlog "     In the case that a column does not have a width, this value will be";
      putlog "     used instead.  The value should be the width in characters.";
      putlog "     If the value of this option is a comma separated list.";
      putlog "     Each number will be used for the column in the same position.  If";
      putlog "     the table has more columns, the list will start over again.";
      putlog " ";
      putlog "TagAttr Style Element:   Default Value ''";
      putlog "     Values: <ExcelFormat> or <Format: ExcelFormat> <Formula: ExcelFormula>";
      putlog "     This is not a tagset option but a style attribute that the tagset will";
      putlog "     use to get formula's and column formats. The format and formula's given";
      putlog "     must be a valid to excel.";
      putlog "     A single value without a keyword is interpreted as a format.";
      putlog "     Both a formula and format can be specified together with keywords.";
      putlog "     There should be no spaces except for those between the two values";
      putlog "     The keyword and value must be separated by a ':'";
      putlog "     tagattr='Format:###.## Formula:SUM(R[-4]C:R[-1]C').";
      putlog " ";
      putlog "Sheet_Interval:   Default Value 'Table'";
      putlog "     Values: Table, Page, Bygroup, Proc, None.";
      putlog "     This option controls how many tables will go in a worksheet.";
      putlog "     In reality only one table is allowed per worksheet.  To get more";
      putlog "     than one table, the tables are actually combined into one.";
      putlog " ";
      putlog "     Specifying a sheet interval will cause the current worksheet to close.";
      putlog " ";
      putlog "Sheet_Name:   Default Value 'None'";
      putlog "     Values: Any string ";
      putlog "     Worksheet names can be up to 31 characters long.  This name will";
      putlog "     be used in combination with a worksheet counter to create a unique name.";
      putlog " ";
      putlog "Sheet_Label:   Default Value 'None'";
      putlog "     Values: Any String";
      putlog "     This option is used in combination with the various worksheet naming.";
      putlog "     heuristics which are based on the sheet interval.";
      putlog "     This string will be used as the first part of the name instead of the";
      putlog "     predefined string it would normally use.";
      putlog " ";
      putlog "     These are the defaults:";
      putlog " ";
      putlog "     'Proc ' total_Proc_count  - label";
      putlog "     'Page ' total_page_count  - label";
      putlog "     'By '   numberOfWorksheets byGroupLabel - label";
      putlog "     'Table ' numberOfWorksheets  - label";
      putlog " ";
      putlog "Auto_SubTotals:   Default Value 'No'";
      putlog "     Values: Yes, No";
      putlog "     If yes, this option causes a subtotal formula to be placed in the";
      putlog "     subtotal cells on the last table row of the Print Procedure's tables.";
      putlog "     WARNING: This does not work with Sum By.  It only works if the ";
      putlog "     totals only happen once per table.";
      putlog " ";
      putlog "Convert_Percentages:   Default Value 'Yes'";
      putlog "     Remove percent symbol, apply excel percent format, and multiply by 100.";
      putlog "     This causes percentage values to display as numeric percentages in Excel.";
      putlog "     If 'No' percentage values will be untouched and will appear as";
      putlog "     strings in Excel.";
      putlog "     Will be deprecated in a future release when it is no longer needed.";
      putlog " ";
      putlog "Currency_symbol:   Default Value '$'";
      putlog "     Used for detection of currency formats and for ";
      putlog "     removing those symbols so excel will like them.";
      putlog "     Will be deprecated in a future release when it is";
      putlog "     no longer needed.        ";
      putlog " ";
      putlog "Currency_format:   Default Value 'Currency'";
      putlog "     The currency format specified for excel to use.";
      putlog "     Another possible value is 'Euro Currency'.";
      putlog "     Will be deprecated in a future release when it is";
      putlog "     no longer needed.        ";
      putlog " ";
      putlog "Decimal_separator:   Default Value '.'";
      putlog "     The character used for the decimal point.";
      putlog "     Will be deprecated in a future release when it is no longer needed.";
      putlog " ";
      putlog "Thousands_separator:   Default Value ','";
      putlog "     The character used for indicating thousands in numeric values.";
      putlog "     Used for removing those symbols from numerics so excel will like them.";
      putlog "     Will be deprecated in a future release when it is no longer needed.";
      putlog " ";
      putlog "Numeric_Test_Format:   Default Value '12.'";
      putlog "     Used for determining if a value is numeric or not.";
      putlog "     Other useful values might be COMMAX or NLNUM formats.";
      putlog "     Will be deprecated in a future release when it is no longer needed.";
      putlog " ";
      putlog "==============================================================================";
   end;
   define event compile_regexp;
      unset $currency_sym;
      unset $decimal_separator;
      unset $thousands_separator;
      set $currency_sym "\" $currency;
      set $currency_sym "\$" /if ^$currency_sym;
      set $decimal_separator "\." /if ^$decimal_separator;
      set $thousands_separator "," /if ^$thousands_separator;
      set $punctuation $currency_sym $thousands_separator %nrstr("%%");
      set $integer_re "\d+";
      set $sign_re "[+-]?";
      set $group_re "\d{1,3}(?:" $thousands_separator "\d{3})*";
      set $whole_re "(?:" $group_re "|" $integer_re ")";
      set $exponent_re "[eE]" $sign_re $integer_re;
      set $fraction_re "(?:" $decimal_separator "\d*)";
      set $real_re "(?:" $whole_re $fraction_re "|" $fraction_re $integer_re "|" $whole_re ")";
      set $percent_re $sign_re $real_re %nrstr("\%%");
      set $scinot_re $sign_re "(?:" $real_re $exponent_re "|" $real_re ")";
      set $cents_re "(?:" $decimal_separator "\d\d)";
      set $money_re $sign_re $currency_sym "(?:" $whole_re $cents_re "|" $cents_re "|" $whole_re ")";
      set $number_re "/^(?:" $real_re "|" $percent_re "|" $scinot_re "|" $money_re ")\Z/";
      eval $number prxparse($number_re);
      set $tagattr_regexp "/^(format:|formula:)/";
      eval $tagattr_regex prxparse($tagattr_regexp);
   end;
   define event sheet_interval;
      unset $tmp_interval;

      do /if value;
         set $tmp_interval value;

      else;
         set $tmp_interval tagset_alias;
      done;


      trigger set_sheet_interval /if $tmp_interval;
   end;
   define event set_sheet_interval;

      trigger worksheet finish /if $tmp_interval;
      set $tmp_interval lowcase($tmp_interval);

      do /if $tmp_interval in ("table", "bygroup");
         set $sheet_interval $tmp_interval;

      else /if cmp( $tmp_interval, "page");
         set $sheet_interval "page";

      else /if cmp( $tmp_interval, "proc");
         set $sheet_interval "proc";

      else /if cmp( $tmp_interval, "none");
         set $sheet_interval "none";

      else;
         set $sheet_interval "table";
      done;

   end;
   define event proc_list;
      set $proclist["Gchart" ] "1";
      set $proclist["Gplot" ] "1";
      set $proclist["Gmap" ] "1";
      set $proclist["Gcontour" ] "1";
      set $proclist["G3d" ] "1";
      set $proclist["Gbarline" ] "1";
      set $proclist["Gareabar" ] "1";
      set $proclist["Gradar" ] "1";
      set $proclist["Gslide" ] "1";
      set $proclist["Ganno" ] "1";
   end;
   define event nls_numbers;
      unset $currency;
      unset $currency_format;
      unset $decimal_separator;
      unset $thousands_separator;
      unset $test_format;
      set $currency $options["CURRENCY_SYMBOL" ] /if $options;
      set $currency "$" /if ^$currency;
      set $currency_compress $currency ",";
      set $currency_format $options["CURRENCY_FORMAT" ] /if $options;
      set $currency_format "Currency" /if ^$currency_format;
      set $decimal_separator $options["DECIMAL_SEPARATOR" ] /if $options;
      set $decimal_separator "\." /if ^$decimal_separator;
      set $thousands_separator $options["THOUSANDS_SEPARATOR" ] /if $options;
      set $thousands_separator "," /if ^$thousands_separator;
      set $test_format $options["NUMERIC_TEST_FORMAT" ] /if $options;
      set $test_format "12." /if ^$test_format;
   end;
   define event bad_fonts;
      set $bad_fonts[] "Times";
      set $bad_fonts[] "Times Roman";
      set $bad_fonts[] "Trebuchet MS";
   end;
   define event needed_styles;
      set $missing_styles["Data" ] "True";
      set $missing_styles["Header" ] "True";
      set $missing_styles["Footer" ] "True";
      set $missing_styles["RowHeader" ] "True";
      set $missing_styles["Table" ] "True";
      set $missing_styles["Batch" ] "True";
      set $missing_styles["SystemFooter" ] "True";
      set $missing_styles["SystemTitle" ] "True";
   end;
   define event options_setup;
      set $options["test" ] "test" /if ^$options;
      unset $landscape;
      set $landscape "True" /if cmp( $options["ORIENTATION"], "landscape");

      do /if ^$landscape;
         set $landscape "True" /if cmp( orientation , "landscape");
      done;


      do /if $options["EMBEDDED_TITLES"];

         do /if cmp( $options["EMBEDDED_TITLES"], "yes");
            set $embedded_titles "true";

         else;
            unset $embedded_titles;
         done;


      else;

         do /if cmp( embedded_titles , "yes");
            set $embedded_titles "true";

         else;
            unset $embedded_titles;
         done;

      done;


      do /if $options["FROZEN_HEADERS"];

         do /if cmp( $options["FROZEN_HEADERS"], "yes");
            set $frozen_headers "true";

         else;
            unset $frozen_headers;
         done;


      else;

         do /if cmp( frozen_headers , "yes");
            set $frozen_headers "true";

         else;
            unset $frozen_headers;
         done;

      done;


      do /if $options["FROZEN_ROWHEADERS"];

         do /if cmp( $options["FROZEN_ROWHEADERS"], "yes");
            set $frozen_rowheaders "true";

         else;
            unset $frozen_rowheaders;
         done;


      else;

         do /if cmp( frozen_rowheaders , "yes");
            set $frozen_rowheaders "true";

         else;
            unset $frozen_rowheaders;
         done;

      done;


      do /if $options["CONVERT_PERCENTAGES"];

         do /if cmp( $options["CONVERT_PERCENTAGES"], "no");
            unset $convert_percentages;

         else;
            set $convert_percentages "true";
         done;


      else;

         do /if cmp( convert_percentages , "no");
            unset $convert_percentages;

         else;
            set $convert_percentages "true";
         done;

      done;


      do /if $options["AUTOFILTER"];

         do /if cmp( $options["AUTOFILTER"], "none");
            unset $autofilter;

         else;
            set $autofilter $options["AUTOFILTER" ];
         done;


      else;

         do /if cmp( autofilter , "none");
            unset $autofilter;

         else;
            set $autofilter autofilter;
         done;

      done;

      eval $widthfudge 0.75;

      do /if $options["WIDTH_FUDGE"];

         do /if cmp( $options["WIDTH_FUDGE"], "none");
            unset $widthFudge;

         else;
            set $widthFudge $options["WIDTH_FUDGE" ];
            eval $widthFudge inputn($widthFudge,"BEST");
         done;


      else;

         do /if cmp( width_fudge , "none");
            unset $widthFudge;

         else /if width_fudge;
            eval $widthFudge inputn(width_Fudge ,"BEST");
         done;

      done;

      unset $widthpoints;

      do /if $options["WIDTH_POINTS"];

         do /if cmp( $options["WIDTH_POINTS"], "none");
            unset $widthPoints;

         else;
            set $widthPoints $options["WIDTH_POINTS" ];
            eval $widthPoints inputn($widthPoints,"BEST");
         done;


      else;

         do /if cmp( width_points , "none");
            unset $widthPoints;

         else /if width_points;
            eval $widthPoints inputn(width_points ,"BEST");
         done;

      done;

      unset $default_widths;

      do /if $options["DEFAULT_COLUMN_WIDTH"];

         do /if cmp( $options["DEFAULT_COLUMN_WIDTH"], "none");
            unset $default_widths;

         else;
            set $defwid $options["DEFAULT_COLUMN_WIDTH" ];

            trigger set_default_widths;
         done;


      else;

         do /if cmp( default_column_width , "none");
            unset $default_widths;

         else /if default_column_width;
            set $defwid default_column_width;

            trigger set_default_widths;
         done;

      done;


      do /if $options["SHEET_INTERVAL"];
         set $tmp_interval lowcase($options["SHEET_INTERVAL"]);

         trigger set_sheet_interval;
         unset $options["SHEET_INTERVAL" ];
      done;


      do /if $options["SHEET_NAME"];
         set $sheet_name $options["SHEET_NAME" ];

      else;
         unset $sheet_name;
      done;


      do /if $options["SHEET_LABEL"];
         set $sheet_label $options["SHEET_LABEL" ];

      else;
         unset $sheet_label;
      done;

      unset $auto_sub_totals;

      do /if $options["AUTO_SUBTOTALS"];
         set $auto_sub_totals "True" /if cmp( $options["AUTO_SUBTOTALS"], "yes");
      done;

      eval $autofilter_table 1;

      do /if $sheet_interval ^  in ("table", "bygroup");

         do /if $options["AUTOFILTER_TABLE"];
            set $tmp $options["AUTOFILTER_TABLE" ];
            eval $autofilter_table inputn($tmp,"BEST");
         done;

      done;

   end;
   define event set_default_widths;

      do /if index($defwid, ",");
         set $def_width scan($defwid,1,",");
         eval $count 1;

         do /while ^cmp( $def_width, " ");
            set $default_widths[] strip($def_width);
            eval $count $count +1;
            set $def_width scan($defwid,$count,",");
         done;


      else;
         set $default_widths[] strip($defwid);
      done;

   end;
   define event options_set;

      trigger set_options;
   end;
   define event set_options;

      trigger nls_numbers;

      trigger compile_regexp;

      trigger options_setup;

      trigger documentation;
   end;
   define event initialize;

      trigger set_options;

      trigger bad_fonts;

      trigger needed_styles;
      set $align getoption("center");
      set $sheet_names[%nrstr("#$%%!^&&&&") ] "junk";

      trigger proc_list;
      set $weight["1px" ] "0";
      set $weight["2px" ] "1";
      set $weight["3px" ] "2";
      set $weight["4px" ] "3";
      set $font_size["xx-small" ] "8";
      set $font_size["x-small" ] "12";
      set $font_size["medium" ] "14";
      set $font_size["large" ] "16";
      set $font_size["x-large" ] "18";
      set $font_size["xx-large" ] "20";
      eval $numberOfWorksheets 0;
      eval $format_override_count 0;
      set $tmp_interval tagset_alias;

      trigger set_sheet_interval;
   end;
   define event doc;
      start:
         eval $numberOfWorksheets 0;
         put "<?xml version=""1.0""";
         putq " encoding=" encoding;
         put "?>" NL NL;
         putl "<Workbook xmlns=""urn:schemas-microsoft-com:office:spreadsheet""";
         putl "          xmlns:x=""urn:schemas-microsoft-com:office:excel""";
         putl "          xmlns:ss=""urn:schemas-microsoft-com:office:spreadsheet""";
         putl "          xmlns:html=""http://www.w3.org/TR/REC-html40"">";
         putl "<DocumentProperties xmlns=""urn:schemas-microsoft-com:office"">";

         do /if operator;
            putl "<Author>" operator "</Author>";
            putl "<LastAuthor>" operator "</LastAuthor>";
         done;

         putl "<Created>" date "T" time "</Created>";
         putl "<LastSaved>" date "T" time "</LastSaved>";
         putl "<Company>SAS Institute Inc. http://www.sas.com</Company>";
         putl "<Version>" saslongversion "</Version>";
         putl "</DocumentProperties>";

      finish:
         putl "</Workbook>";
   end;
   define event embedded_stylesheet;
      start:
         unset $currency_styles;
         unset $percentage_styles;
         unset $style_list;
         eval $format_override_count 0;

         open style;
         put "<Styles>" NL;

         trigger alignstyle;

      finish:
         close;
   end;
   define event doc_body;
      start:

         open worksheet;

      finish:

         trigger worksheet;
         close;

         open style;
         putl "</Styles>" NL;
         close;
         put $$style;
         delstream style;
         put $$master_worksheet;
         delstream master_worksheet;
   end;
   define event shortstyles;
      flush;

      open style;
      iterate $missing_styles;

      do /while _name_;
         set $cell_class _name_;

         trigger empty_style;
         next $missing_styles;
      done;

      close;
      unset $cell_class;
   end;
   define event empty_style;
      put "<Style ss:ID=""" $cell_class """/>" NL;
   end;
   define event style_class;
      unset $doit;
      set $doit "true" /if cmp( htmlclass, "SystemTitle");
      set $doit "true" /if cmp( htmlclass, "SystemFooter");
      set $doit "true" /if cmp( htmlclass, "NoteContent");
      set $doit "true" /if cmp( htmlclass, "byline");
      set $doit "true" /if contains( htmlclass, "able");
      set $doit "true" /if contains( htmlclass, "atch");
      set $doit "true" /if contains( htmlclass, "ata");
      set $doit "true" /if contains( htmlclass, "eader");
      set $doit "true" /if contains( htmlclass, "ooter");
      break /if ^$doit;
      unset $missing_styles[htmlclass ];
      putq "<Style ss:ID=" HTMLCLASS ">" NL;
      set $format_override $attrs["format" ];

      trigger xl_style_elements;

      open style;
      put $$style_elements;
      unset $$style_elements;
      putl "</Style>";
   end;
   define event xl_style_elements;
      delstream style_elements;

      open style_elements;
      put "<Alignment";
      set $headerString lowcase(htmlclass);
      set $headerStringIndex index($headerString,"header");
      put " ss:WrapText=""1""" /if cmp( $headerStringIndex, "1");
      unset $headerString;
      unset $headerStringIndex;

      do /if cmp( htmlclass, "SystemTitle") or cmp ( htmlclass, "SystemFooter");

         do /if cmp( $align, "center");
            put " ss:Horizontal=""Center""";
         done;

      done;

      putl "/>";
      putl "<ss:Borders>";
      put "<ss:Border ss:Position=""Left""";
      putq " ss:Color=" BORDERCOLOR;

      do /if borderwidth;
         putq " ss:Weight=" $weight[BORDERWIDTH ];
         put " ss:LineStyle=""Continuous""";
      done;

      putl " />";
      put "<ss:Border ss:Position=""Top""";
      putq " ss:Color=" BORDERCOLOR;

      do /if borderwidth;
         putq " ss:Weight=" $weight[BORDERWIDTH ];
         put " ss:LineStyle=""Continuous""";
      done;

      putl " />";
      put "<ss:Border ss:Position=""Right""";
      putq " ss:Color=" BORDERCOLOR;

      do /if borderwidth;
         putq " ss:Weight=" $weight[BORDERWIDTH ];
         put " ss:LineStyle=""Continuous""";
      done;

      putl " />";
      put "<ss:Border ss:Position=""Bottom""";
      putq " ss:Color=" BORDERCOLOR;

      do /if borderwidth;
         putq " ss:Weight=" $weight[BORDERWIDTH ];
         put " ss:LineStyle=""Continuous""";
      done;

      putl " />";
      putl "</ss:Borders>";

      trigger font_interior;
      put "<Protection";
      put " ss:Protected=""1""";
      put " />" NL;
      flush;
      close;
   end;
   define event cell_format;
      put "<NumberFormat";
      putq " ss:Format=" $format_override;
      putq " ss:Format=" $format /if ^$format_override;
      put " />" NL;
   end;
   define event font_interior;

      do /if any( font_face, font_size, font_weight, foreground);
         put "<Font";

         do /if font_face;
            set $fontFace font_face;

            do /if contains( font_face, "Courier");
               set $fontFace tranwrd($fontFace,"sans-serif, ","");
               set $fontFace tranwrd($fontFace,", sans-serif","");
               set $fontFace tranwrd($fontFace,"sans-serif","");
            done;

            set $fontFace tranwrd($fontFace,"SAS Monospace, ","");
            set $fontFace tranwrd($fontFace,"SAS Monospace","");
            set $fontFace tranwrd($fontFace,"'","");
            set $fontFace tranwrd($fontFace," ,",",");
            set $fontname scan($fontFace,1,",");
            eval $count 1;
            unset $tmp_fontFace;

            do /while ^cmp( $fontname, " ");
               iterate $bad_fonts;

               do /while _value_;
                  set $fontname strip($fontname);

                  do /if cmp( $fontname, _value_);
                     unset $fontname /if cmp( $fontname, _value_);
                     stop;
                  done;

                  next $bad_fonts;
               done;


               do /if $fontname;
                  set $tmp_fontFace $tmp_fontFace ", " /if $tmp_fontFace;
                  set $tmp_fontFace $tmp_fontFace $fontname;
                  unset $fontname;
               done;

               eval $count $count +1;
               set $fontname scan($fontFace,$count,",");
               set $fontname strip($fontname);
            done;

            set $fontFace $tmp_fontFace;
            eval $comma index($fontFace,",");
            eval $comma_index $comma;
            eval $comma_count 0;
            set $tmp_fontFace $fontFace;

            do /while $comma > 0;
               eval $comma $comma +1;
               eval $comma_count $comma_count +1;

               do /if $comma_count = 3;
                  eval $comma_index $comma_index -1;
                  set $fontFace substr($fontFace,1,$comma_index);
                  stop;
               done;

               set $tmp_fontFace substr($tmp_fontFace,$comma);
               eval $comma index($tmp_fontFace,",");
               eval $comma_index $comma_index + $comma;
            done;

            putq " ss:FontName=" strip($fontFace);
            unset $fontFace;
         done;

         eval $pt_pos index(FONT_SIZE,"pt") -1;

         do /if $pt_pos > 0;
            set $size substr(font_size,1,$pt_pos);
            putq " ss:Size=" $size;

         else;
            set $size $font_size[FONT_SIZE ];
            putq " ss:Size=" $font_size[FONT_SIZE ];
         done;


         do /if cmp( htmlclass, "data");
            stop /if $data_point_size;
            set $data_point_size $size;
         done;


         do /if cmp( htmlclass, "header");
            stop /if $header_point_size;
            set $header_point_size $size;
         done;

         put " ss:Italic=""1""" /if cmp( FONT_STYLE, "italic");
         put " ss:Bold=""1""" /if cmp( FONT_WEIGHT, "bold");
         putq " ss:Color=" FOREGROUND /if ^cmp( foreground, "transparent");
         put " />" NL;
      done;


      do /if background;
         put "<Interior";

         do /if ^cmp( background, "transparent");
            putq " ss:Color=" BACKGROUND;
            put " ss:Pattern=""Solid""" /if exist( BACKGROUND);
         done;

         put " />" NL;
      done;

   end;
   define event output;
      start:

         trigger worksheet /if cmp( $sheet_interval, "table");

         trigger worksheet /if cmp( $sheet_interval, "proc");

      finish:

         trigger worksheet /if cmp( $sheet_interval, "table");

         trigger worksheet /if cmp( $sheet_interval, "bygroup");
   end;
   define event proc;
      start:

         trigger options_setup;
         set $align getoption("center");
         set $proc_name name;

      finish:

         trigger worksheet /if cmp( $sheet_interval, "proc");
   end;
   define event worksheet_label;

      do /if label;
         set $label label;

      else;
         set $label proc_name;
      done;


      do /if $sheet_name;

         do /if $sheet_names[$sheet_name];
            eval $name_count $sheet_names[$sheet_name ] +0;
            eval $name_count $name_count +1;
            eval $sheet_names[$sheet_name ] $name_count;

         else;
            eval $sheet_names[$sheet_name ] 1;
         done;

         set $worksheetName $sheet_name " " $name_count;

      else;
         set $worksheetName $sheet_label " ";

         do /if cmp( $sheet_interval, "none");
            set $worksheetName "Job " /if ^$sheet_label;
            set $worksheetName $worksheetName $numberOfWorksheets " - " $label;

         else /if cmp( $sheet_interval, "proc");
            set $worksheetName "Proc " /if ^$sheet_label;
            set $worksheetName $worksheetName total_Proc_count " - " $label;

         else /if cmp( $sheet_interval, "page");
            set $worksheetName "Page " /if ^$sheet_label;
            set $worksheetName $worksheetName total_page_count " - " $label;

         else /if cmp( $sheet_interval, "bygroup");
            set $worksheetName "By " /if ^$sheet_label;
            set $worksheetName $worksheetName $numberOfWorksheets " " $byGroupLabel " - " $label;

         else /if cmp( $sheet_interval, "table");
            set $worksheetName "Table " /if ^$sheet_label;
            set $worksheetName $worksheetName $numberOfWorksheets " - " $label;
         done;

      done;

      unset $byGroupLabel;
      unset $label;
   end;
   define event clean_worksheet_label;
      set $worksheetName tranwrd($worksheetName,"/"," ");
      set $worksheetName tranwrd($worksheetName,"\"," ");
      set $worksheetName tranwrd($worksheetName,"?"," ");
      set $worksheetName tranwrd($worksheetName,"*"," ");
      set $worksheetName tranwrd($worksheetName,":"," ");
      set $worksheetName tranwrd($worksheetName,"'"," ");
      eval $worksheetNameLength length($worksheetName);

      do /if $worksheetNameLength > 31;
         set $worksheetName substr($worksheetName,1,31);
      done;

   end;
   define event worksheet;
      start:

         do /if $proclist[proc_name];
            putlog "Excel XML does not support output from Proc:" proc_name;
            putlog "Output will not be created.";
            break;
         done;

         break /if $worksheet_started;
         unset $worksheet_widths;
         unset $worksheet_has_panes;
         unset $worksheet_has_autofilter;
         eval $worksheet_row 0;
         eval $numberOfWorksheets $numberOfWorksheets +1;

         trigger worksheet_label;

         trigger clean_worksheet_label;
         unset $$worksheet_start;

         open worksheet_start;
         putq "<Worksheet ss:Name=" $worksheetName ">" NL;
         unset $tempWorksheetName;
         unset $worksheetName;
         put "<x:WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel"">" NL;
         put "<x:PageSetup>" NL;
         put $$page_setup /if ^$embedded_titles;

         do /if $landscape;
            put "<Layout x:Orientation=""Landscape"" x:StartPageNumber=""2""/>" NL;
            put "<PageMargins x:Right=""0.5"" x:Top=""0.75""/>" NL;
         done;

         put "</x:PageSetup>" NL;
         close;

         open worksheet;
         set $worksheet_started "True";

      finish:
         break /if $proclist[proc_name];
         break /if ^$worksheet_started;
         unset $worksheet_started;

         open master_worksheet;
         put $$worksheet_start;
         unset $$worksheet_start;

         trigger worksheet_head_end;

         trigger table_start;
         put $$worksheet;
         putl "</Table>";
         eval $table_count 0;
         unset $$worksheet;
         putl "</Worksheet>";
   end;
   define event table_start;
      break /if ^$regular_table;
      unset $regular_table;
      put "<Table";
      putq " ss:StyleID=" $table_class;
      putl ">";
      iterate $worksheet_widths;

      do /while _value_;
         put "<ss:Column ss:AutoFitWidth=""1""";
         eval $numeric_width inputn(_value_,"BEST");
         putq " ss:Width=" _value_ /if $numeric_width > 0;
         put "/>" NL;
         next $worksheet_widths;
      done;

   end;
   define event worksheet_head_end;

      do /if any( $frozen_headers, $frozen_rowheaders);
         stop /if $worksheet_has_panes;
         put "<Selected/>" NL;
         put "<FreezePanes/>" NL;
         put "<FrozenNoSplit/>" NL;
         set $worksheet_has_panes "true";

         do /if $embedded_titles;

            do /if $titles;
               eval $row_count $row_count + $titles +1;
               eval $worksheet_row $worksheet_row + $titles +1;
            done;

         done;

         unset $panes;
         eval $pane_count 0;

         do /if $frozen_headers;

            do /if $row_count > 0;
               put "<SplitHorizontal>" $row_count "</SplitHorizontal>" NL;
               put "<TopRowBottomPane>" $row_count "</TopRowBottomPane>" NL;
               eval $pane_count $pane_count +2;
               set $panes["3" ] "3";
               set $panes["2" ] "2";
               set $active_pane "2";
            done;

         done;


         do /if $frozen_rowheaders;

            do /if $best_rowheader_count > 0;
               put "<SplitVertical>" $best_rowheader_count "</SplitVertical>" NL;
               put "<LeftColumnRightPane>" $best_rowheader_count "</LeftColumnRightPane>" NL;
               eval $pane_count $pane_count +2;

               do /if $panes["3"];
                  set $panes["0" ] "0";
                  set $active_pane "0";

               else;
                  set $panes["3" ] "3";
                  set $active_pane "1";
               done;

               set $panes["1" ] "1";
            done;

         done;


         do /if $panes;
            put "<ActivePane>" $active_pane "</ActivePane>" NL;
            put "<Panes>" NL;
            putvars $panes "<Pane>" NL "<Number>" _name_ "</Number>" NL "</Pane>" NL;
            put "</Panes>" NL;
         done;

         put "<ProtectObjects>False</ProtectObjects>" NL;
         put "<ProtectScenarios>False</ProtectScenarios>" NL;
      done;

      put "</x:WorksheetOptions>" NL;

      do /if $autofilter;
         stop /if $worksheet_has_autofilter;
         set $worksheet_has_autofilter "True";
         putq "<AutoFilter";
         put " x:Range=""";
         eval $last $last_autofilter_col +1;

         do /if cmp( $autofilter, "all");
            put "R" $autofilter_row "C1:R" $last_autofilter_row "C" $last;

         else /if index($autofilter, "-");
            eval $tmp_col inputn(scan($autofilter,1,"-") , "BEST" );
            set $tmp_col $last /if $tmp_col > $last;
            put "R" $autofilter_row "C" $tmp_col;
            eval $tmp_col inputn(scan($autofilter,2,"-") , "BEST" );
            set $tmp_col $last /if $tmp_col > $last;
            put ":R" $last_autofilter_row "C" $tmp_col;

         else;
            eval $tmp_col inputn($autofilter,"BEST");
            set $tmp_col $last /if $tmp_col > $last;
            put "R" $autofilter_row "C" $tmp_col;
            put ":R" $last_autofilter_row "C" $tmp_col;
         done;

         put """ xmlns=""urn:schemas-microsoft-com:office:excel"">";
         putq "</AutoFilter>";
      done;

      unset $autofilter_row;
      unset $last_autofilter_row;
   end;
   define event byline;
      set $byGroupLabel VALUE;
      set $byline value;
      set $byline_style htmlclass;

      trigger worksheet finish /if cmp( $sheet_interval, "bygroup");

      trigger worksheet /if cmp( $sheet_interval, "bygroup");
   end;
   define event verbatim;
      start:
         eval $colcount 0;

         trigger worksheet;
         put "<Table";
         putq " ss:StyleID=" HTMLCLASS;
         putl ">";
         put "<ss:Column ss:AutoFitWidth=""1""/>" NL;

      finish:

         trigger embedded_footnotes;
         putl "</Table>";
         unset $batch_one;

         trigger worksheet finish /if cmp( $sheet_interval, "table");

         trigger worksheet finish /if cmp( $sheet_interval, "bygroup");
   end;
   define event verbatim_text;

      trigger worksheet_or_head;
      put "<Row ss:StyleID=""Batch""><Cell ss:StyleID=""Batch"">";
      putq "<Data ss:Type=""String""";
      put ">";
      set $value "." value;
      set $value strip($value);
      put $value;
      unset $value;
      putl "</Data></Cell></Row>";

      open worksheet;
   end;
   define event table;
      start:
         unset $auto_sub_totals_done;
         eval $colcount 0;
         eval $row_count 0;
         eval $rowheader_count 0;
         eval $best_rowheader_count 0;
         eval $first_data_column 0;

         trigger worksheet;

         do /if ^$table_count;
            eval $table_count 1;

         else;
            eval $table_count $table_count +1;
         done;


         do /if $worksheet_row > 0;
            eval $worksheet_row $worksheet_row +1;
            eval $table_index $worksheet_row;

         else /if $sheet_interval ^  in ("table", "bygroup");

            do /if $byline;
               eval $table_index 1;
               eval $worksheet_row 1;
            done;

         done;

         set $regular_table "True";
         set $table_class HTMLCLASS;
         set $is_a_table_head "true";

      finish:

         do /if $table_count = $autofilter_table;

            do /if ^$last_autofilter_row;
               eval $last_autofilter_row $worksheet_row;
               eval $last_autofilter_col $colcount;
            done;

         done;


         trigger embedded_footnotes;

         trigger worksheet finish /if cmp( $sheet_interval, "table");

         trigger worksheet finish /if cmp( $sheet_interval, "bygroup");
   end;
   define event row;
      start:

         trigger worksheet_or_head;

         do /if exists( $table_index, $byline);
            set $span_cell_index $table_index;
            set $span_cell_style $byline_style;

            trigger span_cell start;
            put $byline;

            trigger span_cell finish;
            eval $table_index $table_index +1;
            eval $worksheet_row $worksheet_row +1;
            unset $span_cell_index;
            unset $byline;
         done;

         put "<Row";
         putq " ss:Index=" $table_index;
         putq " ss:StyleID=" HTMLCLASS;
         putl ">";
         unset $table_index;
         eval $worksheet_row $worksheet_row +1;

         do /if cmp( section, "head");
            eval $row_count $row_count +1;

         else /if cmp( section, "body");
            eval $data_row_count $data_row_count +1;
         done;


         do /if cmp( section, "body");

            do /if $rowheader_count > $best_rowheader_count;
               eval $best_rowheader_count $rowheader_count;
            done;

            eval $rowheader_count 0;
         done;


         open worksheet;

      finish:

         trigger worksheet_or_head;
         putl "</Row>";
         set $auto_sub_totals_done "True" /if ($auto_sub_totals_done, "Almost");

         open worksheet;
   end;
   define event colspec_entry;
      start:

         open worksheet;
         set $colwidth strip(colwidth);

         do /if exists( name);
            eval $header_len length(name);

         else;
            eval $header_len 0;
         done;


      finish:

         do /if $colwidth;
            eval $number_of_chars inputn($colwidth,"BEST");

            do /if missing($number_of_chars);
               eval $number_of_chars 0 +0;
            done;


         else;
            eval $number_of_chars 0 +0;
         done;


         do /if $number_of_chars = 0;
            stop /if ^$default_widths;
            eval $index $default_widths;

            do /if $index > 1;
               eval $tmp_colcount $colcount +1;
               eval $index $default_widths;

               do /if $index > $tmp_colcount;
                  eval $index $tmp_colcount;

               else /if $tmp_colcount > $index;

                  do /while $tmp_colcount > $index;
                     eval $tmp_colcount $tmp_colcount - $default_widths;
                  done;

                  eval $index $tmp_colcount;
               done;

            done;

            set $defwid $default_widths[$index ];
            eval $number_of_chars inputn($defwid,"BEST");
         done;


         do /if $widthPoints;
            eval $points $widthPoints;

         else;
            eval $points max(inputn($header_point_size,"3.") , inputn($data_point_size,"3.") );
         done;


         do /if $number_of_chars < $header_len;
            eval $difference $header_len - $number_of_chars;

            do /if $difference = 1;
               eval $number_of_chars $header_len +1;

            else;
               eval $number_of_chars $header_len +0;
            done;

            unset $difference;
         done;


         do /if exists( $number_of_chars, $Points, $widthfudge);
            eval $width $Points * $number_Of_Chars * $widthfudge;
            set $table_widths[] $width;
         done;

         eval $colcount $colcount +1;
   end;
   define event sub_colspec_header;
      eval $header_len 0;

      do /if value;
         eval $header_len length(value);
         eval $headerStringIndex index(value,%nrstr("&#10;"));

         do /if $headerStringIndex > 0;
            eval $headerStringIndex 1;
            eval $header_len 0;
            set $headerFragment scan(value,$headerStringIndex,%nrstr("&#10;"));

            do /while ^cmp( $headerFragment, " ");
               eval $header_len max($header_len,length($headerFragment) );
               eval $headerStringIndex $headerStringIndex +1;
               eval $headerFragment scan(value,$headerStringIndex,%nrstr("&#10;"));
            done;

         done;

         unset $headerStringIndex;
         unset $headerFragment;
      done;

   end;
   define event MergeAcross;
      eval $mergeAcross inputn(COLSPAN,"3.") -1;
      putq " ss:MergeAcross=" $mergeAcross;
      unset $mergeAcross;
   end;
   define event MergeDown;
      eval $mergeDown inputn(ROWSPAN,"3.") -1;
      putq " ss:MergeDown=" $mergeDown;
      unset $mergeDown;
   end;
   define event cell_start;
      start:

         do /if any( font_face, font_size, font_style, font_weight, foreground, background, borderwidth, bordercolor);

            trigger xl_style_elements;
            set $style_over_ride "true";

         else;
            unset $style_over_ride;
         done;


         open cell_start;

         trigger MergeAcross /if COLSPAN;

         trigger MergeDown /if ROWSPAN;
         putq " ss:Index=" COLSTART;
         close;
         set $format_override $attrs["format" ] /if $attrs;

         trigger worksheet_or_head;
         set $cell_class htmlclass;

      finish:
         break /if ^$$cell_start;

         trigger worksheet_or_head;
         put "<Cell";
         putq " ss:StyleID=" $cell_class;
         unset $formula;
         set $formula $attrs["formula" ] /if $attrs;

         do /if $formula;
            putq " ss:Formula=" $formula;

         else;
            stop /if ^$auto_sub_totals;
            stop /if cmp( $auto_sub_totals_done, "True");
            stop /if ^cmp( $proc_name, "print");
            stop /if cmp( section, "head");
            stop /if ^colstart;
            stop /if $first_data_column > inputn(colstart, "BEST");
            stop /if ^cmp( event_name, "header");
            set $tmp_value strip(value);
            stop /if $data_row_count < 2 & $first_data_column = 0;

            do /if $tmp_value;
               eval $tmp_count $data_row_count -1;
               put " ss:Formula=";
               put """=SUBTOTAL(9,R[-" $tmp_count "]C:R[-1]C)""";
               unset $tmp_count;
               set $auto_sub_totals_done "Almost";
            done;

            unset $tmp_value;
         done;

         put $$cell_start;
         put ">";
         unset $$cell_start;
         close;
   end;
   define event style_over_ride;
      break /if ^$style_over_ride;

      do /if $style_list[$cell_class];

         do /if $$style_elements;
            eval $style_list[$cell_class ] $style_list[$cell_class ] +1;

         else;
            set $cell_class $cell_class $style_list[$cell_class ];
            break;
         done;


      else;
         eval $style_list[$cell_class ] 1;
      done;

      set $cell_class $cell_class $style_list[$cell_class ];
      flush;

      open style;
      put "<Style ss:ID=""" $cell_class """";
      putq " ss:Parent=" $parent_class ">" NL;
      put $$style_elements;
      unset $$style_elements;

      trigger cell_format;
      putl "</Style>";
      close;

      open worksheet;
   end;
   define event resolve_cell_format;
      set $parent_class $cell_class;

      do /if $format_override;
         set $cell_class $cell_class "_manual";
         set $key $parent_class $format_override;

         do /if ^$manual_format_styles[$key];
            eval $format_override_count $format_override_count +1;
            set $manual_format_styles[$key ] $format_override_count;
            set $cell_class $cell_class $format_override_count "_";

         else;
            set $cell_class $cell_class $manual_format_styles[$key ] "_";
         done;

         set $style_over_ride "true";

      else;

         do /if cmp( $format, $currency_format);
            set $cell_class $cell_class "_currency";

            do /if ^$currency_styles[$parent_class];
               set $currency_styles[$parent_class ] $cell_class;
            done;

            set $style_over_ride "true";

         else /if cmp( $format, "Percent");
            set $cell_class $cell_class "_percent";

            do /if ^$percentage_styles[$parent_class];
               set $percentage_styles[$parent_class ] $cell_class;
            done;

            set $style_over_ride "true";
         done;

      done;


      trigger style_over_ride;
      unset $parent_class;
   end;
   define event cell_and_value;
      break /if ^any( value, $empty);

      do /if ^$cell_tag;

         trigger value_type;

         trigger resolve_cell_format;

         trigger worksheet_or_head;

         trigger cell_start finish;

         open worksheet;
      done;


      trigger value_put;
   end;
   define event tagattr_settings;
      unset $attrs;
      break /if ^tagattr;
      break /if cmp( section, "head");

      do /if index(tagattr, ":") > 0;
         eval $index 1;
         set $tmp scan(tagattr,$index," ");

         do /while ^cmp( $tmp, " ");

            do /if prxmatch($tagattr_regex, $tmp);
               set $attr scan($tmp,1,":");
               set $attrs[$attr ] scan($tmp,2,":");

            else;
               set $attrs[$attr ] $attrs[$attr ] " " $tmp;
            done;

            eval $index $index +1;
            set $tmp scan(tagattr,$index," ");
         done;


      else;
         set $attrs["format" ] tagattr;
      done;

   end;
   define event data;
      start:

         trigger tagattr_settings;
         unset $format_override;

         do /if cmp( section, "body");

            do /if ^$first_data_column & cmp( event_name, "data");
               eval $first_data_column inputn(colstart,"BEST");
            done;

         done;


         trigger cell_start start;

         trigger cell_and_value /if value;
         set $in_a_cell "true";

      finish:

         do /if ^$value_put;
            set $empty "true";

            trigger cell_and_value;
            unset $empty;
         done;

         unset $value_put;
         unset $in_a_cell;

         trigger worksheet_or_head;
         put "</Data>";
         putl "</Cell>";

         open worksheet;
   end;
   define event value_type;
      set $value strip(VALUE);
      set $format "General";

      do /if $value;
         eval $is_numeric prxmatch($number,$value);

         do /if $is_numeric;
            set $type "Number";
            set $value compress($value,$punctuation);

            do /if index(value, %nrstr("%%")) > 0;
               set $format "Percent" /if index(value, %nrstr("%%")) > 0;
               eval $tmp inputn($value,$test_format) / 100;
               set $value $tmp;

            else /if index(value, $currency) > 0;
               set $format $currency_format /if index(value, $currency) > 0;
            done;


         else;
            set $type "String";
         done;


      else;
         set $type "String";
         set $type "Number" /if cmp( type, "int");
         set $type "Number" /if cmp( type, "double");
         set $type "String" /if cmp( type, "string");
      done;

   end;
   define event value_put;

      trigger worksheet_or_head;

      do /if ^$value_put;

         do /if cmp( event_name, "header");
            set $tmp_val strip(value);
            set $type "String" /if ^$tmp_val;
            unset $tmp_val;
         done;

         putq "<Data ss:Type=" $type;
         put ">";
         set $value_put "true";
         unset $type;
      done;

      put $value;
      unset $value;

      open worksheet;
   end;
   define event worksheet_or_head;

      do /if $is_a_table_head;

         open table_headers;

      else;

         open worksheet;
      done;

   end;
   define event rowspec;
      start:
         break /if $is_a_table_head;

      open table_headers;
   end;
   define event table_head;
      start:
         break /if $colspecs_are_done;
         set $is_a_table_head "true";

         open table_headers;

      finish:

         do /if $colspecs_are_done;
            unset $colspecs_are_done;
            break;
         done;

         unset $is_a_table_head;
         close;
   end;
   define event table_body;

      do /if $$table_headers;

         do /if $titles_are_done;
            unset $titles_are_done;

         else;

            trigger embedded_title;
         done;

         put $$table_headers;
         unset $$table_headers;
      done;


      do /if $table_count = $autofilter_table;

         do /if ^$autofilter_row;
            eval $autofilter_row $worksheet_row;
         done;

      done;

      unset $is_a_table_head;
      eval $data_row_count 0;
   end;
   define event colspecs;
      start:

         trigger worksheet_or_head;

      finish:
         eval $colcount $colcount -1;
         set $colspecs_are_done "true";

         trigger embedded_title;
         put $$table_headers;
         unset $$table_headers;
         set $titles_are_done "true";
         eval $count 1;

         do /while $table_widths;

            do /if $worksheet_widths[$count];
               eval $width inputn($worksheet_widths[$count],"Best");

               do /if $width < inputn($table_widths[1], "Best");
                  set $worksheet_widths[$count ] $table_widths[1 ];
               done;


            else;
               set $worksheet_widths[] $table_widths[1 ];
            done;

            unset $table_widths[1 ];
            eval $count $count +1;
         done;

   end;
   define event header;
      start:

         do /if cmp( section, "body");
            eval $rowheader_count $rowheader_count +1;
         done;


         trigger data;

      finish:

         trigger data;
   end;
   define event embedded_title;
      break /if ^$embedded_titles;
      break /if ^$titles;

      do /if ^$worksheet_row;
         eval $worksheet_row 0;
      done;

      eval $worksheet_row $worksheet_row + $titles +1;
      eval $count 1;

      do /while $count <= $titles;
         set $span_cell_style $title_styles[$count ];

         trigger span_cell start;
         put $titles[$count ];

         trigger span_cell finish;
         eval $count $count +1;
      done;

      unset $span_cell_style;
      unset $titles;

      trigger span_cell start;

      trigger span_cell finish;
   end;
   define event embedded_footnotes;
      break /if ^$embedded_titles;
      break /if ^$footers;

      trigger span_cell start;

      trigger span_cell finish;

      do /if ^$worksheet_row;
         eval $worksheet_row 0;
      done;

      eval $worksheet_row $worksheet_row + $footers +1;
      eval $count 1;

      do /while $count <= $footers;
         set $span_cell_style $footer_styles[$count ];

         trigger span_cell start;
         put $footers[$count ];

         trigger span_cell finish;
         eval $count $count +1;
      done;

      unset $footers;
   end;
   define event span_cell;
      start:
         putq "<Row";
         putq " ss:Index=" $span_cell_index;
         put " ss:StyleID=""Table"">";
         put "<Cell";
         putq " ss:StyleID=" $span_cell_style;
         putq " ss:MergeAcross=" $colcount;
         put ">";
         putq "<Data ss:Type=""String""";
         put ">";

      finish:
         put "</Data>";
         put "</Cell></Row>" NL;
   end;
   define event hyperlink;

      trigger put_value;
   end;
   define event put_value;

      do /if $in_a_cell;

         trigger cell_and_value /if value;

      else;
         put strip(VALUE);
      done;

   end;
   define event put_value_cr;

      do /if $in_a_cell;

         trigger cell_and_value /if value;

      else;
         put strip(VALUE) NL;
      done;

   end;
   define event page_setup;
      start:
         unset $$page_setup;
         unset $titles;
         unset $footers;

         open page_setup;

      finish:
         close;

         open worksheet;

         trigger worksheet finish /if cmp( $sheet_interval, "page");

         trigger worksheet start /if cmp( $sheet_interval, "page");

         trigger worksheet start /if cmp( $sheet_interval, "none");

         trigger worksheet start /if cmp( $sheet_interval, "proc");
   end;
   define event system_title_setup_group;
      start:
         unset $titles;
         unset $title_styles;
         put "<x:Header ";

      finish:
         putl """/>";
         unset $not_first;
   end;
   define event system_footer_setup_group;
      start:
         unset $footers;
         unset $footer_styles;
         put "<x:Footer ";

      finish:
         putl """/>";
         unset $not_first;
   end;
   define event title_data;

      do /if $not_first;
         put NL;

      else;
         putq " ss:StyleID=" htmlclass;
         putq " Data=""";
      done;

      put value;
      flush;
      set $not_first "True";
   end;
   define event system_title_setup;

      trigger title_data;
      set $tmp_value strip(value);
      set $tmp_value " " /if ^$tmp_value;
      set $titles[] $tmp_value;
      unset $tmp_value;

      trigger title_footer_over_rides;
      set $title_styles[] $style_name;
   end;
   define event system_footer_setup;

      trigger title_data;
      set $tmp_value strip(value);
      set $tmp_value " " /if ^$tmp_value;
      set $footers[] $tmp_value;
      unset $tmp_value;

      trigger title_footer_over_rides;
      set $footer_styles[] $style_name;
   end;
   define event title_footer_over_rides;
      set $style_name htmlclass;

      do /if any( font_face, font_size, font_style, font_weight, foreground, background, borderwidth, bordercolor);

         do /if cmp( event_name, "system_title_setup");

            do /if $title_style_count;
               eval $title_style_count $title_style_count +1;

            else;
               eval $title_style_count 1;
            done;

            set $style_name htmlclass "_" $title_style_count;

         else /if cmp( event_name, "system_footer_setup");

            do /if $footer_style_count;
               eval $footer_style_count $footer_style_count +1;

            else;
               eval $footer_style_count 1;
            done;

            set $style_name htmlclass "_" $footer_style_count;
         done;


         trigger xl_style_elements;

         open style;
         put "<Style ss:ID=""" $style_name """";
         putq " ss:Parent=" $htmlclass ">" NL;
         put $$style_elements;
         unset $$style_elements;
         putl "</Style>";
         close;

         open page_setup;
      done;

   end;
   define event putvars;
      put NL "----- Event Variables -----" NL;
      putvars event _NAME_ "=" _VALUE_ NL;
      put "----- Style Variables -----" NL;
      putvars style _NAME_ "=" _VALUE_ NL;
      put NL;
   end;
   log_note = "NOTE: This is the Excel XP tagset (SUGI 30 release). Add options(doc='help') to the ods statement for more information.";
   nobreakspace = " ";
   registered_tm = %nrstr("&reg;");
   trademark = %nrstr("&trade;");
   copyright = %nrstr("&copy;");
   mapsub = %nrstr("/&lt;/&gt;/&amp;/");
   map = %nrstr("<>&");
   split = %nrstr("&#10;");
   indent = 0;
   output_type = "xml";
   stacked_columns = OFF;
   pure_style = OFF;
   embedded_stylesheet;
end;
run; quit;