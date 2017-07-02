var modal = "";

function showModal(elem){
	var tempStr = elem.id;
	tempStr = tempStr.replace("A", "B");
	modal = document.getElementById(String(tempStr));
	modal.style.display = "block";
}

function hideModal(){
    modal.style.display = "none";
}

window.onclick = function(event) {
    if (event.target == modal) {
        modal.style.display = "none";
    }
}



