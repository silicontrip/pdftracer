
import java.io.File;
public class FilepartParent implements Filepart {

	public String get(File f) { return f.getParent(); }

}
