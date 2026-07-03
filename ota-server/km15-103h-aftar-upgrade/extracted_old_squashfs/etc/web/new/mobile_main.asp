<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
</head>
<script language='JavaScript' type='text/javascript' src='/script/mcr_progress.js?version=<% mcr_getWebVersion(); %>'></script>
<script>
var mcrProgress = null;
function initProgress(){
        mcrProgress = new MCRProgress(MCRProgress.TYPE_LAYOUT_FRAMESET,
                        document,
                        "div_detail_contents",
                        "div_admin_progress",
                        admin_progress );
}

function initValue(){
        initProgress();
}

</script>
<frameset frameborder=NO border=0 framespacing=0 onload="initValue();">
        <frameset name="div_detail_contents" id="div_detail_contents" rows="99.999%,*" frameborder=NO border=0 framespacing=0">
                <frame scrolling=yes src="/mobile.asp">
                <frame name="admin_progress" id="admin_progress" scrolling=yes src="/new/mobile_common_progress.asp">
        </frameset>
</frameset>
</html>
