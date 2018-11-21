import java.util.ArrayList;
import java.io.File;

public abstract class Rule {

	protected Filepart file;
	protected Stringcompare comp;
	public Rule (Filepart fp, Stringcompare sc) { file = fp; comp = sc; }
	public abstract boolean eval(String e, ArrayList<File> al);

}


