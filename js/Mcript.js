var modal = "";
var player = "";
var isFullscreen = 1;

document.addEventListener("fullscreenchange", FShandler);
document.addEventListener("webkitfullscreenchange", FShandler);
document.addEventListener("mozfullscreenchange", FShandler);
document.addEventListener("MSFullscreenChange", FShandler);
document.addEventListener("keydown", function (e) {
    if (e.keyCode === 70) {
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
        player.currentTime -= 15;
    } else if (e.keyCode === 39) {
        player.currentTime += 15;
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