part of targets_cli;

/// Various commands for teachers
/// Moss-related code is in moss.dart

getSubmissions(String id){
    File info = new File("$home/.targets-oauth");
    if(!info.existsSync()){
        print("You need to authenticate with GitHub to use this command.");
        print("You'll only need to do this once.");
        print("Go to https://github.com/settings/applications");
        print("Click 'Generate new token' under 'Personal access tokens'");
        print("Click 'Generate token' on the next page");
        print("Copy the hexadecimal string that's highlighted and paste it here.");
        print("");
        String oauth = prompt("OAuth Token: ");
        info.writeAsStringSync(oauth);
    }
    String token = info.readAsStringSync();
    List<String> parts = id.split("/");
    if (parts.length != 2) {
        print("Invalid assignment id!");
        return;
    }
    String teacher = parts[0];
    String owner = teacher;
    if (teacher.contains(":")) {
        List<String> pieces = teacher.split(":");
        teacher = pieces[0];
        owner = pieces[1];
    }
    String dirname = "$teacher-${parts[1]}";
    Directory dir = new Directory("$wd/$dirname");
    if (dir.existsSync()) {
        print("$dirname already exists in this directory!");
        return;
    }
    String url = "http://darttargets.com/results/console_zipper.php";
    print("Attempting download...");
    return http.post(url, body: {"token": token, "owner": teacher, "project": parts[1]})
        .then((response) {
        if (response.body == "Invalid authentication") {
            print("You aren't allowed to download submissions for that assignment");
            print("If you need to reauthenticate, delete ~/.targets-oauth");
        } else {
            print("Submissions downloaded.");
            print("Downloading template...");
            var oldwd = wd;
            wd = wd + "/$dirname";
            var oldprint = print;
            print = (a, [b]){};
            loadCallback = (){
                print = oldprint;
                wd = oldwd;
                print("Template downloaded.");
                Archive arch;
                try{
                    arch = new ZipDecoder().decodeBytes(response.bodyBytes);
                }on ArchiveException {
                    print("Something went wrong! Try again");
                    return;
                }
                print("Extracting submissions...");
                for (ArchiveFile file in arch){
                    String filename = file.name;
                    if(filename.endsWith("/")){
                        new Directory("$wd/$filename")..createSync(recursive: true);
                    }else{
                        new File("$wd/$filename")..createSync(recursive: true)..writeAsBytesSync(file.content);
                    }
                }
                print("Submisssions extracted to $dirname.");
            };
            return getAssignment(id,true,true);
        }
    });
}

batch(){
    File tests = new File("$wd/targets/tests.dart");
    File alttests = new File("$wd/template/targets/tests.dart");
    if(!tests.existsSync()&&!alttests.existsSync()){
        print("You need to add a template to this directory first!",RED);
        return;
    }
    String log = "";
    var directs = new Directory(wd).listSync();
    for(var dir in directs){
        if(dir is Directory){
            String dirpath = dir.path.split(Platform.pathSeparator).last;
            if(dirpath!="template"&&dirpath!="distributed"){
                log+="$dirpath\n****************************************\n";
                print("Testing $dirpath...");
                Directory temp = new Directory("$wd/.temp");
                temp.createSync();
                copyDirectory(new Directory("$wd/template"), temp);
                copyDirectory(dir, temp);
                new File("$wd/.temp/targets/tester.dart").writeAsStringSync(tester_dart);
                new File("$wd/.temp/targets/helpers.dart").writeAsStringSync(helpers_dart);
                var path = "$wd/.temp";
                var res = Process.runSync("dart",["targets/tester.dart"], workingDirectory: path);
                log+=res.stdout;
                log+=res.stderr;
                log+="\n";
                temp.deleteSync(recursive:true);
            }
        }
    }
    log = log.replaceAll("\u001b[0;31m","");
    log = log.replaceAll("\u001b[0;32m","");
    log = log.replaceAll("\u001b[0;36m","");
    log = log.replaceAll("\u001b[0;0m","");
    log = log.replaceAll("\r\n","\n");
    if(Platform.isWindows){
        log = log.replaceAll("\n","\r\n");
    }
    new File("$wd/log.txt").writeAsStringSync(log);
    print("Tests complete. Results outputted to 'log.txt'",GREEN);
}

distribute(){
    Directory template = new Directory("$wd/template");
    Directory dist = new Directory("$wd/distributed");
    if(!template.existsSync()){
        print("You need to add a template to this directory first!",RED);
        return;
    } else if(dist.existsSync()){
        print("Submissions already distributed!", RED);
        return;
    }
    dist.createSync();
    for(var dir in Directory.current.listSync()){
        if(dir is Directory){
            String dirpath = dir.path.split(Platform.pathSeparator).last;
            if(dirpath!="targets"&&dirpath!="template"&&dirpath!="distributed"){
                copyDirectory(template, new Directory("$wd/distributed/$dirpath"));
                copyDirectory(dir, new Directory("$wd/distributed/$dirpath"));
            }
        }
    }
}