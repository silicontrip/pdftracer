
public class FilepartCanonical implements Filepart {

	public String get(File f) { return f.getCanonicalPath(); }

}
