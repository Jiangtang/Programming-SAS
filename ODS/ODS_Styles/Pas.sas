

ods path (prepend)  Work.PasBiost(update); 

/*****************************************A4  PORT*****************************************************/


/* #1: Styles.A4_10_PORT_v2 : Base */
Proc Template;
  Define Style Styles.RTF_A4_10_PORT;
  Parent = Styles.Rtf;
  Replace Table From Output /
          Rules = All
          Frame = Box
          Cellpadding = 2pt
          Cellspacing = 0.75pt
          Borderwidth = 0.75pt
          Bordercolor=Color_list('fg')
          ;
  Replace Body from Document /
          Topmargin=3.0cm
          Bottommargin=4.3cm
          Leftmargin=2.8cm
          Rightmargin=1.5cm
          ;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",10.1pt)
          'TitleFont' = ("Times New Roman",10.1pt)
          'StrongFont' = ("Times New Roman",10.1pt)
          'EmphasisFont' = ("Times New Roman",10.1pt)
          'FixedEmphasisFont' = ("Courier New",10.1pt)
          'FixedStrongFont' = ("Courier New",10.1pt)
          'FixedHeadingFont' = ("Courier New",10.1pt)
          'BatchFixedFont' = ("Courier New",10.1pt)
          'FixedFont' = ("Courier New",10.1pt)
          'headingEmphasisFont' = ("Times New Roman",10.1pt)
          'headingFont' = ("Times New Roman",10.1pt)
          'docFont' = ("Times New Roman",10.1pt)
          ;
  Replace Color_list /
          'link' = blue
          'bgH'  = cxA0A0A0
          'fg'   = black
          'bg'   = _undef_
          ;
  Replace Colors /
          'headerfgemph' = color_list('fg')
          'headerbgemph' = color_list('bg')
          'headerfgstrong' = color_list('fg')
          'headerbgstrong' = color_list('bg')
          'headerfg' = color_list('fg')
          'headerbg' = color_list('bg')
          'datafgemph' = color_list('fg')
          'databgemph' = color_list('bg')
          'datafgstrong' = color_list('fg')
          'databgstrong' = color_list('bg')
          'datafg' = color_list('fg')
          'databg' = color_list('bg')
          'batchbg' = color_list('bg')
          'batchfg' = color_list('fg')
          'tableborder' = color_list('fg')
          'tablebg' = color_list('bg')
          'notefg' = color_list('fg')
          'notebg' = color_list('bg')
          'bylinefg' = color_list('fg')
          'bylinebg' = color_list('bg')
          'captionfg' = color_list('fg')
          'captionbg' = color_list('bg')
          'proctitlefg' = color_list('fg')
          'proctitlebg' = color_list('bg')
          'titlefg' = color_list('fg')
          'titlebg' = color_list('bg')
          'systitlefg' = color_list('fg')
          'systitlebg' = color_list('bg')
          'Conentryfg' = color_list('fg')
          'Confolderfg' = color_list('fg')
          'Contitlefg' = color_list('fg')
          'link2' = color_list('link')
          'link1' = color_list('link')
          'contentfg' = color_list('fg')
          'contentbg' = color_list('bg')
          'docfg' = color_list('fg')
          'docbg' = color_list('bg')
          ;
  End;
Run;


/* #2 */
Proc Template;
  Define Style Styles.RTF_A4_9_PORT;
  Parent = Styles.RTF_A4_10_PORT;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",9.1pt)
          'TitleFont' = ("Times New Roman",9.1pt)
          'StrongFont' = ("Times New Roman",9.1pt)
          'EmphasisFont' = ("Times New Roman",9.1pt)
          'FixedEmphasisFont' = ("Courier New",9.1pt)
          'FixedStrongFont' = ("Courier New",9.1pt)
          'FixedHeadingFont' = ("Courier New",9.1pt)
          'BatchFixedFont' = ("Courier New",9.1pt)
          'FixedFont' = ("Courier New",9.1pt)
          'headingEmphasisFont' = ("Times New Roman",9.1pt)
          'headingFont' = ("Times New Roman",9.1pt)
          'docFont' = ("Times New Roman",9.1pt)
          ;
  End;
