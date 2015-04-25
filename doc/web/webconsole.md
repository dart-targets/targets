{"title":"Web Console Usage"}
## Web Console Usage

Targets was originally designed be used from the command line (Terminal on OS X or Command Prompt on Windows). However, since its primary purpose is for high school CS classes, command line usage is not always ideal. Because of this, Targets provides a web-based interface as well.

In general, you can use either the web console or the command line, but your teacher may prefer one over the other. The command line guide is available [here](usage.html).

Before you can complete this guide, you'll either need to be on a school machine (which should already have Targets installed) or you'll need to install Targets on home machine by following [this guide](installation.html). The installation guide will require you to use the command line, but all commands are given to you verbatim and you won't need to use it again for Targets after this.

#### Setting Up Your Working Directory ####

Before we begin, you need to setup your working directory to best support Targets. In many cases, it makes sense for your working directory to be on a flash drive, as doing so ensures that you don't have two different versions of your code at home and at school. A better solution would be using version control, but for a high school class, that's more trouble than it's worth.

Create a directory on your flash drive for your assignments. Call it whatever you want, just make sure that you keep all of your work for this class that you'll be submitting with Targets inside of it (you can keep other stuff in that folder too, just make sure your Targets assignments are there). Inside, you'll want to download and add at least one of the following scripts.

- [Windows](TargetsWindows.bat)
- [Mac OS X](TargetsOSX.command)
- [Linux/Unix](TargetsUnix.sh)

These scripts launch the Targets console within the directory they're placed in for each platform. Download the script for each platform you plan to use Targets with to your working directory.

Technically, double clicking these scripts is just the same as typing `targets gui` into your command line, but we're trying to avoid using the command line, so the scripts make things easier.

#### Introduction to the Web Console ####

Once you do run the script (double click on Windows or OS X), it should first open a command line window (Terminal or Command Prompt) and then it should open your web browser. Don't worry about the command line window, as you don't need to type anything into it. However, **do not** close it, as it will close Targets.

Your web browser should open [this page](http://darttargets.com/gui). While this page is remote, all of the communication is actually between this web page and Targets on your computer, which is running in the command line window. When you interact with the web page, the command line runs the corresponding command as if you had typed them in yourself.

Now we get to why it was important to save the script in the directory where you keep your projects. In the first text box on the web page, you should see the file path that you launched the script from. You can change this path if you want, but provided you launch the script correctly, you shouldn't need to.

Now that we have the web console open, you can download your first assignment.

#### Downloading Templates ####

In order to download an assignment through Targets, you need to put your teacher's GitHub username in the box labeled **Teacher ID** and the assignment's ID in the box labeled **Assignment ID**. Ask your teacher for which IDs to use for each assignment. They should also provide an ID specifically to learn to use Targets in this guide.

With the IDs your teacher provides, download an assignment. Assuming everything is set up properly, Targets should download the template, creating a subfolder within the directory you launched it.

Most assignments should have a `README.md` file, which is a plain text file describing the assignment. You can view a nicely formatted version of this file by clicking the **View on GitHub** button in the web console.

The `targets` folder contains all of the files necessary for Targets to run on that assignment, including tests and the identifiers that make sure your submission gets to your teacher. You should never have to look at anything in this folder and you should never change anything in it, as it may force you to re-download the template if you want to submit your assignment.

Anything else is the actual assignment code. Your teacher should provide instructions on what files you'll need to edit. If you want Targets to submit the right code, make sure that you do not move or rename files that will be submitted (also be wary of copying them, as you may make your changes in a different version).

#### Running Tests ####

Now that you know what's been downloaded, head back to the web console and click the **Run Tests** button. This should run the include tests for this assignment and output the results.

If any tests do not pass, your teacher may want you to modify certain files so that they do.

Most assignment templates that you download through Targets should include some basic tests. However, these are not exhaustive, and your teacher will run more extensive tests on your code after you submit it, in addition to hand grading your code for partial credit. You can actually change these tests by going into the `targets` folder, but you shouldn't, because passing or not passing the tests included have no bearing on your grade; it's your teacher's tests that matter. The included tests are merely to help guide you in completing your assignments.

#### Submitting Your Code ####

Once you've modified the necessary files to pass the tests, you can submit it by going back to the Targets console. Two things are required for your submission: your full name and your email address. Your teacher may also require that you include your student ID. They may also ask you to use a certain email. The email must be associated with a Google account, as you will use it to validate your submission.

Fill in the necessary boxes in the web console. Once you've done this, click the **Submit Assignment** button. After a moment, a new view should appear in the web console.

This view should include all of the code you're about to submit. You'll want to make sure that all of your code from all of the files you edited is included.

Once you've verified that, click the **Yes** button. A Google sign-in form should pop up. It's important that you sign in with the Google account that matches the email you used, as the submission will fail if it doesn't.

Provided everything is in order, you should see a message that says "Code submitted to `x`", where `x` is your teacher's username. This means that your teacher will be able to see and grad it. If you find a mistake and want to fix it, you can resubmit, but this will delete your previous submission, so make sure you don't resubmit after the deadline. Once you're done, hit the **Close** button in the upper right of the page to go back to the web console.

If you want to learn how to use Targets from the command line, read [this guide](usage.html).

[Home](index.html)

