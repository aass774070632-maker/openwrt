
/* ==================================================
	for Progress bar (apply)
   ================================================== */
MCRProgress.TYPE_LAYOUT_FRAMESET 	= 0x01;
MCRProgress.TYPE_LAYOUT_DIV		 	= 0x02;

function MCRProgress(
		typeLayout,			//TYPE_LAYOUT_*
		objDocument,
		strViewID,			//frameLayout - view, progress 포함하고있는 frameset id, div - view (iframe)를 포함하는 div id
		strProgressID,		//frameLayout - 미사용, div - progress (iframe)를 포함하는 div id
		objWindowProgress	//progress.asp에 대한 frame 또는 iframe - 함수호출
//		strCmdType,			//dummy
//		strUrl,				//dummy
//		strMessage,			//display message
//		nTimeout			//wait time sec
	){
	this.typeLayout = typeLayout;
	this.objDocument = objDocument;
	this.strViewID = strViewID;
	this.strProgressID = strProgressID;
	this.objWindowProgress = objWindowProgress;
//	this.strCmdType = strCmdType;
//	this.strUrl = strUrl;
//	this.strMessage = strMessage;
//	this.nTimeout = nTimeout;

	this.timeoutCycle = 1000;
	this.initValues();

	//timer 처리를 위한 global 변수등록	(변수선언을 따로하면 오류발생하니 변수선언은 하지 않는다)
	gProgressInstance = this;
}

MCRProgress.prototype.initValues = function(){
	if( this.timer != null ){
		clearTimeout( this.timer );
		this.timer = null;
	}
	
	this.timeIncrement = 0;
	this.timeCount = 0;
	this.progressRatio = 0;
	this.timeout = 0;
	this.strMessage = "";
	this.strCommand = "";
}

/*
 *	FrameSet일 경우 view가 위쪽에 progress는 아래쪽에 있어야 함.
 */
MCRProgress.prototype.swapDisplay = function(flag){
	if( flag == 0 ){
		//progress display
		if( this.typeLayout == MCRProgress.TYPE_LAYOUT_FRAMESET ){
			this.objDocument.getElementById( this.strViewID ).rows = "0%,100%";
		}else if( this.typeLayout == MCRProgress.TYPE_LAYOUT_DIV ){
			this.objDocument.getElementById( this.strViewID ).style.display = "none";	//hide
			this.objDocument.getElementById( this.strProgressID ).style.display = "";	//show
		}
	}else if( flag == 1 ){
		if( this.typeLayout == MCRProgress.TYPE_LAYOUT_FRAMESET ){
			this.objDocument.getElementById( this.strViewID ).rows = "100%,0%";
		}else if( this.typeLayout == MCRProgress.TYPE_LAYOUT_DIV ){
			this.objDocument.getElementById( this.strViewID ).style.display = "";
			this.objDocument.getElementById( this.strProgressID ).style.display = "none";
		}
	}
}

MCRProgress.prototype.startProgress = function(
		strCmdType,			//dummy
		nTimeout,			//wait time sec
		strUrl,				//dummy
		strMessage			//display message
	){
	
	this.initValues();
	
	this.strCmdType = strCmdType;
	this.strMessage = strMessage;
	this.strUrl = strUrl;
	this.timeout = nTimeout;
	this.timeCount = nTimeout;
	
	this.swapDisplay(0);
	
	this.timeIncrement = 1.0 / this.timeout;
	this.setMessage();
	this.setProgressBar(0);
	
	this.refreshPage();
	
	this.timer = setTimeout(progressTimer, this.timeoutCycle);	//1sec 마다 호출
}

MCRProgress.prototype.startProgressSimple = function(
		strCmdType,			//dummy
		nTimeout			//wait time sec
){
	var strMessage = "";
	
	if( strCmdType == "apply" ){
		strMessage = "설정중입니다. 잠시 기다려주십시오. ";
	}
	
	this.startProgress(strCmdType, nTimeout, null, strMessage);
}

MCRProgress.prototype.stopProgress = function(){
	this.swapDisplay(1);
	this.initValues();
}

MCRProgress.prototype.refreshPage = function(){
	if( this.typeLayout == MCRProgress.TYPE_LAYOUT_DIV ){
		this.objWindowProgress.mcr_refreshPage();
	}
}
////////////////////////////////////////////////////
// timer action - timer는 member 함수를 call할수 없으므로 일반 함수사용
function progressTimer(){
	if( gProgressInstance == null ) return;
	
	gProgressInstance.progressRatio = gProgressInstance.progressRatio + gProgressInstance.timeIncrement;
	gProgressInstance.timeCount = gProgressInstance.timeCount - 1;
	gProgressInstance.setMessage();
	
	if( gProgressInstance.timeCount > 0 ){
		gProgressInstance.timer = setTimeout(progressTimer, gProgressInstance.timeoutCycle);	//1sec 마다 호출
		gProgressInstance.setProgressBar(gProgressInstance.progressRatio);
	}else{
		gProgressInstance.setProgressBar(gProgressInstance.progressRatio);
		//Timer 등록하지 않음
		 if( gProgressInstance.typeLayout == MCRProgress.TYPE_LAYOUT_FRAMESET ) {
                        history.back();
                }
		gProgressInstance.stopProgress();
	}
}

////////////////////////////////////////////////////
// UI
MCRProgress.prototype.setMessage = function(){
	if( this.strMessage != null ){
		var strMsg = this.strMessage + "("+this.timeCount+")"
		this.objWindowProgress.mcr_setMessage(strMsg);
		//this.objWindowProgress.document.getElementById("uiProgressMessage").translateLabelHTML( strMsg );
	}
}

MCRProgress.prototype.setProgressBar = function(ratio){
	//this.objWindowProgress.uiProgress.setBar(ratio);
	this.objWindowProgress.mcr_setProgressBar(ratio);
}
