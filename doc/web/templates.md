{"title":"Creating Assignment Templates"}
## Creating Assignment Templates

> Important: If writing assignment templates on Windows, **do not** use Notepad, as it tends to cause cross-platform issues with line breaks. Either edit in an IDE like Eclipse or a text editor designed for code like [Sublime Text](http://sublimetext.com). Check Google for a plugin for Dart syntax highlighting if you want it.

One of the core features of Targets is the use of an assignment template downloaded through GitHub that includes tests and ensures all student work adheres more or less to the same structure.

While creating new templates for each assignment will take some work, they should be more-or-less reusable each year, which means that future uses are as simple as providing the assignment ID to students. Plus, you can have TAs create the templates.

#### Creating a New Assignment ####

> Note: This page details how to create assignments written in Dart. However, though `IOTarget`, Targets can test other languages, including Java. For a Java guide, read the version of this document that I created for Monte Vista High School [here](mvhs/templates.html).

To create a new assignment, you can use the `targets init` command. This command is almost identical to the `targets get` command that students use, except that it keeps all comments intact on the `tests.dart` file.

For this document, we'll start from the `example` template. Run the following command:

    targets init example

#### Adding Assignment Starter Code ####

For most assignments, it's recommended that you create a skeleton of each file that you want students to complete (however, it's not required, as you obviously can't do this for more open-ended projects where students have classes with different names).

Clearly comment which methods and classes students are required to complete and which should not be changed (as they'd risk breaking the tests).

#### Writing tests.dart ####

Now you need to write `tests.dart`, which is a file contained within the `targets` folder. This folder also contains `helpers.dart` and `tester.dart`, but you should not change these, as Targets adds its own version when students download templates, overwritting any changes you make.

The only mandatory changes are to the following lines:

    final String name = "Name of Assignment Here";

    final String owner = "your-github-username";

    final String id = "assignment-identifier";

    final List<String> files = ["ListOf.dart", "Files.dart", "ToSubmit.dart"];

The comments within the file describe more about each of these. If you have an open-ended project where you want all files of a specific type to be submitted, use `"*.type"` (e.g. `"*.dart"` for all Dart files not in the `targets` folder).

Techincally, you don't need your template to have tests for students to run if you just want to use the submission features of Targets. In that case, just have `getTargets()` return an empty list 

    List<Target> getTargets(){
        return [];
    }

However, most assignments should probably include tests. This document describes how to test Dart code. See the MVHS document linked about for use of `IOTarget` to test other languages.

First, import any student code that you wish to test based on the relative path:

    import '../example.dart' as Example;

Within the `getTargets()` method, you should create all the tests you wish to include with the template. For Dart code, these can be of two types: `ScoredTarget` and `TestTarget`. To construct these:

    TestTarget target1 = new TestTarget("Unscored Test");

    // This is worth 5 points
    ScoredTarget target2 = new ScoredTarget("Scored Test", 5);

You should then set a the `test` property of either type of Target to a function that runs a test. For TestTargets, the function should return `true` if the test passes or `false` if it fails. For ScoredTargets, the function should return the number of points earned. Alternatively, it can return `true`, which is the equivalent of returing the max number of points, or `false`, which is the equivalent of returning 0 points.

    //Test passes if student's fib(5) is equal to 5
    target1.test = () => Example.fib(5) == 5;

    //Test scores full points if student's fact(5) is equal to 120
    target2.test = () => Example.fact(5) == 120;

Have `getTargets()` return a list of Targets. Here's a sample `getTargets()` method:

    List<Target> getTargets(){
        Target fibTest = new ScoredTarget("Fibonacci",3);
        fibTest.test = () => Example.fib(5) == 5;

        Target factTest = new ScoredTarget("Factorial",2);
        factTest.test = () => Example.fact(5) == 120;

        return [fibTest, factTest];
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

    git add example.dart
    git add targets

If you want to add everything in the folder:

    git add .

Make sure to only add everything if you want every file in the folder (including hidden files) to be included with the template.

Now, we commit our changes locally

    git commit -m "some message about what changes you're making"

However, this only saves our changes on our local machine. We want to publish it to GitHub. To do so, we need to create a new repository for this assignment.

Open GitHub in your browser and create a new repository.

In the the **Repository name** field, enter the id from your `tests.dart`, prefixed with `targets-`. This would mean that an ID like `assignment1` would become `targets-assignment1`. This repository **must** be public (adding private repositories would cost money anyway). Then click **Create repository**.

You should be taken to a new page. Look at the instructions under **…or push an existing repository from the command line**. The first line should contain something like this:

    git remote add origin https://github.com/yourusername/targets-yourid.git

Copy this line into your terminal and run it. Your local repository is now linked to the public GitHub repository. However, your code isn't actually there yet. Now, we need to push your local changes to GitHub with:

    git push origin master

And that's it! You've now published your assignment. If you want to make updates in the future, run the following commands in order:

    git add .
    git commit -m "some message about what changes you're making"
    git push origin master

However, I do not recommend updating projects while students are actively working on them, as they won't be able to download the changes without starting over. However, you can make changes to a single assignment but keep the same assignment ID each year.

Students can follow [this guide](webconsole.html) in order to download your template through the web console or [this guide](usage.html) to download it from the command line. You'll need to give them the assignment's assignment ID and your GitHub username or organization name. The console provides a link to its GitHub page.

Continue to [Grading Student Submissions](grading.html)

[Home](index.html)


