<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% User user = (User) session.getAttribute("currentUser"); if (user == null || !"DONOR".equals(user.getRole())) { response.sendRedirect("index.jsp"); return; } %>
<!DOCTYPE html>
<html>
<head><title>My Donations</title></head>
<body>
    <h2>My Donations</h2>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <hr>
    
    <h3>Donate New Item</h3>
    <form action="InventoryServlet" method="post">
        <input type="hidden" name="action" value="add">
        Item Name: <input type="text" name="itemName" required>
        Category: <input type="text" name="category" required>
        Quantity: <input type="number" name="quantity" required min="1">
        <button type="submit">Add Donation</button>
    </form>
    
    <h3>My Donated Items</h3>
    <table border="1" cellpadding="5">
        <tr style="background-color: #dff0d8;"><th>ID</th><th>Item</th><th>Category</th><th>Quantity</th><th>Actions</th></tr>
        <%
            Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement("SELECT * FROM Inventory WHERE donor_email = ?");
                ps.setString(1, user.getLoginId());
                rs = ps.executeQuery();
                while (rs.next()) {
        %>
            <tr>
                <form action="InventoryServlet" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                    <td><%= rs.getInt("id") %></td>
                    <td><input type="text" name="itemName" value="<%= rs.getString("item_name") %>"></td>
                    <td><input type="text" name="category" value="<%= rs.getString("category") %>"></td>
                    <td><input type="number" name="quantity" value="<%= rs.getInt("quantity") %>"></td>
                    <td>
                        <button type="submit">Update</button>
                        <a href="InventoryServlet?action=delete&id=<%= rs.getInt("id") %>" onclick="return confirm('Delete this item?');">Delete</a>
                    </td>
                </form>
            </tr>
        <%      }
            } catch (Exception e) { e.printStackTrace(); } finally { if (rs != null) try { rs.close(); } catch(SQLException e){} if (ps != null) try { ps.close(); } catch(SQLException e){} if (con != null) try { con.close(); } catch(SQLException e){} }
        %>
    </table>
</body>
</html>