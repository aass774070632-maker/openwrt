/* Language convert */
function translateLabelHTML(strElementID, strTransName){
	var e = document.getElementById(strElementID);
	if( e!= null )
		e.innerHTML = _(strTransName);
}

function translateLabelValue(strElementID, strTransName){
	var e = document.getElementById(strElementID);
	if( e!= null )
		e.value = _(strTransName);
}

/*
 *	IE6 등에서 innerHTML에 form 또는 복잡한 Tag가 들어갈때 오류가 발생하므로
 *	이를 회피하기 위한 code
 */
function mcr_setInnerHTML(containerId, setHtml) {
	var newdiv = document.createElement("div");
	newdiv.innerHTML = setHtml;
	var container = document.getElementById(containerId);
	if( container != null ){
		container.appendChild(newdiv);
	}
}

/* ==================================================
	Form 제어
   ================================================== */

/* init combo */
function initCombo(e, initValue){
	if( e!= null ){
		for (var i = 0; i < e.length; i++) {
			if ( e.options[i].value == initValue ) {
				e.options[i].selected=true;
			}
		}
	}
}

/* init checkbox */
function initCheckbox(e, initValue){
	if( e!= null ){
		if( initValue == "1" ){
			e.checked = true;
		}else{
			e.checked = false;
		}
	}
}
/* init radiobutton */
function initRadio(e, initValue){
	if( e!= null ){
		for (var i = 0; i < e.length; i++) {
			if ( e[i].value == initValue ) {
				e[i].checked=true;
			}
		}
	}
}
/* init textbox */
function initText(e, initValue){
	if( e!= null ){
		if( initValue != null && initValue.length > 0 ){
			e.value = initValue;
		}else{
			e.value = "";
		}
	}
}

/*
 * div, span, table, tr 등에서 동작됨
 */
function objectShow(obj, bShow){
	if( obj == null ) return;
	if (bShow){
		obj.style.display = "";
	}else{
		obj.style.display = "none";
	}
}

/*
 * form data element(input, ... )
 */
function objectDisable(obj, bDisable){
	if( obj == null ) return;
	obj.disabled = bDisable;
}

function comboSetArray(targetCombo, srcArray, defaultValue){
	targetCombo.options.length = srcArray.length;
	for( var i = 0; i < targetCombo.options.length; i++ ){
		targetCombo.options[i] = new Option(srcArray[i], i);
	}
	if( defaultValue != -1 ){
		initCombo( targetCombo, defaultValue );
	}
}

function getRadioSelectedValue(field){
	if( field == null ) return -1;
	for( var i = 0; i < field.length; i++ ){
		if( field[i].checked == true ){
			return field[i].value;
		}
	}
	return -1;
}

/* init combo */
function initComboById(strElementID, initValue){
	return initCombo(document.getElementById(strElementID), initValue);
}
/* init checkbox */
function initCheckboxById(strElementID, initValue){
	return initCheckbox(document.getElementById(strElementID), initValue);
}

/* init radiobutton */
function initRadioByName(strElementID, initValue){
	/* radio는 동일 name에 여러개가 묶이므로 Name으로 조회, id는 unique하니 사용불가 */
	return initRadio(document.getElementsByName(strElementID), initValue);
}

/* init textbox */
function initTextById(strElementID, initValue){
	return initText(document.getElementById(strElementID), initValue);
} 

function setFocusById(strElementID){
	var e = document.getElementById(strElementID);
	if( e != null ){
		e.focus();
	}
}

function objectShowById(strElementID, bShow){
	objectShow(document.getElementById(strElementID), bShow);
}

function objectDisableById(strElementID, bDisable){
	objectDisable(document.getElementById(strElementID), bDisable);
}

function getComboSelectedValue(field){
	if( field != null ){
		return field[field.selectedIndex].value;
	}else{
		return "";
	}
}

function getComboSelectedValueById(strElementID){
	var e = document.getElementById(strElementID);
	return getComboSelectedValue( e );
}

