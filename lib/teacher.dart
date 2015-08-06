part of targets_cli;

/// Various commands for teachers
/// Moss-related code is in moss.dart

saveSubmissions(String templateId, String directory, var data) async {
    String working = wd;
    await new Directory("$working/$directory").create();
    for (var subm in data) {
        var info = {
            'course': subm['course'],
            'assignment': subm['assignment'],
            'student': subm['student'],
            'note': subm['note'],
            'time': subm['time']
        };
        String studentDir = subm['student'].replaceAll('@', '-at-');
        await new Directory('$working/$directory/$studentDir').create();
        await new File('$working/$directory/$studentDir/info.json').writeAsString(JSON.encode(info));
        for (var file in subm['files'].keys) {
            String contents = subm['files'][file];
            var fileObj = new File('$working/$directory/$studentDir/$file');
            await fileObj.create(recursive: true);
            await fileObj.writeAsString(contents);
        }
    }
    print("Downloading template...");
    var oldwd = working;
    working = working + '/$directory';
    var oldprint = print;
    print = (a, [b]){};
    await getAssignment(templateId, true, true);
    print = oldprint;
    working = oldwd;
}

batch([bool useJson = false]) async {
    if (useJson) {
        var results = await batchJson();
        if (results.containsKey('error')) return;
        await new File("$wd/results.json").writeAsString(JSON.encode(results));
        print("Tests complete. Results outputted to 'results.json'",GREEN);
        return;
    }
    File jsonFile = new File("$wd/template/targets/tests.json");
    File tests = new File("$wd/template/targets/tests.dart");
    if (jsonFile.existsSync()) {
        var config = JSON.decode(jsonFile.readAsStringSync());
        var testsdart = buildTestsDart(config);
        tests.writeAsStringSync(testsdart);
    }
    if(!tests.existsSync()){
        print("You need to add a template to this directory first!",RED);
        return;
    }
    String log = "";
    var directs = new Directory(wd).listSync();
    for(var dir in directs){
        if(dir is Directory){
            String dirpath = dir.path.split(Platform.pathSeparator).last;
            if(dirpath!="template"&&dirpath!="distributed"&&dirpath!='.temp'){
                var email = dirpath.replaceAll('-at-', '@');
                log+="$email\n****************************************\n";
                print("Testing $email...");
                Directory temp = new Directory("$wd/.temp");
                temp.createSync();
                copyDirectory(new Directory("$wd/template"), temp);
                copyDirectory(dir, temp);
                new File("$wd/.temp/targets/tester.dart").writeAsStringSync(tester_dart);
                new File("$wd/.temp/targets/helpers.dart").writeAsStringSync(helpers_dart);
                var path = "$wd/.temp/";
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

batchJson() async {
    String working = wd;
    File jsonFile = new File("$working/template/targets/tests.json");
    File tests = new File("$working/template/targets/tests.dart");
    if (jsonFile.existsSync()) {
        var config = JSON.decode(jsonFile.readAsStringSync());
        var testsdart = buildTestsDart(config);
        tests.writeAsStringSync(testsdart);
    }
    if(!(await tests.exists())){
        print("You need to add a template to this directory first!", RED);
        return {'error': 'No template'};
    }
    var results = {};
    await for (var dir in new Directory(working).list()){
        if(dir is Directory){
            String dirpath = dir.path.split(Platform.pathSeparator).last;
            if(dirpath!="template"&&dirpath!="distributed"&&dirpath!='.temp'){
                var email = dirpath.replaceAll('-at-', '@');
                print("Testing $email...");
                Directory temp = new Directory("$working/.temp");
                temp.createSync();
                copyDirectory(new Directory("$working/template"), temp);
                copyDirectory(dir, temp);
                await new File("$working/.temp/targets/tester.dart").writeAsString(tester_dart);
                await new File("$working/.temp/targets/helpers.dart").writeAsString(helpers_dart);
                var path = "$working/.temp/";
                var res = await Process.run("dart",["targets/tester.dart", "json"], workingDirectory: path);
                try {
                    results[email] = JSON.decode(res.stdout);
                } catch (ex, st) {
                    results[email] = 'error';
                }
                await temp.delete(recursive:true);
            }
        }
    }
    results['timestamp'] = new DateTime.now().millisecondsSinceEpoch;
    return results;
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