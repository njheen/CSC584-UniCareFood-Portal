<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Allow both STAFF and ADMIN
    User user = (User) session.getAttribute("currentUser");
    if (user == null || (!"STAFF".equals(user.getRole()) && !"ADMIN".equals(user.getRole()))) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }

    // --- Get filter parameters ---
    String statusFilter = request.getParameter("status");
    String searchReqId = request.getParameter("searchReqId");
    String searchName = request.getParameter("searchName");
    String searchId = request.getParameter("searchId");

    // Set defaults
    if (statusFilter == null || statusFilter.trim().isEmpty()) statusFilter = "ALL";
    if (searchReqId == null) searchReqId = "";
    if (searchName == null) searchName = "";
    if (searchId == null) searchId = "";

    // Clean inputs
    searchReqId = searchReqId.trim();
    searchName = searchName.trim();
    searchId = searchId.trim();
%>
<!DOCTYPE html>
<html>
<head><title>Manage Voucher Requests</title></head>
<body>
    <h2>Voucher Request Management</h2>
    <a href="dashboard.jsp">Back to Dashboard</a>
    <hr>
    <p style="color:green;">${param.msg}</p>

    <!-- FILTER FORM -->
    <form method="get" action="staff_requests.jsp" style="background:#f5f5f5; padding:15px; border-radius:5px; margin-bottom:20px;">
        <table>
            <tr>
                <td><strong>Status:</strong></td>
                <td>
                    <select name="status">
                        <option value="ALL" <%= "ALL".equals(statusFilter) ? "selected" : "" %>>All</option>
                        <option value="PENDING" <%= "PENDING".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                        <option value="APPROVED" <%= "APPROVED".equals(statusFilter) ? "selected" : "" %>>Approved</option>
                        <option value="REJECTED" <%= "REJECTED".equals(statusFilter) ? "selected" : "" %>>Rejected</option>
                    </select>
                </td>
                <td><strong>Request ID:</strong></td>
                <td><input type="text" name="searchReqId" value="<%= searchReqId %>" placeholder="e.g. 123"></td>
            </tr>
            <tr>
                <td><strong>Student Name:</strong></td>
                <td><input type="text" name="searchName" value="<%= searchName %>" placeholder="e.g. John"></td>
                <td><strong>Student ID:</strong></td>
                <td><input type="text" name="searchId" value="<%= searchId %>" placeholder="e.g. S001"></td>
            </tr>
            <tr>
                <td colspan="4" style="padding-top:10px;">
                    <button type="submit">Filter</button>
                    <a href="staff_requests.jsp" style="margin-left:10px;">Clear Filters</a>
                </td>
            </tr>
        </table>
    </form>

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
            Connection con = null; 
            PreparedStatement ps = null; 
            ResultSet rs = null;
            
            try {
                con = DBConnection.getConnection();
                
                // --- Build dynamic SQL ---
                StringBuilder sql = new StringBuilder(
                    "SELECT v.id, v.reason, v.status, s.name, s.student_id " +
                    "FROM VoucherRequests v JOIN Students s ON v.student_id = s.student_id WHERE 1=1"
                );
                
                // Use ArrayList to hold parameters
                java.util.List<String> paramValues = new java.util.ArrayList<String>();
                
                // Status filter
                if (!"ALL".equals(statusFilter)) {
                    sql.append(" AND v.status = ?");
                    paramValues.add(statusFilter);
                }
                
                // Request ID (exact match)
                if (!searchReqId.isEmpty()) {
                    sql.append(" AND v.id = ?");
                    paramValues.add(searchReqId);
                }
                
                // Student name (case‑insensitive partial match)
                if (!searchName.isEmpty()) {
                    sql.append(" AND LOWER(s.name) LIKE ?");
                    paramValues.add("%" + searchName.toLowerCase() + "%");
                }
                
                // Student ID (case‑insensitive partial match)
                if (!searchId.isEmpty()) {
                    sql.append(" AND LOWER(s.student_id) LIKE ?");
                    paramValues.add("%" + searchId.toLowerCase() + "%");
                }
                
                // Order by request ID descending (newest first)
                sql.append(" ORDER BY v.id DESC");
                
                ps = con.prepareStatement(sql.toString());
                
                // Set parameters
                for (int i = 0; i < paramValues.size(); i++) {
                    ps.setString(i + 1, paramValues.get(i));
                }
                
                rs = ps.executeQuery();
                
                boolean hasRows = false;
                while (rs.next()) {
                    hasRows = true;
        %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("name") %></td>
                <td><%= rs.getString("student_id") %></td>
                <td><%= rs.getString("reason") %></td>
                <td><strong><%= rs.getString("status") %></strong></td>
                <td>
                    <form action="VoucherServlet" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="updateStatus">
                        <input type="hidden" name="requestId" value="<%= rs.getInt("id") %>">
                        <select name="status">
                            <option value="APPROVED" <%= "APPROVED".equals(rs.getString("status")) ? "selected" : "" %>>Approve</option>
                            <option value="REJECTED" <%= "REJECTED".equals(rs.getString("status")) ? "selected" : "" %>>Reject</option>
                            <option value="PENDING" <%= "PENDING".equals(rs.getString("status")) ? "selected" : "" %>>Pending</option>
                        </select>
                        <button type="submit">Update</button>
                    </form>
                    <a href="VoucherServlet?action=delete&id=<%= rs.getInt("id") %>" onclick="return confirm('Delete?');">Delete</a>
                </td>
            </tr>
        <%
                }
                if (!hasRows) {
                    out.print("<tr><td colspan='6' style='text-align:center;color:red;'>No requests match your filters.</td></tr>");
                }
            } catch (Exception e) { 
                e.printStackTrace(); 
            } finally {
                if (rs != null) try { rs.close(); } catch (Exception e) {}
                if (ps != null) try { ps.close(); } catch (Exception e) {}
                if (con != null) try { con.close(); } catch (Exception e) {}
            }
        %>
    </table>
</body>
</html>