/*<pre><b>
/ Program      : crprotds.sas
/ Version      : 1.2
/ Author       : Roland Rashleigh-Berry
/ Date         : 30-Jul-2007
/ Purpose      : Spectre (Clinical) macro to create a protocol dataset from a
/                protocol details flat file.
/ SubMacros    : none
/ Notes        : The protocol flat file must have a specific form for this macro
/                to work correctly. Actions are driven by special labels starting
/                in the first column as shown below. Lines that do not follow
/                this pattern will be ignored and treated as comment lines.
/
/ drugname: ---  Name of drug
/ protocol: ---  Name of protocol
/ report: -----  Name of report
/ titlestyle: -- Title style (max 8 chars to identify client which will also
/                be the start name of the client titles macro).
/ paper: -----   Whether A4 or Letter
/ margin: ----   Decimal number for the all-round margin in inches.
/ lmargin: ----  Decimal number for the left margin in inches (portrait).
/ rmargin: ----  Decimal number for the right margin in inches (portrait).
/ rmargin: ----  Decimal number for the top margin in inches (portrait).
/ bmargin: ----  Decimal number for the bottom margin in inches (portrait).
/ dflayout: ---  Code to say whether the default page layout is landscape or
/                portrait and whether the lines are tight, followed by the
/                point size. The following examples are all valid: l9 lt9 p10
/                pt11 lt8.5 p10.5
/ dfllayout: --  Default landscape layout.
/ dfplayout: --- Default portrait layout.
/ dfltlayout: --  Default landscape tight layout.
/ dfptlayout: --- Default portrait tight layout.
/ clean: clean in (0,1)     Criteria for selecting clean/unclean patients from
/                           the stat.acct dataset.
/ pagexofy: "Page x of y"   Default style of the "Page x of Y" label (quoted)
/ pagemac: pagexofy         Macro to call to add "page x of y" labels
/ pop1: ---      First defined population.
/ poplabel1: ------  First defined population label.
/ (repeat for populations up to 9)
/ 
/ Usage        : %crprotds(flatfile,der.study)
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ flatfile          (pos) File name of flat file containing study details.
/ dsout             (pos) Output dataset containing protocol details.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  07Mar07         "pagexofy" variable setup included
/ rrb  25Jun07         "pagemac" variable setup added
/ rrb  30Jul07         Header tidy
/===============================================================================
/ No guarantee as to the suitability or accuracy of this code is given or
/ implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: crprotds v1.2;

%macro crprotds(flatfile,dsout);

  data &dsout;
    length pop1 pop2 pop3 pop4 pop5 pop6 pop7 pop8 pop9 $ 8
           paper margin dflayout dfllayout dfplayout dfltlayout
           dfptlayout titlestyle $ 8 
           pagexofy pagemac $ 32
           poplabel1 poplabel2 poplabel3 poplabel4 
           poplabel5 poplabel6 poplabel7 poplabel8 poplabel9 $ 80
          drugname protocol report text clean $ 200;
    infile "%sysfunc(compress(&flatfile,%str(%'%")))" pad eof=eof;
    loop:
    input @1 text $char200.;
    if upcase(text) EQ: "DRUGNAME:" then drugname=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "PROTOCOL:" then protocol=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "REPORT:" then report=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "TITLESTYLE:" then titlestyle=lowcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "PAPER:" then paper=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "MARGIN:" then margin=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "LMARGIN:" then lmargin=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "RMARGIN:" then rmargin=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "TMARGIN:" then tmargin=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "BMARGIN:" then bmargin=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "DFLAYOUT:" then dflayout=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "DFLLAYOUT:" then dfllayout=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "DFPLAYOUT:" then dfplayout=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "DFLTLAYOUT:" then dfltlayout=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "DFPTLAYOUT:" then dfptlayout=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "CLEAN:" then clean=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "PAGEXOFY:" then pagexofy=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "PAGEMAC:" then pagemac=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "POP1:" then pop1=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "POPLABEL1:" then poplabel1=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "POP2:" then pop2=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "POPLABEL2:" then poplabel2=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "POP3:" then pop3=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "POPLABEL3:" then poplabel3=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "POP4:" then pop4=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "POPLABEL4:" then poplabel4=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "POP5:" then pop5=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "POPLABEL5:" then poplabel5=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "POP6:" then pop6=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "POPLABEL6:" then poplabel6=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "POP7:" then pop7=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "POPLABEL7:" then poplabel7=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "POP8:" then pop8=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "POPLABEL8:" then poplabel8=left(substr(text,index(text,":")+1));
    else if upcase(text) EQ: "POP9:" then pop9=upcase(left(substr(text,index(text,":")+1)));
    else if upcase(text) EQ: "POPLABEL9:" then poplabel9=left(substr(text,index(text,":")+1));
    goto loop;
    eof:
    if lmargin=. then lmargin=margin;
    if rmargin=. then rmargin=margin;
    if tmargin=. then tmargin=margin;
    if bmargin=. then bmargin=margin;
    if pagexofy=" " then pagexofy="Page x of Y";
    if pagemac=" " then pagemac="pagexofy";
    output;
    label drugname='Drug name'
          protocol='Protocol'
          report='Report'
          titlestyle='Titles style'
          paper='Paper form (A4, Letter, A4Letter)'
          lmargin='Left margin (inches) (portrait orientation)'
          rmargin='Right margin (inches) (portrait orientation)'
          tmargin='Top margin (inches) (portrait orientation)'
          bmargin='Bottom margin (inches) (portrait orientation)'
          dflayout='Default layout'
          dfllayout='Default landscape layout'
          dfplayout='Default portrait layout'
          dfltlayout='Default landscape tight layout'
          dfptlayout='Default portrait tight layout'
          clean='Criteria for selecting clean/unclean subjects from acct'
          pagexofy='Style of the "Page x of Y" label'
          pagemac='Macro to call to add "Page x of Y" labels'
          pop1='Population 1'
          poplabel1='Population 1 label'
          pop2='Population 2'
          poplabel2='Population 2 label'
          pop3='Population 3'
          poplabel3='Population 3 label'
          pop4='Population 4'
          poplabel4='Population 4 label'
          pop5='Population 5'
          poplabel5='Population 5 label'
          pop6='Population 6'
          poplabel6='Population 6 label'
          pop7='Population 7'
          poplabel7='Population 7 label'
          pop8='Population 8'
          poplabel8='Population 8 label'
          pop9='Population 9'
          poplabel9='Population 9 label'
          ;
    drop text margin;
 run;

%mend crprotds;
