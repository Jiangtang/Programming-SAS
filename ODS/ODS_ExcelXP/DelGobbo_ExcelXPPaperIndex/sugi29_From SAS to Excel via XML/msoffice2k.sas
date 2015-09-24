proc template;

define tagset Tagsets.Msoffice2k;
   notes "Special tagset for MSOffice consumption.";
   mvar _EXCELROWHEIGHT _INEXCEL _DECIMAL_SEPARATOR _THOUSANDS_SEPARATOR;
   define event initialize;

      trigger set_just_lookup;

      trigger set_nls_num;
   end;
   define event set_nls_num;
      unset $decimal_separator;
      unset $thousand_separator;
      set $decimal_separator $options["DECIMAL_SEPARATOR" ] /if $options;
      set $decimal_separator _DECIMAL_SEPARATOR /if ^$decimal_separator;
      set $decimal_separator "\." /if ^$decimal_separator;
      set $thousand_separator $options["THOUSAND_SEPARATOR" ] /if $options;
      set $thousand_separator _THOUSANDS_SEPARATOR /if ^$thousand_separator;
      set $thousand_separator "\," /if ^$thousand_separator;
   end;
   define event doc_head;
      start:
         put "<head>" NL;
         put VALUE NL;

      finish:
         put "<style type=""text/css"">" NL;
         put "table {" NL;
         putq "  mso-displayed-decimal-separator:" $decimal_separator ";" NL;
         putq "  mso-displayed-thousand-separator:" $thousand_separator ";" NL;
         put "}" NL;
         put "</style>" NL;
         put "</head>" NL;
   end;
   define event doc;
      start:
         put "<html xmlns:v=""urn:schemas-microsoft-com:vml"">" NL;

      finish:
         put "</html>" NL;
   end;
   define event title_container;
   end;
   define event title_container_row;
   end;
   define event system_title;
      start:
         put "<h1";
         putq " class=" htmlclass;

         trigger align;
         put ">";
         put VALUE;
         break /if exists( value);
         put %nrstr("&nbsp;") /if exists( empty);

      finish:
         put "</h1>" NL;
   end;
   define event system_footer;
      start:
         put "<h1";
         putq " class=" htmlclass;

         trigger align;
         put ">";
         put VALUE;

      finish:
         put "</h1>" NL;
   end;
   define event note;
      put "<h3";
      putq " class=" htmlclass;

      trigger align;
      put ">";
      put VALUE;
      put "</h3>" NL;
   end;
   define event warning;
      put "<h3";
      putq " class=" htmlclass;

      trigger align;
      put ">";
      put VALUE;
      put "</h3>" NL;
   end;
   define event error;
      put "<h3";
      putq " class=" htmlclass;

      trigger align;
      put ">";
      put VALUE;
      put "</h3>" NL;
   end;
   define event fatal;
      put "<h3";
      putq " class=" htmlclass;

      trigger align;
      put ">";
      put VALUE;
      put "</h3>" NL;
   end;
   define event put_table_border_vars;

      do /if ^exists( borderWidth);
         eval $borderW strip(tranwrd($table_border_width,"px","") );

      else;
         eval $borderW strip(tranwrd(borderwidth,"px","") );
      done;

      putq " border=" $borderW;
      putq " bordercolor=" $table_border_color /if ^exists( bordercolor);
      putq " bordercolor=" bordercolor /if exists( bordercolor);
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

         trigger style_inline;

         trigger rowcol /if ^$cell_count;
         put " nowrap" /if no_wrap;
         put ">";

         trigger cell_value;

      finish:

         trigger header /breakif cmp( htmlclass, "RowHeader");

         trigger header /breakif cmp( htmlclass, "Header");

         trigger cell_value;
         put "</td>" NL;
   end;
   define event row;
      put "<tr>" NL;

      finish:

         do /if $cell_count;
            close;
            putq "<td colspan=" $cell_count "</td>" /if $cell_count;
            eval $cell_count 0;

         else /if $$row;
            put $$row;
            unset $$row;
         done;

         put "</tr>" NL;
   end;
   define event ms_graph_width;
      set $local_width WIDTH /if ^cmp( WIDTH, "0");
      set $local_width OUTPUTWIDTH /if ^exists( WIDTH);
      set $local_width "640" /if ^exists( $local_width);
      eval $extpos index($local_width,"px");
      put $local_width /breakif $extpos = 0;
      eval $extpos $extpos -1;
      set $local_width substr($local_width,1,$extpos);
      put $local_width;
      unset $local_width;
      unset $extpos /if exists( $extpos);
      style = Graph;
      pure_style;
   end;
   define event ms_graph_height;
      set $local_height DEPTH /if ^cmp( DEPTH, "0");
      set $local_height OUTPUTHEIGHT /if ^exists( DEPTH);
      set $local_height "480" /if ^exists( $local_height);
      eval $extpos index($local_height,"px");

      do /if $extpos = 0;
         eval $heightnum inputn($local_height,"4.");
         put $local_height;
         unset $local_height;
         unset $extpos /if exists( $extpos);
         break;
      done;

      eval $extpos $extpos -1;
      set $local_height substr($local_height,1,$extpos);
      put $local_height;
      eval $heightnum inputn($local_height,"4.");
      unset $local_height;
      unset $extpos /if exists( $extpos);
      style = Graph;
      pure_style;
   end;
   define event activex_graph;
      start:

         do /if ^_INEXCEL;
            put "<table cellspacing=1 cellpadding=1 rules=NONE frame=VOID border=0 width=";

            trigger ms_graph_width;
            put ">" NL;
            put "<tr class=""c"" height=""";

            trigger ms_graph_height;
            put """>" NL;
            put "<td class=""c"" height=""";

            trigger ms_graph_height;
            put """>" NL;
            put "<v:shape id='" ref_id "_v' type='#_x0000_t201' style='position:absolute;" NL;
            put " margin-left:0;margin-top:0;";
            put "width:";

            trigger ms_graph_width;
            put "px;height:";

            trigger ms_graph_height;
            put "px'>" NL;
            put "</v:shape>" NL;
            put "<object " NL;
            putq " id=" ref_id NL;
            put " v:shapes=""" ref_id "_v""" NL;

         else;

            do /if cmp( _INEXCEL , "true");
               put "<table cellspacing=1 cellpadding=1 rules=NONE frame=VOID border=0 width=";

               trigger ms_graph_width;
               put ">" NL;
               put "<tr class=""c"">" NL;
               put "<td class=""c"">" NL;
               put "<v:shape id='" ref_id "_v' type='#_x0000_t201' style='position:absolute;" NL;
               put " margin-left:0;margin-top:0;";
               put "width:";

               trigger ms_graph_width;
               put "px;height:";

               trigger ms_graph_height;
               put "px'>" NL;
               put "</v:shape>" NL;
               put "<object " NL;
               putq " id=" ref_id NL;
               put "  v:shapes=""" ref_id "_v""" NL;

            else;
               put "<object " NL;
               putq " id=" ref_id NL;
            done;

         done;


      finish:
         put "</object> " NL;

         do /if ^_INEXCEL;
            put "</td>" NL;
            put "</tr>" NL;
            put "</table>" NL;

         else;

            do /if cmp( _INEXCEL , "true");
               put "</td>" NL;
               put "</tr>" NL;

               do /if _EXCELROWHEIGHT;
                  eval $rowheight inputn(_EXCELROWHEIGHT ,"3.");

               else;
                  eval $rowheight 17;
               done;

               eval $ratio $heightnum * ( 1 / $rowheight );
               eval $span floor($ratio);
               put "<tr style=""mso-xlrowspan:";
               put $span;
               put """></tr>" NL;
               put "</table>" NL;
               unset $ratio;
               unset $span;
               unset $rowheight;
            done;

         done;

   end;
   define event image;
      put "<div";

      trigger alt_align;
      put ">" NL;
      put "<img";
      putq " alt=" alt;
      put " src=""";
      put BASENAME /if ^exists( NOBASE);
      put URL;
      put """";
      put " height=""";

      trigger ms_graph_height;
      put """";
      put " width=""";

      trigger ms_graph_width;
      put """";
      put " border=""0""";
      put " usemap=""#" @CLIENTMAP;
      put " usemap=""#" NAME /if ^exists( @CLIENTMAP);
      put """" /if any( @CLIENTMAP, NAME);
      putq " id=" HTMLID;

      trigger classalign;
      put ">" NL;
      put "</div>" NL;
   end;
   define event html3_center;
      start:
         put "<CENTER>" NL;

      finish:
         put "</CENTER>" NL;
   end;
   define event java2_graph;
      start:

         trigger ie_check /if ^exists( $ieCheckDone);

         trigger javascript start;
         put "   document.writeln(""<OBJECT"");" NL;

         trigger graph_java_width;

         trigger graph_java_height;
         put "   document.writeln(""ALIGN=\""baseline\"""");" NL;
         put "if (_ie == true) {" NL;
         put "   document.writeln(""CLASSID=\""clsid:8AD9C840-044E-11D1-B3E9-00805F499D931\"""");" NL;
         put "   document.writeln(""CODEBASE=\""http://java.sun.com/products/plugin/autodl/jinstall-1_4_1-windows-i586.cab#Version=1,4,0,0\"""");" NL;
         put "}" NL;
         put "else {" NL;
         put "   document.writeln(""TYPE=\""application/x-java-applet;version=1.4\"""");" NL;
         put "   document.writeln(""CODEBASE=\""http://java.sun.com/products/plugin/index.html#download\"""");" NL;
         put "}" NL;

      finish:
         put "</OBJECT>" NL;
      pure_style;
   end;
   define event java2_parameters;
      put "<PARAM NAME=""TYPE"" VALUE=""application/x-java-applet;version=1.4"">" NL;
      put "<PARAM NAME=""SCRIPTABLE"" VALUE=""true"">" NL;
   end;
   define event activex_unsupported;
      put "Sorry, there was a problem with the Graph control or plugin in your browser." NL;
      putq "The graph " code " cannot be displayed." NL;
   end;
   define event graph_java_width;
      put "   document.writeln(""WIDTH=" WIDTH """);" NL /breakif ^cmp( WIDTH, "0");
      put "   document.writeln(""WIDTH=" OUTPUTWIDTH """);" NL /if exists( OUTPUTWIDTH);
      put "   document.writeln(""WIDTH=640"");" NL /if ^exists( OUTPUTWIDTH);
      style = Graph;
      pure_style;
   end;
   define event graph_java_height;
      put "   document.writeln(""HEIGHT=" DEPTH """);" NL /breakif ^cmp( DEPTH, "0");
      put "   document.writeln(""HEIGHT=" OUTPUTHEIGHT """);" NL /if exists( OUTPUTHEIGHT);
      put "   document.writeln(""HEIGHT=480"");" NL /if ^exists( OUTPUTHEIGHT);
      style = Graph;
      pure_style;
   end;
   define event graph_java2_attribute;
      put "   document.writeln(""";
      put NAME "=\""" VALUE "\""";
      put """);" NL;
   end;
   define event graph_java2_fxd_attributes;
      put "   document.writeln("">"");" NL;

      trigger javascript finish;
   end;
   define event style_inline;
      put " " tagattr;
      break /if ^any( font_face, font_size, font_weight, font_style, foreground, background, backgroundimage, leftmargin, rightmargin, topmargin, bottommargin, bullet, outputheight, outputwidth, htmlstyle, indent, text_decoration, borderwidth,
            bordertopwidth, borderbottomwidth, borderrightwidth, borderleftwidth, bordercolor, bordertopcolor, borderbottomcolor, borderrightcolor, borderleftcolor, borderstyle, bordertopstyle, borderbottomstyle, borderrightstyle, borderleftstyle, just,
            vjust);
      put " style=""";
      put " font-family: " FONT_FACE;
      put ";" / exists( FONT_FACE);
      put " font-size: " FONT_SIZE;
      put ";" / exists( FONT_SIZE);
      put " font-weight: " FONT_WEIGHT;
      put ";" / exists( FONT_WEIGHT);
      put " font-style: " FONT_STYLE;
      put ";" / exists( FONT_STYLE);
      put " color: " FOREGROUND;
      put ";" / exists( FOREGROUND);
      put " text-decoration: " text_decoration;
      put ";" / exists( text_decoration);
      put " background-color: " BACKGROUND;
      put ";" / exists( BACKGROUND);
      put "  background-image: url('" BACKGROUNDIMAGE "')" /if exists( backgroundimage);
      put ";" / exists( BACKGROUNDIMAGE);
      put " margin-left: " LEFTMARGIN;
      put ";" / exists( LEFTMARGIN);
      put " margin-right: " RIGHTMARGIN;
      put ";" / exists( RIGHTMARGIN);
      put " margin-top: " TOPMARGIN;
      put ";" / exists( TOPMARGIN);
      put " margin-bottom: " BOTTOMMARGIN;
      put ";" / exists( BOTTOMMARGIN);
      put " text-indent: " indent;
      put ";" / exists( indent);

      trigger Border_inline;
      put " list_style_type: " BULLET;
      put ";" / exists( BULLET);
      put " height: " OUTPUTHEIGHT;
      put ";" / exists( OUTPUTHEIGHT);
      put " width: " OUTPUTWIDTH;
      put ";" / exists( OUTPUTWIDTH);
      put "  text-align: " / exists( just);
      put "center" /if cmp( just, "c");
      put "right" /if cmp( just, "r");
      put "left" /if cmp( just, "l");
      put ";" / exists( just);
      put "  vertical-align: " / exists( vjust);
      put "middle" /if cmp( vjust, "c");
      put "top" /if cmp( vjust, "t");
      put "bottom" /if cmp( vjust, "b");
      put ";" / exists( vjust);
      put " " htmlstyle;
      put ";" / exists( htmlstyle);
      put """";
   end;
   define event align;
   end;
   define event headalign;
   end;
   define event classalign;
      break /if ^htmlclass;
      put " class=""" htmlclass """";
   end;
   define event classheadalign;
      break /if ^htmlclass;
      put " class=""" htmlclass """";
   end;
   parent = tagsets.html4;
   embedded_stylesheet;
end;
run; quit;