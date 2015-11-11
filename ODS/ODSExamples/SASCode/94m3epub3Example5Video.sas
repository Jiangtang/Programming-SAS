title;
ods epub3 file="VideoEscapechar.epub" title="Marmot Sighting eBook" newchapter=now;
ods escapechar='^';
ods proclabel = "Marmot Sighting (Video)";
proc odstext contents="";
p "^{video multimedia/marmot.m4v?controls=controls;poster=multimedia/marmot.jpg;float=left;
margintop=0;marginright=.5em;width=240px;height=135px}
No vacation is complete without home video. If you enjoy wildlife, check out the marmot  
^{noteref large mountain-dwelling ground squirrel}  we saw while driving the
^{style [url='http://en.wikipedia.org/wiki/Trail_Ridge_Road'] Trail Ridge Road}.";
run;
ods epub3 close;
