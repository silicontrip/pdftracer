import java.util.ArrayList;

import javax.lang.model.util.ElementScanner6;

import java.io.*;

public class dupefind {

	private static boolean findFile (ArrayList<File> sl, ArrayList<File> al)
	{
		// any entry in al is found in sl
		for  (File f : al)
			if (sl.contains(f))
				return true;

		return false;
	}

	private static ArrayList<File> findEntry(ArrayList<File> al, ArrayList<ArrayList<File>> aaf)
	{
		int count = 0;
		ArrayList<File> entry = null;
		for (ArrayList<File> sl: aaf)
		{
			if (findFile(sl,al))
			{
				count ++;
				entry = sl;
				// will return entry here, but doing testing first.
			}

		}
		assert(count <= 1); 
		// 0 <= count <= 1
		//if (count == 0)
			
		return entry;
	}

	private static String readln() {
		String ln = "";

		try {
			BufferedReader is = new BufferedReader(new InputStreamReader(System.in));
			ln = is.readLine();
                // if (ln.length() == 0 ) return null;
		} catch (IOException e) {
			System.out.println("IOException: " + e);
		}
		return ln;
	}

	private static void printParentLine (ArrayList<File> al)
	{
		if (al != null )
		{
		boolean first = true;
		for (File fl : al)
					{
							if(!first)
									System.out.print(" : ");
							first=false;
							try {
									System.out.print(fl.getParent());
							} catch (Exception e) {
									System.out.print("*ERROR*");
							}
					}
					System.out.println("");
				}
				else      
				System.out.println("null");
	}
	public static void printParent(ArrayList<ArrayList<File>> duplicatelist)
	{
			for (ArrayList<File> al : duplicatelist)
				printParentLine(al);
	}

		private static void printLine (ArrayList<File> al)
		{
			if (al != null )
			{
			boolean first = true;
            for (File fl : al)
                        {
                                if(!first)
                                        System.out.print(" : ");
                                first=false;
                                try {
                                        System.out.print(fl.getCanonicalPath());
                                } catch (Exception e) {
                                        System.out.print("*ERROR*");
                                }
                        }
						System.out.println("");
					}
					else      
					System.out.println("null");
		}
        public static void print(ArrayList<ArrayList<File>> duplicatelist)
        {
				for (ArrayList<File> al : duplicatelist)
					printLine(al);
        }
	public static void main(String[] args) {
		try {
			Rulelist  rulelist  = new Rulelist();
			//System.out.println("args len:" + args.length);
			Filelist fl;
			if (args.length == 0)
				fl = new Filelist(".");
			else 
				fl = new Filelist (args[0]);

			System.out.println("-- SCAN --");
			// start this in thread

			new Thread(new Runnable() {
				@Override
				public void run() {
					fl.filescan();
				}
			   }).start();

			// loop progress...
			while (!fl.getScanCompleted()) { 
				try {
					System.out.println("Files Remaining... " + fl.getScanRemain());
					Thread.sleep(1000); 
				} catch (InterruptedException ie) { ; }
			}
		
			int totalfiles = fl.countfiles();

			System.out.println("Files Remaining to Compare: " + totalfiles);
			System.out.println("-- COMPARE --");
			// start this in thread

			new Thread(new Runnable() {
				@Override
				public void run() {
					fl.filecompare();
				}
			   }).start();

			// loop progress...
			while (!fl.getCompareCompleted()) { 
				try {
					System.out.println("comparing... " + fl.getProcessed() + "/" + totalfiles + " " + fl.getMatches());
					Thread.sleep(1000); 
				} catch (InterruptedException ie) { ; }
			}

		//	fl.print();
			ArrayList<ArrayList<File>> allList = fl.getDuplicatelist();

			ArrayList<ArrayList<File>> currentList = allList;

			while (true) {
				
				System.out.print("" + currentList.size() + "> ");	
				String argument = readln();

				// going to need a command parser class...
				String[] arguments = argument.split(":");
				if (arguments.length == 1) {
					if ("reset".equals(arguments[0]))
					{
						currentList = allList;
					} else if ("delete".equals(arguments[0])) {
						// check current delete list with alllist
						ArrayList<ArrayList<File>> newList = new ArrayList<ArrayList<File>>();
						for (ArrayList<File> al : allList)
						{
							ArrayList<File> deleteList = findEntry(al,currentList);
							if (deleteList != null && deleteList.size() < al.size())
							{
								for (File f: deleteList)
								{
									System.out.println("Deleting... " + f.getCanonicalPath());
									f.delete();
								}
								// find entry in alllist
								// count entries
								// if al.size < alllist.entry.size()
								// delete

								//
							} else {
								if (deleteList != null) {
									System.out.print("WARNING not deleting all: "  );
									printLine(deleteList);
								}
								newList.add(al);
							}
						}
						allList = newList;
						currentList = newList;
					} else if ("compare".equals(arguments[0])) {
						for (ArrayList<File> al : allList)
						{
							ArrayList<File> deleteList = findEntry(al,currentList);
							if (deleteList != null)
							{
								if (al.size() == deleteList.size())
									System.out.println("-- ALL --");
								else
									System.out.println("--");
								printLine(al);
								printLine(deleteList);
							}
						}
					} else if ("all".equals(arguments[0])) {
						for (ArrayList<File> al : allList)
						{
							ArrayList<File> deleteList = findEntry(al,currentList);
							if (deleteList != null)
							{
								if (al.size() == deleteList.size())
								printLine(al);
							}
						}
					} else if ("parent".equals(arguments[0])) {
							printParent(currentList);
					} else if ("print".equals(arguments[0])) {
							print(currentList);	
					} else if ("quit".equals(arguments[0])) {
						System.exit(0);
					}
				} else if (arguments.length == 3) {
					if ("group".equals(arguments[0])) {
						currentList = rulelist.evalGroup(currentList, arguments[1],arguments[2]);
					} else if ("ignore".equals(arguments[0])) {
							currentList = rulelist.evalIgnore(currentList, arguments[1],arguments[2]);
					} else if ("filter".equals(arguments[0])) {
						// remember to check that we're not deleting all duplicates
						currentList = rulelist.evalFilter(currentList, arguments[1], arguments[2]);
					} else {
						rulelist.printHelp();
					}
 				} else {
					rulelist.printHelp();
				}

			}

		} catch (Exception e) {
			System.out.println ("An error occurred: " + e );
		}
	}
}
