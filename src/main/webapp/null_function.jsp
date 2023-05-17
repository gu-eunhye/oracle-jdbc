<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	/*
		select 이름, nvl(일분기, 0) from 실적
		select 이름, nvl2(일분기, 'success', 'fail') from 실적
		select 이름, nullif(사분기, 100) from 실적
		select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) from 실적
	*/
	
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl,dbuser,dbpw);
	System.out.println(conn);
	
	
	String sql = "select 이름, nvl(일분기, 0) nvl from 실적";
	PreparedStatement stmt = conn.prepareStatement(sql);
	System.out.println(stmt);
	
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String,Object>> list = new ArrayList<>(); //new ArrayList<HashMap<String,Object>>(); 생략가능
	while(rs.next()){
		HashMap<String , Object> m = new HashMap<String,Object>();
		m.put("이름", rs.getString("이름"));
		m.put("nvl", rs.getInt("nvl"));
		list.add(m);
	}
	System.out.println(list.size()+"<-- nvl size()");
	
	String sql2 = "select 이름, nvl2(일분기, 'success', 'fail') nvl2 from 실적";
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	System.out.println(stmt2);
	
	ResultSet rs2 = stmt2.executeQuery();
	ArrayList<HashMap<String,Object>> list2 = new ArrayList<>(); //new ArrayList<HashMap<String,Object>>(); 생략가능
	while(rs2.next()){
		HashMap<String , Object> m2 = new HashMap<String,Object>();
		m2.put("이름", rs2.getString("이름"));
		m2.put("nvl2", rs2.getString("nvl2"));
		list2.add(m2);
	}
	System.out.println(list2.size()+"<-- nvl2 size()");
	
	
	String sql3 = "select 이름, nullif(사분기, 100) nullif from 실적";
	PreparedStatement stmt3 = conn.prepareStatement(sql3);
	System.out.println(stmt3);
	
	ResultSet rs3 = stmt3.executeQuery();
	ArrayList<HashMap<String,Object>> list3 = new ArrayList<>(); //new ArrayList<HashMap<String,Object>>(); 생략가능
	while(rs3.next()){
		HashMap<String , Object> m3 = new HashMap<String,Object>();
		m3.put("이름", rs3.getString("이름"));
		m3.put("nullif", rs3.getString("nullif"));
		list3.add(m3);
	}
	System.out.println(list3.size()+"<-- nullif size()");
	
	String sql4 = "select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) coalesce from 실적";
	PreparedStatement stmt4 = conn.prepareStatement(sql4);
	System.out.println(stmt4);
	
	ResultSet rs4 = stmt4.executeQuery();
	ArrayList<HashMap<String,Object>> list4 = new ArrayList<>(); //new ArrayList<HashMap<String,Object>>(); 생략가능
	while(rs4.next()){
		HashMap<String , Object> m4 = new HashMap<String,Object>();
		m4.put("이름", rs4.getString("이름"));
		m4.put("coalesce", rs4.getInt("coalesce"));
		list4.add(m4);
	}
	System.out.println(list4.size()+"<-- coalesce size()");
	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
	table, td, th {
	  border : 1px solid black;
	  border-collapse : collapse;
	};
</style>
</head>
<body>
	<h1>NULL Function Test</h1>
		<h4>1.select 이름, nvl(일분기, 0) from 실적; </h4>
		<table>
			<%
				for(HashMap<String, Object> m : list){
			%>
					<tr>
						<td><%=m.get("이름") %></td>
						<td><%=(Integer)(m.get("nvl")) %></td>
					</tr>
			<%
				}
			%>
		</table>
		
		<h4>2.select 이름, nvl2(일분기, 'success', 'fail') from 실적;</h4>
		<table>
			<%
				for(HashMap<String, Object> m2 : list2){
			%>
					<tr>
						<td><%=m2.get("이름") %></td>
						<td><%=m2.get("nvl2") %></td>
					</tr>
			<%
				}
			%>
		</table>
		
		<h4>3.select 이름, nullif(사분기, 100) from 실적;</h4>
		<table>
			<%
				for(HashMap<String, Object> m3 : list3){
			%>
					<tr>
						<td><%=m3.get("이름") %></td>
						<td><%=m3.get("nullif") %></td>
					</tr>
			<%
				}
			%>
		</table>
		
		<h4>4.select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) from 실적;</h4>
		<table>
			<%
				for(HashMap<String, Object> m4 : list4){
			%>
					<tr>
						<td><%=m4.get("이름") %></td>
						<td><%=(Integer)(m4.get("coalesce")) %></td>
					</tr>
			<%
				}
			%>
		</table>
</body>
</html>