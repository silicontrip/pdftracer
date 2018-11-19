
import java.util.*;
import java.io.File;

public class Rulelist {


//	private ArrayList<ArrayList<File>> duplicatelist;

// RULE STRATEGY
	private HashMap<String,Stringcompare> compMap;
	private HashMap<String,Filepart> partMap;
	private HashMap<String,Rule> groupRuleMap;

	private HashMap<String,Filter> filterMap;
	private HashMap<String,Filter> ignoreMap;


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
		filterMap = new HashMap<String,Filter>();

		for (String partName: partMap.keySet())
		{
			for (String compName: compMap.keySet())
			{
				groupRuleMap.put ("Any" + partName + compName, new RuleAny(partMap.get(partName),compMap.get(compName)));
				groupRuleMap.put ("One" + partName + compName, new RuleOne(partMap.get(partName),compMap.get(compName)));
				groupRuleMap.put ("All" + partName + compName, new RuleAll(partMap.get(partName),compMap.get(compName)));

				filterMap.put("Any" + partName + compName, new FilterAny(partMap.get(partName),compMap.get(compName)));
				filterMap.put("One" + partName + compName, new FilterOne(partMap.get(partName),compMap.get(compName)));

			}
		}
	}

	// maybe return a string instead.
	public void printHelp() 
	{
		System.out.println("Group filter commands");
		for (String k : groupRuleMap.keySet())
			System.out.println("group:"+k+":<argument>");

		System.out.println("File filter commands");
			for (String k : filterMap.keySet())
				System.out.println("filter:"+k+":<argument>");

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

	public ArrayList<ArrayList<File>> evalGroup (ArrayList<ArrayList<File>> duplicatelist, String groupCommand, String groupArgument)
	{
		ArrayList<ArrayList<File>> ndl = new ArrayList<ArrayList<File>>();
		for (ArrayList<File> al : duplicatelist)
			if (groupRuleMap.get(groupCommand).eval(groupArgument,al))
				ndl.add(al);	
		return ndl;
	}

	public ArrayList<ArrayList<File>> evalIgnore (ArrayList<ArrayList<File>> duplicatelist, String groupCommand, String groupArgument)
	{
		ArrayList<ArrayList<File>> ndl = new ArrayList<ArrayList<File>>();
		for (ArrayList<File> al : duplicatelist)
			if (!groupRuleMap.get(groupCommand).eval(groupArgument,al))
				ndl.add(al);	
		return ndl;
	}


	public ArrayList<ArrayList<File>> evalFilter(ArrayList<ArrayList<File>> duplicatelist, String groupCommand, String groupArgument)
	{
		ArrayList<ArrayList<File>> ndl = new ArrayList<ArrayList<File>>();
		for (ArrayList<File> al : duplicatelist)
		{
			ArrayList<File> nl = filterMap.get(groupCommand).eval(groupArgument,al);
			if (nl.size() > 0)
				ndl.add(nl);	
		}
		// need to check that this doesn't delete all files.
		return ndl;
	}

}
