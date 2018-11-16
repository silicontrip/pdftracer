import java.io.File;
public class FilepartCanonical implements Filepart {

	public String get(File f) { 
		try {
			return f.getCanonicalPath(); 
		} catch (Exception e) {
			return null;
		}
	}
}
