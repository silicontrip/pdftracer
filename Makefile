
CP=.
CLASSES=Filelist.class Rulelist.class \
Filepart.class FilepartCanonical.class FilepartName.class FilepartParent.class \
Rule.class RuleAll.class RuleAny.class RuleOne.class \
Filter.class FilterAny.class FilterOne.class \
Stringcompare.class StringContains.class StringEquals.class StringMatches.class StringStartsWith.class \
dupefind.class test.class

JAVAOPTS=-target 1.7 -source 1.7
ANONCLASSES='test$$1.class' 'test$$2.class' 'dupefind$$1.class' 'dupefind$$2.class'
JARS=
MAINCLASS=

all: yajdf.jar

yajdf.jar: classes MANIFEST.MF
	jar cfm yajdf.jar MANIFEST.MF $(CLASSES) $(ANONCLASSES)

classes: $(CLASSES)


%.class: %.java
	javac $(JAVAOPTS)  -classpath $(CP) -encoding utf8 -Xlint:deprecation -Xlint:unchecked  $<

