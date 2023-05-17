<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	/*
		select department_id, job_id, count(*) from employees
		group by department_id, job_id
		
		select department_id, job_id, count(*) from employees
		group by rollup(department_id, job_id) 
		
		select department_id, job_id, count(*) from employees
		group by cube(department_id, job_id) 
		
	*/
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl,dbuser,dbpw);
	System.out.println(conn);
	
	
	String sql = "select department_id 부서ID, job_id 직무ID, count(*) cnt from employees group by department_id, job_id";
	PreparedStatement stmt = conn.prepareStatement(sql);
	System.out.println(stmt);
	
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String,Object>> list = new ArrayList<>(); //new ArrayList<HashMap<String,Object>>(); 생략가능
	while(rs.next()){
		HashMap<String , Object> m = new HashMap<String,Object>();
		m.put("부서ID", rs.getInt("부서ID"));
		m.put("직무ID", rs.getString("직무ID"));
		m.put("cnt", rs.getInt("cnt"));
		list.add(m);
	}
	System.out.println(list.size()+"<-- group_by size()");
	
	
	String sql2 = "select department_id 부서ID, job_id 직무ID, count(*) cnt from employees group by rollup(department_id, job_id)";
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	System.out.println(stmt2);
	
	ResultSet rs2 = stmt2.executeQuery();
	ArrayList<HashMap<String,Object>> list2 = new ArrayList<>(); //new ArrayList<HashMap<String,Object>>(); 생략가능
	while(rs2.next()){
		HashMap<String , Object> m2 = new HashMap<String,Object>();
		m2.put("부서ID", rs2.getInt("부서ID"));
		m2.put("직무ID", rs2.getString("직무ID"));
		m2.put("cnt", rs2.getInt("cnt"));
		list2.add(m2);
	}
	System.out.println(list2.size()+"<-- rollup size()");
	
	
	String sql3 = "select department_id 부서ID, job_id 직무ID, count(*) cnt from employees group by cube(department_id, job_id)";
	PreparedStatement stmt3 = conn.prepareStatement(sql3);
	System.out.println(stmt3);
	
	ResultSet rs3 = stmt3.executeQuery();
	ArrayList<HashMap<String,Object>> list3 = new ArrayList<>(); //new ArrayList<HashMap<String,Object>>(); 생략가능
	while(rs3.next()){
		HashMap<String , Object> m3 = new HashMap<String,Object>();
		m3.put("부서ID", rs3.getInt("부서ID"));
		m3.put("직무ID", rs3.getString("직무ID"));
		m3.put("cnt", rs3.getInt("cnt"));
		list3.add(m3);
	}
	System.out.println(list3.size()+"<-- cube size()");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>group_by_function.jsp</title>
<style>
	table, td, th {
	  border : 1px solid black;
	  border-collapse : collapse;
	};
</style>
</head>
<body>
	<h1>Employees table Group By function Test</h1>
		<h2>group by</h2>
		<table>
			<tr>
				<td>부서ID</td>
				<td>직무ID</td>
				<td>cnt</td>
			</tr>
			<%
				for(HashMap<String, Object> m : list){
			%>
					<tr>
						<td><%=(Integer)(m.get("부서ID")) %></td>
						<td><%=m.get("직무ID") %></td>
						<td><%=(Integer)(m.get("cnt")) %></td>
					</tr>
			<%
				}
			%>
		</table>
		
		<h2>group by rollup</h2>
		<table border="1">
			<tr>
				<td>부서ID</td>
				<td>직무ID</td>
				<td>cnt</td>
			</tr>
			<%
				for(HashMap<String, Object> m2 : list2){
			%>
					<tr>
						<td><%=(Integer)(m2.get("부서ID")) %></td>
						<td><%=m2.get("직무ID") %></td>
						<td><%=(Integer)(m2.get("cnt")) %></td>
					</tr>
			<%
				}
			%>
		</table>
		
		<h2>group by cube</h2>
		<table border="1">
			<tr>
				<td>부서ID</td>
				<td>직무ID</td>
				<td>cnt</td>
			</tr>
			<%
				for(HashMap<String, Object> m3 : list3){
			%>
					<tr>
						<td><%=(Integer)(m3.get("부서ID")) %></td>
						<td><%=m3.get("직무ID") %></td>
						<td><%=(Integer)(m3.get("cnt")) %></td>
					</tr>
			<%
				}
			%>
		</table>
</body>
</html>