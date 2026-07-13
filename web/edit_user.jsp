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
<head>
    <title>Edit User - UniCare Food Portal</title>
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
            <h1><i class="fa fa-user-pen"></i> Edit User <span style="font-size:16px; color:#64748b; font-weight:500;">(<%= editRole %>)</span></h1>
        </div>

        <div style="margin-bottom:20px;">
            <a href="manage_users.jsp" style="color:#1E5E2F; text-decoration:none; font-weight:600; display:inline-flex; align-items:center; gap:6px;">
                <i class="fa fa-arrow-left" style="font-size:12px;"></i> Back to User List
            </a>
        </div>

        <!-- ===== EDIT FORM ===== -->
        <div class="form-container">
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
                            <div class="form-group">
                                <label>Staff ID (Read-Only)</label>
                                <input type="text" class="form-control" value="<%= rs.getString("staff_id") %>" readonly style="background:#f1f5f9; color:#64748b;">
                            </div>

                            <div class="form-group">
                                <label>Account Role</label>
                                <select name="newRole" class="form-control" required>
                                    <option value="STAFF" <%= "STAFF".equals(rs.getString("role")) ? "selected" : "" %>>General Staff</option>
                                    <option value="ADMIN" <%= "ADMIN".equals(rs.getString("role")) ? "selected" : "" %>>Administrator</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Change Password</label>
                                <input type="password" name="password" class="form-control" value="<%= rs.getString("password") %>" required>
                            </div>
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
                            <div class="form-group">
                                <label>Email/Login (Read-Only)</label>
                                <input type="text" class="form-control" value="<%= rs.getString("email") %>" readonly style="background:#f1f5f9; color:#64748b;">
                            </div>

                            <div class="form-group">
                                <label>Full Name</label>
                                <input type="text" name="name" class="form-control" value="<%= rs.getString("name") %>" required>
                            </div>

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
                        }
                        // 3. STUDENT EDIT FORM
                        else if ("STUDENT".equals(editRole)) {
                            ps = con.prepareStatement("SELECT * FROM Students WHERE student_id = ?");
                            ps.setString(1, editId);
                            rs = ps.executeQuery();
                            if (rs.next()) {
                %>
                            <div class="form-group">
                                <label>Student ID (Read-Only)</label>
                                <input type="text" class="form-control" value="<%= rs.getString("student_id") %>" readonly style="background:#f1f5f9; color:#64748b;">
                            </div>

                            <div class="form-group">
                                <label>Full Name</label>
                                <input type="text" name="name" class="form-control" value="<%= rs.getString("name") %>" required>
                            </div>

                            <div class="form-group">
                                <label>Email</label>
                                <input type="email" name="email" class="form-control" value="<%= rs.getString("email") %>" required>
                            </div>

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
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch(SQLException e) {}
                        if (ps != null) try { ps.close(); } catch(SQLException e) {}
                        if (con != null) try { con.close(); } catch(SQLException e) {}
                    }
                %>

                <div style="display:flex; gap:12px; margin-top:10px;">
                    <button type="submit" class="btn btn-primary" style="flex:1; height:40px;">
                        <i class="fa fa-floppy-disk"></i> Save Changes
                    </button>
                    <a href="manage_users.jsp" class="btn btn-danger" style="background:#64748b; text-decoration:none; display:inline-flex; align-items:center; justify-content:center; height:40px; padding:0 16px;">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
