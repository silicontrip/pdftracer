# pdftracer
Yet another PDF editor.

## Background

Many years ago I learnt PostScript, initially to automate filling electronic forms for faxing but then it became my favourite vector image format.   So as soon as PDF became available I set out to learn that as a replacement to PostScript.  PDF however was more machine friendly and less human friendly, as the document contains the length of Content streams in bytes and each PDF object's byte offset is stored in the document, making writing one by hand quite difficult.

### Why tracer?

Recently I was handed a operating manual with the phrase "I have been unable to find this anywhere on the net"  So I scanned the manual.  Still scanning is not as good as a properly formatted PDF, so I set out to digitize it and discovered that I needed specific features which are not offered in any authoring program.

That's where this program comes in.  It is a PDF editor in the literal sense, and it lets you edit the PDF structure and content streams, while in real time updating the finished pdf view.  

Some Planned features include:
* Document helpers for inserting bitmap images and fonts.
* an IDE style content stream editor, with command templates.
* High level functions such as add new Page.

Tracer features

* variable transperancy background layer, from any Quartz image.
* obtain document co-ordinates from PDFView.
* selecting element in PDFview highlights it in content stream view. 
