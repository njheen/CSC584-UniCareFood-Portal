<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Security check: Only allow STAFF
    User loggedInUser = (User) session.getAttribute("currentUser");
    if (loggedInUser == null || !"STAFF".equals(loggedInUser.getRole())) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }

    // Capture search parameters from the URL
    String searchQuery = request.getParameter("q");
    String searchRole = request.getParameter("role");
    
    // Handle null values for the first page load
    if (searchQuery == null) searchQuery = "";
    if (searchRole == null) searchRole = "ALL";
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
        
        Role: 
        <select name="role">
            <option value="ALL" <%= "ALL".equals(searchRole) ? "selected" : "" %>>All Roles</option>
            <option value="STUDENT" <%= "STUDENT".equals(searchRole) ? "selected" : "" %>>Student</option>
            <option value="DONOR" <%= "DONOR".equals(searchRole) ? "selected" : "" %>>Donor</option>
            <option value="STAFF" <%= "STAFF".equals(searchRole) ? "selected" : "" %>>Staff</option>
        </select>
        &nbsp;&nbsp;
        
        Search: 
        <input type="text" name="q" value="<%= searchQuery %>" placeholder="Name, Username, Student ID, or System ID" size="40">
        &nbsp;&nbsp;
        
        <button type="submit">Search</button>
        <a href="manage_users.jsp" style="margin-left: 10px;">Clear Filters</a>
    </form>
    <br><br>

    <table border="1" cellpadding="5" cellspacing="0" width="100%">
        <tr style="background-color: #f2f2f2;">
            <th>ID</th>
            <th>Username</th>
            <th>Role</th>
            <th>Full Name</th>
            <th>Student ID</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Actions</th>
        </tr>
        <%
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                
                // 1. Build the base SQL query
                String sql = "SELECT * FROM Users WHERE 1=1 ";
                boolean hasRoleFilter = !searchRole.equals("ALL");
                boolean hasTextFilter = !searchQuery.trim().isEmpty();

                // Append conditions dynamically based on user input
                if (hasRoleFilter) {
                    sql += " AND role = ? ";
                }
                if (hasTextFilter) {
                    // We cast 'id' to VARCHAR so we can search it like text alongside the strings
                    sql += " AND (LOWER(full_name) LIKE ? OR LOWER(username) LIKE ? OR LOWER(student_id) LIKE ? OR CAST(id AS VARCHAR(20)) LIKE ?) ";
                }
                
                sql += " ORDER BY role, id";
                
                // 2. Prepare the statement
                ps = con.prepareStatement(sql);
                int paramIndex = 1;
                
                // 3. Bind the variables safely to prevent SQL injection
                if (hasRoleFilter) {
                    ps.setString(paramIndex++, searchRole);
                }
                if (hasTextFilter) {
                    String likeQuery = "%" + searchQuery.trim().toLowerCase() + "%";
                    ps.setString(paramIndex++, likeQuery); // For full_name
                    ps.setString(paramIndex++, likeQuery); // For username
                    ps.setString(paramIndex++, likeQuery); // For student_id
                    ps.setString(paramIndex++, likeQuery); // For system id
                }
                
                rs = ps.executeQuery();
                
                boolean foundResults = false;
                while (rs.next()) {
                    foundResults = true;
        %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("username") %></td>
                <td><strong><%= rs.getString("role") %></strong></td>
                <td><%= rs.getString("full_name") %></td>
                <td><%= rs.getString("student_id") != null ? rs.getString("student_id") : "N/A" %></td>
                <td><%= rs.getString("email") %></td>
                <td><%= rs.getString("phone") %></td>
                <td>
                    <a href="edit_user.jsp?id=<%= rs.getInt("id") %>">Edit</a> | 
                    
                    <%-- Prevent staff from deleting themselves --%>
                    <% if (loggedInUser.getId() != rs.getInt("id")) { %>
                        <a href="UserServlet?action=delete&id=<%= rs.getInt("id") %>" onclick="return confirm('Are you sure you want to delete this user?');">Delete</a>
                    <% } else { %>
                        <span style="color:gray;">(You)</span>
                    <% } %>
                </td>
            </tr>
        <%
                }
                
                // Display a message if no users match the search
                if (!foundResults) {
                    out.print("<tr><td colspan='8' style='text-align:center; color:red;'>No users found matching your search criteria.</td></tr>");
                }
                
            } catch (Exception e) { 
                e.printStackTrace(); 
                out.print("<tr><td colspan='8' style='color:red;'>Error loading data: " + e.getMessage() + "</td></tr>");
            } finally {
                if (rs != null) try { rs.close(); } catch(SQLException e) {}
                if (ps != null) try { ps.close(); } catch(SQLException e) {}
                if (con != null) try { con.close(); } catch(SQLException e) {}
            }
        %>
    </table>
</body>
</html>