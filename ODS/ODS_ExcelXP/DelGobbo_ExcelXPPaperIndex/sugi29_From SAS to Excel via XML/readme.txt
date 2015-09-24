Contents:
========

This ZIP archive contains the following files:

phcae.sas7bdat - sample SAS table with adverse event information.

DataToImport.xls - sample multi-sheet Excel workbook.

DataToImport.xml - XML version of DataToImport.xls.  This file will be read into SAS.

vehicles.xml - sample XML file representing Ford model information.

excelxp.sas - recent version of the ExcelXP ODS tagset.

msoffice2k.sas - recent version of the MSOffice2K ODS tagset.

excelxp.map - SAS XMLMap used to read Excel XML files into SAS tables.

vehicles.map - SAS XMLMap used to read the file vehicles.xml into a SAS table.

loadxl.sas - contains the XLXP2SAS SAS macro, which reads Excel XML workbooks into SAS tables.

sample.sas - sample code used in the paper "From SAS to Excel via XML".


Installation:
============

Unpack the archive into one or more directories, making note of the directory name(s).


Usage:
=====

Edit the file sample.sas and provide directory information where indicated in the comments.  If you unpacked the archive into a single directory, use this directory information throughout the code.

For example, if you unpacked all files in the archive to the directory c:\temp, then the substituted SAS code would appear as follows:

    libname myLib 'c:\temp';

    libname pharma 'c:\temp' access=read;

    %let OUTDIR=c:\temp;

    %include 'c:\temp\excelxp.sas';

    %include 'c:\temp\msoffice2k.sas';

    %include 'c:\temp\loadxl.sas';

    %xlxp2sas(excelfile=c:\temp\DataToImport.xml, 
              mapfile=c:\temp\excelxp.map);

Start SAS and submit sample.sas for execution.