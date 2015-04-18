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
    if (name.contains(":")&&name.contains("/")){
        var parts = name.split(":");
        var parts2 = parts[1].split("/");
        String owner = parts[0];
        String githubUser = parts2[0];
        String id = parts2[1];
        String url = 'https://github.com/$githubUser/targets-$id';
        zipLoad(isTemplate, true, url, id, isTeacher, owner, githubUser);
    }else if(name.contains(":")){
        var parts = name.split(":");
        String url = 'https://github.com/dart-targets/targets-${parts[1]}';
        String id = parts[1];
        zipLoad(isTemplate, true, url, id, isTeacher, parts[0], "dart-targets");
    }else if(name.contains("/")){
        var parts = name.split("/");
        String url = 'https://github.com/${parts[0]}/targets-${parts[1]}';
        String id = parts[1];
        zipLoad(isTemplate, true, url, id, isTeacher);
    }else{
        String url = 'https://github.com/dart-targets/targets-$name';
        zipLoad(isTemplate, true, url, name, isTeacher);
    }
}

getZipAssignment(String name, String url){
    zipLoad(false, false, url, name, false);
}

zipLoad(bool isTemplate, bool fromGitHub, String url, String id, bool isTeacher, [String newOwner, String oldOwner='dart-targets']){
    if(fromGitHub) url += "/archive/master.zip";
    String realID = id;
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
            if(fromGitHub) filename = filename.replaceFirst("targets-$realID-master", id);
            else filename = "$id/$filename";
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