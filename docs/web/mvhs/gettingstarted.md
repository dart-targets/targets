{"title":"Getting Started"}
## Getting Started - MVHS

This guide covers the basics of getting started with Targets for teachers.

#### Necessary Personal Software ####

The same Targets executable runs on every machine, regardless of platform or whether the user is a teacher or a student. This means that the basic software setup for home computers uses the same [installation guide](installation.md) as the students. Teachers and TAs should follow this guide for their personal computers. Lab computers should have all the same tools installed.

The main difference is that teachers and TAs will actually need to use both Dart and Git directly to some extent.

Let's start with Git.

#### Setting Up a GitHub Account ####

[GitHub](https://github.com) is a hosted Git service that Targets uses to host assignment templates. Open source hosting is completely free (even if you don't actually license your code under an open source license). If you want private repositories, you can pay for it, sign up for GitHub Education (which I believe provides 5 free private ones), or try BitBucket, which is another hosted Git service that offers free private repositories to everyone.

However, Targets depends on all assignment repositories being public so that students can download them. In order to use GitHub, you'll need to make an account. If you don't have one already, make one now. Use whatever username you want, as I've created an mvhs GitHub organization that MV Targets assignments will be linked to so that students don't have to worry about teacher usernames.

Once you have created a GitHub account, you may be able to request an invite to the MVHS organization [here][2]. If you can't find anything, send me an [email](mailto:jack@jackthakar.com) or talk to me directly. I'll add you ASAP. I currently the owner of the organization (I registered for it because I didn't want Monta Vista getting it first), but I'll transfer it as soon as everything is set up.

#### Basic Git Usage ####

The [Creating Assignment Templates](templates.html) guide describes the specific Git commands you need to publish assignments, but I recommend that you read up elsewhere about how Git actually works.

For a good, fairly complete overview of Git, check out CS 61B's [Git Guide][1]. Some parts require a GitHub account registered with the class, but most should work for anyone.

#### Using Dart ####

Pretty much all of Targets is written in Dart. I chose Dart for a couple of reasons, namely that I like it and that it can run both on the command line and in a web browser really well. It can also run server-side, but I opted for PHP scripts since they can run on my shared hosting that I don't have to pay anything more for.

You don't need to learn much Dart to write Targets assignments (unless they're written in Dart), and since I'm assuming that everyone reading this knows Java, you already know about 95% of the Dart you need to create them.

You can read all about Dart at its [official website](https://dartlang.org), if you want to try Dart outside the scope of Targets (which I highly recommend).

There are actually a lot of differences between Dart and Java (most of which are for the better), but the only one you really need to worry about for writing Targets assignments is lists.

Dart doesn't have arrays. Everywhere that you would use an array in Java, you use a list. The easiest way to create a list is with a list literal, like so:

    List<int> intList = [1, 4, 9, 16, 25];

Generics work roughly the same as they do in Java, though there are no primitives (`ints` and `doubles` are objects), so you can use `List<int>` instead `List<Integer>`. However, you don't actually need the type annotation at all.

    var intList = [1, 4, 9, 16, 25];

This works just as well as the previous version. Basically, anywhere in Dart, you can use types when they help clarify your code (I make sure to use them for relevant methods that you need to use for tests in Targets), but you're never required to do so.

You can then use normal list methods:

    var intList = [1, 4, 9, 16, 25];
    intList.add(6); // 1, 4, 9, 16, 25, 6
    intList.insert(0, -4); // -4, 1, 4, 9, 16, 25, 6
    intList.remove(9); // -4, 1, 4, 16, 25, 6
    intList.removeAt(3); // -4, 1, 4, 25, 6


A couple other things to keep in mind about Dart when creating assignments:

- Dart uses `bool` for T/F values, as opposed to Java's `boolean`
- Inline String literals can use single or double quotes. You can use three quotes (single or double) to have a String literal span multiple lines.
- Dart **does not** support overloaded methods or constructors. However, it instead supports named constructors and optional parameters (both named and positional)
- Print in Dart is just `print()`

To learn how to actually create assignments, see [Creating Assignment Templates](templates.html)

[Home](index.html)

[1]: http://berkeley-cs61b.github.io/public_html/materials/guides/using-git.html
[2]: https://github.com/mvhs
