/*
1. full text search:   %grep(sashelp,John);
2. check log

*/


/*
1. full text search:   %grep(sashelp,John);
*/

filename fts url "https://raw.github.com/Jiangtang/Programming-SAS/master/FullTextSearch.sas";
%include fts / nosource;
filename fts clear;


/*
2. check log:   %checkLog;
*/


/* Download and Compile CheckLog */
filename checkLog url "http://goo.gl/H2zu9";
%include checkLog / nosource;
filename checkLog clear;