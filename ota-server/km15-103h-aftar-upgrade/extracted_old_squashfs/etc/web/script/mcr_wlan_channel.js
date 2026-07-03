//var AutoChannelRange_splitCount = 3;
var isUseVendorChannelList = 0;

var ChannelList_24G = new Array(14);
ChannelList_24G[0] = "Auto";
ChannelList_24G[1] = "1";
ChannelList_24G[2] = "2";
ChannelList_24G[3] = "3";
ChannelList_24G[4] = "4";
ChannelList_24G[5] = "5";
ChannelList_24G[6] = "6";
ChannelList_24G[7] = "7";
ChannelList_24G[8] = "8";
ChannelList_24G[9] = "9";
ChannelList_24G[10] = "10";
ChannelList_24G[11] = "11";
ChannelList_24G[12] = "12";
ChannelList_24G[13] = "13";

//-------------------------
// deprcated (2013.01.28)
//-------------------------
// 1 - Primary/Control Channel
// 2 - Secondary/Extension Channel
// 3 - 20MHz Only
// 4 - not used
//-------------------------
// value re-define for 11ac (2013.01.28)
// value re-define for 11ax qca (2019.03.21)
//-------------------------
// avail
//bit 0 : 20M use
//bit 1 : 40M use	
//bit 2 : 80M use	
//bit 3 : 160M use
//bit 4 : 80+80M use
// nChBandWidth - bit shift (bit3-0), non-continue(bit4)
// nChBandWidth 80+80을 추가하기 위해서 bit 4에 flag추가함. 아래소스에서 BandWidth 값에서 bandwidth정보만 추출시 mask로 처리할 것
//	0 : 20M - ( << 0)
//  1 : 40M - ( << 1)
//  2 : 80M - ( << 2)
//  3 : 160M - ( << 3)
//  0x12 (18) : 80+80M - ( << 2) & non-continue
var CH_BW_5G_20M	= 0x00;
var CH_BW_5G_40M	= 0x01;
var CH_BW_5G_80M	= 0x02;
var CH_BW_5G_160M	= 0x03;
var CH_BW_5G_80_80M	= 0x12;
// primary
//bit 0 : 20M (1-primary)	
//bit 1 : 40M (1-primary, 0-secondary)	
//bit 2 : 80M (1-primary, 0-secondary)	

var ChannelList_5G_DFS_COL = 2;
var ChannelList_5G_AVAIL_COL = 3;
var ChannelList_5G_PRIMARY_COL = 4;
var ChannelList_5G_CURRENT_COL = 5;

//80+80(nc)
var ChannelList_5G = [
	//0		1		2	3			4			5
	//Idx	channel	DFS	DefAvail  	Primary		CurrentAvail
	["0", 	"Auto",	0,	0x1F, 		0x00,  		0],
	//U-NII-1
	["1",	"36", 	0,	0x1F,		0x07, 		0],
	["2",	"40", 	0,	0x1F,		0x01, 		0],
	["3",	"44", 	0,	0x1F,		0x07,		0],
	["4",	"48", 	0,	0x1F,		0x01,		0],
	//U-NII-2
	["5",	"52", 	1,	0x1F,		0x07,		0],
	["6",	"56", 	1,	0x1F,		0x01,		0],
	["7",	"60", 	1,	0x1F,		0x07,		0],
	["8",	"64", 	1,	0x1F,		0x01,		0],
	//U-NII Worldwide
	["9",	"100", 	1,	0x1F,		0x07, 		0],
	["10",	"104", 	1,	0x1F,		0x01, 		0],
	["11",	"108", 	1,	0x1F,		0x07, 		0],
	["12",	"112", 	1,	0x1F,		0x01, 		0],
	["13",	"116", 	1,	0x1F,		0x07, 		0],
	["14",	"120", 	1,	0x1F,		0x01, 		0],
	["15",	"124", 	1,	0x1F,		0x07, 		0],
	["16",	"128", 	1,	0x1F,		0x01, 		0],
	["17",	"132", 	1,	0x03,		0x07, 		0],
	["18",	"136", 	1,	0x03,		0x01, 		0],
	["19",	"140", 	1,	0x03,		0x07, 		0],
	["20",	"144", 	1,	0x00,		0x01, 		0],
	//U-NII-3
	["21",	"149", 	0,	0x17,		0x07, 		0],
	["22",	"153", 	0,	0x17,		0x01, 		0],
	["23",	"157", 	0,	0x17,		0x07, 		0],
	["24",	"161", 	0,	0x17,		0x01, 		0],
	["25",	"165", 	0,	0x01,		0x03, 		0],
	["26",	"169", 	0,	0x00,		0x01, 		0]
	//마지막에 ',' 주의. ','가 있는 경우 IE에서는 array length가 늘어나버림.
];

var Channel_5G_BITMASK_DFS 		= 0x00FFFF0;
var Channel_5G_BITMASK_NONDFS 	= 0x1F0000F;

//VHT80_80
var ChannelList_5G_VHT80_80_EXT_LABEL_COL = 1;
var ChannelList_5G_VHT80_80_EXT_CENTER_CH_COL = 2;
var ChannelList_5G_VHT80_80_EXT_RANGE_START_COL = 3;
var ChannelList_5G_VHT80_80_EXT_RANGE_END_COL = 4;
var ChannelList_5G_VHT80_80_EXT_AVAIL_IDX_BIT_COL = 5;
//AVAIL_IDX_COL
// ChannelList_5G_VHT80_80_EXT 사용가능한 Index의 bitmask
var ChannelList_5G_VHT80_80_EXT = [
	//0		1		2			3	  	4		5
	//Idx	channel	CenterCH	Start 	End		IDX_BIT
	["0",	"36-48", 	"42",	36,		48,		0x2c],
	["1",	"52-64", 	"58",	52,		64,		0x2c],
	["2",	"100-112", 	"106",	100,	112,	0x23],
	["3",	"116-128", 	"122",	116,	128,	0x23],
	["4",	"132-144", 	"138",	132,	144,	0x00],
	["5",	"149-161", 	"155",	149,	161,	0x0f]
	//마지막에 ',' 주의. ','가 있는 경우 IE에서는 array length가 늘어나버림.
];

