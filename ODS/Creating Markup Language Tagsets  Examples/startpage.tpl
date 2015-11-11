
proc template;
    define tagset tagsets.startpage;
        parent=tagsets.html4;
        
        define event initialize;
            set $set_start_page tagset_alias;
            trigger start_page;
        end;    

        define event doc_body;
            start:
                put '<body onload="startup()"';
                put ' onunload="shutdown()"';
                put  ' bgproperties="fixed"' / WATERMARK;
                putq " class=" HTMLCLASS;
                putq " background=" BACKGROUNDIMAGE;
                trigger style_inline;
                put ">" CR;
                trigger pre_post;
                put          CR;
                trigger ie_check;

            finish:
                /*-----------------------------------------------eric-*/
                /*-- Print the footnotes we saved if we aren't      --*/
                /*-- paging.                                        --*/
                /*--------------------------------------------14Aug03-*/
                trigger put_footnotes /if $start_page_no;

                trigger pre_post;
                put "</body>" CR;
        end;
            

        define event startpage;
            /*---------------------------------------------------eric-*/
            /*-- if we got a value check set start page,            --*/
            /*-- if we didn't get a value then set it               --*/
            /*-- to the alias we got on the initial ods             --*/
            /*-- statement.                                         --*/
            /*------------------------------------------------11Aug03-*/
            do /if value;
                set $set_start_page value /if !$set_start_page;
            else;
                set $set_start_page tagset_alias;
            done;
            
            /*---------------------------------------------------eric-*/
            /*-- normal behavior by default if we weren't given     --*/
            /*-- anything to go on.                                 --*/
            /*------------------------------------------------11Aug03-*/
            set $set_start_page "yes" /if !$set_start_page;
            
            do /if cmp($set_start_page, 'no');
                set $start_page_no "true";
            else;
                /*------------------------------------------------eric-*/
                /*-- Print the footnotes if we just turned start     --*/
                /*-- page back on.                                   --*/
                /*---------------------------------------------11Aug03-*/
                trigger put_footnotes;
                
                unset $start_page_no;
                unset $titles_printed;
                trigger block_title finish;
                trigger block_title_container finish;
                trigger block_page_breaks finish;
            done;
            unset $set_start_page;
        end;
       
 
        /*-------------------------------------------------------eric-*/
        /*-- All titles happen between this event's start           --*/
        /*-- and finish.  redirect them to a stream or              --*/
        /*-- throw them away.                                       --*/
        /*----------------------------------------------------14Aug03-*/
        define event system_title_group;
            start:
                do /if $start_page_no;
                    do /if $titles_printed;
                        trigger block_title;
                        trigger block_title_container;
                    done;
                    set $titles_printed "true";

                    /*------------------------------------------eric-*/
                    /*-- Block the page breaks after the first     --*/
                    /*-- titles have been printed.  Otherwise we   --*/
                    /*-- don't get a pagebreak when we switch from --*/
                    /*-- start_page=yes to start_page=no.          --*/
                    /*---------------------------------------11Aug03-*/
                    trigger block_page_breaks start;
                done;
            finish:
                trigger block_title;
                trigger block_title_container;
        end;
        
        
        /*-------------------------------------------------------eric-*/
        /*-- All footnotes happen between this event's start        --*/
        /*-- and finish.  redirect them to a stream or              --*/
        /*-- throw them away.                                       --*/
        /*----------------------------------------------------14Aug03-*/
        define event system_footer_group;
            start:
                do /if exists($$footnotes);
                    trigger block_footnote;
                    trigger block_title_container;
                else;
                    trigger block_title_container finish;
                    open footnotes;
                    set $footnotes_open "true";
                done;

            finish:
                do /if $footnotes_open;
                    close;
                    unset $footnotes_open;
                    trigger block_title_container start;
                else;
                    trigger block_footnote finish;
                    trigger block_title_container finish;
                done;

                trigger put_footnotes /if ^$start_page_no;
        end;
            

        /*-------------------------------------------------------eric-*/
        /*-- Write out the footnotes we saved earlier.              --*/
        /*----------------------------------------------------14Aug03-*/
        define event put_footnotes;
            put $$footnotes;
            unset $$footnotes;
        end;
        
            
        /*--------------------------------------------------eric-*/
        /*-- Block/unblock the titles or footnotes.            --*/
        /*-----------------------------------------------11Aug03-*/
        define event block_title_container;
            start:
                break /if $title_container_blocked;
 
                unblock title_container;
                unblock title_row;
                set $title_container_blocked "true";
             finish:
                unblock title_container;
                unblock title_row;
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
        /*-- block the page breaks so we don't get them inside the panel.--*/
        /*----------------------------------------------------1Aug 03-*/
        define event block_page_breaks;
            start:
                /*-----------------------------------------------eric-*/
                /*-- Only block it once.  Keep the reference count  --*/
                /*-- to one.                                        --*/
                /*--------------------------------------------14Aug03-*/
                do / if ^exists($page_blocked);
                    set $page_blocked "true";
                    block line;
                    block pagebreak;
                done;                   
            finish:
                unblock line;
                unblock pagebreak;
                unset $page_blocked;
        end;

    end;
run;
