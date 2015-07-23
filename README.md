## targets ##

**Note: This branch is designed to connect to the [new Targets server](https://github.com/dart-targets/targets_server) that is currently being developed to replace the existing PHP scripts. DO NOT MERGE**

[![Build Status](https://travis-ci.org/dart-targets/targets.svg)](https://travis-ci.org/dart-targets/targets)

Targets is an assignment manager and autograder intended for high school CS classes that uses GitHub to download assignment templates.

This README describes the fundamentals of using Targets. [Full documentation](http://docs.darttargets.com) intended for teachers and students is also available, though it is currently a draft and is subject to change.

`targets get example` downloads an example assignment from `https://github.com/dart-targets/targets-example`.

You can download assignments you create with `targets get username/assignment` which would download from `https://github.com/username/targets-assignment`.

Starting in 0.7.0, Targets can download assignments from any zip archive that is publicly accessible on the web. Just use:

    targets get assignment-name http://example.com/template.zip

If you want to use an assignment someone else has created (but have submissions sent to you), add your username and a colon. `targets get userA:userB/assignment` downloads from `https://github.com/userB/targets-assignment` but alters the `tests.dart` file so that submissions are sent to `userA`.

### Creating Templates ###

To create a new assignment template, you can download a fully commented version of an existing template with `targets init`. This command will download the `example` template I've created. You can add an assignment argument to download some other assignment.

`targets init` works almost exactly the same as `targets get`, except that it leaves comments in the `tests.dart` file untouched. `//`, `/*`, and `/**` style comments are kept with either command, but unindented `///` comments are removed when using `targets get`. The `example` template includes many of these comments to explain the structure of `tests.dart`.

Once you've completed your assignment template, push it to a new GitHub repository. The repo name should start with `targets-`. Students can then download your new assignment with `targets get user/id` when `user` is your GitHub username and `id` is everything after the `targets-` in your repo name.

Starting in 0.7.4, you can keep templates in subdirectories of GitHub repositories. For example, an ID like `user/assign/dirA/dirB` refers to a Targets template in the subdirectory `dirA/targets-dirB` within the GitHub repo at `https://github.com/user/assign`. The assignment will be downloaded to a directory called `assign-dirA-dirB`. You should use this for the `id` field of `tests.dart`. This allows you to add a Targets template to an existing repository or include multiple Targets templates in the same repository.

If you would prefer to keep your assignment templates private, you can instead put the template in a zip file (with the root of the template at the root of the zip) and share the URL with your students. Note that in this case, you cannot share the same zip with other teachers as Targets will not modify the owner property in `tests.dart`. If you want to share assignments, post them to GitHub (it also makes them easier for your students to download).

### Submission and Grading ###

Students can run the tests on their assignment with `targets check` and submit with `targets submit` (after first running `targets setup`). Student submissions are validated with a Google account (the primary email of the account must match the one their enter in `targets setup`). 

Submissions are made to the GitHub user or organization name set in the `owner` variable of `tests.dart`. Once submissions have been uploaded, you can view and download them [here](http://darttargets.com/results) by logging into your GitHub account.

Once you download a zip of submissions, you can run tests on all them with `targets batch`. Just put a version of your assignment template with more rigorous tests into a folder called `template` within the extracted zip file. `targets batch` will output a log of tests on all submissions to `log.txt`.

Starting in 0.7.3, you can download submissions from the command line with `targets submissions username/assignment`. This will require that you create an OAuth key for GitHub, but then you can set up a directory to run `targets batch` with just one command.

Additionally, if you open the submission viewer in Dartium, you can paste in code from a `tests.dart` file to run tests of Dart code without downloading submissions. Please note that this feature works best with very simple assignments. When all code is in one file, it should work fine. It should theoretically work with multiple files, as long as they are all uploaded with students' submissions, but things may break. If the web grader does not work, just download the zip and use `targets batch`.

For the time being, the submission service is free of charge. The server is running on "unlimited" shared hosting, so I shouldn't have any issues keeping it free, unless demand is such that I go beyond whatever my host deems "unlimited" to be. To keep the server lightweight, all submissions will be deleted after 30 days. Make sure to download the zip archive within that window or your students will have to resubmit.

### Similarity Detection ###

Starting in 0.6.0, Targets supports easy submission of student code to [Moss](http://moss.stanford.edu) for similarity detection. You can run `targets moss` on any set of student submissions that you can run `targets batch` on. Once you enter the command, you'll be prompted for the language your students' code is in, the file extension to submit, and your Moss account ID. In addition to student code, Targets will also upload code in `template` to Moss to improve accuracy by providing a baseline. Once Moss responds, your web browser will open with the results.

### Languages Other Than Dart ###

Targets is best suited for testing Dart code. However, version 0.2.3 added support for `IOTarget`, which lets you test output for given input sent to a program. To see an example of how `IOTarget` works, `targets init java-example`. I've tested simple examples on both OSX and Windows, but testing more complex programs may result in some issues, particularly cross-platform. If you use `IOTarget`, make sure to use `targets check` on a completed version of your template on each OS that your students may use.

Prior to 0.7.2, `IOTarget` tests could not be scored. With the new properties for `TestTarget` (which `IOTarget` extends) in 0.7.2, each `IOTarget` can add an all-or-nothing amount of points to the total score.

For obvious reasons, `IOTarget` is not supported by the web grader, though `targets batch` should work fine.

### Web Interface ###

Since targets is primarily intended for high school CS courses (there's much better software out there for universities), you may not want your students to have to access targets from the command line, both because command line programs can be daunting to high school students and because your school's IT department may not want to provide command line access to students.

To allow student use of targets outside of the command line, version 0.5.0 adds the `targets gui` command. This starts a local web socket server on the student's machine and opens their web browser to [darttargets.com/gui](http://darttargets.com/gui). From here, students can download assignments, run tests, and submit their work without touching the command line. There's even a button to upgrade targets through pub (though this may not work on all setups).

Downloading templates from the zip files using the web console is supported as of 0.7.6.

By default, the local server is hosted on port 7620 (fun fact: this number was reached by adding the ASCII codes of the letters in "targets" and multiplying by 10). You can customize it with `targets gui #`, where # is your preferred port. If using the default interface URL, the default port will automatically be changed in the page that launches by adding "?port=#" to the end.

The source of the web interface is included in the pub package and on GitHub if you want to customize it. To have Targets launch your new version, use `targets gui # http://yourinterface.com`. You can put your custom in a shell script to allow your students to launch the interface with one click.

### Sample Project: Enigma ###

In addition to a few small templates hosted on the `dart-targets` GitHub, I'm currently developing a large sample project for Targets in which students build an Enigma machine simulator and then attempt to break the code. The project is hosted [here](https://github.com/dart-targets/enigma). Draft templates are currently available in Dart and Java. A Python version is under development.

### Installing ###

You can install targets with:

    pub global activate targets

You may be prompted by pub to add a directory to your path. Obviously, Dart should also be on your path. Previous versions of Targets required Git to download assignment templates, but, starting in 0.7.0, templates are instead downloaded from the zip archive of the project that GitHub provides.

The code is available on [GitHub](https://github.com/dart-targets/targets) under the revised BSD license.