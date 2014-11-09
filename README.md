## targets ##

Targets is an assignment manager and autograder for Dart programs intended for those who wish to use Dart to teach programming/CS. It uses GitHub to download assignment templates.

`targets get example` downloads an example assignment from `https://github.com/dart-targets/targets-example`.

You can download assignments you create with `targets get username/assignment` which would download from `https://github.com/username/targets-assignment`.

If you want to use an assignment someone else has created (but have submissions sent to you), add your username and a colon. `targets get userA:userB/assignment` downloads from `https://github.com/userB/targets-assignment` but alters the `tests.dart` file so that submissions are sent to `userA`.

### Creating Templates ###

To create a new assignment template, you can download a fully commented version of an existing template with `targets init`. This command will download the `example` template I've created. You can add an assignment argument to download some other assignment.

`targets init` works almost exactly the same as `targets get`, except that it leaves comments in the `tests.dart` file untouched. `//`, `/*`, and `/**` style comments are kept with either command, but unindented `///` comments are removed when using `targets get`. The `example` template includes many of these comments to explain the structure of `tests.dart`.

Once you've completed your assignment template, push it to a new GitHub repository. The repo name should start with `targets-`. Students can then download your new assignment with `targets get user/id` when `user` is your GitHub username and `id` is everything after the `targets-` in your repo name.

### Submission and Grading ###

Students can run the tests on their assignment with `targets check` and submit with `targets submit` (after first running `targets setup`). Student submissions are validated with a Google account (the primary email of the account must match the one their enter in `targets setup`). 

Submission is active, but the submission viewer isn't fully set up yet. I intend to offer submission free of charge for the time being, with submissions deleted after 30 days. I may have to change this policy in the future depending on demand.

Submissions are made to the GitHub user or organization name set in the `owner` variable of `tests.dart`. Once submissions have been uploaded, you can view and download them [here](http://darttargets.com/results) by logging into your GitHub account.

Once you download a zip of submissions, you can run tests on all them with `targets batch`. Just put a `tests.dart` file (ideally, this should include different tests from what you provide in the template to ensure students don't just write code to pass the tests) in a folder called `targets` within the extracted zip file. `targets batch` will output a log of tests on all submissions to `log.txt`.

If you have template files that are required for your tests to run but aren't included in student submissions, you can put them in a folder called `template` within the extracted zip. You could actually download a full project template (with `targets get`) and then rename the folder to `template`, as, when a file exists both in a student submission and in `template`, the student submission is used.

Additionally, if you open the submission viewer in Dartium, you can paste in code from a `tests.dart` file to run tests without downloading submissions. Please note that this feature works best with very simple assignments. When all code is in one file, it should work fine. It should theoretically work with multiple files, as long as they are all uploaded with students' submissions, but things may break. If the web grader does not work, just download the zip and use `targets batch`.

For the time being, the submission service is free of charge. The server is running on "unlimited" shared hosting, so I shouldn't have any issues keeping it free, unless demand is such that I go beyond whatever my host deems "unlimited" to be. To keep the server lightweight, all submissions will be deleted after 30 days. Make sure to download the zip archive within that window or your students will have to resubmit.

### Languages Other Than Dart ###

Targets is primarily designed to test code written in Dart. However, version 0.2.3 added support for `IOTarget`, which lets you test output for given input sent to a program. To see an example of how `IOTarget` works, `targets init java-example`. I've tested simple examples on both OSX and Windows, but testing more complex programs may result in some issues, particularly cross-platform. If you use `IOTarget`, make sure to use `targets check` on a completed version of your template on each OS that your students may use.

For obvious reasons, `IOTarget` is not supported by the web grader, though `targets batch` should work fine.

### Installing ###

You can install targets with:

    pub global activate targets

You may be prompted by pub to add a directory to your path. Targets also requires both Dart and Git to be installed to your path.

The code is available on [GitHub](https://github.com/dart-targets/targets) under the revised BSD license.