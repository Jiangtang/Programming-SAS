ods tagsets.msoffice2k_x file="test.xls" 
		options (panelcols="2" zoom="70"  autofilter="yes");

proc print data=sashelp.class noobs;
    var height / style={HTMLSTYLE="mso-number-format:'@'"} style(column)={cellwidth=.5 in};
run;

proc print data=sashelp.class noobs;
    var height / style(column)={cellwidth=.5 in} style={HTMLSTYLE="mso-number-format:'@'"} ;
run;
 
ods tagsets.msoffice2k_x close;



/*style = {cellwidth=150 mm tagattr = 'format:text'} */

ods tagsets.excelxp file="test1.xls";
 
ods tagsets.excelxp options( sheet_name='test 1');
proc print data=sashelp.class noobs;
    var height / style={tagattr='format:text'} style(column)={cellwidth=.5 in};
run;

ods tagsets.excelxp options( sheet_name='test 2');
proc print data=sashelp.class noobs;
    var height / style(column)={cellwidth=.5 in} style={tagattr='format:text'} ;
run;
 
ods tagsets.excelxp close;
