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
	ArrayList<String> p_name_list=new ArrayList<String>();//product ID, 10
	ArrayList<String> s_name_list=new ArrayList<String>();//state ID,20
	HashMap<Integer, Integer> product_ID_amount	=	new HashMap<Integer, Integer>();
	HashMap<String, Integer> state_ID_amount=	new HashMap<String, Integer>();

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
String		p_name=null,s_name=null;
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
		SQL_1 = "select state, sum(agg) from p_category_product_state group by state order by sum desc limit 20;";
		SQL_2 = "select pid, agg, pname from p_category_product order by agg desc limit 10;";
		SQL_pt = "select pid from p_category_product order by agg desc limit 10;";
	}	
	if(("All").equals(state) && !("0").equals(category))//0,1
	{
		SQL_1 = "select state, sum(agg) from p_category_state where cid = "+ category +" group by state order by sum desc limit 20;";
		SQL_2 = "select pid, agg, pname from p_category_product where cid = "+ category +" order by agg desc limit 10;";
		SQL_pt = "select pid from p_category_product where cid = "+ category +" order by agg desc limit 10;";
	}
	if(!("All").equals(state) && ("0").equals(category))//1,0
	{
		SQL_1 = "select state, sum(agg) from p_category_product_state where state = '"+ state +"' group by state order by sum desc limit 20;";
		SQL_2 = "select pid, agg, pname from p_category_product_state where state = '"+ state +"' order by agg desc limit 10;";
		SQL_pt = "select pid from p_category_product_state where state = '"+ state +"' order by agg desc limit 10;";
	}
	if(!("All").equals(state) && !("0").equals(category))//1,1
	{
		SQL_1 = "select state, sum(agg) from p_category_state where cid = "+ category +" and state = '"+ state +"' group by state order by sum desc limit 20;";
		SQL_2 = "select pid, agg, pname from p_category_product_state where state = '"+ state +"' and cid = "+ category +" order by agg desc limit 10;";
		SQL_pt = "select pid from p_category_product_state where state = '"+ state +"' and cid = "+ category +" order by agg desc limit 10;";
	}
	
	SQL_ut="insert into u_t (state, sum) "+SQL_1;
	SQL_pt="insert into p_t (id) "+SQL_pt;
	
	//customer name
	rs=stmt.executeQuery(SQL_1);
	while(rs.next())
	{

		s_name_list.add(rs.getString(1));
		state_ID_amount.put(rs.getString(1), rs.getInt(2));
		  
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
	stmt2.execute("CREATE TEMP TABLE u_t (state text, sum int)ON COMMIT DELETE ROWS;");
	//customer tempory table
	stmt2.execute(SQL_ut);
	//product tempory table
	stmt2.execute(SQL_pt);

	SQL_3 = "select p.state, p.pid, p.agg from p_category_product_state p, p_t pt, u_t ut where pt.id = p.pid and ut.state = p.state;";
	rs=stmt.executeQuery(SQL_3);
	
	HashMap<String, Integer> cell_amount = new HashMap<String, Integer>();
	
	while(rs.next ())
	{
		cell_amount.put(rs.getString(1) + rs.getInt(2), rs.getInt(3));
	}
	
	
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

		for(int i=0;i<s_name_list.size();i++)
		{
			s_name			=	s_name_list.get(i);
			if(state_ID_amount.get(s_name)!=null)
			{
				amount_show=(Integer)state_ID_amount.get(s_name);
				if(amount_show!=0)
				{
					out.println("<tr align=\"center\"><td width=\"10%\"><strong>"+s_name+"(<font color='#0000ff'>$"+amount_show+"</font>)</strong></td></tr>");
				}
				else
				{
					out.println("<tr align=\"center\"><td width=\"10%\"><strong>"+s_name+"(<font color='#ff0000'>$0</font>)</strong></td></tr>");
				}	
			}
			else
			{
				out.println("<tr align=\"center\"><td width=\"10%\"><strong>"+s_name+"(<font color='#ff0000'>$0</font>)</strong></td></tr>");
			}
		}

	%>
	</table>
</td>
<td width="88%">	
 
	<table align="center" width="100%" border="1">
<%	

	for(int i=0;i<s_name_list.size();i++)
	{
		out.println("<tr  align='center'>");
		for(int j=0;j<p_list.size();j++)
		{
				if(cell_amount.get(s_name_list.get(i) + p_list.get(j)) != null)
				{
					out.println("<td width=\"10%\"><font color='#0000ff'><b>"+cell_amount.get(s_name_list.get(i) + p_list.get(j))+"</b></font></td>");
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