function getRadioSelectedValueByName(strElementName){
	var e = document.getElementsByName(strElementName);
	return getRadioSelectedValue( e );
}
/* ==================================================
	Data 검증 
   ================================================== */
/* data : value type */   
function isEmpty( data ){
	if( data == null || data == "" ) return true;
	return false;
}

function isDigit(data) {
	var string = "1234567890.";
	for( var i=0;i<data.length;i++){
		if (string.indexOf(data.charAt(i))==-1){
			return false;
		}
	}
	return true;
}


/* data : value type */   
function isHex( data ){
	var string = "0123456789ABCDEF";
	for( var i=0;i<data.length;i++){
		if( string.indexOf( data.charAt(i).toUpperCase() ) == -1 ){
			return false;
		}
	}
	return true;
}

/* data : value type */ 
function isIpAddress(ipaddr){
	// 0~3 : ipaddress, 4 - netmask (optional)
	var re = /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}[/\d{1,2}]?/;
    
	if(re.test(ipaddr) == true){
		var parts = ipaddr.split(/\.|\//);
		if( parts.length > 4 ){
			return false;
		}
		/* check part range */
		for(var i=0; i<parts.length; i++){
			if (parseInt((parts[i]),10) > 255){
				return false;
			}
		}
		return true;
	} else {
		return false;
	}
} 

/* data : value type */ 
function isMacAddress(mac){
    var re = /^\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}$/;
    
    if(re.test(mac) == true){  
		var string = "0123456789ABCDEF:";
        for( var i=0;i<mac.length;i++){
			if( string.indexOf( mac.charAt(i).toUpperCase() ) == -1 ){
				return false;
			}
		}
	}else{
		return false;
	}
	return true;
}

function isKorean(str){
	var regexp = /[ㄱ-힣]/g;
	return regexp.test( str );
}

function checkKoreanTextFormArray(arrTextForm){
	var ret = true;
	var e;
	var arrSize = arrTextForm.length;
	for( var i = 0; i < arrSize; i++ ){
		e = document.getElementById(arrTextForm[i]);
		if( e != null ){
			if( isKorean( e.value ) ){
				e.focus();
				ret = false;
				break;
			}
		}
	}
	return ret;
}


/*
 * range check
 *	1 	: success
 *	0 	: obj is null
 *	-1	: empty
 *	-2	: failed
 */
function validateRange(obj, base, min, max, bFocus){
	var nRet = 0;
	var nValue = 0;
	
	if( obj == null )	nRet = 0;
	else if( isEmpty(obj.value) == true )	nRet = -1;
	else{
		nValue = parseInt(obj.value, base);
		if( min <= nValue && nValue <= max ){
			nRet = 1;
		}else{
			nRet = -2;
		}
	}
	
	if( bFocus && nRet <= -1 ){
		obj.focus();
	}
	return nRet;
}

function validateRangeById(strElementID, base, min, max, bFocus){
	var ret = validateRange(document.getElementById(strElementID), base, min, max, bFocus);
	return ret;
}

// 한글 length check
function getByteLength(str){
	return(str.length+(escape(str)+"%u").match(/%u/g).length-1);
}

/* 
	HTTP Request Define
*/
function httpRequest(url, content, handler, handlerError){
	var xmlHttpRequest;
	if (window.XMLHttpRequest) { // Mozilla, Safari,...
		xmlHttpRequest = new XMLHttpRequest();
		if (xmlHttpRequest.overrideMimeType) {
			xmlHttpRequest.overrideMimeType('text/xml');
		}
	} else if (window.ActiveXObject) { // IE
		try {
			xmlHttpRequest = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try {
				xmlHttpRequest = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e) {}
		}
	}
	
	if (!xmlHttpRequest) {
		alert('Giving up :( Cannot create an XMLHTTP instance');
		return false;
	}
	if( xmlHttpRequest ){
		xmlHttpRequest.onreadystatechange = function(){
			//alert("requestHandler:" + xmlHttpRequest);
			if( xmlHttpRequest != null ){
				if( xmlHttpRequest.readyState == 4 ){
					if( xmlHttpRequest.status == 200 ){
						//사용자 데이터 처리
						handler(xmlHttpRequest.responseText);
					} else {
						if( handlerError != null ){
							handlerError(xmlHttpRequest.status);
						}else{
							alert('There was a problem with the request.');
						}
					}
				}
			}else{
				alert('XMLHttpRequest is not created');
			}
		}
		
		xmlHttpRequest.open('POST', url, true);
		xmlHttpRequest.send(content);
	}
	
	return true;
}

