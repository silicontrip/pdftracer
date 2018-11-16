import java.io.File;
public class FilepartName implements Filepart {

	public String get(File f) { return f.getName(); }

}
