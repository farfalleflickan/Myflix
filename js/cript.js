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

window.onclick = function(event) {
    if (event.target === modal) {
        modal.style.display = "none";
        player.pause();
        player = "";
    }
};



