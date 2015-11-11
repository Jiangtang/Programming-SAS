var ua = navigator.userAgent.toLowerCase();
var is_ie = (ua.indexOf("msie") != -1) && document.all && (ua.indexOf("opera") == -1);

var LyRatingsCookieName = "LyRatings";
var LyRatingsInfo = [];
var cookiesEnabled = true;
var lr_results = Array();
var lr_all = Array();
var lr_sso = LR_fetchCookie("MAYA_SSO");
LR_unpackRatings();

function $() {
  var elements = new Array();

  for (var i = 0; i < arguments.length; i++) {
    var element = arguments[i];
    if (typeof element == 'string')
      element = document.getElementById(element);

    if (arguments.length == 1)
      return element;

    elements.push(element);
  }

  return elements;
}

// Conditional Include
var lr_nostyle; // can be externally defined to suppress style sheet inclusion
if( !lr_nostyle )
  document.write("<link rel='stylesheet' type='text/css' href='http://ratings.lycos.com/css/lycosRating.css'/>\n");

var LR_cacheBustNum = (new Date).getTime();
function LR_getCacheBust() { return LR_cacheBustNum++; }
function LR_contactServer(type,propid,docid,catid,numStars,chksum) {
  var cur = lr_all[docid];
  var url = 'http://ratings.lycos.com/ratings/'+type+'.php?s='+propid+'&d='+escape(docid)+
    '&c='+escape(catid)+'&z='+LR_getCacheBust()+"&MAYA_SSO="+lr_sso;
  if(numStars)
    url += '&nv='+cur.numVotes+'&r='+numStars+"&h="+chksum;
  var script = document.createElement("script");
  script.type="text/javascript";
  script.src=url;

  document.getElementsByTagName('head').item(0).appendChild(script);
  if( is_ie && numStars )
    {
      LR_setAvgRating(docid,Math.round((cur.avgStars*cur.numVotes+numStars)*2/(cur.numVotes+1))/2,cur.numVotes+1);
    }
}

var LR_current = null;

function LycosRating(docid,numStars,catid,savedText) {
  this.id = "lyRating_"+LR_varEscape(docid);
  this.catid = catid;
  this.numStars = numStars;
  this.savedText = savedText;
  this.numVotes = 0;
  this.avgStars = 0;
  this.active = (numStars==0 && cookiesEnabled);
  LR_setCursor(docid,this.active);
}

function LR_submitRating(propid, docid, numStars, lr, chksum) {
  LR_contactServer('rate',propid,docid,lr.catid,numStars,chksum);
  lr.numStars = numStars;
  lr.savedText = LR_labels[6];
  lr.active = false;
  LR_setCursor(docid,lr.active);
  var label = $("lr_label_"+LR_varEscape(docid));
  if (label) label.innerHTML = lr.savedText;
  LR_updateRatingCookie(docid,numStars);
}

function LR_setCursor( docid, isActive )
{
  for( var i=1; i<6; i++) {
    var star = $('s'+i+'_'+LR_varEscape(docid)+'_i');
    if (star) star.style.cursor = isActive ? "pointer" : "default";
  }
}

function LR_hiliteStars(docid, numStars) {
  for (i=1;i<6;i++) {
    type = (i<=numStars) ? 'filled' : 'empty';
    var star = $("s"+i+"_"+LR_varEscape(docid)+"_i");
    if (star) star.src = 'http://ly.lygo.com/ly/rate/'+type+'_star.gif';
  }
}

function LR_mouseMove(e) {
  if (e.button == 0 && is_ie && LR_current != null )
    LR_mouseBlur();
}

function LR_mouseDown(docid, numStars) {
  var lr = lr_all[docid];
  if( !lr.active ) return;
  LR_current = lr;
  document.body.parentNode.onmouseup = LR_mouseBlur;
  LR_hiliteStars(docid, numStars);
}

function LR_mouseUp(propid, docid, numStars, chksum) {
  var lr = lr_all[docid];
  if( !lr.active ) return;
  if (LR_current != null && LR_current == lr) {
    LR_hiliteStars(docid, numStars);
    LR_submitRating(propid, docid, numStars, lr, chksum);
    LR_current = null;
  }
}

function LR_mouseOver(docid, numStars) {
  var lr = lr_all[docid];
  if( !lr.active ) return;
  if (LR_current != null) {
    if (LR_current == lr)
      LR_hiliteStars(docid, numStars);
    else
      return;
  } else {
    for(i=1;i<=numStars;i++) {
      var star = $("s"+i+"_"+LR_varEscape(docid)+"_i");
      if (star) star.src = 'http://ly.lygo.com/ly/rate/hilite_star.gif';
    }
  }
  var label = $("lr_label_"+LR_varEscape(docid));
  if (label) label.innerHTML = LR_labels[numStars];
}

function LR_mouseBlur() {
  LR_current = null;
  document.body.parentNode.onmouseup = null;
}

function LR_mouseOut(docid, numStars) {
  var lr = lr_all[docid];
  if( !lr.active ) return;
  LR_hiliteStars(docid, lr.numStars);
  var label = $("lr_label_"+LR_varEscape(docid));
  if (label) label.innerHTML = lr.savedText;
}

function LR_getInitNumStars(docid) {
  return LyRatingsInfo[docid]?LyRatingsInfo[docid]:0;
}

