<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head><title>Student Registration</title></head>
<body>
    <h2>Student Registration</h2>
    <form action="AuthServlet" method="post">
        <input type="hidden" name="action" value="registerStudent">
        
        Full Name: <input type="text" name="fullName" required><br><br>
        Student ID: <input type="text" name="studentId" required><br><br>
        Email: <input type="email" name="email" required><br><br>
        Phone Number: <input type="text" name="phone" required><br><br>
        
        Username (Login ID): <input type="text" name="username" required><br><br>
        Password: <input type="password" name="password" required minlength="5"><br><br>
        
        <button type="submit">Register as Student</button>
    </form>
    <br>
    <a href="index.jsp">Back to Login</a>
</body>
</html>