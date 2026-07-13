<%@page import="models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Security check: Only allow STAFF or ADMIN
    User user = (User) session.getAttribute("currentUser");
    if (user == null || (!"STAFF".equals(user.getRole()) && !"ADMIN".equals(user.getRole()))) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Register New Staff - UniCare Food Portal</title>
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
            <h1>Staff & Admin Provisioning</h1>
        </div>

        <h2 style="color: #1E5E2F; margin-top: 20px; font-size: 20px;">
            <i class="fa fa-user-shield"></i> Register New Staff / Admin Account
        </h2>
        
        <!-- Registration Form Layout -->
        <div class="form-container" style="max-width: 500px; margin-top: 15px; padding: 30px;">
            <form action="AuthServlet" method="post" style="display: flex; flex-direction: column; gap: 20px;">
                <input type="hidden" name="action" value="staffRegister">
                
                <!-- Account Role Selection -->
                <div class="form-group" style="margin: 0;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Account Role</label>
                    <select name="role" class="form-control" required>
                        <option value="STAFF">General Staff</option>
                        <option value="ADMIN">Administrator</option>
                    </select>
                </div>
                
                <!-- Staff ID Parameter Field -->
                <div class="form-group" style="margin: 0;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Staff ID (Login ID)</label>
                    <input type="text" name="staffId" class="form-control" placeholder="e.g. STF1002" required>
                </div>
                
                <!-- Security Password Field -->
                <div class="form-group" style="margin: 0;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Temporary Password</label>
                    <input type="password" name="password" class="form-control" placeholder="Minimum 5 characters" required minlength="5">
                </div>
                
                <!-- Form Submission Control Buttons -->
                <div style="display: flex; gap: 12px; margin-top: 5px;">
                    <button type="submit" class="btn btn-primary" style="flex: 1; height: 40px;">
                        <i class="fa fa-user-plus"></i> Create Account
                    </button>
                    <a href="dashboard.jsp" class="btn btn-danger" style="background: #64748b; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; height: 40px; padding: 0 16px;">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
