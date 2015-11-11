var lycos_ad = Array();
var lycos_search_query = "";
var lycos_onload_timer;

function lycos_load_script(url) {
    document.write('<script type="text/javascript" src="' + url + '"></script>');
}

function lycos_load_style(url) {
    if (document.createStyleSheet) {
        document.createStyleSheet(url);
    } else {
	if (document.createElement && document.getElementsByTagName) {
	    var link = document.createElement("link");
	    link.rel = "stylesheet";
	    link.type = "text/css";
	    link.href = url;
	    link.media = "screen";
	    document.getElementsByTagName('head').item(0).appendChild(link);
	}
    }
}

function lycos_get_cookie(name) {
    var dc = document.cookie;
    var prefix = name + "=";
    var begin = dc.indexOf("; " + prefix);
    if (begin == -1) {
        begin = dc.indexOf(prefix);
        if (begin != 0) return null;
    }
    else begin += 2;
    var end = document.cookie.indexOf(";", begin);
    if (end == -1) end = dc.length;
    return unescape(dc.substring(begin + prefix.length, end));
}

function lycos_get_query_variable(varname) {
    var qs = window.location.search.substring(1);
    var pairs = qs.split("&");
    
    for (var i = 0; i < pairs.length; i++) {
	var pos = pairs[i].indexOf('=');
	if (pos == -1) {continue;}
	var argname = pairs[i].substring(0,pos);
	var argvalue = pairs[i].substring(pos+1);
	if (argname == varname) {
            return decodeURIComponent(argvalue.replace("+", " "));
	}
    }
    return null;
}


function lycos_show_bottom_ad() {
    // quit if this function has already been called
    if (arguments.callee.done) return;
    arguments.callee.done = true;
    if (this.lycos_onload_timer) clearInterval(lycos_onload_timer);

    if (document.getElementById && document.getElementsByTagName) {
	var footer_ad = document.getElementById("FooterAd");
	var body_element = document.getElementsByTagName("body").item(0);
	if (footer_ad && body_element) {
	    body_element.appendChild(footer_ad);
	    footer_ad.style.display = "block";
	}
    }
}

function lycos_check_size() {
    var window_width = 0, window_height = 0;
    if (typeof(window.innerWidth) == 'number' ) {
        window_width = window.innerWidth;
        window_height = window.innerHeight;
    } else if (document.documentElement && (document.documentElement.clientWidth || document.documentElement.clientHeight)) {
        window_width = document.documentElement.clientWidth;
        window_height = document.documentElement.clientHeight;
    } else if (document.body && (document.body.clientWidth || document.body.clientHeight)) {
        window_width = document.body.clientWidth;
        window_height = document.body.clientHeight;
    }

    var lycos_track_img = document.createElement('img');
    if( top == self ) {
        return 1;
    } else {
        if ((window_width < 300) || (window_height < 300)) {
            lycos_track_img.src=this.lycos_ad_track_small+"&w="+window_width+"&h="+window_height;
            return 0;
        } else {
            lycos_track_img.src=this.lycos_ad_track_served+"&w="+window_width+"&h="+window_height;
            return 1;
        }
    }


}

function lycos_top100(dir) {
    top.location.href='http://lt.tripod.com/tp_toolbar/'+dir+'/_h_/'+this.lycos_ad_www_server+'/bin/top100/top100.pl?a='+dir+"&url="+location.href;
}

