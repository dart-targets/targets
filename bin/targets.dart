#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'dart:async';

const String VERSION = "0.5.0-experimental";

void main(var args){
    if(Platform.isWindows){
        HOME = Platform.environment['USERPROFILE'];
    }else{
        HOME = Platform.environment['HOME'];
    }
    if(args.length==0||args[0]=="info"||args[0]=="--version"){
        print("targets $VERSION", GREEN);
        print("darttargets.com", BLUE);
        print("Run 'targets help' for list of commands");
    }else if(args[0]=="help"||args[0]=="--help"){
        print("Usage: targets <command>");
        print("Student Commands:");
        print("   setup             Sets up targets for user");
        print("   get <assignment>  Downloads assignment with name from GitHub");
        print("   check             Runs tests on assignment");
        print("   submit            Submits assignment to server");
        print("   gui               Opens targets web interface");
        print("");
        print("Teacher Commands:");
        print("   init              Downloads template from GitHub");
        print("   init <assignment> Downloads assignment from GitHub as template");
        print("   batch             Grades multiple submissions downloaded from server");
        print("");
        print("Teachers should upload completed templates with tests to GitHub");
        print("Repo url with form github.com/username/targets-project");
        print("can be downloaded with targets get as username/project");
    }else if(args[0]=="setup"){
        setup();
    }else if(args[0]=="get"){
        if(args.length==1){
            print("No assignment detected",RED);
            return;
        }
        getAssignment(args[1],false);
    }else if(args[0]=="check"){
        checkAssign();
    }else if(args[0]=="submit"){
        submit(false);
    }else if(args[0]=="manual-submit"){
        submit(true);
    }else if(args[0]=="init"){
        if(args.length==1){
            getAssignment("example",true);
        }else{
            getAssignment(args[1],true);
        }
    }else if(args[0]=="batch"){
        batch();
    }else if(args[0]=="gui"){
        if(args.length == 1){
            runGuiServer(7620);
        }else runGuiServer(int.parse(args[1]));
    }else if(args[0]=="gui-server"){
        if(args.length == 1){
            runGuiServer(7620, false);
        }else runGuiServer(int.parse(args[1]), false);
    }
}

String wd = Directory.current.path;
HttpServer server;

