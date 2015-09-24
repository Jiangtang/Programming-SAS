*  Library to store styles and tagsets.  Fill in the path.;

libname myLib 'C:\Users\jhu.D-WISE\Box Sync\SAS\SAS_code\ODS\ODS_ExcelXP\DelGobbo_ExcelXPPaperIndex\sugi29_From SAS to Excel via XML';

*  Library containing the sample data (phcae.sas7bdat).  Fill in the path.;

libname pharma 'C:\Users\jhu.D-WISE\Box Sync\SAS\SAS_code\ODS\ODS_ExcelXP\DelGobbo_ExcelXPPaperIndex\sugi29_From SAS to Excel via XML' access=read;

*  Output directory for XML output.  Fill in the path.;

%let OUTDIR=C:\Users\jhu.D-WISE\Box Sync\SAS\SAS_code\ODS\ODS_ExcelXP\DelGobbo_ExcelXPPaperIndex\sugi29_From SAS to Excel via XML;

*;
*  Set the ODS search path.  Tagsets and styles are written to the 
*  MYLIB library.
*;

ods path myLib.tmplmst(update) sashelp.tmplmst(read);

*;
*  Import recent versions of the ExcelXP and MSOffice2K tagsets
*  to the MYLIB library.  Specify the appropriate path to the
*  files excelxp.sas and msoffice2k.sas.
*;

%include 'C:\Users\jhu.D-WISE\Box Sync\SAS\SAS_code\ODS\ODS_ExcelXP\DelGobbo_ExcelXPPaperIndex\sugi29_From SAS to Excel via XML\excelxp.sas';

%include 'C:\Users\jhu.D-WISE\Box Sync\SAS\SAS_code\ODS\ODS_ExcelXP\DelGobbo_ExcelXPPaperIndex\sugi29_From SAS to Excel via XML\msoffice2k.sas';

*  Create the "baseline" XML output file;

ods listing close;
ods tagsets.ExcelXP file='phdata.xml' path="&OUTDIR" style=Statistical;
  proc print data=pharma.phcae noobs label;
    by protocol;
    var patient visit aedate aecode aetext aesev frequency aesevc;
  run; quit;

  proc tabulate data=pharma.phcae;
    by protocol;
    var aesev;
    class aetext aesevc;
    classlev aetext aesevc;
    table aetext*aesevc,aesev*pctn;
    keyword all pctn;
    keylabel pctn='Percent';
  run; quit;
ods tagsets.ExcelXP close;

*;
*  Create the style to correct missing cell border lines.
*
*  Apply cell borders to header and data cells:
*    1=None, 2=Thin, 3=Medium, 4=Thick
*;

proc template;
  define style XLStatistical;
    parent = styles.Statistical;
    replace Header from HeadersAndFooters /
      borderwidth=2;
    replace RowHeader from Header /
      borderwidth=2;
    replace Data from Cell /
      font = fonts('docFont')
      background = colors('databg')
      foreground = colors('datafg')
      borderwidth=2;
  end;
run; quit;

*  Create the corrected XML output file;

ods tagsets.ExcelXP file='phdata.xml' path="&OUTDIR" style=XLStatistical;
  proc print data=pharma.phcae noobs label;
    by protocol;
    var patient visit aedate;
    var aecode / style={tagattr="\00000000"};
    var aetext aesev frequency aesevc;
  run; quit;

  proc tabulate data=pharma.phcae;
    by protocol;
    var aesev;
    class aetext aesevc;
    classlev aetext aesevc;
    table aetext*aesevc,aesev*pctn;
    keyword all pctn;
    keylabel pctn='Percent';
  run; quit;
ods tagsets.ExcelXP close;

*  Import the SAS macro used to import XML to SAS tables;

%include 'C:\Users\jhu.D-WISE\Box Sync\SAS\SAS_code\ODS\ODS_ExcelXP\DelGobbo_ExcelXPPaperIndex\sugi29_From SAS to Excel via XML\loadxl.sas';

*;
*  Import the sample Excel XML workbook into SAS.  Specify the
*  appropriate path to the files DataToImport.xml and excelxp.map.
*  DO NOT USE QUOTES in the file names.
*;

%xlxp2sas(excelfile=d:\ct_vl_global_library.xls, 
          mapfile=C:\Users\jhu.D-WISE\Box Sync\SAS\SAS_code\ODS\ODS_ExcelXP\DelGobbo_ExcelXPPaperIndex\sugi29_From SAS to Excel via XML\excelxp.map);
