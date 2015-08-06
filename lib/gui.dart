part of targets_cli;

/// Methods used to create web-based GUI for Targets

HttpServer server;
int currentPort;

runGuiServer(port, [browser=true]){
    var url = "$serverRoot/console";
    return HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((HttpServer newServer) {
        server = newServer;
        currentPort = port;
        if(port!=7620 && url==defaultURL) url += "#$port";
        print("Connect to ws://localhost:$port at $url",GREEN);
        print("This process must remain running for the console to work.");
        if(browser) openBrowser(url);
        server.listen((HttpRequest request) {
            if (WebSocketTransformer.isUpgradeRequest(request)){
                WebSocketTransformer.upgrade(request).then(handleSocket);
            }
            else {
                request.response.statusCode = HttpStatus.FORBIDDEN;
                request.response.reasonPhrase = "Please connect from $url";
                request.response.close();
            }
        });
    });
}

var serverPrint = (str, [String type=PLAIN]){
    str = str.toString();
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

List<WebSocket> sockets = [];

handleSocket(WebSocket socket) async {
    sockets.add(socket);
    var clientPrint = (str, [type=PLAIN]) => send({'type':'log','text':str}, socket);
    socket.listen((String s) async {
        try {
            var map = JSON.decode(s);
            print = clientPrint;
            map['socket'] = socket;
            switch (map['command']) {
                case 'get':
                    await consoleGet(map);
                    break;
                case 'test':
                    await consoleTest(map);
                    break;
                case 'submit':
                    await consoleSubmit(map);
                    break;
                case 'update':
                    await consoleUpdate(map);
                    break;
                case 'directory':
                    await consoleDirectory(map);
                    break;
                case 'read-file':
                    await consoleReadFile(map);
                    break;
                case 'write-file':
                    await consoleWriteFile(map);
                    break;
                case 'save-submissions':
                    await consoleSaveSubmissions(map);
                    break;
                case 'batch-grade':
                    await consoleBatchGrade(map);
                    break;
            }
            print = serverPrint;
        } catch (e) {
            send({
                'type': 'error',
                'exception': '$e'
            }, socket);
            serverPrint(e);
        }
    },onDone: () {
        sockets.remove(socket);
    });
    send({
        'type': 'init',
        'directory': Directory.current.path,
        'version': version
    }, socket);
}

send(msg, socket) {
    socket.add(JSON.encode(msg));
}

respond(msg, original) {
    msg['type'] = 'response';
    msg['command'] = original['command'];
    msg['cmd-id'] = original['cmd-id'];
    send(msg, original['socket']);
}

consoleGet(msg) async {
    String id = msg['assignment'];
    if (msg.containsKey('url') && msg['url'] != null) {
        await getZipAssignment(id, msg['url']);
    } else {
        await getAssignment(id, false);
    }
    respond({}, msg);
}

consoleTest(msg) async {
    if (!msg.containsKey('json')) {
        msg['json'] = false;
    }
    String output = "";
    if (msg['json']) {
        print = (text) => output += text + '\n';
    }
    wd = Directory.current.path + "/" + msg['assignment'];
    await checkAssign(msg['json']);
    wd = Directory.current.path;
    if (msg['json']) {
        respond({'results': output}, msg);
    } else {
        respond({}, msg);
    }
}

consoleSubmit(msg) async {
    wd = Directory.current.path + "/" + msg['assignment'];
    String hash = await uploadSubmission(msg['email'], msg['note']);
    wd = Directory.current.path;
    respond({'hash': hash}, msg);
}

bool updated = false;

consoleUpdate(msg) async {
    if (updated) return;
    updated = true;
    serverPrint(Process.runSync('pub',['global','activate', 'targets']).stdout);
    await new Future.delayed(new Duration(milliseconds:500));
    await server.close(force: true);
    for (var socket in sockets) {
        await socket.close(WebSocketStatus.GOING_AWAY, 'Server rebooting');   
    }
    serverPrint("Starting new instance...");
    Process.start('pub',['global','run','targets', 'console', '--background'], runInShell:true).then((process) {
        process.stdout.transform(new Utf8Decoder())
                .transform(new LineSplitter()).listen((String line){
            serverPrint(line);
        });
        process.stderr.transform(new Utf8Decoder())
                .transform(new LineSplitter()).listen((String line){
            serverPrint(line);
        });
    });
}

consoleDirectory(msg) async {
    var tree = await findTree(Directory.current);
    respond({'tree': tree}, msg);
}

findTree(Directory dir) async {
    var tree = {};
    int length = dir.absolute.path.length;
    await for (var file in dir.list()) {
        file = file.absolute;
        var path = file.path.substring(length + 1);
        if (file is File) {
            tree[path] = path;
        } else if (file is Directory) {
            tree[path] = await findTree(file);
        }
   }
   return tree;
}

consoleReadFile(msg) async {
    File file = new File(msg['file']);
    if (!file.absolute.path.startsWith(wd) || msg['file'].contains('..')) {
        throw new Exception("Console may only access files within root directory");
    }
    String contents = await file.readAsString();
    respond({'contents': contents}, msg);
}

consoleWriteFile(msg) async {
    File file = new File(msg['file']);
    if (!file.absolute.path.startsWith(wd) || msg['file'].contains('..')) {
        throw new Exception("Console may only access files within root directory");
    }
    await file.writeAsString(msg['contents']);
    respond({}, msg);
}

consoleSaveSubmissions(msg) async {
    await saveSubmissions(msg['templateId'], msg['directory'], msg['submissions']);
    respond({}, msg);
}

consoleBatchGrade(msg) async {
    wd = Directory.current.path + '/' + msg['directory'];
    var results = await batchJson();
    wd = Directory.current.path;
    respond({'results': results}, msg);
}