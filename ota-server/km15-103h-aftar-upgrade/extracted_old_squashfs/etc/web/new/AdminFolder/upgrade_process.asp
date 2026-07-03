<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
	"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko-KR">
	
<head>
<title>Firmware Upgrade Process</title>

<link href="/style/style.css" rel="stylesheet" type="text/css">

<%include('new/metatag.asp');%>
<script language="javascript" type="text/javascript" src="/lang/b28n.js" ></script>
<script language="javascript" type="text/javascript" src="/script/mcr_common.js" ></script>
<script language="javascript" type="text/javascript">

Butterlate.setTextDomain("admin");

var MWJ_progBar = 0;
var time=0;
var delay_time=1000;
var timer=null;
var time_count=0;
var error_count=0;
var percent_ck=0;

var requestSync= 0; 

function progress(){
  if (time < 1)
    time = time + 0.060;
	
  if(time >=1) time=1; // 진행률 100%초과되는 현상 수정.

  timer = setTimeout('progress()',delay_time);
  myProgBar.setBar(time);

  percent_ck= Math.round(time * 100);

  if(document.all) {                 
        document.all.percent_num.innerHTML = percent_ck + "%";
  }
  else if(document.getElementById) { 
        document.getElementById("percent_num").innerHTML = percent_ck + "%";
  }

  if( requestSync == 0 ){
    httpRequest("/goform/mcr_getUpgradeStatus", "n/a", processHttpResponse, processHttpError);
    requestSync = 1;
  }


}

function pagereload() {
  window.location.href = "http://"+window.location.host;
}

function processHttpError(status){
	clearTimeout( timer );
	alert("업그레이드로 리부팅 중이거나, 웹과의 접속이 끊어졌습니다. 업그레이드 중이면 잠시 기다려주시고, 그렇지 않으면 AP장비의 포트상태나 설정상태를 확인해 주세요");
    timer = setTimeout('pagereload()',60000);
}


