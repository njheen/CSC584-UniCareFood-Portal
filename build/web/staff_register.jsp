<%@page import="models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Security check: Only allow access if logged in as STAFF
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"STAFF".equals(user.getRole())) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }
%>
<!DOCTYPE html>
<html>
<head><title>Register New Staff</title></head>
<body>
    <h2>Register New Staff Member</h2>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <hr>
    
    <form action="AuthServlet" method="post">
        <input type="hidden" name="action" value="staffRegister">
        
        Full Name: <input type="text" name="fullName" required><br><br>
        Email: <input type="email" name="email" required><br><br>
        Phone Number: <input type="text" name="phone" required><br><br>
        
        Username: <input type="text" name="username" required><br><br>
        Password: <input type="password" name="password" required minlength="5"><br><br>
        
        <button type="submit">Register Staff</button>
    </form>
</body>
</html>