                                                                                                                      
                                                                                                                                        
proc template;                                                                                                                          
define tagset Tagsets.Msoffice2k_x;                                                                                                     
  define event initialize;                                                                                                              
  putlog "v2.60";                                                                                                                       
                                                                                                                                        
  do /if $options["DOC"];                                                                                                               
    set $doc $options["DOC"];                                                                                                           
  else;                                                                                                                                 
      unset $doc;                                                                                                                       
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["ORIENTATION"];                                                                                                       
    set $orientation $options["ORIENTATION" ];                                                                                          
  else;                                                                                                                                 
      unset $orientation;                                                                                                               
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["PRINT_HEADER"];                                                                                                      
      set $print_header $options["PRINT_HEADER" ];                                                                                      
  else;                                                                                                                                 
      unset $print_header;                                                                                                              
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["PRINT_FOOTER"];                                                                                                      
      set $print_footer $options["PRINT_FOOTER" ];                                                                                      
  else;                                                                                                                                 
      unset $print_footer;                                                                                                              
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["MARGIN"];                                                                                                            
      set $margin $options["MARGIN" ];                                                                                                  
  else;                                                                                                                                 
    unset $margin;                                                                                                                      
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["PRINT_HEADER_MARGIN"];                                                                                               
      set $header_margin $options["HEADER_MARGIN" ];                                                                                    
  else;                                                                                                                                 
      unset $header_margin;                                                                                                             
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["PRINT_FOOTER_MARGIN"];                                                                                               
      set $footer_margin $options["FOOTER_MARGIN" ];                                                                                    
  else;                                                                                                                                 
    unset $footer_margin;                                                                                                               
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["RIGHT_MARGIN"];                                                                                                      
      set $right_margin $options["RIGHT_MARGIN" ];                                                                                      
  else;                                                                                                                                 
    unset $right_margin;                                                                                                                
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["LEFT_MARGIN"];                                                                                                       
      set $left_margin $options["LEFT_MARGIN" ];                                                                                        
  else;                                                                                                                                 
    unset $left_margin;                                                                                                                 
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["BOTTOM_MARGIN"];                                                                                                     
      set $bottom_margin $options["BOTTOM_MARGIN" ];                                                                                    
  else;                                                                                                                                 
    unset $bottom_margin;                                                                                                               
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["TOP_MARGIN"];                                                                                                        
      set $top_margin $options["TOP_MARGIN" ];                                                                                          
  else;                                                                                                                                 
    unset $top_margin;                                                                                                                  
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["SHEET_NAME"];                                                                                                        
      set $sheet_name $options["SHEET_NAME" ];                                                                                          
  else;                                                                                                                                 
    unset $sheet_name;                                                                                                                  
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["ZOOM"];                                                                                                              
      set $zoom $options["ZOOM"];                                                                                                       
  else;                                                                                                                                 
    unset $zoom;                                                                                                                        
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["FROZEN_HEADERS"];                                                                                                    
    set $frozen_headers $options["FROZEN_HEADERS" ];                                                                                    
  else;                                                                                                                                 
    unset $frozen_headers;                                                                                                              
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["FROZEN_ROWHEADERS"];                                                                                                 
    set $frozen_rowheaders $options["FROZEN_ROWHEADERS" ];                                                                              
  else;                                                                                                                                 
    unset $frozen_rowheaders;                                                                                                           
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["SCALE"];                                                                                                             
    set $scale $options["SCALE" ];                                                                                                      
  else;                                                                                                                                 
    unset $scale;                                                                                                                       
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["GRIDLINES"];                                                                                                         
    set $gridlines $options["GRIDLINES" ];                                                                                              
  else;                                                                                                                                 
    unset $gridlines;                                                                                                                   
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["BLACKANDWHITE"];                                                                                                     
    set $blackandwhite $options["BLACKANDWHITE" ];                                                                                      
  else;                                                                                                                                 
    unset $blackandwhite;                                                                                                               
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["DRAFTQUALITY"];                                                                                                      
    set $draftquality $options["DRAFTQUALITY" ];                                                                                        
  else;                                                                                                                                 
    unset $draftquality;                                                                                                                
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["PRINT_FITHEIGHT"];                                                                                                   
    set $fitheight $options["PRINT_FITHEIGHT" ];                                                                                        
  else;                                                                                                                                 
    unset $fitheight;                                                                                                                   
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["PRINT_FITWIDTH"];                                                                                                    
    set $fitwidth $options["PRINT_FITWIDTH" ];                                                                                          
  else;                                                                                                                                 
    unset $fitwidth;                                                                                                                    
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["PAPERSIZE"];                                                                                                         
    set $papersize $options["PAPERSIZE" ];                                                                                              
  else;                                                                                                                                 
    unset $papersize;                                                                                                                   
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["AUTOFILTER"];                                                                                                        
    set $autofilter $options["AUTOFILTER" ];                                                                                            
  else;                                                                                                                                 
    unset $autofilter;                                                                                                                  
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["WORKSHEET_SOURCE"];                                                                                                  
    set $worksheet_source $options["WORKSHEET_SOURCE" ];                                                                                
  else;                                                                                                                                 
    unset $worksheet_source;                                                                                                            
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["PAGEBREAK"];                                                                                                         
    set $pagebreak $options["PAGEBREAK" ];                                                                                              
  else;                                                                                                                                 
    unset $pagebreak;                                                                                                                   
  done;                                                                                                                                 
                                                                                                                                        
                                                                                                                                        
  do /if $options["TABCOLOR"];                                                                                                          
    set $tabcolor $options["TABCOLOR" ];                                                                                                
  else;                                                                                                                                 
    unset $tabcolor;                                                                                                                    
  done;                                                                                                                                 
                                                                                                                                        
                                                                                                                                        
  do /if $options["FITTOPAGE"];                                                                                                         
    set $fit2page $options["FITTOPAGE" ];                                                                                               
  else;                                                                                                                                 
    unset $fit2page;                                                                                                                    
  done;                                                                                                                                 
                                                                                                                                        
                                                                                                                                        
  do /if $options["LEADING_ZERO"];                                                                                                      
    set $leading_zero $options["LEADING_ZERO" ];                                                                                        
  else;                                                                                                                                 
    unset $leading_zero;                                                                                                                
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["ROTATE_HEADERS"];                                                                                                    
    set $rotate_headers $options["ROTATE_HEADERS" ];                                                                                    
  else;                                                                                                                                 
    unset $rotate_headers;                                                                                                              
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["HEIGHT"];                                                                                                            
    set $height $options["HEIGHT" ];                                                                                                    
  else;                                                                                                                                 
    unset $height;                                                                                                                      
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["NOWARN_PATH"];                                                                                                       
    set $nowarn_path $options["NOWARN_PATH" ];                                                                                          
  else;                                                                                                                                 
    unset $nowarn_path;                                                                                                                 
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["IMAGE_PATH"];                                                                                                        
    set $image_path $options["IMAGE_PATH" ];                                                                                            
  else;                                                                                                                                 
    unset $image_path;                                                                                                                  
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["IMAGE_HEIGHT"];                                                                                                      
    set $image_height $options["IMAGE_HEIGHT" ];                                                                                        
  else;                                                                                                                                 
    unset $image_height;                                                                                                                
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["IMAGE_WIDTH"];                                                                                                       
    set $image_width $options["IMAGE_WIDTH" ];                                                                                          
  else;                                                                                                                                 
    unset $image_width;                                                                                                                 
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["PAGEBREAK_ROW"];                                                                                                     
    set $pagebreak_row $options["PAGEBREAK_ROW" ];                                                                                      
  else;                                                                                                                                 
    unset $pagebreak_row;                                                                                                               
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["EMBEDDED_TITLES"];                                                                                                   
    set $embedded_titles $options["EMBEDDED_TITLES" ];                                                                                  
  else;                                                                                                                                 
    unset $embedded_titles;                                                                                                             
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["EMBEDDED_TITLES_ONCE"];                                                                                              
    set $embedded_titles_once $options["EMBEDDED_TITLES_ONCE" ];                                                                        
  else;                                                                                                                                 
    unset $embedded_titles_once;                                                                                                        
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["EMBEDDED_FOOTNOTES"];                                                                                                
    set $embedded_footnotes $options["EMBEDDED_FOOTNOTES" ];                                                                            
  else;                                                                                                                                 
    unset $embedded_footnotes;                                                                                                          
  done;                                                                                                                                 
                                                                                                                                        
  do / if $options["GRAPH_HEIGHT"];                                                                                                     
    set $graph_height $options["GRAPH_HEIGHT" ];                                                                                        
  else;                                                                                                                                 
    unset $graph_height;                                                                                                                
  done;                                                                                                                                 
                                                                                                                                        
  do / if $options["GRAPH_WIDTH"];                                                                                                      
    set $graph_width $options["GRAPH_WIDTH" ];                                                                                          
  else;                                                                                                                                 
    unset $graph_width;                                                                                                                 
  done;                                                                                                                                 
                                                                                                                                        
  do / if $options["WORKSHEET_LOCATION"];                                                                                               
    set $worksheet_location $options["WORKSHEET_LOCATION" ];                                                                            
  else;                                                                                                                                 
    unset $worksheet_location;                                                                                                          
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["BANNER_COLOR_EVEN"];                                                                                                 
      set $banner_even $options["BANNER_COLOR_EVEN" ];                                                                                  
                                                                                                                                        
  else;                                                                                                                                 
     unset $banner_even;                                                                                                                
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["BANNER_COLOR_ODD"];                                                                                                  
     set $banner_odd $options["BANNER_COLOR_ODD" ];                                                                                     
                                                                                                                                        
  else;                                                                                                                                 
     unset $banner_odd;                                                                                                                 
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["FBANNER_COLOR_EVEN"];                                                                                                
    set $fbanner_even $options["FBANNER_COLOR_EVEN" ];                                                                                  
                                                                                                                                        
  else;                                                                                                                                 
     unset $fbanner_even;                                                                                                               
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["FBANNER_COLOR_ODD"];                                                                                                 
     set $fbanner_odd $options["FBANNER_COLOR_ODD" ];                                                                                   
                                                                                                                                        
  else;                                                                                                                                 
    unset $fbanner_odd;                                                                                                                 
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["HEADER_BGCOLOR"];                                                                                                    
     set $header_bgcolor $options["HEADER_BGCOLOR"];                                                                                    
                                                                                                                                        
  else;                                                                                                                                 
     unset $header_bgcolor;                                                                                                             
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["HEADER_FGCOLOR"];                                                                                                    
     set $header_fgcolor $options["HEADER_FGCOLOR"];                                                                                    
                                                                                                                                        
  else;                                                                                                                                 
     unset $header_fgcolor;                                                                                                             
  done;                                                                                                                                 
                                                                                                                                        
  do /if $options["ROWHEADER_BGCOLOR"];                                                                                                 
     set $rowheader_bgcolor $options["ROWHEADER_BGCOLOR"];                                                                              
                                                                                                                                        
  else;                                                                                                                                 
     unset $rowheader_bgcolor;                                                                                                          
  done;                                                                                                                                 
                                                                                                                                        
                                                                                                                                        
  trigger set_just_lookup;                                                                                                              
  trigger set_nls_num;                                                                                                                  
  trigger valid_options;                                                                                                                
  trigger check_valid_options;                                                                                                          
  trigger list_options / if cmp($options["DOC"],"help");                                                                                
  putlog $doc;                                                                                                                          
