<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || (!"STAFF".equals(user.getRole()) && !"ADMIN".equals(user.getRole()))) { 
        response.sendRedirect("index.jsp"); return; 
    }
%>
<!DOCTYPE html>
<html>
<head><title>Manage Students</title></head>
<body>
    <h2>Student Management</h2>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <hr>
    <table border="1" cellpadding="5">
        <tr><th>Student ID</th><th>Name</th><th>Email</th><th>Phone</th><th>Actions</th></tr>
        <%
            Connection con = null;
            Statement stmt = null;
            ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                stmt = con.createStatement();
                rs = stmt.executeQuery("SELECT * FROM Students");
                while(rs.next()){
        %>
            <tr>
                <td><%= rs.getString("student_id") %></td>
                <td><%= rs.getString("name") %></td>
                <td><%= rs.getString("email") %></td>
                <td><%= rs.getString("phone_num") %></td>
                <td>
                    <a href="edit_user.jsp?id=<%= rs.getString("student_id") %>&role=STUDENT">Edit</a> | 
                    <a href="UserServlet?action=delete&role=STUDENT&id=<%= rs.getString("student_id") %>" onclick="return confirm('Delete?');">Delete</a>
                </td>
            </tr>
        <%      }
            } catch(Exception e) { e.printStackTrace(); } 
            finally {
                if(rs != null) try { rs.close(); } catch(SQLException e) {}
                if(stmt != null) try { stmt.close(); } catch(SQLException e) {}
                if(con != null) try { con.close(); } catch(SQLException e) {}
            }
        %>
    </table>
</body>
</html>