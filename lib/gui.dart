part of targets_cli;

/// Methods used to create web-based GUI for Targets

HttpServer server;
int currentPort;

runGuiServer(port, [browser=true]){
    var url = "$serverRoot/console";
    port = 7620; // may change later
    return HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((HttpServer newServer) {
        server = newServer;
        currentPort = port;
        if(port!=7620) url += "#$port";
        print("Connect to ws://localhost:$port at $url",GREEN);
        print("This process must remain running for the console to work.");
        if(browser) openBrowser(url);
        server.listen((HttpRequest request) {
            if (WebSocketTransformer.isUpgradeRequest(request)){
                String origin = request.headers.value('origin');
                if (origin != serverRoot) {
                    String msg = 'You may only connect from $serverRoot.\nRun `targets console --server $origin` to connect from $origin.';
                    print(msg);
                    request.response.statusCode = HttpStatus.FORBIDDEN;
                    request.response.reasonPhrase = msg;
                    request.response.close();
                } else {
                    WebSocketTransformer.upgrade(request).then(handleSocket);
                }
            }
            else {
                request.response.statusCode = HttpStatus.FORBIDDEN;
                request.response.reasonPhrase = "WebSockets only";
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
            var msg = JSON.decode(s);
            print = clientPrint;
            msg['socket'] = socket;
            switch (msg['command']) {
                case 'get':
                    await consoleGet(msg);
                    break;
                case 'test':
                    await consoleTest(msg);
                    break;
                case 'submit':
                    await consoleSubmit(msg);
                    break;
                case 'update':
                    await consoleUpdate(msg);
                    break;
                case 'directory':
                    await consoleDirectory(msg);
                    break;
                case 'read-file':
                    await consoleReadFile(msg);
                    break;
                case 'write-file':
                    await consoleWriteFile(msg);
                    break;
                case 'create-file':
                    await consoleCreateFile(msg);
                    break;
                case 'delete-file':
                    await consoleDeleteFile(msg);
                    break;
                case 'create-directory':
                    await consoleCreateDirectory(msg);
                    break;
                case 'delete-directory':
                    await consoleDeleteDirectory(msg);
                    break;
                case 'save-submissions':
                    await consoleSaveSubmissions(msg);
                    break;
                case 'batch-grade':
                    await consoleBatchGrade(msg);
                    break;
                case 'run-file':
                    await consoleRunFile(msg, socket);
                    break;
                case 'run-file-input':
                    await consoleRunFileInput(msg);
                    break;
                case 'run-file-cancel':
                    await consoleRunFileCancel(msg);
                    break;
            }
            print = serverPrint;
        } catch (e, st) {
            send({
                'type': 'error',
                'exception': '$e'
            }, socket);
            serverPrint(e);
            serverPrint(st);
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

_currentDirectorySlash() {
  return Directory.current.path + Platform.pathSeparator;
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
    wd = _currentDirectorySlash() + msg['assignment'];
    await checkAssign(msg['json']);
    wd = Directory.current.path;
    if (msg['json']) {
        respond({'results': output}, msg);
    } else {
        respond({}, msg);
    }
}

consoleSubmit(msg) async {
    wd = _currentDirectorySlash() + msg['assignment'];
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

findTree(Directory dir, [bool root = true) async {
    var tree = {};
    int length = (dir.absolute.path + Platform.pathSeparator).length;
    if (Platform.isWindows && root) {
      length -= 1; // hacky fix - TODO: make not so hacky
    }
    await for (var file in dir.list()) {
        file = file.absolute;
        var path = file.path.substring(length);
        if (file is File) {
            tree[path] = path;
        } else if (file is Directory) {
            tree[path] = await findTree(file, false);
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

consoleCreateFile(msg) async {
    File file = new File(msg['file']);
    if (!file.absolute.path.startsWith(wd) || msg['file'].contains('..')) {
        throw new Exception("Console may only access files within root directory");
    }
    await file.create();
    respond({}, msg);
}

consoleCreateDirectory(msg) async {
    Directory file = new Directory(msg['directory']);
    if (!file.absolute.path.startsWith(wd) || msg['file'].contains('..')) {
        throw new Exception("Console may only access files within root directory");
    }
    await file.create();
    respond({}, msg);
}

consoleDeleteFile(msg) async {
    File file = new File(msg['file']);
    if (!file.absolute.path.startsWith(wd) || msg['file'].contains('..')) {
        throw new Exception("Console may only access files within root directory");
    }
    await file.delete();
    respond({}, msg);
}

consoleDeleteDirectory(msg) async {
    Directory file = new Directory(msg['directory']);
    if (!file.absolute.path.startsWith(wd) || msg['file'].contains('..')) {
        throw new Exception("Console may only access files within root directory");
    }
    await file.delete();
    respond({}, msg);
}

consoleSaveSubmissions(msg) async {
    await saveSubmissions(msg['templateId'], msg['directory'], msg['submissions']);
    respond({}, msg);
}

consoleBatchGrade(msg) async {
    wd = _currentDirectorySlash() + msg['directory'];
    var results = await batchJson();
    wd = Directory.current.path;
    respond({'results': results}, msg);
}

consoleRunFile(msg, socket) async {
    File file = new File(msg['file']);
    if (!file.absolute.path.startsWith(wd) || msg['file'].contains('..')) {
        throw new Exception("Console may only access files within root directory");
    }
    String working = file.parent.absolute.path;
    var run = msg['run'];
    String running = file.absolute.path.substring(working.length + 1);
    if (run == 'java') {
        var cfile = running;
        running = running.split('.').first;
        var result = await Process.run('javac', [cfile], workingDirectory: working, runInShell: true);
        if (result.stderr != null && result.stderr.length > 0) {
            respond({'error': result.stderr}, msg);
            return;
        }
    }
    var args;
    if (msg['args'] == null || msg['args'] == '') {
        args = [];
    } else {
        args = msg['args'].split(' ');
    }
    args.insert(0, running);
    var process = await Process.start(run, args, workingDirectory: working, runInShell: true);
    consoleRunFileInput = (msg) {
        process.stdin.add(msg['data']);
    };
    
    consoleRunFileCancel = (msg) {
        process.kill();
    };
    process.stdout.listen((data){
        send({'type': 'run-file-output', 'data': data}, socket);
    }).onDone((){
        respond({}, msg);
        consoleRunFileInput = (msg) => null;
        consoleRunFileCancel = (msg) => null;
    });
    process.stderr.listen((data){
        send({'type': 'run-file-output', 'data': data}, socket);
    });
}

var consoleRunFileInput = (msg) => null;
var consoleRunFileCancel = (msg) => null;