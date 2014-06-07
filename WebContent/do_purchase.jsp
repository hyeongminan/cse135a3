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
		private float price=0f;
		private String uname=null;
		private String pname=null;
		private String state=null;
		public Sale(){
		//default constructor
		}
		public Sale(int userid, int productid, int q, float p ) {
			uid = userid;
			pid = productid;
			quantity = q;
			price = p;
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
		public float getPrice(){
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
					
					ResultSet rs = stmt.executeQuery("select c.uid, c.pid, c.quantity, c.price from carts c where c.uid="+userID+";");
					ArrayList<Sale> sales = new ArrayList<Sale>();
					while(rs.next()){
						Sale sale = new Sale(rs.getInt(1),rs.getInt(2),rs.getInt(3),rs.getFloat(4)); 
						sales.add(sale);
					}
					
					PreparedStatement update_p_category_customer_state = null;
					PreparedStatement update_p_category_product = null;
					PreparedStatement update_p_category_product_state = null;
					PreparedStatement update_p_category_state = null;
					PreparedStatement update_p_customer_product = null;
					PreparedStatement update_p_customer_state = null;
					
					String update_1 = "update p_category_customer_state set agg = agg + ? where uid = ? and cid = ;";
		
					String update_2 = "";
					String update_3 = "";
					String update_4 = "";
					String update_5 = "";
					String update_6 = "";
					
					for(int i = 0; i < sales.size(); i++)
					{
						update_p_category_customer_state = conn.prepareStatement(update_1);
						update_p_category_customer_state.executeUpdate();
						
						update_p_category_product = conn.prepareStatement(update_2);
						update_p_category_product_state = conn.prepareStatement(update_3);
						update_p_category_state = conn.prepareStatement(update_4);
						update_p_customer_product = conn.prepareStatement(update_5);
						update_p_customer_state = conn.prepareStatement(update_6);
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