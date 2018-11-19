
CP=.
CLASSES=Filelist.class Rulelist.class \
Filepart.class FilepartCanonical.class FilepartName.class FilepartParent.class \
Rule.class RuleAll.class RuleAny.class RuleOne.class \
Filter.class FilterAny.class FilterOne.class \
Stringcompare.class StringContains.class StringEquals.class StringMatches.class StringStartsWith.class \
test.class dupefind.class

ANONCLASSES='test$$1.class' 'test$$2.class' 'dupefind$$1.class' 'dupefind$$2.class'
JARS=
MAINCLASS=

all: hack.jar

hack.jar: classes MANIFEST.MF
	jar cfm yajdf.jar MANIFEST.MF $(CLASSES) $(ANONCLASSES)

classes: $(CLASSES)


%.class: %.java
	javac  -classpath $(CP) -encoding utf8 -Xlint:deprecation -Xlint:unchecked  $<

