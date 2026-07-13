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
<head>
    <title>Manage All Users - UniCare Food Portal</title>
    <!-- Modernized Layout Assets -->
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>

    <!-- Unified Framework Includes -->
    <%@ include file="navbar.jsp" %>
    <%@ include file="sidebar.jsp" %>

    <!-- Content Workspace Wrapper -->
    <div class="main-content">
        <div class="page-title">
            <h1>User Account Directory Management</h1>
        </div>

        <!-- Success Notification Box -->
        <% if (request.getParameter("msg") != null) { %>
            <div class="alert alert-success">
                <i class="fa fa-check-circle"></i> <%= request.getParameter("msg") %>
            </div>
        <% } %>

        <!-- Stylized Management Search / Filtering Tool -->
        <div class="form-container" style="max-width: 100%; margin-bottom: 30px; padding: 20px;">
            <form action="manage_users.jsp" method="get" style="display: flex; flex-wrap: wrap; gap: 20px; align-items: flex-end;">
                
                <div style="flex: 1; min-width: 200px;">
                    <label style="font-weight: 600; color: #1E5E2F; margin-bottom: 8px; display: block;">Functional Role View</label>
                    <select name="role" class="form-control">
                        <option value="ALL" <%= "ALL".equals(searchRole) ? "selected" : "" %>>Display All Sub-Tables</option>
                        <option value="STUDENT" <%= "STUDENT".equals(searchRole) ? "selected" : "" %>>Students Accounts Only</option>
                        <option value="DONOR" <%= "DONOR".equals(searchRole) ? "selected" : "" %>>Donors Accounts Only</option>
                        <option value="STAFF" <%= "STAFF".equals(searchRole) ? "selected" : "" %>>Staff & Administrative Only</option>
                    </select>
                </div>

                <div style="flex: 2; min-width: 280px;">
                    <label style="font-weight: 600; color: #1E5E2F; margin-bottom: 8px; display: block;">Keyword Database Query</label>
                    <input type="text" name="q" value="<%= searchQuery %>" class="form-control" placeholder="Search unique ID, name strings, or email addresses...">
                </div>

                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn btn-primary">
                        <i class="fa fa-filter"></i> Apply Filters
                    </button>
                    <a href="manage_users.jsp" class="btn btn-danger" style="background: #64748b;">
                        <i class="fa fa-undo"></i> Clear
                    </a>
                </div>
            </form>
        </div>

        <%
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
        %>

        <%-------------------------------------------------------------------------
          TABLE 1: STAFF & ADMINS
        -------------------------------------------------------------------------%>
        <% if (searchRole.equals("ALL") || searchRole.equals("STAFF")) { %>
            <h2 style="color: #1E5E2F; margin-top: 20px; font-size: 20px;"><i class="fa fa-user-shield"></i> Staff & Administrators</h2>
            <div class="table-container" style="margin-bottom: 40px;">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Staff ID Identifier</th>
                            <th>Assigned Security Role</th>
                            <th>Administrative Actions</th>
                        </tr>
                    </thead>
                    <tbody>
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
                                <td><strong><%= rs.getString("staff_id") %></strong></td>
                                <td><span style="background: #dbeafe; color: #1e40af; padding: 4px 8px; border-radius: 4px; font-size: 13px; font-weight: bold;"><%= rs.getString("role") %></span></td>
                                <td>
                                    <a href="edit_user.jsp?id=<%= rs.getString("staff_id") %>&role=<%= rs.getString("role") %>" class="btn btn-primary" style="padding: 6px 12px; font-size: 13px;"><i class="fa fa-edit"></i> Edit</a>
                                    <% if (!loggedInUser.getLoginId().equals(rs.getString("staff_id"))) { %>
                                        <a href="UserServlet?action=delete&role=<%= rs.getString("role") %>&id=<%= rs.getString("staff_id") %>" class="btn btn-danger" style="padding: 6px 12px; font-size: 13px;" onclick="return confirm('Delete this staff member?');"><i class="fa fa-trash"></i> Delete</a>
                                    <% } else { %>
                                        <span style="color:#94a3b8; font-style: italic; margin-left: 10px;"><i class="fa fa-user-check"></i> Current Session Account</span>
                                    <% } %>
                                </td>
                            </tr>
                        <%  } 
                            if (!hasStaff) { %>
                                <tr>
                                    <td colspan="3" style="color:#991b1b; text-align:center; padding: 20px; background: #fef2f2;">No administrator or staff members match your explicit search criteria.</td>
                                </tr>
                        <%  }
                            rs.close(); ps.close();
                        %>
                    </tbody>
                </table>
            </div>
        <% } %>

        <%-------------------------------------------------------------------------
          TABLE 2: DONORS
        -------------------------------------------------------------------------%>
        <% if (searchRole.equals("ALL") || searchRole.equals("DONOR")) { %>
            <h2 style="color: #1E5E2F; margin-top: 20px; font-size: 20px;"><i class="fa fa-hand-holding-heart"></i> Philanthropic Donors</h2>
            <div class="table-container" style="margin-bottom: 40px;">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Email (Login ID Key)</th>
                            <th>Full Corporate/Personal Name</th>
                            <th>Active Phone Number</th>
                            <th>Administrative Actions</th>
                        </tr>
                    </thead>
                    <tbody>
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
                                <td><strong><%= rs.getString("name") %></strong></td>
                                <td><%= rs.getString("phone_num") %></td>
                                <td>
                                    <a href="edit_user.jsp?id=<%= rs.getString("email") %>&role=DONOR" class="btn btn-primary" style="padding: 6px 12px; font-size: 13px;"><i class="fa fa-edit"></i> Edit</a>
                                    <a href="UserServlet?action=delete&role=DONOR&id=<%= rs.getString("email") %>" class="btn btn-danger" style="padding: 6px 12px; font-size: 13px;" onclick="return confirm('Delete this donor?');"><i class="fa fa-trash"></i> Delete</a>
                                </td>
                            </tr>
                        <%  } 
                            if (!hasDonors) { %>
                                <tr>
                                    <td colspan="4" style="color:#991b1b; text-align:center; padding: 20px; background: #fef2f2;">No contributing donors match your specific search queries.</td>
                                </tr>
                        <%  }
                            rs.close(); ps.close();
                        %>
                    </tbody>
                </table>
            </div>
        <% } %>

        <%-------------------------------------------------------------------------
          TABLE 3: STUDENTS
        -------------------------------------------------------------------------%>
        <% if (searchRole.equals("ALL") || searchRole.equals("STUDENT")) { %>
            <h2 style="color: #1E5E2F; margin-top: 20px; font-size: 20px;"><i class="fa fa-graduation-cap"></i> Registered Student Beneficiaries</h2>
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Student Matriculation ID</th>
                            <th>Full Legal Name</th>
                            <th>Institutional Email</th>
                            <th>Contact Phone Number</th>
                            <th>Administrative Actions</th>
                        </tr>
                    </thead>
                    <tbody>
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
                                <td><strong><%= rs.getString("student_id") %></strong></td>
                                <td><%= rs.getString("name") %></td>
                                <td><%= rs.getString("email") %></td>
                                <td><%= rs.getString("phone_num") %></td>
                                <td>
                                    <a href="edit_user.jsp?id=<%= rs.getString("student_id") %>&role=STUDENT" class="btn btn-primary" style="padding: 6px 12px; font-size: 13px;"><i class="fa fa-edit"></i> Edit</a>
                                    <a href="UserServlet?action=delete&role=STUDENT&id=<%= rs.getString("student_id") %>" class="btn btn-danger" style="padding: 6px 12px; font-size: 13px;" onclick="return confirm('Delete this student?');"><i class="fa fa-trash"></i> Delete</a>
                                </td>
                            </tr>
                        <%  } 
                            if (!hasStudents) { %>
                                <tr>
                                    <td colspan="5" style="color:#991b1b; text-align:center; padding: 20px; background: #fef2f2;">No student profiles match the designated search filters inside the system.</td>
                                </tr>
                        <%  }
                            rs.close(); ps.close();
                        %>
                    </tbody>
                </table>
            </div>
        <% } %>

        <%
            } catch (Exception e) { 
                e.printStackTrace(); 
                out.print("<div class='alert alert-danger'><i class='fa fa-exclamation-triangle'></i> Operational error loading datasets: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch(SQLException e) {}
                if (ps != null) try { ps.close(); } catch(SQLException e) {}
                if (con != null) try { con.close(); } catch(SQLException e) {}
            }
        %>
    </div>
</body>
</html>
