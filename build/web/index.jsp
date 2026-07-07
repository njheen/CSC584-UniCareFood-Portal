<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head><title>Food Bank Login</title></head>
<body>
    <h2>Login to Food Bank System</h2>
    <p style="color:red;">${param.error}</p>
    <p style="color:green;">${param.msg}</p>
    <form action="AuthServlet" method="post">
        <input type="hidden" name="action" value="login">
        Username: <input type="text" name="username" required><br><br>
        Password: <input type="password" name="password" required><br><br>
        <button type="submit">Login</button>
    </form>
    <br>
    <a href="public_register.jsp">Register as a Student or Donor</a>
</body>
</html>