{"title":"MVHS Student Usage Guide"}
## MVHS Student Usage Guide

Targets was originally designed to be used from the command line (Terminal on OS X or Command Prompt on Windows). However, since its primary purpose is for high school CS classes, command line usage is not always ideal. Because of this, Targets provides a web-based interface as well.

For Monte Vista specifically, we require that you use this web console when interacting with Targets on the school computers. If you want, you can use the Targets from the console on your home computer, but we will require that you use the web console on the MVHS machines, as the school doesn't want students to have access to Command Prompt on them. The command line guide is available [here](../usage.html), but is not tailored for Monte Vista.

Before you can complete this guide, you'll either need to be on a school machine (which already has Targets installed) or you'll need to install Targets on home machine by following [this guide](installation.html). The installation guide will require you to use the command line, but all commands are given to you verbatim and you won't need to use it again for Targets after this.

#### Setting Up Your Flash Drive ####

Before we begin, you need to set up your flash drive to best support Targets. Targets doesn't require that you use a flash drive to store your code, but doing so ensures that you don't have two different versions of your code at home and at school. A better solution would be using version control, but for a high school class, that's more trouble than it's worth.

> Important: Your Targets directory should not be the same as your Eclipse workspace. After you download an assignment, you can import it into Eclipse with General &gt; Existing Projects into Workspace, but make sure that "Copy projects into workspace" is unchecked, or you may end up testing and submitting the wrong version of your code.

Create a directory on your flash drive for your AP Java assignments. Call it whatever you want, just make sure that you keep all of your Java work that you'll be submitting with Targets inside of it (you can keep other stuff in that folder too, just make sure your Targets assignments are there). Inside, you'll want to download (right click and Save Link As) and add at least one of the following scripts.

- [Windows](MVHSTargetsWindows.bat)
- [Mac OS X](MVHSTargetsOSX)
- [Linux/Unix](MVHSTargetsUnix.sh)

These scripts launch the Targets console within the directory they're placed in for each platform. At the very least, you'll need the Windows script to launch the web console on the school computers. If you use Windows at home, the same script will work. If not, you'll need to use the script for OS X or Linux.

Technically, double clicking these scripts is just the same as typing `targets gui 7620 http://mvhs.darttargets.com` into your command line, but we're trying to avoid using the command line, so the scripts make things easier.

#### Introduction to the Web Console ####

Once you do run the script (double click on Windows or OS X), it should first open a command line window (Terminal or Command Prompt) and then it should open your web browser. Don't worry about the command line window, as you don't need to type anything into it. However, **do not** close it, as it will close Targets.

Your web browser should open [this page](http://mvhs.darttargets.com). While this page is remote, all of the communication is actually between this web page and Targets on your computer, which is running in the command line window. When you interact with the web page, the command line runs the corresponding command as if you had typed them in yourself.

Now we get to why it was important to save the script in the directory where you keep your projects. In the first text box on the web page, you should see the file path that you launched the script from. You can change this path if you want, but provided you launch the script correctly, you shouldn't need to.

Now that we have the web console open, you can download your first assignment.

#### Downloading Templates ####

In order to download an assignment through Targets, you need to put the assignment's ID in the box labeled **Assignment ID**. As a sample, we'll use the id `eclipse-sample`. Enter it in the box and click the button labeled **Download**.

Assuming everything is set up properly, Targets should download the template, creating a folder called "eclipse-sample" within your assignments directory. This folder should contain three files (`Student.java`, `TestStudent.java` and `README.md`) and one subdirectory (`targets`). This particular assignment can be imported into Eclipse. If you do import it, make sure that you don't create a copy of the project, as this will prevent Targets from seeing the changes you make.

The `README.md` file is a plain text file describing the assignment that should be included in most assignments. You can view a nicely formatted version of this file by clicking the **View on GitHub** button in the web console.

The `targets` folder contains all of the files necessary for Targets to run on that assignment, including tests and the identifiers that make sure your submission gets to Mrs. Anwar. You shouldn't have to look at anything in this folder and you should never change anything in it, as it may corrupt some necessary files, forcing you to re-download the template in order to submit your assignment.

`TestStudent.java` is run by Targets when it runs tests. You shouldn't modify this file, but you can read it to help gain an understanding of how your code is supposed to work. 

The `Student.java` file is what we actually care about. This is the file that will be submitted to Mrs. Anwar. In your actual assignments, you will often edit more than one file, but for this example, we just use one. If you want Targets to submit the right code, make sure that you do not move or rename this file (also be wary of copying it, as you may make your changes in a different version).

#### Running Tests ####

Now that you know what's been downloaded, head back to the web console and click the **Run Tests** button. This should run the included tests for this assignment and output the results.

You should notice that none of the four tests for this assignment pass. Fill in the necessary constructors and methods in `Student.java` and try the tests again. If any of them still fail, check your code for bugs and try again.

Most assignment templates that you download through Targets should include some basic tests. However, these are not exhaustive, and Mrs. Anwar and her TAs will run more extensive tests on your code after you submit it, in addition to hand grading your code for partial credit. You can actually change these tests by going into the `targets` folder, but you shouldn't, because passing or not passing the tests included have no bearing on your grade; it's Mrs. Anwar's tests that matter. The included tests are merely to help guide you in completing your assignments.

#### Submitting Your Code ####

Once you've modified `Student.java` to pass the tests, you can submit it by going back to the Targets console. Three things are required for your submission: your full name, your school email address (@students.srvusd.net) and your SRVUSD student ID. However, only your email address is verified during submission, so check your name and student ID for typos (though, if you make a mistake, Mrs. Anwar should still be able to be able to identify your work by your email address).

Fill in the three boxes in the web console (for your email address, you only need the part before the @, as everything after that is added automatically). Once you've done this, click the **Submit Assignment** button. After a moment, a new view should appear in the web console.

This view should include all of the code you're about to submit. In this case, it should just be the contents of `Student.java`, but in future assignments, you'll want to make sure that all of your code from all of the files you edited is included.

>Login Note: If you've only signed into your personal Google account on the computer that you're using, you may not be given the option of logging in with your school account. To fix this, go to google.com and click on your profile picture in the upper right. In the panel that appears, select "Add Account" and login with your school email. From now on, you should be given a choice of accounts whenever you submit.

Once you've verified that, click the **Yes** button. A Google sign-in form should pop up. It's important that you sign in with your **school Google account**, as the submission will fail if it doesn't match your school email. You may not be prompted to sign-in if you already have recently. If it defaults to your personal Google account, go to Google Drive or another Google site and sign in with your school account first, then submit.

Provided everything is in order, you should see a message that says "Code submitted to mvhs". This means that Mrs. Anwar and her TAs will be able to see it and grade it. If you find a mistake and want to fix it, you can resubmit, but this will delete your previous submission, so make sure you don't resubmit after the deadline. Once you're done, hit the **Close** button in the upper right of the page to go back to the web console.

#### Fallbacks and Reporting Issues ####

Targets is still in beta, but I'm working to make it as best as possible. For now, Mrs. Anwar may want you to continue to submit the old way (through SchoolLoop) in case anything goes catastrophically wrong with Targets. If you encounter any issues, let Mrs. Anwar know (particularly if it has something to do with submissions, to make sure she gets your code), and send me an email. I've set up a [dedicated address](mailto:mvhstargets@jackthakar.com) for MVHS students to report issues, comments, or suggestions about Targets.

[Home](index.html)

