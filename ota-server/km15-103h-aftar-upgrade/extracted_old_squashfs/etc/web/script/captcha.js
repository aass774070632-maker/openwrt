(function (window, document, $, undefined) {

    //var possibleCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    var possibleCharacters = "abcdefghijklmnopqrstuvwxyz";

    var defaults = {

        selector: "#captcha",
        text: null,
        randomText: true,
        randomColours: false,
        width: 300,
        height: 44,
        colour1: "#000000",
        colour2: "#000000",
        font: 'bold 51px "Elephant"',
        onSuccess: function () { alert('Correct!'); }
    };

    var CAPTCHA = function (config) {

        var that = this;

        this._settings = $.extend({}, defaults, config || {});

        this._container = $(this._settings.selector);

        //var controlWrapper = $('<div>').appendTo(this._container);

        /*
        this._input = $('<input>').addClass('user-text')
                        .bind('keypress', function (e) {
                            if (e.which == 13) {
                                that.validate(that._input.val());
                            }
                        })
                        .appendTo(controlWrapper);

        this._button = $('<button>').text('submit')
                        .addClass('validate')
                        .bind('click', function () { that.validate(that._input.val()); })
                        .appendTo(controlWrapper);
        */
        var canvasWrapper = $('<div>').appendTo(this._container);

        this._canvas = $('<canvas>').appendTo(canvasWrapper).attr("style","border:1px;border-color:#c0c0c0;border-style:solid;").width(this._settings.width).height(this._settings.height);
        
        if (typeof G_vmlCanvasManager != 'undefined') {
               canvas = G_vmlCanvasManager.initElement(this._canvas.get(0));
        }  
        this._context = this._canvas.get(0).getContext("2d");

    };

    CAPTCHA.prototype = {

        generate: function () {

            var context = this._context;

            //if there's no text, set the flag to randomly generate some
            if (this._settings.text == null || this._settings.text == '') {
                this._settings.randomText = true;
            }

            if (this._settings.randomText) {
                this._generateRandomText();
            }

            if (this._settings.randomColours) {
                this._settings.colour1 = this._generateRandomColour();
                this._settings.colour2 = this._generateRandomColour();
            }

            var gradient1 = context.createLinearGradient(0, 0, this._settings.width, 0);
            gradient1.addColorStop(0, this._settings.colour1);
            gradient1.addColorStop(1, this._settings.colour2);

            context.fillStyle = gradient1;
            //context.fillRect(0, 0, this._settings.width, this._settings.height);

            var gradient2 = context.createLinearGradient(0, 0, this._settings.width, 0);
            gradient2.addColorStop(0, this._settings.colour2);
            gradient2.addColorStop(1, this._settings.colour1);

            context.font = this._settings.font;
            //context.fillStyle = gradient2;

            if (typeof G_vmlCanvasManager != 'undefined') {
            context.setTransform((Math.random() / 5) + 0.5,    //scalex
            //context.setTransform(0.4,    //scalex
                                0.1 - (Math.random() / 8),      //skewx
                                0.1 - (Math.random() / 2),      //skewy
                                (Math.random() / 5) + 0.5,     //scaley
                                //2.0,     //scaley
                                (Math.random() * 20) + 80,      //transx
                                35);                           //transy
            }
            else {
            context.setTransform((Math.random() / 5) + 0.5,    //scalex
            //context.setTransform(0.4,    //scalex
                                0.1 - (Math.random() / 5),      //skewx
                                0.1 - (Math.random() / 5),      //skewy
                                (Math.random() / 5) + 2.0,     //scaley
                                //2.0,     //scaley
                                (Math.random() * 20) + 100,      //transx
                                120);                           //transy
            }
            context.fillText(this._settings.text, 0, 0);

            //context.setTransform(1, 0, 0, 1, 0, 0);

            //var numRandomCurves = Math.floor((Math.random() * 6) + 5);
            var numRandomCurves = 1;

            for (var i = 0; i < numRandomCurves; i++) {
                this._drawRandomCurve();
            }
        },

        validate: function (userText) {
		if (userText === this._settings.text) {
                	return true;
                	//this._settings.onSuccess();
		} else if(userText === "" || userText === "여기에 아래의 문자를 입력하세요" ){
                	alert("보안키가 입력되지 않았습니다.");
                	refreshCaptcha();
			$('#captchatext').val("");
                	return false;
		}else{
                	alert("보안키가 맞지 않습니다.");
                	//this.generate();
                	refreshCaptcha();
			$('#captchatext').val("");
                	return false;
            	}
        },

        _drawRandomCurve: function () {

            var ctx = this._context;

            var gradient1 = ctx.createLinearGradient(0, 0, this._settings.width, 0);
            gradient1.addColorStop(0, Math.random() < 0.5 ? this._settings.colour1 : this._settings.colour2);
            gradient1.addColorStop(1, Math.random() < 0.5 ? this._settings.colour1 : this._settings.colour2);

            //ctx.lineWidth = Math.floor((Math.random() * 4) + 2);
            ctx.lineWidth = 3;
            ctx.strokeStyle = gradient1;
            ctx.beginPath();
            //ctx.moveTo(Math.floor((Math.random() * this._settings.width)), Math.floor((Math.random() * this._settings.height)));
            ctx.moveTo(-10,-20);
            //ctx.bezierCurveTo(Math.floor((Math.random() * this._settings.width)), Math.floor((Math.random() * this._settings.height)),
            //    Math.floor((Math.random() * this._settings.width)), Math.floor((Math.random() * this._settings.height)),
            //    Math.floor((Math.random() * this._settings.width)), Math.floor((Math.random() * this._settings.height)));
            ctx.bezierCurveTo(Math.floor((Math.random() * 250)), Math.floor((Math.random() * -60)),
                Math.floor((Math.random() * 250)), Math.floor((Math.random() * 30)),
                Math.floor(200), Math.floor((Math.random() * -50)));
            //ctx.bezierCurveTo((Math.random() *50),10,(Math.random() *50),10,200,(Math.random() *30));
            ctx.stroke();
        },

        _generateRandomText: function () {
            this._settings.text = '';
            //var length = Math.floor((Math.random() * 3) + 6);
            var length = 5;
            for (var i = 0; i < length; i++) {
                this._settings.text += possibleCharacters.charAt(Math.floor(Math.random() * possibleCharacters.length));
            }
	    $('#captchadata').val(this._settings.text);
        },

        _generateRandomColour: function () {
            return "rgb(" + Math.floor((Math.random() * 255)) + ", " + Math.floor((Math.random() * 255)) + ", " + Math.floor((Math.random() * 255)) + ")";
        }
    };

    window.CAPTCHA = CAPTCHA || {};

}(window, document, jQuery));
