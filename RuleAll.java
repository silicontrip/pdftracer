import java.util.ArrayList;
import java.io.File;
public class RuleAll extends Rule {

	public RuleAll (Filepart fp, Stringcompare sc) { super(fp,sc); }

	// I need an array called Ring with one element

	public boolean eval (String e, ArrayList<File> al)
	{
                for (File f : al)
                        if (!comp.eval(file.get(f),e))
                                return false;
                return true;
        }
	
}
