<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Public Registration</title>
    <script>
        // Function to toggle the Student ID field based on role selection
        function toggleStudentFields() {
            var role = document.getElementById("roleSelect").value;
            var studentIdRow = document.getElementById("studentIdRow");
            var studentIdInput = document.getElementById("studentIdInput");
            
            if (role === "STUDENT") {
                studentIdRow.style.display = "block";
                studentIdInput.required = true;
            } else {
                studentIdRow.style.display = "none";
                studentIdInput.required = false;
                studentIdInput.value = ""; // clear it out for donors
            }
        }
    </script>
</head>
<body onload="toggleStudentFields()">
    <h2>Register an Account</h2>
    <form action="AuthServlet" method="post">
        <input type="hidden" name="action" value="publicRegister">
        
        Account Type: 
        <select name="role" id="roleSelect" onchange="toggleStudentFields()">
            <option value="STUDENT">Student</option>
            <option value="DONOR">Donor</option>
        </select><br><br>
        
        Full Name: <input type="text" name="fullName" required><br><br>
        
        <div id="studentIdRow">
            Student ID: <input type="text" name="studentId" id="studentIdInput"><br><br>
        </div>
        
        Email: <input type="email" name="email" required><br><br>
        Phone Number: <input type="text" name="phone" required><br><br>
        
        Username (Login ID): <input type="text" name="username" required><br><br>
        Password: <input type="password" name="password" required minlength="5"><br><br>
        
        <button type="submit">Register</button>
    </form>
    <br>
    <a href="index.jsp">Back to Login</a>
</body>
</html>