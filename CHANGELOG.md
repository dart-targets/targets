#### 0.7.1
  * New `targets template` command that works like `targets init`, but downloads to a folder called `template` (for later use with `targets batch`)
  * New `targets distribute` command which takes a folder set up for `targets batch` and creates a folder for each submission that contains the student code on top of the template (if you want to manually run anything on student code that requires template files)
  * Update from web console no longer requires Targets to be on the path (only pub needs to be)

#### 0.7.0
  * Rewrites `targets get` to eliminate the need for Git to be installed on student machines.
  * Adds support for zip file templates with `targets get` if you don't want to host your assignments on GitHub.
  * `tester.dart` and `helpers.dart` are now re-added before every `targets check` or `targets submit` command to ensure students do not modify them
  * The `IOTarget` Java helper methods should now properly compile classes in packages.
  * Errors during `IOTarget` pre-test commands (usually compilation) now halt the testing process, even if there are other tests left to run. Previously (in 0.6.0), errors in compilation only failed the one test.

#### 0.6.0
  * New `targets moss` command
  * Allows teachers to send student code that's prepared for `targets batch` to [Moss][http://moss.stanford.edu] for similarity detection
  * IOTargets now fail when any pre commands fail. This will ensure that students are notified about compile-errors in their code

#### 0.5.2
  * Improved IOTarget.makeJava
  * **Breaks existing use of IOTarget.makeJava**
  * Adds additional helpers in IOTarget

#### 0.5.1
  * Fixes bugs with updating through the student GUI

#### 0.5.0
  * Adds student GUI to targets, launched with `targets gui`
  * This runs a local web socket server and opens [darttargets.com/gui](http://darttargets.com/gui) in your browser
  * The web interface connects to the local web socket server to allow easy access to student commands without using the terminal (you could write a simple script to run `targets gui`)
  * Minor improvements to downloading templates with git

#### 0.4.1
  * Fixes bug with browser opening on submit on Windows introduced in 0.4.0

#### 0.4.0
  * Fixed issue with submitting large amounts of data with `targets submit`
  * Added option to submit all files of a certain type (include "*.extension" as on the strings in the `files` list in your `tests.dart` file)

#### 0.3.0
  * Added `targets batch` command, which allows for testing multiple submisssions at once.
  * Improved documentation
  * Submissions can now be viewed [here](http://darttargets.com/results)

#### 0.2.3
  * Added `IOTarget`, which allows testing of other languages. For an example in Java, download the `java-example` assignment with `targets get` or `targets init`

#### 0.2.2
  * Fixed issues; should work on OSX, Windows, and Linux now

#### 0.2.1
  * First release
