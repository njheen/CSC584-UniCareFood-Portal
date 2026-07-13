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
<head>
    <title>My Profile - UniCare Food Portal</title>
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
            <h1><i class="fa fa-id-badge"></i> My Staff Profile</h1>
        </div>

        <!-- Notification Boxes -->
        <% if (request.getParameter("msg") != null) { %>
            <div class="alert alert-success">
                <i class="fa fa-check-circle"></i> <%= request.getParameter("msg") %>
            </div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger">
                <i class="fa fa-triangle-exclamation"></i> <%= request.getParameter("error") %>
            </div>
        <% } %>

        <!-- ===== PROFILE FORM ===== -->
        <div class="form-container">
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
                    <div class="form-group">
                        <label>Staff ID</label>
                        <input type="text" class="form-control" value="<%= rs.getString("staff_id") %>" readonly style="background:#f1f5f9; color:#64748b;">
                    </div>

                    <div class="form-group">
                        <label>Role</label>
                        <input type="text" class="form-control" value="<%= rs.getString("role") %>" readonly style="background:#f1f5f9; color:#64748b;">
                    </div>

                    <div class="form-group">
                        <label>Change Password</label>
                        <input type="password" name="password" class="form-control" value="<%= rs.getString("password") %>" required>
                    </div>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch(SQLException e) {}
                        if (ps != null) try { ps.close(); } catch(SQLException e) {}
                        if (con != null) try { con.close(); } catch(SQLException e) {}
                    }
                %>

                <button type="submit" class="btn btn-primary"><i class="fa fa-key"></i> Update Password</button>
            </form>
        </div>

        <!-- ===== DANGER ZONE ===== -->
        <div class="form-container" style="margin-top:30px; border:1px solid #fecaca;">
            <h3 style="color:#991b1b; margin-bottom:10px;"><i class="fa fa-triangle-exclamation"></i> Danger Zone</h3>
            <p style="color:#64748b; margin-bottom:16px;">Deleting your staff account is permanent and cannot be undone.</p>
            <a href="UserServlet?action=deleteProfile&role=<%= user.getRole() %>&id=<%= user.getLoginId() %>"
               class="btn btn-danger"
               onclick="return confirm('Are you absolutely sure you want to delete your staff account? This cannot be undone.');">
                <i class="fa fa-trash"></i> Delete My Account
            </a>
        </div>
    </div>
</body>
</html>
