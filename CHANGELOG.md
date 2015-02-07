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
