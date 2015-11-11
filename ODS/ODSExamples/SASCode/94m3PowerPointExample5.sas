title;
title2 'Tiled Image Background';
title3 'Specified By a Fileref';
filename backgrnd "tilepattern.gif";
ods powerpoint options(backgroundimage="backgrnd" backgroundrepeat="repeat");
proc print data=sashelp.class(obs=5);
run;
ods powerpoint close;
