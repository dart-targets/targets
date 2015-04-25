part of targets_cli;

/// This adds support for Moss similarity detection on any set of student
/// submissions that supports the `targets batch` command

Socket socket;

String id;

String lang;

var exts = [];

Future mossRun(){
    Directory template = new Directory("template");
    if(!template.existsSync()){
        print("You must add a template to this directory first!", RED);
        return;
    }
    String home;
    if(Platform.isWindows){
        home = Platform.environment['USERPROFILE'];
    }else{
        home = Platform.environment['HOME'];
    }
    File cache = new File("$home/.targets-moss");
    if(cache.existsSync()){
        String saved = cache.readAsStringSync().trim();
        String entry = prompt("Moss Account ID (default: $saved): ").trim();
        if(entry==""){
            id = saved;
        }else id = entry;
    }else{
        id = prompt("Moss Account ID: ").trim();
    }
    cache.writeAsStringSync(id);
    print("Run 'targets moss --help' for language options");
    lang = prompt("Language: ").toLowerCase();
    while(true){
        var next = prompt("File Extension (enter to stop): ");
        if(next.length==0) break;
        else{
            if(next.startsWith(".")) next = next.substring(1);
            exts.add(next);
        }
    }
    return Socket.connect("moss.stanford.edu", 7690).then((newSocket){
        socket = newSocket;
        socket.transform(new Utf8Decoder())
                .transform(new LineSplitter())
                .listen((String line){
            if(state == "language"){
                receiveLanguageValidation(line);
            }else if(state == "url"){
                socket.write("end\n");
                socket.close();
                openBrowser(line);
            }
        });
        socket.write("moss $id\n");
        socket.write("directory 1\n");
        socket.write("X 0\n");
        socket.write("maxmatches 10\n");
        socket.write("show 250\n");
        state = "language";
        socket.write("language $lang\n");
    });
}

void receiveLanguageValidation(result){
    if(result == null || result.trim().toLowerCase() != "yes"){
        print("Invalid language");
        socket.close();
        exit(0);
    }else{
        List<MossFile> files = [];
        Directory template = new Directory("template");
        print("Preparing template...");
        for(var item in template.listSync(recursive: true)){
            if(item is File && validFileType(item.path)){
                files.add(new MossFile(item, true));
            }
        }
        var students = Directory.current.listSync();
        print("Preparing student code...");
        for(var s in students){
            if(s is Directory && s.absolute.path != template.absolute.path){
                for(var item in s.listSync(recursive: true)){
                    if(item is File && validFileType(item.path)){
                        files.add(new MossFile(item));
                    }
                }
            }
        }
        int currentID = 1;
        print("Uploading ${files.length} files...");
        int count = 0;
        for(MossFile file in files){
            count++;
            int fid = 0;
            if(!file.base){
                fid = currentID++;
            }
            var size = ASCII.encode(file.contents).length;
            var path = file.path.replaceAll(" ","_");
            String header = "file $fid $lang $size $path\n";
            socket.write(header);
            socket.write(file.contents+"");
        }
        print("Code uploaded. Awaiting response...");
        state = "url";
        String time = new DateTime.now().toString();
        socket.write("query 0 Submitted via Targets at $time\n");
    }
}

bool validFileType(String path){
    for(var e in exts){
        if(path.endsWith(".$e")) return true;
    }
    return false;
}

var state = "not started";

class MossFile{
    String _contents;
    bool base;
    String path;

    String get contents => _contents;

    MossFile(File file, [bool base=false]){
        this.base = base;
        _contents = file.readAsStringSync();
        _contents = _contents.replaceAll("\r\n", "\n");
        path = file.absolute.path.replaceAll("\\", "/");
        path = path.substring(Directory.current.absolute.path.length+1);
        if(base){
            path = path.substring("template/".length);
        }
    }
}

void mossHelp(){
    var langs = ["c", "cc", "java", "ml", "pascal", "ada", "lisp", "scheme",
        "haskell", "fortran", "ascii", "vhdl", "perl", "matlab", "python", 
        "mips", "prolog", "spice", "vb", "csharp", "modula2", "a8086", 
        "javascript", "plsql", "verilog"];
    print("Language Options:");
    String str = "";
    int count = 0;
    for(var l in  langs){
        count += l.length + 1;
        str += l;
        if(count>80){
            count = 0;
            str += "\n";
        }else str += " ";
    }
    print(str);
}