end;                                                                                                                                    
                                                                                                                                        
define event javascript;                                                                                                                
end;                                                                                                                                    
define event startup_Function;                                                                                                          
end;                                                                                                                                    
define event shutdown_function;                                                                                                         
end;                                                                                                                                    
                                                                                                                                        
define event valid_options;                                                                                                             
        set $valid_options["DOC"]                                                                                                       
              "Specifies the options for the tagset";                                                                                   
        set $valid_options["ORIENTATION"]                                                                                               
              "Modifies worksheet page orientation";                                                                                    
        set $valid_options["PRINT_HEADER"]                                                                                              
              "Specifies text for header section of the page setup";                                                                    
        set $valid_options["PRINT_FOOTER"]                                                                                              
              "Specifies footer section of the page setup";                                                                             
        set $valid_options["MARGIN"]                                                                                                    
              "Modifies worksheet margins specifying each margin separated by a comma";                                                 
        set $valid_options["PRINT_HEADER_MARGIN"] "Specifies margins for header section";                                               
        set $valid_options["PRINT_FOOTER_MARGIN" ] "Specifies margins for the footer section";                                          
        set $valid_options["LEFT_MARGIN" ] "Specifies the left margins for the worksheet";                                              
        set $valid_options["RIGHT_MARGIN" ] "Specifies the right margins for the worksheet";                                            
        set $valid_options["TOP_MARGIN" ] "Specifies the top margin for the worksheet";                                                 
        set $valid_options["BOTTOM_MARGIN" ] "Specifies the bottom margin for the worksheet";                                           
        set $valid_options["SHEET_NAME" ] "Modifies sheet name";                                                                        
        set $valid_options["FROZEN_HEADERS" ] "Freezes column headers";                                                                 
        set $valid_options["FROZEN_ROWHEADERS" ] "Freezes row headers";                                                                 
        set $valid_options["SCALE" ] "Modifies the print scale";                                                                        
        set $valid_options["GRIDLINES"] "modifies the gridlines";                                                                       
        set $valid_options["BLACKANDWHITE"]                                                                                             
              "Modifies print color to black and white";                                                                                
        set $valid_options["DRAFTQUALITY"]                                                                                              
              "Modifies work sheet print setting";                                                                                      
        set $valid_options["PRINT_FITHEIGHT"]                                                                                           
              "modifies the fitheight page setup setting";                                                                              
        set $valid_options["PRINT_FITWIDTH"]                                                                                            
              "Modifies the fitwidth page setup setting";                                                                               
        set $valid_options["PAPERSIZE"]                                                                                                 
              "Modifies current paper size";                                                                                            
        set $valid_options["AUTOFILTER"]                                                                                                
              "Adds filters to headers";                                                                                                
        set $valid_options["WORKSHEET_SOURCE"]                                                                                          
              "Adds multiple worksheets per workbook by taking separates HTML files";                                                   
        set $valid_options["NOWARN_PATH"]                                                                                               
              "Adds path which removes the warning dialog when adding multiple sheets per workbook";                                    
        set $valid_options["PAGEBREAK"]                                                                                                 
              "Provides the ability to modify pagebreak";                                                                               
        set $valid_options["TABCOLOR"]                                                                                                  
              "Modifies the tab color";                                                                                                 
        set $valid_options["FITTOPAGE"]                                                                                                 
              "Modifies the page settup fit to page option";                                                                            
        set $valid_options["LEADING_ZERO"]                                                                                              
              "retains leading zeroes";                                                                                                 
        set $valid_options["ROTATE_HEADERS"]                                                                                            
              "Provides rotation values for headers. Works in cunjunction with the HEIGHT= option";                                     
        set $valid_options["HEIGHT"] "Modifies the height of the headers";                                                              
        set $valid_options["ZOOM"] "Applies zoom to each table individually by specifying zoom value separated by a comma";             
        set $valid_options["OPEN_MACRO"] " Adds a macro which executes when the worksheet loads ";                                      
        set $valid_options["CLOSE_MACRO"] " Adds a macro which executes when the worksheet closed";                                     
        set $valid_options["PANELCOLS"] "Panels tables and graphs";                                                                     
        set $valid_options["PANEL_SPACE"] "Adds the number of blanks cells to add between tables or graphs";                            
        set $valid_options["IMAGE_PATH"] "Path to image or logo";                                                                       
        set $valid_options["IMAGE_HEIGHT"] "Height of image specified with the image_path option";                                      
        set $valid_options["IMAGE_WIDTH"] "Width of image specified with the image_path option";                                        
        set $valid_options["EMBEDDED_TITLES"] "Removes titles from the worksheet";                                                      
        set $valid_options["EMBEDDED_FOOTNOTES"] "Removes footnotes from the worksheet";                                                
        set $valid_options["PAGEBREAK_ROW"] "Sets the rows break on";                                                                   
        set $valid_options["GRAPH_WIDTH"] "Sets width for the graphs";                                                                  
        set $valid_options["WORKSHEET_LOCATION"] "AddS the starting row and column of the output";                                      
        set $valid_options["BANNER_COLOR_EVEN"] "Sets the background color for the even rows";                                          
        set $valid_options["BANNER_COLOR_ODD"] "Sets the background color for the odd rows";                                            
        set $valid_options["FBANNER_COLOR_EVEN"] "Sets the foreground color for the even rows";                                         
        set $valid_options["FBANNER_COLOR_ODD"] "Sets the foreground color for the odd rows";                                           
        set $valid_options["HEADER_BGCOLOR"] "Sets the background color for the headers";                                               
        set $valid_options["DATA_BGCOLOR"] "Sets the background color for table cells";                                                 
                                                                                                                                        
  end;                                                                                                                                  
  define event check_valid_options;                                                                                                     
      break /if ^$options;                                                                                                              
      iterate $options;                                                                                                                 
                                                                                                                                        
      do /while _name_;                                                                                                                 
         do /if ^$valid_options[_name_];                                                                                                
            putlog "Unrecognized option: "  _name_;                                                                                     
         done;                                                                                                                          
                                                                                                                                        
         next $options;                                                                                                                 
     done;                                                                                                                              
                                                                                                                                        
     end;                                                                                                                               
     define event list_options;                                                                                                         
        iterate $valid_options;                                                                                                         
        putlog                                                                                                                          
              "==============================================================                                                           