function processHttpResponse(strResponse){

	if (time_count < 2){
		init_val = strResponse;
		time_count++;
   		requestSync = 0;
		return ;
	}

	if( strResponse == "0" ){
		alert(_("upgrade status change applied"));
	}else if( strResponse == "1" ){
		window.location.href = "http://"+window.location.host+"/new/upgrade_success.asp";
	}else if( strResponse == "2" ){
		alert(_("upgrade filewritefail"));
	}else if( strResponse == "3" ){
		alert(_("upgrade fileinforfail"));
	}else if( strResponse == "4" ){
		alert(_("upgrade flashreadfail"));
	}else if(strResponse == "5" ){
		alert(_("upgrade flashwritefail"));
	}else if( strResponse == "7" ){
		alert(_("upgrade tftppkagefail"));
	}else if( strResponse == "8" ){
		alert(_("image already latest version"));
	}else if( strResponse == "18" ){
		alert(_("upgrade wait current call finish"));
	}else if( strResponse == "19" ){
		alert(_("upgrade handset progress"));

	}else if( strResponse == "11" ){
		alert("S/W 업데이트 실패(업그레이드 서버 정보 없음) : 업그레이드 서버주소를 확인해 주세요");
	}else if( strResponse == "12" ){
		alert("S/W 업데이트 실패(업그레이드 서버 연결 실패) : 업그레이드 서버 연결이 되지 않았습니다");
	}else if( strResponse == "13" ){
		alert("S/W 업데이트 실패(업그레이드 정보 수신 실패) : 서버로부터 업그레이드에 필요한 정보 수신을 못했습니다");
	}else if( strResponse == "14" ){
		alert("S/W 업데이트 실패(업그레이드 정보 오류) : 업그레이드에 필요한 정보가 적합하지 않습니다");
	}else if( strResponse == "16" ){
		alert("S/W 업데이트 실패(AP 시스템 오류) : AP장비에 이상이 있습니다. 재시동후에 다시 시도해 주세요");
	}else if( strResponse == "17" ){
		alert("S/W 업데이트 실패(업그레이드 정보 수신 실패) : 업그레이드 정보를 잘못 가져왔습니다");
	}else if( strResponse == "20" ){
		alert("S/W 업데이트 실패(파일서버 로그인 실패) : 업그레이드 파일서버 계정이 맞지 않습니다");
	}else if( strResponse == "21" ){
		alert("S/W 업데이트 실패(파일서버 연결 실패) : 업그레이드 파일서버에 연결할 수 없습니다");
	}else if( strResponse == "22" ){
		alert("S/W 업데이트 실패(파일서버 다운로드 중 실패) : 업그레이드 파일 수신을 완료하지 못했습니다");
	}else if( strResponse == "23" ){
		alert("요청한 파일이 없음 : 업그레이드 대상 파일이 없습니다");
	}else if( strResponse == "24" ){
		alert("S/W 업데이트 실패(파일서버 오류) : 업그레이드 서버에서 해당파일이 존재하지 않습니다");
	}else if( strResponse == "25" ){
		alert("S/W 업데이트 실패(시스템 오류) : AP장비에 이상이 있습니다. 재시동후에 다시 시도해 주세요");
	}else if( strResponse == "26" ){
		alert("S/W 업데이트 실패(업그레이드 취소) : AP장비에서 중단 요청이 발생했습니다");
	}else if( strResponse == "27" ){
		alert("S/W 업데이트 실패(파일 무결성 오류) : 업그레이드 서버에서 받아 온 이미지 파일이 올바르지 않습니다. 다시 시도해서 동일한 오류가 발생하면, 업그레이드할 이미지 파일이 없거나 업그레이드 서버에서 작업 중이므로 기다려 주세요");
	}else{ // 기타 일반 오류
		strResponse = 6;
	}

	time_count++;
   	requestSync = 0;
	if( strResponse != "1" && strResponse != "6"){
		requestSync = 1;
		clearTimeout( timer );
		timer = null;

		self.close();
	}

  if( time_count > 180 )	
  {
	clearTimeout( timer );
	timer = null;
	alert(_("upgrade failtimeout"));
	self.close();
  }
}

function showPortStatus()
{
    var str = "<% mcr_getPortStatus(); %>";
    var all = new Array();

    if(str == "-1"){
        document.write("not support");
        return ;
    }

    all = str.split(",");
    if(all[0] != "1"){
        alert("WAN 포트상태를 확인해 주세요.외부망에 접속할 수 없습니다");
    }
}
function initTranslation()
{
    var e = document.getElementById("upgTitle");
    e.innerHTML = _("upgrade title");

}

function initValue(){
	initTranslation();
	progress();
}

function noEvent() {
    if (event.keyCode == 116) {
        event.keyCode= 2;
        return false;
    }
    else if(event.ctrlKey && (event.keyCode==78 || event.keyCode == 82))
    {
        return false;
    }
}
document.onkeydown = noEvent; 

</script>
</head>

<body leftmargin="20" oncontextmenu="return false" onselectstart="return false" onLoad="initValue()" >

<table width=90% height=150>
	<tr>
		<td> <h3 id="upgTitle"></h3> </td>
	</tr>
	<tr> 
		<td class="PD4-1" colspan="2"></td>
	</tr>
	<tr> 
		<td class="font1-1">잠시 기다려 주세요. 업그레이드중입니다.</td>
	</tr>
	<tr>
		<td style="padding-left:10px;" >
			<div>
			<script type="text/javascript" language="javascript">
				var myProgBar = new progressBar(
            		1,         
            		'#000000', 
            		'#ffffff', 
            		'#ed1c24', 
            		400,       
            		15,        
            		1          
        		);
			</script>
			</div>
		</td>
		<td id="percent_num">
                </td>
	</tr>
	<tr> 
		<td class="font1-1" >※그래프는 AP장비로부터 업그레이드 상태를 보고 받고 있음을 의미합니다.
		</td>
	</tr>
</table>
<br>

</body>
</html>
