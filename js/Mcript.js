var modal = "";
var player = "";
var isFullscreen = 1;

document.addEventListener("fullscreenchange", FShandler);
document.addEventListener("webkitfullscreenchange", FShandler);
document.addEventListener("mozfullscreenchange", FShandler);
document.addEventListener("MSFullscreenChange", FShandler);
document.addEventListener("keydown", function (e) {
    if (e.keyCode === 70) {
	e.preventDefault();
	e.stopPropagation();
        if (isFullscreen % 2 === 0) {
            if (document.exitFullscreen) {
                document.exitFullscreen();
            } else if (document.webkitExitFullscreen) {
                document.webkitExitFullscreen();
            } else if (document.mozCancelFullScreen) {
                document.mozCancelFullScreen();
            } else if (document.msExitFullscreen) {
                document.msExitFullscreen();
            }
        } else {
            if (player.requestFullscreen) {
                player.requestFullscreen();
            } else if (player.msRequestFullscreen) {
                player.msRequestFullscreen();
            } else if (player.mozRequestFullScreen) {
                player.mozRequestFullScreen();
            } else if (player.webkitRequestFullscreen) {
                player.webkitRequestFullscreen();
            }
        }
    } else if (e.keyCode === 37) {
	e.preventDefault();
	e.stopPropagation();
        player.currentTime -= 5;
    } else if (e.keyCode === 39) {
	e.preventDefault();
	e.stopPropagation();
        player.currentTime += 5;
    } else if (e.keyCode === 32) {
	e.preventDefault();
	e.stopPropagation();
        if(player.paused){
                player.play();
        } else {
                player.pause();
        }
    }
}, false);

function FShandler() {
    isFullscreen++;
}

function showModal(elem){
	var tempStr = elem.id;
	tempStr = tempStr.replace("A", "B");
	modal = document.getElementById(String(tempStr));
        tempStr = tempStr.replace("B", "C");
        player = document.getElementById(String(tempStr));
	modal.style.display = "block";
}

function hideModal(){
    modal.style.display = "none";
    player.pause();
    player = "";
}

function setAlt(elem, altStr){
    var me = document.getElementById(elem.id);
    me.alt = altStr;
    me.style.display = "inline";
}

window.onclick = function(event) {
    if (event.target === modal) {
        modal.style.display = "none";
        player.pause();
        player = "";
    }
};

function showModalsetSubs(elem, srcStr) {
    var tempStr = elem.id;
    tempStr = tempStr.replace("A", "B");
    modal = document.getElementById(String(tempStr));
    tempStr = tempStr.replace("B", "C");
    player = document.getElementById(String(tempStr));
    modal.style.display = "block";
    var subNum=parseInt(player.childElementCount)-1;
    var array = srcStr.split(',');
    for (var i=1, j=0; i<=subNum; i++, j++){
        player.children[i].src=array[j];
    }
}

function setPadding(){
    document.getElementById("paddingDiv").style.display="block";
    var wrapper = document.getElementById("wrapper");
    var wDiv = wrapper.offsetWidth;
    var tempArr = document.getElementsByClassName("movieDiv");
    var temp1 = tempArr[0];
    var temp2 = tempArr[1];
    var style = getComputedStyle(temp1);
    var extraSpace = Math.abs(parseFloat((temp1.offsetLeft + temp1.getBoundingClientRect().width)-temp2.offsetLeft));
    var sDiv = parseFloat(temp1.getBoundingClientRect().width);
    var currentElHeight=parseInt(style.marginTop)+temp1.offsetHeight;
    var rate = Math.floor(wDiv/(sDiv+(extraSpace/2)));
    var numbEl = (wrapper.childElementCount-1)%rate;
    var realRate = Math.floor(rate-numbEl);
    var extraElementW=sDiv*realRate+extraSpace*(realRate-1)+parseFloat(style.marginLeft);
    if (numbEl <= 0){
        extraElementW=0;
        currentElHeight=0;
        document.getElementById("paddingDiv").style.display="none";
    } else {
        document.getElementById("paddingDiv").style.width=extraElementW.toString()+"px";
		document.getElementById("paddingDiv").style.paddingLeft="5px";
        document.getElementById("paddingDiv").style.height=currentElHeight.toString()+"px";
    }
}

window.onload=setPadding;
window.onresize=setPadding;
