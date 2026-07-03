<html>
<head>
<%include('new/metatag.asp');%>
<title>WMM 정책 설정</title>
<%include('new/script.asp');%>

<link href="/style/style.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
a { font-style:normal; font-weight:normal; text-decoration:none; }
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
	background-color: #ffffff;
}
-->
</style>

<script language="javascript" type="text/javascript">

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';





var maxSSID;

var arrData = new Array();




 
function validateOnSubmit_WMM(){
	var idx;
	var arrRange15Form = new Array(
		"ui_be_cwmin_ap", "ui_bk_cwmin_ap", "ui_vi_cwmin_ap", "ui_vo_cwmin_ap", 
		"ui_be_cwmax_ap", "ui_bk_cwmax_ap", "ui_vi_cwmax_ap", "ui_vo_cwmax_ap", 
		"be_aifs_ap", "bk_aifs_ap", "vi_aifs_ap", "vo_aifs_ap",
		
		"ui_be_cwmin_sta", "ui_bk_cwmin_sta", "ui_vi_cwmin_sta", "ui_vo_cwmin_sta", 
		"ui_be_cwmax_sta", "ui_bk_cwmax_sta", "ui_vi_cwmax_sta", "ui_vo_cwmax_sta", 
		"be_aifs_sta", "bk_aifs_sta", "vi_aifs_sta", "vo_aifs_sta"
	);
	
	var arrRange8192Form = new Array(
		"be_txop_ap", "bk_txop_ap", "vi_txop_ap", "vo_txop_ap",
		"be_txop_sta", "bk_txop_sta", "vi_txop_sta", "vo_txop_sta"
	);
	
	for( idx in arrRange15Form ){
		if( validateRangeById( arrRange15Form[idx], 10, 0, 15, true) != 1 ){
			alert("Range : 0~15");
			return false;
		}
	}
	for( idx in arrRange8192Form ){
		if( validateRangeById( arrRange8192Form[idx], 10, 0, 8192, true) != 1 ){
			alert("Range : 0~8192");
			return false;
		}
	}
	
	convertECw2WMM("be_cwmin_ap");
	convertECw2WMM("be_cwmax_ap");
	convertECw2WMM("bk_cwmin_ap");
	convertECw2WMM("bk_cwmax_ap");
	convertECw2WMM("vi_cwmin_ap");
	convertECw2WMM("vi_cwmax_ap");
	convertECw2WMM("vo_cwmin_ap");
	convertECw2WMM("vo_cwmax_ap");

	convertECw2WMM("be_cwmin_sta");
	convertECw2WMM("be_cwmax_sta");
	convertECw2WMM("bk_cwmin_sta");
	convertECw2WMM("bk_cwmax_sta");
	convertECw2WMM("vi_cwmin_sta");
	convertECw2WMM("vi_cwmax_sta");
	convertECw2WMM("vo_cwmin_sta");
	convertECw2WMM("vo_cwmax_sta");
	
	return true;
}



function initForms(flag, defaultSSIDIndex){
	if( flag == 0 ){
		var gProjectCode;
		gProjectCode = '<% mcr_getCfgCommon("SysConfDb_ProjectCode"); %>';
		if( gProjectCode == '32' ){
			$("#viewAPWMM").show();
			$("#viewAPWMM2").show();
		}else{
			$("#viewAPWMM").hide();
			$("#viewAPWMM2").hide();
		}
		
		$("#wlanUIMenu02").removeClass("menu3rdNormal").addClass("menu3rdSelect");
			
		httpRequest("/goform/mcr_getWirelessWMM?wlanIfIndex="+gWlanIfIndex, "n/a", processHttpResponse);
	}else if( flag == 1 ){
		updateFormValue(0, defaultSSIDIndex);
	}else if( flag == -1 ){
		updateFormValue(1, defaultSSIDIndex);
	}
}


