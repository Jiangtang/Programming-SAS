
function AdManager(){function loadScript(_1){document.write("<script type=\"text/javascript\" src=\""+_1+"\"></script>");}
function getCookie(_2){var dc=document.cookie;var _4=_2+"=";var _5=dc.indexOf("; "+_4);if(_5==-1){_5=dc.indexOf(_4);if(_5!=0){return null;}}else{_5+=2;}
var _6=document.cookie.indexOf(";",_5);if(_6==-1){_6=dc.length;}
return unescape(dc.substring(_5+_4.length,_6));}
function getQueryVariable(_7){var qs=window.location.search.substring(1);var _9=qs.split("&");for(var i=0;i<_9.length;i++){var _b=_9[i].indexOf("=");if(_b==-1){continue;}
var _c=_9[i].substring(0,_b);var _d=_9[i].substring(_b+1);if(_c==_7){return decodeURIComponent(_d.replace("+"," "));}}
return null;}
this.chooseProductSet=function(){};this.getSlot=function(_e){if(this.slots&&this.slots[_e]){return this.slots[_e];}else{return null;}};this.isSlotAvailable=function(_f){return Boolean(this.getSlot(_f));};this.renderSlot=function(_10){var str=this.getSlot(_10);if(str){document.write(str);}};this.renderHeader=function(){this.renderSlot("header");};this.renderFooter=function(_12){this.renderSlot("footer");};this.getParam=function(_13){if(this.params&&this.params[_13]){return this.params[_13];}else{return null;}};this.setParam=function(_14,_15){this.params[_14]=_15;};this.setForcedParam=function(_16,_17){this.setParam(_16,_17);};this.setHostId=function(_18){this.host=_18;};this.setTaxId=function(_19){this.taxid=_19;};this.setVid=function(vid){};this.supportProductSet=function(set){};this.setDebugMode=function(_1c){};this.ver=2;this.params=new Object();if(window.cm_host){this.host=window.cm_host;}
if(window.cm_taxid){this.taxid=window.cm_taxid;}
if(window.cm_role){this.role=window.cm_role;}
var _1d=getCookie("cm_role");if(_1d){this.role=_1d;}
var _1e=getQueryVariable("cm_role");if(_1e){this.role=_1e;}
this.init=function(){if(this.host&&this.taxid){if(this.role&&(this.role=="local")){loadScript("catman/code/"+this.host+this.taxid+".js");}else{if(this.role&&((this.role=="deux")||(this.role=="dev"))){loadScript("http://scripts.pd.lycos.com/catman/code/"+this.host+this.taxid+".js");}else{if(this.role&&(this.role=="qa")){loadScript("http://scripts.qa.lycos.com/catman/code/"+this.host+this.taxid+".js");}else{loadScript("http://scripts.lycos.com/catman/code/"+this.host+this.taxid+".js");}}}}};}
new AdManager().init();