Run;


/* #3 */
Proc Template;
  Define Style Styles.RTF_A4_8_PORT;
  Parent = Styles.RTF_A4_10_PORT;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",8.1pt)
          'TitleFont' = ("Times New Roman",8.1pt)
          'StrongFont' = ("Times New Roman",8.1pt)
          'EmphasisFont' = ("Times New Roman",8.1pt)
          'FixedEmphasisFont' = ("Courier New",8.1pt)
          'FixedStrongFont' = ("Courier New",8.1pt)
          'FixedHeadingFont' = ("Courier New",8.1pt)
          'BatchFixedFont' = ("Courier New",8.1pt)
          'FixedFont' = ("Courier New",8.1pt)
          'headingEmphasisFont' = ("Times New Roman",8.1pt)
          'headingFont' = ("Times New Roman",8.1pt)
          'docFont' = ("Times New Roman",8.1pt)
          ;
  End;
Run;


/*****************************************A4   LAND*****************************************************/


/* #4 */
Proc Template;
  Define Style Styles.RTF_A4_10_LAND;
  Parent = Styles.RTF_A4_10_PORT;
  Replace Body from Document /
          Topmargin=4.3cm
          Bottommargin=2.5cm
          Leftmargin=2.8cm
          Rightmargin=1.0cm
          ;
  End;
Run;


/* #5 */
Proc Template;
  Define Style Styles.RTF_A4_9_LAND;
  Parent = Styles.RTF_A4_10_LAND;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",9.1pt)
          'TitleFont' = ("Times New Roman",9.1pt)
          'StrongFont' = ("Times New Roman",9.1pt)
          'EmphasisFont' = ("Times New Roman",9.1pt)
          'FixedEmphasisFont' = ("Courier New",9.1pt)
          'FixedStrongFont' = ("Courier New",9.1pt)
          'FixedHeadingFont' = ("Courier New",9.1pt)
          'BatchFixedFont' = ("Courier New",9.1pt)
          'FixedFont' = ("Courier New",9.1pt)
          'headingEmphasisFont' = ("Times New Roman",9.1pt)
          'headingFont' = ("Times New Roman",9.1pt)
          'docFont' = ("Times New Roman",9.1pt)
          ;
  End;
Run;

/* #6 */
Proc Template;
  Define Style Styles.RTF_A4_8_LAND;
  Parent = Styles.RTF_A4_10_LAND;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",8.1pt)
          'TitleFont' = ("Times New Roman",8.1pt)
          'StrongFont' = ("Times New Roman",8.1pt)
          'EmphasisFont' = ("Times New Roman",8.1pt)
          'FixedEmphasisFont' = ("Courier New",8.1pt)
          'FixedStrongFont' = ("Courier New",8.1pt)
          'FixedHeadingFont' = ("Courier New",8.1pt)
          'BatchFixedFont' = ("Courier New",8.1pt)
          'FixedFont' = ("Courier New",8.1pt)
          'headingEmphasisFont' = ("Times New Roman",8.1pt)
          'headingFont' = ("Times New Roman",8.1pt)
          'docFont' = ("Times New Roman",8.1pt)
          ;
  End;
Run;


/*****************************************LETTER   PORT*****************************************************/

/* #7 */
Proc Template;
  Define Style Styles.RTF_LETTER_10_PORT;
  Parent = Styles.RTF_A4_10_PORT;
  Replace Body from Document /
          Topmargin=3.0cm
          Bottommargin=2.5cm
          Leftmargin=2.8cm
          Rightmargin=2.1cm
          ;
  End;
Run;