function isDFSRange(autoChannelRange){
	var ret = 0;
	if( (autoChannelRange & Channel_5G_BITMASK_DFS) != 0 && 
		(autoChannelRange & Channel_5G_BITMASK_NONDFS) == 0){
		ret = 1;
	}
	return ret;
}

// DefAvail & AvailChannelRange 를 고려해서 Current에 사용가능 channel 목록을 update한다.
// 이후 5G 관련 정보는 Current Col을 참조한다.
function isBandWidthGroupAvail_5G(primaryIdx, nChBandWidth){
	var channelCount = Math.pow( 2, (nChBandWidth & 0x0f) );
	var bandWidthBit = (1 << (nChBandWidth & 0x0f));
	var idx;
	var avail = true;
	
	for( idx = 0; idx < channelCount; idx++ ){
		if( !(ChannelList_5G[idx+primaryIdx][ChannelList_5G_CURRENT_COL] & bandWidthBit) ){
			//하나라도 disable이면 사용불가
			avail = false;
			break;
		}
	}
	
	return avail;
}

function updateCurrentAvailChannelGroup_5G(primaryIdx, nChBandWidth){
	var channelCount = Math.pow( 2, (nChBandWidth & 0x0f) );
	var bandWidthBit = (1 << (nChBandWidth & 0x0f));
	var idx;
	var avail = isBandWidthGroupAvail_5G(primaryIdx, nChBandWidth);
	
	for( idx = 0; idx < channelCount; idx++ ){
		if( avail ){
			ChannelList_5G[idx+primaryIdx][ChannelList_5G_CURRENT_COL] |= bandWidthBit;
		}else{
			ChannelList_5G[idx+primaryIdx][ChannelList_5G_CURRENT_COL] &= ~bandWidthBit;
		}
	}
	
	return avail;
}

function updateCurrentAvailChannel_5G(nChBandWidth, nAvailChannelRange, bIncludeAuto){
	var channelCount = Math.pow( 2, (nChBandWidth & 0x0f) );
	var bandWidthBit = (1 << (nChBandWidth & 0x0f));
	var idx, startPrimaryIdx;
	
	for( idx = 0; idx < ChannelList_5G.length; idx++ ){
		//STEP 1. user avail 적용
		if( isAvailChannelRange(idx, nAvailChannelRange, bIncludeAuto) ){
			//step 2. copy def_avail -> cur_avail
			ChannelList_5G[idx][ChannelList_5G_CURRENT_COL] = ChannelList_5G[idx][ChannelList_5G_AVAIL_COL];
		}else{
			ChannelList_5G[idx][ChannelList_5G_CURRENT_COL] = 0x00;
		}
	}
	
	//STEP 3. Bandwidth 별 설정
	if( nChBandWidth != 0 ){
		for( idx = 1; idx < ChannelList_5G.length; ){
			if( ChannelList_5G[idx][ChannelList_5G_PRIMARY_COL] & bandWidthBit ){
				//primary channel
				startPrimaryIdx = idx;
				updateCurrentAvailChannelGroup_5G(startPrimaryIdx, nChBandWidth );
				idx += channelCount;
			}else{
				idx++;
			}
		}
	}

	//debug	
	/* 
	console.debug("nChBandWidth:"+nChBandWidth);
		console.debug("IDX  CHANNEL  DEF CUR");
	for( idx = 0; idx < ChannelList_5G.length; idx++ ){
		console.debug(""+idx+"   "+ChannelList_5G[idx][1]+"      "+ChannelList_5G[idx][ChannelList_5G_AVAIL_COL]+"  "+ChannelList_5G[idx][ChannelList_5G_CURRENT_COL]);
	}
	*/
}

function isAvailChannelRange(idx, nAvailChannelRange, bIncludeAuto){
	//20M, 40M일때의 처리가 복잡하므로 ChannelList 기준으로 동작
	var ret = false;
	if( idx == 0 ){
		//auto
		if( bIncludeAuto == true ){
			ret = true;
		}
	}else{
		if( nAvailChannelRange & (1 << (idx-1) ) ){
			ret = true;
		}else{
			ret = false;
		}
	}	
	return ret;
}

function isAvailChannelRangeUsingBandWidth(idx, freqType, nChBandWidth, nAvailChannelRange, bIncludeAuto){
	var ret = false;
	var curChannelAvail = false;
	var pairChannelAvail = false;
	
	if( idx == 0 ){
		//auto
		if( bIncludeAuto == true ){
			ret = true;
		}
	}else{
		if( freqType == '1' ){
			//2.4GHz
			ret = isAvailChannelRange(idx, nAvailChannelRange, bIncludeAuto);
		}else{
			//5GHz
			var bandWidthBit = (1 << (nChBandWidth & 0x0f));
			if( ChannelList_5G[idx][ChannelList_5G_CURRENT_COL] & bandWidthBit ){
				ret = true;
			}else{
				ret = false;
			}
		}
	}	
	return ret;
}

function is2GChannelDisplay(idx, projectCode, nChBandWidth, nAvailChannelRange, bIncludeAuto){
	var ret = false;

	//avail channel 처리
	ret = isAvailChannelRangeUsingBandWidth( idx, '1', nChBandWidth, nAvailChannelRange, bIncludeAuto );
	return ret;
}

function is5GChannelDisplay(idx, projectCode, nChBandWidth, nAvailChannelRange, bChannelRange, bIncludeAuto){
	var bandWidthBit = (1 << (nChBandWidth & 0x0f));
	var ret = false;
	var bUseDFS = true;
	
	//avail channel 처리
	ret = isAvailChannelRangeUsingBandWidth( idx, '2', nChBandWidth, nAvailChannelRange, bIncludeAuto );
		
	//DFS filter - DFS range이면 무조건 제외
	/*
	if( bChannelRange == false &&
		bUseDFS == true && ChannelList_5G[idx][ChannelList_5G_DFS_COL] == 1 ){
		ret = false;
	}
	*/
	return ret;
}

