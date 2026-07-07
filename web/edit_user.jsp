<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Security check: Only allow STAFF or ADMIN
    User loggedInUser = (User) session.getAttribute("currentUser");
    if (loggedInUser == null || (!"STAFF".equals(loggedInUser.getRole()) && !"ADMIN".equals(loggedInUser.getRole()))) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }

    String editId = request.getParameter("id");
    String editRole = request.getParameter("role");
    
    if (editId == null || editRole == null) {
        response.sendRedirect("manage_users.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head><title>Edit User</title></head>
<body>
    <h2>Edit User (<%= editRole %>)</h2>
    <a href="manage_users.jsp">Back to User List</a>
    <hr>

    <form action="UserServlet" method="post">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="role" value="<%= editRole %>">
        <input type="hidden" name="id" value="<%= editId %>">

        <%
            Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                
                // 1. STAFF / ADMIN EDIT FORM
                if ("STAFF".equals(editRole) || "ADMIN".equals(editRole)) {
                    ps = con.prepareStatement("SELECT * FROM Staff WHERE staff_id = ?");
                    ps.setString(1, editId);
                    rs = ps.executeQuery();
                    if (rs.next()) {
        %>
                        Staff ID (Read-Only): <input type="text" value="<%= rs.getString("staff_id") %>" readonly style="background:#eee;"><br><br>
                        Account Role:
                        <select name="newRole" required>
                            <option value="STAFF" <%= "STAFF".equals(rs.getString("role")) ? "selected" : "" %>>General Staff</option>
                            <option value="ADMIN" <%= "ADMIN".equals(rs.getString("role")) ? "selected" : "" %>>Administrator</option>
                        </select><br><br>
                        Change Password: <input type="text" name="password" value="<%= rs.getString("password") %>" required><br><br>
        <%
                    }
                } 
                // 2. DONOR EDIT FORM
                else if ("DONOR".equals(editRole)) {
                    ps = con.prepareStatement("SELECT * FROM Donors WHERE email = ?");
                    ps.setString(1, editId);
                    rs = ps.executeQuery();
                    if (rs.next()) {
        %>
                        Email/Login (Read-Only): <input type="text" value="<%= rs.getString("email") %>" readonly style="background:#eee; width:250px;"><br><br>
                        Full Name: <input type="text" name="name" value="<%= rs.getString("name") %>" required><br><br>
                        Phone Number: <input type="text" name="phone" value="<%= rs.getString("phone_num") %>" required><br><br>
                        Change Password: <input type="text" name="password" value="<%= rs.getString("password") %>" required><br><br>
        <%          }
                }
                // 3. STUDENT EDIT FORM
                else if ("STUDENT".equals(editRole)) {
                    ps = con.prepareStatement("SELECT * FROM Students WHERE student_id = ?");
                    ps.setString(1, editId);
                    rs = ps.executeQuery();
                    if (rs.next()) {
        %>
                        Student ID (Read-Only): <input type="text" value="<%= rs.getString("student_id") %>" readonly style="background:#eee;"><br><br>
                        Full Name: <input type="text" name="name" value="<%= rs.getString("name") %>" required><br><br>
                        Email: <input type="email" name="email" value="<%= rs.getString("email") %>" required><br><br>
                        Phone Number: <input type="text" name="phone" value="<%= rs.getString("phone_num") %>" required><br><br>
                        Change Password: <input type="text" name="password" value="<%= rs.getString("password") %>" required><br><br>
        <%          }
                }
        %>
        <button type="submit">Save Changes</button>
        <%
            } catch (Exception e) { 
                e.printStackTrace(); 
            } finally {
                if (rs != null) try { rs.close(); } catch(SQLException e) {}
                if (ps != null) try { ps.close(); } catch(SQLException e) {}
                if (con != null) try { con.close(); } catch(SQLException e) {}
            }
        %>
    </form>
</body>
</html>