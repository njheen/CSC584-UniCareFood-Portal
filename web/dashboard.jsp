<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    // Only Staff, Admins, and Donors get to this dashboard. Students go to student_dashboard.jsp
    if (user == null || "STUDENT".equals(user.getRole())) { response.sendRedirect("index.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head><title>Dashboard</title></head>
<body>
    <h2>Welcome, <%= user.getName() %> (<%= user.getRole() %>)</h2>
    
    <hr>
    <%-- 1. ADMIN ONLY FEATURES --%>
    <% if ("ADMIN".equalsIgnoreCase(user.getRole())) { %>
        <div style="background-color: #f0f0f0; padding: 10px; margin-bottom: 10px;">
            <strong>Admin Tools:</strong>
            <a href="manage_users.jsp">Manage All Users (Global)</a> | 
            <a href="staff_register.jsp">Register New Staff</a>
        </div>
    <% } %>

    <%-- 2. STAFF & ADMIN FEATURES --%>
    <% if ("STAFF".equals(user.getRole()) || "ADMIN".equals(user.getRole())) { %>
        <a href="inventory.jsp">Manage Inventory</a> | 
        <a href="staff_requests.jsp">Manage Voucher Requests</a> | 
        <a href="manage_students.jsp">Manage Students</a> | 
        <a href="profile.jsp">My Profile</a>
    <% } %>

    <%-- 3. DONOR FEATURES --%>
    <% if ("DONOR".equals(user.getRole())) { %>
        <a href="donor_inventory.jsp">Manage My Donations</a> | 
        <a href="profile.jsp">My Profile</a>
    <% } %>

    <a href="AuthServlet?action=logout" style="color:red; float:right;">Logout</a>
    <hr>
    
    <h3>System Dashboard Overview</h3>
    <%-- (Keep your existing stats/tables code here) --%>
</body>
</html>