function updateFormValue(useDefault, defaultSSIDIndex){
	var be_cwmin_ap, be_cwmax_ap, be_aifs_ap, be_txop_ap, be_noack_ap, be_acm_ap;
	var bk_cwmin_ap, bk_cwmax_ap, bk_aifs_ap, bk_txop_ap, bk_noack_ap, bk_acm_ap;
	var vi_cwmin_ap, vi_cwmax_ap, vi_aifs_ap, vi_txop_ap, vi_noack_ap, vi_acm_ap;
	var vo_cwmin_ap, vo_cwmax_ap, vo_aifs_ap, vo_txop_ap, vo_noack_ap, vo_acm_ap;

	var be_cwmin_sta, be_cwmax_sta, be_aifs_sta, be_txop_sta, be_acm_sta;
	var bk_cwmin_sta, bk_cwmax_sta, bk_aifs_sta, bk_txop_sta, bk_acm_sta;
	var vi_cwmin_sta, vi_cwmax_sta, vi_aifs_sta, vi_txop_sta, vi_acm_sta;
	var vo_cwmin_sta, vo_cwmax_sta, vo_aifs_sta, vo_txop_sta, vo_acm_sta;

	var priority_0, priority_1, priority_2, priority_3, priority_4, priority_5, priority_6, priority_7;

	if( defaultSSIDIndex == -1 ) defaultSSIDIndex = 0;

	var idx = 0;
	for( var i = 0; i < arrData.length; i++ ){
		if( arrData[i][0] == defaultSSIDIndex ){
			idx = i;
			break;
		}
	}

	if( useDefault == 0 ){
		$("#wmmActivity").val( arrData[idx][2] );
		
		priority_0 = arrData[idx][3];
		priority_1 = arrData[idx][4];
		priority_2 = arrData[idx][5];
		priority_3 = arrData[idx][6];
		priority_4 = arrData[idx][7];
		priority_5 = arrData[idx][8];
		priority_6 = arrData[idx][9];
		priority_7 = arrData[idx][10];
		
		be_cwmin_ap = arrData[idx][11];	be_cwmin_sta = arrData[idx][35];
		be_cwmax_ap = arrData[idx][12];	be_cwmax_sta = arrData[idx][36];
		be_aifs_ap = arrData[idx][13]; 	be_aifs_sta = arrData[idx][37];
		be_txop_ap = arrData[idx][14];	be_txop_sta = arrData[idx][38];
		be_acm_ap = arrData[idx][15];	be_acm_sta = arrData[idx][39];
		be_noack_ap = arrData[idx][16];

		bk_cwmin_ap = arrData[idx][17];	bk_cwmin_sta = arrData[idx][40];
		bk_cwmax_ap = arrData[idx][18];	bk_cwmax_sta = arrData[idx][41];
		bk_aifs_ap = arrData[idx][19];	bk_aifs_sta = arrData[idx][42];
		bk_txop_ap = arrData[idx][20];	bk_txop_sta = arrData[idx][43];
		bk_acm_ap = arrData[idx][21];	bk_acm_sta = arrData[idx][44];
		bk_noack_ap = arrData[idx][22];

		vi_cwmin_ap = arrData[idx][23];	vi_cwmin_sta = arrData[idx][45];
		vi_cwmax_ap = arrData[idx][24];	vi_cwmax_sta = arrData[idx][46];
		vi_aifs_ap = arrData[idx][25];	vi_aifs_sta = arrData[idx][47];
		vi_txop_ap = arrData[idx][26];	vi_txop_sta = arrData[idx][48];
		vi_acm_ap = arrData[idx][27];	vi_acm_sta = arrData[idx][49];
		vi_noack_ap = arrData[idx][28];

		vo_cwmin_ap = arrData[idx][29];	vo_cwmin_sta = arrData[idx][50];
		vo_cwmax_ap = arrData[idx][30];	vo_cwmax_sta = arrData[idx][51];
		vo_aifs_ap = arrData[idx][31];	vo_aifs_sta = arrData[idx][52];
		vo_txop_ap = arrData[idx][32];	vo_txop_sta = arrData[idx][53];
		vo_acm_ap = arrData[idx][33];	vo_acm_sta = arrData[idx][54];
		vo_noack_ap = arrData[idx][34];
	}else{
		be_cwmin_ap = "15";	be_cwmax_ap = "63";		be_aifs_ap = "3";	be_txop_ap = "0";		be_acm_ap = "0";	be_noack_ap = "0";
		bk_cwmin_ap = "15";	bk_cwmax_ap = "1023";	bk_aifs_ap = "7";	bk_txop_ap = "0";		bk_acm_ap = "0";	bk_noack_ap = "0";
		vi_cwmin_ap = "7";	vi_cwmax_ap = "15";		vi_aifs_ap = "1";	vi_txop_ap = "3008";	vi_acm_ap = "0";	vi_noack_ap = "0";
		vo_cwmin_ap = "3";	vo_cwmax_ap = "7";		vo_aifs_ap = "1";	vo_txop_ap = "1504";	vo_acm_ap = "0";	vo_noack_ap = "0";

		be_cwmin_sta = "15";	be_cwmax_sta = "1023";	be_aifs_sta = "3";	be_txop_sta = "0";		be_acm_sta = "0";
		bk_cwmin_sta = "15";	bk_cwmax_sta = "1023";	bk_aifs_sta = "7";	bk_txop_sta = "0";		bk_acm_sta = "0";
		vi_cwmin_sta = "7";		vi_cwmax_sta = "15";	vi_aifs_sta = "2";	vi_txop_sta = "3008";	vi_acm_sta = "0";
		vo_cwmin_sta = "3";		vo_cwmax_sta = "7";		vo_aifs_sta = "1";	vo_txop_sta = "1504";	vo_acm_sta = "0";
		
		priority_0 = "0";	priority_1 = "1";	priority_2 = "1";	priority_3 = "0";
		priority_4 = "2";	priority_5 = "2";	priority_6 = "3";	priority_7 = "3";
	}
	
	convertWmmECwValue("be_cwmin_ap", be_cwmin_ap);
	convertWmmECwValue("be_cwmax_ap", be_cwmax_ap);
	$("#be_aifs_ap").val( be_aifs_ap );
	$("#be_txop_ap").val( be_txop_ap );
	$("#be_acm_ap").val( be_acm_ap );
	$("#be_noack_ap").val( be_noack_ap );
	convertWmmECwValue("bk_cwmin_ap", bk_cwmin_ap);
	convertWmmECwValue("bk_cwmax_ap", bk_cwmax_ap);
	$("#bk_aifs_ap").val( bk_aifs_ap );
	$("#bk_txop_ap").val( bk_txop_ap );
	$("#bk_acm_ap").val( bk_acm_ap );
	$("#bk_noack_ap").val( bk_noack_ap );
	convertWmmECwValue("vi_cwmin_ap", vi_cwmin_ap);
	convertWmmECwValue("vi_cwmax_ap", vi_cwmax_ap);
	$("#vi_aifs_ap").val( vi_aifs_ap );
	$("#vi_txop_ap").val( vi_txop_ap );
	$("#vi_acm_ap").val( vi_acm_ap );
	$("#vi_noack_ap").val( vi_noack_ap );
	convertWmmECwValue("vo_cwmin_ap", vo_cwmin_ap);
	convertWmmECwValue("vo_cwmax_ap", vo_cwmax_ap);
	$("#vo_aifs_ap").val( vo_aifs_ap );
	$("#vo_txop_ap").val( vo_txop_ap );
	$("#vo_acm_ap").val( vo_acm_ap );
	$("#vo_noack_ap").val( vo_noack_ap );

	convertWmmECwValue("be_cwmin_sta", be_cwmin_sta);
	convertWmmECwValue("be_cwmax_sta", be_cwmax_sta);
	$("#be_aifs_sta").val( be_aifs_sta );
	$("#be_txop_sta").val( be_txop_sta );
	$("#be_acm_sta").val( be_acm_sta );
	convertWmmECwValue("bk_cwmin_sta", bk_cwmin_sta);
	convertWmmECwValue("bk_cwmax_sta", bk_cwmax_sta);
	$("#bk_aifs_sta").val( bk_aifs_sta );
	$("#bk_txop_sta").val( bk_txop_sta );
	$("#bk_acm_sta").val( bk_acm_sta );
	convertWmmECwValue("vi_cwmin_sta", vi_cwmin_sta);
	convertWmmECwValue("vi_cwmax_sta", vi_cwmax_sta);
	$("#vi_aifs_sta").val( vi_aifs_sta );
	$("#vi_txop_sta").val( vi_txop_sta );
	$("#vi_acm_sta").val( vi_acm_sta );
	convertWmmECwValue("vo_cwmin_sta", vo_cwmin_sta);
	convertWmmECwValue("vo_cwmax_sta", vo_cwmax_sta);
	$("#vo_aifs_sta").val( vo_aifs_sta );
	$("#vo_txop_sta").val( vo_txop_sta );
	$("#vo_acm_sta").val( vo_acm_sta );
	
	$("input[name='wmm_priority_0']").val( [ priority_0 ] );	
	$("input[name='wmm_priority_1']").val( [ priority_1 ] );	
	$("input[name='wmm_priority_2']").val( [ priority_2 ] );	
	$("input[name='wmm_priority_3']").val( [ priority_3 ] );	
	$("input[name='wmm_priority_4']").val( [ priority_4 ] );	
	$("input[name='wmm_priority_5']").val( [ priority_5 ] );	
	$("input[name='wmm_priority_6']").val( [ priority_6 ] );	
	$("input[name='wmm_priority_7']").val( [ priority_7 ] );	
}


