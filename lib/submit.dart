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

submitCLI() async {
    String email = settings['email'];
    if (email == null) {
        print("Please enter the email of the Targets account to submit your assignment as.");
        email = prompt("Email: ");
        while (email == "") {
            email = prompt("Email: ");
        }
    } else {
        print("Enter your email or just hit enter to use the default.");
        String input = prompt("Email ($email): ");
        if (input != "") {
            email = input;
        }
    }
    settings['email'] = email;
    saveUserSettings();
    var note = prompt("Note to teacher (hit enter to skip): ");
    if (note == "") note = null;
    print("Submitting as $email...");
    String hash = await uploadSubmission(email, note);
    print("Your submission has been uploaded to the server, but you must validate it before it is marked as submitted.");
    print("If you do not validate your submission within 10 minutes, it will be deleted and you will have to re-upload.");
    String validationUrl = "$serverRoot/validate/$hash";
    print("Validation URL: $validationUrl", BLUE);
    openBrowser(validationUrl);
}

uploadSubmission(String email, String note) async {
    File testerFile = new File("$wd/targets/tester.dart");
    File helperFile = new File("$wd/targets/helpers.dart");
    await testerFile.writeAsString(tester_dart);
    await helperFile.writeAsString(helpers_dart);
    var results = await Process.run('dart', 
        ['targets/tester.dart','submit'], workingDirectory:wd);
    List<String> lines = results.stdout.split("\n");
    if(lines[0].contains("Unhandled exception:")){
        print("Assignment is corrupted. Redownload or contact your teacher.",RED);
        return;
    }
    Submission subm = new Submission();
    subm.course = lines[0].split(":")[0].trim();
    subm.assignment = lines[0].split(":")[1].trim();
    subm.student = email;
    if (note != null) {
        subm.note = note;
    }
    lines.removeAt(0);
    lines.removeLast();
    subm.files = {};
    for (String line in lines) {
        line = line.trim();
        if (line.startsWith("*.")) {
            String extension = line.substring(1);
            List<File> files = getFilesWithExtension(extension);
            for(File f in files){
                String relpath = f.path.substring(Directory.current.path.length+1);
                String filedata = await f.readAsString();
                subm.files[relpath] = filedata;
            }
        } else if (line.startsWith("!")) {
            subm.files.remove(line.substring(1));
        } else {
            String filedata = await new File(wd+"/"+line).readAsString();
            subm.files[line] = filedata;
        }
    }
    bootstrapMapper();
    String encSubm = mapper.encodeJson(subm);
    print("Uploading submission...");
    String url = "$serverRoot/api/v1/upload";
    var response = await http.post(url, body: encSubm, headers: {
        'Content-Type': 'application/json'
    });
    if (response.statusCode != 200) {
        throw new Exception("Upload failed with code ${response.statusCode} and response ${response.body}");
    }
    return response.body;
}
