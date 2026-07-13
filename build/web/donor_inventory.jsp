<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% User user = (User) session.getAttribute("currentUser"); if (user == null || !"DONOR".equals(user.getRole())) { response.sendRedirect("index.jsp"); return; } %>
<!DOCTYPE html>
<html>
<head>
    <title>My Donations - UniCare Food Portal</title>
    <!-- Modernized Layout Assets -->
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
            <h1>My Donations Workspace</h1>
        </div>

        <!-- Section A: Donate New Item Form -->
        <h2 style="color: #1E5E2F; margin-top: 20px; font-size: 20px;"><i class="fa fa-plus-circle"></i> Donate New Item</h2>
        <div class="form-container" style="max-width: 100%; margin-bottom: 40px; padding: 20px;">
            <form action="InventoryServlet" method="post" style="display: flex; flex-wrap: wrap; gap: 15px; align-items: flex-end;">
                <input type="hidden" name="action" value="add">
                
                <div style="flex: 1; min-width: 180px;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Item Name</label>
                    <input type="text" name="itemName" class="form-control" required>
                </div>
                
                <div style="flex: 1; min-width: 180px;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Category</label>
                    <input type="text" name="category" class="form-control" required>
                </div>
                
                <div style="width: 120px;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Quantity</label>
                    <input type="number" name="quantity" class="form-control" required min="1">
                </div>
                
                <div style="flex: 1; min-width: 150px;">
                    <label style="font-weight: 600; color: #333; margin-bottom: 6px; display: block;">Expiry Date</label>
                    <input type="date" name="expiryDate" class="form-control">
                </div>
                
                <div>
                    <button type="submit" class="btn btn-primary" style="height: 40px;">
                        <i class="fa fa-paper-plane"></i> Add Donation
                    </button>
                </div>
            </form>
        </div>

        <!-- Section B: My Donated Items Table -->
        <h2 style="color: #1E5E2F; margin-top: 20px; font-size: 20px;"><i class="fa fa-hand-holding-heart"></i> My Donated Items</h2>
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Item</th>
                        <th>Category</th>
                        <th>Quantity</th>
                        <th>Expiry Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
                        try {
                            con = DBConnection.getConnection();
                            ps = con.prepareStatement("SELECT * FROM Inventory WHERE donor_email = ?");
                            ps.setString(1, user.getLoginId());
                            rs = ps.executeQuery();
                            boolean hasItems = false;
                            while (rs.next()) {
                                hasItems = true;
                    %>
                        <tr>
                            <form action="InventoryServlet" method="post" style="margin:0;">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                                
                                <td><strong><%= rs.getInt("id") %></strong></td>
                                <td><input type="text" name="itemName" class="form-control" style="padding: 4px 8px; font-size: 13px;" value="<%= rs.getString("item_name") %>"></td>
                                <td><input type="text" name="category" class="form-control" style="padding: 4px 8px; font-size: 13px;" value="<%= rs.getString("category") %>"></td>
                                <td><input type="number" name="quantity" class="form-control" style="padding: 4px 8px; font-size: 13px; max-width: 100px;" value="<%= rs.getInt("quantity") %>"></td>
                                <td><input type="date" name="expiryDate" class="form-control" style="padding: 4px 8px; font-size: 13px;" value="<%= rs.getDate("expiry_date") != null ? rs.getDate("expiry_date").toString() : "" %>"></td>
                                <td>
                                    <button type="submit" class="btn btn-primary" style="padding: 6px 12px; font-size: 13px;"><i class="fa fa-sync-alt"></i> Update</button>
                                    <a href="InventoryServlet?action=delete&id=<%= rs.getInt("id") %>" class="btn btn-danger" style="padding: 6px 12px; font-size: 13px; text-decoration: none; display: inline-block;" onclick="return confirm('Delete this item?');"><i class="fa fa-trash"></i> Delete</a>
                                </td>
                            </form>
                        </tr>
                    <%      }
                            if(!hasItems) { %>
                                <tr>
                                    <td colspan="6" style="text-align: center; color: #666; padding: 20px;">No contribution records found. Start donating above!</td>
                                </tr>
                    <%      }
                        } catch (Exception e) { e.printStackTrace(); } finally { if (rs != null) try { rs.close(); } catch(SQLException e){} if (ps != null) try { ps.close(); } catch(SQLException e){} if (con != null) try { con.close(); } catch(SQLException e){} }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
