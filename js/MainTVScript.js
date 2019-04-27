var modal = "";
var selElement = "";
var player = "";
var myFrame = "";
var frameDiv = "";

function setFrame(elem, name){
    var tempStr = elem.id;
    tempStr = tempStr.replace("A", "IN");
    tempFrame = document.getElementById(String(tempStr));
    myFrame=tempFrame;
    tempStr = tempStr.replace("IN", "B");
    modal = document.getElementById(String(tempStr));
    modal.style.display = "block";
    tempFrame.src=name;  
}

function setAlt(elem, altStr) {
    var me = document.getElementById(elem.id);
    me.alt = altStr;
    me.style.display = "inline";
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

function setPadding(){
    if (document.getElementById("paddingDiv")!=null){        
        document.getElementById("paddingDiv").style.display="block";
        var wrapper = document.getElementById("wrapper");
        var wDiv = wrapper.offsetWidth;
        var tempArr = document.getElementsByClassName("showDiv");
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
}

function resizeFrame(){
    if (myFrame != null && myFrame != ""){            
        var tempHeight = myFrame.contentWindow.document.body.scrollHeight;
        var tempStr = myFrame.id;
        tempStr = tempStr.replace("IN", "frameDiv");
        frameDiv = document.getElementById(String(tempStr));
        frameDiv.style.height=String(tempHeight)+"px";
    }
}

window.onload=setPadding;
window.onresize=setPadding;
window.onresize=resizeFrame;