/* 
	HTTP Request Define
*/
/*
function xmlhttpRequest(reqMethod, url, content, handler, user, password, arrReqHeader, splitter){
	var xmlHttpRequest;
	if (window.XMLHttpRequest) { // Mozilla, Safari,...
		xmlHttpRequest = new XMLHttpRequest();
		if (xmlHttpRequest.overrideMimeType) {
			xmlHttpRequest.overrideMimeType('text/xml');
		}
	} else if (window.ActiveXObject) { // IE
		try {
			xmlHttpRequest = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try {
				xmlHttpRequest = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e) {}
		}
	}
	
	if (!xmlHttpRequest) {
		alert('Giving up :( Cannot create an XMLHTTP instance');
		return false;
	}
	if( xmlHttpRequest ){
		xmlHttpRequest.onreadystatechange = function(){
			//alert("requestHandler:" + xmlHttpRequest);
			if( xmlHttpRequest != null ){
				if( xmlHttpRequest.readyState == 4 ){
					if( xmlHttpRequest.status == 200 ){
						//사용자 데이터 처리
						handler(1, xmlHttpRequest.responseText, xmlHttpRequest.status);
					} else {
						handler(0, "", xmlHttpRequest.status);
					}
				}
			}else{
				alert('XMLHttpRequest is not created');
			}
		}
		
		xmlHttpRequest.open(reqMethod, url, true, user, password);
		if( arrReqHeader != null ){
			for( var i = 0; i < arrReqHeader.length; i++ ){
				var pair = arrReqHeader[i].split(splitter);
				if( pair.length == 2 ){
					xmlHttpRequest.setRequestHeader(pair[0], pair[1]);
				}
			}
		}
		xmlHttpRequest.send(content);
	}
	return true;
}
*/

/* 
	Cookie
*/
function setCookie(name, value, maxage, path, domain, secure){
	//IE는 max-age 지원하지 않음
	var strExpire ="" ;
	if( maxage ){
		var expires = maxage * 1000;
		
		var today = new Date();
		var expires_date = new Date( today.getTime() + (expires) );
		strExpire = ";expires=" + expires_date.toGMTString();
	}
	var strCookie = name + "=" + escape(value) +
//		( (maxage) ? ";max-age="+maxage : "" ) +
		( (strExpire) ? strExpire : ";expires=Thu, 01-Jan-1970 00:00:01 GMT" ) +
		( ( path ) ? ";path=" + path : "" ) +
		( ( domain ) ? ";domain=" + domain : "" ) +
		( ( secure ) ? ";secure" : "" );
	
	document.cookie = strCookie;
}

function getCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function removeCookie(name) {
	setCookie(name,"", 0, "", "", "");
}

//login session cookie : "MCRSESSIONID"
//cookie format : userIndex_privilege_randomKey_userID
function getUserPrivilege(){
	var cookieSessionID = getCookie("MCRSESSIONID");
	var privilege = 0;

	if( cookieSessionID != null ){
		var part = cookieSessionID.split('_');
		if( part.length == 6 || part.length == 4){		//KT-6, ETC-4
			var strPrivilege = part[1];
			privilege = parseInt(strPrivilege, 10);
		}
	}

	return privilege;
}

