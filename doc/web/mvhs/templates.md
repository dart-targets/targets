{"title":"Creating Assignment Templates"}
## Creating Assignment Templates - MVHS

> Important: If writing assignment templates on Windows, **do not** use Notepad, as it tends to cause cross-platform issues with line breaks. Either edit in an IDE like Eclipse or a text editor designed for code like [Sublime Text](http://sublimetext.com). Check Google for a plugin for Dart syntax highlighting if you want it.

One of the core features of Targets is the use of an assignment template downloaded through GitHub that includes tests and ensures all student work adheres more or less to the same structure.

While creating new templates for each assignment will take some work, they should be more-or-less reusable each year, which means that future uses are as simple as providing the assignment ID to students. Plus, you can have TAs create the templates.

#### Creating a New Assignment ####

To create a new assignment, you can use the `targets init` command. This command is almost identical to the `targets get` command that students use, except that it keeps all comments intact on the `tests.dart` file.

I recommend that you start from one of the following templates (though you can also base a new assignment off of an existing one by using its ID):

    targets init java-example

    targets init mvhs/sample

    targest init mvhs/eclipse-template

`java-example` is a sample of the core Targets project, which includes a simple example which reverses all lines of input provided to it. The code in `Example.java` is already written, and the included tests already pass.

`mvhs/sample` is a sample in the MVHS organization, which includes an example which performs arithmetic operations based on arguments passed to the class. For example, to add 5 and 6, you would run.

    java Sample add 5 6

`mvhs/eclipse-template` contains multiple source files in Eclipse project format.

#### Adding Assignment Starter Code ####

For most assignments, it's recommended that you create a skeleton of each file that you want students to complete (however, it's not required, as you obviously can't do this for more open-ended projects where students have classes with different names).

In particular, you should either write the `main` method for the assignment or include a separate test class in order for the tests to run. The `mvhs/sample` assignment provides a good example of this.

Clearly comment which methods and classes students are required to complete and which should not be changed (as they'd risk breaking the tests).

#### Writing tests.dart ####

Now you need to write `tests.dart`, which is a file contained within the `targets` folder. This folder also contains `helpers.dart` and `tester.dart`, but you should not change these, as Targets adds its own version when students download templates, overwritting any changes you make.

The only mandatory changes are to the following lines:

    final String name = "Name of Assignment Here";

    /// This shouldn't change for MV projects
    final String owner = "mvhs";

    final String id = "assignment-identifier";

    final List<String> files = ["ListOf.java", "Files.java", "ToSubmit.java"];

The comments within the file describe more about each of these. If you have an open-ended project where you want all files of a specific type to be submitted, use `"*.type"` (e.g. `"*.java"` for all Java files).

Techincally, you don't need your template to have tests for students to run if you just want to use the submission features of Targets. In that case, just have `getTargets()` return an empty list 

    List<Target> getTargets(){
        return [];
    }

However, most assignments should probably include tests. There are more customizable options for assignments written in Dart but tests of other languages are limited to using `IOTarget`.

To create a single `IOTarget` for Java code, you can pass the main class name and an `InputOutput` object into the `IOTarget.makeJava` static method.

`InputOutput` contains a name for an individual test, expected output, and either arguments or standard input to run it with. For example:

    /// Unnamed constructor has parameters name, input, and output
    InputOutput io1 = new InputOutput("Test 1", "dog", "god");

    /// For InputOutput with arguments instead of input
    InputOutput io2 = new InputOutput.withArgs("Addition Test", "add 7 3", "10.0");

    /// For InputOutput with both arguments and input
    InputOutput io3 = new InputOutput.withArgsInput("Test 3", "args", "input", "output");

Pass an `InputOutput` object into `IOTarget.makeJava`.

    IOTarget target = IOTarget.makeJava("Sample", io2);

You can create multiple IOTarget objects for the same main class with `IOTarget.makeMultiJava`

    List<IOTarget> targets = IOTarget.makeMultiJava("Sample", [io1, io2, io3]);

Have `getTargets()` return a list of Targets (probably IOTargets). Here's the `getTargets()` method for `mvhs/sample`:

    List<Target> getTargets(){
        InputOutput io1 = new InputOutput.withArgs("Addition", "add 7 3", "10.0");
        InputOutput io2 = new InputOutput.withArgs("Subtraction", "subtract 7 3", "4.0");
        InputOutput io3 = new InputOutput.withArgs("Multiplication", "multiply 7 3", "21.0");
        InputOutput io4 = new InputOutput.withArgs("Division", "divide 16 4", "4.0");
        return IOTarget.makeMultiJava("Sample", [io1, io2, io3, io4]);
    }

Once you've written tests, you can verify that they work by running `targets check` from inside the assignment directory. You should make sure that your tests fail on the main template and pass on a completed assignment before releasing it to students.

#### Creating a README.md ####

Create a file called `README.md` in the root of your assignment directory. This file is not required, but it provides an overview of the assignment on the GitHub page. If you don't want to write a full spec, add the following text (customized for your project):

    <Brief description of assignment>

    Change the assignment id to `assignment-id` in the web console to download this template.

    If you're using the command line, use the following command:

        targets get mvhs/assignment-id

This file supports Markdown formatting. You can learn how to use it [here](http://daringfireball.net/projects/markdown/). Markdown allows create document formatting all in plaintext. This entire document (and all of the others on this site) is written in Markdown.

Ideally, your `README.md` should contain the full specifications of the assignment. This will provide students a full copy of the plaintext version when they download the template as well as a nicely formatted version to read on GitHub. GitHub has it's own flavor of Markdown that allows you to do a few extra things, including syntax highlighting. You can read about it [here](https://help.github.com/articles/github-flavored-markdown/).

#### Publishing Your Assigment ####

Now we need to use Git. Before we start, remove all `.class` files that you don't want included in the template.

First, from inside the assignment directory, initialize a new Git repository:

    git init

At any time, you can use `git status` to see what files it's tracking and what changes have been committed.

You can then add individual files and folders to the repository:

    git add Sample.java
    git add targets

If you want to add everything in the folder:

    git add .

Make sure to only add everything if you want every file in the folder (including hidden files) to be included with the template.

Now, we commit our changes locally

    git commit -m "some message about what changes you're making"

However, this only saves our changes on our local machine. We want to publish it to GitHub. To do so, we need to create a new repository for this assignment.

Open the [MVHS organization page](https://github.com/mvhs) in your browser and click the **New repository** button.

In the the **Repository name** field, enter the id from your `tests.dart`, prefixed with `targets-`. This would mean that an ID like `assignment1` would become `targets-assignment1`. This repository **must** be public (adding private repositories would cost $25/month anyway). Then click **Create repository**.

You should be taken to a new page. Look at the instructions under **…or push an existing repository from the command line**. The first line should contain something like this:

    git remote add origin https://github.com/mvhs/targets-yourid.git

Copy this line into your terminal and run it. Your local repository is now linked to the public GitHub repository. However, your code isn't actually there yet. Now, we need to push your local changes to GitHub with:

    git push origin master

And that's it! You've now published your assignment. If you want to make updates in the future, run the following commands in order:

    git add .
    git commit -m "some message about what changes you're making"
    git push origin master

However, I do not recommend updating projects while students are actively working on them, as they won't be able to download the changes without starting over. However, you can make changes to a single assignment but keep the same assignment ID each year.

Students can follow [this guide](webconsole.html) in order to download your template through the web console. You'll need to give them the assignment's assignment ID. The console provides a link to its GitHub page.

Continue to [Grading Student Submissions](grading.html)

[Home](index.html)


