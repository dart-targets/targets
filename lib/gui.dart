part of targets_cli;

/// Methods used to create web-based GUI for Targets

HttpServer server;
int currentPort;
String currentUrl;

const String defaultURL = "http://darttargets.com/gui";

runGuiServer(port, [browser=true, url=defaultURL]){
    return HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((HttpServer newServer) {
        server = newServer;
        currentPort = port;
        currentUrl = url;
        if(port!=7620 && url==defaultURL) url += "?port=$port";
        print("Connect to ws://localhost:$port at ${url.substring(7)}",GREEN);
        print("This process must remain running for the GUI to work.");
        if(browser) openBrowser(url);
        server.listen((HttpRequest request) {
            if (WebSocketTransformer.isUpgradeRequest(request)){
                WebSocketTransformer.upgrade(request).then(handleSocket);
            }
            else {
                request.response.statusCode = HttpStatus.FORBIDDEN;
                request.response.reasonPhrase = "Please connect from darttargets.com/gui";
                request.response.close();
            }
        });
    });
}

var lastSocket;

void handleSocket(WebSocket socket){
    if(lastSocket!=null){
        lastSocket.add(JSON.encode({'type':'newclient'}));
    }
    lastSocket = socket;
    var serverPrint = (String str, [String type=PLAIN]){
        if(type==PLAIN||Platform.isWindows){
            stdout.writeln(str);
        }else if(type==RED){
            stdout.writeln("\u001b[0;31m"+str+"\u001b[0;0m");
        }else if(type==GREEN){
            stdout.writeln("\u001b[0;32m"+str+"\u001b[0;0m");
        }else if(type==BLUE){
            stdout.writeln("\u001b[0;36m"+str+"\u001b[0;0m");
        }
    };
    var clientPrint = (str, [type=PLAIN]) => socket.add(JSON.encode({'type':'log','text':str}));
    print = clientPrint;
    socket.listen((String s) {
        var map = JSON.decode(s);
        String command = map['command'];
        wd = map['workingDirectory'];
        if(command == 'submit'){
            submit(false, withInfo:map['info'], callback:(url){
                socket.add(JSON.encode({'type':'submit','url':url}));
            });
        }else if(command == 'get'){
            getAssignment(map['id'], false);
        }else if(command == 'get-zip'){
            getAssignment(map['id'], map['url']);
        }else if(command == 'check'){
            checkAssign();
        }else if(command == 'update'){
            serverPrint("Update triggered. Server about to close...");
            serverPrint(Process.runSync('pub',['global','activate','targets']).stdout);
            socket.add(JSON.encode({'type':'reboot'}));
            new Future.delayed(new Duration(milliseconds:2000),(){
                server.close(force:true);
                serverPrint("Starting new instance...");
                Process.start('pub',['global','run','targets', 'gui', '--server', '$currentPort', 
                                            currentUrl], runInShell:true).then((process) {
                    process.stdout.transform(new Utf8Decoder())
                            .transform(new LineSplitter()).listen((String line){
                        serverPrint(line);
                    });
                });
            });
        }
    },onDone: () {
        print = serverPrint;
    });
    socket.add(JSON.encode({'type':'init',
        'workingDirectory':Directory.current.path,
        'version':version
    }));
}