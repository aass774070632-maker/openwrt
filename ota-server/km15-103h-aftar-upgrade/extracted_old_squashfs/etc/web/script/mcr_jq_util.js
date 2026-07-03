/*!
 * jQuery Utility
 * 
 *	Copyright (c) Mercury Corporation All Rights Reserved.
 *
 *  Created on: 2014. 07. 24
 *  Author: HJKIM
 */
(function($){
	/////////////////////////////////
	// Mouse Event - context menu, select disable
	var select_exceptions = [ "INPUT", "TEXTAREA", "SELECT" ].join(",");
	
	//for IE, Chrome, Safari
	function onSelectStart(e){
		if( select_exceptions.indexOf( e.target.tagName ) == -1 )
			return false;
		return true;
	}
	
	function onMouseDown(e){
		if( typeof document.onselectstart == "undefined" ){
			//for ff
			if( select_exceptions.indexOf( e.target.tagName ) == -1 )
				return false;
		}
		return true;
	}
	
    $.fn.mjq_disableSelection = function() {
        return this
        .attr('unselectable', 'on')
        .css('user-select', 'none')
        .css('-moz-user-select', 'none')
        .css('-khtml-user-select', 'none')
        .css('-webkit-user-select', 'none')
        .on('selectstart', onSelectStart)
        .on('mousedown', onMouseDown)
        .on('contextmenu', false);
    };
 
    $.fn.mjq_enableSelection = function() {
        return this
        .attr('unselectable', '')
        .css('user-select', '')
        .css('-moz-user-select', '')
        .css('-khtml-user-select', '')
        .css('-webkit-user-select', '')
        .off('selectstart', false)
        .off('mousedown', false)
        .off('contextmenu', false);
    };
 
	/////////////////////////////////
	// input
 	function onEnter(e){
 		var code = e.keyCode || e.which;
 		if( code == 13 ){	//Enter Keycode
 			//do nothing
 			return false;
 		}
 	}
 	
 	$.fn.mjq_disableInputEnter = function() {
 		return this.bind("keypress", onEnter);
 	};
})(jQuery);
