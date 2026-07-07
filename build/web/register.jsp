<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head><title>Register</title></head>
<body>
    <h2>Register New User</h2>
    <form action="AuthServlet" method="post" onsubmit="return validateForm()">
        <input type="hidden" name="action" value="register">
        Username: <input type="text" id="username" name="username" required><br><br>
        Password: <input type="password" id="password" name="password" required><br><br>
        Role: 
        <select name="role">
            <option value="DONOR">Donor</option>
            <option value="STAFF">HEP Staff</option>
        </select><br><br>
        <button type="submit">Register</button>
    </form>

    <script>
        function validateForm() {
            var pass = document.getElementById("password").value;
            if (pass.length < 5) {
                alert("Password must be at least 5 characters long.");
                return false;
            }
            return true;
        }
    </script>
</body>
</html>