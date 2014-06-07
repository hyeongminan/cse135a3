package cse135;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;

//import java

public class FirstPrecomputationProgram {

	public static void main(String[] args) {
		
		System.out.println("Program started...");
		
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
			
			System.out.println("Creating precomputation tables...");
			
			PreparedStatement ps = conn.prepareStatement("CREATE TABLE p_category_customer_state (   cid integer NOT NULL,   uid integer NOT NULL,   state text NOT NULL,   agg integer NOT NULL,   uname text NOT NULL,   CONSTRAINT p_category_customer_state_pkey PRIMARY KEY (cid, uid, state) );");
			ps.executeUpdate();
			
			ps = conn.prepareStatement("CREATE TABLE p_category_product (   cid integer NOT NULL,   pid integer NOT NULL,   agg integer NOT NULL,   pname text NOT NULL,   CONSTRAINT p_category_product_pkey PRIMARY KEY (cid, pid) );");
			ps.executeUpdate();
			
			ps = conn.prepareStatement("CREATE TABLE p_category_product_state (   cid integer NOT NULL,   pid integer NOT NULL,   state text NOT NULL,   agg integer NOT NULL,   pname text NOT NULL,   CONSTRAINT p_category_product_state_pkey PRIMARY KEY (cid, pid, state) );");
			ps.executeUpdate();
			
			ps = conn.prepareStatement("CREATE TABLE p_category_state (   cid integer NOT NULL,   state text NOT NULL,   agg integer NOT NULL,   CONSTRAINT p_category_state_pkey PRIMARY KEY (cid, state) );");
			ps.executeUpdate();
			
			ps = conn.prepareStatement("CREATE TABLE p_customer_product (   uid integer NOT NULL,   pid integer NOT NULL,   agg integer NOT NULL,   CONSTRAINT p_customer_product_pkey PRIMARY KEY (uid, pid) );");
			ps.executeUpdate();
			
			ps = conn.prepareStatement("CREATE TABLE p_customer_state (   uid integer NOT NULL,   state text NOT NULL,   agg integer NOT NULL,   uname text NOT NULL,   CONSTRAINT p_customer_state_pkey PRIMARY KEY (uid, state) );");
			ps.executeUpdate();
			
			ps.close();
			
			String SQL = "";
			
			System.out.println("Populating precomputation tables...");
			
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
			
			System.out.println("Program completed!");
			
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			System.out.println("Woops, SQLException was thrown!");
			e.printStackTrace();
		}
		
		
		
	}
	
	
}
