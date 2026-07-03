/*
 * javascript dynamic table 생성
 *	div 의 innerHTML 영역을 대체하는 방식
 *
 *	[Usage]
 *	1. 테이블 생성
 *		table = new MCRTable( ... );
 *	2. column 추가
 *		table.addColumn(MCRColumn.TYPE_CHECKBOX ... )
 *		table.addColumn(MCRColumn.TYPE_NORMAL ... )
 *	3. 데이터 설정
 *		table.setRows(data);
 *		table.setRows(null);	//데이터 clear
 *	4. table 표시
 *		table.layout();
 */
 
MCRTable.TYPE_TABLE_USE_TABLE_HEADER 	= 0x01;
MCRTable.TYPE_TABLE_USE_COL 			= 0x02;
MCRTable.TYPE_TABLE_USE_TH 				= 0x04;
 
//////////////////////////////
// Table Layout
MCRTable.isEmpty = function( data ){
	if( data == null || data == "" ) return true;
	return false;
}

/*
	Table Constructor
		Table layout을 위한 객체를 생성한다.
		
	strReplaceDiv 	: replace 할 div id
	strTableAttr 	: <table> tag 내에 사용할 attr string
	tableType		: TYPE_TABLE_*
	strHeaderTrAttr	: table header <th> tag attr string
	strTrAttr		: data 영역의 <tr> tag attr - 모든 data row에 대해서 동일해야 함
	strEmpty		: data row가 없을 경우 출력할 String
	strSplit		: data column split token
	convFormatCallback : data column 을 Table에 표시하기 위한 convert function
		callback function은 
			function parseData(nRowIdx, aColumns, aRow, strSplit) 의 형태로 구현되어야 함
				nRowIdx 	: 현재 display할 row (0~)
				aColumns 	: MCRColumn 객체 array
				aRow		: datarow에서 추출한 현재의 row data
				strSplit	: aRow를 split 할 token
				return		: 화면에 display할 column 정보 array (string)
								최초 index가 MCRColumn.TYPE_CHECKBOX type인 경우
								최초 index는 name, value 형태의 array로 사용할 수 있다 (checkbox의 name/id 와 value에 사용됨)
*/	
function MCRTable(
	strReplaceDiv, 					//display div
	tableType,						//tableType
	strTableAttr, 					//attr - table
	strHeaderTrAttr, 				//attr - header
	strTrAttr, 						//attr - tr (data)
	strEmpty, strSplit, convFormatCallback){
	//config
	this.tableType = tableType;							//Mandatory
	this.strTableAttr = strTableAttr;					//Mandatory
	this.strReplaceDiv = strReplaceDiv;					//Mandatory
	this.strHeaderTrAttr = strHeaderTrAttr;				//Mandatory
	this.strTrAttr = strTrAttr;							//Mandatory
	this.strSplit = strSplit;							//Mandatory
	this.convFormatCallback = convFormatCallback;		//Mandatory
	this.strEmpty = strEmpty;							//Mandatory
	
	this.aColumns = [];
	this.aRows = [];
	
	//2011.03.21 user define bottom row
	this.strBottomRow = "";
	//2011.03.21 append user define row
	//2018.05.18 append empty image
	this.strEmptyImage = "";
}

MCRTable.prototype.addColumn = function(type, name, strColAttr, strThAttr, strTdAttr, strOnClick){
	this.aColumns[this.aColumns.length] = new MCRColumn(type, name, strColAttr, strThAttr, strTdAttr, strOnClick);
}

MCRTable.prototype.setRows = function(aRows){
	this.aRows = aRows;
}

MCRTable.prototype.setEmptyString = function(strEmpty){
	this.strEmpty = strEmpty;
}

//2011.03.21 append user define row
MCRTable.prototype.setBottomRow = function(strBottomRow){
	this.strBottomRow = strBottomRow;
}
//2011.03.21 append user define row
//2018.05.18 append empty image
MCRTable.prototype.setEmptyImage = function(strEmptyImage){
	this.strEmptyImage = strEmptyImage;
}

