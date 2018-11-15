
import java.io.*;
import java.util.*;
import java.nio.file.*;


public class Filelist {

	private HashMap<Long,HashSet<File>> flist;
	private ArrayList<ArrayList<File>> duplicatelist;
	private File scanDir;

	private ArrayList<File> toProcess;

	private int filesProcessed =0;

	public Filelist (File dir) { this(); setScanDir(dir); }
	public Filelist (String dir) { this(); setScanDir(dir); }

	public Filelist ()
	{
		flist = new HashMap<Long,HashSet<File>>();
		duplicatelist = new ArrayList<ArrayList<File>>();
	}

	public void setScanDir (File dir) { scanDir = dir; }
	public void setScanDir (String dir) { scanDir = new File(dir); }
	public File getScanDir () { return scanDir; }

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
	private boolean sameContent(File file1, File file2) throws IOException {
		return sameContent (file1.toPath(), file2.toPath());
	}

	private boolean sameContent(Path file1, Path file2) throws IOException {

		final long size = Files.size(file1);

		System.err.println("Comparing bytes: " + size);
/*
    if (size != Files.size(file2))
        return false;
*/
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
	}
	public int countfiles() 
	{
		int total = 0;
		for (Map.Entry<Long, HashSet<File>> fe : flist.entrySet()) 
			total += fe.getValue().size() - 1;
		return total;
	}

	public int getProcessed() { return filesProcessed; }
	
	public void filecompare() throws IOException
	{
		// some sort of readable progress
		filesProcessed = 0;
		for (Map.Entry<Long, HashSet<File>> fe : flist.entrySet()) {
			ArrayList<File> samesize = new ArrayList<File>(fe.getValue());
			if (samesize.size() > 1) {
				System.err.println("files: " + samesize.size() + " bytes: " + fe.getKey());
				if (samesize.size() == 2)
				{
					if (sameContent(samesize.get(0),samesize.get(1)))
					{
						ArrayList<File> samelist = new ArrayList<File>();
						samelist.add(samesize.get(0));
						samelist.add(samesize.get(1));
						duplicatelist.add(samelist);
					}
					filesProcessed ++;
					System.err.println("processed: " + filesProcessed); // tp be handled in a different thread
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
								samelist.add(duplicateFiles.get(j));
								duplicateFiles.remove(j);
							}
							filesProcessed ++;
							System.err.println("processed: " + filesProcessed); // tp be handled in a different thread
						}
						if (samelist.size() > 1)
							duplicatelist.add(samelist);

						duplicateFiles.remove(0);
					}
				}
			}	

		}

	}

	public void filescan()
	{

		toProcess = new ArrayList<File>();
		toProcess.add(getScanDir());

		while (toProcess.size() > 0) {
			for (File sourcefile: toProcess.get(0).listFiles()) {
				//System.out.println(sourcefile.getAbsolutePath());
				if (sourcefile.isFile()) {
					Long fsize = new Long(sourcefile.length());
					if (flist.containsKey(fsize))
					{
						flist.get(fsize).add(sourcefile);
					} else {
						HashSet<File> hs = new HashSet<File>();
						hs.add(sourcefile);
						flist.put(fsize,hs);
					}
					
				} else if ( sourcefile.isDirectory()) {
				      toProcess.add(sourcefile);
				} else {
					System.out.println ("Source is not a file.");
				}
			}
			toProcess.remove(0);
		}

	}
	
	public void scan() { 
		filescan(); 
		
	}
	

}
