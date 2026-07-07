<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Allow both STAFF and ADMIN
    User user = (User) session.getAttribute("currentUser");
    if (user == null || (!"STAFF".equals(user.getRole()) && !"ADMIN".equals(user.getRole()))) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }
%>
<!DOCTYPE html>
<html>
<head><title>Manage Voucher Requests</title></head>
<body>
    <h2>Voucher Request Management</h2>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <hr>
    <p style="color:green;">${param.msg}</p>

    <table border="1" cellpadding="5" cellspacing="0">
        <tr style="background-color: #f2f2f2;">
            <th>Req ID</th>
            <th>Student Name</th>
            <th>Student ID</th>
            <th>Reason</th>
            <th>Status</th>
            <th>Action</th>
        </tr>
        <%
            Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
            try {
                con = DBConnection.getConnection();
                // Join VoucherRequests with Students to get the student's name
                String query = "SELECT v.id, v.reason, v.status, s.name, s.student_id " +
                               "FROM VoucherRequests v JOIN Students s ON v.student_id = s.student_id";
                ps = con.prepareStatement(query);
                rs = ps.executeQuery();
                
                while(rs.next()) {
        %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("name") %></td>
                <td><%= rs.getString("student_id") %></td>
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
                    <a href="VoucherServlet?action=delete&id=<%= rs.getInt("id") %>" onclick="return confirm('Delete?');">Delete</a>
                </td>
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