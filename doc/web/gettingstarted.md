{"title":"Getting Started"}

## Getting Started

This guide covers the basics of getting started with Targets for teachers.

#### Necessary Personal Software ####

The same Targets executable runs on every machine, regardless of platform or whether the user is a teacher or a student. This means that the basic software setup for home computers uses the same [installation guide](installation.md) as the students. Teachers and TAs should follow this guide for their personal computers.

The main difference is that teachers and TAs will actually need to use both Dart and Git directly to some extent.

Let's start with Git.

#### Setting Up a GitHub Account ####

[GitHub](https://github.com) is a hosted Git service that Targets uses to host assignment templates. Open source hosting is completely free (even if you don't actually license your code under an open source license). If you want private repositories, you can pay for it, sign up for GitHub Education (which I believe provides 5 free private ones), or try BitBucket, which is another hosted Git service that offers free private repositories to everyone.

However, Targets depends on all assignment repositories being public so that students can download them. In order to use GitHub, you'll need to make an account. If you don't have one already, make one now.

If you want multiple people to be able to access student submissions, you may want to create a GitHub organization and have all teachers and TAs join it.

#### Basic Git Usage ####

The [Creating Assignment Templates](templates.html) guide describes the specific Git commands you need to publish assignments, but I recommend that you read up elsewhere about how Git actually works.

For a good, fairly complete overview of Git, check out CS 61B's [Git Guide][1]. Some parts require a GitHub account registered with the class, but most should work for anyone.

#### Using Dart ####

Pretty much all of Targets is written in Dart. I chose Dart for a couple of reasons, namely that I like it and that it can run both on the command line and in a web browser really well. It can also run server-side, but I opted for PHP scripts since they can run on my shared hosting that I don't have to pay anything more for.

You don't need to learn much Dart to write Targets assignments (unless they're written in Dart). If you know Java or another language with a C-style syntax, you already know about 95% of the Dart you need to create them.

You can read all about Dart at its [official website](https://dartlang.org).

To learn how to actually create assignments, see [Creating Assignment Templates](templates.html)

[Home](index.html)

[1]: http://berkeley-cs61b.github.io/public_html/materials/guides/using-git.html
[2]: https://github.com/mvhs
