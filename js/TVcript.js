var modal = "";
var ulElement = "";
var selElement = "";
var videoModal = "";
var player = "";
var autoSwitchEpisode=false;

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
    selElement = document.getElementById(String(tempStr)+String("_"));
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

function hideModal() {
    modal.style.display = "none";
    ulElement.style.display = "none";
}

function hideVideoModal() {
    videoModal.style.display = "none";
    player.pause();
    player = "";
}

function setAlt(elem, altStr){
    var me = document.getElementById(elem.id);
    me.alt = altStr;
    me.style.display = "inline";
}

function prevEp(){
	var index = videoModal.id.indexOf("_");
	var myID = videoModal.id.substr(0, index+1);
	var currentNum = parseInt(videoModal.id.substr(index+1));
	if (currentNum !== 0){
		videoModal.style.display = "none";
	 	player.pause();
    		player = "";
		currentNum-=1;
		tempStr=String(myID)+String(currentNum);
		videoModal = document.getElementById(tempStr);
		videoModal.style.display = "block";
		tempStr = tempStr.replace("E", "F");
 		player = document.getElementById(String(tempStr));
		player.play();
	}
}

function nextEp(){
	videoModal.style.display = "none";
 	player.pause();
	player = "";
	var index = videoModal.id.indexOf("_");
	var myID = videoModal.id.substr(0, index+1);
	var currentNum = parseInt(videoModal.id.substr(index+1));
	currentNum+=1;
	tempStr=String(myID)+String(currentNum);	
	videoModal = document.getElementById(tempStr);
	videoModal.style.display = "block";
	tempStr = tempStr.replace("E", "F");
 	player = document.getElementById(String(tempStr));
	if (autoSwitchEpisode === true){
		player.addEventListener('ended',nextEp);
	}
	player.play();
}

function autoSwitch(){
	if (autoSwitchEpisode === false){
		autoSwitchEpisode=true;
		var e = document.getElementsByClassName("autoButton");
		player.addEventListener('ended',nextEp);	
		for (var i=0; i< e.length; i++){
			e[i].checked = true;
		}
	} else {
		autoSwitchEpisode=false;
		player.removeEventListener('ended',nextEp);	
		var e = document.getElementsByClassName("autoButton");
		for (var i=0; i< e.length; i++){
			e[i].checked = false;
		}
	}
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