/* #8 */
Proc Template;
  Define Style Styles.RTF_LETTER_9_PORT;
  Parent = Styles.RTF_LETTER_10_PORT;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",9.1pt)
          'TitleFont' = ("Times New Roman",9.1pt)
          'StrongFont' = ("Times New Roman",9.1pt)
          'EmphasisFont' = ("Times New Roman",9.1pt)
          'FixedEmphasisFont' = ("Courier New",9.1pt)
          'FixedStrongFont' = ("Courier New",9.1pt)
          'FixedHeadingFont' = ("Courier New",9.1pt)
          'BatchFixedFont' = ("Courier New",9.1pt)
          'FixedFont' = ("Courier New",9.1pt)
          'headingEmphasisFont' = ("Times New Roman",9.1pt)
          'headingFont' = ("Times New Roman",9.1pt)
          'docFont' = ("Times New Roman",9.1pt)
          ;
  End;
Run;

/* #9 */
Proc Template;
  Define Style Styles.RTF_LETTER_8_PORT;
  Parent = Styles.RTF_LETTER_10_PORT;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",8.1pt)
          'TitleFont' = ("Times New Roman",8.1pt)
          'StrongFont' = ("Times New Roman",8.1pt)
          'EmphasisFont' = ("Times New Roman",8.1pt)
          'FixedEmphasisFont' = ("Courier New",8.1pt)
          'FixedStrongFont' = ("Courier New",8.1pt)
          'FixedHeadingFont' = ("Courier New",8.1pt)
          'BatchFixedFont' = ("Courier New",8.1pt)
          'FixedFont' = ("Courier New",8.1pt)
          'headingEmphasisFont' = ("Times New Roman",8.1pt)
          'headingFont' = ("Times New Roman",8.1pt)
          'docFont' = ("Times New Roman",8.1pt)
          ;
  End;
Run;

/*****************************************LETTER   LAND*****************************************************/

/* #10 */
Proc Template;
  Define Style Styles.RTF_LETTER_10_LAND;
  Parent = Styles.RTF_A4_10_PORT;
  Replace Body from Document /
          Topmargin=4.3cm
          Bottommargin=3.1cm
          Leftmargin=1.0cm
          Rightmargin=1.0cm
          ;
  End;
Run;

/* #11 */
Proc Template;
  Define Style Styles.RTF_LETTER_9_LAND;
  Parent = Styles.RTF_LETTER_10_LAND;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",9.1pt)
          'TitleFont' = ("Times New Roman",9.1pt)
          'StrongFont' = ("Times New Roman",9.1pt)
          'EmphasisFont' = ("Times New Roman",9.1pt)
          'FixedEmphasisFont' = ("Courier New",9.1pt)
          'FixedStrongFont' = ("Courier New",9.1pt)
          'FixedHeadingFont' = ("Courier New",9.1pt)
          'BatchFixedFont' = ("Courier New",9.1pt)
          'FixedFont' = ("Courier New",9.1pt)
          'headingEmphasisFont' = ("Times New Roman",9.1pt)
          'headingFont' = ("Times New Roman",9.1pt)
          'docFont' = ("Times New Roman",9.1pt)
          ;
  End;
Run;


/* #12 */
Proc Template;
  Define Style Styles.RTF_LETTER_8_LAND;
  Parent = Styles.RTF_Letter_10_LAND;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",8.1pt)
          'TitleFont' = ("Times New Roman",8.1pt)
          'StrongFont' = ("Times New Roman",8.1pt)
          'EmphasisFont' = ("Times New Roman",8.1pt)
          'FixedEmphasisFont' = ("Courier New",8.1pt)
          'FixedStrongFont' = ("Courier New",8.1pt)
          'FixedHeadingFont' = ("Courier New",8.1pt)
          'BatchFixedFont' = ("Courier New",8.1pt)
          'FixedFont' = ("Courier New",8.1pt)
          'headingEmphasisFont' = ("Times New Roman",8.1pt)
          'headingFont' = ("Times New Roman",8.1pt)
          'docFont' = ("Times New Roman",8.1pt)
          ;
  End;
Run;


