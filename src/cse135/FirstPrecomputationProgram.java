package cse135;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

//import java

public class FirstPrecomputationProgram {

	public static void main(String[] args) {
		
		
		Connection conn=null;
		Statement stmt=null;
		
		try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
	    try {
			conn=DriverManager.getConnection("jdbc:postgresql://" +
			    	Util.SERVERNAME + ":" +
			    	Util.PORTNUMBER + "/" +
			    	Util.DATABASE,
			    	Util.USERNAME,
			    	Util.PASSWORD);
			
			stmt =conn.createStatement();
			
			String SQL = "";
			
			SQL = "insert into p_category_customer_state "
					+ "select c.id as cid, u.id as uid, u.state, sum(s.price * s.quantity) as total, u.name "
					+ "from users u, sales s, products p, categories c "
					+ "where u.id = s.uid and s.pid = p.id and p.cid = c.id "
					+ "group by u.id, c.id;;";
			
			stmt.execute(SQL);
			
			
			stmt.execute(SQL);
			stmt.execute(SQL);
			stmt.execute(SQL);
			stmt.execute(SQL);
			stmt.execute(SQL);
			
			
			
			
			conn.close();
			
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
		
	}
	
	
}
