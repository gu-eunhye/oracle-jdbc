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
	int rowPerPage = 5; //한페이지에 출력할 행 수
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

	/* rank + ntile
		select 번호, 이름, 연봉, 순위, 등급 
		from (select rownum 번호, 이름, 연봉, 순위, 등급
				from(select first_name 이름, salary 연봉, rank() over(order by salary desc) 순위, ntile(10) over (order by salary desc) 등급
						from employees))
		where 번호 between ? and ?
	*/
	String sql = "select 번호, 이름, 연봉, 순위, 등급 from (select rownum 번호, 이름, 연봉, 순위, 등급 from(select first_name 이름, salary 연봉, rank() over(order by salary desc) 순위, ntile(10) over (order by salary desc) 등급 from employees)) where 번호 between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	ResultSet rs = stmt.executeQuery();
	  
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
	   HashMap<String, Object> m = new HashMap<String, Object>();
	   m.put("이름", rs.getString("이름"));
	   m.put("연봉", rs.getInt("연봉"));
	   m.put("순위", rs.getInt("순위"));
	   m.put("등급", rs.getInt("등급"));
	   list.add(m);
	}
	System.out.println(list.size() + " <- list.size()");
	
	
	//dense rank 페이징 변수****************************************************************************
	int currentPage2 = 1; //시작 페이지
	if(request.getParameter("currentPage2") != null) {
	  currentPage2 = Integer.parseInt(request.getParameter("currentPage2"));
	}
	int beginRow2 = (currentPage2-1) * rowPerPage + 1;  //한페이지에 출력될 첫번째 행 번호
	int endRow2 = beginRow2 + (rowPerPage - 1); //한페이지에 출력될 마지막 행 번호
	if(endRow2 > totalRow) { //마지막페이지의 마지막 행 번호 > 전체 행 수
	   endRow2 = totalRow;	//--> 마지막 행 번호 = 전체 행 수
	}
	int minPage2 = (currentPage2 - 1) / pagePerPage * pagePerPage + 1; //페이징 버튼 시작 값
	int maxPage2 = minPage2+(pagePerPage - 1); //페이징 버튼 종료 값
	if(maxPage2 > lastPage){ //마지막페이지의 페이징버튼종료값 > 마지막페이지
		maxPage2 = lastPage; //--> 페이징버튼종료값 = 마지막페이지
	}
	/* dense rank
		select 번호, 이름, 연봉, denserank
		from (select rownum 번호, 이름, 연봉, denserank 
				from (select first_name 이름, salary 연봉, dense_rank() over(order by salary desc) denserank 
						from employees))
		where 번호 between ? and ?
	*/
	String sql2 = "select 번호, 이름, 연봉, denserank from (select rownum 번호, 이름, 연봉, denserank from (select first_name 이름, salary 연봉, dense_rank() over(order by salary desc) denserank from employees)) where 번호 between ? and ?";
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	stmt2.setInt(1, beginRow2);
	stmt2.setInt(2, endRow2);
	ResultSet rs2 = stmt2.executeQuery();
	
	ArrayList<HashMap<String, Object>> list2 = new ArrayList<>();
	while(rs2.next()) {
	   HashMap<String, Object> m2 = new HashMap<String, Object>();
	   m2.put("이름", rs2.getString("이름"));
	   m2.put("연봉", rs2.getInt("연봉"));
	   m2.put("denserank", rs2.getInt("denserank"));
	   list2.add(m2);
	}
	System.out.println(list2.size() + " <- list2.size()");
	
	
	//row number 페이징 변수****************************************************************************
	int currentPage3 = 1; //시작 페이지
	if(request.getParameter("currentPage3") != null) {
	  currentPage3 = Integer.parseInt(request.getParameter("currentPage3"));
	}
	int beginRow3 = (currentPage3-1) * rowPerPage + 1;  //한페이지에 출력될 첫번째 행 번호
	int endRow3 = beginRow3 + (rowPerPage - 1); //한페이지에 출력될 마지막 행 번호
	if(endRow3 > totalRow) { //마지막페이지의 마지막 행 번호 > 전체 행 수
	   endRow3 = totalRow;	//--> 마지막 행 번호 = 전체 행 수
	}
	int minPage3 = (currentPage3 - 1) / pagePerPage * pagePerPage + 1; //페이징 버튼 시작 값
	int maxPage3 = minPage3+(pagePerPage - 1); //페이징 버튼 종료 값
	if(maxPage3 > lastPage){ //마지막페이지의 페이징버튼종료값 > 마지막페이지
		maxPage3 = lastPage; //--> 페이징버튼종료값 = 마지막페이지
	}
	
	/*
		select 이름, 연봉, rownumber 
		from (select first_name 이름, salary 연봉, row_number() over(order by salary desc) rownumber from employees)
		where rownumber between ? and ?
	*/
	String sql3 = "select 이름, 연봉, rownumber from (select first_name 이름, salary 연봉, row_number() over(order by salary desc) rownumber from employees) where rownumber between ? and ?";
	PreparedStatement stmt3 = conn.prepareStatement(sql3);
	stmt3.setInt(1, beginRow3);
	stmt3.setInt(2, endRow3);
	ResultSet rs3 = stmt3.executeQuery();
	
	ArrayList<HashMap<String, Object>> list3 = new ArrayList<>();
	while(rs3.next()) {
	   HashMap<String, Object> m3 = new HashMap<String, Object>();
	   m3.put("이름", rs3.getString("이름"));
	   m3.put("연봉", rs3.getInt("연봉"));
	   m3.put("rownumber", rs3.getInt("rownumber"));
	   list3.add(m3);
	}
	System.out.println(list3.size() + " <- list3.size()");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>rank_ntile_list.jsp</title>
