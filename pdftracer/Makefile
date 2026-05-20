
# be careful using asan as it slows down NSTextView dramatically.
#OPTFLAGS=-g -fsanitize=address

OPTFLAGS=-O3
CPP=clang++
CPPFLAGS=$(OPTFLAGS) -I/usr/local/include -std=c++17 -I/opt/homebrew/include

#LDFLAGS=-std=c++17 -fsanitize=address -L/usr/local/lib -lqpdf -framework Foundation -framework AppKit -framework QuartzCore -framework PDFKit -framework UniformTypeIdentifiers -framework CoreText
LDFLAGS=-std=c++17 -L/usr/local/lib -L/opt/homebrew/lib -lqpdf -framework Foundation -framework AppKit -framework QuartzCore -framework PDFKit -framework UniformTypeIdentifiers -framework CoreText

CC=clang
CFLAGS=$(OPTFLAGS) -I/usr/local/include -isysroot `xcrun --show-sdk-path`

OBJ= ObjcQPDF.o ObjcQPDFObjectHandle.o \
	Arguments.o OutlineQPDF.o OutlineQPDFObj.o OutlineQPDFPage.o \
	QPDFDocument.o QPDFDocumentController.o QPDFFontEmbedder.o QPDFHelp.o QPDFMenu.o QPDFOutlineView.o \
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
