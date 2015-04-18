part of targets_cli;

/// Most commands for students
/// Submission and setup is in submit.dart

checkAssign(){
    if(!new File("$wd/targets/tester.dart").existsSync()){
        print("You are not in an assignment directory!",RED);
        return;
    }
    File testerFile = new File("$wd/targets/tester.dart");
    File helperFile = new File("$wd/targets/helpers.dart");
    testerFile.writeAsStringSync(tester_dart);
    helperFile.writeAsStringSync(helpers_dart);
    Process.start("dart",['targets/tester.dart'], workingDirectory:wd).then((process) {
        process.stdout.transform(new Utf8Decoder())
                .transform(new LineSplitter())
                .listen((String line){
                    print(line);
                });
    });
}

getAssignment(String name, bool isTeacher, [bool isTemplate=false]){
    String newOwner = null;
    String repoOwner = null;
    
    if (name.contains(":")) {
        newOwner = name.split(":")[0];
        name = name.split(":")[1];
    }
    
    if (name.contains("/")) {
        repoOwner = name.split("/")[0];
        if (newOwner == null) newOwner = repoOwner;
        name = name.substring(repoOwner.length + 1);
    } else {
        repoOwner = "dart-targets";
        newOwner = "dart-targets";
    }
    String url = "https://github.com/$repoOwner/targets-$name/archive/master.zip";
    if (name.contains("/")) {
        String repo = name.split("/")[0];
        url = "https://github.com/$repoOwner/$repo/archive/master.zip";
    }
    zipLoad(isTemplate, true, url, name, isTeacher, newOwner, repoOwner);
}

getZipAssignment(String name, String url){
    zipLoad(false, false, url, name, false);
}

zipLoad(bool isTemplate, bool fromGitHub, String url, String id, bool isTeacher, [String newOwner, String oldOwner='dart-targets']){
    String realID = id;
    String subdirLoc = null;
    if(id.contains("/") && fromGitHub) {
        id = id.replaceAll("/", "-");
        var parts = realID.split("/");
        subdirLoc = parts[1];
        for (int i = 2; i < parts.length - 1; i++) {
            subdirLoc += "/" + parts[i];
        }
        subdirLoc += "/targets-" + parts.last;
    }
    if(isTemplate) id = "template";
    if (new Directory("$wd/$id").existsSync()){
        print("Assignment already downloaded", RED);
        return;
    }
    print("Attempting assignment download...");
    http.get(url).then((response){
        Archive arch;
        try {
            arch = new ZipDecoder().decodeBytes(response.bodyBytes);
        } on ArchiveException {
            if(fromGitHub){
                print("Could not find an assignment with that id");
            }else{
                print("Could not find an assignment at that address");
            }
            return;
        }
        print("Download complete. Extracting...");
        for (ArchiveFile file in arch){
            String filename = file.name;
            if (realID.contains("/") && fromGitHub) {
                String prefix = "${realID.split('/')[0]}-master/$subdirLoc";
                if (!filename.startsWith(prefix)) continue;
                filename = filename.replaceFirst(prefix, id);
            } else if(fromGitHub) {
                filename = filename.replaceFirst("targets-$realID-master", id);
            } else filename = "$id/$filename";
            print(filename);
            if(!isTeacher && filename == "$id/targets/tests.dart"){
                File tests = new File("$wd/$id/targets/tests.dart")..createSync(recursive: true);
                var lines = UTF8.decode(file.content).split("\n");
                String text = "";
                for(String str in lines){
                    if(str=='final String owner = "$oldOwner";'&&newOwner!=null){
                        text += 'final String owner = "$newOwner";\n';
                    }else if(!str.startsWith("///"))text+="$str\n";
                }
                tests.writeAsStringSync(text);
            }else if(filename.endsWith("/")){
                new Directory("$wd/$filename")..createSync(recursive: true);
            }else{
                new File("$wd/$filename")..createSync(recursive: true)..writeAsBytesSync(file.content);
            }
        }
        File testerFile = new File("$wd/$id/targets/tester.dart");
        File helperFile = new File("$wd/$id/targets/helpers.dart");
        testerFile.writeAsStringSync(tester_dart);
        helperFile.writeAsStringSync(helpers_dart);
        if(isTeacher){
            print("Template downloaded to '$id'", GREEN);
        }else print("Assignment downloaded to '$id'", GREEN);
        if (loadCallback != null) {
            loadCallback();
        }
    });
}