
import java.util.ArrayList;
import java.io.File;
public class RuleOne extends Rule {

	public RuleOne (Filepart fp, Stringcompare sc) { super(fp,sc); }

	public boolean eval (String e, ArrayList<File> al)
	{
		int count = 0;
                for (File f : al)
                        if (comp.eval(file.get(f),e))
                                count++;
                return count==1;
        }
	
}