function is5GChannelEnabled(idx){
	var ret = false;
//	var bUseDFS = true;
	
	//avail channel 처리
	if( ChannelList_5G[idx][ChannelList_5G_CURRENT_COL] != 0 ){
		ret = true;
	}else{
		ret = false;
	}
	return ret;
}
//////////////////////////////////////////////////////
// Wireless Channel
//	Combo의 value
//	2.4GHz 	: 0 - auto, 1~13 - channel == index
//	5GHz 	: 0 - auto, 1~24 - ChannelList_5G index 
function setPrimaryChannel_2G(channelOption, defaultChannel, projectCode, nChBandWidth, nAvailChannelRange, bIncludeAuto){
	//var channelOption = document.getElementById("channel");
	var idx, optionIdx;
	
	channelOption.options.length = 0;
	for( idx = 0, optionIdx = 0; idx < ChannelList_24G.length; idx++ ){
		if( is2GChannelDisplay(idx, projectCode, nChBandWidth, nAvailChannelRange, bIncludeAuto) ){
			channelOption.options[optionIdx] = new Option(ChannelList_24G[idx], idx);
			optionIdx++;
		}
	}
}

function setPrimaryChannel_5G(channelOption, defaultChannel, projectCode, nChBandWidth, nAvailChannelRange, bIncludeAuto){
	var idx, optionIdx;
	
	//cuurent avail channel list 갱신 - 이후 이 테이블만 참조
	updateCurrentAvailChannel_5G(nChBandWidth, nAvailChannelRange, bIncludeAuto);
	
	channelOption.options.length = 0;
	for( idx = 0, optionIdx = 0; idx < ChannelList_5G.length; idx++ ){
		if( is5GChannelDisplay(idx, projectCode, nChBandWidth, nAvailChannelRange, false, bIncludeAuto) ){
			// value는 channel 값을 직접사용.
			//channelOption.options[optionIdx] = new Option(ChannelList_5G[idx][1], ChannelList_5G[idx][0]);
			if( idx == 0 ){
				//Auto
				channelOption.options[optionIdx] = new Option(ChannelList_5G[idx][1], ChannelList_5G[idx][0]);
			}else{
				channelOption.options[optionIdx] = new Option(ChannelList_5G[idx][1], ChannelList_5G[idx][1]);
			}
			optionIdx++;
		}
	}
}

function setPrimaryChannel(channelID, defaultChannel, freqType, projectCode, nChBandWidth, nAvailChannelRange, bIncludeAuto){
	var channelOption = document.getElementById(channelID);
	//console.debug("setPrimaryChannel|setPrimaryChannel---"+"projectCode:"+projectCode+" strChBandWidth:"+nChBandWidth+" freqType:"+freqType+" defaultChannel:"+defaultChannel);
	if( freqType == '1' ){
		//2.4GHz
		setPrimaryChannel_2G(channelOption, defaultChannel, projectCode, nChBandWidth, nAvailChannelRange, bIncludeAuto);
	}else{
		//5GHz
		if( nChBandWidth == CH_BW_5G_80_80M ){
			nChBandWidth = 0x04;
		}		
		setPrimaryChannel_5G(channelOption, defaultChannel, projectCode, nChBandWidth, nAvailChannelRange, bIncludeAuto);
	}
	if( defaultChannel != -1 && defaultChannel != null ){
		initCombo(channelOption, defaultChannel);
	}
}


///////////////////////////////////////////////////////////
// Channel Extension - 선택된 Primary에 의해서 결정되는 2nd channel 처리
/*
 *	Main Channel	ExtChannel
 *	-----------------------------------------
 *	1				5
 *	2				6
 *	3				7
 *	4				8
 *	5				1	9
 *	6				2	10
 *	7				3	11
 *	8				4	12
 *	9				5	13
 *	10				6
 *	11				7
 *	12				8
 *	13				9
 */
function setChannelExtension_2G(chExtensionID, channelID){
//	var chExtension = document.getElementById("chExtension");
//	var channel = getComboSelectedValueById("channel");
	var chExtension = document.getElementById(chExtensionID);
	var channel = getComboSelectedValueById(channelID);
	var nSelectedChannel = parseInt(channel, 10);
	
	if( nSelectedChannel >= 1 && nSelectedChannel <= 4 ){
		chExtension.options.length = 1;
		if( cpuName.indexOf('RTL') != -1 ){
			chExtension.options[0] = new Option("Upper", nSelectedChannel+4);
		}else{
			chExtension.options[0] = new Option(ChannelList_24G[nSelectedChannel+4], nSelectedChannel+4);
		}
	}else if( nSelectedChannel >= 5 && nSelectedChannel <= 9 ){
		chExtension.options.length = 2;
		if( cpuName.indexOf('RTL') != -1 ){
			chExtension.options[0] = new Option("Lower", nSelectedChannel-4);
			chExtension.options[1] = new Option("Upper", nSelectedChannel+4);
		}else{
			chExtension.options[0] = new Option(ChannelList_24G[nSelectedChannel-4], nSelectedChannel-4);
			chExtension.options[1] = new Option(ChannelList_24G[nSelectedChannel+4], nSelectedChannel+4);
		}
	}else if( nSelectedChannel >= 10 && nSelectedChannel <= 13 ){
		chExtension.options.length = 1;
		if( cpuName.indexOf('RTL') != -1 ){
			chExtension.options[0] = new Option("Lower", nSelectedChannel-4);
		}else{
			chExtension.options[0] = new Option(ChannelList_24G[nSelectedChannel-4], nSelectedChannel-4);
		}
	}else{
		chExtension.options.length = 1;
		chExtension.options[0] = new Option(ChannelList_24G[0], 0);
	}
}

function findChannelIndex_5G(nSelectedChannel){
	var idx, ret = -1;
	for( idx = 0; idx < ChannelList_5G.length; idx++ ){
		if( ChannelList_5G[idx][1] == ''+nSelectedChannel ){
			ret = idx;
			break;
		}
	}
	
	return ret;
}

