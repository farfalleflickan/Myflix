var modal = "";
var ulElement = "";
var selElement = "";
var videoModal = "";
var player = "";

function changeSeason(elem) {
    ulElement.style.display = "none";
    var e = document.getElementById(elem.id);
    var myVal = e.options[e.selectedIndex].value;
    tempStr = elem.id.replace("selector", "C");
    tempStr = tempStr.substring(0, tempStr.lastIndexOf('C') + 2) + "_" + String(myVal);
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
    tempStr = tempStr.substring(0, tempStr.lastIndexOf('C') + 2) + "_" + String(myVal);
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