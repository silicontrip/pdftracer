
CP=.
CLASSES=Filelist.class Rulelist.class \
Filepart.class FilepartCanonical.class FilepartName.class FilepartParent.class \
Rule.class RuleAll.class RuleAny.class RuleOne.class \
Filter.class FilterAny.class FilterOne.class \
Stringcompare.class StringContains.class StringEquals.class StringMatches.class StringStartsWith.class \
test.class

ANONCLASSES=
JARS=
MAINCLASS=

all: hack.jar

hack.jar: classes MANIFEST.MF
	jar cfm yajdf.jar MANIFEST.MF $(CLASSES)

classes: $(CLASSES)


%.class: %.java
	javac  -classpath $(CP) -encoding utf8 -Xlint:deprecation -Xlint:unchecked  $<

