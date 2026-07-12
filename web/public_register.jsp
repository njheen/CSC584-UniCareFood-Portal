<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Public Registration - UniCare Food Portal</title>
    <!-- Modernized Layout Assets -->
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
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
<body style="background: #f1f5f9; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">

    <!-- Center Registration Card -->
    <div class="form-container" style="max-width: 450px; width: 100%; margin: 20px; padding: 35px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); background: #ffffff;">
        
        <div style="text-align: center; margin-bottom: 25px;">
            <i class="fa fa-user-plus" style="font-size: 36px; color: #1E5E2F; margin-bottom: 10px;"></i>
            <h2 style="color: #1E5E2F; margin: 0; font-size: 24px; font-weight: 700;">Create an Account</h2>
            <p style="color: #64748b; font-size: 14px; margin-top: 5px;">Join the UniCare Food Portal community</p>
        </div>

        <form action="AuthServlet" method="post" style="display: flex; flex-direction: column; gap: 18px;">
            <input type="hidden" name="action" value="publicRegister">
            
            <!-- Account Type Dropdown -->
            <div class="form-group" style="margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Account Type</label>
                <select name="role" id="roleSelect" onchange="toggleFields()" class="form-control">
                    <option value="DONOR">Donor</option>
                    <option value="STUDENT">Student</option>
                </select>
            </div>
            
            <!-- Full Name Input -->
            <div class="form-group" style="margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Full Name</label>
                <input type="text" name="name" class="form-control" placeholder="e.g. Amirul Bakhtiar" required>
            </div>
            
            <!-- Student ID (Toggled conditionally via original JS) -->
            <div id="studentIdRow" class="form-group" style="display:none; margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Student ID <span style="font-weight: normal; color: #64748b; font-size: 0.85em;">(Will be your Login ID)</span></label>
                <input type="text" name="studentId" id="studentIdInput" class="form-control" placeholder="e.g. S12345">
            </div>
            
            <!-- Email Input -->
            <div class="form-group" style="margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">
                    Email Address 
                    <span id="emailLoginNote" style="color: #2563eb; font-size: 0.85em; font-weight: normal; display: inline; margin-left: 4px;">
                        (Will be your Login ID)
                    </span>
                </label>
                <input type="email" name="email" class="form-control" placeholder="name@example.com" required>
            </div>
            
            <!-- Phone Input -->
            <div class="form-group" style="margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Phone Number</label>
                <input type="text" name="phone" class="form-control" placeholder="e.g. 0123456789" required>
            </div>
            
            <!-- Password Input -->
            <div class="form-group" style="margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Password</label>
                <input type="password" name="password" class="form-control" placeholder="Minimum 5 characters" required minlength="5">
            </div>
            
            <!-- Register Action Button -->
            <button type="submit" class="btn btn-primary" style="width: 100%; height: 42px; font-size: 15px; margin-top: 10px; font-weight: 600;">
                <i class="fa fa-check-circle"></i> Register
            </button>
        </form>
        
        <!-- Back Navigation Link -->
        <div style="text-align: center; margin-top: 25px; border-top: 1px solid #e2e8f0; padding-top: 15px;">
            <a href="index.jsp" style="color: #1E5E2F; text-decoration: none; font-size: 14px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px;">
                <i class="fa fa-arrow-left" style="font-size: 12px;"></i> Back to Login
            </a>
        </div>
    </div>

</body>
</html>