function lycos_get_search_referrer() {
    var searchReferrers=[[/^http:\/\/search.msn.com\/.*[\?\&]q=([a-zA-Z0-9_\+%\-\.\: \'\"]+)/i, 1],
                         [/^http:\/\/.*[\?\&]q=cache[^\+]*[\+]([a-zA-Z0-9_\+%\-\.\: \'\"]+)/i, 1],
                         [/^http:\/\/.*looksmart.com\/.*[\?\&]key=([a-zA-Z0-9_\+%\-\.\: \'\"]+)/i, 1],
                         [/^http:\/\/.*[\?\&\/](query|search|MT|q|p|ask|key|qkw|k|qry|K)=([a-zA-Z0-9_\+%\-\.\: \'\"]+)/i, 2]];
    var query;
    for (var i=0; i<searchReferrers.length; i++) {
        var result = document.referrer.match(searchReferrers[i][0]);
        if (result) {
            query = unescape(result[searchReferrers[i][1]].replace("+", " "));
            break;
        }
    }
    return query;
}

function lycos_draw_promo() {
    var promo_html;

    promo_html = '  <div class="sponsorBar">' +
	'   <div>Site Sponsors</div>' +
        '   <a href="http://www.whowhere.com/?utm_source=Tripod&amp;utm_medium=Sponsor%2BBar" target="_blank"><img src="http://af.lygo.com/d/toolbar/sponsors/whowhere_70x20.jpg" width="70" height="20" alt="sponsor logo" title="Find the people you miss in the U.S. with WhoWhere free people search engine."/></a>' +
	'   <a href="http://www.gamesville.com/" target="_blank"><img src="http://af.lygo.com/d/toolbar/sponsors/gvLogo70x20.jpg" width="70" height="20" alt="sponsor logo" title="Play free online games at Gamesville!"/></a>' +
	'   <a href="http://www.listen.com/disty/index.jsp?from=lycos" target="_blank"><img src="http://af.lygo.com/d/toolbar/sponsors/rhapsody_logo.jpg" width="70" height="20" alt="sponsor logo" title="Rhapsody"/></a>' +
	'  <a href="http://www.wired.com/wired/issue/test2007?mbid=lycos-test-70x20" target="_blank"><img src="http://af.lygo.com/d/toolbar/sponsors/wired_test_70x20.gif" width="70" height="20" alt="WIRED"/></a>' +
	'  </div>';

    document.write(promo_html);
}

function lycos_draw_toolbar() {
    lycos_load_style("/adm/ad/toolbar.css");

    var toolbar_html = 
	'  <div id="tb">';
    var search_query_name = "query";
    var search_query_value = "";
    var page_title = encodeURIComponent( document.title );
    var page_url = encodeURIComponent( document.location.href );
    var monsterRand = Math.floor( Math.random() * 1000001 );

    if (this.lycos_search_query) {
	search_query_value = this.lycos_search_query;
    } else if (this.lycos_ad_category && this.lycos_ad_category.find_what) {
        search_query_value = this.lycos_ad_category.find_what;
    }
    search_query_value = search_query_value.replace('"', "");

    toolbar_html += 
   
        '    <form name="lycos_search" method="get" target="_top" action="http://'+this.lycos_ad_www_server+'/bin/search/pursuit">' +
        '      <table cellpadding="0" cellspacing="0" border="0" width="100%" height="52">'+
	'        <tr>' +
        '          <td rowspan="2"><a href="http://www.lycos.com/" target="_blank"><img src="http://ly.lygo.com/ly/cos/img/lycos_the_dog.png" width="41" height="42" alt="Lycos Search" title="Woof!!!"/></a></td>' +
	'          <td height="25" colspan="2">' +
	'            <table cellpadding="0" cellspacing="0" border="0">' +
	'              <tr>' +
	'                <td><strong>&nbsp;Search:</strong></td>' +
	'                <td><input type="radio" name="cat" value="lycos" checked="checked"></td>' +
	'                <td nowrap="nowrap">The Web</td>' +
	'                <td><input type="radio" name="cat" value="tripod_member"></td>' +
	'                <td nowrap="nowrap">Tripod</td>' +
	'              </tr>' +
	'            </table>' +
	'          </td>'+
	'          <td colspan="2" style="border-bottom: 1px solid #dcdcdc;">' +
  '           <img src="http://af.lygo.com/d/toolbar/abuse.gif" alt="icon" title="report abuse" height="8" hspace="3" width="8"><a href="http://help.lycos.com/newticket.php" target="_top">Report Abuse</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' +
	'           <span class="raquo">&laquo;</span>' +
	'           <span id="lycos_top100">' +
	'            <a href="javascript:lycos_top100(\'prev\')" target="_top">Previous</a> |' +
	'            <a href="http://lt.tripod.com/tp_toolbar/top100/_h_/'+this.lycos_ad_www_server+'/members/top100_1.html" target="_top">Top 100</a> |' +
	'            <a href="javascript:lycos_top100(\'next\')" target="_top">Next</a>' +
	'          </span>' +
	'          <span class="raquo">&raquo;</span>' +
	'          </td>' +
	'          <td rowspan="2" width="150"><a href="http://'+this.lycos_ad_www_server+'" target="_top"><img src="http://af.lygo.com/d/toolbar/logo.tripod-toolbar.gif" alt="logo" title="hosted by tripod" border="0" height="50" width="150"></a></td>' +
	'        </tr>' +
	'        <tr>' +
	'          <td nowrap="nowrap">&nbsp;<input id="query" type="text" name="'+search_query_name+'" value="'+search_query_value+'"> <input name="submit" class="buttons" type="image" value="image" src="http://ly.lygo.com/ly/hp/ggiBut.gif" /></td>' +
	'          <td id="angle"><img src="http://af.lygo.com/d/toolbar/angle25x25.gif" width="25" height="25" alt="angle graphic" title=""/></td>';
    if (tripod_ratings_hash) {
        toolbar_html += '<td style="background-color: #fff;"><script type="text/javascript">drawRatingsWidget(300,tripod_member_name,"",tripod_ratings_hash)</script></td>';
    }
    toolbar_html +=
	'         <td style="background-color: #fff; font-size: 9px; padding: 0 0 0 10px;">share: ' +
	'          <a href="http://del.icio.us/post?url=' + page_url + ';title=' + page_title + '" title="Submit to del.icio.us" target="_blank">del.icio.us</a> |' +
	'          <a href="http://digg.com/submit?phase=2&amp;url=' + page_url + '&amp;title=' + page_title + '" title="Submit to digg" target="_blank">digg</a> |' +
	'          <a href="http://reddit.com/submit?url=' + page_url + '&amp;title=' + page_title + '" title="Submit to reddit" target="_blank">reddit</a> |' +
        '          <a href="http://furl.net/store?u=' + page_url + '&amp;t=' + page_title + '" title="Submit to furl" target="_blank">furl</a> |' +
        '          <a href="http://facebook.com/share.php?u=' + page_url + '" title="Submit to facebook" target="_blank">facebook</a>' +
	'         </td>' +

	'        </tr>' +
	'      </table>' +
	'    </form>' +
	'</div>'
   
    document.write(toolbar_html);
}

function lycos_insert_ads() {
    this.lycos_search_query = lycos_get_search_referrer();

    var lycos_ad_mgr = new AdManager();

    if (this.lycos_search_query) {
        lycos_ad_mgr.setForcedParam("keyword", this.lycos_search_query);
    } else if (this.lycos_ad_category && this.lycos_ad_category.find_what) {
	lycos_ad_mgr.setForcedParam("keyword", this.lycos_ad_category.find_what);
    }

    if (this.lycos_ad_category && this.lycos_ad_category.dmoz) {
        lycos_ad_mgr.setForcedParam("page", this.lycos_ad_category.dmoz);
    } else {
        lycos_ad_mgr.setForcedParam("page", "member");
    }

    var lycos_prod_set = lycos_ad_mgr.chooseProductSet();
    lycos_ad_mgr.renderHeader();

    var slots = ["leaderboard", "leaderboard2", "toolbar_image", 
		 "toolbar_text", "smallbox" ];
    for (var slot in slots) {
	if (lycos_ad_mgr.isSlotAvailable(slots[slot])) {
	    this.lycos_ad[slots[slot]] = lycos_ad_mgr.getSlot(slots[slot]);
	}
    }

    lycos_ad_mgr.renderFooter();

    if (this.lycos_ad["leaderboard"]) {
        document.write('<div id="tb_container">');
	lycos_draw_toolbar();
	document.write(lycos_ad["leaderboard"]);
    }
}

if (lycos_check_size()) {
    lycos_insert_ads();
}
