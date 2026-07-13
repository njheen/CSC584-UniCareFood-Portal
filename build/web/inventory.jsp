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

    boolean hasActiveFilter = !filterCategory.trim().isEmpty() || !filterExpiryFrom.trim().isEmpty()
            || !filterExpiryTo.trim().isEmpty() || !searchItem.trim().isEmpty() || !searchDonor.trim().isEmpty();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Inventory - UniCare Food Portal</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>

    <!-- Unified Framework Includes -->
    <%@ include file="navbar.jsp" %>
    <%@ include file="sidebar.jsp" %>

    <!-- Content Workspace Wrapper -->
    <div class="main-content">
        <div class="page-title">
            <h1><i class="fa fa-boxes-stacked"></i> Food Bank Inventory Management</h1>
        </div>

        <!-- Notification Boxes -->
        <% if (request.getParameter("msg") != null) { %>
            <div class="alert alert-success">
                <i class="fa fa-check-circle"></i> <%= request.getParameter("msg") %>
            </div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger">
                <i class="fa fa-triangle-exclamation"></i> <%= request.getParameter("error") %>
            </div>
        <% } %>

        <!-- ===== STATISTICS CARDS ===== -->
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
        <div class="cards" style="margin-bottom:30px;">
            <div class="card">
                <div class="icon"><i class="fa fa-cubes"></i></div>
                <h3>Total Items (Qty)</h3>
                <h1><%= totalItems %></h1>
            </div>
            <div class="card">
                <div class="icon"><i class="fa fa-tags"></i></div>
                <h3>Food Types</h3>
                <h1><%= totalTypes %></h1>
            </div>
            <div class="card" style="<%= lowStockCount > 0 ? "background:#fef2f2;" : "" %>">
                <div class="icon" style="color:#c62828;"><i class="fa fa-triangle-exclamation"></i></div>
                <h3>Low Stock (&lt;10)</h3>
                <h1 style="color:#c62828;"><%= lowStockCount %></h1>
            </div>
            <div class="card" style="<%= nearExpiryCount > 0 ? "background:#fff8e1;" : "" %>">
                <div class="icon" style="color:#e65100;"><i class="fa fa-hourglass-half"></i></div>
                <h3>Near Expiry (&le;7 days)</h3>
                <h1 style="color:#e65100;"><%= nearExpiryCount %></h1>
            </div>
        </div>

        <!-- ===== FILTER FORM ===== -->
        <div class="form-container" style="max-width:100%; margin-bottom:30px;">
            <form method="get" action="inventory.jsp">
                <div style="display:flex; flex-wrap:wrap; gap:20px;">
                    <div style="flex:1; min-width:180px;">
                        <label style="font-weight:600; color:#1E5E2F; margin-bottom:8px; display:block;">Category</label>
                        <input type="text" name="filterCategory" value="<%= filterCategory %>" class="form-control" placeholder="e.g. Rice">
                    </div>
                    <div style="flex:1; min-width:160px;">
                        <label style="font-weight:600; color:#1E5E2F; margin-bottom:8px; display:block;">Expiry From</label>
                        <input type="date" name="filterExpiryFrom" value="<%= filterExpiryFrom %>" class="form-control">
                    </div>
                    <div style="flex:1; min-width:160px;">
                        <label style="font-weight:600; color:#1E5E2F; margin-bottom:8px; display:block;">Expiry To</label>
                        <input type="date" name="filterExpiryTo" value="<%= filterExpiryTo %>" class="form-control">
                    </div>
                </div>
                <div style="display:flex; flex-wrap:wrap; gap:20px; margin-top:16px; align-items:flex-end;">
                    <div style="flex:1; min-width:200px;">
                        <label style="font-weight:600; color:#1E5E2F; margin-bottom:8px; display:block;">Item Name</label>
                        <input type="text" name="searchItem" value="<%= searchItem %>" class="form-control" placeholder="Search by name">
                    </div>
                    <div style="flex:1; min-width:200px;">
                        <label style="font-weight:600; color:#1E5E2F; margin-bottom:8px; display:block;">Donor (name/email)</label>
                        <input type="text" name="searchDonor" value="<%= searchDonor %>" class="form-control" placeholder="Search donor">
                    </div>
                    <div style="display:flex; gap:10px;">
                        <button type="submit" class="btn btn-primary"><i class="fa fa-filter"></i> Apply Filters</button>
                        <a href="inventory.jsp" class="btn btn-danger" style="background:#64748b;"><i class="fa fa-undo"></i> Clear</a>
                    </div>
                </div>
            </form>
        </div>

        <!-- ===== INVENTORY TABLE ===== -->
        <h2 style="color:#1E5E2F; font-size:20px; margin-bottom:12px;"><i class="fa fa-clipboard-list"></i> Current Inventory</h2>
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Item</th><th>Category</th><th>Qty</th><th>Expiry Date</th>
                        <th>Donor Name</th><th>Donor Email</th><th>Donor Phone</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    con = null; PreparedStatement ps = null; rs = null;
                    boolean hasRows = false;
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
                            hasRows = true;
                            String donorName = rs.getString("name") != null ? rs.getString("name") : "Anonymous";
                            String donorEmail = rs.getString("donor_email") != null ? rs.getString("donor_email") : "-";
                            String donorPhone = rs.getString("phone_num") != null ? rs.getString("phone_num") : "-";
                            Date expiry = rs.getDate("expiry_date");
                            String expiryStr = (expiry != null) ? expiry.toString() : "-";
                            int qty = rs.getInt("quantity");
                            boolean isLow = qty < 10;
                %>
                    <tr>
                        <td><strong><%= rs.getString("item_name") %></strong></td>
                        <td><%= rs.getString("category") %></td>
                        <td>
                            <% if (isLow) { %>
                                <span style="background:#fee2e2; color:#991b1b; padding:3px 8px; border-radius:4px; font-weight:bold;"><%= qty %></span>
                            <% } else { %>
                                <%= qty %>
                            <% } %>
                        </td>
                        <td><%= expiryStr %></td>
                        <td><%= donorName %></td>
                        <td><%= donorEmail %></td>
                        <td><%= donorPhone %></td>
                        <td>
                            <a href="edit_inventory.jsp?id=<%= rs.getInt("id") %>" class="btn btn-primary" style="padding:6px 12px; font-size:13px;"><i class="fa fa-edit"></i> Edit</a>
                            <a href="InventoryServlet?action=delete&id=<%= rs.getInt("id") %>" class="btn btn-danger" style="padding:6px 12px; font-size:13px;" onclick="return confirm('Delete this item?');"><i class="fa fa-trash"></i> Delete</a>
                        </td>
                    </tr>
                <%
                        }
                        if (!hasRows) {
                %>
                    <tr>
                        <td colspan="8" style="color:#991b1b; text-align:center; padding:20px; background:#fef2f2;">
                            <% if (hasActiveFilter) { %>
                                No inventory items match your search criteria.
                            <% } else { %>
                                No inventory items yet.
                            <% } %>
                        </td>
                    </tr>
                <%
                        }
                    } catch (Exception e) { e.printStackTrace(); }
                    finally { if (rs != null) try { rs.close(); } catch(SQLException e){} if (ps != null) try { ps.close(); } catch(SQLException e){} if (con != null) try { con.close(); } catch(SQLException e){} }
                %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
