<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Student Registration - UniCare Food Portal</title>
    <!-- Modernized Layout Assets -->
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body style="background: #f1f5f9; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">

    <!-- Center Student Registration Card -->
    <div class="form-container" style="max-width: 450px; width: 100%; margin: 20px; padding: 35px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); background: #ffffff;">
        
        <div style="text-align: center; margin-bottom: 25px;">
            <i class="fa fa-user-graduate" style="font-size: 36px; color: #1E5E2F; margin-bottom: 10px;"></i>
            <h2 style="color: #1E5E2F; margin: 0; font-size: 24px; font-weight: 700;">Student Registration</h2>
            <p style="color: #64748b; font-size: 14px; margin-top: 5px;">Access campus food support resources</p>
        </div>

        <form action="AuthServlet" method="post" style="display: flex; flex-direction: column; gap: 16px;">
            <input type="hidden" name="action" value="registerStudent">
            
            <!-- Full Name Input -->
            <div class="form-group" style="margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Full Name</label>
                <input type="text" name="fullName" class="form-control" placeholder="e.g. Amir Nazhan" required>
            </div>
            
            <!-- Student ID Input -->
            <div class="form-group" style="margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Student ID</label>
                <input type="text" name="studentId" class="form-control" placeholder="e.g. 2025555542" required>
            </div>
            
            <!-- Email Input -->
            <div class="form-group" style="margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Email Address</label>
                <input type="email" name="email" class="form-control" placeholder="student@uitm.edu.my" required>
            </div>
            
            <!-- Phone Input -->
            <div class="form-group" style="margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Phone Number</label>
                <input type="text" name="phone" class="form-control" placeholder="e.g. 0123456789" required>
            </div>
            
            <!-- Username (Login ID) Input -->
            <div class="form-group" style="margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Username <span style="font-weight: normal; color: #64748b; font-size: 0.85em;">(Your Login ID)</span></label>
                <input type="text" name="username" class="form-control" placeholder="Choose a login username" required>
            </div>
            
            <!-- Password Input -->
            <div class="form-group" style="margin: 0;">
                <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Password</label>
                <input type="password" name="password" class="form-control" placeholder="Minimum 5 characters" required minlength="5">
            </div>
            
            <!-- Submit Action Control -->
            <button type="submit" class="btn btn-primary" style="width: 100%; height: 42px; font-size: 15px; margin-top: 10px; font-weight: 600;">
                <i class="fa fa-graduation-cap"></i> Register as Student
            </button>
        </form>
        
        <!-- Bottom Core Navigation Footer Links -->
        <div style="text-align: center; margin-top: 25px; border-top: 1px solid #e2e8f0; padding-top: 15px;">
            <a href="index.jsp" style="color: #1E5E2F; text-decoration: none; font-size: 14px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px;">
                <i class="fa fa-arrow-left" style="font-size: 12px;"></i> Back to Login
            </a>
        </div>
    </div>

</body>
</html>
