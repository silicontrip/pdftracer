# pdftracer
Yet another PDF editor.

## Background

Many years ago I learnt PostScript, initially to automate filling electronic forms for faxing but then it became my favourite vector image format.   So as soon as PDF became available I set out to learn that as a replacement to PostScript.  PDF however was more machine friendly and less human friendly, as the document contains the length of Content streams in bytes and each PDF object's byte offset is stored in the document, making writing one by hand quite difficult.

### Why tracer?

Recently I was handed a operating manual with the phrase "I have been unable to find this anywhere on the net"  So I scanned the manual.  Still scanning is not as good as a properly formatted PDF, so I set out to digitize it and discovered that I needed specific features which are not offered in any authoring program.

That's where this program comes in.  It is a PDF editor in the literal sense, and it lets you edit the PDF structure and content streams, while in real time updating the finished pdf view.  

Like any good Unix application, it doesn't throw up are you sure dialogs when you are about to delete or corrupt essential PDF objects, that could make the PDF unreadable or cause the editor to crash (I'm working on exception catching for these)

Some Planned features aka TODO:
* Document helpers for inserting bitmap images and fonts.
* an IDE style content stream editor, with command templates.
* High level functions such as add new Page.

Planned tracer features

* variable transperancy background layer, from any Quartz image.
* obtain document co-ordinates from PDFView.
* selecting element in PDFview highlights it in content stream view.
* Highlighting Text in stream editor highlights it in PDF view.

# Feature Updates (reverse chron)
* Line numbers in the text view
* Helper to insert one of the standard 13 PDF fonts.
* Printing the PDF
* Set the Page size from most common page sizes (so you don't have to remember the point dimensions like 595 x 842)
* Syntax Highlighting
* Choose stream editor font
* Scroll and Zoom in the PDF
* Add Page
* Basic PDF command help
* Open, Open Recent, Save, Save As
* Retain window layout per document
* Copy and Paste


# What syntax is this, Objective-C?

This code is a mixture of Objective-C and Objective-C++, unlike C++ is to C, Objective-C and Objective-C++ is fully compatible with thier nonobjective C counterparts.

## So what is different?

There are 5 main differences to know about when reading the code.  This is the crash course for those familiar with say Java or C++

### Important differences

* the `@""` symbol is used to denote an Objective-C NSString literal.
* All Objective-C classes are pass by reference, the compiler will not allow you to create an object that is initialised without the * pointer notation.  Of course this doesn't apply to primitive types.
* `instance->method()` (as there is no equivalent to instance.method()) calls have a very different syntax `[instance method]`
* Specifying parameters is also very different, `instance->method(arg1)` becomes `[instance method:arg1]`
* Multiple parameters have a psuedo specify by name. `[instance methodWithArg1:arg1 Arg2:arg2]` although this looks like named parameters, it isn't, you cannot change the order and you can't omit parameters (unless there is an overloaded method), it's just a more human friendly way of making a very long method name readable.
* Method declarations are also quite different.  `- (returnType*)methodName:(arg1Type*)arg1 withArg2:(arg2Type*)arg2;` The actual method name (known as a selector) is `methodName:withArg2:` which takes 2 parameters as there is 2 :  Also notice that the first character is a `-` this means it's an instance method. A `+` means it's a class method, or static method.

### Less important things
* Objective-C files use the extension `.m` Objective-C++ files use `.mm`
* Objective-C does not _call_ methods from other classes but sends messages to them.  This is mostly just a semantic difference.  But can allow classes to respond to any method and the compiler only reports a warning if a method isn't found `NSString may not respond to: DoTheHokeyPokey`
* the `#include` functionality is expanded on using the `#import` keyword. This also automatically protects from including the same header twice, without the need for wrapping the header in `#ifndef MY_HEADER`
* Objective-C header files do not live in a single include directory, but are a part of a Framework. A framework contains the shared library binary, additional resources and the headers (some frameworks are distributed without headers) this location is hidden from the code. An import looks like: `#import <Foundation/Foundation.h>` Foundation.h is considered an umbrella header which includes all the Foundation classes header files, where the actual header is located `/System/Library/Frameworks/Foundation.framework/Versions/C/Headers/Foundation.h
* The objective-C specific class definitions begin with `@`, method declarations and instance variables are begin with a `@interface MyClass : MySuper` and end with `@end` The actual method code begins with `@implementation MyClass` and finish with a `@end`
* Objective C splits object allocation and initialisation into 2 seperate tasks. You'll see a lot of these kind of statements; `MyClass* myinstance = \[\[MyClass alloc] init];` 

### and the confusing memory stuff (which I only understood about a week ago)
As none of the Objective-c instance objects can be statically allocated and therefore deleted when they go out of scope.  Objective-C has 3 ways to prevent local variables from leaking.  (by the way I went from C coding to Java, so my understanding didn't go much beyond `malloc`, `realloc`, `free`)

1. For every `alloc` there must be a `release` or `autorelease` method called.  `Release` forces the object to deallocate immediately, `autorelease` will release at an appropriate moment, usually when the variable goes out of scope, or you can wrap code in autorelease blocks, if it's a heavy memory using block of code, to force a release at the end of the block.
2. Use of the naming convention Class alloc and initialisation methods names eg `NSString* mystring = [NSString stringWithCString:"abc123"];`  will return an object already auto released.  So no need to do that.  If you do want to use the variable elsewhere, send it a `retain` message.  Also note that if you add this instance to a container class, array, dictionary etc. That class will take ownership and send a retain message to the newly added instance. So you don't have to.
3. Another naming convention includes the word `new` and indicates that the returned instance will be retained and you will have to release it at some point.

Not very difficult concepts, but important to have the specific details. (oh and I learnt all this from XCode's Analyze function, which showed me all the allocations I'd made errors with, and made it quite clear how this system worked)