function setChannelExtension_5G(chExtensionID, channelID, projectCode, nChBandWidth){
	var bandWidthBit = (1 << (nChBandWidth & 0x0f));
	var chExtension = document.getElementById(chExtensionID);
	var channel = getComboSelectedValueById(channelID);
	var nSelectedChannel = parseInt(channel, 10);
	var nSelectedIdx = findChannelIndex_5G(nSelectedChannel);	//channel->index
	var extensionChannelIdx = 0;

	if( nSelectedChannel == 0 ){
		//auto
		extensionChannelIdx = 0;
	}else{
		if( ChannelList_5G[nSelectedIdx][ChannelList_5G_PRIMARY_COL] & bandWidthBit ){
			extensionChannelIdx = nSelectedIdx + 1;	//upper
		}else{
			extensionChannelIdx = nSelectedIdx - 1;	//lower
		}
	}
	//check out of range
	if( nChBandWidth == 0 //20M
		|| extensionChannelIdx >= ChannelList_5G.length ){
		extensionChannelIdx = 0;
	}

	chExtension.options.length = 1;
	// value는 channel 값을 직접사용.
	chExtension.options[0] = new Option(ChannelList_5G[extensionChannelIdx][1], ChannelList_5G[extensionChannelIdx][1]);
}

function setChannelExtension_5G_VHT80_80(chExtensionID, channelID, projectCode, nChBandWidth){
	var bandWidthBit = (1 << (nChBandWidth & 0x0f));
	var chExtension = document.getElementById(chExtensionID);
	var channel = getComboSelectedValueById(channelID);
	var nSelectedChannel = parseInt(channel, 10);
	var nSelectedIdx = findChannelIndex_5G(nSelectedChannel);	//channel->index
	var extensionChannelIdx = 0;
	var i = 0;

	if( nSelectedChannel == 0 ){
		//auto
		extensionChannelIdx = 0;
		
		chExtension.options.length = 1;
		// value는 channel 값을 직접사용.
		chExtension.options[0] = new Option(ChannelList_5G[extensionChannelIdx][1], ChannelList_5G[extensionChannelIdx][1]);
	}else{
		//초기화
		extensionChannelIdx = 0;
		chExtension.options.length = 0;
		for( i = 0; i < 6; i++ ){
			if( nSelectedChannel >= ChannelList_5G_VHT80_80_EXT[i][ChannelList_5G_VHT80_80_EXT_RANGE_START_COL] &&
				nSelectedChannel <= ChannelList_5G_VHT80_80_EXT[i][ChannelList_5G_VHT80_80_EXT_RANGE_END_COL] ){
				extensionChannelIdx = ChannelList_5G_VHT80_80_EXT[i][ChannelList_5G_VHT80_80_EXT_AVAIL_IDX_BIT_COL];
				break;
			}
		}
		if( extensionChannelIdx != 0 ){
			for( i = 0; i < 6; i++ ){
				if( extensionChannelIdx & (1 << i) ){
					obj = new Option(ChannelList_5G_VHT80_80_EXT[i][1], ChannelList_5G_VHT80_80_EXT[i][2]);
					chExtension.add( obj );
				}
			}
		}
	}
	//debug	
	/*
	console.debug("chExtension:"+chExtension.length);
	for( idx = 0; idx < chExtension.length; idx++ ){
		console.debug(""+idx+"   "+chExtension.options[idx].text+"      "+chExtension.options[idx].value);
	}
	*/
}

function setChannelExtension(chExtensionID, channelID, freqType, projectCode, nChBandWidth, defaultChExtension){
	//console.debug("setChannelExtension---"+"projectCode:"+projectCode+" freqType:"+freqType);
	if( freqType == '1' ){
		//2.4GHz
		setChannelExtension_2G(chExtensionID, channelID);
	}else{
		//5GHz
		if( nChBandWidth == CH_BW_5G_80_80M ){	//VHT80_80
			setChannelExtension_5G_VHT80_80(chExtensionID, channelID, projectCode, nChBandWidth);
		}else{
			setChannelExtension_5G(chExtensionID, channelID, projectCode, nChBandWidth);
		}
	}
	
	if( defaultChExtension != -1 && defaultChExtension != null ){
		initComboById(chExtensionID, defaultChExtension);
	}
}

//////////////////////////////////////////
// Auto Channel Range
function generateChannelLabel(nLabelFormat, channelNo, channelFreq){
	var channelLabel = "";
	if( nLabelFormat == 0 ){
		channelLabel = "["+channelNo+"] "+ channelFreq ;
	}else if( nLabelFormat == 1 ){
		//freq 없이 간격필요한 경우
		channelLabel = ""+channelNo+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
	}
	return channelLabel;
}

function setAutoChannelRange_2G(channelRangeID, projectCode, nChBandWidth, nAvailChannelRange, nAutoChannelRange_splitCount, nLabelFormat){
	var e = document.getElementById(channelRangeID);
	var strTable;
	var channelNo, channelFreq, channelLabel, channelName;
	var splitIdx = 0;

	strTable = "<table>";

	//auto는 불필요
	for( idx = 1; idx < ChannelList_24G.length; idx++ ){
		channelNo = idx;
		channelFreq = (2407 + 5*channelNo);
		channelLabel = generateChannelLabel(nLabelFormat, channelNo, channelFreq);
		channelName = "autochannel_"+idx;
		
		if( is2GChannelDisplay(idx, projectCode, nChBandWidth, nAvailChannelRange) ){
			splitIdx++;
			//open tr brace
			if( (splitIdx % nAutoChannelRange_splitCount) == 1 ){
				strTable += "<tr>";
			}
			//append checkbox
			strTable += "<td><input type='checkbox' id='"+channelName+"' name='"+channelName+"' value='1'>"+channelLabel+"</input></td>";
			
			//close tr brace
			if( ((splitIdx % nAutoChannelRange_splitCount) == 0) || 
				((idx + 1) == ChannelList_24G.length) ){
				strTable += "</tr>";
			}
		}
	}

	strTable += "</table>";
	if( e != null ){
		e.innerHTML = strTable;
	}
}

