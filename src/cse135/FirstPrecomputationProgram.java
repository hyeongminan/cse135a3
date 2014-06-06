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
			
			SQL = "insert into p_customer_state "
					+ "select u.id as uid, u.state, sum(s.price * s.quantity) as total, u.name "
					+ "from users u, sales s "
					+ "where u.id = s.uid "
					+ "group by u.id;";
			stmt.execute(SQL);
			
			SQL = "insert into p_category_state "
					+ "select c.id as cid, u.state, sum(s.price * s.quantity) as total "
					+ "from users u, sales s, products p, categories c "
					+ "where u.id = s.uid and s.pid = p.id and p.cid = c.id "
					+ "group by c.id, u.state;";
			stmt.execute(SQL);
			
			SQL = "insert into p_customer_product "
					+ "select u.id, p.id, sum(s.quantity * s.price) as total "
					+ "from users u, sales s, products p "
					+ "where u.id = s.uid and s.pid = p.id "
					+ "group by u.id, p.id;";
			stmt.execute(SQL);
			
			SQL = "insert into p_category_product "
					+ "select c.id as cid, p.id as pid, sum(s.price * s.quantity) as agg, p.name "
					+ "from categories c, products p, sales s "
					+ "where s.pid = p.id and p.cid = c.id "
					+ "group by c.id, p.id;";
			stmt.execute(SQL);
			
			SQL = "insert into p_category_product_state "
					+ "select c.id as cid, p.id as pid, u.state, sum(s.price * s.quantity) as agg, p.name "
					+ "from categories c, products p, users u, sales s "
					+ "where s.uid = u.id and p.id = s.pid and p.cid = c.id "
					+ "group by c.id, p.id, u.state;";
			stmt.execute(SQL);
			
			
			
			
			conn.close();
			
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
		
	}
	
	
}
