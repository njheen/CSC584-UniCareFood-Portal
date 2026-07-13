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
            <h1><i class="fa fa-id-badge"></i> My Profile <span style="font-size:16px; color:#64748b; font-weight:500;">(<%= user.getRole() %>)</span></h1>
        </div>

        <div style="margin-bottom:20px;">
            <a href="<%= dashboardLink %>" style="color:#1E5E2F; text-decoration:none; font-weight:600; display:inline-flex; align-items:center; gap:6px;">
                <i class="fa fa-arrow-left" style="font-size:12px;"></i> Back to Dashboard
            </a>
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
                    <div class="form-group">
                        <label>Login ID</label>
                        <input type="text" class="form-control" value="<%= user.getLoginId() %>" readonly style="background:#f1f5f9; color:#64748b;">
                    </div>

                    <div class="form-group">
                        <label>Name</label>
                        <input type="text" name="name" class="form-control" value="<%= rs.getString("name") %>" required>
                    </div>

                    <% if ("STUDENT".equals(user.getRole())) { %>
                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" name="email" class="form-control" value="<%= rs.getString("email") %>" required>
                        </div>
                    <% } %>

                    <div class="form-group">
                        <label>Phone Number</label>
                        <input type="text" name="phone" class="form-control" value="<%= rs.getString("phone_num") %>" required>
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

                <button type="submit" class="btn btn-primary"><i class="fa fa-floppy-disk"></i> Update Profile</button>
            </form>
        </div>

        <!-- ===== DANGER ZONE ===== -->
        <div class="form-container" style="margin-top:30px; border:1px solid #fecaca;">
            <h3 style="color:#991b1b; margin-bottom:10px;"><i class="fa fa-triangle-exclamation"></i> Danger Zone</h3>
            <p style="color:#64748b; margin-bottom:16px;">
                Deleting your profile is permanent.
                <% if ("STUDENT".equals(user.getRole())) { %>
                    All your pending voucher requests will be deleted.
                <% } else { %>
                    Your previous donations will become anonymous.
                <% } %>
            </p>
            <a href="UserServlet?action=deleteProfile&role=<%= user.getRole() %>&id=<%= user.getLoginId() %>"
               class="btn btn-danger"
               onclick="return confirm('Are you absolutely sure you want to delete your profile? This cannot be undone.');">
                <i class="fa fa-trash"></i> Delete My Account
            </a>
        </div>
    </div>
</body>
</html>