function convertWmmECwValue(strTargetID, cwValue){
	var acwValue = new Array( 0, 1, 3, 7, 15, 31, 63, 127, 255, 511, 1023, 2047, 4095, 8191, 16383, 32767 );
	var i, idx = 0;
	var nCwValue = parseInt( cwValue, 10 );
	for( i = 0; i < 15; i++ ){
		if( nCwValue == acwValue[i] ){
			idx = i;
			break;
		}
	}

	$("#"+strTargetID).val( cwValue );
	$("#ui_"+strTargetID).val( ''+idx );
}

function convertECw2WMM(strID){
	var nECWValue = parseInt( $("#ui_"+strID).val(), 10 );
	$("#"+strID).val( ''+Math.pow(2, nECWValue) - 1 );
}



function processHttpResponse(strResponse){
	var rowOnly = 1;
	var lineArr = strResponse.split("\n");

	maxSSID = parseInt(lineArr[0], 10);
	
	for( var row=0; row < lineArr.length-rowOnly; row++){
		var strField = lineArr[row+rowOnly].split("\r");
		if( strField.length > 1 ){
			arrData[row] = strField;
		}
	}
	
	initForms(1, -1);
}

$(document).ready(function(){
	$("#form_wmm").bind( "submit", function(){
		return validateOnSubmit();
	});

	var menu_sel = 0;
	$("label[id^='wlanUIMenu']").each( function(){
		$(this).bind({
			mouseenter: function(){
				menu_sel = $( this ).hasClass('menu3rdSelect');
				$( this ).removeClass("menu3rdNormal menu3rdSelect").addClass("menu3rdMouse");
			},
			mouseleave: function(){
				if( menu_sel ){
					$( this ).removeClass("menu3rdMouse").addClass("menu3rdSelect");
					menu_sel = 0;
				}else{
					$( this ).removeClass("menu3rdMouse").addClass("menu3rdNormal");
				}
			}
		});
	});
	$(document).mjq_disableSelection();
	$("input[type='text']").mjq_disableInputEnter();

	initValue();
});

