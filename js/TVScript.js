var modal = "";
var ulElement = "";
var selElement = "";
var videoModal = "";
var player = "";
var myFrame = "";
var frameDiv = "";
var vidModalStatus=false;
var autoSwitchEpisode = false;
var isFullscreen = 1;

document.addEventListener("resize", rezHandler);
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
                rezHandler();
            } else if (document.webkitExitFullscreen) {
                document.webkitExitFullscreen();
                rezHandler();
            } else if (document.mozCancelFullScreen) {
                document.mozCancelFullScreen();
                rezHandler();
            } else if (document.msExitFullscreen) {
                document.msExitFullscreen();
                rezHandler();
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
		if (player.currentTime >= player.duration){
			nextEp();
		}
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

function rezHandler() {
    if (vidModalStatus===true){
        var tempHeight=videoModal.firstElementChild.offsetHeight+20;
        parent.frameDiv.style.height=String(tempHeight)+"px";
		document.body.style.overflow="hidden";
    }
}


function FShandler() {
    isFullscreen++;
}

function isDescendant(parent, child) {
    var node = child.parentNode;
    while (node !== null) {
        if (node === parent) {
            return true;
        }
        node = node.parentNode;
    }
    return false;
}

function changeSeason(elem) {
    ulElement.style.display = "none";
    var e = document.getElementById(elem.id);
    var myVal = e.options[e.selectedIndex].value;
    var tempStr = elem.id.replace("selector", "C");
    tempStr = tempStr.split("C").pop();
    tempStr = "C" + tempStr + String(myVal);
    ulElement = document.getElementById(String(tempStr));
    ulElement.style.display = "block";
    parent.resizeFrame();
}

function showModal(id) {
    var tempStr = id;
    selElement = document.getElementById(String(id));
    var myVal = selElement.value;
    tempStr = tempStr.replace("selector", "C");
    tempStr = tempStr.split("C").pop();
    tempStr = "C" + tempStr + String(myVal);
    ulElement = document.getElementById(String(tempStr));
    ulElement.style.display = "block";
}

function showVideoModal(elem) {
    var tempStr = elem.id;
    tempStr = tempStr.replace("D", "E");
    videoModal = document.getElementById(String(tempStr));
    tempStr = tempStr.replace("E", "F");
    player = document.getElementById(String(tempStr));
    videoModal.style.cssText = "background-color: white; display: block;";
    videoModal.firstElementChild.style.cssText = "width: auto; height: auto; margin: 0; padding: 0; border: 0;";
    var tempHeight=(videoModal.firstElementChild.offsetHeight)+18;
    parent.frameDiv.style.height=String(tempHeight)+"px";
    vidModalStatus=true;
	document.body.style.overflow="hidden";
}

function showVideoModalsetSubs(elem, srcStr) {
    var tempStr = elem.id;
    tempStr = tempStr.replace("D", "E");
    videoModal = document.getElementById(String(tempStr));
    tempStr = tempStr.replace("E", "F");
    player = document.getElementById(String(tempStr));
    videoModal.style.cssText = "background-color: white; display: block;";
    videoModal.firstElementChild.style.cssText = "width: auto; height: auto; margin: 0; padding: 0; border: 0;";
    var tempHeight=(videoModal.firstElementChild.offsetHeight)+18;
    parent.frameDiv.style.height=String(tempHeight)+"px";
    vidModalStatus=true;
	document.body.style.overflow="hidden";
    var subNum = parseInt(player.childElementCount) - 1;
    var array = srcStr.split(',');
    for (var i = 1, j = 0; i <= subNum; i++, j++) {
        player.children[i].src = array[j];
    }
}


function hideModal() {
    parent.modal.style.display = "none";
    parent.frameDiv = "";    
}

function hideVideoModal() {
    videoModal.style.display = "none";
	document.body.style.overflow="auto";
    player.pause();
    player = "";
    vidModalStatus=false;
    parent.resizeFrame();
}

function resetPlayer(){
    var myTime = player.currentTime;
	var mySrc = player.children[0].src;
	player.children[0].src="";
    player.load();
	player.children[0].src=mySrc;
    player.currentTime = myTime;
	player.load();
    player.play();
}

function prevEp() {
    var index = videoModal.id.indexOf("_");
    var myID = videoModal.id.substr(0, index + 1);
    var currentNum = parseInt(videoModal.id.substr(index + 1));
    if (currentNum !== 0) {
        videoModal.style.display = "none";
        player.pause();
        player = "";
        currentNum -= 1;
        tempStr = String(myID) + String(currentNum);
        videoModal = document.getElementById(tempStr);
        videoModal.style.display = "block";
        if (isDescendant(ulElement, videoModal) === false && selElement.value !== 1) {
            selElement.selectedIndex = parseInt(parseInt(selElement.value) - 2);
            changeSeason(selElement);
        }
        tempStr = tempStr.replace("E", "F");
        player = document.getElementById(String(tempStr));
        player.play();
    }
}

function nextEp() {
    var index = videoModal.id.indexOf("_");
    var myID = videoModal.id.substr(0, index + 1);
    var currentNum = parseInt(videoModal.id.substr(index + 1));
    currentNum += 1;
    var tempStr = String(myID) + String(currentNum);
	tempStr = tempStr.replace("E", "D");
	var btnElem = document.getElementById(tempStr);
	oldVolume = player.volume;
    if (document.getElementById(tempStr) !== null) {
		hideVideoModal();
		btnElem.click();
        if (isDescendant(ulElement, videoModal) === false) {
            selElement.selectedIndex = parseInt(parseInt(selElement.value));
            changeSeason(selElement);
        }
        if (autoSwitchEpisode === true) {
            player.addEventListener('ended', nextEp);
        }
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
        }
        player.volume = oldVolume;
        player.play();
    }
}

function autoSwitch() {
    if (autoSwitchEpisode === false) {
        autoSwitchEpisode = true;
        var e = document.getElementsByClassName("autoButton");
        player.addEventListener('ended', nextEp);
        for (var i = 0; i < e.length; i++) {
            e[i].checked = true;
        }
    } else {
        autoSwitchEpisode = false;
        player.removeEventListener('ended', nextEp);
        var e = document.getElementsByClassName("autoButton");
        for (var i = 0; i < e.length; i++) {
            e[i].checked = false;
        }
    }
}

window.parent.onclick = function (event) {
    if (event.target === parent.modal) {
        if (player==""){
            parent.modal.style.display = "none";
            parent.myFrame="";
        } else {
            hideVideoModal();
        }
    }
};

parent.window.onresize=rezHandler;
