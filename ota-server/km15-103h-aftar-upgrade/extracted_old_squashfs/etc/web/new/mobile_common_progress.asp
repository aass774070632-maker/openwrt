<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
	"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko-KR">
	
<head>
<title>Progress</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language='JavaScript' type='text/javascript' src='/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>'></script>


<style>

body{
	width:300px;
	font-size: 10pt;
	font-family: Arial, Helvetica, sans-serif;
	margin-left: 0px;
}

</style>

<script language="javascript" type="text/javascript" src="/script/mcr_common.js" ></script>
<script language="javascript" type="text/javascript" src="/script/jquery.js" ></script>
<script language="javascript" type="text/javascript">

//---------------------------------------------------

var MWJ_progBar = 0;

function mcr_setProgressBar(ratio){
	uiProgress.setBar(ratio);
}

function mcr_setMessage(message){
	$('#uiProgressMessage').text(message);
}

function mcr_refreshPage(){
	nHeight = 100;
	
	if( parent.document.getElementById("admin_progress") != null ){
		parent.document.getElementById("admin_progress").style.height=nHeight;
	}
}

function initValue(){
	mcr_refreshPage();
}

</script>
</head>
<div data-role="page" data-theme="d">
        <div data-role="header" data-theme="d">
                <table width="100%">
                        <tr>
                                <td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
                                </td>
                                <td align="center">
                                        <img src="/images/mobile/m_logo_GiGA.png?version=<% mcr_getWebVersion(); %>" />
                                </td>
                                <td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
                                </td>
                        </tr>
                </table>
        </div>
        <div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
                <table width="100%">
                        <tr>
                                <td>
                                        <img src="/images/kt_logo.png?version=<% mcr_getWebVersion(); %>" style="width: 24px;">
                                </td>
                                <td align="left" width="90%" style="font-weight:bold;">
                                 설정 상태
                                </td>
                        </tr>
                </table>
        </div>
        <hr color="f62530" style="border-width: 2px 0 0 0; margin:0px" width="100%">
        <div>
                <table>
                        <tr height="5"></tr>
                </table>
        </div>

	<div style="margin-left:10px">
		<body oncontextmenu="return false" onselectstart="return false" onLoad="initValue()" bgcolor="#F1F1F1">
			<p>
			<p>
			<label id="uiProgressMessage"></label>
			<p>
			<script type="text/javascript" language="javascript">
				var uiProgress = new progressBar(
            			1,         
            			'#000000', 
            			'#ffffff', 
            			'#043db2',
            			300,       
            			15,        
            			1          
        			);
			</script>
		</body>
	</div>
</div>
</html> 
