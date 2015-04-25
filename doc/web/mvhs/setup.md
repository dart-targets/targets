{"title":"Targets Installation on MVHS Machines"}
## Targets Installation on MVHS Machines
*This specification is a draft. I will need to try the setup myself and adapt this document as necessary.*

This document describes the installation steps necessary to best setup Targets on the MVHS instructional machines. The current version requires administrative access for initial setup of Dart and Git. Administrative access would also be needed to update Dart or Git, but the current versions of both of these are stable enough to not require updates unless a class wished to directly use the Dart programming language or teach command line use of Git (the latter of which would probably be best taught on Unix machines anyway).

Once Dart and Git are installed, Targets can be updated quickly and easily from student accounts (there's even a command in the web console to do so). If my knowledge of the student account structure is correct, I believe that each student account would maintain its own version of Targets. However, it's also possible the the version of Targets is tied to the machine or some combination of the two. Either way, this should not be a significant issue, as the Targets executable is only ~32 KB.

The only possible issue preventing updating from student accounts that I can think of would be if the version of Targets is machine-tied and located in a folder that is write-protected from students. I don't think this will happen, but if it does, it can be remedied in the same way that Android Studio updates were.

While Dart is required for all installations of Targets (as Targets runs Dart code in the Dart VM), Git is not required for student operation of Targets as of version 0.7.0. However, Mrs. Anwar and her TAs will need Git in order to create and publish templates that students can then download. Because of this, I recommend that Git is installed on at least Mrs. Anwar's computer and the TA computer, though installing it everywhere might just be easier.

The way I see it, there are three ways we can install Targets on the instructional machines:

1. Follow this guide on one computer, and then clone the drive to the other machines (recommended)
2. Follow this guide on each computer
3. Use the more portable version I mentioned in the original document. I don't recommend this as it involves a lot of moving parts that could break, and some admin access would probably still be required to put java and javac on the system path.

### Installing Dart and Git Through Chocolatey ###

I recommend using Chocolatey for installation of Dart and Git, as it handles setting up the path and all dependencies with just one command in the shell. Chocolatey is a command line package manager for Windows, like APT for Debian or Homebrew for OS X. It allows us to install Dart and Git with a total of three commands in an administrative command prompt. Chocolatey would remain on the machines in case an administrator wanted to install something else, but it would not allow new installations or upgrades by a student account.

Installation is simple. First, install Chocolatey:

    @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

Then, you can easily install Git

    choco install git.commandline

and Dart

    choco install dart-sdk

This is also the method I recommend in my student guide for installing Targets on their home computers.

### Installing Targets through Pub ###

Pub is the Dart package manager that is included when we install the Dart SDK. I host and provide updates to Targets by uploading it to Pub. We can install or upgrade Targets with the following command:

    pub global activate targets

The Targets web console uses this command when the user clicks the Update button.

### Configuring the Path ###

In order for the Targets command to be recognized, we need to add it to the system path. This will vary depending on where Pub installs Targets (it's usually in the user's AppData, but I'm not sure how it works with networked accounts).

Once the path is configured, Targets should work on the school machines. However, in order to run tests of Java code through Targets, both java and javac need to be on the path as well. If I recall correctly from last school year, java was on the path, but javac was not. We can configure this when we configure the path for Targets.

### Student Use of Targets ###

Targets was originally written as a command line tool, but since it's primarily intended for high school CS classes (universities generally have their own systems which work better for 1000+ student classes like Berkeley's 61A and 61B), I added a graphical interface for students in Targets 0.5.0.

The GUI works by running a local web socket server from Targets. It then opens a web page in the user's default browser which connects to said server. When students select options in the GUI, Targets runs the corresponding commands and reports the results back to the user.

While Targets technically runs a web server on the student's machine, it's configured in such a way that all communication is local and no strain whatsoever is put on the school's network. Likewise, while the web page that loads the console is remote, the data it loads remotely is just a static web page. All dynamic interaction is with the local Targets server.

By default, the `targets gui` command runs the server on port 7620 and opens [this page](http://darttargets.com/gui) for the gui. I've created a separate page that is tailored for Monte Vista (in color scheme and functionality) that can be opened with:

    targets gui 7620 http://mvhs.darttargets.com

or, if you wish to change the port the server is run on:

    targets gui #### http://mvhs.darttargets.com/?port=####

The targets process is identical no matter what `targets gui` command is used. Only the student-facing interface is different.

[Home](index.html)