ods path (prepend)  Work.Ut(update);

proc template;
   define style Styles.UTStandard;
      parent = styles.printer;
      style Body from Document
         "Controls the Body file." /
         marginbottom = 0.25in
         margintop = 0.25in
         marginright = 0.25in
         marginleft = 0.25in;
      style fonts /
         'TitleFont2' = ("<serif>, Times Roman",12pt,bold)
         'TitleFont' = ("<serif>, Times Roman",12pt,bold)
         'StrongFont' = ("<serif>, Times Roman",10pt,bold)
         'EmphasisFont' = ("<serif>, Times Roman",10pt)
         'FixedEmphasisFont' = ("<monospace>, Courier",9pt)
         'FixedStrongFont' = ("<monospace>, Courier",9pt,bold)
         'FixedHeadingFont' = ("<monospace>, Courier",9pt,bold)
         'BatchFixedFont' = ("SAS Monospace, <monospace>, Courier",6.7pt)
         'FixedFont' = ("<monospace>, Courier",9pt)
         'headingEmphasisFont' = ("<serif>, Times Roman",11pt,bold )
         'headingFont' = ("<serif>, Times Roman",11pt,bold)
         'docFont' = ("<serif>, Times Roman",10pt);
      style GraphFonts /
         'GraphDataFont' = ("<serif>, <MTserif>",8pt)
         'GraphUnicodeFont' = ("<MTserif-unicode>",9pt)
         'GraphValueFont' = ("<serif>, <MTserif>",10pt)
         'GraphLabelFont' = ("<serif>, <MTserif>",11pt)
         'GraphFootnoteFont' = ("<serif>, <MTserif>",11pt)
         'GraphTitleFont' = ("<serif>, <MTserif>",12pt,bold)
         'GraphAnnoFont' = ("<serif>, <MTserif>",10pt);
      style titleAndNoteContainer from titleAndNoteContainer /
         width = _undef_;
      style cell from container /
         linkcolor = colors('link2');
      style table from table /
         padding = 3pt;
      style batch from batch /
         rules = none
         frame = void
         padding = 0pt
         borderspacing = 0pt;
      style Byline from Byline
         "Controls byline text." /
         frame = void;
      style color_list
         "Colors used in the default style" /
         'link' = blue
         'bgH' = grayBB
         'fg' = black
         'bg' = _undef_;
      style GraphBox from GraphBox /
         displayopts = "fill caps median mean outliers";
      style GraphHistogram from GraphHistogram /
         displayopts = "fill outline";
      style GraphEllipse from GraphEllipse /
         displayopts = "outline";
      style GraphBand from GraphBand /
         displayopts = "fill";
   end;
run;



proc template;
   define style Styles.UTTlf;
      parent = styles.printer;
      style Body from Document
         "Controls the Body file." /
         marginleft = 0.5in
         marginright = 0.5in
         margintop = 0.5in
         marginbottom = 0.5in;
      style fonts /
         'docFont' = ("Courier New",9pt)
         'headingFont' = ("Courier New",10pt)
         'headingEmphasisFont' = ("Courier New",10pt,bold)
         'FixedFont' = ("<monospace>, Courier New",9pt)
         'BatchFixedFont' = ("SAS Monospace, <monospace>, Courier New",6.7pt)
         'FixedHeadingFont' = ("<monospace>, Courier New",9pt,bold)
         'FixedStrongFont' = ("<monospace>, Courier New",9pt,bold)
         'FixedEmphasisFont' = ("<monospace>, Courier New",9pt)
         'EmphasisFont' = ("Courier New",9pt)
         'StrongFont' = ("Courier New",9pt)
         'TitleFont' = ("Courier New",11pt)
         'TitleFont2' = ("Courier New",11pt);
      class header /
         backgroundcolor = white;
      class table /
         padding = 1pt
         rules = groups
         borderspacing = 0
         frame = void;
   end;
run;