<style>
	table, td, th {
	  border : 1px solid black;
	  border-collapse : collapse;
	};
</style>
</head>
<body>
	<!-- ---------------------rank + ntile---------------------- -->
	<h1>rank ntile list</h1>
	<table>
		<tr>
			<td>이름</td>
			<td>연봉</td>
			<td>순위</td>
			<td>등급</td>
		</tr>
		<%
			for(HashMap<String,Object> m :list){
				%>
				<tr>
					<td><%=(String)m.get("이름") %></td>
					<td><%=(Integer)m.get("연봉") %></td>
					<td><%=(Integer)m.get("순위") %></td>
					<td><%=(Integer)m.get("등급") %></td>
				</tr>
				<%
			}
		%>
	</table>
	<!-- rank, ntile 페이징 -->
	<%
		if(minPage > 1){
	%>
			<a href="./rank_ntile_list.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	<%
		}
		for(int i = minPage; i<=maxPage; i=i+1){
			if(i == currentPage){
	%>
				<span><%=i %></span>&nbsp;
	<%
			}else{
	%>
				<a href="./rank_ntile_list.jsp?currentPage=<%=i%>"><%=i %></a>&nbsp;
	<%
			}
		}
		if(maxPage != lastPage){
	%>
			<a href="./rank_ntile_list.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%
		}	
	%>
	<!-- --------------------- dense rank ---------------------- -->
	<h1>dense rank list</h1>
	<table>
		<tr> 
			<td>이름</td>
			<td>연봉</td>
			<td>denserank</td>
		</tr>
		<%
			for(HashMap<String,Object> m2 :list2){
				%>
				<tr>
					<td><%=(String)m2.get("이름") %></td>
					<td><%=(Integer)m2.get("연봉") %></td>
					<td><%=(Integer)m2.get("denserank") %></td>
				</tr>
				<%
			}
		%>
	</table>
	<!-- dense rank 페이징 -->
	<%
		if(minPage2 > 1){
	%>
			<a href="./rank_ntile_list.jsp?currentPage2=<%=minPage2-pagePerPage%>">이전</a>
	<%
		}
		for(int i = minPage2; i<=maxPage2; i=i+1){
			if(i == currentPage2){
	%>
				<span><%=i %></span>&nbsp;
	<%
			}else{
	%>
				<a href="./rank_ntile_list.jsp?currentPage2=<%=i%>"><%=i %></a>&nbsp;
	<%
			}
		}
		if(maxPage2 != lastPage){
	%>
			<a href="./rank_ntile_list.jsp?currentPage2=<%=minPage2+pagePerPage%>">다음</a>
	<%
		}	
	%>
	<!-- --------------------- row number ---------------------- -->
	<h1>row number list</h1>
	<table>
		<tr> 
			<td>이름</td>
			<td>연봉</td>
			<td>rownumber</td>
		</tr>
		<%
			for(HashMap<String,Object> m3 :list3){
				%>
				<tr>
					<td><%=(String)m3.get("이름") %></td>
					<td><%=(Integer)m3.get("연봉") %></td>
					<td><%=(Integer)m3.get("rownumber") %></td>
				</tr>
				<%
			}
		%>
	</table>
	<!-- row number 페이징 -->
	<%
		if(minPage3 > 1){
	%>
			<a href="./rank_ntile_list.jsp?currentPage3=<%=minPage3-pagePerPage%>">이전</a>
	<%
		}
		for(int i = minPage3; i<=maxPage3; i=i+1){
			if(i == currentPage3){
	%>
				<span><%=i %></span>&nbsp;
	<%
			}else{
	%>
				<a href="./rank_ntile_list.jsp?currentPage3=<%=i%>"><%=i %></a>&nbsp;
	<%
			}
		}
		if(maxPage3 != lastPage){
	%>
			<a href="./rank_ntile_list.jsp?currentPage3=<%=minPage3+pagePerPage%>">다음</a>
	<%
		}	
	%>
</body>
</html>