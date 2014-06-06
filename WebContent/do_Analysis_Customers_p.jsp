<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" import="java.util.*" errorPage="" %>
<%@ page import="cse135.Util" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CSE135</title>
<script type="text/javascript" src="js/js.js" language="javascript"></script>
</head>

<body>

<%
	ArrayList<Integer> p_list=new ArrayList<Integer>();//product ID, 10
	ArrayList<Integer> u_list=new ArrayList<Integer>();//customer ID,20
	ArrayList<String> p_name_list=new ArrayList<String>();//product ID, 10
	ArrayList<String> u_name_list=new ArrayList<String>();//customer ID,20
	HashMap<Integer, Integer> product_ID_amount	=	new HashMap<Integer, Integer>();
	HashMap<Integer, Integer> customer_ID_amount=	new HashMap<Integer, Integer>();

	String  state=null, category=null, age=null;
	try { 
			state     =	request.getParameter("state"); 
			category  =	request.getParameter("category");		
	}
	catch(Exception e) 
	{ 
       state=null; category=null;
	}

%>
<%
Connection	conn=null;
Statement 	stmt,stmt2;
ResultSet 	rs=null;
String  	SQL_1=null,SQL_2=null,SQL_ut=null, SQL_pt=null, SQL_3=null;
String  	SQL_amount_row=null,SQL_amount_col=null,SQL_amount_cell=null;
int 		p_id=0,u_id=0;
String		p_name=null,u_name=null;
int 		p_amount_price=0,u_amount_price=0;

	
try
{
	try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
    conn=DriverManager.getConnection("jdbc:postgresql://" +
	    	Util.SERVERNAME + ":" +
	    	Util.PORTNUMBER + "/" +
	    	Util.DATABASE,
	    	Util.USERNAME,
	    	Util.PASSWORD);
	stmt =conn.createStatement();
	stmt2 =conn.createStatement();
	
	
	if(("All").equals(state) && ("0").equals(category))//0,0
	{
		SQL_1 = "select uid, agg, uname from p_customer_state order by agg desc limit 20;";
		SQL_2 = "select pid, agg, pname from p_category_product order by agg desc limit 10;";
		SQL_ut = "select uid from p_customer_state order by agg desc limit 20;";
		SQL_pt = "select pid from p_category_product order by agg desc limit 10;";
	}	
	if(("All").equals(state) && !("0").equals(category))//0,1
	{
		SQL_1 = "select uid, agg, uname from p_category_customer_state where cid = "+ category +" order by agg desc limit 20;";
		SQL_2 = "select pid, agg, pname from p_category_product where cid = "+ category +" order by agg desc limit 10;";
		SQL_ut = "select uid from p_category_customer_state where cid = "+ category +" order by agg desc limit 20;";
		SQL_pt = "select pid from p_category_product where cid = "+ category +" order by agg desc limit 10;";
	}
	if(!("All").equals(state) && ("0").equals(category))//1,0
	{
		SQL_1 = "select uid, agg, uname from p_customer_state where state = '"+ state +"' order by agg desc limit 20;";
		SQL_2 = "select pid, agg, pname from p_category_product_state where state = '"+ state +"' order by agg desc limit 10;";
		SQL_ut = "select uid from p_customer_state where state = '"+ state +"' order by agg desc limit 20;";
		SQL_pt = "select pid from p_category_product_state where state = '"+ state +"' order by agg desc limit 10;";
	}
	if(!("All").equals(state) && !("0").equals(category))//1,1
	{
		SQL_1 = "select uid, agg, uname from p_category_customer_state where state = '"+ state +"' and cid = "+ category +" order by agg desc limit 20;";
		SQL_2 = "select pid, agg, pname from p_category_product_state where state = '"+ state +"' and cid = "+ category +" order by agg desc limit 10;";
		SQL_ut = "select uid from p_category_customer_state where state = '"+ state +"' and cid = "+ category +" order by agg desc limit 20;";
		SQL_pt = "select pid from p_category_product_state where state = '"+ state +"' and cid = "+ category +" order by agg desc limit 10;";
	}
	
	SQL_ut="insert into u_t (id) "+SQL_ut;
	SQL_pt="insert into p_t (id) "+SQL_pt;
	
	//customer name
	rs=stmt.executeQuery(SQL_1);
	while(rs.next())
	{
		u_list.add(rs.getInt(1));
		customer_ID_amount.put(rs.getInt(1), rs.getInt(2));
		u_name_list.add(rs.getString(3));
		  
	}

	//product name
	rs=stmt.executeQuery(SQL_2);
	while(rs.next())
	{
		p_list.add(rs.getInt(1));
		product_ID_amount.put(rs.getInt(1), rs.getInt(2));
		p_name_list.add(rs.getString(3));
		  
	}
	
	
	//cells
	conn.setAutoCommit(false);
	stmt2.execute("CREATE TEMP TABLE p_t (id int)ON COMMIT DELETE ROWS;");
	stmt2.execute("CREATE TEMP TABLE u_t (id int)ON COMMIT DELETE ROWS;");
	//customer tempory table
	stmt2.execute(SQL_ut);
	//product tempory table
	stmt2.execute(SQL_pt);
	
	SQL_3 = "select uid, pid, agg from p_customer_product, p_t pt, u_t ut where pt.id = pid and ut.id = uid";
	rs=stmt.executeQuery(SQL_3);
	
	
%>	

	<table align="center" width="100%" border="1">
		<tr align="center">
			<td width="12%"><table align="center" width="100%" border="0"><tr align="center"><td><strong><font size="+2" color="#FF00FF">CUSTOMER</font></strong></td></tr></table></td>
			<td width="88%">
				<table align="center" width="100%" border="1">
					<tr align="center">
<%	
	int amount_show=0;
	for(int i=0;i<p_list.size();i++)
	{
		p_id			=   p_list.get(i);
		p_name			=	p_name_list.get(i);
		if(product_ID_amount.get(p_id)!=null)
		{
			amount_show=(Integer)product_ID_amount.get(p_id);
			if(amount_show!=0)
			{
				out.print("<td width='10%'><strong>"+p_name+"<br>(<font color='#0000ff'>$"+amount_show+"</font>)</strong></td>");
			}
			else
			{
				out.print("<td width='10%'><strong>"+p_name+"<br>(<font color='#ff0000'>$0</font>)</strong></td>");
			}	
		}
		else
		{
			out.print("<td width='10%'><strong>"+p_name+"<br>(<font color='#ff0000'>$0</font>)</strong></td>");
		}
	}
%>
										</tr>
				</table>
			</td>
		</tr>
	</table>
	
<table align="center" width="100%" border="1">
<tr><td width="12%">
	
	<table align="center" width="100%" border="1">
<%	
		for(int i=0;i<u_list.size();i++)
		{
			u_id			=	u_list.get(i);
			u_name			=	u_name_list.get(i);
			if(customer_ID_amount.get(u_id)!=null)
			{
				amount_show=(Integer)customer_ID_amount.get(u_id);
				if(amount_show!=0)
				{
					out.println("<tr align=\"center\"><td width=\"10%\"><strong>"+u_name+"(<font color='#0000ff'>$"+amount_show+"</font>)</strong></td></tr>");
				}
				else
				{
					out.println("<tr align=\"center\"><td width=\"10%\"><strong>"+u_name+"(<font color='#ff0000'>$0</font>)</strong></td></tr>");
				}	
			}
			else
			{
				out.println("<tr align=\"center\"><td width=\"10%\"><strong>"+u_name+"(<font color='#ff0000'>$0</font>)</strong></td></tr>");
			}
		}
	%>
	</table>
</td>
<td width="88%">	
 
	<table align="center" width="100%" border="1">
<%	
	boolean empty_flag = !rs.next();
	for(int i=0;i<u_list.size();i++)
	{
		out.println("<tr  align='center'>");
		for(int j=0;j<p_list.size();j++)
		{
				if(!empty_flag && rs.getInt(1) == u_list.get(i) && rs.getInt(2) == p_list.get(j))
				{
					out.println("<td width=\"10%\"><font color='#0000ff'><b>"+rs.getInt(3)+"</b></font></td>");
					empty_flag = !rs.next();
				}
				else
					out.println("<td width=\"10%\"><font color='#ff0000'>0</font></td>");
		}
		out.println("</tr>");
	}
%>

	</table>
	
</td>
</tr>
</table>	

<%
	conn.commit();
	conn.setAutoCommit(true);
	conn.close();
}
catch(Exception e)
{
  out.println("Fail! Please connect your database first.");
}
%>	

</body>
</html>