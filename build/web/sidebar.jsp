<%@ page import="models.User" %>
<%
    User navUser = (User) session.getAttribute("currentUser");
    String navRole = (navUser != null) ? navUser.getRole() : "";
    String currentUri = request.getRequestURI();
    String currentPage = currentUri.substring(currentUri.lastIndexOf('/') + 1);
%>
<div class="sidebar">
    <ul>
        <% if ("STUDENT".equals(navRole)) { %>
            <li class="<%= currentPage.equals("student_dashboard.jsp") ? "active" : "" %>">
                <a href="student_dashboard.jsp"><i class="fa fa-home"></i> Dashboard</a>
            </li>
        <% } else { %>
            <li class="<%= currentPage.equals("dashboard.jsp") ? "active" : "" %>">
                <a href="dashboard.jsp"><i class="fa fa-home"></i> Dashboard</a>
            </li>
        <% } %>

        <% if ("STAFF".equals(navRole) || "ADMIN".equals(navRole)) { %>
            <li class="<%= currentPage.equals("inventory.jsp") ? "active" : "" %>">
                <a href="inventory.jsp"><i class="fa fa-archive"></i> Inventory</a>
            </li>
            <li class="<%= currentPage.equals("staff_requests.jsp") ? "active" : "" %>">
                <a href="staff_requests.jsp"><i class="fa fa-ticket"></i> Voucher Requests</a>
            </li>
            <li class="<%= currentPage.equals("manage_students.jsp") ? "active" : "" %>">
                <a href="manage_students.jsp"><i class="fa fa-user-graduate"></i> Students</a>
            </li>
        <% } %>

        <% if ("ADMIN".equals(navRole)) { %>
            <li class="<%= currentPage.equals("manage_users.jsp") ? "active" : "" %>">
                <a href="manage_users.jsp"><i class="fa fa-users-gear"></i> All Users</a>
            </li>
            <li class="<%= currentPage.equals("staff_register.jsp") ? "active" : "" %>">
                <a href="staff_register.jsp"><i class="fa fa-user-plus"></i> Register Staff</a>
            </li>
        <% } %>

        <% if ("DONOR".equals(navRole)) { %>
            <li class="<%= currentPage.equals("donor_inventory.jsp") ? "active" : "" %>">
                <a href="donor_inventory.jsp"><i class="fa fa-hand-holding-heart"></i> My Donations</a>
            </li>
        <% } %>

        <li class="<%= (currentPage.equals("profile.jsp") || currentPage.equals("staff_profile.jsp")) ? "active" : "" %>">
            <% if ("STAFF".equals(navRole) || "ADMIN".equals(navRole)) { %>
                <a href="staff_profile.jsp"><i class="fa fa-id-badge"></i> My Profile</a>
            <% } else { %>
                <a href="profile.jsp"><i class="fa fa-id-badge"></i> My Profile</a>
            <% } %>
        </li>
    </ul>
    <a href="AuthServlet?action=logout" class="logout">
        <i class="fa fa-sign-out"></i> Logout
    </a>
</div>
