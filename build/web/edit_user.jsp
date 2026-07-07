<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Security check: Only allow STAFF
    User loggedInUser = (User) session.getAttribute("currentUser");
    if (loggedInUser == null || !"STAFF".equals(loggedInUser.getRole())) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }

    String userId = request.getParameter("id");
    if (userId == null) {
        response.sendRedirect("manage_users.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit User</title>
    <script>
        function toggleStudentFields() {
            var role = document.getElementById("roleSelect").value;
            var studentIdRow = document.getElementById("studentIdRow");
            if (role === "STUDENT") {
                studentIdRow.style.display = "block";
            } else {
                studentIdRow.style.display = "none";
            }
        }
    </script>
</head>
<body onload="toggleStudentFields()">
    <h2>Edit User Information</h2>
    <a href="manage_users.jsp">Back to User List</a>
    <hr>

    <%
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement("SELECT * FROM Users WHERE id = ?");
            ps.setInt(1, Integer.parseInt(userId));
            rs = ps.executeQuery();
            
            if (rs.next()) {
                String currentRole = rs.getString("role");
    %>
    
    <form action="UserServlet" method="post">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
        
        <p><strong>User ID:</strong> <%= rs.getInt("id") %></p>

        Account Type: 
        <select name="role" id="roleSelect" onchange="toggleStudentFields()">
            <option value="STUDENT" <%= "STUDENT".equals(currentRole) ? "selected" : "" %>>Student</option>
            <option value="DONOR" <%= "DONOR".equals(currentRole) ? "selected" : "" %>>Donor</option>
            <option value="STAFF" <%= "STAFF".equals(currentRole) ? "selected" : "" %>>Staff</option>
        </select><br><br>

        Username: <input type="text" name="username" value="<%= rs.getString("username") %>" required><br><br>
        Full Name: <input type="text" name="fullName" value="<%= rs.getString("full_name") %>" required><br><br>
        
        <div id="studentIdRow">
            Student ID: <input type="text" name="studentId" value="<%= !"N/A".equals(rs.getString("student_id")) ? rs.getString("student_id") : "" %>"><br><br>
        </div>
        
        Email: <input type="email" name="email" value="<%= rs.getString("email") %>" required><br><br>
        Phone Number: <input type="text" name="phone" value="<%= rs.getString("phone") %>" required><br><br>
        
        <button type="submit">Save Changes</button>
    </form>

    <%
            } else {
                out.println("<p style='color:red;'>User not found.</p>");
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        } finally {
            if (rs != null) try { rs.close(); } catch(SQLException e) {}
            if (ps != null) try { ps.close(); } catch(SQLException e) {}
            if (con != null) try { con.close(); } catch(SQLException e) {}
        }
    %>
</body>
</html>