================";                                                                                                                      
        putlog "Short descriptions of the supported options";                                                                           
        putlog                                                                                                                          
              "==============================================================                                                           
================";                                                                                                                      
        putlog "Name    :  Description";                                                                                                
        putlog " ";                                                                                                                     
                                                                                                                                        
        do /while _name_;                                                                                                               
            unset $option;                                                                                                              
            set $option $options[_name_ ];                                                                                              
            set $option $option_defaults[_name_ ] /if ^$option;                                                                         
            putlog _name_ " :  " ;                                                                                                      
            putlog "      "  _value_;                                                                                                   
                        putlog " ";                                                                                                     
            next $valid_options;                                                                                                        
        done;                                                                                                                           
                                                                                                                                        
        putlog " ";                                                                                                                     
    end;                                                                                                                                
                                                                                                                                        
 define event doc;                                                                                                                      
    start:                                                                                                                              
      put "<html xmlns:x=""urn:schemas-microsoft-com:office:excel""" NL;                                                                
          put "      xmlns:v=""urn:schemas-microsoft-com:vml"">" NL;                                                                    
                                                                                                                                        
    finish:                                                                                                                             
      put "</html>" NL;                                                                                                                 
 end;                                                                                                                                   
                                                                                                                                        
 define event doc_head;                                                                                                                 
   start:                                                                                                                               
     put "<head>" NL;                                                                                                                   
     put "<meta name=""Excel Workbook Frameset"">" NL /if $worksheet_source;                                                            
                                                                                                                                        
     do / if $nowarn_path;                                                                                                              
        putq "<link rel=File-List href=" $nowarn_path ">" NL / if $worksheet_source;                                                    
     done;                                                                                                                              
     break / if $worksheet_source;                                                                                                      
                                                                                                                                        
  /*********************************************************** /                                                                        
  /* Defining the items of the page setup such as the margins */                                                                        
  /* and the page orientation.                                */                                                                        
  /************************************************************/                                                                        
                                                                                                                                        
  do /if any($orientation, $print_header, $print_footer, $margin, $header_margin, $footer_margin,                                       
            $left_margin,$top_margin,$right_margin,$bottom_margin);                                                                     
                                                                                                                                        
    put "<style> @page {";                                                                                                              
    put " mso-page-orientation:landscape; " / if cmp($orientation,"landscape");                                                         
    putq " mso-header-data:" $print_header ";" NL /if $print_header;                                                                    
    putq " mso-footer-data:" $print_footer ";" NL /if $print_footer;                                                                    
    put " margin: " $margin ";" NL / if $margin;                                                                                        
    put " margin-left:" $left_margin ";" NL /  if $left_margin;;                                                                        
    put " margin-right:" $right_margin ";" NL / if $right_margin; ;                                                                     
    put " margin-top:" $top_margin ";" NL /  if $top_margin;;                                                                           
    put " margin-bottom" $bottom_margin ";" NL / if $bottom_margin;                                                                     
    put " mso-header-margin:" $header_margin ";" NL /if $header_margin;                                                                 
    put " mso-footer-margin:" $footer_margin ";" NL /if $footer_margin;                                                                 
    put "}</style>" NL;                                                                                                                 
  done;                                                                                                                                 
                                                                                                                                        
  put VALUE NL;                                                                                                                         
                                                                                                                                        
  do / if exist($image_path);                                                                                                           
     putq "<img src=" $image_path  ;                                                                                                    
     put " height=" $image_height ;                                                                                                     
     put " width="  $image_width;                                                                                                       
     put " />" NL;                                                                                                                      
     put "</br>" NL;                                                                                                                    
     put "</br>" NL;                                                                                                                    
  done;                                                                                                                                 
                                                                                                                                        
 finish:                                                                                                                                
     put "<style type=""text/css"">" NL;                                                                                                
     put "table {" NL;                                                                                                                  
     putq "  mso-displayed-decimal-separator:" $decimal_separator ";"   NL;                                                             
     putq "  mso-displayed-thousand-separator:" $thousand_separator ";" NL;                                                             
     put "}" NL;                                                                                                                        
                                                                                                                                        
     do / if any($banner_even,$banner_odd,$fbanner_even,$fbanner_odd);                                                                  
         put ".first {" / if any($banner_even,$fbanner_even);                                                                           
         put " background-color:"  $banner_even " !important;" NL / if $banner_even;                                                    
         put " color:" $fbanner_even " !important;" NL / if $fbanner_even;                                                              
         put "}" NL /  if any($banner_even,$fbanner_even);                                                                              
                                                                                                                                        
         put ".second {" / if any($banner_odd,$fbanner_odd);                                                                            
         put " background-color:"  $banner_odd " !important;" NL / if $banner_odd;                                                      
         put " color:" $fbanner_odd " !important;" NL / if $fbanner_odd;                                                                
         put "}" NL / if any ($banner_odd,$fbanner_odd);                                                                                
     done;                                                                                                                              
                                                                                                                                        
     put "</style>" NL;                                                                                                                 
                                                                                                                                        
     do / if any($orientation,$sheet_name,$zoom,$frozen_headers,$frozen_rowheaders,$scale, $gridlines,                                  
                  $blackandwhite,$draftquality,$fitheight, $fitwidth, $papersize,$pagebreak, $tabcolor,                                 
                  $options['CLOSE_MACRO'], $options['CLOSE_MACRO'],$worksheet_source);
          set $xmloptions "true";
     done;


     do / if cmp($xmloptions,"true"); 
                                                                                                                                        
       put "<!--[if gte mso 9]><xml>" NL;                                                                                            
                                                                                                                                        
                                                                                                                                        
 /***************************************************************************/                                                          
 /* Adds syntax which allows a macro to be executed when the page is loaded */                                                          
 /* *************************************************************************/                                                          
                                                                                                                                        
  do / if $options['OPEN_MACRO'];                                                                                                       
    put "<x:ExcelName>" NL;                                                                                                             
    put "  <x:Name>auto_open</x:Name>" NL;                                                                                              
    put "  <x:Macro>Command</x:Macro>" NL;                                                                                              
    put "  <x:Formula>" $options['OPEN_MACRO'] "</x:Formula>" NL;                                                                       
    put "</x:ExcelName>" NL;                                                                                                            
  done;                                                                                                                                 
                                                                                                                                        
 /***************************************************************************/                                                          
 /* Adds syntax which allows a macro to be executed when the page is closed */                                                          
 /* *************************************************************************/                                                          
                                                                                                                                        
 do / if $options['CLOSE_MACRO'];                                                                                                       
     put "<x:ExcelName>" NL;                                                                                                            
     put "  <x:Name>auto_close</x:Name>" NL;                                                                                            
     put "  <x:Macro>Command</x:/Macro>" NL;                                                                                            
     put "  <x:Formula>" $options['OPEN_MACRO'] "</x:Formula>" NL;                                                                      
     put "</x:ExcelName>" NL;                                                                                                           
 done;                                                                                                                                  
                                                                                                                                        
     put "<x:ExcelWorkbook>" NL;                                                                                                        
     put " <x:ExcelWorksheets>" NL;                                                                                                     
     put " <x:ExcelWorksheet>" NL /if ^$worksheet_source;                                                                               
                                                                                                                                        
 /******************************************************************/                                                                   
 /* Adds a sheet name if the SHEET_NAME= option is used, otherwise */                                                                   
 /* A default sheet name is given.                                 */                                                                   
 /******************************************************************/                                                                   
                                                                                                                                        
  do /if $sheet_name;                                                                                                                   
    put " <x:Name>" $sheet_name "</x:Name>" NL;                                                                                         
  else;                                                                                                                                 
    put " <x:Name>Sheet1</x:Name>" NL /if ^any($sheet_name,$worksheet_source);                                                          
  done;                                                                                                                                 
                                                                                                                                        
 /******************************************************************/                                                                   
 /* Specifies the line to dd the pge break.                        */                                                                   
 /*                                                                */                                                                   
 /******************************************************************/                                                                   
                                                                                                                                        
  do /if $pagebreak_row;                                                                                                                
                                                                                                                                        
      do /if index($pagebreak_row,",");                                                                                                 
         set $pbreak_value scan($pagebreak_row,1,",");                                                                                  
         eval $page_cnt 1;                                                                                                              
                                                                                                                                        
         do /while ^cmp($pbreak_value," ");                                                                                             
            set $pbreak_row[] strip($pbreak_value);                                                                                     
            eval $page_cnt $page_cnt +1;                                                                                                
            set $pbreak_value scan($pagebreak_row,$page_cnt,",");                                                                       
         done;                                                                                                                          
                                                                                                                                        
      else;                                                                                                                             
         set $pbreak_row[] strip($pagebreak_row);                                                                                       
      done;                                                                                                                             
                                                                                                                                        
    iterate $pbreak_row;                                                                                                                
                                                                                                                                        
       put " <x:PageBreaks>" NL;                                                                                                        
    do /while _value_;                                                                                                                  
                                                                                                                                        
       put "  <x:RowBreaks>" NL;                                                                                                        
       put "   <x:RowBreak>" NL;                                                                                                        
       put "    <x:Row>" _value_  "</x:Row>" NL;                                                                                        
       put "   </x:RowBreak>" NL;                                                                                                       
       put "  </x:RowBreaks>" NL;                                                                                                       
                                                                                                                                        
     next $pbreak_row;                                                                                                                  
    done;                                                                                                                               
      put " </x:PageBreaks>" NL;                                                                                                        
 done;                                                                                                                                  
                                                                                                                                        
                                                                                                                                        
  /******************************************************************/                                                                  
  /* When creating multiple worksheets per workbook, the sheet name */                                                                  
  /* and the name of the HTML file are given.                       */                                                                  
  /*                                                                */                                                                  
  /* options(worksheet_source="A#c:\temp.html,B#c:\temp.html")      */                                                                  
  /*                                                                */                                                                  
  /******************************************************************/                                                                  
                                                                                                                                        
 do /if $worksheet_source;                                                                                                              
   do /if index($worksheet_source, ",");                                                                                                
     set $worksource scan($worksheet_source,1,",");                                                                                     
     eval $wsheet 1;                                                                                                                    
     do /while ^cmp( $worksource, " ");                                                                                                 
        set $w_sheet[] strip($worksource);                                                                                              
        eval $wsheet $wsheet +1;                                                                                                        
        set $worksource scan($worksheet_source,$wsheet,",");                                                                            
     done;                                                                                                                              
   done;                                                                                                                                
                                                                                                                                        
  iterate $w_sheet;                                                                                                                     
  eval $tcount 0;                                                                                                                       
                                                                                                                                        
  do /while _value_;                                                                                                                    
    do /if contains( $worksheet_source, "#");                                                                                           
       put " <x:ExcelWorksheet>" NL;                                                                                                    
       set $sheet scan(_value_,1,"#");                                                                                                  
       set $path scan(_value_,2,"#");                                                                                                   
       put " <x:Name>" $sheet "</x:Name>" NL;                                                                                           
      putq " <x:WorksheetSource HRef=" $path "/>" NL;                                                                                   
    else;                                                                                                                               
      eval $tcount $tcount +1;                                                                                                          
      eval $sname catx(" ","Table",$tcount);                                                                                            
      put " <x:ExcelWorksheet>" NL;                                                                                                     
      put " <x:Name>" $sname "</x:Name>" NL;                                                                                            
      putq " <x:WorksheetSource HRef=" _value_ "/>" NL;                                                                                 
    done;                                                                                                                               
      put " </x:ExcelWorksheet>" NL;                                                                                                    
   next $w_sheet;                                                                                                                       
                                                                                                                                        
  done;                                                                                                                                 
