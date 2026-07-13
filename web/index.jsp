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
    background: #f4f7f9;
    margin: 0;
    font-family: Arial, sans-serif;
}

.page-wrapper{
    min-height:100vh;
    display:flex;
    justify-content:center;
    align-items:center;
    padding:40px 20px;
}

.login-card{
    width:100%;
    max-width:450px;
}
    </style>
</head>
<body class="login-page">

<div class="page-wrapper">

    <div class="login-card">

        <div class="form-container">

            <div style="text-align:center;margin-bottom:25px;">

                <i class="fa fa-heartbeat"
                   style="font-size:48px;color:#1E5E2F;margin-bottom:10px;"></i>

                <h1 style="color:#1E5E2F;font-size:28px;">
                    UniCare Food Portal
                </h1>

                <p style="color:#666;">
                    Care Shared, Futures Fed
                </p>

            </div>

            <% if (request.getParameter("error") != null) { %>

            <div class="alert alert-danger" style="margin-bottom:20px;">
                <i class="fa fa-triangle-exclamation"></i>
                <%= request.getParameter("error") %>
            </div>

            <% } %>

            <% if (request.getParameter("msg") != null) { %>

            <div class="alert alert-success" style="margin-bottom:20px;">
                <i class="fa fa-check-circle"></i>
                <%= request.getParameter("msg") %>
            </div>

            <% } %>

            <form action="AuthServlet" method="POST">

                <input type="hidden" name="action" value="login">

                <div class="form-group">
                    <label>Username / Email Address</label>

                    <input
                        type="text"
                        name="loginId"
                        class="form-control"
                        placeholder="Enter your username"
                        required>
                </div>

                <div class="form-group">
                    <label>Password</label>

                    <input
                        type="password"
                        name="password"
                        class="form-control"
                        placeholder="••••••••"
                        required>
                </div>

                <button
                    type="submit"
                    class="btn btn-primary"
                    style="width:100%;margin-top:10px;">

                    Authenticate & Login

                </button>

            </form>

            <div style="text-align:center;margin-top:20px;">

                <p style="font-size:14px;color:#555;">

                    Need an account?

                    <a href="public_register.jsp"
                       style="color:#1E5E2F;font-weight:bold;text-decoration:none;">

                        Register Here

                    </a>

                </p>

            </div>

            <hr style="margin:30px 0;">

            <div style="text-align:center;">

                <h3 style="color:#1E5E2F;">
                    <i class="fa-solid fa-circle-question"></i>
                    Need Help?
                </h3>

                <p style="color:#555;">
                    Forgot your password or experiencing login issues?
                </p>

                <p style="color:#555;">
                    Please contact the UniCare Food Portal Administrator.
                </p>

                <p style="margin-top:15px;">

                    <i class="fa-solid fa-phone"></i>

                    +60 3-5544 1234

                </p>

                <p>

                    <i class="fa-solid fa-envelope"></i>

                    admin@unicarefood.my

                </p>

                <p style="font-size:13px;color:#888;margin-top:15px;">

                    Our team will verify your identity before assisting
                    with password recovery.

                </p>

            </div>

        </div>

    </div>

</div>

</body>


</html>
