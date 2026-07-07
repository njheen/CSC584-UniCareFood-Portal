<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Public Registration</title>
    <script>
        // Function to toggle fields based on role selection
        function toggleFields() {
            var role = document.getElementById("roleSelect").value;
            var studentIdRow = document.getElementById("studentIdRow");
            var studentIdInput = document.getElementById("studentIdInput");
            var emailLoginNote = document.getElementById("emailLoginNote");
            
            if (role === "STUDENT") {
                // Show Student ID field, hide Email login note
                studentIdRow.style.display = "block";
                studentIdInput.required = true;
                emailLoginNote.style.display = "none";
            } else {
                // Hide Student ID field, show Email login note for Donors
                studentIdRow.style.display = "none";
                studentIdInput.required = false;
                studentIdInput.value = ""; // clear it out
                emailLoginNote.style.display = "inline";
            }
        }
    </script>
</head>
<body onload="toggleFields()">
    <h2>Register an Account</h2>
    <form action="AuthServlet" method="post">
        <input type="hidden" name="action" value="publicRegister">
        
        Account Type: 
        <select name="role" id="roleSelect" onchange="toggleFields()">
            <option value="DONOR">Donor</option>
            <option value="STUDENT">Student</option>
        </select><br><br>
        
        Full Name: <input type="text" name="name" required><br><br>
        
        <div id="studentIdRow" style="display:none;">
            Student ID (Your Login ID): <input type="text" name="studentId" id="studentIdInput"><br><br>
        </div>
        
        Email: <input type="email" name="email" required> 
        <span id="emailLoginNote" style="color: blue; font-size: 0.9em;">(This will be your Login ID)</span><br><br>
        
        Phone Number: <input type="text" name="phone" required><br><br>
        
        Password: <input type="password" name="password" required minlength="5"><br><br>
        
        <button type="submit">Register</button>
    </form>
    <br>
    <a href="index.jsp">Back to Login</a>
</body>
</html>