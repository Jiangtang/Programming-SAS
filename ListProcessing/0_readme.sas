/*===================================================================================
 |              SAS List Processing Utility Macros
 |
 |    Author:  see individual snippets
 | Collector:  Jiangtang Hu (Jiangtanghu.com)
 |  Archived:  https://github.com/Jiangtang/Programming-SAS/tree/master/ListProcessing
 |
 +-------List Creating---------------------------------------------------------------
 |
 | %range:          produces a sequence like 1 2 3 or f1 f2 f3 or 1a 2a 3a
 | %range_non_int:  increment a macro do loop by a non-integer value
 | %suffix_counter: Create a list of variable names formed by adding a numeric counter suffix to a base name.
 |
 | %getVar: get all variables (N, C or all) from a dataset
 |
 | %qreadpipe: read the output of a system command
 | %dir:       return a list of members of a directory
 | %dirfpq:    return a list of full-path quoted members of a directory
 |
 |
 +-------List Formating---------------------------------------------------------------
 |
 | %changesep: change the separator for a list
 | %seplist:   Emit a list of items separated by some delimiter
 |
 | %splitmac: insert split characters in a macro string
 |
 | %capmac:  capitalise the first letter of each  word in a macro string
 |
 +-------quoting---------------------------------------------------------------
 |
 | %qt:        add quotes to each element in a list
 | %quotelst:  quote the elements of a list
 |
 | %upt:       remove quotes from each element of a list
 | %qdequote:  remove front and end matching quotes from a macro string
 | %dequote:   remove front and end matching quotes from a macro string
 |
 | %noquotes:  remove all quoted strings from a macro expression
 |
 | %quotecnt:  count quoted strings in a macro expression
 |
 | %quotescan: scan for a quoted string in a macro   expression
 |
 |
 +-------List Properties-----------------------------------------------------------
 |
 | %num_tokens: Count the number of “tokens” (variables) in a list.
 | %countW:     Retrieve the number of words in a macro variable
 | %words:      return the number of words in a string
 | %windex:     return the word count position in a string
 |
 |
 |
 |
 +-------List Manipulation-----------------------------------------------------------
 |
 | %slice:  return a sub-list sliced by a index
 |
 |
 | %zip:           zips two lists together by joining correponding elements, see, a b and c d ==> ac bd
 | %parallel_join: Join two variable lists by connecting each variable in the first list to its correspondingvariable in the second list
 | %add_string:    Add a text string to each variable in a list as either a prefix or suffix
 | %xprod:         take cross product of two lists, see, a b and c d ==> ac ad bc bd
 |
 | %appmvar: append a string onto an existing macro variable
 | %prefix:  return a list with a prefix added
 | %suffix:  return a list with a suffix added
 |
 |
 |
 |
 | %replace:       replace symbolic variable in block of code with each element of a list, see, a b and code = #=__#  ==> a=__a b=__b
 | %rename_string: Create a list suitable for the rename statement
 | %editlist:      edit a list of space delimited items
 |
 | %nodup:  drop duplicates in a space-delimited list
 |
 | %match:  return elements of a list that match those in a reference list
 |
 | %remove:  remove all occurrences of the target string(s) from another string
 | %removew: remove all occurrences of the target word(s) from a source list of words.
 |
 | %reverse:  Reverse a macro variable's value (use %sysfunc(reverse) since v6.12)
 |
 |
 |
 +==================================================================================*/
