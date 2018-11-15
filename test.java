

public class test {

	public static void main(String[] args) {
		try {
			Filelist fl = new Filelist(".");
			System.out.println("-- SCAN --");
			fl.filescan();
			System.out.println("Files to Compare: " + fl.countfiles());
			System.out.println("-- COMPARE --");
			fl.filecompare();
			fl.print();
		} catch (Exception e) {
			System.out.println ("An error occurred: " + e );
		}
	}
}
