<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    
    // Allow STAFF and ADMIN only
    if (user == null || (!"STAFF".equals(user.getRole()) && !"ADMIN".equals(user.getRole()))) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }
%>
<!DOCTYPE html>
<html>
<head><title>Staff Profile</title></head>
<body>
    <h2>My Staff Profile</h2>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <hr>
    <p style="color:green;">${param.msg}</p>
    
    <form action="UserServlet" method="post">
        <input type="hidden" name="action" value="updateProfile">
        <input type="hidden" name="role" value="<%= user.getRole() %>">
        
        <%
            Connection con = null; 
            PreparedStatement ps = null; 
            ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement("SELECT * FROM Staff WHERE staff_id = ?");
                ps.setString(1, user.getLoginId());
                rs = ps.executeQuery();
                
                if (rs.next()) {
        %>
            Staff ID: <input type="text" value="<%= rs.getString("staff_id") %>" readonly style="background:#eee;"><br><br>
            Role: <input type="text" value="<%= rs.getString("role") %>" readonly style="background:#eee;"><br><br>
            Change Password: <input type="text" name="password" value="<%= rs.getString("password") %>" required><br><br>
        <%      }
            } catch (Exception e) { 
                e.printStackTrace(); 
            } finally {
                if (rs != null) try { rs.close(); } catch(SQLException e) {}
                if (ps != null) try { ps.close(); } catch(SQLException e) {}
                if (con != null) try { con.close(); } catch(SQLException e) {}
            }
        %>
        
        <button type="submit">Update Password</button>
    </form>
    
    <br><br><hr>
    <h3 style="color:red;">Danger Zone</h3>
    <p>Deleting your staff account is permanent.</p>
    
    <a href="UserServlet?action=deleteProfile&role=<%= user.getRole() %>&id=<%= user.getLoginId() %>" 
       onclick="return confirm('Are you absolutely sure you want to delete your staff account? This cannot be undone.');" 
       style="color:red; font-weight:bold;">DELETE MY ACCOUNT</a>
</body>
</html>