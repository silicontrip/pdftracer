import java.util.ArrayList;
import java.io.File;

public class FilterAny extends Filter {

	public FilterAny (Filepart fp, Stringcompare sc) { super(fp,sc); }

	public ArrayList<File> eval (String e, ArrayList<File> al)
	{
        ArrayList<File> nl = new ArrayList<File>();
                for (File f : al)
                        if (comp.eval(file.get(f),e))
                                nl.add(f);
                return nl;
        }
	
}
