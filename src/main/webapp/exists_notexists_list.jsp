<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	int currentPage = 1; //시작 페이지
	if(request.getParameter("currentPage") != null) {
	  currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	  
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn);
	 
	int totalRow = 0; //전체 행 수
	String totalRowSql = "select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()) {
	   totalRow = totalRowRs.getInt(1); // totalRowRs.getInt("count(*)")
	}
	  
	int rowPerPage = 10; //한페이지에 출력할 행 수
	int beginRow = (currentPage-1) * rowPerPage + 1;  //한페이지에 출력될 첫번째 행 번호
	int endRow = beginRow + (rowPerPage - 1); //한페이지에 출력될 마지막 행 번호
	if(endRow > totalRow) { //마지막페이지의 마지막 행 번호 > 전체 행 수
	   endRow = totalRow;	//--> 마지막 행 번호 = 전체 행 수
	}
	//페이지 네비게이션 페이징
	/*	currentPage 	minPage				~ maxPage
		1				1=(1-1)/10*10+1 	~ 10
		2				1=(2-1)/10*10+1		~ 10
		10				1=(10-1)/10*10+1	~ 10
			 
		11				11					~ 20
		12				11					~ 20
		20				11					~ 20
			
		minPage	= (cp - 1) / pagePerPage * pagePerPage + 1
		maxPage = minPage + ( pagePerPage - 1 )
		maxPage > lastPage --> maxPage = lastPage
	*/		
			
	int lastPage = totalRow / rowPerPage; //마지막페이지
	if(totalRow % rowPerPage != 0){
		lastPage += 1;
	}
	
	int pagePerPage = 5; //페이지당 출력할 페이징 버튼 수
	
	int minPage	= (currentPage - 1) / pagePerPage * pagePerPage + 1; //페이징 버튼 시작 값
	int maxPage = minPage+(pagePerPage - 1); //페이징 버튼 종료 값
	if(maxPage > lastPage){ //마지막페이지의 페이징버튼종료값 > 마지막페이지
		maxPage = lastPage; //--> 페이징버튼종료값 = 마지막페이지
	}
	
	/*
		select 번호, 사원ID, 이름
		from
			(select rownum 번호, e.employee_id 사원ID, e.first_name 이름
				from employees e 
				where exists (select * from departments d where d.department_id = e.department_id))
		where 번호 between ? and ?
	*/
	String sql = "select 번호, 사원ID, 이름 from (select rownum 번호, e.employee_id 사원ID, e.first_name 이름 from employees e where exists (select * from departments d where d.department_id = e.department_id)) where 번호 between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	ResultSet rs = stmt.executeQuery();
	  
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
	   HashMap<String, Object> m = new HashMap<String, Object>();
	   m.put("번호", rs.getInt("번호"));
	   m.put("사원ID", rs.getInt("사원ID"));
	   m.put("이름", rs.getString("이름"));
	   list.add(m);
	}
	System.out.println(list.size() + " <- list.size()");
	
	/*
		select e.employee_id 사원ID, e.first_name 이름
		from employees e 
		where not exists (select * from departments d where d.department_id = e.department_id)
	*/
	String sql2 = "select e.employee_id 사원ID, e.first_name 이름 from employees e where not exists (select * from departments d where d.department_id = e.department_id)";
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	ResultSet rs2 = stmt2.executeQuery();
	ArrayList<HashMap<String, Object>> list2 = new ArrayList<>();
	while(rs2.next()) {
	   HashMap<String, Object> m2 = new HashMap<String, Object>();
	   m2.put("사원ID", rs2.getInt("사원ID"));
	   m2.put("이름", rs2.getString("이름"));
	   list2.add(m2);
	}
	System.out.println(list2.size() + " <- list2.size()");

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>exists_notexists_list.jsp</title>
<style>
	table, td, th {
	  border : 1px solid black;
	  border-collapse : collapse;
	};
</style>
</head>
<body>
	<h1>exists list</h1>
	<table>
		<tr>
			<td>사원ID</td>
			<td>이름</td>
		</tr>
		<%
			for(HashMap<String,Object> m :list){
				%>
				<tr>
					<td><%=(Integer)m.get("사원ID") %></td>
					<td><%=(String)m.get("이름") %></td>
				</tr>
				<%
			}
		%>
	</table>
	<!-- 페이징 -->
	<%
		if(minPage > 1){
	%>
			<a href="./exists_notexists_list.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	<%
		}
		for(int i = minPage; i<=maxPage; i=i+1){
			if(i == currentPage){
	%>
				<span><%=i %></span>&nbsp;
	<%
			}else{
	%>
				<a href="./exists_notexists_list.jsp?currentPage=<%=i%>"><%=i %></a>&nbsp;
	<%
			}
		}
		if(maxPage != lastPage){
	%>
			<!-- minPage+pagePerPage = maxPage+1 -->
			<a href="./exists_notexists_list.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%
		}	
	%>
	
	<h1>not exists list</h1>
	<table>
		<tr>
			<td>사원ID</td>
			<td>이름</td>
		</tr>
		<%
			for(HashMap<String,Object> m2 :list2){
				%>
				<tr>
					<td><%=(Integer)m2.get("사원ID") %></td>
					<td><%=(String)m2.get("이름") %></td>
				</tr>
				<%
			}
		%>
	</table>
</body>
</html>