//cookie format : userIndex_privilege_randomKey_userID
function getUserID(){
	var cookieSessionID = getCookie("MCRSESSIONID");
	var strID = "";

	if( cookieSessionID != null ){
		var part = cookieSessionID.split('_');
		if( part.length == 6 || part.length == 4 ){		//KT-6, ETC-4
			strID = part[3];
		}
	}

	return strID;
}
// 14.08.20 [LJH] 포트 정보 확인
function getUserPortNum(){
	var cookieSessionID = getCookie("MCRSESSIONID");
	var PortNum = 0;

	if( cookieSessionID != null ){
		var part = cookieSessionID.split('_');
		if( part.length == 6 || part.length == 4){		//KT-6, ETC-4
			var strPortNum = part[4];
			PortNum = parseInt(strPortNum, 10);
		}
	}

	return PortNum;
}

/* ==================================================
	사업자별 요구사항처리
   ================================================== */
/* Vendor별 요구사항
	권한별로 SSID 보일지 말지 결정하는 기능 
*/
/*
	deprecated : isShow_WlanSSIDSecurityByUser 사용할 것
function isShow_WlanSSIDByUser(projectCode, userPrivilege, ssidName){
	var ret = 1;
	
	if( projectCode == '0' && userPrivilege != '7' ){	// skbb 11n & no super user
		if( ssidName == 'SK_VoIP' || ssidName == 'anyway' ){
			ret = 0;
		}
	}else if( projectCode == '32' && userPrivilege != '7' ){	// KTHHP & no super user
		if( ssidName == 'NESPOT' || ssidName == 'QOOKnSHOW' || ssidName == 'KT_SoIP' ){
			ret = 0;
		}
	}else if( projectCode == '2' && userPrivilege != '7' ){		// KTAP & no super user
		if( ssidName == 'NESPOT' || ssidName == 'QOOKnSHOW' || ssidName == 'KT_SoIP' ){
			ret = 0;
		}
	}
	
	return ret;
}
*/

function isShow_WlanSSIDByWPS(projectCode, userPrivilege, ssidName){
	var ret = 1;
/*	
	if( projectCode == '32' ){	// KTHHP
		if( userPrivilege == '7' ){	//superuser
			if( ssidName == 'NESPOT' || ssidName == 'QOOKnSHOW' ){
				ret = 0;
			}
		}else{	
			if( ssidName == 'NESPOT' || ssidName == 'QOOKnSHOW' || ssidName == 'KT_SoIP' ){
				ret = 0;
			}
		}
	}else if( projectCode == '2' ){		// KTAP
		if( userPrivilege == '7' ){	//superuser
			if( ssidName == 'NESPOT' || ssidName == 'QOOKnSHOW' ){
				ret = 0;
			}
		}else{	
			if( ssidName == 'NESPOT' || ssidName == 'QOOKnSHOW' || ssidName == 'KT_SoIP' ){
				ret = 0;
			}
		}
	}
*/	
	return ret;
}

function isShow_WlanSSIDSecurityByUser(projectCode, userPrivilege, userID, ssidName){
	var ret = 1;
/*	
	if( projectCode == '0' ){		// skbb 11n
		if( userPrivilege != '7' ){	// no super user
			if( ssidName == 'SK_VoIP' || ssidName == 'anyway' || ssidName == 'SK_SMART' ){
				ret = 0;
			}
		}else{
			//super user중 root일때 추가사항
			if( userID == 'root' ){
				if( ssidName == 'SK_VoIP' ){
					ret = 0;
				}
			}
		}
	}
*/	
	return ret;
}

/*
 * HJKIM 2010.09.27
 *	SSID, KEY 정보를 HTML Code에 출력시 Space등이 포함된 경우 그대로 출력되지 않으므로
 *	escape charter로 변환함.
 */
function convertSpaceToEscape(string){
	var strConv = "";
/*
	for( var i = 0; i < string.length; i++ ){
		if( string[i] == ' ' ){
			strConv += "&nbsp;";
		}else{
			strConv += (""+string[i]);
		}
	}
*/	
	strConv = string;
	return strConv.replace(/ /g, "&nbsp;");
}

/* ==================================================
	for new web 
   ================================================== */

//	page refresh
function refreshPageSize(){
	changeTable();
}

