<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }
    
    // Determine which dashboard to link back to
    String dashboardLink = "STUDENT".equals(user.getRole()) ? "student_dashboard.jsp" : "dashboard.jsp";
    
    // Check if user is STAFF or ADMIN - they should use staff_profile.jsp instead
    if ("STAFF".equals(user.getRole()) || "ADMIN".equals(user.getRole())) {
        response.sendRedirect("staff_profile.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head><title>My Profile</title></head>
<body>
    <h2>My Profile (<%= user.getRole() %>)</h2>
    <a href="<%= dashboardLink %>">Back to Dashboard</a>
    <hr>
    <p style="color:green;">${param.msg}</p>

    <form action="UserServlet" method="post">
        <input type="hidden" name="action" value="updateProfile">
        <%
            Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                if ("DONOR".equals(user.getRole())) {
                    ps = con.prepareStatement("SELECT * FROM Donors WHERE email = ?");
                } else if ("STUDENT".equals(user.getRole())) {
                    ps = con.prepareStatement("SELECT * FROM Students WHERE student_id = ?");
                }
                ps.setString(1, user.getLoginId());
                rs = ps.executeQuery();
                
                if (rs.next()) {
        %>
            Login ID: <input type="text" value="<%= user.getLoginId() %>" readonly style="background:#eee;"><br><br>
            Name: <input type="text" name="name" value="<%= rs.getString("name") %>" required><br><br>
            <% if ("STUDENT".equals(user.getRole())) { %>
                Email: <input type="email" name="email" value="<%= rs.getString("email") %>" required><br><br>
            <% } %>
            Phone Number: <input type="text" name="phone" value="<%= rs.getString("phone_num") %>" required><br><br>
            Change Password: <input type="text" name="password" value="<%= rs.getString("password") %>" required><br><br>
        <%      }
            } catch (Exception e) { e.printStackTrace(); } finally { 
                if (rs != null) try { rs.close(); } catch(SQLException e) {}
                if (ps != null) try { ps.close(); } catch(SQLException e) {}
                if (con != null) try { con.close(); } catch(SQLException e) {}
            }
        %>
        <button type="submit">Update Profile</button>
    </form>
    <br><br><hr>
    
    <h3 style="color:red;">Danger Zone</h3>
    <p>Deleting your profile is permanent. <% if("STUDENT".equals(user.getRole())) out.print("All your pending voucher requests will be deleted."); else out.print("Your previous donations will become anonymous."); %></p>
    
    <a href="UserServlet?action=deleteProfile&role=<%= user.getRole() %>&id=<%= user.getLoginId() %>" 
       onclick="return confirm('Are you absolutely sure you want to delete your profile? This cannot be undone.');" 
       style="color:red; font-weight:bold;">DELETE MY ACCOUNT</a>

</body>
</html>