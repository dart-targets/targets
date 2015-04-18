import 'package:targets/targets_cli.dart';
import 'package:args/args.dart';

void main(var args){
    setHome();
    
    var results = parseArgs(args);
    var cmd = results.command;
    
    if (results['version'] || args.length == 0) {
        info();
        return;
    }
    if (results['help'] || args[0] == "help") {
        help();
        return;
    }
    
    if (cmd == null) {
        invalid(args);
        return;
    }
    
    var rest = cmd.rest;
    
    switch (cmd.name) {
        case 'setup':
            setup();
            break;
        case 'get':
        case 'init':
        case 'template':
            bool teacher = cmd.name != 'get';
            bool template = cmd.name == 'template';
            if (rest.length == 0 && teacher){
                getAssignment("example", true, template);
            } else if (rest.length == 1){
                getAssignment(rest[0], teacher, template);
            } else if (rest.length == 2 && !teacher){
                getZipAssignment(rest[0], rest[0]);
            } else invalid(args);
            break;
        case 'check':
            checkAssign();
            break;
        case 'gui':
            if (rest.length == 0){
                runGuiServer(7620, !cmd['server']);
            } else if(rest.length == 2){
                runGuiServer(int.parse(rest[1]), !cmd['server'], rest[2]);
            } else if(rest.length == 1){
                runGuiServer(int.parse(rest[1]), !cmd['server']);
            } else invalid(args);
            break;
        case 'submit':
            submit(cmd['manual']);
            break;
        case 'submissions':
            if (rest.length > 0) {
                getSubmissions(rest[0]);
            } else invalid(args);
            break;
        case 'batch':
            batch();
            break;
        case 'distribute':
            distribute();
            break;
        case 'moss':
            if (cmd['help']) mossHelp();
            else mossRun();
            break;
        default:
            invalid(args);
    }
}

ArgResults parseArgs(args) {
    var parser = new ArgParser();
    
    parser.addFlag('help', abbr: 'h', negatable: false, help: 'Display list of commands');
    parser.addFlag('version', abbr: 'v', negatable: false, 
                help: 'Display the application version.');
    
    var pSetup = parser.addCommand('setup');
    var pGet = parser.addCommand('get');
    var pCheck = parser.addCommand('check');
    var pGui = parser.addCommand('gui');
    pGui.addFlag('server', negatable: false, help: "Doesn't open web browser automatically");
    var pSubmit = parser.addCommand('submit');
    pSubmit.addFlag('manual', negatable: false, help: "Displays validation URL instead of opening browser");
    
    var pInit = parser.addCommand('init');
    var pSubmissions = parser.addCommand('submissions');
    var pTemplate = parser.addCommand('template');
    var pBatch = parser.addCommand('batch');
    var pDistribute = parser.addCommand('distribute');
    var pMoss = parser.addCommand('moss');
    pMoss.addFlag('help', abbr: 'h', negatable: false, help: 'Display list of Moss languages');

    try {
        return parser.parse(args);
    } on FormatException {
        invalid(args);
        exit(0);
    }
    return null;
}

help() {
    print("Usage: targets <command>");
    print("Student Commands:");
    print("   setup             Sets up targets for user");
    print("   get <assignment>  Downloads assignment with name from GitHub");
    print("   get <name> <url>  Downloads assignment with name from zip file");
    print("   check             Runs tests on assignment");
    print("   submit            Submits assignment to server");
    print("   gui               Opens targets web interface");
    print("");
    print("Teacher Commands:");
    print("   init              Downloads template from GitHub");
    print("   init <assignment> Downloads assignment from GitHub as template");
    print("   submissions <id>  Downloads all submissions and template for assignment");
    print("   template <assign> Like init, but downloads to folder called 'template'");
    print("   batch             Grades multiple submissions downloaded from server");
    print("   distribute        Combines template with each student's code");
    print("   moss              Submits submissions to Moss for similarity detection");
    print("");
    print("Teachers should upload completed templates with tests to GitHub");
    print("Repo url with form github.com/username/targets-project");
    print("can be downloaded with targets get as username/project");
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