// button append
// 주의 : div, span은 <div id="div_btn_apply" class="mcr_href_btn"></div> 형태일 것.
//			<div id="div_btn_apply" class="mcr_href_btn"/> 형태로 사용시
//			다음 button 처리시 이상해짐.
function setHREFBtn(strDivId, strBtnType, strFormName, strBtnName, strUserFunc){
	var strName = "";
	var e = document.getElementById(strDivId);
	if( e!= null ){
		if( strBtnType == "SUBMIT" ){
			strName = "<a href='#' onclick='if("+strUserFunc+" == true) document."+strFormName+".submit();return false;'><span id='"+strBtnName+"'>"+strBtnName+"</span></a>";
		}else if( strBtnType == "RESET" ){
			strName = "<a href='#' onclick='window.location.reload();'><span id='"+strBtnName+"'>"+strBtnName+"</span></a>";
		}else{
			strName = "<a href='#' onclick='"+strUserFunc+"'><span id='"+strBtnName+"'></span></a>";
		}
		
		e.innerHTML = strName;
	}
}

/* ==================================================
	for Multiple Wlan
   ================================================== */
   
function generateMultiWlanURL(loc, wanIfIndex, bRedirect, newURL){
	var string;
	if( bRedirect ){
		if( isEmpty(newURL) ){
			string = "/goform/mcr_getWirelessFormRedirect?redirect-url="+ loc.pathname + "&wlanIfIndex="+wanIfIndex;
		}else{
			string = "/goform/mcr_getWirelessFormRedirect?redirect-url="+ newURL + "&wlanIfIndex="+wanIfIndex;
		}
	}else{
		string = newURL + "&wlanIfIndex="+wanIfIndex;
	}
	return string;
}   

/*
 * form POST시 Multiple Wlan 설정관련 정보 전달을 위한 parameter 설정
 *	WlanIfIndex - 현재 선택된 Wlan Interface (physical)
 *	wlanRedirectPage - redirect 용 Page
 *	위 두 파라메터는 각 page에 hidden type의 form element로 정의되어 있어야 한다.
 *
 *	form의 값을 변경하므로 body onload시 또는 그 이후에 호출되어야 함.
 *	optional parameter
 *		newURL - loc.pathname을 그대로 사용하지 않고 다른 page로 redirect 필요한 경우
 *		form - object, 한 page에 여러 form이 있어서 wlanIfIndex, wlanRedirectPage 를 id로 접근할 수 없는 경우
 */   
function setMultiWlanInfo(loc, wlanIfIndex, newURL, form){
	if( isEmpty(form) ){
		initTextById("wlanIfIndex", ''+wlanIfIndex);
		initTextById("wlanRedirectPage", generateMultiWlanURL( loc, wlanIfIndex, true, newURL ) );
	}else{
		form.wlanIfIndex.value = ''+wlanIfIndex;
		form.wlanRedirectPage.value = generateMultiWlanURL( loc, wlanIfIndex, true, newURL );
	}
}

/* 
 * Multi Interface - SSID index 체계를 Array Index 체계로 변경한다.
 *		Array Index			SSIDIndex		
 *			0				0
 *			1				1
 *			...
 *			maxSSID-1		maxSSID-1
 *			maxSSID			100
 *			maxSSID+1		101
 */
function convertMultiSSIDIdxToArrayIndex(nMaxSSIDCount, nSSIDIdx){
	var nMappingIdx = 0;
	if( nSSIDIdx >= 100 ){
		// nMappingIdx = (nSSIDIdx - 100) + nMaxSSIDCount;
		nMappingIdx = (nSSIDIdx - 100) + 5;	//for MSSID - 5
	}else{
		nMappingIdx = nSSIDIdx;
	}
	return nMappingIdx;
}

function mcr_getWlanIfIndex(nPhyIndex, nVapIndex){
	if( nVapIndex < 0 ) nVapIndex = 0;
	return nPhyIndex*100 + nVapIndex;
}

/* ==================================================
	for Progress bar (upgrade)
   ================================================== */

