
import java.util.ArrayList;
import java.io.File;
public class FilterOne extends Filter {

	public FilterOne (Filepart fp, Stringcompare sc) { super(fp,sc); }

	public ArrayList<File> eval (String e, ArrayList<File> al)
	{
        ArrayList<File> nl = new ArrayList<File>();
                for (File f : al)
                        if (comp.eval(file.get(f),e))
                                nl.add(f);
        if (nl.size() == 1)
            return nl;
        else
            return new ArrayList<File>();
    }
	
}
