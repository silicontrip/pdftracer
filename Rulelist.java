
import java.util.*;

public class Rulelist {


//	private ArrayList<ArrayList<File>> duplicatelist;

// RULE STRATEGY
	private HashMap<String,Stringcompare> compMap;
	private HashMap<String,Filepart> partMap;
	private HashMap<String,Rule> groupRuleMap;

	public Rulelist () {

// still would like to automate this even more
		compMap = new HashMap<String,Stringcompare>();
		compMap.put("Equals", new StringEquals());
		compMap.put("Matches", new StringMatches());
		compMap.put("Contains", new StringContains());
		compMap.put("StartsWith",  new StringStartsWith());

		partMap = new HashMap<String,Filepart>();
		partMap.put("Canonical" , new FilepartCanonical());
		partMap.put("Name",  new FilepartName());
		partMap.put("Parent" , new FilepartParent());

		groupRuleMap = new HashMap<String,Rule>();

		for (String partName: partMap.keySet())
		{
			for (String compName: compMap.keySet())
			{
				groupRuleMap.put ("any" + partName + compName, new RuleAny(partMap.get(partName),compMap.get(compName));
				groupRuleMap.put ("one" + partName + compName, new RuleOne(partMap.get(partName),compMap.get(compName));
				groupRuleMap.put ("all" + partName + compName, new RuleAll(partMap.get(partName),compMap.get(compName));
			}
		}

	}
/*
	public Rulelist (ArrayList<ArrayList<File>> dl) { 
		this();
		duplicatelist = dl; 
	}
*/

// filter rules
// (handled in strategies)

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


	public ArrayList<ArrayList<File>> evalGroup (ArrayList<ArrayList<File>> duplicatelist, ArrayListString groupCommand, String groupArgument)
	{
		ArrayList<ArrayList<File>> ndl = new ArrayList<ArrayList<File>>();
		for (ArrayList<File> al : duplicatelist)
			if (groupRuleMap.get(groupCommand).eval(groupArgument,al))
				ndl.add(al);	
		return ndl;
	}


}