function LR_updateRatingCookie(docid,numStars) {
  if( numStars < 1 || numStars > 5 )
    return;

  maxLen = 1000;
  cookieVal = LR_fetchCookie(LyRatingsCookieName);
  mark = '|'+escape(docid)+':';
  old = cookieVal.indexOf(mark);
  if(old == -1 ) {
    if( cookieVal == '|' ) cookieVal = '';
    cookieVal += '|' + escape(docid) + ':' + numStars;
    len = cookieVal.length;
    if( len > maxLen ) {
      start = cookieVal.indexOf('|',len-maxLen);
      cookieVal = cookieVal.substring(start,len);
    }
  }
  else {
    old += mark.length;
    cookieVal = cookieVal.substring(0,old) + numStars + cookieVal.substring(old+1,cookieVal.length);
  }

  if( cookieVal )
    LR_setCookie(LyRatingsCookieName,cookieVal);
}

function LR_unpackRatings() {
  LR_labels = ["Select&nbsp;Rating","Poor","Below Avg","Average","Good","Excellent","Rated","Be the first to rate this"];
  str = LR_fetchCookie(LyRatingsCookieName);
  if( str == "" )
    {
      LR_setCookie(LyRatingsCookieName,'|');
      cookiesEnabled = ( LR_fetchCookie(LyRatingsCookieName) != "" );
    }
  else {
    pairs = str.split('|');
    for( i=0; i<pairs.length; i++) {
      pairs[i] = pairs[i].split(':');
      LyRatingsInfo[unescape(pairs[i][0])] = pairs[i][1];
    }
  }
}

function LR_setAvgRating( docid, numStars, numVotes ) {
  var escId = LR_varEscape(docid);
  if(numStars>0 && numVotes>0)
    {
      var lr = lr_all[docid];
      lr.avgStars = numStars;
      lr.numVotes = numVotes;
      var star = $('lr_avg_'+escId+'_i');
      if (star) star.src = 'http://ly.lygo.com/ly/rate/stars_'+numStars+'.gif';
      star = $('lr_tot_'+escId);
      if (star) star.innerHTML = '(' + numVotes + ')';
    }
  else if( numVotes==0 )
    {
      var lr = lr_all[docid];
      lr.savedText = LR_labels[7];
      var label = $('lr_label_'+escId);
      if (label) label.innerHTML = LR_labels[7];
    }
}

function LR_setCookie(name,val) {
  var exp = (new Date((new Date()).getTime()+86400000*365)).toGMTString();
  var domain = document.domain.replace(/.*(\..*\..*)/, '$1');
  document.cookie = name+"="+val+";path=/;domain="+domain+";expires="+exp;
  document.cookie = name+"="+val+";path=/;domain=.lycos.com;expires="+exp;
}

function LR_fetchCookie(cookieName) {
  var all = document.cookie;
  //var start =  all.lastIndexOf( cookieName + "=" );
  var start =  all.lastIndexOf( cookieName + "=" );
  if( start >= 0 )
    {
      start += cookieName.length+1;
      var end = all.indexOf( ";", start );
      if( end > start )
	return all.substring( start, end );
      else
	return all.substring( start );
    }
  return "";
}

function LR_varEscape(x){
  return x.replace(/(\W)/g, function(c){return '$'+c.charCodeAt(0)}); //escape(x);
}

// draw the LycosRatings widget.
// Pass in: propid - ID of the hosting property
//          docid  - ID of the item to be rated
//          catid  - category of the item to be rated
//          hash   - the server-generated verification hash
function drawRatingsWidget( propid, docid, catid, hash )
{
  docid += '';
  var escid = LR_varEscape(docid);
  var htmid = docid.replace(/\'/g, "\\'");
  numStars = LR_getInitNumStars( docid );
  l = (numStars>0) ? LR_labels[6] : LR_labels[0];
  if( !catid ) catid = '';

  document.write("<div class='lr_rating' onmouseover='$(\"lr_pop_"+escid+"\")"+
		 ".style.display=\"block\"' onmouseout='$(\"lr_pop_"+escid+"\")"+
		 ".style.display=\"none\"'><div class='lr_pop' id='lr_pop_"+escid+
		 "'><div class='lr_pop_top'><img src=\"http://ly.lygo.com/ly/rate/arrow_7x7.gif\" "+
		 "class=\"lr_arrow\" />");

  for( i=1; i<6; i++ )
  {
    type = (i<=numStars) ? 'filled' : 'empty';
    document.write
      ('<a id="'+escid+'" href="javascript:;" onmousemove="LR_mouseMove(event)" '+
       'onmousedown="LR_mouseDown(\''+htmid+'\','+i+');return false;" '+
       'onmouseup="LR_mouseUp('+propid+',\''+htmid+'\','+i+',\''+hash+'\');return false;" '+
       'onmouseover="LR_mouseOver(\''+htmid+'\','+i+');return false;" '+
       'onmouseout="LR_mouseOut(\''+htmid+'\','+i+');return false;" '+
       '><img class="lr_star" id="s'+i+'_'+escid+'_i" src="http://ly.lygo.com/ly/rate/'+type+
       '_star.gif" /></a>');
  }

  document.write('</div><div class="lr_pop_bot"><div><table><tr class="lr_label"><td '+
		 'width="110"><span id="lr_label_'+escid+'">'+l+'</span></td><td align="right">' +
		 '<span class="lr_tot_votes" id="lr_tot_'+escid+'"></span></td></tr></table>'+
		 '</div></div></div><div class="lr_main">'+
		 '<img class=\"lr_stars\" id=\"lr_avg_'+escid+'_i" '+
		 'src="http://ly.lygo.com/ly/rate/stars_0.gif" width="91" height="17" /></div></div>');
  lr_all[docid] = new LycosRating( docid, numStars, catid, l );
  LR_contactServer( 'getRating', propid, docid, '', '' );
}
