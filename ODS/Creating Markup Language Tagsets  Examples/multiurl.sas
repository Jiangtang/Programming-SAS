
proc template;
    

    define tagset tagsets.multi_url;

        define event stylesheet_link;
            break /if !exists(url);
            set $urlList url;
            trigger urlLoop ;
            unset $urlList;
        end;

        define event link;
            putq '<link rel="stylesheet" type="text/css" href=' $current_url; '>' nl;
        end;

        define event urlLoop;
            eval $space_pos index($urlList, " ");

            do /while $space_pos ne 0;

                set $current_url substr($urlList,1,$space_pos);
                set $current_url trim($current_url);

                trigger link;

                set $urlList substr($urlList,$space_pos);
                set $urlList strip($urlList);

                eval $space_pos index($urlList, " ");
            done;

            /* when space_pos is 0 it's either the only link or the last link */
            set $current_url $urlList;
            trigger link;
        end;
    end;
run;

ods tagsets.multi_url file="multi_url_out.txt" stylesheet=(url="file1.css file2.css file3.css");
ods tagsets.multi_url close;

