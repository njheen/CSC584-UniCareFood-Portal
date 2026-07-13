<%@page import="models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Security check: Only allow STAFF or ADMIN (this is an internal tool, not public signup)
    User user = (User) session.getAttribute("currentUser");
    if (user == null || (!"STAFF".equals(user.getRole()) && !"ADMIN".equals(user.getRole()))) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Register New Student - UniCare Food Portal</title>
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
            <h1>Student Beneficiary Records</h1>
        </div>

        <!-- Notification Boxes -->
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger">
                <i class="fa fa-triangle-exclamation"></i> <%= request.getParameter("error") %>
            </div>
        <% } %>

        <h2 style="color: #1E5E2F; margin-top: 20px; font-size: 20px;">
            <i class="fa fa-user-graduate"></i> Register New Student
        </h2>

        <!-- Registration Form Layout -->
        <div class="form-container" style="max-width: 500px; margin-top: 15px; padding: 30px;">
            <form action="AuthServlet" method="post" style="display: flex; flex-direction: column; gap: 18px;">
                <input type="hidden" name="action" value="registerStudent">

                <!-- Full Name Input -->
                <div class="form-group" style="margin: 0;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Full Name</label>
                    <input type="text" name="name" class="form-control" placeholder="e.g. Amir Nazhan" required>
                </div>

                <!-- Student ID Input -->
                <div class="form-group" style="margin: 0;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Student ID <span style="font-weight: normal; color: #64748b; font-size: 0.85em;">(Will be their Login ID)</span></label>
                    <input type="text" name="studentId" class="form-control" placeholder="e.g. 2025555542" required>
                </div>

                <!-- Email Input -->
                <div class="form-group" style="margin: 0;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Email Address</label>
                    <input type="email" name="email" class="form-control" placeholder="student@uitm.edu.my" required>
                </div>

                <!-- Phone Input -->
                <div class="form-group" style="margin: 0;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Phone Number</label>
                    <input type="text" name="phone" class="form-control" placeholder="e.g. 0123456789" required>
                </div>

                <!-- Password Input -->
                <div class="form-group" style="margin: 0;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Temporary Password</label>
                    <input type="password" name="password" class="form-control" placeholder="Minimum 5 characters" required minlength="5">
                </div>

                <!-- Form Submission Control Buttons -->
                <div style="display: flex; gap: 12px; margin-top: 5px;">
                    <button type="submit" class="btn btn-primary" style="flex: 1; height: 40px;">
                        <i class="fa fa-user-plus"></i> Register Student
                    </button>
                    <a href="manage_students.jsp" class="btn btn-danger" style="background: #64748b; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; height: 40px; padding: 0 16px;">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