function getRefToDivNest(divID, oDoc)
{
  if( !oDoc ) { oDoc = document; }
  if( document.layers ) {
    if( oDoc.layers[divID] ) { return oDoc.layers[divID]; } else {
    for( var x = 0, y; !y && x < oDoc.layers.length; x++ ) {
        y = getRefToDivNest(divID,oDoc.layers[x].document); }
    return y; } }
  if( document.getElementById ) { return document.getElementById(divID); }
  if( document.all ) { return document.all[divID]; }
  return document[divID];
}

function progressBar( oBt, oBc, oBg, oBa, oWi, oHi, oDr )
{
  MWJ_progBar++; this.id = 'MWJ_progBar' + MWJ_progBar; this.dir = oDr; this.width = oWi; this.height = oHi; this.amt = 0;
  //write the bar as a layer in an ilayer in two tables giving the border
  document.write( '<span id = "progress_div" class = "off" > <table border="0" cellspacing="0" cellpadding="'+oBt+'">'+
    '<tr><td bgcolor="'+oBc+'">'+
        '<table border="0" cellspacing="0" cellpadding="0"><tr><td height="'+oHi+'" width="'+oWi+'" bgcolor="'+oBg+'">' );
  if( document.layers ) {
    document.write( '<ilayer height="'+oHi+'" width="'+oWi+'"><layer bgcolor="'+oBa+'" name="MWJ_progBar'+MWJ_progBar+'"></layer></ilayer>' );
  } else {
    document.write( '<div style="position:relative;top:0px;left:0px;height:'+oHi+'px;width:'+oWi+';">'+
            '<div style="position:absolute;top:0px;left:0px;height:0px;width:0;font-size:1px;background-color:'+oBa+';" id="MWJ_progBar'+MWJ_progBar+'"></div></div>' );
  }
  document.write( '</td></tr></table></td></tr></table></span>\n' );
  this.setBar = resetBar; //doing this inline causes unexpected bugs in early NS4
  this.setCol = setColour;
}
function resetBar( a, b )
{
  //work out the required size and use various methods to enforce it
  this.amt = ( typeof( b ) == 'undefined' ) ? a : b ? ( this.amt + a ) : ( this.amt - a );
  if( isNaN( this.amt ) ) { this.amt = 0; } if( this.amt > 1 ) { this.amt = 1; } if( this.amt < 0 ) { this.amt = 0; }
  var theWidth = Math.round( this.width * ( ( this.dir % 2 ) ? this.amt : 1 ) );
  var theHeight = Math.round( this.height * ( ( this.dir % 2 ) ? 1 : this.amt ) );
  var theDiv = getRefToDivNest( this.id ); if( !theDiv ) { window.status = 'Progress: ' + Math.round( 100 * this.amt ) + '%'; return; }
  if( theDiv.style ) { theDiv = theDiv.style; theDiv.clip = 'rect(0px '+theWidth+'px '+theHeight+'px 0px)'; }
  var oPix = document.childNodes ? 'px' : 0;
  theDiv.width = theWidth + oPix; theDiv.pixelWidth = theWidth; theDiv.height = theHeight + oPix; theDiv.pixelHeight = theHeight;
  if( theDiv.resizeTo ) { theDiv.resizeTo( theWidth, theHeight ); }
  theDiv.left = ( ( this.dir != 3 ) ? 0 : this.width - theWidth ) + oPix; theDiv.top = ( ( this.dir != 4 ) ? 0 : this.height - theHeight )+   oPix;
}

function setColour( a )
{
  //change all the different colour styles
  var theDiv = getRefToDivNest( this.id ); if( theDiv.style ) { theDiv = theDiv.style; }
  theDiv.bgColor = a; theDiv.backgroundColor = a; theDiv.background = a;
}


