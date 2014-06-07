<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" import="database.*"   import="java.util.*" errorPage="" %>
<%@ page import="cse135.Util" %>
<%@include file="welcome.jsp" %>
<%
if(session.getAttribute("name")!=null)
{

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CSE135</title>
</head>

<body>

<div style="width:20%; position:absolute; top:50px; left:0px; height:90%; border-bottom:1px; border-bottom-style:solid;border-left:1px; border-left-style:solid;border-right:1px; border-right-style:solid;border-top:1px; border-top-style:solid;">
	<table width="100%">
		<tr><td><a href="products_browsing.jsp" target="_self">Show Products</a></td></tr>
		<tr><td><a href="buyShoppingCart.jsp" target="_self">Buy Shopping Cart</a></td></tr>
	</table>	
</div>
<div style="width:79%; position:absolute; top:50px; right:0px; height:90%; border-bottom:1px; border-bottom-style:solid;border-left:1px; border-left-style:solid;border-right:1px; border-right-style:solid;border-top:1px; border-top-style:solid;">
<p><table align="center" width="80%" style="border-bottom-width:2px; border-top-width:2px; border-bottom-style:solid; border-top-style:solid">
	<tr><td align="left"><font size="+3">
	<%
	
	class Sale 
	{
		private int uid=0;
		private int pid=0;
		private int cid=0;
		private int quantity=0;
		private int price=0;
		private String uname=null;
		private String pname=null;
		private String state=null;
		public Sale(){
		//default constructor
		}
		public Sale(int userid, int productid, int q, int p, int catid, String productname, String username, String userstate) {
			uid = userid;
			pid = productid;
			quantity = q;
			price = p;
			cid = catid;
			pname = productname;
			uname = username;
			state = userstate;
		}
		public int getUid(){
			return uid;
		}
		public int getPid(){
			return pid;
		}
		public int getCid(){
			return cid;
		}
		public int getQuantity(){
			return quantity;
		}
		public int getPrice(){
			return price;
		}
		public String getUname(){
			return uname;
		}
		public String getPname(){
			return pname;
		}
		public String getState(){
			return state;
		}
		public void setCid(int categoryId){
			cid = categoryId;
		}
		public void setUname(String username){
			uname = username;
		}
		public void setPname(String prodname){
			pname = prodname;
		}
		public void setState(String statename){
			state = statename;
		}
	}
	
	
	
	String uName=(String)session.getAttribute("name");
	int userID  = (Integer)session.getAttribute("userID");
	String role = (String)session.getAttribute("role");
	String card=null;
	int card_num=0;
	try {card=request.getParameter("card"); }catch(Exception e){card=null;}
	try
	{
		 card_num    = Integer.parseInt(card);
		 if(card_num>0)
		 {
	
				Connection conn=null;
				Statement stmt=null;
				try
				{
					
					String SQL_copy="INSERT INTO sales (uid, pid, quantity, price) select c.uid, c.pid, c.quantity, c.price from carts c where c.uid="+userID+";";
					String  SQL="delete from carts where uid="+userID+";";
					
					try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
				    conn=DriverManager.getConnection("jdbc:postgresql://" +
			    	    	Util.SERVERNAME + ":" +
			    	    	Util.PORTNUMBER + "/" +
			    	    	Util.DATABASE,
			    	    	Util.USERNAME,
			    	    	Util.PASSWORD);
					stmt =conn.createStatement();
					
					ResultSet rs = stmt.executeQuery("select c.uid, c.pid, c.quantity, c.price, p.cid, p.name, u.name, u.state from carts c, products p, users u where c.uid="+userID+" and c.pid=p.id and c.uid=u.id;");
					
					ArrayList<Sale> sales = new ArrayList<Sale>();
					
					
					while(rs.next()){
						Sale sale = new Sale(rs.getInt(1),rs.getInt(2),rs.getInt(3),rs.getInt(4),rs.getInt(5),rs.getString(6), rs.getString(7), rs.getString(8)); 
						sales.add(sale);
					}
					
					PreparedStatement update_p_category_customer_state = null;
					PreparedStatement update_p_category_product = null;
					PreparedStatement update_p_category_product_state = null;
					PreparedStatement update_p_category_state = null;
					PreparedStatement update_p_customer_product = null;
					PreparedStatement update_p_customer_state = null;
					
					PreparedStatement insert_p_category_customer_state = null;
					PreparedStatement insert_p_category_product = null;
					PreparedStatement insert_p_category_product_state = null;
					PreparedStatement insert_p_category_state = null;
					PreparedStatement insert_p_customer_product = null;
					PreparedStatement insert_p_customer_state = null;
					
					String update_1 = "update p_category_customer_state set agg = agg + ? where uid = ? and cid = ?;";
					String update_2 = "update p_category_product set agg = agg + ? where pid = ?;";
					String update_3 = "update p_category_product_state set agg = agg + ? where cid = ? and pid=? and state=?;";
					String update_4 = "update p_category_state set agg = agg + ? where state = ? and cid = ?;";
					String update_5 = "update p_customer_product set agg = agg + ? where uid = ? and pid = ?;";
					String update_6 = "update p_customer_state set agg = agg + ? where uid = ?;";
					
					String insert_1 = "insert into p_category_customer_state (cid, uid, state, agg, uname) values (?, ?, ?, ?, ?);";
					String insert_2 = "insert into p_category_product (cid, pid, agg, pname) values (?, ?, ?, ?);";
					String insert_3 = "insert into p_category_product_state (cid, pid, state, agg, pname) values (?, ?, ?, ?, ?);";
					String insert_4 = "insert into p_category_state (cid, state, agg) values (?, ?, ?);";
					String insert_5 = "insert into p_customer_product (uid, pid, agg) values (?, ?, ?);";
					String insert_6 = "insert into p_customer_state (uid, state, agg, uname) values (?, ?, ?, ?);";
					
					Sale entry;
					int result_1, result_2, result_3, result_4, result_5, result_6;
					for(int i = 0; i < sales.size(); i++)
					{
						entry = sales.get(i);
						
						update_p_category_customer_state = conn.prepareStatement(update_1);
						update_p_category_customer_state.setInt(1, entry.getQuantity() * entry.getPrice());
						update_p_category_customer_state.setInt(2, entry.getUid());
						update_p_category_customer_state.setInt(3, entry.getCid());
						result_1 = update_p_category_customer_state.executeUpdate();
						if(result_1 == 0)
						{
							insert_p_category_customer_state = conn.prepareStatement(insert_1);
							insert_p_category_customer_state.setInt(1, entry.getCid());
							insert_p_category_customer_state.setInt(2, entry.getUid());
							insert_p_category_customer_state.setString(3, entry.getState());
							insert_p_category_customer_state.setInt(4, entry.getQuantity() * entry.getPrice());
							insert_p_category_customer_state.setString(5, entry.getUname());
							result_1 = insert_p_category_customer_state.executeUpdate();
						}
						conn.commit();
						
						update_p_category_product = conn.prepareStatement(update_2);
						update_p_category_product.setInt(1, entry.getQuantity() * entry.getPrice());
						update_p_category_product.setInt(2, entry.getPid());
						result_2 = update_p_category_product.executeUpdate();
						if(result_2 == 0)
						{
							insert_p_category_product = conn.prepareStatement(insert_2);
							insert_p_category_product.setInt(1, entry.getCid());
							insert_p_category_product.setInt(2, entry.getPid());
							insert_p_category_product.setInt(3, entry.getQuantity() * entry.getPrice());
							insert_p_category_product.setString(4, entry.getPname());
							result_2 = insert_p_category_product.executeUpdate();
						}
						conn.commit();
						
						
						update_p_category_product_state = conn.prepareStatement(update_3);
						update_p_category_product_state.setInt(1, entry.getQuantity() * entry.getPrice());
						update_p_category_product_state.setInt(2, entry.getCid());
						update_p_category_product_state.setInt(3, entry.getPid());
						update_p_category_product_state.setString(4, entry.getState());
						result_3 = update_p_category_product_state.executeUpdate();
						if(result_3 == 0)
						{
							insert_p_category_product_state = conn.prepareStatement(insert_3);
							insert_p_category_product_state.setInt(1, entry.getCid());
							insert_p_category_product_state.setInt(2, entry.getPid());
							insert_p_category_product_state.setString(3, entry.getState());
							insert_p_category_product_state.setInt(4, entry.getQuantity() * entry.getPrice());
							insert_p_category_product_state.setString(5, entry.getPname());
							result_3 = insert_p_category_product_state.executeUpdate();
						}
						
						conn.commit();
						
						
						update_p_category_state = conn.prepareStatement(update_4);
						update_p_category_state.setInt(1, entry.getQuantity() * entry.getPrice());
						update_p_category_state.setString(2, entry.getState());
						update_p_category_state.setInt(3, entry.getCid());
						result_4 = update_p_category_state.executeUpdate();
						if(result_4 == 0)
						{
							insert_p_category_state = conn.prepareStatement(insert_4);
							insert_p_category_state.setInt(1, entry.getCid());
							insert_p_category_state.setString(2, entry.getState());
							insert_p_category_state.setInt(3, entry.getQuantity() * entry.getPrice());
							result_4 = insert_p_category_state.executeUpdate();
						}
						conn.commit();
						
						
						update_p_customer_product = conn.prepareStatement(update_5);
						update_p_customer_product.setInt(1, entry.getQuantity() * entry.getPrice());
						update_p_customer_product.setInt(2, entry.getUid());
						update_p_customer_product.setInt(3, entry.getPid());
						result_5 = update_p_customer_product.executeUpdate();
						if(result_5 == 0)
						{
							insert_p_customer_product = conn.prepareStatement(insert_5);
							insert_p_customer_product.setInt(1, entry.getUid());
							insert_p_customer_product.setInt(2, entry.getPid());
							insert_p_customer_product.setInt(3, entry.getQuantity() * entry.getPrice());
							result_5 = insert_p_customer_product.executeUpdate();
						}
						conn.commit();
						
						
						update_p_customer_state = conn.prepareStatement(update_6);
						update_p_customer_state.setInt(1, entry.getQuantity() * entry.getPrice());
						update_p_customer_state.setInt(2, entry.getUid());
						result_6 = update_p_customer_state.executeUpdate();
						if(result_6 == 0)
						{
							insert_p_customer_state = conn.prepareStatement(insert_6);
							insert_p_customer_state.setInt(1, entry.getUid());
							insert_p_customer_state.setString(2, entry.getState());
							insert_p_customer_state.setInt(3, entry.getQuantity() * entry.getPrice());
							insert_p_customer_state.setString(4, entry.getUname());
							result_6 = insert_p_customer_state.executeUpdate();
						}
						
						conn.commit();
						
						
					}
					
				
					try{
					
							conn.setAutoCommit(false);
							/**record log,i.e., sales table**/
							stmt.execute(SQL_copy);
							stmt.execute(SQL);
							conn.commit();
							
							conn.setAutoCommit(true);
							out.println("Dear customer '"+uName+"', Thanks for your purchasing.<br> Your card '"+card+"' has been successfully proved. <br>We will ship the products soon.");
							out.println("<br><font size=\"+2\" color=\"#990033\"> <a href=\"products_browsing.jsp\" target=\"_self\">Continue purchasing</a></font>");
					}
					catch(Exception e)
					{
						out.println("Fail! Please try again <a href=\"purchase.jsp\" target=\"_self\">Purchase page</a>.<br><br>");
						
					}
					conn.close();
				}
				catch(Exception e)
				{
						out.println("<font color='#ff0000'>Error.<br><a href=\"purchase.jsp\" target=\"_self\"><i>Go Back to Purchase Page.</i></a></font><br>");
						
				}
			}
			else
			{
			
				out.println("Fail! Please input valid credit card numnber.  <br> Please <a href=\"purchase.jsp\" target=\"_self\">buy it</a> again.");
			}
		}
	catch(Exception e) 
	{ 
		out.println("Fail! Please input valid credit card numnber.  <br> Please <a href=\"purchase.jsp\" target=\"_self\">buy it</a> again.");
	}
%>
	
	</font><br>
</td></tr>
</table>
</div>
</body>
</html>
<%}%>