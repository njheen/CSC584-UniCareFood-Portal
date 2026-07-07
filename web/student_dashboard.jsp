<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Verify user is a STUDENT
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"STUDENT".equals(user.getRole())) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }
%>
<!DOCTYPE html>
<html>
<head><title>Student Dashboard</title></head>
<body>
    <h2>Welcome, <%= user.getName() %> (Student)</h2>
    
    <a href="profile.jsp">My Profile</a> | 
    <a href="AuthServlet?action=logout">Logout</a>
    <hr>
    
    <p style="color:green;">${param.msg}</p>

    <h3>Request a Food Voucher</h3>
    <form action="VoucherServlet" method="post">
        <input type="hidden" name="action" value="requestVoucher">
        Reason for request:<br>
        <textarea name="reason" rows="4" cols="50" required></textarea><br><br>
        <button type="submit">Submit Request</button>
    </form>

    <hr>
    
    <h3>My Voucher Requests</h3>
    <table border="1" cellpadding="5">
        <tr style="background-color: #fcf8e3;">
            <th>Request ID</th>
            <th>Reason</th>
            <th>Status</th>
        </tr>
        <%
            // 1. Declare the database variables here
            Connection con = null; 
            PreparedStatement ps = null; 
            ResultSet rs = null;
            
            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement("SELECT * FROM VoucherRequests WHERE student_id = ?");
                ps.setString(1, user.getLoginId());
                rs = ps.executeQuery();
                
                while(rs.next()) {
        %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("reason") %></td>
                <td><strong><%= rs.getString("status") %></strong></td>
            </tr>
        <%      
                }
            } catch(Exception e) { 
                e.printStackTrace(); 
            } finally {
                // Close only the result set and statement so we can reuse the connection for the next table
                if(rs != null) try { rs.close(); } catch(Exception e){}
                if(ps != null) try { ps.close(); } catch(Exception e){}
            }
        %>
    </table>

    <hr>
    
    <h3>Available Food Stock</h3>
    <table border="1" cellpadding="5" width="50%">
        <tr style="background-color: #dff0d8;">
            <th>Item</th>
            <th>Category</th>
            <th>Quantity Available</th>
        </tr>
        <%
            try {
                // Reusing the 'con' connection from above
                ps = con.prepareStatement("SELECT item_name, category, SUM(quantity) as total_qty FROM Inventory GROUP BY item_name, category");
                rs = ps.executeQuery();
                
                while(rs.next()) {
        %>
            <tr>
                <td><%= rs.getString("item_name") %></td>
                <td><%= rs.getString("category") %></td>
                <td><%= rs.getInt("total_qty") %></td>
            </tr>
        <%      
                }
            } catch(Exception e) { 
                e.printStackTrace(); 
            } finally { 
                // 3. Now we close ALL connections at the very end
                if(rs != null) try { rs.close(); } catch(Exception e){}
                if(ps != null) try { ps.close(); } catch(Exception e){}
                if(con != null) try { con.close(); } catch(Exception e){}
            }
        %>
    </table>
</body>
</html>