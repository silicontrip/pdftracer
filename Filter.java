import java.util.ArrayList;
import java.io.File;
public abstract class Filter {
	protected Filepart file;
	protected Stringcompare comp;
	public Filter (Filepart fp, Stringcompare sc) { file = fp; comp = sc; }
	public abstract ArrayList<File> eval(String e, ArrayList<File> al);
}