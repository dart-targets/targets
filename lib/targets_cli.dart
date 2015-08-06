library targets_cli;

import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

import 'package:redstone_mapper/mapper.dart' as mapper;
import 'package:redstone_mapper/mapper_factory.dart';

import 'package:targets/models.dart';

/// Student commands not related to submission
part 'student.dart';

/// Assignment submission
part 'submit.dart';

/// Graphical interface for students
part 'gui.dart';

/// Most commands for teachers
part 'teacher.dart';

/// Support for sending submissions to Moss
part 'moss.dart';

/// Builds a test.dart based on test.json
part 'testbuilder.dart';

/// Helpful utility methods and classes
part 'utils.dart';

/// Text of helpers.dart to be copied
part 'helpers_text.dart';

/// Text of tester.dart to be copied
part 'tester_text.dart';

/// Current working directory
/// Usually the users working directory when run from command line
/// but can be modified for use with the GUI
String wd = Directory.current.path;

/// Users home directory
/// Set in main method based on platform
String home = null;

/// Default server
String serverRoot = "http://localhost:8080";

setHome() {
    if (home!=null) return;
    if(Platform.isWindows){
        home = Platform.environment['USERPROFILE'];
    }else{
        home = Platform.environment['HOME'];
    }
}

Map<String, String> settings;

loadUserSettings() async {
    File file = new File("$home/.targets-settings");
    if(!file.existsSync()){
        settings = {
            "email": null,
            "moss": null,
            "oauth": null
        };
        return;
    }
    String json = await file.readAsString();
    settings = JSON.decode(json);
}

saveUserSettings() {
    File file = new File("$home/.targets-settings");
    String json = JSON.encode(settings);
    file.writeAsStringSync(json);
}

const String version = "0.8.0-experimental";

/// If not null, called by zipLoad when complete
Function loadCallback = null;