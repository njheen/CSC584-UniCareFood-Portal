<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% String currentUri = request.getRequestURI(); %>
<div class="sidebar">
    <ul>
        <li class="<%= currentUri.contains("dashboard.jsp") ? "active" : "" %>">
            <a href="dashboard.jsp"><i class="fa fa-home"></i> Dashboard</a>
        </li>
        <li class="<%= currentUri.contains("inventory") || currentUri.contains("Inventory") ? "active" : "" %>">
            <a href="InventoryServlet?action=list"><i class="fa fa-archive"></i> Inventory</a>
        </li>
        <li class="<%= currentUri.contains("voucher") || currentUri.contains("Voucher") ? "active" : "" %>">
            <a href="VoucherServlet?action=list"><i class="fa fa-ticket"></i> Vouchers</a>
        </li>
        <li class="<%= currentUri.contains("user") || currentUri.contains("User") ? "active" : "" %>">
            <a href="UserServlet?action=list"><i class="fa fa-users"></i> Users</a>
        </li>
    </ul>
    <a href="AuthServlet?action=logout" class="logout">
        <i class="fa fa-sign-out"></i> Logout
    </a>
</div>