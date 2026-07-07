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
<head><title>Register New Staff</title></head>
<body>
    <h2>Register New Staff / Admin</h2>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <hr>
    
    <form action="AuthServlet" method="post">
        <input type="hidden" name="action" value="staffRegister">
        
        Account Role:
        <select name="role" required>
            <option value="STAFF">General Staff</option>
            <option value="ADMIN">Administrator</option>
        </select><br><br>
        
        Staff ID (Login ID): <input type="text" name="staffId" required><br><br>
        Password: <input type="password" name="password" required minlength="5"><br><br>
        
        <button type="submit">Create Account</button>
    </form>
</body>
</html>