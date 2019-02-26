
import java.io.*;
import java.util.*;
import java.nio.file.*;


public class Filelist implements Runnable, Serializable {

	transient private HashMap<Long,HashSet<File>> flist;
	private ArrayList<ArrayList<File>> duplicatelist;
//	private File scanDir;
	private ArrayList<File>scanDirs;

	transient private ArrayList<File> toProcess;

	transient private int filesProcessed =0;
	transient private int matchesProcessed =0;
	transient private boolean scanCompleted = false;
	transient private boolean compareCompleted = false;


	public Filelist (File dir) { this(); addScanDir(dir); }
	public Filelist (String dir) { this(); addScanDir(dir); }

	public Filelist ()
	{
		scanDirs = new ArrayList<File>();
		flist = new HashMap<Long,HashSet<File>>();
		duplicatelist = new ArrayList<ArrayList<File>>();
	}

	//public void setScanDir (File dir) { scanDir = dir; }
//	public void setScanDir (String dir) { scanDir = new File(dir); }
//	public File getScanDir () { return scanDir; }

	public void addScanDir(File dir) { scanDirs.add(dir); }
	public void addScanDir(String dir) { scanDirs.add(new File(dir)); }

// these are needed for serializable...?
	public ArrayList<ArrayList<File>> getDuplicatelist() { return duplicatelist; }
	public void setDuplicatelist(ArrayList<ArrayList<File>> dl) { duplicatelist = dl; }

	public void print() 
	{
		for (ArrayList<File> al : duplicatelist)
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
	}


	// from  https://stackoverflow.com/questions/27379059/determine-if-two-files-store-the-same-content
	private boolean sameContent(File file1, File file2)  {
		return sameContent (file1.toPath(), file2.toPath());
	}

	private boolean sameContent(Path file1, Path file2)  {

		try {
			final long size = Files.size(file1);
			// zero length check
			if (size < 4096)
				return Arrays.equals(Files.readAllBytes(file1), Files.readAllBytes(file2));

			try (BufferedInputStream is1 = new BufferedInputStream (Files.newInputStream(file1));
				BufferedInputStream is2 = new BufferedInputStream(Files.newInputStream(file2))) {
        // Compare byte-by-byte.
        // Note that this can be sped up drastically by reading large chunks
        // (e.g. 16 KBs) but care must be taken as InputStream.read(byte[])
        // does not neccessarily read a whole array!
				int data;
				while ((data = is1.read()) != -1)
				    if (data != is2.read())
					return false;
			}

			return true;
		} catch (IOException e) {
			// if one file has a read error, it's probably not going to be the same as the other file
			// or it's best not to match it for other reasons.
			return false;
		}
	}


	// public int countfiles() { return flist.size(); }

	
	public int countfiles() 
	{
		int total = 0;
		for (Map.Entry<Long, HashSet<File>> fe : flist.entrySet()) 
			total += fe.getValue().size()>1? 1:0;
		return total;
	}

	public int getProcessed() { return filesProcessed; }
	public int getMatches() { return matchesProcessed; }
	public int getScanRemain() { 
		if (toProcess != null)
			return toProcess.size(); 
			return 0;
		}
	public boolean getScanCompleted() { return scanCompleted; }
	public boolean getCompareCompleted() { return compareCompleted; }

// compare a list of files
	public void filecompare() 
	{
		// some sort of readable progress
		filesProcessed = 0;
		compareCompleted = false;
		for (Map.Entry<Long, HashSet<File>> fe : flist.entrySet()) {
			ArrayList<File> samesize = new ArrayList<File>(fe.getValue());
			if (samesize.size() > 1) {
				filesProcessed ++;

				//System.err.println("files: " + samesize.size() + " bytes: " + fe.getKey());
				if (samesize.size() == 2)
				{
					if (sameContent(samesize.get(0),samesize.get(1)))
					{
						matchesProcessed ++;
						ArrayList<File> samelist = new ArrayList<File>();
						samelist.add(samesize.get(0));
						samelist.add(samesize.get(1));
						duplicatelist.add(samelist);
					}
				//	filesProcessed ++;
					//System.err.println("processed: " + filesProcessed); // tp be handled in a different thread
				} else {
					ArrayList<File> duplicateFiles = new ArrayList<File>(samesize);
					while (duplicateFiles.size() > 0)
					{
						ArrayList<File> samelist = new ArrayList<File>();
						samelist.add(duplicateFiles.get(0));
						for (int j =1; j < duplicateFiles.size(); j++)
						{
							if (sameContent(duplicateFiles.get(0),duplicateFiles.get(j)))
							{
								matchesProcessed ++;
								samelist.add(duplicateFiles.get(j));
								duplicateFiles.remove(j);
							}
					//		System.err.println("processed: " + filesProcessed); // tp be handled in a different thread
						}
				//		filesProcessed ++;

						if (samelist.size() > 1)
							duplicatelist.add(samelist);

						duplicateFiles.remove(0);
					}
				}
			}	

		}
		compareCompleted = true;
	}

// create a list of file, index by filesize
	public void filescan()
	{
		scanCompleted = false;

		toProcess = new ArrayList<File>(scanDirs);
		
		//toProcess.add(getScanDir());

		while (toProcess.size() > 0) {
			for (File sourcefile: toProcess.get(0).listFiles()) {
				//System.out.println(sourcefile.getAbsolutePath());
				if (sourcefile.isFile()) {
					Long fsize = new Long(sourcefile.length());
					if (fsize > 0)  // use find -empty
					{
						if (flist.containsKey(fsize))
						{
							flist.get(fsize).add(sourcefile);
						} else {
							HashSet<File> hs = new HashSet<File>();
							hs.add(sourcefile);
							flist.put(fsize,hs);
						}
					}
				} else if ( sourcefile.isDirectory()) {
				      toProcess.add(sourcefile);
				} else {
					System.out.println ("Source is not a file.");
				}
			}
			toProcess.remove(0);
		}
		scanCompleted = true;

	}
	
	public void run() { 
		filescan(); 
		filecompare();		
	}
	

}
