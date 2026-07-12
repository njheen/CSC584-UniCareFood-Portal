<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="navbar">
    <h2>UniCare Food Portal</h2>
    <div class="profile">
        Welcome, <strong>${sessionScope.user.username != null ? sessionScope.user.username : 'User'}</strong>
    </div>
</div>