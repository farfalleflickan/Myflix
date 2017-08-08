var modal = "";
var ulElement = "";
var selElement = "";
var videoModal = "";
var player = "";
var autoSwitchEpisode = false;
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
    } else if (e.keyCode === 32) {
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

function changeSeason(elem) {
    ulElement.style.display = "none";
    var e = document.getElementById(elem.id);
    var myVal = e.options[e.selectedIndex].value;
    var tempStr = elem.id.replace("selector", "C");
    tempStr = tempStr.split("C").pop();
    tempStr = "C" + tempStr + String(myVal);
    ulElement = document.getElementById(String(tempStr));
    ulElement.style.display = "block";
}

function showModal(elem) {
    var tempStr = elem.id;
    tempStr = tempStr.replace("A", "B");
    modal = document.getElementById(String(tempStr));
    tempStr = tempStr.replace("B", "selector");
    selElement = document.getElementById(String(tempStr) + String("_"));
    var myVal = selElement.value;
    tempStr = tempStr.replace("selector", "C");
    tempStr = tempStr.split("C").pop();
    tempStr = "C" + tempStr + "_" + String(myVal);
    ulElement = document.getElementById(String(tempStr));
    modal.style.display = "block";
    ulElement.style.display = "block";
}

function showVideoModal(elem) {
    var tempStr = elem.id;
    tempStr = tempStr.replace("D", "E");
    videoModal = document.getElementById(String(tempStr));
    tempStr = tempStr.replace("E", "F");
    player = document.getElementById(String(tempStr));
    videoModal.style.display = "block";
}

function showVideoModalsetSubs(elem, srcStr) {
    var tempStr = elem.id;
    tempStr = tempStr.replace("D", "E");
    videoModal = document.getElementById(String(tempStr));
    tempStr = tempStr.replace("E", "F");
    player = document.getElementById(String(tempStr));
    videoModal.style.display = "block";
    var subNum = parseInt(player.childElementCount) - 1;
    var array = srcStr.split(',');
    for (var i = 1, j = 0; i <= subNum; i++, j++) {
        player.children[i].src = array[j];
    }
}

function hideModal() {
    modal.style.display = "none";
    ulElement.style.display = "none";
}

function hideVideoModal() {
    videoModal.style.display = "none";
    player.pause();
    player = "";
}

function setAlt(elem, altStr) {
    var me = document.getElementById(elem.id);
    me.alt = altStr;
    me.style.display = "inline";
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
    if (document.getElementById(tempStr) !== null) {
        videoModal.style.display = "none";
        videoModal = document.getElementById(tempStr);
        player.pause();
        player = "";
        videoModal.style.display = "block";
        tempStr = tempStr.replace("E", "F");
        player = document.getElementById(String(tempStr));
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

window.onclick = function (event) {
    if (event.target === modal) {
        modal.style.display = "none";
    }
    if (event.target === videoModal) {
        videoModal.style.display = "none";
        player.pause();
        player = "";
    }
};
