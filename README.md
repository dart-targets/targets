## targets ##

[![Build Status](https://travis-ci.org/dart-targets/targets.svg)](https://travis-ci.org/dart-targets/targets)

Targets is an assignment manager and simple autograder intended for use in high school CS classes.

Targets consists of three core components: a server that stores course, assignment, and submission information, a desktop client that runs tests and uploads submissions, and a web console for teachers and students to interact with both the server and the desktop client.

This Pub package contains the desktop client, and can be installed or updated with:

    pub global activate targets

The server code (which also includes the web console) is available on [GitHub](https://github.com/dart-targets/targets_server) if you want to host it yourself. By default, the desktop client connects to the Targets server running at [codetargets.com](http://codetargets.com). If you are interested in using this server for a class, please [contact us](mailto:targets@codetargets.com). If you're hosting your own server, add `--server http://yourserver.com` to the end of every command.

### Using the Web Console ###

Most actions will be done through the web console, which can be launched with `targets console`. By default, this will open the web console in your default browser. You can skip this with the `--background` flag. Targets will run a web socket server at `ws://localhost:7620`, which the web console will attempt to connect to.

Even when the web console is not connected to the desktop client, teachers will be able to create and edit assignments and view submissions made by students. Students will be able to view available assignments and their past submissions. If the web console is connected to the desktop client, teachers will be able to download and batch grade student submissions and students will be able to download assignment templates, run tests on their code, and submit their work. Both students and teachers will also have access to a code editor for the files in the directory where the desktop client is running from. From the editor, students and teachers can also run Dart, Java, and Python files.

### Requirements ###

This desktop client requires version 1.9+ of the Dart SDK to be installed on your path. If restrictions on school computers prevent you from installing the Dart SDK, it can also be set up on a flash drive ([send us an email](mailto:targets@codetargets.com) for more information on this).

Each teacher and TA/grader will need a GitHub account to log into the web console. All members of the course staff should be added to a GitHub organization that will be used as the course ID. Organization owners will be recognized as teachers by the Targets server and will have full read and write access to the course. Non-owner members will be recognized as graders/TAs by the server and will have read-only access to assignments and student submissions.

Each student will need a Google account to log into the web console. Their Google email will identify their submissions to teachers. Teachers need to provide a list of emails that are allowed to enroll in the course before students can join. If students have a Google account created by your school or district, teachers can also whitelist an entire domain.

Both students and teachers will need access to a modern web browser that supports web sockets. If you have issues connecting to the desktop client from Internet Explorer or Microsoft Edge, it may be due to Microsoft not allowing remote pages to connect to local web sockets. We believe to have worked around this restriction in the current version of the server, but if you have issues, switch to Chrome or Firefox (portable versions of both of these browsers are available if you're using school computers that only have IE installed).

### Creating Assignments ###

TODO