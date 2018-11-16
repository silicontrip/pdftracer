

public class test {

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
        public static void print(ArrayList<ArrayList<File>> duplicatelist)
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
	public static void main(String[] args) {
		try {
			Rulelist  rulelist  = new Rulelist();
			Filelist fl = new Filelist(".");
			System.out.println("-- SCAN --");
			fl.filescan();
			System.out.println("Files to Compare: " + fl.countfiles());
			System.out.println("-- COMPARE --");
			fl.filecompare();
		//	fl.print();
			ArrayList<ArrayList<File>> currentList = fl.getDuplicatelist();

			while (true) {
				print(currentList);
				System.out.print("> ");	
				String argument = readln();
				String[] args = arguments.split("/;/");	
				if (args.length == 2) {
					currentList = rulelist.evalGroup(currentList, args[0],args[1]);
				} else {
					System.out.println("command and argument required ; seperated");
				}
				


			}

		} catch (Exception e) {
			System.out.println ("An error occurred: " + e );
		}
	}
}