function setAutoChannelRange_5G(channelRangeID, projectCode, nChBandWidth, nAvailChannelRange, nAutoChannelRange_splitCount, nLabelFormat){
	var e = document.getElementById(channelRangeID);
	var strTable;
	var channelNo, channelFreq, channelLabel, channelName;
	var splitIdx = 0;
	var display = 0;
	var enabled = 0;

	strTable = "<table>";

	//auto는 불필요
	for( idx = 1; idx < ChannelList_5G.length; idx++ ){
		channelNo = parseInt( ChannelList_5G[idx][1], 10);
		channelFreq = (5000 + 5*channelNo);
		channelLabel = generateChannelLabel(nLabelFormat, channelNo, channelFreq);
		channelName = "autochannel_"+idx;
		
		enabled = is5GChannelEnabled(idx);
		display = is5GChannelDisplay(idx, projectCode, nChBandWidth, nAvailChannelRange, true);
		//if( is5GChannelDisplay(idx, projectCode, nChBandWidth, nAvailChannelRange, true) ){
		if( enabled ){
			splitIdx++;
			//open tr brace
			if( (splitIdx % nAutoChannelRange_splitCount) == 1 ){
				strTable += "<tr>";
			}
			//append checkbox
			if( display ){
				strTable += "<td><input type='checkbox' id='"+channelName+"' name='"+channelName+"' value='1'>"+channelLabel+"</input></td>";
			}else{
				strTable += "<td><input type='checkbox' disabled ='disabled' id='"+channelName+"' name='"+channelName+"' value='1'>"+channelLabel+"</input></td>";
			}
			
			//close tr brace
			if( ((splitIdx % nAutoChannelRange_splitCount) == 0) || 
				((idx + 1) == ChannelList_5G.length) ){
				strTable += "</tr>";
			}
		}
	}

	strTable += "</table>";
	if( e != null ){
		e.innerHTML = strTable;
	}
}
function setAutoChannelRange(channelRangeID, freqType, projectCode, nChBandWidth, nAvailChannelRange, nAutoChannelRange_splitCount, nLabelFormat){
	//console.debug("setAutoChannelRange---"+"projectCode:"+projectCode+" freqType:"+freqType+" strChBandWidth:"+nChBandWidth);
	if( freqType == '1' ){
		//2.4GHz
		setAutoChannelRange_2G(channelRangeID, projectCode, nChBandWidth, nAvailChannelRange, nAutoChannelRange_splitCount, nLabelFormat);
	}else{
		//5GHz
		if( nChBandWidth == CH_BW_5G_80_80M ){
			nChBandWidth = 0x04;
		}
		setAutoChannelRange_5G(channelRangeID, projectCode, nChBandWidth, nAvailChannelRange, nAutoChannelRange_splitCount, nLabelFormat);
	}
}

function setAutoChannelRangeValue(freqType, channelRange){
	var i;
	var bitChannel = 0;
	var strID = "";
	var count = 0;
	if( freqType == '1' ){
		//2.4GHz
		count = ChannelList_24G.length - 1;
	}else{
		//5GHz
		count = ChannelList_5G.length - 1;
	}
	
	for( var i = 0; i < count; i++ ){
		strID = "autochannel_"+(i+1);
		bitChannel = 1 << i;
		
		if( channelRange & bitChannel ){
			initCheckboxById(strID, "1");
		}else{
			initCheckboxById(strID, "0");
		}
	}
}

function mergeAutoChannelRangeValue(freqType, autochannelRangeID){
	var i;
	var bitChannel = 0;
	var strID = "";
	var channelRange = 0;
	var e = null;

	var count = 0;
	if( freqType == '1' ){
		//2.4GHz
		count = ChannelList_24G.length - 1;
	}else{
		//5GHz
		count = ChannelList_5G.length - 1;
	}	
	for( var i = 0; i < count; i++ ){
		strID = "autochannel_"+(i+1);
		bitChannel = 1 << i;

		e = document.getElementById(strID);
		if( e != null && e.checked == true ){
			channelRange += bitChannel;
		}
	}

	//console.debug("mergeAutoChannelRangeValue-channelRange"+channelRange);
	//initTextById("autochannelrange", ''+channelRange);
	initTextById(autochannelRangeID, ''+channelRange);
}

//////////////////////////////////////////
// DataRate

//ANT_COL
//bit 0 : 1T1R
//bit 1 : 2T2R
//bit 2 : 3T3R
//bit 3 : 4T4R
//WMODE COL
//bit 0 : b
//bit 1 : g
//bit 2 : n
//bit 3 : a
//bit 4 : ac
//bit 5 : ax
//BandWidth COL
//bit 0 : 20M
//bit 1 : 40M
//bit 2 : 80M
//bit 3 : 160M
//Value COL
var RateType_LEGACY = 0x01 << 30;
var RateType_HT 	= 0x01 << 29;
var RateType_VHT 	= 0x01 << 28;
var RateType_HE 	= 0x01 << 31;	//11ax
var RateType_MASK	= 0xf0 << 24;

var DataRate_MCS_LABEL_COL		= 0;
var DataRate_MCS_VALUE_COL		= 1;
var DataRate_MCS_ANT_COL		= 2;
var DataRate_MCS_WMODE_COL		= 3;
var DataRate_MCS_BANDWIDTH_COL	= 4;
var DataRate_MCS_CURRENT_COL	= 5;