/************************************************************************************/
/*                   PPPPPPP   DDDDDD   FFFFFFF                   */
/*                   P     P   D    D   F                       */
/*                   PPPPPPP   D    D   FFFF                    */
/*                   P         D    D   F                     */
/*                   P         DDDDDD   F                     */
/************************************************************************************/

/*****************************************A4  PORT***********************************/


/* #13: Styles.A4_10_PORT_v2 : Base */
Proc Template;
  Define Style Styles.PDF_A4_10_PORT;
  parent=Styles.printer;
  Replace Table From Output /
      background=_undef_
        frame=hsides
      Rules=groups
          Cellpadding = 2pt
          Cellspacing = 0.75pt
          Borderwidth = 0.75pt
          Bordercolor=Color_list('fg')
          ;
  Replace Body from Document /
          Topmargin=3.0cm
          Bottommargin=4.3cm
          Leftmargin=2.8cm
          Rightmargin=1.5cm
          ;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",10.1pt)
          'TitleFont' = ("Times New Roman",10.1pt)
          'StrongFont' = ("Times New Roman",10.1pt)
          'EmphasisFont' = ("Times New Roman",10.1pt)
          'FixedEmphasisFont' = ("Courier New",10.1pt)
          'FixedStrongFont' = ("Courier New",10.1pt)
          'FixedHeadingFont' = ("Courier New",10.1pt)
          'BatchFixedFont' = ("Courier New",10.1pt)
          'FixedFont' = ("Courier New",10.1pt)
          'headingEmphasisFont' = ("Times New Roman",10.1pt)
          'headingFont' = ("Times New Roman",10.1pt)
          'docFont' = ("Times New Roman",10.1pt)
              ;
  Replace Color_list /
          'link' = blue
          'bgH'  = cxA0A0A0
          'fg'   = black
          'bg'   = _undef_
          ;
  Replace Colors /
          'headerfgemph' = color_list('fg')
          'headerbgemph' = color_list('bg')
          'headerfgstrong' = color_list('fg')
          'headerbgstrong' = color_list('bg')
          'headerfg' = color_list('fg')
          'headerbg' = color_list('bg')
          'datafgemph' = color_list('fg')
          'databgemph' = color_list('bg')
          'datafgstrong' = color_list('fg')
          'databgstrong' = color_list('bg')
          'datafg' = color_list('fg')
          'databg' = color_list('bg')
          'batchbg' = color_list('bg')
          'batchfg' = color_list('fg')
          'tableborder' = color_list('fg')
          'tablebg' = color_list('bg')
          'notefg' = color_list('fg')
          'notebg' = color_list('bg')
          'bylinefg' = color_list('fg')
          'bylinebg' = color_list('bg')
          'captionfg' = color_list('fg')
          'captionbg' = color_list('bg')
          'proctitlefg' = color_list('fg')
          'proctitlebg' = color_list('bg')
          'titlefg' = color_list('fg')
          'titlebg' = color_list('bg')
          'systitlefg' = color_list('fg')
          'systitlebg' = color_list('bg')
          'Conentryfg' = color_list('fg')
          'Confolderfg' = color_list('fg')
          'Contitlefg' = color_list('fg')
          'link2' = color_list('link')
          'link1' = color_list('link')
          'contentfg' = color_list('fg')
          'contentbg' = color_list('bg')
          'docfg' = color_list('fg')
          'docbg' = color_list('bg')
          ;

  End;
Run;


/* #14 */
Proc Template;
  Define Style Styles.PDF_A4_9_PORT;
  Parent = Styles.PDF_A4_10_PORT;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",9.1pt)
          'TitleFont' = ("Times New Roman",9.1pt)
          'StrongFont' = ("Times New Roman",9.1pt)
          'EmphasisFont' = ("Times New Roman",9.1pt)
          'FixedEmphasisFont' = ("Courier New",9.1pt)
          'FixedStrongFont' = ("Courier New",9.1pt)
          'FixedHeadingFont' = ("Courier New",9.1pt)
          'BatchFixedFont' = ("Courier New",9.1pt)
          'FixedFont' = ("Courier New",9.1pt)
          'headingEmphasisFont' = ("Times New Roman",9.1pt)
          'headingFont' = ("Times New Roman",9.1pt)
          'docFont' = ("Times New Roman",9.1pt)

          ;
  End;
