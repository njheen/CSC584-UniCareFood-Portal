<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"STUDENT".equals(user.getRole())) { response.sendRedirect("index.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head><title>Student Dashboard</title></head>
<body>
    <h2>Welcome, <%= user.getFullName() %> (Student)</h2>
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
        <tr><th>Request ID</th><th>Reason</th><th>Status</th></tr>
        <%
            Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement("SELECT * FROM VoucherRequests WHERE user_id = ?");
                ps.setInt(1, user.getId());
                rs = ps.executeQuery();
                while(rs.next()) {
        %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("reason") %></td>
                <td><strong><%= rs.getString("status") %></strong></td>
            </tr>
        <%      }
            } catch(Exception e) { e.printStackTrace(); } 
            finally {
                if(rs != null) try { rs.close(); } catch(Exception e){}
                if(ps != null) try { ps.close(); } catch(Exception e){}
                if(con != null) try { con.close(); } catch(Exception e){}
            }
        %>
    </table>
</body>
</html>