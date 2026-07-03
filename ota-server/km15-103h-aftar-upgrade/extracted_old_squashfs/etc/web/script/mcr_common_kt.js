/* ==================================================
	for Multiple Wlan
   ================================================== */
   
function generateMultiWlanURL_KT(loc, wanIfIndex, bRedirect, newURL){
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
function setMultiWlanInfo_KT(loc, wlanIfIndex, newURL, form){
	if( isEmpty(form) ){
		initTextById("wlanIfIndex", ''+wlanIfIndex);
		initTextById("wlanRedirectPage", generateMultiWlanURL_KT( loc, wlanIfIndex, true, newURL ) );
	}else{
		form.wlanIfIndex.value = ''+wlanIfIndex;
		form.wlanRedirectPage.value = generateMultiWlanURL_KT( loc, wlanIfIndex, true, newURL );
	}
}

//-------------------------------------------------------
// Wireless Menu Event 처리
//-------------------------------------------------------
function WirelessSetFormElement(doc, name, value){
	//동일한 id의 tag가 있는지 확인한다.(중복검사)
	var e = doc.getElementById(name);
	if( e == null ){
		//input tag 추가
		var input = doc.createElement("input");
		input.type = 'hidden';
		input.id = name;
		input.name = name;
		input.value = ( (value == null) ? "" : value );
		doc.form.appendChild( input );
		input = null;
	}else{
		e.value = ( (value == null) ? "" : value );
	}
}

function WirelessChangePage(menu, pageUrl, wlanIfIndex){
	//parameter 처리를 위한 input tag 추가
	WirelessSetFormElement(parent.document, "redirect-url", "/new/"+pageUrl);
	WirelessSetFormElement(parent.document, "wlanIfIndex", wlanIfIndex);
	
	menu.changeSubMenu3SubBtn("/goform/mcr_getWirelessFormRedirect");
}
