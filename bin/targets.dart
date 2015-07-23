import 'package:targets/targets_cli.dart';
import 'package:args/args.dart';

import 'dart:async';
import 'dart:io';

Future main(var args) async {
    setHome();
    await loadUserSettings();
    
    var results = parseArgs(args);
    var cmd = results.command;
    
    serverRoot = results['server'];
    
    if (results['version'] || args.length == 0) {
        info();
        return null;
    }
    if (results['help'] || args[0] == "help") {
        help();
        return null;
    }
    
    if (cmd == null) {
        invalid(args);
        return null;
    }
    
    var rest = cmd.rest;
    
    switch (cmd.name) {
        case 'setup':
            return print("Student info is now provided with each submission.");
        case 'get':
        case 'init':
        case 'template':
            bool teacher = cmd.name != 'get';
            bool template = cmd.name == 'template';
            if (rest.length == 0 && teacher){
                return getAssignment("example", true, template);
            } else if (rest.length == 1){
                return getAssignment(rest[0], teacher, template);
            } else if (rest.length == 2 && !teacher){
                return getZipAssignment(rest[0], rest[1]);
            } else invalid(args);
            break;
        case 'check':
            return checkAssign();
        case 'console':
        case 'gui': // legacy
            if (rest.length == 0){
                return runGuiServer(7620, !cmd['background']);
            } else if(rest.length == 1){
                return runGuiServer(int.parse(rest[0]), !cmd['background']);
            } else invalid(args);
            break;
        case 'submit':
            return submitCLI();
        case 'submissions':
            if (rest.length > 0) {
                return getSubmissions(rest[0]);
            } else invalid(args);
            break;
        case 'batch':
            batch();
            break;
        case 'distribute':
            distribute();
            break;
        case 'moss':
            if (cmd['help']) {
                mossHelp();
                break;
            }
            return mossRun();
        default:
            invalid(args);
    }
    return null;
}

ArgResults parseArgs(args) {
    var parser = new ArgParser();
    
    parser.addFlag('help', abbr: 'h', negatable: false, help: 'Display list of commands');
    parser.addFlag('version', abbr: 'v', negatable: false, 
                help: 'Display the application version.');
    parser.addOption('server', help: 'Change the default server', defaultsTo: serverRoot);
    
    parser.addCommand('setup');
    parser.addCommand('get');
    parser.addCommand('check');
    var pGui = parser.addCommand('console');
    pGui.addFlag('background', negatable: false, help: "Doesn't open web browser automatically");
    // legacy
    parser.addCommand('gui', pGui);
    
    var pSubmit = parser.addCommand('submit');
    
    parser.addCommand('init');
    parser.addCommand('submissions');
    parser.addCommand('template');
    parser.addCommand('batch');
    parser.addCommand('distribute');
    var pMoss = parser.addCommand('moss');
    pMoss.addFlag('help', abbr: 'h', negatable: false, help: 'Display list of Moss languages');

    try {
        return parser.parse(args);
    } on FormatException {
        invalid(args);
        exit(1);
    }
    return null;
}

help() {
    print("Usage: targets <command>");
    print("Student Commands:");
    print("   get <assignment>  Downloads assignment with name from GitHub");
    print("   get <name> <url>  Downloads assignment with name from zip file");
    print("   check             Runs tests on assignment");
    print("   submit            Submits assignment to server");
    print("   console           Opens targets web interface");
    print("");
    print("Teacher Commands:");
    print("   init              Downloads template from GitHub");
    print("   init <assignment> Downloads assignment from GitHub as template");
    print("   submissions <id>  Downloads all submissions and template for assignment");
    print("   template <assign> Like init, but downloads to folder called 'template'");
    print("   batch             Grades multiple submissions downloaded from server");
    print("   distribute        Combines template with each student's code");
    print("   moss              Submits submissions to Moss for similarity detection");
    print("Options:");
    print("   --server          Change server from default ($serverRoot)");
    print("");
    print("Teachers should upload completed templates with tests to GitHub");
    print("Repo url with form github.com/username/targets-project");
    print("can be downloaded with `targets get username/project`");
}

info() {
    print("targets $version", GREEN);
    print("darttargets.com", BLUE);
    print("Run 'targets --help' for list of commands");
}

invalid(args) {
    print("'targets ${args.join(' ')}' is not a valid command.");
    print("Run 'targets --help' for a list of commands."); 
}

// For use in tests

setHomeDir(String h) => home = h;
setWorkingDir(String w) => wd = w;
setPrint(var fn) => print = fn;
