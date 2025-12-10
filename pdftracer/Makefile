
#OPTFLAGS=-g -fsanitize=address
OPTFLAGS=-g
CPP=clang++
CPPFLAGS=$(OPTFLAGS) -I/usr/local/include -std=c++17

LDFLAGS=-std=c++17 -L/usr/local/lib -lqpdf -framework Foundation -framework AppKit -framework QuartzCore -framework PDFKit

CC=clang
CFLAGS=$(OPTFLAGS) -I/usr/local/include 

OBJ= ObjcQPDF.o ObjcQPDFObjectHandle.o \
	Arguments.o OutlineQPDF.o OutlineQPDFObj.o OutlineQPDFPage.o QPDFCell.o \
	QPDFDocument.o QPDFDocumentController.o QPDFHelp.o QPDFMenu.o QPDFOutlineView.o QPDFPageView.o \
	QPDFSegmentedCell.o QPDFSyntaxHighlighter.o QPDFTextView.o QPDFView.o QPDFWindow.o QPDFWindowController.o \
	NoodleLineNumberMarker.o NoodleLineNumberView.o

all: editor

editor: $(OBJ) editor.o
	$(CPP) $(LDFLAGS) $(OBJ) -o editor editor.o

%.o: %.mm
	$(CPP) $(CPPFLAGS) -c $^

%.o: %.m
	$(CC) $(CFLAGS) -c $^

clean:
	rm -f *.o editor
