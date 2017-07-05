var modal = "";
var player = "";

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