if (this.lycos_ad["leaderboard2"]) {
    document.write('</div>');

    if (document.addEventListener) {
	/* for Mozilla/Opera9 */
        document.addEventListener("DOMContentLoaded", 
				  lycos_show_bottom_ad, false);

    } 

    if (/WebKit/i.test(navigator.userAgent)) {
        /* for Safari */
	lycos_onload_timer = setInterval(function() {
	    if (/loaded|complete/.test(document.readyState)) {
	        lycos_show_bottom_ad();
	    }
        }, 10);
    } 

    window.onload = lycos_show_bottom_ad;
}