var DataRate_MCS = [
	//0				1						2		3		4			5
	//Label			Value					ANT		WMODE	BANDWIDTH	CurrentAvail
	["Auto",		0,						0x0f,	0x3f,	0x0f,		0],
	//Legacy
	["1",			RateType_LEGACY | 0x01, 0x0f,	0x01,	0x0f,		0],
	["2",			RateType_LEGACY | 0x02,	0x0f,	0x01,	0x0f,		0],
	["5.5",			RateType_LEGACY | 0x03,	0x0f,	0x01,	0x0f,		0],
	["11",			RateType_LEGACY | 0x04,	0x0f,	0x01,	0x0f,		0],
	["6",			RateType_LEGACY | 0x05,	0x0f,	0x0a,	0x0f,		0],
	["9",			RateType_LEGACY | 0x06,	0x0f,	0x0a,	0x0f,		0],
	["12",			RateType_LEGACY | 0x07,	0x0f,	0x0a,	0x0f,		0],
	["18",			RateType_LEGACY | 0x08,	0x0f,	0x0a,	0x0f,		0],
	["24",			RateType_LEGACY | 0x09,	0x0f,	0x0a,	0x0f,		0],
	["36",			RateType_LEGACY | 0x0a,	0x0f,	0x0a,	0x0f,		0],
	["48",			RateType_LEGACY | 0x0b,	0x0f,	0x0a,	0x0f,		0],
	["54",			RateType_LEGACY | 0x0c,	0x0f,	0x0a,	0x0f,		0],
	//HT
	["MCS 0",		RateType_HT | 0x00,		0x0f,	0x04,	0x0f,		0],
	["MCS 1",		RateType_HT | 0x01,		0x0f,	0x04,	0x0f,		0],
	["MCS 2",		RateType_HT | 0x02,		0x0f,	0x04,	0x0f,		0],
	["MCS 3",		RateType_HT | 0x03,		0x0f,	0x04,	0x0f,		0],
	["MCS 4",		RateType_HT | 0x04,		0x0f,	0x04,	0x0f,		0],
	["MCS 5",		RateType_HT | 0x05,		0x0f,	0x04,	0x0f,		0],
	["MCS 6",		RateType_HT | 0x06,		0x0f,	0x04,	0x0f,		0],
	["MCS 7",		RateType_HT | 0x07,		0x0f,	0x04,	0x0f,		0],
	
	["MCS 8",		RateType_HT | 0x08,		0x0e,	0x04,	0x0f,		0],
	["MCS 9",		RateType_HT | 0x09,		0x0e,	0x04,	0x0f,		0],
	["MCS10",		RateType_HT | 0x0a,		0x0e,	0x04,	0x0f,		0],
	["MCS11",		RateType_HT | 0x0b,		0x0e,	0x04,	0x0f,		0],
	["MCS12",		RateType_HT | 0x0c,		0x0e,	0x04,	0x0f,		0],
	["MCS13",		RateType_HT | 0x0d,		0x0e,	0x04,	0x0f,		0],
	["MCS14",		RateType_HT | 0x0e,		0x0e,	0x04,	0x0f,		0],
	["MCS15",		RateType_HT | 0x0f,		0x0e,	0x04,	0x0f,		0],

	["MCS16",		RateType_HT | 0x10,		0x0c,	0x04,	0x0f,		0],
	["MCS17",		RateType_HT | 0x11,		0x0c,	0x04,	0x0f,		0],
	["MCS18",		RateType_HT | 0x12,		0x0c,	0x04,	0x0f,		0],
	["MCS19",		RateType_HT | 0x13,		0x0c,	0x04,	0x0f,		0],
	["MCS20",		RateType_HT | 0x14,		0x0c,	0x04,	0x0f,		0],
	["MCS21",		RateType_HT | 0x15,		0x0c,	0x04,	0x0f,		0],
	["MCS22",		RateType_HT | 0x16,		0x0c,	0x04,	0x0b,		0],
	["MCS23",		RateType_HT | 0x17,		0x0c,	0x04,	0x0f,		0],
	
	["MCS24",		RateType_HT | 0x18,		0x08,	0x04,	0x0f,		0],
	["MCS25",		RateType_HT | 0x19,		0x08,	0x04,	0x0f,		0],
	["MCS26",		RateType_HT | 0x1a,		0x08,	0x04,	0x0f,		0],
	["MCS27",		RateType_HT | 0x1b,		0x08,	0x04,	0x0f,		0],
	["MCS28",		RateType_HT | 0x1c,		0x08,	0x04,	0x0f,		0],
	["MCS29",		RateType_HT | 0x1d,		0x08,	0x04,	0x0f,		0],
	["MCS30",		RateType_HT | 0x1e,		0x08,	0x04,	0x0f,		0],
	["MCS31",		RateType_HT | 0x1f,		0x08,	0x04,	0x0f,		0],
	
	//VHT
	["NSS1_MCS0",	RateType_VHT | 0x00,	0x0f,	0x10,	0x0f,		0],
	["NSS1_MCS1",	RateType_VHT | 0x01,	0x0f,	0x10,	0x0f,		0],
	["NSS1_MCS2",	RateType_VHT | 0x02,	0x0f,	0x10,	0x0f,		0],
	["NSS1_MCS3",	RateType_VHT | 0x03,	0x0f,	0x10,	0x0f,		0],
	["NSS1_MCS4",	RateType_VHT | 0x04,	0x0f,	0x10,	0x0f,		0],
	["NSS1_MCS5",	RateType_VHT | 0x05,	0x0f,	0x10,	0x0f,		0],
	["NSS1_MCS6",	RateType_VHT | 0x06,	0x0f,	0x10,	0x0f,		0],
	["NSS1_MCS7",	RateType_VHT | 0x07,	0x0f,	0x10,	0x0f,		0],
	["NSS1_MCS8",	RateType_VHT | 0x08,	0x0f,	0x10,	0x0f,		0],
	["NSS1_MCS9",	RateType_VHT | 0x09,	0x0f,	0x10,	0x0e,		0],

	["NSS2_MCS0",	RateType_VHT | 0x0a,	0x0e,	0x10,	0x0f,		0],
	["NSS2_MCS1",	RateType_VHT | 0x0b,	0x0e,	0x10,	0x0f,		0],
	["NSS2_MCS2",	RateType_VHT | 0x0c,	0x0e,	0x10,	0x0f,		0],
	["NSS2_MCS3",	RateType_VHT | 0x0d,	0x0e,	0x10,	0x0f,		0],
	["NSS2_MCS4",	RateType_VHT | 0x0e,	0x0e,	0x10,	0x0f,		0],
	["NSS2_MCS5",	RateType_VHT | 0x0f,	0x0e,	0x10,	0x0f,		0],
	["NSS2_MCS6",	RateType_VHT | 0x10,	0x0e,	0x10,	0x0f,		0],
	["NSS2_MCS7",	RateType_VHT | 0x11,	0x0e,	0x10,	0x0f,		0],
	["NSS2_MCS8",	RateType_VHT | 0x12,	0x0e,	0x10,	0x0f,		0],
	["NSS2_MCS9",	RateType_VHT | 0x13,	0x0e,	0x10,	0x0e,		0],

	["NSS3_MCS0",	RateType_VHT | 0x14,	0x0c,	0x10,	0x07,		0],
	["NSS3_MCS1",	RateType_VHT | 0x15,	0x0c,	0x10,	0x07,		0],
	["NSS3_MCS2",	RateType_VHT | 0x16,	0x0c,	0x10,	0x07,		0],
	["NSS3_MCS3",	RateType_VHT | 0x17,	0x0c,	0x10,	0x07,		0],
	["NSS3_MCS4",	RateType_VHT | 0x18,	0x0c,	0x10,	0x07,		0],
	["NSS3_MCS5",	RateType_VHT | 0x19,	0x0c,	0x10,	0x07,		0],
	["NSS3_MCS6",	RateType_VHT | 0x1a,	0x0c,	0x10,	0x07,		0],
	["NSS3_MCS7",	RateType_VHT | 0x1b,	0x0c,	0x10,	0x07,		0],
	["NSS3_MCS8",	RateType_VHT | 0x1c,	0x0c,	0x10,	0x07,		0],
	["NSS3_MCS9",	RateType_VHT | 0x1d,	0x0c,	0x10,	0x07,		0],

	["NSS4_MCS0",	RateType_VHT | 0x1e,	0x08,	0x10,	0x07,		0],
	["NSS4_MCS1",	RateType_VHT | 0x1f,	0x08,	0x10,	0x07,		0],
	["NSS4_MCS2",	RateType_VHT | 0x20,	0x08,	0x10,	0x07,		0],
	["NSS4_MCS3",	RateType_VHT | 0x21,	0x08,	0x10,	0x07,		0],
	["NSS4_MCS4",	RateType_VHT | 0x22,	0x08,	0x10,	0x07,		0],
	["NSS4_MCS5",	RateType_VHT | 0x23,	0x08,	0x10,	0x07,		0],
	["NSS4_MCS6",	RateType_VHT | 0x24,	0x08,	0x10,	0x07,		0],
	["NSS4_MCS7",	RateType_VHT | 0x25,	0x08,	0x10,	0x07,		0],
	["NSS4_MCS8",	RateType_VHT | 0x26,	0x08,	0x10,	0x07,		0],
	["NSS4_MCS9",	RateType_VHT | 0x27,	0x08,	0x10,	0x07,		0],

	//HE - 11ax
	//Label			Value					ANT		WMODE	BANDWIDTH	CurrentAvail
	["HE_1_MCS0",	RateType_HE | 0x00,		0x0f,	0x20,	0x0f,		0],
	["HE_1_MCS1",	RateType_HE | 0x01,		0x0f,	0x20,	0x0f,		0],
	["HE_1_MCS2",	RateType_HE | 0x02,		0x0f,	0x20,	0x0f,		0],
	["HE_1_MCS3",	RateType_HE | 0x03,		0x0f,	0x20,	0x0f,		0],
	["HE_1_MCS4",	RateType_HE | 0x04,		0x0f,	0x20,	0x0f,		0],
	["HE_1_MCS5",	RateType_HE | 0x05,		0x0f,	0x20,	0x0f,		0],
	["HE_1_MCS6",	RateType_HE | 0x06,		0x0f,	0x20,	0x0f,		0],
	["HE_1_MCS7",	RateType_HE | 0x07,		0x0f,	0x20,	0x0f,		0],
	["HE_1_MCS8",	RateType_HE | 0x08,		0x0f,	0x20,	0x0f,		0],
	["HE_1_MCS9",	RateType_HE | 0x09,		0x0f,	0x20,	0x0f,		0],
	["HE_1_MCS10",	RateType_HE | 0x0a,		0x0f,	0x20,	0x0f,		0],
	["HE_1_MCS11",	RateType_HE | 0x0b,		0x0f,	0x20,	0x0f,		0],

	["HE_2_MCS0",	RateType_HE | 0x0c,		0x0e,	0x20,	0x0f,		0],
	["HE_2_MCS1",	RateType_HE | 0x0d,		0x0e,	0x20,	0x0f,		0],
	["HE_2_MCS2",	RateType_HE | 0x0e,		0x0e,	0x20,	0x0f,		0],
	["HE_2_MCS3",	RateType_HE | 0x0f,		0x0e,	0x20,	0x0f,		0],
	["HE_2_MCS4",	RateType_HE | 0x10,		0x0e,	0x20,	0x0f,		0],
	["HE_2_MCS5",	RateType_HE | 0x11,		0x0e,	0x20,	0x0f,		0],
	["HE_2_MCS6",	RateType_HE | 0x12,		0x0e,	0x20,	0x0f,		0],
	["HE_2_MCS7",	RateType_HE | 0x13,		0x0e,	0x20,	0x0f,		0],
	["HE_2_MCS8",	RateType_HE | 0x14,		0x0e,	0x20,	0x0f,		0],
	["HE_2_MCS9",	RateType_HE | 0x15,		0x0e,	0x20,	0x0f,		0],
	["HE_2_MCS10",	RateType_HE | 0x16,		0x0e,	0x20,	0x0f,		0],
	["HE_2_MCS11",	RateType_HE | 0x17,		0x0e,	0x20,	0x0f,		0],

	["HE_3_MCS0",	RateType_HE | 0x18,		0x0c,	0x20,	0x07,		0],
	["HE_3_MCS1",	RateType_HE | 0x19,		0x0c,	0x20,	0x07,		0],
	["HE_3_MCS2",	RateType_HE | 0x1a,		0x0c,	0x20,	0x07,		0],
	["HE_3_MCS3",	RateType_HE | 0x1b,		0x0c,	0x20,	0x07,		0],
	["HE_3_MCS4",	RateType_HE | 0x1c,		0x0c,	0x20,	0x07,		0],
	["HE_3_MCS5",	RateType_HE | 0x1d,		0x0c,	0x20,	0x07,		0],
	["HE_3_MCS6",	RateType_HE | 0x1e,		0x0c,	0x20,	0x07,		0],
	["HE_3_MCS7",	RateType_HE | 0x1f,		0x0c,	0x20,	0x07,		0],
	["HE_3_MCS8",	RateType_HE | 0x20,		0x0c,	0x20,	0x07,		0],
	["HE_3_MCS9",	RateType_HE | 0x21,		0x0c,	0x20,	0x07,		0],
	["HE_3_MCS10",	RateType_HE | 0x22,		0x0c,	0x20,	0x07,		0],
	["HE_3_MCS11",	RateType_HE | 0x23,		0x0c,	0x20,	0x07,		0],

	["HE_4_MCS0",	RateType_HE | 0x24,		0x08,	0x20,	0x07,		0],
	["HE_4_MCS1",	RateType_HE | 0x25,		0x08,	0x20,	0x07,		0],
	["HE_4_MCS2",	RateType_HE | 0x26,		0x08,	0x20,	0x07,		0],
	["HE_4_MCS3",	RateType_HE | 0x27,		0x08,	0x20,	0x07,		0],
	["HE_4_MCS4",	RateType_HE | 0x28,		0x08,	0x20,	0x07,		0],
	["HE_4_MCS5",	RateType_HE | 0x29,		0x08,	0x20,	0x07,		0],
	["HE_4_MCS6",	RateType_HE | 0x2a,		0x08,	0x20,	0x07,		0],
	["HE_4_MCS7",	RateType_HE | 0x2b,		0x08,	0x20,	0x07,		0],
	["HE_4_MCS8",	RateType_HE | 0x2c,		0x08,	0x20,	0x07,		0],
	["HE_4_MCS9",	RateType_HE | 0x2d,		0x08,	0x20,	0x07,		0],
	["HE_4_MCS10",	RateType_HE | 0x2e,		0x08,	0x20,	0x07,		0],
	["HE_4_MCS11",	RateType_HE | 0x2f,		0x08,	0x20,	0x07,		0]
];

