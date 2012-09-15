libname mylib 'C:\Users\jhu\Documents\GitHub\Programming-SAS';
options mstored sasmstore=mylib;


/*
1. full text search:   %grep(sashelp,John);
*/

filename fts url "https://raw.github.com/Jiangtang/Programming-SAS/master/FullTextSearch.sas";
%include fts / nosource;
filename fts clear;

