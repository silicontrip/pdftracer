
import java.io.File;
public class FilepartParent implements Filepart {

	public String get(File f) {  
		String s = f.getParent(); 
		// System.out.println("parent: " + s);
		return s;
	}

}
