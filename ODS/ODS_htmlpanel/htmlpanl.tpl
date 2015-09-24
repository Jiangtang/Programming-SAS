proc template;
    define tagset tagsets.htmlpanel;
        parent = tagsets.html4;
        mvar panelborder;
        mvar panelcolumns;
        
        /*-------------------------------------------------------eric-*/
        /*-- If 'yes' titles and footnotes will occur inside each   --*/
        /*-- cell.  They will be repeated for each output object.   --*/
        /*----------------------------------------------------22Aug03-*/
        mvar embedded_titles;

        /*-------------------------------------------------------dan--*/
        /*-- If 'no', bylabels are stripped from the byline before  --*/
        /*-- they are output.                                       --*/
        /*----------------------------------------------------25Feb04-*/
        mvar bylabels;
        
    define event documentation;
        break /if ^$options;
        trigger quick_reference /if cmp($options['DOC'], 'quick');
        trigger help            /if cmp($options['DOC'], 'help');
        trigger settings        /if cmp($options['DOC'], 'settings');
    end;

    define event settings;
        putlog "PanelColumns: " $panel_columns;

        putlog "PanelBorder: " $panelborder;
        putlog "PanelBorder: 0" /if ^$panelborder;

        putlog "Embedded_Titles: " $embedded_titles;
        putlog "Embedded_Titles: No" /if ^$embedded_titles;

        putlog "ByLabels: " $bylabels;
    end;

    define event help;
        putlog "==============================================================================";
        putlog "The HTMLPanel Tagset Help Text.";
        putlog " ";
        putlog "This Tagset/Destination helps with the creation of layout tables";
        putlog "In HTML output.";
        putlog " ";
        putlog "By default it will automatically panel any graph procedure that is";
        putlog "doing 'By' processing.  It can also be used to do simple semi-automatic";
        putlog "panelling and more complex nested panels.";
        putlog " ";
        putlog "See Also:";
        putlog "http://support.sas.com/rnd/base/topics/odsmarkup/";
        putlog " ";
        trigger quick_reference;
    end;

    define event quick_reference;
        putlog "==============================================================================";
        putlog " ";
        putlog "These are the options supported by this tagset.";
        putlog " ";
        putlog "Sample usage:";
        putlog " ";
        putlog "ods tagsets.htmlpanel file='test.html' options(doc='Quick'); ";
        putlog " ";
        putlog "ods tagsets.htmlpanel options(panelColumns='3'";
        putlog "                              embedded_titles='No'";
        putlog "                              bylabels='No'); ";
        putlog " ";
        putlog "Doc:  No default value.  Two possible values: 'help' and 'quick'.";
        putlog "     Help: Displays introductory text and options";
        putlog "     Quick: Displays available options";
        putlog "     Settings: Displays Current settings";
        putlog " ";
        putlog "PanelColumns:   Default Value '2'";
        putlog "     Current Value: " $panel_columns;
        putlog "     How many columns of panels to create when doing automatic or ";
        putlog "     semi-automatic panelling.  The default is to put everything 2 up";
        putlog "     Also available as a macro variable";
        putlog " ";
        putlog "PanelBorder:   Default Value '0'";
        putlog "     Current Value: " $panelborder;
        putlog "     Current Value: 0" /if ^$panelborder;
        putlog "     This is border width, 0 means no borders.  Bigger numbers make it wider";
        putlog "     Also available as a macro variable";
        putlog " ";
        putlog "Embedded_Titles:   Default Value 'No'";
        putlog "     Current Value: " $embedded_titles;
        putlog "     Current Value: No" /if ^$embedded_titles;
        putlog "     If 'Yes' titles and footnotes will appear inside each panel as if each";
        putlog "     panel where a miniature page.  If 'No' the titles and footnotes appear";
        putlog "     once above and below the entire panel grouping.";
        putlog "     Also available as a macro variable";
        putlog " ";
        putlog "ByLabels:   Default Value 'Yes'";
        putlog "     Current Value: " $bylabels;
        putlog "     If 'No' remove the variable name and equals sign from the bylines";
        putlog "     Also available as a macro variable";
        putlog " ";
        putlog "------------------------------------------------------------------------";
        putlog "Event Controls";
        putlog " ";
        putlog "Semi-automatic and manual panelling is controlled by calling events from";
        putlog "the ODS statement.  They are started and stopped by specifying start and";
        putlog "finish as arguments to the event.  Row_panel and column_panels can be nested";
        putlog "to create complex layout configurations";
        putlog " ";
        putlog "Panel:   ";
        putlog "     This event starts and stops semi-automatic panelling.  All output";
        putlog "     between the start and finish will be panelled according to the";
        putlog "     settings of the option variables above.";
        putlog " ";
        putlog "     ODS tagsets.htmlpanel event=panel(start);";
        putlog "     /* Run Procs here */";
        putlog "     ODS tagsets.htmlpanel event=panel(finish);";
        putlog " ";
        putlog "row_panel:";   
        putlog "     This event starts a row-wise panel.  Each output object will be";
        putlog "     placed horizontally while this panel is active.";
        putlog " ";
        putlog "     ODS tagsets.htmlpanel event=row_panel(start);";
        putlog "     /* Run Procs here */";
        putlog "     ODS tagsets.htmlpanel event=row_panel(finish);";
        putlog " ";
        putlog "column_panel:";
        putlog "     This event starts a column-wise panel.  Each output object will be";
        putlog "     placed vertically while this panel is active.";
        putlog " ";
        putlog "     ODS tagsets.htmlpanel event=column_panel(start);";
        putlog "     /* Run Procs here */";
        putlog "     ODS tagsets.htmlpanel event=column_panel(finish);";
        putlog " ";
        putlog " ";
        putlog "A more complex example.";
        putlog " ";
        putlog " |------------------------|";
        putlog " ||------|        |------||";
        putlog " ||      |        |      ||";
        putlog " ||      |        |      ||";
        putlog " ||      |        |      ||";
        putlog " ||      |        |      ||";
        putlog " ||      |        |      ||";
        putlog " ||      |        |      ||";
        putlog " ||------|        |------||";
        putlog " |------------------------|";
        putlog " ";
        putlog "     ODS tagsets.htmlpanel event=row_panel(start);";
        putlog " ";
        putlog "     ODS tagsets.htmlpanel event=column_panel(start);";
        putlog "     /* Run Procs here */";
        putlog "     ODS tagsets.htmlpanel event=column_panel(finish);";
        putlog " ";
        putlog "     /* Run a graph to be placed in the middle ";
        putlog " ";
        putlog "     ODS tagsets.htmlpanel event=column_panel(start);";
        putlog "     /* Run Procs here */";
        putlog "     ODS tagsets.htmlpanel event=column_panel(finish);";
        putlog " ";
        putlog "     ODS tagsets.htmlpanel event=row_panel(finish);";
        putlog " ";
        putlog "==============================================================================";
    end;
    
    

        /*-------------------------------------------------------eric-*/
        /*-- define a list of procs that are to be paneled.         --*/
        /*----------------------------------------------------23Jul03-*/
        define event proc_list;
            /* Init proc list */
            set $proc_list['Gchart'] '1';
            set $proc_list['Gplot'] '1';
            set $proc_list['Gmap'] '1';
            set $proc_list['Gcontour'] '1';
            set $proc_list['G3d'] '1';                
            set $proc_list['Gbarline'] '1';                
            set $proc_list['Gareabar'] '1';                
            set $proc_list['Gradar'] '1';                
            set $proc_list['Gslide'] '1';                
            set $proc_list['Ganno'] '1';                
        end;

        define event initialize;
            trigger set_just_lookup;
            trigger proc_list;

            /*---------------------------------------------------eric-*/
            /*-- Row-wise means that cells are just cells.  A       --*/
            /*-- row-wise panel looks like this.                    --*/
            /*-- <table>                                            --*/
            /*-- <tr>                                               --*/
            /*-- <td></td>                                          --*/
            /*-- <td></td>                                          --*/
            /*-- <td></td>                                          --*/
            /*-- </tr>                                              --*/
            /*-- </table>                                           --*/
            /*------------------------------------------------25Aug03-*/
            eval $row_wise 1;
            /*---------------------------------------------------eric-*/
            /*-- Column-wise means that cells are rows too.         --*/
            /*-- a column wise table looks like this.               --*/
            /*-- <table>                                            --*/
            /*-- <tr><td></td></tr>                                 --*/
            /*-- <tr><td></td></tr>                                 --*/
            /*-- <tr><td></td></tr>                                 --*/
            /*-- </table>                                           --*/
            /*------------------------------------------------25Aug03-*/
            eval $column_wise 0;
            /*---------------------------------------------------eric-*/
            /*-- Panel automatically.  This means that if the proc  --*/
            /*-- is in the list, and a row_panel or column_panel    --*/
            /*-- hasn't been started, that the output will be       --*/
            /*-- put into rows and columns as indicated by the      --*/
            /*-- panel columns variable.                            --*/
            /*------------------------------------------------25Aug03-*/
            set $automatic "true";

            trigger options_set;

        end;



        /*---------------------------------------------------------------eric-*/
        /*-- Options_set is triggered every time the options() option is    --*/
        /*-- used on the ods statement, except the first time.  Initialize  --*/
        /*-- can take care of the first time.                               --*/
        /*--                                                                --*/
        /*-- options_set doesn't really need to do anything.  We could call --*/
        /*-- this setup options from initialize too,  But setup_options     --*/
        /*-- will get called from psuedo panel which is the only place that --*/
        /*-- really matters.                                                --*/
        /*------------------------------------------------------------4Jun 04-*/

        define event options_set;
            trigger setup_options;
            trigger documentation;
        end;

        define event setup_options;
            unset $panel_columns;
            unset $panelborder;
            unset $embedded_titles;
            set $bylabels "no";  /* just for the documentation */
            unset $nobylabels;
            
            /*---------------------------------------------------eric-*/
            /*-- Set up the options.  Values from the options()     --*/
            /*-- option win over macro variables.                   --*/
            /*------------------------------------------------4Jun 04-*/
            
            /* set the panel columns. default 2 */
            do  /if $options['PANELCOLUMNS'];       
                set $tmp $options['PANELCOLUMNS'];
                eval $panel_columns  inputn($tmp, '2.');
            else;
                eval $panel_columns  inputn(panelcolumns,'2.');
            done;

            do  /if ^$panel_columns;       
                eval $panel_columns  2;
            done;
            
            
            /* border width for panels - default none */
            do /if $options['PANELBORDER'];
                set $tmp $options['PANELBORDER'];
                eval $panelborder     inputn($tmp, '2.');
            else /if panelborder;    
                eval $panelborder     inputn(panelborder, '2.');
            done;
            
            
            /* Embedded titles default no */
            do /if $options['EMBEDDED_TITLES'];
                set $embedded_titles "true" /if cmp($options['EMBEDDED_TITLES'], "yes");

            else /if cmp(embedded_titles, 'yes');
                set $embedded_titles 'true';
            done;    
            
            
            /* Strip the bylabels, default is not to strip */
            do /if $options['BYLABELS'];
                set $nobylabels "true"       /if cmp($options['BYLABELS'], "no");
                set $bylabels "yes";

            else /if cmp(bylabels, 'no');
                set $nobylabels 'true';
            done;
            
        end;


        /*-------------------------------------------------------eric-*/
        /*-- This is where we set up the variables and put the      --*/
        /*-- panel on the que.  The panel actually starts later.    --*/
        /*-- when put_panel goes through the que and creates        --*/
        /*-- the panels.                                            --*/
        /*----------------------------------------------------27Aug03-*/
        define event pseudo_panel;
            start:
                /*-----------------------------------------------eric-*/
                /*-- Automatic mode.                                --*/
                /*-- If one panel is queued or started then don't   --*/
                /*-- start another one.                             --*/
                /*--                                                --*/
                /*-- If it isn't then check to see if the current   --*/
                /*-- proc should be panelled.  Then check for       --*/
                /*-- bygroups only and if we are in a bygroup.      --*/
                /*--                                                --*/
                /*-- If all passes we are queing a panel.           --*/
                /*--------------------------------------------25Aug03-*/
                do /if $automatic;
                    do /if $panel_stack;
                        break;
                    else;
                        do / if ^$semi_automatic;
                           break /if ^$proc_list[proc_name];
                        done;
                        do /if $by_groups_only;
                            break /if ^$in_bygroup;
                        done;
                    done;
                    eval $panel_stack[] $row_wise;
                done;

                /*-----------------------------------------------eric-*/
                /*-- setup the options.  This is in case the macro  --*/
                /*-- variables have changed since the last time.    --*/
                /*--------------------------------------------4Jun 04-*/
                trigger setup_options;

                /*-----------------------------------------------eric-*/
                /*-- push the border width onto the panel_que.      --*/
                /*--------------------------------------------24Aug03-*/
                do / if $panelborder;
                    eval $panel_que[] $panelborder;
                else;
                    eval $panel_que[] 0;
                done;                

                do /if $embedded_titles;
                    set $panel_page "true";
                done;
                
                /*-----------------------------------------------eric-*/
                /*-- unset the footnotes.  we want this panel to    --*/
                /*-- catch the first footnotes it finds after it    --*/
                /*-- starts.                                        --*/
                /*--------------------------------------------24Aug03-*/
                unset $$footnotes /if ^$panel_stack;

            finish:

                trigger real_panel finish;

        end;


        /*-------------------------------------------------------eric-*/
        /*-- The actual panel, start and stop.                      --*/
        /*----------------------------------------------------23Aug03-*/
        define event real_panel;
            start:
                set $in_panel "true";
                do /if $automatic;
                    putlog "================= Automatic Panel Start";
                else;
                    do /if $panel_stack[$stack_index];
                        putlog "================= Row-wise Panel Start";
                    else;
                        putlog "================= Column-wise Panel Start";
                    done;
                done;

                /*-----------------------------------------------eric-*/
                /*-- panel_que[$que_index] is the border width for  --*/
                /*-- this panel.                                    --*/
                /*--------------------------------------------24Aug03-*/
                put nl "<table";
                putq " border=" $panel_que[$que_index];
                put ' cellpadding="0"';
                putq " cellspacing=" $panel_que[$que_index] /if $panel_que[$que_index];
                put ">" nl;

                eval $column_index 0;

                /* automatic takes care of it's own rows. */
                break /if $automatic;

                /* row-wise panel needs a tr */
                put "<tr>" /if $panel_stack[$stack_index];
                    
            finish:
                break /if ^$in_panel;
                
                /* automatic takes care of it's own rows. */
                do /if ^$automatic;
                    /* row-wise panel needs a tr */
                    put "</tr>" /if $panel_stack[$stack_index];
                done;

                put "</table>" nl nl;          
                
                do /if $automatic;
                    putlog "================= Automatic Panel Finish";
                else;
                    do /if $panel_stack[-1];
                        putlog "================= Row-wise Panel Finish";
                    else;
                        putlog "================= Column-wise Panel Finish";
                    done;
                done;

                unset $panel_stack[-1];

                do / if $panel_stack;         
                    trigger panel_cell finish;
                else;
                    put "</div>" nl;
                    unset $in_panel;
                    unset $in_bygroup;
                    unset $semi_automatic;
                    set $automatic "true";
                    put "<br>" CR;
                    trigger put_footnotes /if ^$embedded_titles;

                    trigger block_page_breaks finish;

                done;         
        end;            
            

        /*-------------------------------------------------------eric-*/
        /*-- start and end panel rows when the column count is      --*/
        /*-- right.  Only applies to automatic and semi-automatic   --*/
        /*-- panelling.                                             --*/
        /*----------------------------------------------------27Aug03-*/
        define event panel_row;
            start:
                break / if ^$automatic;                

                put "<tr>" / if $column_index eq 0.0;            

            finish:
                break / if ^$automatic;                
                do / if $column_index eq $panel_columns;
                   put "</tr>";
                   eval $column_index 0;
                done;
        end;

        /*-------------------------------------------------------eric-*/
        /*-- A cell in a panel. for each piece of output.           --*/
        /*----------------------------------------------------23Aug03-*/
        define event panel_cell;
            start:
                put nl;
                do / if $panel_stack[-1];          
                    put '<td>' nl;
                else;
                    put "<tr><td>" nl;
                done;            

                put $$setup_titles /if $embedded_titles;
                    
                put $$byline;
                unset $$byline;

            finish:

                put $$setup_footers /if $embedded_titles;

                put nl;
                do / if $panel_stack[-1];          
                    put "</td>" nl;
                else;
                    put "</td></tr>" nl; 
                done; 
                eval $column_index $column_index+1;
        end;
            
            
        
        /*-------------------------------------------------------eric-*/
        /*-- This prints the beginning of each panel. The           --*/
        /*-- panel_que will have the count of panels pending.       --*/
        /*--                                                        --*/
        /*-- We use negative indexing on the panel_stack to         --*/
        /*-- create each panel that we need.  panel que just        --*/
        /*-- tells us where we should start looping from the        --*/
        /*-- top of the stack.  When we get to the top we           --*/
        /*-- are done.                                              --*/
        /*----------------------------------------------------24Aug03-*/
        define event put_panel;
            break /if ^$panel_que;
            /*---------------------------------------------------eric-*/
            /*-- This is the beginning of panelling. so get it      --*/
            /*-- aligned and block the page breaks.                 --*/
            /*------------------------------------------------24Aug03-*/
            do /if $panel_que = $panel_stack;
                put '<div';
                set $align getoption('center');
                put ' align="center"' /if cmp($align, "center");
                put '>' nl;
                trigger block_page_breaks start;
            done;
            
            /*---------------------------------------------------eric-*/
            /*-- Loop over the top of the stack and print out       --*/
            /*-- the queued panels.                                 --*/
            /*------------------------------------------------24Aug03-*/
            eval $stack_index $panel_que * -1;
            /* if this is a nested panel then put it in a cell */
            put '<td>' nl /if $panel_que < $panel_stack;
            eval $que_index 1;

            do /while $stack_index < 0;

                trigger real_panel start;

                /* nested panel coming up. Put it in a cell */
                do /if $stack_index < -1;
                    put "<tr>" /if $panel_stack[$stack_index];
                    put "<td>" nl /if $stack_index < -1;
                done;

                eval $que_index $que_index + 1;
                eval $stack_index $stack_index + 1;

            done;
            
            unset $panel_que;
        end;

        /*-------------------------------------------------------eric-*/
        /*-- Panel_stack keeps track of open panels and what their  --*/
        /*-- type is.  1 is row-wise, 0 is column-wise.             --*/
        /*-- Automatic uses row-wise.                               --*/
        /*--                                                        --*/
        /*-- Panel_stack[-1] is always going to be the type of      --*/
        /*-- the current panel.  If $panel_stack is 0 then          --*/
        /*-- we aren't panelling.                                   --*/
        /*----------------------------------------------------27Aug03-*/
        

        /*-------------------------------------------------------eric-*/
        /*-- An event to start and stop semi-automatic              --*/
        /*-- panels manually.  This type of panel cannot            --*/
        /*-- be nested.  It also creates rows and columns           --*/
        /*-- based on the value of panelcolumns                     --*/
        /*----------------------------------------------------27Aug03-*/
        define event panel;
            start:

                /*-----------------------------------------------eric-*/
                /*-- Don't do anything if we are more than one      --*/
                /*-- panel deep.                                    --*/
                /*--------------------------------------------27Aug03-*/
                do / if $panel_stack;
                   break /if $panel_stack > 1;
                done;

                /*-----------------------------------------------eric-*/
                /*-- If we are panelling stop it, so we can         --*/
                /*-- start fresh.                                   --*/
                /*--------------------------------------------21Aug03-*/
                trigger real_panel finish;
                
                /*-----------------------------------------------eric-*/
                /*-- turn off proc_list control.                    --*/
                /*--------------------------------------------21Aug03-*/
                set $semi_automatic "true";
                set $automatic "true";
                trigger pseudo_panel;
                
                /*------------------------------------------------dan-*/
                /* No page breaks until the panel is done. This flag  */
                /* is reset in "real_panel finish".                   */
                /*--------------------------------------------06Feb04-*/
                trigger block_page_breaks start;


            finish:
                trigger real_panel finish;
                unset $semi_automatic;

                /*------------------------------------------------dan-*/
                /* In certain cases, the page_breaks are not reset in */
                /* "real_panel finish".  Triggering here to make sure */
                /* it's done.
                /*--------------------------------------------06Feb04-*/
                trigger block_page_breaks finish;
        end;

        /*-------------------------------------------------------eric-*/
        /*-- Start or stop a row-wise panel.                        --*/
        /*----------------------------------------------------23Aug03-*/
        define event row_panel;
            start:
                /* close the auto panel if there is one. */
                trigger real_panel finish /if $automatic;
                unset $automatic;
                trigger pseudo_panel start;
                eval $panel_stack[] $row_wise;
            finish:
                trigger pseudo_panel finish;
        end;            


        /*-------------------------------------------------------eric-*/
        /*-- Start or stop a columnwise panel                       --*/
        /*----------------------------------------------------23Aug03-*/
        define event column_panel;
            start:
                /* close the auto panel if there is one. */
                trigger real_panel finish /if $automatic;
                unset $automatic;
                trigger pseudo_panel start;
                eval $panel_stack[] $column_wise;
            finish:
                trigger pseudo_panel finish;
        end;


        /*-------------------------------------------------------eric-*/
        /*-- The beginning or ending of a procedure.                --*/
        /*-- Only do something if we are in automatic               --*/
        /*-- mode.                                                  --*/
        /*----------------------------------------------------26Aug03-*/
        define event proc;
            start:

                break /if ^$automatic;

                /*-----------------------------------------------eric-*/
                /*-- Check the proc name against the list of procs  --*/
                /*-- that should be paneled.                        --*/
                /*--------------------------------------------23Jul03-*/
                do /if ^$semi_automatic;
                    do / if !$proc_list[proc_name];        
                        /*---------------------------------------eric-*/
                        /*-- This proc isn't in our list.  Close up --*/
                        /*-- the panel if we have one open.         --*/
                        /*------------------------------------15Aug03-*/
                        trigger real_panel finish;
                    done;
                done;

            finish:
                
                break /if ^$automatic;

                /*-----------------------------------------------eric-*/
                /*-- If we are doing bygroup paneling with          --*/
                /*-- separated by's then it's time to close         --*/
                /*-- up the panel and print the footnotes           --*/
                /*-- if we have any.                                --*/
                /*--------------------------------------------15Aug03-*/
                do /if ^$semi_automatic;
                    do / if exists($in_panel, $in_bygroup);
                    
                        put "</tr>" / if $column_index ne 0.0;

                        trigger real_panel finish;

                    done;               
                done;
        end;

        /*-------------------------------------------------------eric-*/
        /*-- A byline.                                              --*/
        /*----------------------------------------------------23Aug03-*/
        define event byline;
            
            /*---------------------------------------------------eric-*/
            /*-- Que a panel if we are doing automatic panelling.   --*/
            /*-- Stop the previous panel if it's not a bygroup.     --*/
            /*------------------------------------------------27Aug03-*/
            do /if $automatic;
                
                /*-----------------------------------------------eric-*/
                /*-- Only do this if we are not doing semi-automatic--*/
                /*-- panelling.  In other words someone did a panel --*/
                /*-- start and expects rows and columns to occur    --*/
                /*-- until a panel end.                             --*/
                /*--------------------------------------------27Aug03-*/
                trigger real_panel finish /if ^exists($in_bygroup) and ^exists($semi_automatic);

                /*---------------------------------------------------eric-*/
                /*-- First byline of the panel.  Print the beginning of --*/
                /*-- the panel  and block the page breaks.              --*/
                /*------------------------------------------------28Jul03-*/

                set $in_bygroup "true";                

                trigger pseudo_panel start;
            
            done;

            open byline /if $panel_stack;

            set $strip_bylabel "true" / if $nobylabels;            
            trigger head2;
            unset $strip_bylabel / if $nobylabels;            
            put '<p/>' / if ^$in_panel;
            
            close /if $panel_stack;
        end;


        /*-------------------------------------------------------dan-*/
        /*-- We strip the bygroup label here, if necessary.        --*/
        /*---------------------------------------------------25Feb04-*/

        define event head2;
            trigger pre_post start;
            put "<div";
            trigger classalign;
            trigger style_inline;
            put ">";
            trigger hyperlink_value / if exists(URL);
            do / if $strip_bylabel;
              set $byval scan(VALUE,2,"=");
              put $byval;
              unset $byval;
            else;
              put VALUE / if !exists(URL);
            done;
            put '&nbsp;' /if !exists(strip(value));
            put "</div>" CR;
            trigger pre_post finish;
        end;



        /*-------------------------------------------------------eric-*/
        /*-- The beginning or ending of an output object.  table,   --*/
        /*-- graph, etc.                                            --*/
        /*----------------------------------------------------23Aug03-*/
        define event output;
            start:
                do / if $panel_stack;

                    /*-------------------------------------------eric-*/
                    /*-- loop through the panel que and start any   --*/
                    /*-- panels in it.                              --*/
                    /*----------------------------------------25Aug03-*/
                    trigger  put_panel;
                    
                    /*-------------------------------------------eric-*/
                    /*-- automatic mode needs rows.                 --*/
                    /*----------------------------------------25Aug03-*/
                    trigger panel_row start;
                
                    trigger panel_cell start;

                else;  
                    put $$setup_titles / if $embedded_titles;
                    put "<div>" CR;
                done;               

            finish:
                do / if $panel_stack;
                    
                    /*-------------------------------------------eric-*/
                    /*-- automatic mode needs rows.                 --*/
                    /*----------------------------------------25Aug03-*/
                    trigger panel_cell finish;
                    trigger panel_row finish;
                else;              
                    put "</div>" CR;
                    put "<br";
                    put $empty_tag_suffix;
                    put ">" CR;
                done;   
        end;
            

        /*-------------------------------------------------------eric-*/
        /*-- All titles happen between this event's start           --*/
        /*-- and finish.  redirect them to a stream or              --*/
        /*-- throw them away.                                       --*/
        /*----------------------------------------------------14Aug03-*/
        define event system_title_group;
            start:
                /*-----------------------------------------------eric-*/
                /*-- We don't want to print the titles if we are    --*/
                /*-- inside a panel or we want the panels to go     --*/
                /*-- inside the panel.  Sounds strange.             --*/
                /*--                                                --*/
                /*-- If a panel is started It's too late. We        --*/
                /*-- can't print them.  likewise, we don't want     --*/
                /*-- to print them inside or outside a panel if     --*/
                /*-- titles are supposed to go inside. - that       --*/
                /*-- happens elsewhere.                             --*/
                /*--------------------------------------------22Aug03-*/
                do /if cmp(embedded_titles, "yes");
                    set $embedded_titles "true";
                done;

                do /if any($panel_page, $in_panel, $embedded_titles);
                    trigger block_title;
                    trigger block_title_container;
                done;
                
            finish:
                trigger block_title finish;
                trigger block_title_container finish;
        end;
        
        
        /*-------------------------------------------------------eric-*/
        /*-- All footnotes happen between this event's start        --*/
        /*-- and finish.  redirect them to a stream or              --*/
        /*-- throw them away.                                       --*/
        /*----------------------------------------------------14Aug03-*/
        define event system_footer_group;
            start:
                /*-----------------------------------------------eric-*/
                /*-- Only save the first footnotes we come across   --*/
                /*-- while we are panelling.                        --*/
                /*--------------------------------------------22Aug03-*/

                do /if any($panel_page, $in_panel);
                    trigger block_footnote;
                    trigger block_title_container;
                done;

            finish:
                trigger block_footnote finish;
                trigger block_title_container finish;
        end;
            

        /*-------------------------------------------------------eric-*/
        /*-- Write out the footnotes we saved earlier.              --*/
        /*----------------------------------------------------14Aug03-*/
        define event put_footnotes;
            put $$footnotes;
            unset $$footnotes;
        end;
        
        /*-------------------------------------------------------eric-*/
        /*-- Make sure panel_page is reset for the next page.       --*/
        /*----------------------------------------------------24Aug03-*/
        define event pagebreak;
            put PAGEBREAKHTML CR;
            /* to let footnotes come out */
            unset $panel_page;
        end;
        

        /*-------------------------------------------------------eric-*/
        /*-- These events create fully formatted titles and         --*/
        /*-- footnotes at the beginning of each 'page'.             --*/
        /*-- They are saved away in 2 streams so we can             --*/
        /*-- print them when ever, and where ever we want.          --*/
        /*----------------------------------------------------22Aug03-*/
        
        /*-------------------------------------------------------eric-*/
        /*-- This event is the beginning and ending of all          --*/
        /*-- page setup.  It surrounds all the titles and           --*/
        /*-- footnotes that come as page setup information.         --*/
        /*----------------------------------------------------24Aug03-*/
        define event page_setup;
            delstream setup_titles;
            delstream setup_footers;
        end;

        /*-------------------------------------------------------eric-*/
        /*-- This surrounds the all the title events in the         --*/
        /*-- setup section.                                         --*/
        /*----------------------------------------------------24Aug03-*/
        define event system_title_setup_group;
            start:
                open setup_titles;
            finish:
                close;
        end;

        define event system_title_setup;
            start:
                trigger system_title;
            finish:
                trigger system_title;
        end;

        /*-------------------------------------------------------eric-*/
        /*-- This surrounds the all the footnote events in the      --*/
        /*-- setup section.                                         --*/
        /*--                                                        --*/
        /*-- Redirect the Footnotes and all their formatting into   --*/
        /*-- a stream for later.  If footnotes is empty then        --*/
        /*-- copy them there too.  - Panels only get the first      --*/
        /*-- set of footnotes we come across.  If embedded_titles   --*/
        /*-- is on, then we use the setup_footnotes instead.  So    --*/
        /*-- they can change from one panel cell to the next.       --*/
        /*----------------------------------------------------24Aug03-*/
        define event system_footer_setup_group;
            start:
                open setup_footers;
            finish:
                close;
                /* save them once for each composite until they get used */
                do /if ^$$footnotes;
                    set $$footnotes $$setup_footers;
                done;
        end;

        define event system_footer_setup;
            start:
                trigger system_footer;
            finish:
                trigger system_footer;
        end;

        /*-------------------------------------------------------eric-*/
        /*-- The title and footnote containers.  For HTML we put    --*/
        /*-- all our titles and footnotes in a table.               --*/
        /*----------------------------------------------------24Aug03-*/
        define event title_setup_container;
            start:
                trigger title_container;
            finish:
                trigger title_container;
        end;

        define event title_setup_container_row;
            start:
                trigger title_container_row;
            finish:
                trigger title_container_row;
        end;

        /*--------------------------------------------------eric-*/
        /*-- Block/unblock the titles or footnotes.            --*/
        /*-----------------------------------------------11Aug03-*/
        define event block_title_container;
            start:
                break /if $title_container_blocked; 
                block title_container;
                block title_container_row;
                set $title_container_blocked "true";

             finish:
                unblock title_container;
                unblock title_container_row;
                unset $title_container_blocked;
        end;
         

        define event block_title;
            start:
                break /if $title_blocked;
              
                block system_title;
                set $title_blocked "true";

            finish:
                unblock system_title;
                unset $title_blocked;
        end;

 
        define event block_footnote;
            start:
                break /if $footnote_blocked;

                block system_footer;
                set $footnote_blocked "true";

             finish:
                 unblock system_footer;
                 unset $footnote_blocked;
        end;
         

        /*-------------------------------------------------------eric-*/
        /*-- Block and unblock page breaks.                         --*/
        /*----------------------------------------------------14Aug03-*/
        define event block_page_breaks;
            start:
                block line;   
                block pagebreak;
            finish:
                unblock line;   
                unblock pagebreak;
        end;

    end;
run;