MCRTable.prototype.toString = function(){
	var nRow, nCol, nColOffset;
	var aCols = null;
	var str = "";
	
	if( this.tableType & MCRTable.TYPE_TABLE_USE_TABLE_HEADER ){
		str += "<table "+this.strTableAttr+">\r\n";
	}
	
	if( this.tableType & MCRTable.TYPE_TABLE_USE_COL ){
		for( nCol = 0; nCol < this.aColumns.length; nCol++ ){
			str += this.aColumns[nCol].getCol();
		}
	}
	
	if( this.tableType & MCRTable.TYPE_TABLE_USE_TH ){
		//Table Header
		if( MCRTable.isEmpty(this.strHeaderTrAttr) ){
			str += "<tr>";
		}else{
			str += "<tr "+ this.strHeaderTrAttr +">";
		}
		for( nCol = 0; nCol < this.aColumns.length; nCol++ ){
			str += this.aColumns[nCol];
		}
		str += "</tr>\r\n";
	}
	
	if( this.aRows == null || this.aRows.length == 0 ){
		//row empty
		/*
		str += "<tr><td colspan='"+this.aColumns.length+"' align='center'><label>"+this.strEmpty+"</label></td></tr>";
		*/
		if( MCRTable.isEmpty(this.strTrAttr) ){
			str += "<tr>\r\n";
		}else{	
			str += "<tr "+this.strTrAttr+">\r\n";
		}

		if( MCRTable.isEmpty(this.strEmptyImage) ){
			str += "<td colspan='"+this.aColumns.length+"' align='left'><label>"+this.strEmpty+"</label>";
			str += "</td></tr>";
		}else{
			str += "<td colspan='"+this.aColumns.length+"' align='left'>"+this.strEmptyImage;
			str += "</td></tr>";
		}
	}else{
		//Table Row
		for( nRow = 0; nRow < this.aRows.length; nRow++) {
			if( this.aRows[nRow] != null && this.aRows[nRow].length > 0 ){
				//2011.03.18
				//특정 row는 parsing 단계에서 안보이도록 처리하는 기능 추가
				//출력할 format으로 변경
				aColData = this.convFormatCallback(nRow, this.aColumns, this.aRows[nRow], this.strSplit);
				if( aColData == null || aColData == '' ){
					continue;
				}
				//2011.03.18

				nColOffset = 0;
				if( MCRTable.isEmpty(this.strTrAttr) ){
					str += "<tr>\r\n";
				}else{	
					str += "<tr "+this.strTrAttr+">\r\n";
				}
			
				//checkbox
				if( this.aColumns[0].type & MCRColumn.TYPE_CHECKBOX ){
					if( MCRTable.isEmpty(this.aColumns[0].strTdAttr) ){
						str += "<td align='center'>";
					}else{
						str += "<td align='center' "+this.aColumns[0].strTdAttr+">";
					}
					//name, value pair
					if( aColData[0].length == 2 ){
						var aCheckElement = aColData[0];
						str += "<input type='checkbox' id='"+aCheckElement[0]+"' name='"+aCheckElement[0]+"' value='"+aCheckElement[1]+"'></input></td>\r\n";
					}else{
						str += "<input type='checkbox' id='"+aColData[0]+"' name='"+aColData[0]+"' value='"+nRow+"'></input></td>\r\n";
					}
					nColOffset = 1;
				}
				//checkbox 이외의 데이터
				for( nCol = nColOffset; nCol < this.aColumns.length; nCol++){
					if( MCRTable.isEmpty(this.aColumns[nCol].strTdAttr) ){
						str += "<td>"
					}else{
						str += "<td "+this.aColumns[nCol].strTdAttr+">"
					}
					str += aColData[nCol]+"</td>\r\n";
				}
				str += "</tr>\r\n";
			}
		}
	}
	
	//2011.03.21 append user define row
	if( MCRTable.isEmpty(this.strBottomRow) == false ){
		if( MCRTable.isEmpty(this.strTrAttr) ){
			str += "<tr>\r\n";
		}else{	
			str += "<tr "+this.strTrAttr+">\r\n";
		}
		
		//set row body
		str += this.strBottomRow;
		//end row
		str += "</tr>\r\n";
	}
	//2011.03.21 append user define row
	
	//Table Tail
	if( this.tableType & MCRTable.TYPE_TABLE_USE_TABLE_HEADER ){
		str += "</table>\r\n";
	}
	return str;
}

MCRTable.prototype.layout = function(){
	var e = document.getElementById(this.strReplaceDiv);
	
	if( e != null ){
		e.innerHTML = this.toString();
	}
}

////////////////////////////////////
/*
	Column Constructor
	type : column type define
		TYPE_CHECKBOX	- 선택을 위한 checkbox (현재는 0번째 column에서만 사용가능)
		TYPE_NORMAL - 일반 text
		TYPE_IMGBTN - image button 인 경우(특별한 처리 불필요?) - callback에서 처리
	name : column name - header 가 표시될 경우 header에 출력됨
	strColAttr : <col> tag attr
	strThAttr : <th> tag attr
	strTdAttr : <td> tag attr - data row
	strOnClink : click event 처리 (TYPE_CHECKBOX 일때만 의미있음)
*/	
function MCRColumn(type, name, strColAttr, strThAttr, strTdAttr, strOnClick){
	this.type = type;
	this.name = name;
	this.strColAttr = strColAttr;
	this.strThAttr = strThAttr;
	this.strTdAttr = strTdAttr;
	this.strOnClick = strOnClick;
}

// Column Type define
MCRColumn.TYPE_CHECKBOX 	= 0x01;		//checkbox
MCRColumn.TYPE_NORMAL 		= 0x02;		//normal column
MCRColumn.TYPE_IMGBTN 		= 0x04;		//image button
//MCRColumn.TYPE_SIZEONLY 	= 0x08;		//<th> tag 사용하지 않음 - header 출력이 불필요한경우

MCRColumn.prototype.toString = function() {
	var str = "";
	var strCheckName = this.name+"_all";
	
	if( this.type & MCRColumn.TYPE_CHECKBOX ){
		if( MCRTable.isEmpty(this.strThAttr) ){
			str = "<th align='center'>";
		}else{
			str = "<th align='center' "+this.strThAttr+">";
		}
		str += "<input type='checkbox' value='1' id='"+strCheckName+"' name='"+strCheckName+"' onclick='"+this.strOnClick+"'/></th>\r\n";
	}else if( this.type & MCRColumn.TYPE_NORMAL ){
		if( MCRTable.isEmpty(this.strThAttr) ){
			str = "<th>";
		}else{
			str = "<th "+this.strThAttr+">";
		}
		str += this.name+"</th>\r\n";
	}
	return str;
}

MCRColumn.prototype.getCol = function() {
	var str = "";

	if( MCRTable.isEmpty(this.strColAttr) ){
		str = "<col> </col>\r\n";
	}else{
		str = "<col "+this.strColAttr+"></col>\r\n";
	}
	return str;
}
