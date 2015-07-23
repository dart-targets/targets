library models;

import 'package:crypto/crypto.dart';

import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper/mapper.dart';

class Student {
    
    @Field()
    String name;
    
    @Field()
    String email;
    
    @Field()
    List<String> courses = [];
}

class Course {
    
    @Field()
    String id;
    
    @Field()
    String name;
    
    @Field(model: 'allowed_students')
    List<String> allowedStudents = [];
    
    @Field(model: 'enrolled_students')
    List<String> enrolledStudents = [];
    
    /// Returns true if [student] is allowed in course
    /// Returns false otherwise
    bool allows(Student student) {
        print(encodeJson(student));
        print(encodeJson(this));
        for (String allowed in allowedStudents) {
            if (allowed == student.email || 
                    (allowed.startsWith("@") &&
                    student.email.endsWith(allowed))) {
                return true;
            } 
        }
        return false;
    }
}

class Assignment {
    
    @Field()
    String course;
    
    @Field()
    String id;
    
    @Field()
    DateTime open;
    
    @Field(view: 'open', model: 'open')
    String get open_str => open.toIso8601String();
    
    @Field()
    DateTime deadline;
    
    @Field(view: 'deadline', model: 'deadline')
    String get deadline_str => deadline.toIso8601String();
    
    @Field()
    DateTime close;
    
    @Field(view: 'close', model: 'close')
    String get close_str => close.toIso8601String();
    
    @Field()
    String note;
    
    @Field(model: 'github_url')
    String githubUrl;
    
}

class Submission {
    
    @Field()
    String course;
    
    @Field()
    String assignment;
    
    @Field()
    String student;
    
    @Field()
    DateTime time;
    
    @Field(view: 'time', model: 'time')
    String get time_str {
        if (time == null) return null;
        return time.toIso8601String();
    }
    
    @Field()
    Map<String, String> files;
    
    @Field()
    String note;
    
}

/// Generates an MD5 hash for the given object (must be in models)
String hash(var obj) {
    if (!(obj is Student || obj is Course || 
            obj is Assignment || obj is Submission)) {
        throw new Exception("Object to hash must be in models.dart");
    }
    String json = encodeJson(obj);
    var md5 = new MD5();
    md5.add(json.codeUnits);
    var bytes = md5.close();
    return CryptoUtils.bytesToHex(bytes);
}