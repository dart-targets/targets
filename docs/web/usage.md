{"title":"Command Line Usage"}
## Command Line Usage

Targets can be used by students either from the command line or from a web-based interface. Unless your teacher specifies that they prefer you use one or the other, either one should work.

This guide does not teach you how to actually use the command line. If you already have experience with the command line for your system, feel free to read ahead. Otherwise, you're probably better off reading the guide for the [web console](webconsole.html).

Before you can complete this guide, you'll either need to be on a school machine (which should already have Targets installed) or you'll need to install Targets on home machine by following [this guide](installation.html). 

#### Downloading Assignments ####

To get started, open your terminal and navigate to a folder where you wish to store your Targets assignments. The first command you'll learn is `targets get`. This downloads an assignment template from GitHub based on an identifier that your teacher provides.

    targets get <identifier>

The identifier will probably be in the form `<username>/<id>`, based on your teacher's GitHub username and the specific assignment ID. Ask your teacher for an example assignment that you can download and learn Targets with.

After running a `targets get` command, Targets will download the assignment template to a new subdirectory of your current directory. Enter that subdirectory to run commands on that assignment.

#### Testing Your Code ####

    targets check

This command runs the included tests on your code and displays the output to you. If you're class is being taught in Dart, it's possible that these tests will provide a score. Unless your teacher says otherwise, you should not rely on the score calculated from these tests as your actual score on the assignment.

For all other languages, the only tests you'll get will be pass or fail. These tests help provide a general indication of whether your code is working, but you should not assume that you'll get full credit on an assignment just because the included tests pass. You should also test your code manually to make sure it works.

#### Submitting Your Code ####

Once you're done with your assignment and ready to turn it in, you can submit your code with Targets. First, you'll need to run `targets setup`, which will ask for your full name, email, and (optionally) your student ID. Your teacher will have specific instructions on what email your should use and whether or not you should include your student ID.

You should only need to run `targets setup` once on each computer you use Targets. Now, you can actually submit your code.

First, run `targets submit`. If everything works properly, your default web browser should open. If if doesn't, run `targets manual-submit` and copy the outputted URL in your browser.

On the page that loads, you should see all of the code that you're submitting for the assignment. If you see something missing, you probably put code in a file that your teacher has not set to be submitted. Ask them what you should do.

If everything is in order, click the **Yes** button. You'll then be prompted to log in with Google. It's important that the account you log in with matches the email you entered in `targets setup`. Authorize Targets to access your Google account, and your code should be submitted. Confirm the submission with your teacher.

If you'd prefer to use the web console, see [this guide](webconsole.html).

[Home](index.html)