done;                                                                                                                                  
/*done; */                                                                                                                                  
                                                                                                                                        
 /*******************************************************************/                                                                  
 /* Add various options such as the display and page setup options  */                                                                  
 /*******************************************************************/                                                                  
 /*do / if cmp($xmloptions,"true"); */
  do /if ^exist( $worksheet_source);                                                                                                     
   put " <x:WorksheetOptions>" NL;                                                                                                      
   put "  <x:Zoom>" $zoom "</x:Zoom>" NL /if $zoom;                                                                                     
   put "  <x:Gridlines/>" NL /if $gridlines;                                                                                            
   put "  <x:FitToPage/>" NL /if $fit2page;                                                                                             
   do /if any($frozen_headers,$frozen_rowheaders);                                                                                      
      put "  <x:FreezePanes/>" NL;                                                                                                      
      put "  <x:FrozenNoSplit/>" NL;                                                                                                    
                                                                                                                                        
      do / if $frozen_headers;                                                                                                      
        put "  <x:SplitHorizontal>" $frozen_headers "</x:SplitHorizontal>" NL;                                                          
        put "  <x:TopRowBottomPane>" $frozen_headers "</x:TopRowBottomPane>" NL;                                                        
      done;                                                                                                                         
                                                                                                                                        
      do / if $frozen_rowheaders;                                                                                                   
        put "  <x:SplitVertical>" $frozen_rowheaders "</x:SplitVertical>" NL;                                                           
        put "  <x:LeftColumnRightPane>" $frozen_rowheaders "</x:LeftColumnRightPane>" NL;                                               
     done;                                                                                                                              
   done;                                                                                                                                
                                                                                                                                        
      put " <x:Print>" NL;                                                                                                              
      put " <x:Scale>" $scale "</x:Scale>" NL /if $scale;                                                                               
      put " <x:ValidPrinterInfo/>" NL;                                                                                                  
      put " <x:BlackAndWhite/> " NL /if $blackandwhite;                                                                                 
      put " <x:DraftQuality/>" NL /if $draftquality;                                                                                    
      put " <x:FitDraftQuality/>" NL /if $draftquality;                                                                                 
      put " <x:FitWidth>" $fitwidth "</x:FitWidth>" /if $fitwidth;                                                                      
      put " <x:FitHeight>" $fitheight "</x:FitHeight>" /if $fitheight;                                                                  
                                                                                                                                        
  /**********************************************************/                                                                          
  /* Add the paper size based on the agument passed         */                                                                          
  /**********************************************************/                                                                          
                                                                                                                                        
  do /if $papersize;                                                                                                                    
      set $paper["letter"] "1";                                                                                                         
      set $paper["lettersmall"] "2";                                                                                                    
      set $paper["legal"] "5";                                                                                                          
      set $paper["executive"] "7";                                                                                                      
      set $paper["10X14" ] "16";                                                                                                        
      set $paper["11X17" ] "17";                                                                                                        
      set $paper["A4" ] "11";                                                                                                           
      set $paper["A4SMALL" ] "10";                                                                                                      
      set $paper["A5" ] "11";                                                                                                           
      set $paper["A6" ] "5";                                                                                                            
      set $paper[] $papersize;                                                                                                          
      put " <x:PaperSizeIndex>" $paper[$papersize ] "</x:PaperSizeIndex>" NL;                                                           
   done;                                                                                                                                
      put " </x:Print>" NL;                                                                                                             
                                                                                                                                        
 /**********************************************************/                                                                           
 /* Add the tab color based on the value passed            */                                                                           
 /**********************************************************/                                                                           
                                                                                                                                        
  do /if exists( $tabcolor);                                                                                                            
    set $tab_color["black" ] "0";                                                                                                       
    set $tab_color["white" ] "1";                                                                                                       
    set $tab_color["red" ] "2";                                                                                                         
    set $tab_color["green" ] "3";                                                                                                       
    set $tab_color["blue" ] "4";                                                                                                        
    set $tab_color["yellow" ] "5";                                                                                                      
    set $tab_color["magenta" ] "6";                                                                                                     
    set $tab_color["cyan" ] "7";                                                                                                        
                                                                                                                                        
    set $tab_color[]  $tabcolor;                                                                                                        
                                                                                                                                        
    do / if $tab_color[$tabcolor];                                                                                                      
       put "<x:TabColorIndex>" $tab_color[$tabcolor];                                                                                   
    else;                                                                                                                               
       put "<x:TabColorIndex>" $tabcolor;                                                                                               
    done;                                                                                                                               
                                                                                                                                        
    put "</x:TabColorIndex>";                                                                                                           
  done;                                                                                                                                 
                                                                                                                                        
    put "   <x:ActivePane>2</x:ActivePane>" NL / if exist($frozen_headers);                                            
    put " </x:WorksheetOptions>" NL;                                                                                                    
 done;                                                                                                                                  
    put " </x:ExcelWorksheet>" NL /if ^$worksheet_source;                                                                               
    put "</x:ExcelWorksheets>" NL;                                                                                                      
    put "<x:WindowHeight>12495</x:WindowHeight>" NL;                                                                                    
    put "<x:WindowWidth>18900</x:WindowWidth>" NL;                                                                                      
    put "<x:WindowTopX>60</x:WindowTopX>" NL;                                                                                           
    put "<x:WindowTopY>45</x:WindowTopY>" NL;                                                                                           
    put "<x:ProtectStructure>False</x:ProtectStructure>" NL;                                                                            
    put "<x:ProtectWindows>False</x:ProtectWindows>" NL;                                                                                
    put "</x:ExcelWorkbook>" NL;                                                                                                        
    put "</xml><![endif]-->" NL;                                                                                                        
                                                                                                                                        
  done;                                                                                                                                
 /* done;  */                                                                                                                               
                                                                                                                                        
   put "</head>" NL;                                                                                                                    
                                                                                                                                        
 end;                                                                                                                                   
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
  /*****************************************************/                                                                               
  /* Sets option the title and footnote options        */                                                                               
  /******************************************************/                                                                              
                                                                                                                                        
  define event system_title;                                                                                                            
    eval $tcount[] event_name;                                                                                                          
    break / if cmp($embedded_titles,"no");                                                                                              
                                                                                                                                        
    do / if cmp($embedded_titles_once,"yes");                                                                                           
       break / if $tcount > 1;                                                                                                          
     done;                                                                                                                              
                                                                                                                                        
         start:                                                                                                                         
                                                                                                                                        
           do / if $worksheet_location;                                                                                                 
             do / if $tcount <= 1;                                                                                                      
                 set $col_location scan($worksheet_location,1);                                                                         
                 set $col_location repeat("<td>",$col_location);                                                                        
                 set $row_location scan($worksheet_location,2);                                                                         
                 putq "<Table border=0><TD rowspan=" $row_location "></td></table>";                                                    
                 put "<Table border=0>";                                                                                                
                 put $col_location;                                                                                                     
             done;                                                                                                                      
           done;                                                                                                                        
                                                                                                                                        
                                                                                                                                        
            put "<h1";                                                                                                                  
            putq " class=" htmlclass;                                                                                                   
            trigger align;                                                                                                              
            trigger style_inline;                                                                                           
                                                                                                                                        
            put ">";                                                                                                                    
            put VALUE;                                                                                                                  
            break /if exists( value);                                                                                                   
            put %nrstr("&nbsp;") /if exists( empty);                                                                                    
                                                                                                                                        
         finish:                                                                                                                        
            break / if cmp($embedded_titles,"no");                                                                              
            put "</h1>" NL;                                                                                                             
      end;                                                                                                                              
                                                                                                                                        
      define event system_footer;                                                                                                       
         break / if cmp($embedded_footnotes,"no");                                                                                      
         start:                                                                                                                         
            put "<h1";                                                                                                                  
            putq " class=" htmlclass;                                                                                                   
            trigger align;                                                                                                              
            trigger style_inline;                                                                                           
                                                                                                                                        
            put ">";                                                                                                                    
            put VALUE;                                                                                                                  
                                                                                                                                        
         finish:                                                                                                                        
           break / if cmp($embedded_footnotes,"no");                                                                                    
           put "</h1>" NL;                                                                                                              
      end;                                                                                                                              
                                                                                                                                        
     define event proc_list;                                                                                                            
                                                                                                                                        
         set $proclist["Gchart"] "1";                                                                                                   
         set $proclist["Gplot"] "1";                                                                                                    
         set $proclist["Gmap"] "1";                                                                                                     
         set $proclist["Gkpi"] "1";                                                                                                     
         set $proclist["Gcontour" ] "1";                                                                                                
         set $proclist["G3d" ] "1";                                                                                                     
         set $proclist["Gbarline" ] "1";                                                                                                
         set $proclist["Gareabar" ] "1";                                                                                                
         set $proclist["Gradar" ] "1";                                                                                                  
         set $proclist["Gslide" ] "1";                                                                                                  
         set $proclist["Ganno" ] "1";                                                                                                   
         set $proclist["Sgplot"] "1";                                                                                                   
         set $proclist["Sgpanel"] "1";                                                                                                  
         set $proclist["Sgrender"] "1";                                                                                                 
                                                                                                                                        
  end;                                                                                                                                  
                                                                                                                                        
  define event doc_body;                                                                                                                
     put "<body class=""Body"" style="" text-align: center;"">" NL;
                                                                                                                                      
  finish:                                                                                                                               
                                                                                                                                        
     trigger pre_post;                                                                                                                  
     put "</body>" NL;                                                                                                                  
  end;                                                                                                                                  
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
 /********************************************/                                                                                         
 /* Panel tables and graphs in the worksheet */                                                                                         
 /********************************************/                                                                                         
                                                                                                                                        
  define event proc;                                                                                                                    
                                                                                                                                        
   trigger proc_list;                                                                                                                   
   set $panelcols $options["PANELCOLS" ];                                                                                               
   eval $panel[] event_name;                                                                                                            
   set $pantmp $panel;                                                                                                                  
                                                                                                                                        
      do /if $options["PANELCOLS"];                                                                                                     
         set $pagebreak "no";                                                                                                           
         set $endcol sum($pantmp,$panelcols);                                                                                           
         eval $endcol inputn($endcol,"best");                                                                                           
         eval $endcol $endcol -1;                                                                                                       
         set $startx[] $pantmp;                                                                                                         
                                                                                                                                        
                                                                                                                                        
       do / if cmp($pantmp,"1");                                                                                                        
         put "<table>" NL;                                                                                                              
         put "<tr>" NL;                                                                                                                 
       done;                                                                                                                            
     done;                                                                                                                              
                                                                                                                                        
                                                                                                                                        
        /* Modified 2/21 PROC_COUNT does not generate valid count */                                                                    
        /* Added spaces when the value of panelcols is missing    */                                                                    
                                                                                                                                        
    do /if exist( $startx[$pantmp]);                                                                                                    
       put "</td>" NL /if ^$options["PANELCOLS"];                                                                                       
       do / if $options['PANEL_SPACE'];                                                                                                 
          set $panel_space $options['PANEL_SPACE'];                                                                                     
          eval $panel_space inputn($panel_space,"best")-1;                                                                                
          set $panel_space repeat("<td></td>",$panel_space);                                                                            
          put $panel_space / if proc_count ne 0;                                                                                        
       else;                                                                                                                            
         eval $panel_space 0;                                                                                                           
         eval $panel_space repeat("<td></td>",$panel_space);                                                                            
         put $panel_space / if ^$options["PANELCOLS"];                                                                                  
       done;                                                                                                                            
                                                                                                                                        
          put "<td width=";                                                                                                             
          do / if !$graph_width;                                                                                                        
               trigger ms_graph_width;                                                                                                  
           else;                                                                                                                        
               put $graph_width;                                                                                                        
           done;                                                                                                                        
                                                                                                                                        
          put ">" NL;                                                                                                                   
                                                                                                                                        
     done;                                                                                                                              
                                                                                                                                        
                                                                                                                                        
   finish:                                                                                                                              
    do / if $proclist[proc_name];                                                                                                       
       set $graphics "true";                                                                                                            
     done;                                                                                                                              
                                                                                                                                        
      set $x $endcol;                                                                                                                   
      set $y $pantmp;                                                                                                                   
                                                                                                                                        
      do /if cmp( $x, $y);                                                                                                              
            put "</td>" NL;                                                                                                             
            put "</tr>" NL;                                                                                                             
                                                                                                                                        
        do / if !cmp($graphics,"true");                                                                                                 
            put "</table>" NL ;                                                                                                         
            put "<br>" NL;                                                                                                              
            put "<table>" NL;                                                                                                           
            put "<tr>" NL;                                                                                                              
        done;                                                                                                                           
      done;                                                                                                                             
     done;                                                                                                                              
                                                                                                                                        
    unset $options["PANELCOLS" ];                                                                                                       
                                                                                                                                        
