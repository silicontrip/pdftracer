import java.util.ArrayList;
import java.io.File;

public class RuleAny extends Rule {

        public RuleAny (Filepart fp, Stringcompare sc) { super(fp,sc); }
        
	public boolean eval (String e, ArrayList<File> al)
	{
                for (File f : al)
                        if (comp.eval(file.get(f),e))
                                return true;
                return false;
        }
	
}