function updateDataRate(elDataRate, defVal, 
	freqType, bandMode, wirelessMode, bandwidth){
	
	var idx = 0;
	var totalRate = 0;
	var compValBandMode = 0;
	var compValBandWidth = 0;
	
	// db (BANDMODE_STREAM) -> script define
	if( freqType == '1' ){
		//2.4G
		if( (bandMode & 0x0f00) != 0 ){
			compValBandMode = (bandMode & 0x0f00) >> 8;
		}else{
			compValBandMode = 0x02;	//default 2T2R
		}
	}else{
		//5G
		if( (bandMode & 0x00f0) != 0 ){
			compValBandMode = (bandMode & 0x00f0) >> 4;
		}else{
			compValBandMode = 0x02;	//default 2T2R
		}
	}
	
	// bandwidth
	if( bandwidth == CH_BW_5G_80_80M ){
		bandwidth = 0x03;	//data rate 80_80 == 160
	}
	compValBandWidth = 1 << (bandwidth & 0x1f);
	
	for( var i = 0; i < DataRate_MCS.length; i++ ){
		if( (DataRate_MCS[i][DataRate_MCS_ANT_COL] & compValBandMode) != 0 &&
			(DataRate_MCS[i][DataRate_MCS_WMODE_COL] & wirelessMode) != 0 &&
			(DataRate_MCS[i][DataRate_MCS_BANDWIDTH_COL] & compValBandWidth) != 0 ){
				
			DataRate_MCS[i][DataRate_MCS_CURRENT_COL] = 1;
			totalRate++;
		}else{
			DataRate_MCS[i][DataRate_MCS_CURRENT_COL] = 0;
		}
	}
	
	//clear
	elDataRate.options.length = 0;
	//set Data
	elDataRate.options.length = totalRate;

	for( var i = 0; i < DataRate_MCS.length; i++ ){
		if( DataRate_MCS[i][DataRate_MCS_CURRENT_COL] == 1 ){
			elDataRate.options[idx] = new Option(DataRate_MCS[i][DataRate_MCS_LABEL_COL], DataRate_MCS[i][DataRate_MCS_VALUE_COL]);
			idx++;
		}
	}
	if( defVal != -1 && defVal != null ){
		initCombo( elDataRate, defVal );
	}
}

/* Select-Option Sort */
function compareOptionText(a,b) {
	/*
	* return >0 if a>b
	* 0 if a=b
	* <0 if a<b
	*/
	//Auto는 최상위 - IE와 FF의 Sort처리 순서가 다름
	if( a.text == 'Auto' ) return -1;
	if( b.text == 'Auto' ) return 1;
	
	// textual comparison
	if( isDigit(a.text) && isDigit(b.text) ){
		return parseInt(a.text) - parseInt(b.text);
	}else{
		return a.text!=b.text ? a.text<b.text ? -1 : 1 : 0;
	}
}

function sortOptions(list) {
	var items = list.options.length;

	// create array and make copies of options in list
	var tmpArray = new Array(items);
	for ( i=0; i<items; i++ )
		tmpArray[i] = new Option(list.options[i].text, list.options[i].value);

	// sort options using given function
	tmpArray.sort(compareOptionText);
	
	// make copies of sorted options back to list
	for ( i=0; i<items; i++ )
		list.options[i] = new Option(tmpArray[i].text, tmpArray[i].value);
}

//end of file
