<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) { response.sendRedirect("index.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head><title>Manage Inventory</title></head>
<body>
    <h2>Food Bank Inventory Management</h2>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <hr>
    
    <h3>Add New Contribution (Create)</h3>
    <form action="InventoryServlet" method="post">
        <input type="hidden" name="action" value="add">
        Item Name: <input type="text" name="itemName" required>
        Category: <input type="text" name="category" required>
        Quantity: <input type="number" name="quantity" required min="1">
        <button type="submit">Add Item</button>
    </form>
    
    <h3>Current Inventory (Read, Update, Delete)</h3>
    <table border="1" cellpadding="5">
        <tr style="background-color: #d9edf7;">
            <th>Item</th><th>Category</th><th>Qty</th><th>Donor Name</th><th>Donor Email</th><th>Donor Phone</th><th>Actions</th>
        </tr>
        <%
            // 1. Declare the variables with their types here
            Connection con = null;
            Statement stmt = null;
            ResultSet rs = null;
            
            try {
                con = DBConnection.getConnection();
                stmt = con.createStatement();
                // LEFT JOIN ensures items still show even if the donor was deleted (Anonymized)
                rs = stmt.executeQuery("SELECT i.*, d.name, d.phone_num FROM Inventory i LEFT JOIN Donors d ON i.donor_email = d.email");
                
                while (rs.next()) {
                    String donorName = rs.getString("name") != null ? rs.getString("name") : "Anonymous";
                    String donorEmail = rs.getString("donor_email") != null ? rs.getString("donor_email") : "-";
                    String donorPhone = rs.getString("phone_num") != null ? rs.getString("phone_num") : "-";
        %>
            <tr>
                <td><%= rs.getString("item_name") %></td>
                <td><%= rs.getString("category") %></td>
                <td><%= rs.getInt("quantity") %></td>
                <td><%= donorName %></td>
                <td><%= donorEmail %></td>
                <td><%= donorPhone %></td>
                <td>
                    <a href="InventoryServlet?action=delete&id=<%= rs.getInt("id") %>" onclick="return confirm('Delete?');">Delete</a>
                </td>
            </tr>
        <%      
                }
            } catch (Exception e) { 
                e.printStackTrace(); 
            } finally {
                // 2. Always close resources to prevent database leaks
                if (rs != null) try { rs.close(); } catch(SQLException e) {}
                if (stmt != null) try { stmt.close(); } catch(SQLException e) {}
                if (con != null) try { con.close(); } catch(SQLException e) {}
            }
        %>
    </table>
</body>
</html>