Run;


/* #15 */
Proc Template;
  Define Style Styles.PDF_A4_8_PORT;
  Parent = Styles.PDF_A4_10_PORT;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",8.1pt)
          'TitleFont' = ("Times New Roman",8.1pt)
          'StrongFont' = ("Times New Roman",8.1pt)
          'EmphasisFont' = ("Times New Roman",8.1pt)
          'FixedEmphasisFont' = ("Courier New",8.1pt)
          'FixedStrongFont' = ("Courier New",8.1pt)
          'FixedHeadingFont' = ("Courier New",8.1pt)
          'BatchFixedFont' = ("Courier New",8.1pt)
          'FixedFont' = ("Courier New",8.1pt)
          'headingEmphasisFont' = ("Times New Roman",8.1pt)
          'headingFont' = ("Times New Roman",8.1pt)
          'docFont' = ("Times New Roman",8.1pt)
          ;
  End;
Run;


/*****************************************A4   LAND*****************************************************/


/* #16 */
Proc Template;
  Define Style Styles.PDF_A4_10_LAND;
  Parent = Styles.PDF_A4_10_PORT;
  Replace Body from Document /
          Topmargin=4.3cm
          Bottommargin=2.5cm
          Leftmargin=2.8cm
          Rightmargin=1.0cm
          ;
  End;
Run;


/* #17 */
Proc Template;
  Define Style Styles.PDF_A4_9_LAND;
  Parent = Styles.PDF_A4_10_LAND;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",9.1pt)
          'TitleFont' = ("Times New Roman",9.1pt)
          'StrongFont' = ("Times New Roman",9.1pt)
          'EmphasisFont' = ("Times New Roman",9.1pt)
          'FixedEmphasisFont' = ("Courier New",9.1pt)
          'FixedStrongFont' = ("Courier New",9.1pt)
          'FixedHeadingFont' = ("Courier New",9.1pt)
          'BatchFixedFont' = ("Courier New",9.1pt)
          'FixedFont' = ("Courier New",9.1pt)
          'headingEmphasisFont' = ("Times New Roman",9.1pt)
          'headingFont' = ("Times New Roman",9.1pt)
          'docFont' = ("Times New Roman",9.1pt)
          ;
  End;
Run;

/* #18 */
Proc Template;
  Define Style Styles.PDF_A4_8_LAND;
  Parent = Styles.PDF_A4_10_LAND;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",8.1pt)
          'TitleFont' = ("Times New Roman",8.1pt)
          'StrongFont' = ("Times New Roman",8.1pt)
          'EmphasisFont' = ("Times New Roman",8.1pt)
          'FixedEmphasisFont' = ("Courier New",8.1pt)
          'FixedStrongFont' = ("Courier New",8.1pt)
          'FixedHeadingFont' = ("Courier New",8.1pt)
          'BatchFixedFont' = ("Courier New",8.1pt)
          'FixedFont' = ("Courier New",8.1pt)
          'headingEmphasisFont' = ("Times New Roman",8.1pt)
          'headingFont' = ("Times New Roman",8.1pt)
          'docFont' = ("Times New Roman",8.1pt)
          ;
  End;
Run;


/*****************************************LETTER   PORT*****************************************************/

/* #19 */
Proc Template;
  Define Style Styles.PDF_LETTER_10_PORT;
  Parent = Styles.PDF_A4_10_PORT;
  Replace Body from Document /
          Topmargin=3.0cm
          Bottommargin=2.5cm
          Leftmargin=2.8cm
          Rightmargin=2.1cm
          ;
  End;
Run;

