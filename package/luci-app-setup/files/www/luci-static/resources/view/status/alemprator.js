'use strict';
'use rpc';

var callSystemInfo = L.rpc.declare({ object: 'system', method: 'info' });
var callSystemBoard = L.rpc.declare({ object: 'system', method: 'board' });

return L.view.extend({
    load: function() {
        var head = document.getElementsByTagName('head')[0];
        var link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = L.resource('alemprator.css') + '?v=' + new Date().getTime();
        head.appendChild(link);
        return Promise.all([ callSystemInfo(), callSystemBoard() ]);
    },
    render: function(data) {
        var info = data[0] || {};
        var board = data[1] || {};
        document.body.classList.add('alemprator-setup-body');
        var memPerc = Math.floor(((info.memory.total - info.memory.available) / info.memory.total) * 100);
        var loadPerc = Math.floor((info.load[0] / 65535) * 100);
        var brand = document.querySelector('header a.brand') || document.querySelector('header a');
        if (brand) brand.innerHTML = '♛ <span style="color:#D4AF37; font-weight:bold; letter-spacing:2px">ALEMPRATOR</span>';
        return L.dom.create('div', { 'class': 'cbi-map' }, [
            L.dom.create('div', { 'style': 'text-align:center; padding:40px; direction:rtl' }, [
                L.dom.create('h2', { 'style': 'color:#D4AF37; font-size:3rem' }, 'ALEMPRATOR PLATINUM'),
                L.dom.create('div', { 'class': 'platinum-card', 'style': 'max-width:800px; margin:auto; padding:30px' }, [
                    L.dom.create('p', {}, 'MODEL: ' + (board.model || 'KM14')),
                    L.dom.create('p', {}, 'CPU: ' + loadPerc + '%'),
                    L.dom.create('p', {}, 'RAM: ' + memPerc + '%')
                ])
            ])
        ]);
    },
    handleSaveApply: null, handleSave: null, handleReset: null
});