
import java.util.*;

public class Rulelist {


	private ArrayList<ArrayList<File>> duplicatelist;

	public Rulelist (ArrayList<ArrayList<File>> dl) { duplicatelist = dl; }


// filter rules
//looking like some OO strategy is required
	private boolean anyCanonicalEquals(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getCanonicalPath().equals(e))
				return true;
		return false;
	}

	private boolean anyCanonicalContains(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getCanonicalPath().contains(e))
				return true;
		return false;
	}

	private boolean anyCanonicalMatches(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getCanonicalPath().matches(e))
				return true;
		return false;
	}

	private boolean anyCanonicalStartsWith(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getCanonicalPath().startsWith(e))
				return true;
		return false;
	}

	private boolean anyNameEquals(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getName().equals(e))
				return true;
		return false;
	}

	private boolean anyNameContains(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getName().contains(e))
				return true;
		return false;
	}

	private boolean anyNameMatches(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getName().matches(e))
				return true;
		return false;
	}

	private boolean anyNameStartsWith(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getName().startsWith(e))
				return true;
		return false;
	}

	private boolean anyParentEquals(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getParent().equals(e))
				return true;
		return false;
	}

	private boolean anyParentContains(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getParent().contains(e))
				return true;
		return false;
	}

	private boolean anyParentMatches(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getParent().matches(e))
				return true;
		return false;
	}

	private boolean anyParentStartsWith(String e, ArrayList<File> al)
	{
		for (File f : al)
			if (f.getParent().startsWith(e))
				return true;
		return false;
	}

// file filter

// group filter
	public Rulelist equalsAny (String e)
	{
		ArrayList<ArrayList<File>> ndl = new ArrayList<ArrayList<File>>();
		for (ArrayList<File> al : duplicatelist)
			if (equalsAny(e,al))
				ndl.add(al);	
		return new Rulelsit(ndl);
	}



}
