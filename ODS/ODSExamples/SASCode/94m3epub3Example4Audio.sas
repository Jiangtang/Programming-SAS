
ods epub3 file="AudioEscapechar.epub" newchapter=now options(nonlinear="chapter");
ods escapechar='^';
title2 "You can embed Audio into your eBook";
title3 "Use the Inline Formatting AUDIO Function";
proc odstext contents="";
p "^{audio SAS02_Orchestral30.mp3?controls=controls}"/style={just=c};
run;

ods epub3 options( nonlinear="none" );
ods epub3 event=branch ( start label=" Embedded Audio File (Audio) " url=" chapter2.html " ) ;
ods epub3 event=branch(finish);
title;
ods epub3 close;

