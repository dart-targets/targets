#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

const String VERSION = "0.2.1";

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
        print("");
        print("Teacher Commands:");
        print("   init              Downloads template from GitHub");
        print("   init <assignment> Downloads assignment from GitHub as template");
        print("");
        print("Teachers should upload completed templates with tests to GitHub");
        print("Repo url with form github.com/username/targets-project");
        print("can be downloaded with get command as username/project");
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
    }
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
    if(!new File("targets/tester.dart").existsSync()){
        print("You are not in an assignment directory!",RED);
        return;
    }
    Process.start("dart",['targets/tester.dart']).then((process) {
        process.stdout.transform(new Utf8Decoder())
                .transform(new LineSplitter())
                .listen((String line){
                    print(line);
                });
    });
}

getAssignment(String name, bool isTeacher){
    //Process.start("git",['clone','https://github.com/jathak/ucapcredit.git']);
    if (name.contains(":")&&name.contains("/")){
        var parts = name.split(":");
        var parts2 = parts[1].split("/");
        String owner = parts[0];
        String githubUser = parts2[0];
        String id = parts2[1];
        String url = 'https://github.com/$githubUser/targets-$id';
        gitLoad(url, id, isTeacher, owner);
    }else if(name.contains(":")){
        var parts = name.split(":");
        String url = 'https://github.com/dart-targets/targets-${parts[1]}.git';
        gitLoad(url, parts[1], isTeacher, parts[0]);
    }else if(name.contains("/")){
        var parts = name.split("/");
        String url = 'https://github.com/${parts[0]}/targets-${parts[1]}.git';
        gitLoad(url, parts[1], isTeacher);
    }else{
        String url = 'https://github.com/dart-targets/targets-$name.git';
        gitLoad(url, name, isTeacher);
    }
}

gitLoad(String url, String id, bool isTeacher, [String newOwner]){
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
                        Process.start("git",['clone',url]).then((prc) {
                            prc.exitCode.then((ec){
                                new Directory("targets-$id").renameSync(id);
                                String baseName = Platform.script.toFilePath();
                                baseName = baseName.substring(0, baseName.length-12);
                                String testerName = baseName + "tester.dart";
                                String helperName = baseName + "helpers.dart";
                                new File(testerName).copySync("$id/targets/tester.dart");
                                new File(helperName).copySync("$id/targets/helpers.dart");
                                new Directory("$id/.git").deleteSync(recursive: true);
                                if(!isTeacher){
                                    File tests = new File("$id/targets/tests.dart");
                                    var lines = tests.readAsLinesSync();
                                    String text = "";
                                    for(String str in lines){
                                        if(str=='final String owner = "dart-targets";'&&newOwner!=null){
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

submit(bool manual){
    File info = new File("$HOME/.targets");
    if(!info.existsSync()){
        print("You need to run 'targets setup' first!",RED);
    }else if(! new File("targets/tester.dart").existsSync()){
        print("You are not in an assignment directory!",RED);
    }else{
        Process.run('dart', ['targets/tester.dart','submit']).then((ProcessResult results) {
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
                String infoString = Base64.encode(info.readAsStringSync());
                String data = "$owner;$id;";
                for(String line in lines){
                    line = line.trim();
                    data += line+","+Base64.encode(new File(line).readAsStringSync())+"|";
                }
                data = data.substring(0,data.length-1) + ";" + infoString;
                String fullData = Base64.encode(data).replaceAll("\r\n","");
                String url = "http://targets.jackthakar.com/submit?data="+fullData;
                if(manual){
                    print("Please paste the following URL into your browser:",BLUE);
                    print(url);
                }else if(Platform.isMacOS){
                    Process.start('open',[url]);
                    print("If your browser does not open, try 'targets manual-submit'", BLUE);
                }else if(Platform.isLinux){
                    Process.start('xdg-open',[url]);
                    print("If your browser does not open, try 'targets manual-submit'", BLUE);
                }else if(Platform.isWindows){
                    Process.run('start',[url]);
                    print("If your browser does not open, try 'targets manual-submit'", BLUE);
                }
            }
        });
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