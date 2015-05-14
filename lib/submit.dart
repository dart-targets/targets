part of targets_cli;

/// Contains code related to assignment submission

setup(){
    File info = new File("$home/.targets");
    if(info.existsSync()){
        print("You previously entered:",BLUE);
        print(info.readAsStringSync());
        print("");
    }
    String input = "";
    input += prompt("First Name: ")+" ";
    input += prompt("Last Name: ")+"\n";
    input += prompt("Google Email: ");
    String forClass = prompt("Are you using targets for class? (y/n): ");
    if(forClass.toLowerCase()=="y"||forClass.toLowerCase()=="yes"){
        String hasID = prompt("Does your teacher want you to submit your student id? (y/n): ");
        if(hasID.toLowerCase()=="y"||hasID.toLowerCase()=="yes"){
            input += "\n"+prompt("Student ID: ");
        }
    }
    info.writeAsStringSync(input);
}

submit(bool manual, {String withInfo:null, callback:null}){
    File info = new File("$home/.targets");
    if(!info.existsSync()&&withInfo==null){
        print("You need to run 'targets setup' first!",RED);
    }else if(! new File("$wd/targets/tester.dart").existsSync()){
        print("You are not in an assignment directory!",RED);
    }else{
        File testerFile = new File("$wd/targets/tester.dart");
        File helperFile = new File("$wd/targets/helpers.dart");
        testerFile.writeAsStringSync(tester_dart);
        helperFile.writeAsStringSync(helpers_dart);
        Process.run('dart', ['targets/tester.dart','submit'], 
                workingDirectory:wd).then((ProcessResult results) {
            List<String> lines = results.stdout.split("\n");
            if(lines[0].contains("Unhandled exception:")){
                print("Assignment is corrupted. Redownload or contact your teacher.",RED);
            }else{
                String owner = lines[0].split(":")[0].trim();
                if(owner=="dart-targets"){
                    print("You can't submit without a teacher",RED);
                    return;
                }
                String id = lines[0].split(":")[1].trim();
                lines.removeAt(0);
                lines.removeLast();
                String basicInfo;
                if(withInfo!=null){
                    basicInfo = withInfo;
                }else basicInfo = info.readAsStringSync();
                String email = basicInfo.split("\n")[1];
                String enc_email = Base64.encode(email);
                String infoString = Base64.encode(basicInfo);
                String data = "$owner;$id;";
                var fileData = {};
                for (String line in lines) {
                    line = line.trim();
                    if (line.startsWith("*.")) {
                        String extension = line.substring(1);
                        List<File> files = getFilesWithExtension(extension);
                        for(File f in files){
                            String relpath = f.path.substring(Directory.current.path.length+1);
                            String filedata = f.readAsStringSync();
                            fileData[relpath] = filedata;
                        }
                    } else if (line.startsWith("!")) {
                        fileData.remove(line.substring(1));
                    } else {
                        String filedata = new File(wd+"/"+line).readAsStringSync();
                        fileData[line] = filedata;
                    }
                }
                for (var key in fileData.keys) {
                    data += key + "," + Base64.encode(fileData[key]) + "|";
                }
                data = data.substring(0,data.length-1) + ";" + infoString;
                String fullData = Base64.encode(data).replaceAll("\r\n","");
                HttpClient client = new HttpClient();
                print("Uploading submission...");
                client.postUrl(Uri.parse("http://darttargets.com/submit/tempsubmit.php"))
                    .then((HttpClientRequest request) {
                        request.headers.contentType = ContentType.TEXT;
                        request.headers.contentLength = fullData.length;
                        request.write(fullData);
                        return request.close();
                      }).then(( HttpClientResponse res ) {
                        res.transform(UTF8.decoder).listen((contents) {
                            print(contents);
                            String url = "http://darttargets.com/validate/?owner=$owner&project=$id&identifier=$enc_email";
                            if(callback == null){
                                if(manual){
                                    print("Please paste the following URL into your browser:",BLUE);
                                    print(url);
                                }else {
                                    openBrowser(url);
                                    print("If your browser does not open, try 'targets submit --manual'", BLUE);
                                }
                                new Future.delayed(new Duration(seconds:2),()=>exit(0));
                            }else{
                                callback(url);
                            }
                        });
                      });
            }
        });
    }
}