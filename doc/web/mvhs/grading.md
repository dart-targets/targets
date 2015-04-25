{"title":"Grading Student Submissions"}
## Grading Student Submissions - MVHS

Completed student assignments are submitted to the "mvhs" GitHub organization. If you haved created a GitHub account and joined that organization, see the [Getting Started](gettingstarted.html) guide.

#### Using the Submission Viewer ####

Submissions can be viewed or downloaded from the [Targets Submission Viewer](http://darttargets.com/results).

Click the **Login** button and you will be redirected to GitHub to login. If this is your first time logging in, you will need to authorize the submission viewer with GitHub.

Once you finish logging in, you'll be redirected back to the submission viewer.

Select "mvhs" from the owner dropdown. If you don't see it as an option, it means you haven't been added to the "mvhs" GitHub organization yet.

In the **Assignment ID** box, enter the identifier for the assignment you want to grade. This should match the identifier that you provided to students. For the sample assignment used in the student guide, you would use the identifier `sample`.

If you are grading code written in Dart, there is a way that you can run tests directly in the browser, but since you should only need to grade Java assignments at MVHS, I'll leave instructions for that in the [generic version](../grading.md) of this guide.

Click the **View Submissions** button and, after a few moments, a list of student submissions should appear in the sidebar. Click on one to view all of the code associated with it. This only includes files that were submitted; it does not include template files.

The **Download** button will create a zip archive of all submissions in a format that Targets can easily run tests on.

If you want to view submissions for a different assignment, click the **Back** button in the upper right, and enter a new assignment ID.

#### Deleting Submissions ####

Student submissions will automatically be deleted after **90 days**. This is specific setting for the "mvhs" organization. Other users of Targets have submissions deleted after 30 days. This condition allows me to keep the Targets submission server free by reducing the load on the server. Because of this, make sure to tell students not to submit until a date close enough to the deadline that you can grade them before submissions are deleted.

In the future, I may offer a paid service that offers persistant storage of submissions and server-side autograding (on top of many other features), but I'm not actively developing this yet.

There is (or will be soon) an option for organization owners to manually delete submissions (individually or in bulk). This means that Mrs. Anwar will be able to delete submissions, but TAs will only be able to view them.

#### The `targets batch` Command ####

The `targets batch` command allows you to run tests on multiple student submissions at once. First, download the zip archive from the submission viewer and unzip it.

Create a subdirectory called `template` inside the main directory. Inside this subdirectory, you should include an assignment template that's almost identical to the one provided to students (you can even use `targets init` and then rename the directory it creates to `template`). The difference is that your `tests.dart` file should contain new, more extensive tests.

Once your `template` folder is set up with new tests and all of the files necessary to run them, navigate in your terminal to the main unzipped directory. Run the `targets batch` command.

Targets will run the tests in `template` with each students' submission as if they had run `targets check` themselves. It will then generate a report called `log.txt` with the output for each student's submission.

#### Using Targets in Combination with Other Grading Techniques ####

Target is not designed to be a complete grading solution. While `targets check` allows students to track their progress and `targets batch` can run preliminary tests to speed up grading, additional grading techniques are a must.

Additionally, while tests of Dart code can be more advanced (and include scoring), the `IOTarget` methods used to test other languages only support Pass/Fail tests. This is intentional, as the simple input/output tests `IOTarget` supports should only provide a baseline, both for students in their testing and teachers in their grading.

Here is my recommended use of Targets for Java classes:

1. Teachers/TAs provide templates for assignments, which keeps everyone's code to the same baseline and enables automated testing
2. Students use the basic tests included in the template as a preliminary indicator of their code's validity, but still run their own tests (either manually or with something like JUnit)
3. Students submit their code through Targets, ensuring a uniform submission format
4. Teachers download the zip file of submissions and run more extensive tests with `targets batch`
5. If all tests pass, students can receive full credit after a quick read of their code through the submission viewer by a teacher or TA (to check for plagarism, code quality, etc)
6. If some or all tests fail, teachers and TAs should review their code thoroughly to determine what partial credit to give
7. If necessary, run additional tests of code manually

[Home](index.html)

