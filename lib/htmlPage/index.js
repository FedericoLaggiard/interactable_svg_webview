let touchableEl = [];
let hotspotClasses = [];
const svgContainerId = "svgContainer";
let svgContainer = document.getElementById(svgContainerId);
let jsMessageChannel;

const MESSAGE = (message, data) => JSON.stringify({ message, data});
const EVENT_CODES = {
    HOTSPOT: "HOTSPOT",
    TOUCH: "TOUCH",
    ERROR: "ERROR",
    READY: "READY",
    RESPONSE: "RESPONSE",
    LOAD_SVG: "LOAD_SVG",
    INIT_EVENTS: "INIT_EVENTS",
};
const ERROR_CODES = {
    NO_SVG: "1",
};
const touchedObj = (type,id,classes,name,fullEl) => ({
    type,
    id,
    classes,
    name,
    fullEl
});

window.onLoadSVG = (svg) => {
    loadSVG(svg);
}

window.onFlutterMessage = (msg) => {
    console.log(`received from flutter event ${msg}`);
    const message = JSON.parse(msg);

    switch(message.message){
        case EVENT_CODES.INIT_EVENTS:
            hotspotClasses = JSON.parse(message.data).hotspotClasses;
            touchableEl = JSON.parse(message.data).touchableEl;
            initSVGEvents(message.data);
        break;
    }
};

function sendMessageToFlutter(message) {
    jsMessageChannel.postMessage(message);
}

function loadSVG(svg) {
    console.log("loading SVG on DOM");
    svgContainer.innerHTML = svg;

    setTimeout(() => {
        sendMessageToFlutter(MESSAGE(EVENT_CODES.RESPONSE, "SVG_LOADED"))
    }, 200);
}

// init the SVG Events to grab touch events on svg and send them back to flutter
const initSVGEvents = (data) => {
    const onTouchEvent = (event) => {
        if(event.target.parentNode){
            const target = event.target.parentNode;
            if(touchableEl.includes(target.nodeName) ){

            const t = touchedObj(
                target.tagName,
                target.id,
                [...target.classList],
                target.getAttribute("name"),
                target.outerHTML
            );

            const hotspotFound = hotspotClasses.some((q) => {
                if(target.getAttribute("class") != null && target.getAttribute("class").indexOf(q) > -1) {
                    sendMessageToFlutter(MESSAGE(EVENT_CODES.HOTSPOT, `${JSON.stringify(t)}`));
                    return true;
                }
                return false;
            });

            if(!hotspotFound) sendMessageToFlutter(MESSAGE(EVENT_CODES.TOUCH, `${JSON.stringify(t)}`));
        }
        }
    }

    const svgEl = document.querySelector(`#${svgContainerId}>svg`);
    if(!svgEl){
        sendMessageToFlutter(MESSAGE(EVENT_CODES.ERROR, ERROR_CODES.NO_SVG));
    }else{
        svgEl.addEventListener("touchstart", onTouchEvent);
        if(mobileCheck() === false) svgEl.addEventListener("click", onTouchEvent);
        sendMessageToFlutter(MESSAGE(EVENT_CODES.RESPONSE, "EVENTS_READY"));
    }
}

//for testing in browser
if (mobileCheck() === false) {
    jsMessageChannel = { postMessage: function(message) { console.log(message); } };
    setTimeout(initSVGEvents(), 1000);
}else{
    jsMessageChannel = jsChannel; // <-- jsChannel is the name of the channel configured in flutter
}
// if no message channel is present something is wrong, show an error
if(!jsMessageChannel || !jsMessageChannel.postMessage) {
    alert("No message channel found, is flutter listening?");
}else{
    // otherwise send a message to flutter to notify that the page is ready to receive
    // the svg
    sendMessageToFlutter(MESSAGE(EVENT_CODES.READY,""));
}

//utility to check if we are on browser or on mobile
function mobileCheck() {
  let check = false;
  (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))) check = true;})(navigator.userAgent||navigator.vendor||window.opera);
  return check;
};