<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Welcome - UniCare Food Portal</title>
    <!-- Essential: This tag pulls in your styles -->
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Small localized override just to center the login box on the landing page */
        .login-page {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: #f4f7f9;
        }
    </style>
</head>
<body class="login-page">

    <div class="form-container" style="width: 100%; max-width: 450px;">
        <div style="text-align: center; margin-bottom: 25px;">
            <i class="fa fa-heartbeat" style="font-size: 48px; color: #1E5E2F; margin-bottom: 10px;"></i>
            <h1 style="color: #1E5E2F; font-size: 28px;">UniCare Food Portal</h1>
            <p style="color: #666; margin-top: 5px;">Care Shared, Futures Fed</p>
        </div>

        <form action="AuthServlet" method="POST">
            <input type="hidden" name="action" value="login">

            <div class="form-group">
                <label for="username">Username / Email Address</label>
                <input type="text" id="username" name="loginId" class="form-control" placeholder="Enter your username" required>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 10px;">
                Authenticate & Login
            </button>
        </form>
        
        <div style="text-align: center; margin-top: 20px;">
            <p style="font-size: 14px; color: #555;">
                Need an account? <a href="public_register.jsp" style="color: #1E5E2F; font-weight: bold; text-decoration: none;">Register Here</a>
            </p>
        </div>
    </div>

</body>
</html>
