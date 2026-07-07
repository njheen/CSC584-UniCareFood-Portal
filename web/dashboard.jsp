<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Verify the user is logged in
    User user = (User) session.getAttribute("currentUser");
    if (user == null) { response.sendRedirect("index.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head><title>Dashboard</title></head>
<body>
    <h2>Welcome, <%= user.getUsername() %> (<%= user.getRole() %>)</h2>
    
    <a href="inventory.jsp">Manage Inventory (CRUD)</a> | 
    
    <%-- Only show these links if the user is STAFF --%>
    <% if ("STAFF".equals(user.getRole())) { %>
        <a href="staff_requests.jsp">Manage Voucher Requests</a> | 
        <a href="manage_users.jsp">Manage Users</a> | 
        <a href="staff_register.jsp">Register New Staff</a> |
    <% } %>
    
    <a href="AuthServlet?action=logout">Logout</a>
    <hr>
    
    <h3>System Dashboard</h3>
    <%
        Connection con = null;
        Statement stmt = null;
        ResultSet rsTotal = null;
        ResultSet rsCategory = null;
        try {
            con = DBConnection.getConnection();
            stmt = con.createStatement();
            
            rsTotal = stmt.executeQuery("SELECT SUM(quantity) as total FROM Inventory");
            if(rsTotal.next()) {
    %>
                <p><strong>Total Items in Food Bank:</strong> <%= rsTotal.getInt("total") %></p>
    <%      }
            
            rsCategory = stmt.executeQuery("SELECT category, SUM(quantity) as cat_total FROM Inventory GROUP BY category");
    %>
            <h4>Inventory by Category:</h4>
            <ul>
    <%      while(rsCategory.next()) { %>
                <li><%= rsCategory.getString("category") %>: <%= rsCategory.getInt("cat_total") %></li>
    <%      } %>
            </ul>
    <%  
        } catch (Exception e) { 
            e.printStackTrace(); 
        } finally {
            if (rsTotal != null) try { rsTotal.close(); } catch(SQLException e) {}
            if (rsCategory != null) try { rsCategory.close(); } catch(SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch(SQLException e) {}
            if (con != null) try { con.close(); } catch(SQLException e) {}
        }
    %>
</body>
</html>