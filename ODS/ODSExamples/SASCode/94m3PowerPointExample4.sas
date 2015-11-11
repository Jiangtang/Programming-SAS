title;
title2 'Image Background'; 
title3 'Specified By Path';
ods powerpoint options(backgroundimage='c:\Public\green.jpg');
proc print data=sashelp.class(obs=5);
run;
ods powerpoint close;