function validateOnSubmit(){
	var ret = validateOnSubmit_WMM();
	if( ret == true ){
		parent.mcrProgress.startProgressSimple("apply", 27);
	}
	return ret;
}


function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );

	parent.mcrProgress.stopProgress();

	initForms(0, -1);
	
	changeTableAdmin();
}
</script>

<script>
	function changeTableAdmin() {
		if(document.body.scrollHeight>656) {
			parent.document.getElementById("main").style.height=document.body.scrollHeight;
			parent.document.getElementById("menu").style.height=document.body.scrollHeight;
		} else {
			parent.document.getElementById("main").style.height=656;
			parent.document.getElementById("menu").style.height=656;
		}
	}

</script>
</head>

<body>
<form method="post" class="form_layout" id="form_wmm" name="form_wmm" action="/goform/mcr_KT_setWirelessWMM">
<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value=""/>
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value=""/>

<input type="hidden" id="wmmActivity" name="wmmActivity" value=""/>

<input type="hidden" id="be_cwmin_ap" name="be_cwmin_ap" value=""/>
<input type="hidden" id="bk_cwmin_ap" name="bk_cwmin_ap" value=""/>
<input type="hidden" id="vi_cwmin_ap" name="vi_cwmin_ap" value=""/>
<input type="hidden" id="vo_cwmin_ap" name="vo_cwmin_ap" value=""/>

<input type="hidden" id="be_cwmax_ap" name="be_cwmax_ap" value=""/>
<input type="hidden" id="bk_cwmax_ap" name="bk_cwmax_ap" value=""/>
<input type="hidden" id="vi_cwmax_ap" name="vi_cwmax_ap" value=""/>
<input type="hidden" id="vo_cwmax_ap" name="vo_cwmax_ap" value=""/>

<input type="hidden" id="be_cwmin_sta" name="be_cwmin_sta" value=""/>
<input type="hidden" id="bk_cwmin_sta" name="bk_cwmin_sta" value=""/>
<input type="hidden" id="vi_cwmin_sta" name="vi_cwmin_sta" value=""/>
<input type="hidden" id="vo_cwmin_sta" name="vo_cwmin_sta" value=""/>