/*******************************************************************************
                     Domain Name Vaidation 
*******************************************************************************/    
function CheckDomain(nname)
{
var arr = new Array(
'.com','.net','.org','.biz','.coop','.info','.museum','.name',
'.pro','.edu','.gov','.int','.mil','.ac','.ad','.ae','.af','.ag',
'.ai','.al','.am','.an','.ao','.aq','.ar','.as','.at','.au','.aw',
'.az','.ba','.bb','.bd','.be','.bf','.bg','.bh','.bi','.bj','.bm',
'.bn','.bo','.br','.bs','.bt','.bv','.bw','.by','.bz','.ca','.cc',
'.cd','.cf','.cg','.ch','.ci','.ck','.cl','.cm','.cn','.co','.cr',
'.cu','.cv','.cx','.cy','.cz','.de','.dj','.dk','.dm','.do','.dz',
'.ec','.ee','.eg','.eh','.er','.es','.et','.fi','.fj','.fk','.fm',
'.fo','.fr','.ga','.gd','.ge','.gf','.gg','.gh','.gi','.gl','.gm',
'.gn','.gp','.gq','.gr','.gs','.gt','.gu','.gv','.gy','.hk','.hm',
'.hn','.hr','.ht','.hu','.id','.ie','.il','.im','.in','.io','.iq',
'.ir','.is','.it','.je','.jm','.jo','.jp','.ke','.kg','.kh','.ki',
'.km','.kn','.kp','.kr','.kw','.ky','.kz','.la','.lb','.lc','.li',
'.lk','.lr','.ls','.lt','.lu','.lv','.ly','.ma','.mc','.md','.mg',
'.mh','.mk','.ml','.mm','.mn','.mo','.mp','.mq','.mr','.ms','.mt',
'.mu','.mv','.mw','.mx','.my','.mz','.na','.nc','.ne','.nf','.ng',
'.ni','.nl','.no','.np','.nr','.nu','.nz','.om','.pa','.pe','.pf',
'.pg','.ph','.pk','.pl','.pm','.pn','.pr','.ps','.pt','.pw','.py',
'.qa','.re','.ro','.rw','.ru','.sa','.sb','.sc','.sd','.se','.sg',
'.sh','.si','.sj','.sk','.sl','.sm','.sn','.so','.sr','.st','.sv',
'.sy','.sz','.tc','.td','.tf','.tg','.th','.tj','.tk','.tm','.tn',
'.to','.tp','.tr','.tt','.tv','.tw','.tz','.ua','.ug','.uk','.um',
'.us','.uy','.uz','.va','.vc','.ve','.vg','.vi','.vn','.vu','.ws',
'.wf','.ye','.yt','.yu','.za','.zm','.zw');

var mai = nname;
var val = true;

var dot = mai.lastIndexOf(".");
var dname = mai.substring(0,dot);
var ext = mai.substring(dot,mai.length);
var check = /\.\./;

	if ( check.test(dname) ) { 
	   //alert("domain은 ..이 올수 없습니다.");
	   return false;
	}

	if(dot>2 && dot<57)
	{
		for(var i=0; i<arr.length; i++)
		{
			if(ext == arr[i]) {
				val = true;
				break;
			}
			else {
				val = false;
			}
		}

		if(val == false) {
			//alert("domain의 확장자 "+ext+" 가 잘못되었습니다");
			return false;
		}
		else {
			for(var j=0; j<dname.length; j++)
			{
				var dh = dname.charAt(j);
				var hh = dh.charCodeAt(0);

				if((hh > 47 && hh<59) || (hh > 64 && hh<91) || (hh > 96 && hh<123) || hh==45 || hh==46)
				{
					if((j==0 || j==dname.length-1) && (hh == 45 || hh == 46) ){
						//alert("도메인명의 시작 끝에는 '-', '.'는 올수가 없습니다");
						return false;
					}
				}
				else {
					//alert("도메인명에 특수문자가 포함되어 있습니다");
					return false;
				}
			}
		}
	}
	else {
		//alert("도메인명이 너무 짧거나 깁니다");
		return false;
	}

	return true;
}

function CheckInternetAddress(obj, checkHangul)
{
	var addr = obj.value;

	if ( addr.lenth == 0 ) {
		return false;
	}

	if ( checkHangul == 1 && isKorean(obj.value) == true ) {
		return false;
	}

	if ( isIpAddress(addr) == false && CheckDomain(addr)== false ) {
		return false;
	}

	return true;
} 
