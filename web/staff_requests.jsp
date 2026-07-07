<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"STAFF".equals(user.getRole())) { response.sendRedirect("index.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head><title>Manage Voucher Requests</title></head>
<body>
    <h2>Voucher Request Management</h2>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <hr>
    <p style="color:green;">${param.msg}</p>

    <table border="1" cellpadding="5">
        <tr>
            <th>ID</th>
            <th>Student Info</th>
            <th>Reason</th>
            <th>Current Status</th>
            <th>Action</th>
        </tr>
        <%
            Connection con = null; Statement stmt = null; ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                stmt = con.createStatement();
                // Join query to get the student's name and ID along with the request
                String query = "SELECT r.id, r.reason, r.status, u.full_name, u.student_id " +
                               "FROM VoucherRequests r JOIN Users u ON r.user_id = u.id";
                rs = stmt.executeQuery(query);
                while(rs.next()) {
        %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td>
                    Name: <%= rs.getString("full_name") %><br>
                    ID: <%= rs.getString("student_id") %>
                </td>
                <td><%= rs.getString("reason") %></td>
                <td><%= rs.getString("status") %></td>
                <td>
                    <form action="VoucherServlet" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="updateStatus">
                        <input type="hidden" name="requestId" value="<%= rs.getInt("id") %>">
                        <select name="status">
                            <option value="APPROVED">Approve</option>
                            <option value="REJECTED">Reject</option>
                            <option value="PENDING">Pending</option>
                        </select>
                        <button type="submit">Update</button>
                    </form>
                    |
                    <a href="VoucherServlet?action=delete&id=<%= rs.getInt("id") %>" onclick="return confirm('Delete this request?');">Delete</a>
                </td>
            </tr>
        <%      }
            } catch(Exception e) { e.printStackTrace(); }
            finally {
                if(rs != null) try { rs.close(); } catch(Exception e){}
                if(stmt != null) try { stmt.close(); } catch(Exception e){}
                if(con != null) try { con.close(); } catch(Exception e){}
            }
        %>
    </table>
</body>
</html>