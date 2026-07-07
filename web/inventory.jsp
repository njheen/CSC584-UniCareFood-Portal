<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || (!"STAFF".equals(user.getRole()) && !"ADMIN".equals(user.getRole()))) {
        response.sendRedirect("index.jsp"); 
        return; 
    }

    // ---- Get filter parameters ----
    String filterCategory = request.getParameter("filterCategory");
    String filterExpiryFrom = request.getParameter("filterExpiryFrom");
    String filterExpiryTo = request.getParameter("filterExpiryTo");
    String searchItem = request.getParameter("searchItem");
    String searchDonor = request.getParameter("searchDonor");

    if (filterCategory == null) filterCategory = "";
    if (filterExpiryFrom == null) filterExpiryFrom = "";
    if (filterExpiryTo == null) filterExpiryTo = "";
    if (searchItem == null) searchItem = "";
    if (searchDonor == null) searchDonor = "";
%>
<!DOCTYPE html>
<html>
<head><title>Manage Inventory</title>
<style>
    .stats-grid {
        display: grid; grid-template-columns: repeat(auto-fit, minmax(180px,1fr));
        gap: 16px; margin-bottom: 20px;
    }
    .stat-card {
        background: #f8f9fa; padding: 15px; border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center;
    }
    .stat-number { font-size: 2rem; font-weight: bold; color: #2c3e50; }
    .stat-label { font-size: 0.9rem; color: #6c757d; }
    .alert-warning { background-color: #fff3cd; border: 1px solid #ffc107; padding: 8px; border-radius: 4px; }
    .filter-form { background: #f0f2f5; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
    .filter-form table { border-collapse: collapse; }
    .filter-form td { padding: 5px 10px; }
    table.inventory-table { border-collapse: collapse; width: 100%; }
    table.inventory-table th { background: #d9edf7; }
    table.inventory-table td, table.inventory-table th { border: 1px solid #ddd; padding: 6px; }
</style>
</head>
<body>
    <h2>Food Bank Inventory Management</h2>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <hr>

    <!-- STATISTICS CARDS -->
    <%
        Connection con = null; Statement stmt = null; ResultSet rs = null;
        int totalItems = 0, totalTypes = 0, lowStockCount = 0, nearExpiryCount = 0;
        java.util.Date today = new java.util.Date();
        java.sql.Date sqlToday = new java.sql.Date(today.getTime());
        try {
            con = DBConnection.getConnection();
            stmt = con.createStatement();
            // Total quantity in stock
            rs = stmt.executeQuery("SELECT SUM(quantity) FROM Inventory");
            if (rs.next()) totalItems = rs.getInt(1);
            rs.close();
            // Distinct categories
            rs = stmt.executeQuery("SELECT COUNT(DISTINCT category) FROM Inventory");
            if (rs.next()) totalTypes = rs.getInt(1);
            rs.close();
            // Low stock: quantity < 10 (adjust threshold)
            rs = stmt.executeQuery("SELECT COUNT(*) FROM Inventory WHERE quantity < 10");
            if (rs.next()) lowStockCount = rs.getInt(1);
            rs.close();
            // Near expiry: expiry_date within next 7 days and not null
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.add(java.util.Calendar.DATE, 7);
            java.sql.Date weekLater = new java.sql.Date(cal.getTimeInMillis());
            rs = stmt.executeQuery("SELECT COUNT(*) FROM Inventory WHERE expiry_date IS NOT NULL AND expiry_date <= '" + weekLater + "' AND expiry_date >= '" + sqlToday + "'");
            if (rs.next()) nearExpiryCount = rs.getInt(1);
            rs.close();
        } catch (Exception e) { e.printStackTrace(); } finally { if (stmt != null) try { stmt.close(); } catch(SQLException e){} if (con != null) try { con.close(); } catch(SQLException e){} }
    %>
    <div class="stats-grid">
        <div class="stat-card"><div class="stat-number"><%= totalItems %></div><div class="stat-label">Total Items (Qty)</div></div>
        <div class="stat-card"><div class="stat-number"><%= totalTypes %></div><div class="stat-label">Food Types</div></div>
        <div class="stat-card" style="background: #ffebee;"><div class="stat-number" style="color:#c62828;"><%= lowStockCount %></div><div class="stat-label">⚠️ Low Stock (&lt;10)</div></div>
        <div class="stat-card" style="background: #fff8e1;"><div class="stat-number" style="color:#e65100;"><%= nearExpiryCount %></div><div class="stat-label">⏳ Near Expiry (≤7 days)</div></div>
    </div>

    <!-- FILTER FORM -->
    <form method="get" action="inventory.jsp" class="filter-form">
        <table>
            <tr>
                <td>Category:</td>
                <td><input type="text" name="filterCategory" value="<%= filterCategory %>" placeholder="e.g. Rice"></td>
                <td>Expiry Date From:</td>
                <td><input type="date" name="filterExpiryFrom" value="<%= filterExpiryFrom %>"></td>
                <td>To:</td>
                <td><input type="date" name="filterExpiryTo" value="<%= filterExpiryTo %>"></td>
            </tr>
            <tr>
                <td>Item Name:</td>
                <td><input type="text" name="searchItem" value="<%= searchItem %>" placeholder="Search by name"></td>
                <td>Donor (name/email):</td>
                <td><input type="text" name="searchDonor" value="<%= searchDonor %>" placeholder="Search donor"></td>
                <td colspan="2">
                    <button type="submit">Apply Filters</button>
                    <a href="inventory.jsp" style="margin-left:10px;">Clear</a>
                </td>
            </tr>
        </table>
    </form>

    <!-- TABLE -->
    <h3>Current Inventory</h3>
    <table class="inventory-table">
        <tr>
            <th>Item</th><th>Category</th><th>Qty</th><th>Expiry Date</th>
            <th>Donor Name</th><th>Donor Email</th><th>Donor Phone</th><th>Actions</th>
        </tr>
        <%
            con = null; PreparedStatement ps = null; rs = null;
            try {
                con = DBConnection.getConnection();
                // Build dynamic query
                StringBuilder sql = new StringBuilder(
                    "SELECT i.*, d.name, d.phone_num FROM Inventory i LEFT JOIN Donors d ON i.donor_email = d.email WHERE 1=1"
                );
                java.util.List<String> params = new java.util.ArrayList<String>();
                
                if (!filterCategory.trim().isEmpty()) {
                    sql.append(" AND LOWER(i.category) LIKE ?");
                    params.add("%" + filterCategory.trim().toLowerCase() + "%");
                }
                if (!filterExpiryFrom.trim().isEmpty()) {
                    sql.append(" AND i.expiry_date >= ?");
                    params.add(filterExpiryFrom.trim());
                }
                if (!filterExpiryTo.trim().isEmpty()) {
                    sql.append(" AND i.expiry_date <= ?");
                    params.add(filterExpiryTo.trim());
                }
                if (!searchItem.trim().isEmpty()) {
                    sql.append(" AND LOWER(i.item_name) LIKE ?");
                    params.add("%" + searchItem.trim().toLowerCase() + "%");
                }
                if (!searchDonor.trim().isEmpty()) {
                    sql.append(" AND (LOWER(d.name) LIKE ? OR LOWER(d.email) LIKE ?)");
                    String like = "%" + searchDonor.trim().toLowerCase() + "%";
                    params.add(like);
                    params.add(like);
                }
                sql.append(" ORDER BY i.id DESC");
                
                ps = con.prepareStatement(sql.toString());
                for (int i = 0; i < params.size(); i++) {
                    ps.setString(i+1, params.get(i));
                }
                rs = ps.executeQuery();
                
                while (rs.next()) {
                    String donorName = rs.getString("name") != null ? rs.getString("name") : "Anonymous";
                    String donorEmail = rs.getString("donor_email") != null ? rs.getString("donor_email") : "-";
                    String donorPhone = rs.getString("phone_num") != null ? rs.getString("phone_num") : "-";
                    Date expiry = rs.getDate("expiry_date");
                    String expiryStr = (expiry != null) ? expiry.toString() : "-";
        %>
            <tr>
                <td><%= rs.getString("item_name") %></td>
                <td><%= rs.getString("category") %></td>
                <td><%= rs.getInt("quantity") %></td>
                <td><%= expiryStr %></td>
                <td><%= donorName %></td>
                <td><%= donorEmail %></td>
                <td><%= donorPhone %></td>
                <td>
                    <a href="edit_inventory.jsp?id=<%= rs.getInt("id") %>">Edit</a> |
                    <a href="InventoryServlet?action=delete&id=<%= rs.getInt("id") %>" onclick="return confirm('Delete?');">Delete</a>
                </td>
            </tr>
        <%      }
            } catch (Exception e) { e.printStackTrace(); } 
            finally { if (rs != null) try { rs.close(); } catch(SQLException e){} if (ps != null) try { ps.close(); } catch(SQLException e){} if (con != null) try { con.close(); } catch(SQLException e){} }
        %>
    </table>
</body>
</html>