/* #20 */
Proc Template;
  Define Style Styles.PDF_LETTER_9_PORT;
  Parent = Styles.PDF_LETTER_10_PORT;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",9.1pt)
          'TitleFont' = ("Times New Roman",9.1pt)
          'StrongFont' = ("Times New Roman",9.1pt)
          'EmphasisFont' = ("Times New Roman",9.1pt)
          'FixedEmphasisFont' = ("Courier New",9.1pt)
          'FixedStrongFont' = ("Courier New",9.1pt)
          'FixedHeadingFont' = ("Courier New",9.1pt)
          'BatchFixedFont' = ("Courier New",9.1pt)
          'FixedFont' = ("Courier New",9.1pt)
          'headingEmphasisFont' = ("Times New Roman",9.1pt)
          'headingFont' = ("Times New Roman",9.1pt)
          'docFont' = ("Times New Roman",9.1pt)
          ;
  End;
Run;

/* #21 */
Proc Template;
  Define Style Styles.PDF_LETTER_8_PORT;
  Parent = Styles.PDF_LETTER_10_PORT;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",8.1pt)
          'TitleFont' = ("Times New Roman",8.1pt)
          'StrongFont' = ("Times New Roman",8.1pt)
          'EmphasisFont' = ("Times New Roman",8.1pt)
          'FixedEmphasisFont' = ("Courier New",8.1pt)
          'FixedStrongFont' = ("Courier New",8.1pt)
          'FixedHeadingFont' = ("Courier New",8.1pt)
          'BatchFixedFont' = ("Courier New",8.1pt)
          'FixedFont' = ("Courier New",8.1pt)
          'headingEmphasisFont' = ("Times New Roman",8.1pt)
          'headingFont' = ("Times New Roman",8.1pt)
          'docFont' = ("Times New Roman",8.1pt)
          ;
  End;
Run;

/*****************************************LETTER   LAND*****************************************************/

/* #22 */
Proc Template;
  Define Style Styles.PDF_LETTER_10_LAND;
  Parent = Styles.PDF_A4_10_PORT;
  Replace Body from Document /
          Topmargin=4.3cm
          Bottommargin=3.1cm
          Leftmargin=1.0cm
          Rightmargin=1.0cm
          ;
  End;
Run;

/* #23 */
Proc Template;
  Define Style Styles.PDF_LETTER_9_LAND;
  Parent = Styles.PDF_LETTER_10_LAND;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",9.1pt)
          'TitleFont' = ("Times New Roman",9.1pt)
          'StrongFont' = ("Times New Roman",9.1pt)
          'EmphasisFont' = ("Times New Roman",9.1pt)
          'FixedEmphasisFont' = ("Courier New",9.1pt)
          'FixedStrongFont' = ("Courier New",9.1pt)
          'FixedHeadingFont' = ("Courier New",9.1pt)
          'BatchFixedFont' = ("Courier New",9.1pt)
          'FixedFont' = ("Courier New",9.1pt)
          'headingEmphasisFont' = ("Times New Roman",9.1pt)
          'headingFont' = ("Times New Roman",9.1pt)
          'docFont' = ("Times New Roman",9.1pt)
          ;
  End;
Run;


/* #24 */
Proc Template;
  Define Style Styles.PDF_LETTER_8_LAND;
  Parent = Styles.PDF_Letter_10_LAND;
  Replace Fonts /
          'TitleFont2' = ("Times New Roman",8.1pt)
          'TitleFont' = ("Times New Roman",8.1pt)
          'StrongFont' = ("Times New Roman",8.1pt)
          'EmphasisFont' = ("Times New Roman",8.1pt)
          'FixedEmphasisFont' = ("Courier New",8.1pt)
          'FixedStrongFont' = ("Courier New",8.1pt)
          'FixedHeadingFont' = ("Courier New",8.1pt)
          'BatchFixedFont' = ("Courier New",8.1pt)
          'FixedFont' = ("Courier New",8.1pt)
          'headingEmphasisFont' = ("Times New Roman",8.1pt)
          'headingFont' = ("Times New Roman",8.1pt)
          'docFont' = ("Times New Roman",8.1pt)
          ;
  End;
Run;




