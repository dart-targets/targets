/// Tests the Targets Command Line Interface

import "dart:io";
import "dart:async";

import "package:test/test.dart";
import "../bin/targets.dart" as CLI;

// access token for targetsbot
// broken up to prevent GitHub from revoking it
String oauth = "c31147496528497955" + "42f06a1d2642655e00f83e";

void main() {
    setUp(setup);
    testStudentCommands();
    testTeacherCommands();
    tearDown(cleanup);
}

void testStudentCommands() {
    test("Assignment Download", () async{
        await targets("get", "dart-targets/example");
        expect(nextLine(), equals("Attempting assignment download..."));
        expect(nextLine(), equals("Download complete. Extracting..."));
        expect(lines.last, equals("Assignment downloaded to 'example'"));
        Directory assign = new Directory(wd + "/example");
        expect(assign.existsSync(), isTrue);
    });
    test("Invalid Assignment", () async{
        await targets("get", "jathak/lasdfjadslkfjdsafl");
        expect(nextLine(), equals("Attempting assignment download..."));
        expect(nextLine(), equals("Could not find an assignment with that id"));
    });
    test("Check Full Credit", () async{
        await targets("get", "dart-targets/example");
        Directory assign = new Directory(wd + "/example");
        expect(assign.existsSync(), isTrue);
        CLI.setWorkingDir(wd + "/example");
        await targets("check");
        expect(nextLine(), equals("Example Assignment for targets"));
        expect(nextLine(), equals("Fibonacci: 3/3"));
        expect(nextLine(), equals("Factorial: 3/3"));
        expect(nextLine(), equals("Total Score: 6/6"));
    });
    test("Check No Credit", () async{
        await targets("get", "dart-targets/example");
        new File(wd+"/example/example.dart").writeAsStringSync("""
        int fib(n) => -1;
        int fact(n) => -1;
        """);
        CLI.setWorkingDir(wd + "/example");
        await targets("check");
        expect(nextLine(), equals("Example Assignment for targets"));
        expect(nextLine(), equals("Fibonacci: 0/3"));
        expect(nextLine(), equals("Factorial: 0/3"));
        expect(nextLine(), equals("Total Score: 0/6"));
    });
}

void testTeacherCommands() {
    test("Download Submissions", () async{
        await targets("submissions", "targetsbot:dart-targets/example");
        String subs = wd + "/targetsbot-example";
        Directory d = new Directory(subs);
        expect(d.existsSync(), isTrue);
        Directory correct = new Directory(subs + "/jthakar-berkeley.edu");
        Directory incorrect = new Directory(subs + "/jathakar-ucdavis.edu");
        expect(correct.existsSync(), isTrue);
        expect(incorrect.existsSync(), isTrue);
    });
    test("Batch Grade", () async{
        await targets("submissions", "targetsbot:dart-targets/example");
        String subs = wd + "/targetsbot-example";
        CLI.setWorkingDir(subs);
        await targets("batch");
        String contents = new File(subs + "/log.txt").readAsStringSync();
        expect(contents, contains(expectedCorrect));
        expect(contents, contains(expectedIncorrect));
    });
}

String expectedCorrect = """jthakar-berkeley.edu
****************************************
Example Assignment for targets

Fibonacci: 3/3
Factorial: 3/3
Total Score: 6/6""";
String expectedIncorrect = """jathakar-ucdavis.edu
****************************************
Example Assignment for targets

Fibonacci: 0/3
Factorial: 0/3
Total Score: 0/6""";

var home;
var wd;

void setup() {
    home = Directory.current.path + "/.home";
    wd = Directory.current.path + "/.testing";
    Directory d = new Directory(wd);
    if (d.existsSync()) {
        d.deleteSync(recursive: true);
    }
    d.createSync();
    CLI.setHomeDir(home);
    d = new Directory(home);
    if (d.existsSync()) {
        d.deleteSync(recursive: true);
    }
    d.createSync();
    CLI.setWorkingDir(wd);
    new File(home+"/.targets-oauth").writeAsStringSync(oauth);
}

void cleanup() {
    new Directory(wd).deleteSync(recursive: true);
    new Directory(home).deleteSync(recursive: true);
}

List<String> lines;

String nextLine() {
    return lines.removeAt(0).trim();
}

Future targets([a=null, b=null, c=null, d=null]) {
    var args = [];
    for (var arg in [a, b, c, d]) {
        if (arg != null) args.add(arg);
    }
    lines = [];
    CLI.setPrint((String str, [String type]){
        str = str.replaceAll("\u001b[0;0m", "");
        str = str.replaceAll("\u001b[0;31m", "");
        str = str.replaceAll("\u001b[0;32m", "");
        str = str.replaceAll("\u001b[0;36m", "");
        var strLines = str.split("\n");
        for (var s in strLines) {
            if(s != "") lines.add(s);
        }
    });
    return CLI.main(args);
}

time(millis){
    return new Future.delayed(new Duration(milliseconds:millis), ()=>null);
}


