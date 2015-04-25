{"title":"Targets Installation Guide"}
## Targets Installation Guide - MVHS

Targets should already be installed on the MVHS instructional machines. This guide will show you how to install it on your home computer.

Targets should work on any modern version of Windows, Mac OS X, or Linux. This **does not** include Windows XP. If you are still running Windows XP, your computer is a serious security ris
k and should be updated immediately. Vista isn't much better, but it should support all the tools Targets needs to run. If you don't want Windows 8, then install Windows 7. For OS X, this 
should include all versions 10.6 or higher.

You will need administrative access to your computer in order to install these tools. If your computer is yours and yours alone, you almost certainly have this already. If you share your c
omputer with your family, talk to your parents to see if you have administrative access. If not, they may need to install Targets for you.

### Installing Dart ###

> Note: An older version of this document also instructed you to install Git. If you still want to install Git, you can read the [teacher's installation guide](installation-teachers.html), though it is no longer required starting with Targets 0.7.0.

Before we can install Targets, we need to install the Dart VM. Dart is a programming language like Java and the Dart VM is a tool that lets you run Dart code in the same way that the JVM lets you run Java code. You will not have to learn Dart in order to use Targets, but Targets is written in Dart, so it requires the VM in order to run. Follow the guide for your OS to install it.

> Note: Dart is still being actively developed, so your version numbers may differ from the ones listed here. Targets should work on Dart 1.7 or higher, so as long as you have that, you're good.

#### Mac OS X ####

To install the Dart VM, we'll use a tool called Homebrew. Open the Terminal app and paste the following (then hit enter):

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Once this command finishes executing, we can now install Dart with the following command:

    brew tap dart-lang/dart && brew install dart

That's it. Type `dart --version` and make sure something resembling the following appears when you hit enter:

    Dart VM version: 1.8.5 (Tue Jan 13 13:05:45 2015) on "macos_x64"

#### Windows ####

Windows makes everything messy when trying to write cross-platform apps, so it's amazing that these steps aren't more complicated than they are. To start, open an administrative command prompt by searching for Command Prompt, right clicking, and selecting "Run as Administrator." Paste the following command and hit enter:

    @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

This installs a program called Chocolatey that lets us install Dart with just one command:

    choco install dart-sdk

Close the administrative command prompt and open a regular command prompt. You should now get something resembling the following when running `dart --version`.

    Dart VM version: 1.7.2 (Tue Oct 14 07:41:22 2014) on "windows_x64"

#### Linux ####

The wide variety of Linux distros makes it impossible for me to write a guide that works for all of them, but since you're running Linux, I'll assume you're technically saavy enough to figure it out on your own. Before moving on to the next section, install [Dart](https://dartlang.org) and make sure both the Dart VM and its package manager Pub are on your path.

### Installing Targets ###

Now that Dart is installed, we can install Targets. Open up a command line (Terminal on OS X or Command Prompt on Windows) and run the following command:

    pub global activate targets

Pub is Dart's package manager. We just told it to install the Targets package so we can run it. We're almost there, but now we need to add Pub's executables folder to your system path so that your computer knows what to do when we type "targets" at the command line. This process varies depending on your operating system.

#### Mac OS X ####

Run the following command in your Terminal:

    touch ~/.bash_profile && open ~/.bash_profile

This creates a file called ".bash_profile" in your home directory (if it doesn't already exist) and opens it (probably in TextEdit). If you haven't configured your path before, this file may be empty. If so, add this line to it. If not, add it on a new line below anything that's already there.

    export PATH="$PATH":"~/.pub-cache/bin"

Save this file and close TextEdit. You will now need to close and reopen your Terminal before Targets will work.

#### Windows ####

Open Control Panel &gt; System &gt; Advanced System Settings. This may vary depending on your OS version, so if this doesn't work, look up "change windows path" on Google. You should get to a page that contains a button labeled "Environment Variables...". Click it.

Under "User variables for x" (where x is your username), select "Path" and then press the "Edit" button.

In the variable value field, make sure there is semicolon at the end of the current string and then the directory that Pub printed when you installed Targets. It probably looked something like this (but may vary depending on your version of Windows):

    C:\Users\YOUR_USERNAME_HERE\AppData\Roaming\Pub\Cache\bin

Select OK on all dialogs. You will need to close and reopen your Command Prompt before Targets will work.

#### Linux ####

The process is probably similar to the OS X instructions above (as both are Unix-based), but again, you're running Linux so you can figure this out yourself.

### Conclusion ###

Targets should now be properly installed on your machine. To test this, run the `targets` command in your shell. The output should look something like this:

    targets 0.7.0
    darttargets.com
    Run 'targets help' for list of commands
    
> Note: By the time you read this, Targets may have updated past version 0.7.0. If your version number is 0.7.0 or higher, you're good. However, if your version number is less than 0.7.0, something went wrong during installation. This is a problem because previous versions of Targets required another program to be installed in order to use it. If your version number is less than 0.7.0 after following these steps, [send me an email](mailto:mvhstargets@jackthakar.com).

If you wish, you may use the command line version of Targets on your home computer. You may also use the graphical interface described in the main Targets guide. However, you are required to use the graphical interface on the school computers, as we do not want students to use Command Prompt on the instructional machines.

Continue to the [Web Console Guide](webconsole.html)

[Home](index.html)
