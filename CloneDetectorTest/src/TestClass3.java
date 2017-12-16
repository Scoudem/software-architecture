public class TestClass3 {
	int i = 0;
	public void Main()
	{
		i = 1;
		i = 2;
		i = 3; //Comment
		i = 4;
		i = 5; /* Multiline
		Comment */
		i = 6;
		
		
		System.out.println("// but not a comment");
		System.out.println("/*  */ also not a comment");
		
		/* Code between */ System.out.println("/*  */ also not a comment"); /* two comments */
	}
}
