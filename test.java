

public class test {

	public static void main(String[] args) {
		try {
			Filelist fl = new Filelist(".");
			fl.filescan();
			fl.filecompare();
			fl.print();
		} catch (Exception e) {
			System.out.println ("An error occurred: " + e );
		}
	}
}
