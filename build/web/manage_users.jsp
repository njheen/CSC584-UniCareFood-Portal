<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Security check: Allow BOTH Staff and Admins
    User loggedInUser = (User) session.getAttribute("currentUser");
    if (loggedInUser == null || (!"STAFF".equals(loggedInUser.getRole()) && !"ADMIN".equals(loggedInUser.getRole()))) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }

    // Capture search parameters
    String searchQuery = request.getParameter("q");
    String searchRole = request.getParameter("role");
    
    if (searchQuery == null) searchQuery = "";
    if (searchRole == null) searchRole = "ALL";
    
    String likeQuery = "%" + searchQuery.trim().toLowerCase() + "%";
    boolean hasTextFilter = !searchQuery.trim().isEmpty();
%>
<!DOCTYPE html>
<html>
<head><title>Manage All Users</title></head>
<body>
    <h2>User Management</h2>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <hr>
    
    <p style="color:green;">${param.msg}</p>

    <form action="manage_users.jsp" method="get" style="background-color: #f9f9f9; padding: 10px; border: 1px solid #ccc; display: inline-block;">
        <strong>Filter Users:</strong><br><br>
        
        Role View: 
        <select name="role">
            <option value="ALL" <%= "ALL".equals(searchRole) ? "selected" : "" %>>Show All Tables</option>
            <option value="STUDENT" <%= "STUDENT".equals(searchRole) ? "selected" : "" %>>Students Only</option>
            <option value="DONOR" <%= "DONOR".equals(searchRole) ? "selected" : "" %>>Donors Only</option>
            <option value="STAFF" <%= "STAFF".equals(searchRole) ? "selected" : "" %>>Staff & Admins Only</option>
        </select>
        &nbsp;&nbsp;
        
        Search: 
        <input type="text" name="q" value="<%= searchQuery %>" placeholder="Search ID, Name, or Email" size="30">
        &nbsp;&nbsp;
        
        <button type="submit">Search</button>
        <a href="manage_users.jsp" style="margin-left: 10px;">Clear Filters</a>
    </form>
    <br><br>

    <%
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBConnection.getConnection();
    %>

    <%-------------------------------------------------------------------------
      TABLE 1: STAFF & ADMINS
      Only show if "ALL" or "STAFF" is selected
    -------------------------------------------------------------------------%>
    <% if (searchRole.equals("ALL") || searchRole.equals("STAFF")) { %>
        <h3>Staff & Administrators</h3>
        <table border="1" cellpadding="5" cellspacing="0" width="80%">
            <tr style="background-color: #d9edf7;">
                <th>Staff ID</th>
                <th>Role</th>
                <th>Actions</th>
            </tr>
            <%
                String sqlStaff = "SELECT * FROM Staff WHERE 1=1";
                if (hasTextFilter) sqlStaff += " AND LOWER(staff_id) LIKE ?";
                sqlStaff += " ORDER BY role, staff_id";
                
                ps = con.prepareStatement(sqlStaff);
                if (hasTextFilter) ps.setString(1, likeQuery);
                rs = ps.executeQuery();
                
                boolean hasStaff = false;
                while (rs.next()) {
                    hasStaff = true;
            %>
                <tr>
                    <td><%= rs.getString("staff_id") %></td>
                    <td><strong><%= rs.getString("role") %></strong></td>
                    <td>
                        <a href="edit_user.jsp?id=<%= rs.getString("staff_id") %>&role=<%= rs.getString("role") %>">Edit</a> | 
                        <% if (!loggedInUser.getLoginId().equals(rs.getString("staff_id"))) { %>
                            <a href="UserServlet?action=delete&role=<%= rs.getString("role") %>&id=<%= rs.getString("staff_id") %>" onclick="return confirm('Delete this staff member?');">Delete</a>
                        <% } else { %>
                            <span style="color:gray;">(You)</span>
                        <% } %>
                    </td>
                </tr>
            <%  } 
                if (!hasStaff) out.print("<tr><td colspan='3' style='color:red; text-align:center;'>No staff match your search.</td></tr>");
                rs.close(); ps.close();
            %>
        </table>
        <br>
    <% } %>

    <%-------------------------------------------------------------------------
      TABLE 2: DONORS
      Only show if "ALL" or "DONOR" is selected
    -------------------------------------------------------------------------%>
    <% if (searchRole.equals("ALL") || searchRole.equals("DONOR")) { %>
        <h3>Donors</h3>
        <table border="1" cellpadding="5" cellspacing="0" width="100%">
            <tr style="background-color: #dff0d8;">
                <th>Email (Login ID)</th>
                <th>Name</th>
                <th>Phone Number</th>
                <th>Actions</th>
            </tr>
            <%
                String sqlDonor = "SELECT * FROM Donors WHERE 1=1";
                if (hasTextFilter) sqlDonor += " AND (LOWER(email) LIKE ? OR LOWER(name) LIKE ?)";
                sqlDonor += " ORDER BY name";
                
                ps = con.prepareStatement(sqlDonor);
                if (hasTextFilter) { ps.setString(1, likeQuery); ps.setString(2, likeQuery); }
                rs = ps.executeQuery();
                
                boolean hasDonors = false;
                while (rs.next()) {
                    hasDonors = true;
            %>
                <tr>
                    <td><%= rs.getString("email") %></td>
                    <td><%= rs.getString("name") %></td>
                    <td><%= rs.getString("phone_num") %></td>
                    <td>
                        <a href="edit_user.jsp?id=<%= rs.getString("email") %>&role=DONOR">Edit</a> |
                        <a href="UserServlet?action=delete&role=DONOR&id=<%= rs.getString("email") %>" onclick="return confirm('Delete this donor?');">Delete</a>
                    </td>
                </tr>
            <%  } 
                if (!hasDonors) out.print("<tr><td colspan='4' style='color:red; text-align:center;'>No donors match your search.</td></tr>");
                rs.close(); ps.close();
            %>
        </table>
        <br>
    <% } %>

    <%-------------------------------------------------------------------------
      TABLE 3: STUDENTS
      Only show if "ALL" or "STUDENT" is selected
    -------------------------------------------------------------------------%>
    <% if (searchRole.equals("ALL") || searchRole.equals("STUDENT")) { %>
        <h3>Students</h3>
        <table border="1" cellpadding="5" cellspacing="0" width="100%">
            <tr style="background-color: #fcf8e3;">
                <th>Student ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Phone Number</th>
                <th>Actions</th>
            </tr>
            <%
                String sqlStudent = "SELECT * FROM Students WHERE 1=1";
                if (hasTextFilter) sqlStudent += " AND (LOWER(student_id) LIKE ? OR LOWER(name) LIKE ? OR LOWER(email) LIKE ?)";
                sqlStudent += " ORDER BY name";
                
                ps = con.prepareStatement(sqlStudent);
                if (hasTextFilter) { ps.setString(1, likeQuery); ps.setString(2, likeQuery); ps.setString(3, likeQuery); }
                rs = ps.executeQuery();
                
                boolean hasStudents = false;
                while (rs.next()) {
                    hasStudents = true;
            %>
                <tr>
                    <td><%= rs.getString("student_id") %></td>
                    <td><%= rs.getString("name") %></td>
                    <td><%= rs.getString("email") %></td>
                    <td><%= rs.getString("phone_num") %></td>
                    <td>
                        <a href="edit_user.jsp?id=<%= rs.getString("student_id") %>&role=STUDENT">Edit</a> |
                        <a href="UserServlet?action=delete&role=STUDENT&id=<%= rs.getString("student_id") %>" onclick="return confirm('Delete this student?');">Delete</a>
                    </td>
                </tr>
            <%  } 
                if (!hasStudents) out.print("<tr><td colspan='5' style='color:red; text-align:center;'>No students match your search.</td></tr>");
                rs.close(); ps.close();
            %>
        </table>
    <% } %>

    <%
        } catch (Exception e) { 
            e.printStackTrace(); 
            out.print("<p style='color:red;'>Error loading data: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch(SQLException e) {}
            if (ps != null) try { ps.close(); } catch(SQLException e) {}
            if (con != null) try { con.close(); } catch(SQLException e) {}
        }
    %>
</body>
</html>