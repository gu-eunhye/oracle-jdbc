<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	/*
		select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도
		from
		    (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12,2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 from employees)
		where 번호 between 1 and 10;
	*/
	
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
	  
	String sql = "select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도 from (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12, 2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 from employees) where 번호 between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	ResultSet rs = stmt.executeQuery();
	  
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
	   HashMap<String, Object> m = new HashMap<String, Object>();
	   m.put("번호", rs.getInt("번호"));
	   m.put("이름", rs.getString("이름"));
	   m.put("이름첫글자", rs.getString("이름첫글자"));
	   m.put("연봉", rs.getInt("연봉"));
	   m.put("급여", rs.getDouble("급여"));
	   m.put("입사날짜", rs.getString("입사날짜"));
	   m.put("입사년도", rs.getInt("입사년도"));
	   list.add(m);
	}
	System.out.println(list.size() + " <- list.size()");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>functionEmpList.jsp</title>
<style>
	table, td, th {
	  border : 1px solid black;
	  border-collapse : collapse;
	};
</style>
</head>
<body>
	<table>
		<tr>
			<td>번호</td>
			<td>이름</td>
			<td>이름첫글자</td>
			<td>연봉</td>
			<td>급여</td>
			<td>입사날짜</td>
			<td>입사년도</td>
		</tr>
		<%
			for(HashMap<String,Object> m :list){
				%>
				<tr>
					<td><%=(Integer)m.get("번호") %></td>
					<td><%=(String)m.get("이름") %></td>
					<td><%=(String)m.get("이름첫글자") %></td>
					<td><%=(Integer)m.get("연봉") %></td>
					<td><%=(Double)m.get("급여") %></td>
					<td><%=(String)m.get("입사날짜") %></td>
					<td><%=(Integer)m.get("입사년도") %></td>
				</tr>
				<%
			}
		%>
	</table>
	<%
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
		
		int pagePerPage = 10; //페이지당 출력할 페이징 버튼 수
		
		int minPage	= (currentPage - 1) / pagePerPage * pagePerPage + 1; //페이징 버튼 시작 값
		int maxPage = minPage+(pagePerPage - 1); //페이징 버튼 종료 값
		if(maxPage > lastPage){ //마지막페이지의 페이징버튼종료값 > 마지막페이지
			maxPage = lastPage; //--> 페이징버튼종료값 = 마지막페이지
		}

		if(minPage > 1){
	%>
			<a href="./functionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	<%
		}
		for(int i = minPage; i<=maxPage; i=i+1){
			if(i == currentPage){
	%>
				<span><%=i %></span>&nbsp;
	<%
			}else{
	%>
				<a href="./functionEmpList.jsp?currentPage=<%=i%>"><%=i %></a>&nbsp;
	<%
			}
		}
		if(maxPage != lastPage){
	%>
			<!-- minPage+pagePerPage = maxPage+1 -->
			<a href="./functionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%
		}	
	%>
	
</body>
</html>