<input type="hidden" id="be_cwmax_sta" name="be_cwmax_sta" value=""/>
<input type="hidden" id="bk_cwmax_sta" name="bk_cwmax_sta" value=""/>
<input type="hidden" id="vi_cwmax_sta" name="vi_cwmax_sta" value=""/>
<input type="hidden" id="vo_cwmax_sta" name="vo_cwmax_sta" value=""/>

<input type="hidden" id="be_acm_ap" name="be_acm_ap" value=""/>
<input type="hidden" id="bk_acm_ap" name="bk_acm_ap" value=""/>
<input type="hidden" id="vi_acm_ap" name="vi_acm_ap" value=""/>
<input type="hidden" id="vo_acm_ap" name="vo_acm_ap" value=""/>

<input type="hidden" id="be_noack_ap" name="be_noack_ap" value=""/>
<input type="hidden" id="bk_noack_ap" name="bk_noack_ap" value=""/>
<input type="hidden" id="vi_noack_ap" name="vi_noack_ap" value=""/>
<input type="hidden" id="vo_noack_ap" name="vo_noack_ap" value=""/>

<input type="hidden" id="be_acm_sta" name="be_acm_sta" value=""/>
<input type="hidden" id="bk_acm_sta" name="bk_acm_sta" value=""/>
<input type="hidden" id="vi_acm_sta" name="vi_acm_sta" value=""/>
<input type="hidden" id="vo_acm_sta" name="vo_acm_sta" value=""/>