end;                                                                                                                                    
                                                                                                                                        
 /***************************************************/                                                                                  
 /* Set up alternating banner colors for foreground */                                                                                  
 /* and background colors                           */                                                                                  
 /***************************************************/                                                                                  
                                                                                                                                        
  define event banner_colors;                                                                                                           
                                                                                                                                        
  do /if any( $banner_even, $banner_odd, $fbanner_odd, $fbanner_even);                                                                  
   eval $data_row inputn(data_row,"best");                                                                                              
                                                                                                                                        
      do /if mod($data_row, 2);                                                                                                         
                                                                                                                                        
         do /if any( $banner_odd, $fbanner_odd);                                                                                        
           put " class=""second""" ;                                                                                                    
           else;                                                                                                                        
           done;                                                                                                                        
                                                                                                                                        
           else;                                                                                                                        
                                                                                                                                        
           do /if any( $banner_even, $fbanner_even);                                                                                    
               put " class=""first""";                                                                                                  
           else;                                                                                                                        
           done;                                                                                                                        
                                                                                                                                        
       done;                                                                                                                            
   done;                                                                                                                                
 end;                                                                                                                                   
                                                                                                                                        
  /**********************************************/                                                                                      
  /* Remove the pagebreak based on the argument */                                                                                      
  /**********************************************/                                                                                      
                                                                                                                                        
  define event pagebreak;                                                                                                               
     put PAGEBREAKHTML NL /if ^cmp($pagebreak,"no");                                                                                    
  end;                                                                                                                                  
                                                                                                                                        
  define event header;                                                                                                                  
    start:                                                                                                                              
      put "<td";                                                                                                                        
      putq " title=" flyover;                                                                                                           
                                                                                                                                        
      do /if $autofilter;                                                                                                               
        put " x:autofilter=""all""" /if cmp( htmlclass, "header");                                                                      
      done;                                                                                                                             
      trigger classalign;                                                                                                               
      trigger style_inline;                                                                                                             
      trigger rowcol;                                                                                                                   
                                                                                                                                        
      /* Rotate headers */                                                                                                              
                                                                                                                                        
          do / if $rotate_headers;                                                                                                      
            do / if cmp(section,"head");                                                                                                
            put " style=""mso-rotate:" $rotate_headers ";" / if $rotate_headers;                                                        
            put " vertical-align:bottom;";                                                                                              
            put " height:" $height / if $height;                                                                                        
            put """";                                                                                                                   
            done;                                                                                                                       
          done;                                                                                                                         
                                                                                                                                        
      put ">";                                                                                                                          
      trigger cell_value;                                                                                                               
  finish:                                                                                                                               
      trigger cell_value;                                                                                                               
      put "</td>" NL;                                                                                                                   
 end;                                                                                                                                   
                                                                                                                                        
 define event data;                                                                                                                     
    start:                                                                                                                              
      trigger header /breakif cmp( htmlclass, "RowHeader");                                                                             
      trigger header /breakif cmp( htmlclass, "Header");                                                                                
                                                                                                                                        
      do /if ^$cell_count;                                                                                                              
        do /if cmp( rowspan, "2");                                                                                                      
                                                                                                                                        
          open row;                                                                                                                     
            eval $cell_count 1;                                                                                                         
                                                                                                                                        
        done;                                                                                                                           
      else;                                                                                                                             
          eval $cell_count $cell_count +1;                                                                                              
      done;                                                                                                                             
          put "<td";                                                                                                                    
          putq " title=" flyover;                                                                                                       
          trigger classalign;                                                                                                           
          trigger banner_colors;                                                                                                        
          trigger style_inline;                                                                                                         
          trigger rowcol /if ^$cell_count;                                                                                              
          put " nowrap" /if no_wrap;                                                                                                    
                                                                                                                                        
    do /if cmp($leading_zero,"yes");                                                                                                  
      set $check_var substr(value,1,1);                                                                                                 
      put " style=""mso-number-format:\@""" /if cmp( $check_var,"0"); 
   done;                                                                                                                               
                                                                                                                                        
                                                                                                                                        
    put ">";                                                                                                                            
    trigger cell_value;                                                                                                                 
                                                                                                                                        
  finish:                                                                                                                               
                                                                                                                                        
    trigger header /breakif cmp( htmlclass, "RowHeader");                                                                               
    trigger header /breakif cmp( htmlclass, "Header");                                                                                  
                                                                                                                                        
    trigger cell_value;                                                                                                                 
    put "</td>" NL;                                                                                                                     
                                                                                                                                        
  end;                                                                                                                                  
                                                                                                                                        
  define event table;                                                                                                                   
    start:                                                                                                                              
      trigger pre_post;                                                                                                                 
      put "<p>" NL;                                                                                                                     
      put "<table";                                                                                                                     
      putq " class=" HTMLCLASS;                                                                                                         
      trigger style_inline;                                                                                                             
      put " border=""1""" ;                                                                                                             
      putq " cellspacing=" CELLSPACING;                                                                                                 
      putq " cellpadding=" CELLPADDING;                                                                                                 
      set $parent_table_spacing cellspacing;                                                                                            
      set $parent_table_padding cellpadding;                                                                                            
      putq " rules=" LOWCASE(RULES);                                                                                                    
      putq " frame=" LOWCASE(FRAME);                                                                                                    
      trigger put_table_border_vars;                                                                                                    
      trigger table_summary;                                                                                                            
      put ">" NL;                                                                                                                       
  finish:                                                                                                                               
      put "</table>" NL;                                                                                                                
      trigger pre_post;                                                                                                                 
  end;                                                                                                                                  
                                                                                                                                        
  define event image;                                                                                                                   
         put "<img ";                                                                                                                   
         putq " alt=" alt;                                                                                                              
         put " src=""";                                                                                                                 
         put BASENAME /if ^exists( NOBASE);                                                                                             
         put URL;                                                                                                                       
         put """";                                                                                                                      
         put " height=""";                                                                                                              
                                                                                                                                        
         put $options['GRAPH_HEIGHT'];                                                                                                  
         trigger ms_graph_height / if ^$options['GRAPH_HEIGHT'];;                                                                       
                                                                                                                                        
         put """";                                                                                                                      
         put " width=""";                                                                                                               
         put $options['GRAPH_WIDTH'] / if $options['GRAPH_WIDTH'];                                                                      
         trigger ms_graph_width / if ^$options['GRAPH_WIDTH'];;                                                                         
                                                                                                                                        
         put """";                                                                                                                      
                                                                                                                                        
         put " border=""0""";                                                                                                           
         put " usemap=""#" @CLIENTMAP;                                                                                                  
         put " usemap=""#" NAME /if ^exists( @CLIENTMAP);                                                                               
         put """" /if any( @CLIENTMAP, NAME);                                                                                           
         putq " id=" HTMLID;                                                                                                            
         putq " id=" ref_id /if ^exists( HTMLID);                                                                                       
                                                                                                                                        
         trigger classalign;                                                                                                            
         put ">" NL;                                                                                                                    
     end;                                                                                                                               
                                                                                                                                        
     define event anchor;                                                                                                               
     end;                                                                                                                               
                                                                                                                                        
     define event style_class;                                                                                                          
     break / if $worksheet_source;                                                                                                      
        put "." HTMLCLASS NL;                                                                                                           
        put "{" NL;                                                                                                                     
                                                                                                                                        
        trigger stylesheetclass;                                                                                                        
       /* put "}" NL;*/                                                                                                                 
                                                                                                                                        
     do /if any( $options["HEADER_BGCOLOR"],$options["HEADER_FGCOLOR"]);                                                                
                                                                                                                                        
         do /if cmp( htmlclass, "header");                                                                                              
            put "  background-color:" $options["HEADER_BGCOLOR" ] ";" NL /if $options["HEADER_BGCOLOR"];                                
            put "  color:" $options["HEADER_FGCOLOR" ] ";" NL            / if $options["HEADER_FGCOLOR"];                               
         done;                                                                                                                          
                                                                                                                                        
     done;                                                                                                                              
                                                                                                                                        
     do /if cmp( htmlclass, "rowheader");                                                                                               
                                                                                                                                        
      do /if any( $options["ROWHEADER_BGCOLOR"],$options["ROWHEADER_FGCOLOR"]);                                                         
         put "  background-color:" $options["ROWHEADER_BGCOLOR" ] ";" NL  /if $options["ROWHEADER_BGCOLOR"];                            
         put "  color:" $options["ROWHEADER_FGCOLOR" ] ";" NL             /if $options["ROWHEADER_FGCOLOR"];                            
      done;                                                                                                                             
                                                                                                                                        
   done;                                                                                                                                
                                                                                                                                        
   do /if any( $options["DATA_BGCOLOR"],$options["DATA_FGCOLOR"]);                                                                      
                                                                                                                                        
      do /if cmp( htmlclass, "data");                                                                                                   
         put "  background-color:" $options["DATA_BGCOLOR" ] ";" NL /if $options["DATA_BGCOLOR"];                                       
         put "  color:" $options["DATA_FGCOLOR" ] ";" NL            /if $options["DATA_FGCOLOR"];                                       
      done;                                                                                                                             
                                                                                                                                        
   done;                                                                                                                                
                                                                                                                                        
 done;                                                                                                                                  
                                                                                                                                        
                                                                                                                                        
 do /if $gridline_color and cmp( htmlclass, "table");                                                                                   
   put "  background-color:" $gridline_color;                                                                                           
 done;                                                                                                                                  
                                                                                                                                        
                                                                                                                                        
 do /if $options["BACKGROUND_COLOR"];                                                                                                   
                                                                                                                                        
   do /if cmp( htmlclass, "systemtitle") or cmp ( htmlclass, "systemfooter")                                                            
            or cmp ( htmlclass, "systitleandfootercontainer");                                                                          
      put " background-color:" $options["BACKGROUND_COLOR" ] ";" NL;                                                                    
   done;                                                                                                                                
                                                                                                                                        
 done;                                                                                                                                  
                                                                                                                                        
 put "}" NL;                                                                                                                            
                                                                                                                                        
                                                                                                                                        
end;                                                                                                                                    
                                                                                                                                        
define event output;                                                                                                                    
end;                                                                                                                                    
                                                                                                                                        
define event align_output;                                                                                                              
end;                                                                                                                                    
                                                                                                                                        
define event branch;                                                                                                                    
end;                                                                                                                                    
                                                                                                                                      
define event alignstyle;                                                                                                                
  break / if $worksheet_source;                                                                                                         
        putl ".l {text-align: left }";                                                                                                  
        putl ".c {text-align: center }";                                                                                                
        putl ".r {text-align: right }";                                                                                                 
        putl ".d {text-align: ""."" }";                                                                                                 
        putl ".t {vertical-align: top }";                                                                                               
        putl ".m {vertical-align: middle }";                                                                                            
        putl ".b {vertical-align: bottom }";                                                                                            
        putl "TD, TH {vertical-align: top }";                                                                                           
        putl ".stacked_cell{padding: 0 }";                                                                                              
end;                                                                                                                                    
parent = tagsets.msoffice2k;                                                                                                            
                                                                                                                                        
end;                                                                                                                                
run;
 
