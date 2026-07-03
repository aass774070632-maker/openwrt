/* Menu Focus */
function na_restore_img_src(name, nsdoc)
{
  if (name == ''){
    return;
  }
 
  var img = eval((navigator.appName.indexOf('Netscape', 0) != -1) ? nsdoc+'.'+name : 'document.all.'+name);
 
  if (img && img.altsrc) {
    img.src    = img.altsrc;
    img.altsrc = null;
  }
}
 
function na_preload_img()
{
  var img_list = na_preload_img.arguments;
  if (document.preloadlist == null)
    document.preloadlist = new Array();
  var top = document.preloadlist.length;
  for (var i=0; i < img_list.length; i++) {
    document.preloadlist[top+i]     = new Image;
    document.preloadlist[top+i].src = img_list[i+1];
  }
}
 
function na_change_img_src(name, nsdoc, rpath, preload)
{
  var img = eval((navigator.appName.indexOf('Netscape', 0) != -1) ? nsdoc+'.'+name : 'document.all.'+name);
  if (name == '')
    return;
  if (img) {
    img.altsrc = img.src;
    img.src    = rpath;
  }
}
 
/*
* changeTable 은 삭제되고 changeTableUser 로 대체됩니다.
* function changeTable() {
* 	parent.document.getElementById("main").style.height=document.body.scrollHeight;
* }
*/
function changeTableUser() {
        parent.document.getElementById("main").style.height=document.body.scrollHeight;
}
 
/* sleep func */
function sleep(ms) {
        var cur = new Date();
        var tgt = cur.getTime() + (ms)
        while (true) {
                cur = new Date();
                if (cur.getTime() > tgt) return;
        }
}


function atoi(str, num) {

	i = 1;
	if (num != 1) {
		while (i != num && str.length != 0) {
			if (str.charAt(0) == '.') {
				i++;
			}
			str = str.substring(1);
		}
		if (i != num)
			return -1;
	}

	for (i=0; i<str.length; i++) {
		if (str.charAt(i) == '.') {
			str = str.substring(0, i);
			break;
		}
	}
	if (str.length == 0)
		return -1;
	return parseInt(str, 10);
}

function checkRange(str, num, min, max) {
	d = atoi(str, num);
	if (d > max || d < min)
		return false;
	return true;
}

function isAllNum(str) {
	for (var i=0; i<str.length; i++) {
		if ((str.charAt(i) >= '0' && str.charAt(i) <= '9') || (str.charAt(i) == '.' ))
			continue;
		return 0;
	}
	return 1;
}

function checkIpAddr(field, ismask) {
	if (isAllNum(field.value) == 0) {
		alert("입력오류입니다.[0-9] 숫자를 입력하세요.");
		field.value = field.defaultValue;
		field.focus();
		return false;
	}

	if (ismask) {
		if ((!checkRange(field.value, 1, 0, 256)) ||
				(!checkRange(field.value, 2, 0, 256)) ||
				(!checkRange(field.value, 3, 0, 256)) ||
				(!checkRange(field.value, 4, 0, 256)))
		{
			alert("입력된 IP 오류입니다.");
			field.value = field.defaultValue;
			field.focus();
			return false;
		}
	}
	else {
		if ((!checkRange(field.value, 1, 0, 255)) ||
				(!checkRange(field.value, 2, 0, 255)) ||
				(!checkRange(field.value, 3, 0, 255)) ||
				(!checkRange(field.value, 4, 1, 254)))
		{
			alert("입력된 IP 오류입니다.");
			field.value = field.defaultValue;
			field.focus();
			return false;
		}
	}
	return true;
}

function checkPort(field, iszero) {
	if (isAllNum(field.value) == 0) {
		alert("입력오류입니다.[0-9] 숫자를 입력하세요.");
		field.value = field.defaultValue;
		field.focus();
		return false;
	}

	d1 = atoi(field.value, 1);
	if(iszero) {
		if(d1 > 65535 || d1 < 0){
			alert("입력오류입니다.입력 값이 범위를 초과했습니다.(1~65535)");
			field.value = field.defaultValue;
			field.focus();
			return false;
		}
	}
	else {
		if(d1 > 65535 || d1 < 1){
			alert("입력오류입니다.입력 값이 범위를 초과했습니다.(1~65535)");
			field.value = field.defaultValue;
			field.focus();
			return false;
		}
	}
	return true;
}

/* higherd 신규로 창 띄우기 : 새창의 크기(cw,ch), 새 창 주소(url) , 창제목(wname) */
function New_WindowOpen(cw, ch, url, wname) {
	// 스크린의 크기
	sw=screen.availWidth;
	sh=screen.availHeight;

	//열 창의 포지션
	px=(sw-cw)/2;
	py=(sh-ch)/2;

	var NewWin=window.open(url, wname, 'left='+px+',top='+py+',width='+cw+',height='+ch+',toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no');
}

/* higherd PC에서 업로드할 파일크기
 * 	안타깝게도, IE7 이상이나 FireFox3 이상에서는 안 먹힌다고 합니다. 
 *	dynsrc 가 IE6에서만 쓰는 놈이라네요.
 *
 *	filePath : FileName.value값
 */
function getFileSize(filePath)    
{
	var len = 0;
                        
	if ( navigator.appName.indexOf("Netscape") != -1) {
		try {
			netscape.security.PrivilegeManager.enablePrivilege('UniversalXPConnect');
		} catch(e) {
			alert("signed.applets.codebase_principal_support를 설정해주세요!\n"+e);
			return -1;
		}
		try {
			var file = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
			file.initWithPath ( filePath );
			
			len = file.fileSize;
		} catch(e) {
			alert("에러 발생:"+e);
		}
	} else if (navigator.appName.indexOf('Microsoft') != -1) {
		var img = new Image();
		img.dynsrc = filePath;
		len = img.fileSize;
	}
	return len;
}

function Chk_InputFile(f_name)
{
	if(f_name == ""){
		alert("파일을 지정하세요");
		return false;
	}

	return true;
}

function changeMouseOver(clickId){
	var changeImage;
	changeImage = (document.getElementById(clickId).src).replace('default', 'mouse');

	document.getElementById(clickId).src = changeImage;
}

function changeMouseOut(clickId)
{
	var changeImage;
	changeImage = (document.getElementById(clickId).src).replace('mouse', 'default');

	document.getElementById(clickId).src = changeImage;
}
