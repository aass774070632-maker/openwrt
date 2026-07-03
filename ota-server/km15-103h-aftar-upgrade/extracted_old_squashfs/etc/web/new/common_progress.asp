<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
	"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko-KR">
	
<head>
<title>Progress</title>

<link rel="stylesheet" type="text/css" href="/style/normal_ws.css" />
<style>

body{
	width:300px;
	font-size: 9pt;
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

</html> 