runGuiServer(port, [browser=true]){
    HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((HttpServer newServer) {
        server = newServer;
        print("Connect to ws://localhost:$port at darttargets.com/gui",GREEN);
        print("This process must remain running for the GUI to work.");
        if(browser) openBrowser("http://darttargets.com/gui");
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
        }else if(command == 'check'){
            checkAssign();
        }else if(command == 'update'){
            serverPrint("Update triggered. Server about to close...");
            serverPrint(Process.runSync('pub',['global','activate','targets']).stdout);
            socket.add(JSON.encode({'type':'reboot'}));
            new Future.delayed(new Duration(milliseconds:2000),(){
                server.close(force:true);
                serverPrint("Starting new instance...");
                Process.start('targets',['gui-server']).then((process) {
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
        'version':VERSION
    }));
}

String HOME;

setup(){
    File info = new File("$HOME/.targets");
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

checkAssign(){
    if(!new File("$wd/targets/tester.dart").existsSync()){
        print("You are not in an assignment directory!",RED);
        return;
    }
    Process.start("dart",['targets/tester.dart'], workingDirectory:wd).then((process) {
        process.stdout.transform(new Utf8Decoder())
                .transform(new LineSplitter())
                .listen((String line){
                    print(line);
                });
    });
}

getAssignment(String name, bool isTeacher){
    if (name.contains(":")&&name.contains("/")){
        var parts = name.split(":");
        var parts2 = parts[1].split("/");
        String owner = parts[0];
        String githubUser = parts2[0];
        String id = parts2[1];
        String url = 'https://github.com/$githubUser/targets-$id';
        gitLoad(url, id, isTeacher, owner, githubUser);
    }else if(name.contains(":")){
        var parts = name.split(":");
        String url = 'https://github.com/dart-targets/targets-${parts[1]}.git';
        gitLoad(url, parts[1], isTeacher, parts[0], "dart-targets");
    }else if(name.contains("/")){
        var parts = name.split("/");
        String url = 'https://github.com/${parts[0]}/targets-${parts[1]}.git';
        gitLoad(url, parts[1], isTeacher);
    }else{
        String url = 'https://github.com/dart-targets/targets-$name.git';
        gitLoad(url, name, isTeacher);
    }
}

gitLoad(String url, String id, bool isTeacher, [String newOwner, String oldOwner='dart-targets']){
    if(new Directory(id).existsSync()){
        print("Assignment already downloaded",RED);
        return;
    }
    print("Checking if assignment exists...");
    Process.start("git",['ls-remote',url]).then((process) {
        process.stdout.transform(new Utf8Decoder())
                .transform(new LineSplitter())
                .listen((String line){
                    if(line.contains("refs/heads/master")){
                        if(!isTeacher)print("Found assignment. Downloading...",BLUE);
                        Process.start("git",['clone','--depth', '1',url, id],
                                workingDirectory:wd).then((prc) {
                            prc.exitCode.then((ec){
                                File testerFile = new File("$wd/$id/targets/tester.dart");
                                File helperFile = new File("$wd/$id/targets/helpers.dart");
                                testerFile.writeAsStringSync(tester_dart);
                                helperFile.writeAsStringSync(helpers_dart);
                                new Directory("$wd/$id/.git").deleteSync(recursive: true);
                                if(!isTeacher){
                                    File tests = new File("$wd/$id/targets/tests.dart");
                                    var lines = tests.readAsLinesSync();
                                    String text = "";
                                    for(String str in lines){
                                        if(str=='final String owner = "$oldOwner";'&&newOwner!=null){
                                            text += 'final String owner = "$newOwner";\n';
                                        }else if(!str.startsWith("///"))text+="$str\n";
                                    }
                                    tests.writeAsStringSync(text);
                                    print("Assignment downloaded to '$id'",GREEN);
                                }else print("Template downloaded to '$id'",GREEN);
                            });
                        });
                    }
                });
        process.stderr.transform(new Utf8Decoder())
                    .transform(new LineSplitter()).listen((line) {
                if(line=="remote: Repository not found."){
                    print("Could not find assignment",RED);
                }
            });
    });
}

submit(bool manual, {String withInfo:null, callback:null}){
    File info = new File("$HOME/.targets");
    if(!info.existsSync()&&withInfo==null){
        print("You need to run 'targets setup' first!",RED);
    }else if(! new File("$wd/targets/tester.dart").existsSync()){
        print("You are not in an assignment directory!",RED);
    }else{
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
                if(withInfo==null){
                    basicInfo = withInfo;
                }else basicInfo = info.readAsStringSync();
                String email = basicInfo.split("\n")[1];
                String enc_email = Base64.encode(email);
                String infoString = Base64.encode(basicInfo);
                String data = "$owner;$id;";
                for(String line in lines){
                    line = line.trim();
                    if(line.startsWith("*.")){
                        String extension = line.substring(1);
                        List<File> files = getFilesWithExtension(extension);
                        for(File f in files){
                            String relpath = f.path.substring(Directory.current.path.length+1);
                            String filedata = f.readAsStringSync();
                            data += relpath+","+Base64.encode(filedata)+"|";
                        }
                    }else{
                        String filedata = new File(wd+"/"+line).readAsStringSync();
                        data += line+","+Base64.encode(filedata)+"|";
                    }
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
                                    print("If your browser does not open, try 'targets manual-submit'", BLUE);
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

openBrowser(url){
    if(Platform.isMacOS){
        Process.start('open', [url]);
    }else if(Platform.isLinux){
        Process.start('x-www-browser', [url]);
    }else if(Platform.isWindows){
        Process.start('explorer', [url]);
    }
}

List<File> getFilesWithExtension(String extension){
    List<File> files = allFilesInDirectory(new Directory(wd));
    List<File> goodFiles = [];
    for(File f in files){
        if(f.path.endsWith(extension)) goodFiles.add(f);
    }
    return goodFiles;
}

List<File> allFilesInDirectory(Directory dir){
    List<File> files = [];
    if(dir.path==wd+Platform.pathSeparator+"targets") return files;
    var directs = dir.listSync();
    for(var dir in directs){
        if(dir is Directory){
            files.addAll(allFilesInDirectory(dir));
        }else{
            files.add(dir);
        }
    }
    return files;
}

batch(){
    File tests = new File("targets/tests.dart");
    File alttests = new File("template/targets/tests.dart");
    if(!tests.existsSync()&&!alttests.existsSync()){
        print("You need to add targets/tests.dart to this directory first!",RED);
        return;
    }
    String log = "";
    var directs = Directory.current.listSync();
    for(var dir in directs){
        if(dir is Directory){
            String dirpath = dir.path.split(Platform.pathSeparator).last;
            if(dirpath!="targets" && dirpath!="template"){
                log+="$dirpath\n****************************************\n";
                print("Testing $dirpath...");
                Directory temp = new Directory(".temp");
                temp.createSync();
                copyDirectory(new Directory("template"), temp);
                copyDirectory(new Directory("targets"), new Directory(".temp/targets"));
                copyDirectory(dir, temp);
                new File(".temp/targets/tester.dart").writeAsStringSync(tester_dart);
                new File(".temp/targets/helpers.dart").writeAsStringSync(helpers_dart);
                var current = Directory.current;
                Directory.current = ".temp";
                var res = Process.runSync("dart",["targets/tester.dart"]);
                log+=res.stdout;
                log+=res.stderr;
                log+="\n";
                Directory.current = current;
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
    new File("log.txt").writeAsStringSync(log);
    print("Tests complete. Results outputted to 'log.txt'",GREEN);
}

copyDirectory(Directory from, Directory to){
    var ps = Platform.pathSeparator;
    if(!from.existsSync()) return;
    if(!to.existsSync()) to.createSync();
    for(var item in from.listSync()){
        if(item is Directory){
            copyDirectory(item, new Directory(to.path+ps+item.path.split(ps).last));
        }else if(item is File){
            item.copySync(to.path+ps+item.path.split(ps).last);
        }
    }
}

const String PLAIN = "plain";
const String GREEN = "green";
const String RED = "red";
const String BLUE = "blue";

String prompt(String str, [String type=PLAIN]){
    if(type==PLAIN||Platform.isWindows){
        stdout.write(str);
    }else if(type==RED){
        stdout.write("\u001b[0;31m"+str+"\u001b[0;0m ");
    }else if(type==GREEN){
        stdout.write("\u001b[0;32m"+str+"\u001b[0;0m ");
    }else if(type==BLUE){
        stdout.write("\u001b[0;36m"+str+"\u001b[0;0m ");
    }
    return stdin.readLineSync();
}

Function print = (String str, [String type=PLAIN]){
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


/// Master helpers.dart and tester.dart (since pub global breaks the old way)
final String helpers_dart =
r"""// targets uses this file to test your code
// Changing it will not improve your grade
// It will only make it harder for you to run tests
import 'dart:io';
import 'dart:convert';

abstract class Target{
    Function test;
    String name;
    String error;
}

/// This creates an unscored target
/// [test] should return a bool
class TestTarget extends Target{
    Function test = ()=>false;
    String name;

    TestTarget(this.name, [Function test()]);
}

/// This creates a scored target
/// [test] can return a number (equal to points earned)
/// or a bool (true is full credit, false is no credit)
class ScoredTarget extends Target{
    Function test = ()=>0;
    String name;
    num points;

    ScoredTarget(this.name, this.points);
}

/// This creates a TestTarget that passes standard input
/// to a program that is run and checks if the output
/// matches what's provided
/// This involves several hacks, so it may break in the future
/// Also, using this will require you to download code and
/// batch test, as dart:io isn't available in the browser
class IOTarget extends TestTarget{

    /// command - Command that input is passed to
    /// input - Input (string or file) to pass to command
    /// output - Output (string or file) to match against command output
    /// preCommand - Command or list of commands to run
    ///             before passing in input
    /// postCommand - Command or list commands to run
    ///             after passing in input
    IOTarget(String name, String command, var input, var output, 
                        [var preCommand, var postCommand]):super(name){
        test = (){
            if(input is File){
                input = input.readAsStringSync().replaceAll("\r\n","\n");
            }
            if(output is File){
                output = output.readAsStringSync().replaceAll("\r\n","\n");
            }
            if(preCommand!=null){
                if(preCommand is String) runCommand(preCommand);
                else{
                    for(String str in preCommand) runCommand(str);
                }
            }
            var parts = command.split(" ");
            var exe = parts.removeAt(0);
            String pstr = "";
            for(String str in parts){
                pstr+="'$str',";
            }
            new File(".tempscript.dart").writeAsStringSync('''"""+io_script+r"""''');
            String out = Process.runSync('dart',['.tempscript.dart']).stdout;
            out = out.replaceAll("\r\n","\n");
            if(postCommand!=null){
                if(postCommand is String) runCommand(postCommand);
                else{
                    for(String str in postCommand) runCommand(str);
                }
            }
            if(Platform.isWindows) Process.runSync('del',['.tempscript.dart'],runInShell:true);
            else Process.runSync('rm',['.tempscript.dart']);
            bool result = output==out||output+"\n"==out;
            if(!result){
                this.error = "Expected $output, got $out";
            }
            return result;
        };
    }

    static IOTarget makeJava(String name, String mainClass, String input, 
                        String output, [List<String> otherClasses]){
        List<String> pre = ["javac $mainClass.java"];
        List<String> post = ["rm $mainClass.class"];
        String command = "java $mainClass";
        if(otherClasses != null){
            for(String str in otherClasses){
                pre.add("javac $str.java");
                post.add("rm $str.class");
            }
        }
        return new IOTarget(name, command, input, output, pre, post);
    }

    runCommand(String command){
        var parts = command.split(" ");
        var exe = parts.removeAt(0);
        if(exe=="rm"&&Platform.isWindows){
            exe = "del";
        }
        Process.runSync(exe, parts, runInShell:true);
    }
}""";

/// Used by IOTarget in helpers.dart
final String io_script = r'''
import 'dart:io';
import 'dart:convert';
main(){
    Process.start("$exe",[$pstr]).then((process) {
        process.stdout.transform(UTF8.decoder)
                .transform(new LineSplitter()).listen((data){
            stdout.writeln(data);
        });
        for(String str in """$input""".split("\\n")){
            process.stdin.writeln(str);
        }
        process.stdin.close();
    });
}
''';

final String tester_dart = 
r"""// targets uses this file to test your code
// Changing it will not improve your grade
// It will only make it harder for you to run tests

import 'dart:io';
import 'tests.dart' as Tests;
import 'helpers.dart';

main(List<String> args){
    if(args.length==0)runTests();
    else if(args[0]=="submit"){
        print(Tests.owner+":"+Tests.id);
        for(String file in Tests.files){
            print(file);
        }
    }
}

void runTests(){
    try{
        print(Tests.name, BLUE);
        print("");
    }catch(e){

    }
    List<Target> targets = Tests.getTargets();
    num score = 0;
    num maxPoints = 0;
    bool allPassed = true;
    for(Target t in targets){
        if(t is ScoredTarget){
            maxPoints += t.points;
            var s = 0;
            try{
                s = t.test();
                if(s==null)s=0;
            }catch(e){
                String error = e.toString().replaceAll("\n"," ");
                print("Test ${t.name} failed with error: $error", RED);
            }
            if(s is bool){
                if(s){
                    s = t.points;
                    score += t.points;
                }else s = 0;
            }else if(s != null) score += s;
            String extra = "";
            if(t.error!=null){
                extra = "- ${t.error}";
            }
            print("${t.name}: $s/${t.points} $extra");
        }else if(t is TestTarget){
            bool result = false;
            try{
                result = t.test();
                if(result==null)result=false;
            }catch(e){
                String error = e.toString().replaceAll("\n"," ");
                print("Test ${t.name} failed with error: $error", RED);
            }
            String extra = "";
            if(t.error!=null){
                extra = "- ${t.error}";
            }
            if(result){
                print("${t.name}: Passed $extra");
            }else{
                print("${t.name}: Failed $extra");
                allPassed = false;
            }
        }
    }
    if(maxPoints>0){
        if(score>=maxPoints) print("Total Score: $score/$maxPoints", GREEN);
        else print("Total Score: $score/$maxPoints", RED);
        if(!allPassed) print("Some Additional Tests Failed", RED);
    }else{
        if(allPassed) print("All Tests Passed!", GREEN);
        else print("Some Tests Failed", RED);
    }
}

const String PLAIN = "plain";
const String GREEN = "green";
const String RED = "red";
const String BLUE = "blue";

Function print = (String str, [String type=PLAIN]){
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
""";

class Base64 {
  static const List<String> _encodingTable = const [
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
      'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
      'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
      't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
      '8', '9', '*', '^'];
 
  static String encode(String income ) {
   
    List<int> data = income.codeUnits;
   
    List<String> characters = new List<String>();
    int i;
    for (i = 0; i + 3 <= data.length; i += 3) {
      int value = 0;
      value |= data[i + 2];
      value |= data[i + 1] << 8;
      value |= data[i] << 16;
      for (int j = 0; j < 4; j++) {
        int index = (value >> ((3 - j) * 6)) & ((1 << 6) - 1);
        characters.add(_encodingTable[index]);
      }
    }
    // Remainders.
    if (i + 2 == data.length) {
      int value = 0;
      value |= data[i + 1] << 8;
      value |= data[i] << 16;
      for (int j = 0; j < 3; j++) {
        int index = (value >> ((3 - j) * 6)) & ((1 << 6) - 1);
        characters.add(_encodingTable[index]);
      }
      //characters.add("=");
    } else if (i + 1 == data.length) {
      int value = 0;
      value |= data[i] << 16;
      for (int j = 0; j < 2; j++) {
        int index = (value >> ((3 - j) * 6)) & ((1 << 6) - 1);
        characters.add(_encodingTable[index]);
      }
      //characters.add("=");
      //characters.add("=");
    }
    StringBuffer output = new StringBuffer();
    for (i = 0; i < characters.length; i++) {
      if (i > 0 && i % 76 == 0) {
        output.write("\r\n");
      }
      output.write(characters[i]);
    }
    return output.toString();
  }
}