<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_2_menu3rd.asp');%>
        </td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top" >
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td id="viewAPWMM" style="display:none">
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td class="font5"> WMM</td>
										</tr>
										<tr>
											<td class="PD4"></td>
										</tr>
										<tr>
											<td class="PD5"></td>
										</tr>
										<tr>
											<td>
												<table class="TB" width="100%" border="0">
													<tr>
														<td class="BG1" width="30%">Home Hub Phone</td>
														<td class="BG1">AC_BE</td>
														<td class="BG1">AC_BK</td>
														<td class="BG1">AC_VI</td>
														<td class="BG1">AC_VO</td>
													</tr>
													<tr>
														<td class="BG2">CWmin (0~15)</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="ui_be_cwmin_ap" name="ui_be_cwmin_ap" maxlength="2" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="ui_bk_cwmin_ap" name="ui_bk_cwmin_ap" maxlength="2" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="ui_vi_cwmin_ap" name="ui_vi_cwmin_ap" maxlength="2" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="ui_vo_cwmin_ap" name="ui_vo_cwmin_ap" maxlength="2" value=""></span>
														</td>
													</tr>
													<tr>
														<td class="BG2">CWmax (0~15)</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="ui_be_cwmax_ap" name="ui_be_cwmax_ap" maxlength="2" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="ui_bk_cwmax_ap" name="ui_bk_cwmax_ap" maxlength="2" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="ui_vi_cwmax_ap" name="ui_vi_cwmax_ap" maxlength="2" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="ui_vo_cwmax_ap" name="ui_vo_cwmax_ap" maxlength="2" value=""></span>
														</td>
													</tr>
													<tr>
														<td class="BG2">AIFS (0~15)</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="be_aifs_ap" name="be_aifs_ap" maxlength="2" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="bk_aifs_ap" name="bk_aifs_ap" maxlength="2" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="vi_aifs_ap" name="vi_aifs_ap" maxlength="2" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="vo_aifs_ap" name="vo_aifs_ap" maxlength="2" value=""></span>
														</td>
													</tr>
													<tr>
														<td class="BG2">TxopLimit (0~8192)</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="be_txop_ap" name="be_txop_ap" maxlength="4" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="bk_txop_ap" name="bk_txop_ap" maxlength="4" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="vi_txop_ap" name="vi_txop_ap" maxlength="4" value=""></span>
														</td>
														<td class="BG2-5">
															<span class="BG2-2"><input type="text" class="input3" id="vo_txop_ap" name="vo_txop_ap" maxlength="4" value=""></span>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
								<td>
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td class="font5"> WMM</td>
										</tr>
										<tr>
											<td class="PD4"></td>
										</tr>
										<tr>
											<td class="PD5"></td>
										</tr>
										<tr>
											<td>
												<table class="TB" width="100%" border="0">
													<tr>
														<td class="BG1" width="154">단말</td>
														<td class="BG1" >AC_BE</td>
														<td class="BG1" >AC_BK</td>
														<td class="BG1" >AC_VI</td>
														<td class="BG1" >AC_VO</td>
													</tr>
													<tr>
														<td class="BG2">CWmin (0~15)</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="ui_be_cwmin_sta" name="ui_be_cwmin_sta" maxlength="2" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="ui_bk_cwmin_sta" name="ui_bk_cwmin_sta" maxlength="2" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="ui_vi_cwmin_sta" name="ui_vi_cwmin_sta" maxlength="2" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="ui_vo_cwmin_sta" name="ui_vo_cwmin_sta" maxlength="2" value=""></span>
														</td>
													</tr>
													<tr>
														<td class="BG2">CWmax (0~15)</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="ui_be_cwmax_sta" name="ui_be_cwmax_sta" maxlength="2" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="ui_bk_cwmax_sta" name="ui_bk_cwmax_sta" maxlength="2" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="ui_vi_cwmax_sta" name="ui_vi_cwmax_sta" maxlength="2" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="ui_vo_cwmax_sta" name="ui_vo_cwmax_sta" maxlength="2" value=""></span>
														</td>
													</tr>
													<tr>
														<td class="BG2">AIFS (0~15)</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="be_aifs_sta" name="be_aifs_sta" maxlength="2" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="bk_aifs_sta" name="bk_aifs_sta" maxlength="2" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="vi_aifs_sta" name="vi_aifs_sta" maxlength="2" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="vo_aifs_sta" name="vo_aifs_sta" maxlength="2" value=""></span>
														</td>
													</tr>
													<tr>
														<td class="BG2">TxopLimit (0~8192)</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="be_txop_sta" name="be_txop_sta" maxlength="4" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="bk_txop_sta" name="bk_txop_sta" maxlength="4" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="vi_txop_sta" name="vi_txop_sta" maxlength="4" value=""></span>
														</td>
														<td class="BG2-3">
															<span class="BG2-3"><input type="text" class="input3" id="vo_txop_sta" name="vo_txop_sta" maxlength="4" value=""></span>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td id="viewAPWMM2">
									<p>&nbsp;</p>
								</td>
								<td class="PD6">
									<p align="right"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" value="wlanBtnWMMApply" id="wlanBtnWMMApply" name="wlanBtnWMMApply" width="52" height="24">
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td class="font5">QoS Category</td>
										</tr>
										<tr>
											<td class="PD4"></td>
										</tr>
										<tr>
											<td class="PD5"></td>
										</tr>
										<tr>
											<td>
												<table class="TB" width="100%" border="0">
													<tr>
														<td class="BG1" width="154">　</td>
														<td class="BG1" width="154" >AC_BE</td>
														<td class="BG1" width="154" >AC_BK</td>
														<td class="BG1" width="154" >AC_VI</td>
														<td class="BG1" width="154" >AC_VO</td>
													</tr>
													<tr>
														<td class="BG2" width="144">Category 0</td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_0" value="0"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_0" value="1"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_0" value="2"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_0" value="3"/></td>
													</tr>
													<tr>
														<td class="BG2" width="144">Category 1</td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_1" value="0"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_1" value="1"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_1" value="2"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_1" value="3"/></td>
													</tr>
													<tr>
														<td class="BG2" width="144">Category 2</td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_2" value="0"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_2" value="1"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_2" value="2"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_2" value="3"/></td>
													</tr>
													<tr>
														<td class="BG2" width="144">Category 3</td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_3" value="0"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_3" value="1"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_3" value="2"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_3" value="3"/></td>
													</tr>
													<tr>
														<td class="BG2" width="144">Category 4</td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_4" value="0"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_4" value="1"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_4" value="2"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_4" value="3"/></td>
													</tr>
													<tr>
														<td class="BG2" width="144">Category 5</td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_5" value="0"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_5" value="1"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_5" value="2"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_5" value="3"/></td>
													</tr>
													<tr>
														<td class="BG2" width="144">Category 6</td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_6" value="0"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_6" value="1"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_6" value="2"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_6" value="3"/></td>
													</tr>
													<tr>
														<td class="BG2" width="144">Category 7</td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_7" value="0"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_7" value="1"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_7" value="2"/></td>
														<td class="BG2-3" width="144"><input type="radio" name="wmm_priority_7" value="3"/></td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6">
									<p align="right"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" value="wlanBtnTOSApply" id="wlanBtnTOSApply" name="wlanBtnTOSApply" width="52" height="24">
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
