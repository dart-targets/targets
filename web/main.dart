import 'dart:html';
import 'dart:convert';
import 'dart:async';

var teacherInput = querySelector("#teacher_input");
var assignmentInput = querySelector("#assignment_input");

var serverInput = querySelector("#server_input");

var nameInput = querySelector("#name_input");
var emailInput = querySelector("#email_input");
var sidInput = querySelector("#sid_input");
var dirInput = querySelector("#dir_input");

var connectDiv = querySelector("#connection");
var controlDiv = querySelector("#controls");
var logDiv = querySelector("#log");

var connectButton = querySelector("#connect");
var runtestsButton = querySelector("#runtests");
var downloadButton = querySelector("#download");
var submitButton = querySelector("#submit");
var exitframeButton = querySelector("#exitframe");
var updateButton = querySelector("#update");

var iframe = querySelector("#iframe");
var validateDiv = querySelector("#validate");

var versionText = querySelector("#version");


main(){
    initFields();
    connect("ws://localhost:7620");
    connectButton.onClick.listen((e){
        log("Connecting...",true);
        connect(serverInput.value);
    });
    runtestsButton.onClick.listen((e)=>runTests());
    downloadButton.onClick.listen((e)=>download());
    submitButton.onClick.listen((e)=>submit());
    updateButton.onClick.listen((e)=>update());
    exitframeButton.onClick.listen((e){
        validateDiv.style.display="none";
    });

}

initFields(){
    nameInput.value = window.localStorage['name'];
    emailInput.value = window.localStorage['email'];
    teacherInput.value = window.localStorage['teacher'];
    assignmentInput.value = window.localStorage['assignment'];
    sidInput.value = window.localStorage['sid'];

    nameInput.onChange.listen((e)=>window.localStorage['name']=nameInput.value);
    emailInput.onChange.listen((e)=>window.localStorage['email']=emailInput.value);
    teacherInput.onChange.listen((e)=>window.localStorage['teacher']=teacherInput.value);
    assignmentInput.onChange.listen((e)=>window.localStorage['assignment']=assignmentInput.value);
    sidInput.onChange.listen((e)=>window.localStorage['sid']=sidInput.value);
}

update(){
    if(socket!=null){
        var data = {
            'command':'update'
        };
        log("Sending command to Targets...", true);
        socket.send(JSON.encode(data));
    }
}

runTests(){
    if(socket!=null){
        var data = {
            'workingDirectory':dirInput.value+"/"+assignmentInput.value,
            'command':'check'
        };
        log("Sending command to Targets...",true);
        socket.send(JSON.encode(data));
    }
}

download(){
    if(socket!=null){
        var data = {
            'workingDirectory':dirInput.value,
            'command':'get',
            'id':teacherInput.value+"/"+assignmentInput.value
        };
        log("Sending command to Targets...",true);
        socket.send(JSON.encode(data));
    }
}

submit(){
    if(socket!=null){
        var data = {
            'workingDirectory':dirInput.value+"/"+assignmentInput.value,
            'command':'submit',
            'info':nameInput.value+"\n"+emailInput.value+"\n"+sidInput.value
        };
        log("Sending command to Targets...",true);
        socket.send(JSON.encode(data));
    }
}

WebSocket socket;

connect(String server, [onConnected]){
    socket = new WebSocket(server);
    socket.onOpen.listen((Event e) {
        controlDiv.style.display = "block";
        connectDiv.style.display = "none";
        log("Connected to Targets");
        if(onConnected!=null) onConnected();
    });

    socket.onMessage.listen((MessageEvent e){
        var map = JSON.decode(e.data);
        if(map['type']=='log'){
            log(map['text']);
        }else if(map['type']=='init'){
            if(dirInput.value == ""){
                dirInput.value = map['workingDirectory'];
            }
            versionText.innerHtml = "Version "+map['version'];
        }else if(map['type']=='submit'){
            iframe.src = map['url'];
            validateDiv.style.display = "inline-block";
        }else if(map['type']=='reboot'){
            log("Targets is updating. Please wait...",true);
            controlDiv.style.display = "none";
            connectDiv.style.display = "none";
            new Future.delayed(new Duration(seconds:5), (){
                log("Connecting...", true);
                connect(server);
            });
        }
    });

    socket.onClose.listen((Event e) {
        controlDiv.style.display = "none";
        connectDiv.style.display = "block";
        logDiv.innerHtml = "";
    });
}

sanitize(String msg){
    msg = msg.replaceAll("\u001b[0;31m","<span style='color:#ff4444'>");
    msg = msg.replaceAll("\u001b[0;32m","<span style='color:#44ff44'>");
    msg = msg.replaceAll("\u001b[0;36m","<span style='color:#57f'>");
    msg = msg.replaceAll("\u001b[0;0m", "</span>");
    return msg;
}

log(String msg, [bool clear=false]){
    if(clear) logDiv.innerHtml = "";
    msg = sanitize(msg);
    if(!clear) logDiv.appendHtml("<br>");
    logDiv.appendHtml(msg);
}