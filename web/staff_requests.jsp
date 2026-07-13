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
<head>
    <title>Manage Voucher Requests - UniCare Food Portal</title>
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
            <h1>Voucher Request Management</h1>
        </div>

        <!-- Success Notification Box -->
        <% if (request.getParameter("msg") != null) { %>
            <div class="alert alert-success">
                <i class="fa fa-check-circle"></i> <%= request.getParameter("msg") %>
            </div>
        <% } %>

        <!-- Stylized Management Search / Filtering Tool -->
        <div class="form-container" style="max-width: 100%; margin-bottom: 30px; padding: 20px;">
            <form method="get" action="staff_requests.jsp" style="display: flex; flex-direction: column; gap: 15px;">
                <div style="display: flex; flex-wrap: wrap; gap: 20px;">
                    
                    <div style="flex: 1; min-width: 150px;">
                        <label style="font-weight: 600; color: #1E5E2F; margin-bottom: 6px; display: block;">Request Status</label>
                        <select name="status" class="form-control">
                            <option value="ALL" <%= "ALL".equals(statusFilter) ? "selected" : "" %>>All Requests</option>
                            <option value="PENDING" <%= "PENDING".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                            <option value="APPROVED" <%= "APPROVED".equals(statusFilter) ? "selected" : "" %>>Approved</option>
                            <option value="REJECTED" <%= "REJECTED".equals(statusFilter) ? "selected" : "" %>>Rejected</option>
                        </select>
                    </div>

                    <div style="flex: 1; min-width: 150px;">
                        <label style="font-weight: 600; color: #1E5E2F; margin-bottom: 6px; display: block;">Request ID</label>
                        <input type="text" name="searchReqId" value="<%= searchReqId %>" class="form-control" placeholder="e.g. 123">
                    </div>

                    <div style="flex: 1; min-width: 200px;">
                        <label style="font-weight: 600; color: #1E5E2F; margin-bottom: 6px; display: block;">Student Name</label>
                        <input type="text" name="searchName" value="<%= searchName %>" class="form-control" placeholder="e.g. John">
                    </div>

                    <div style="flex: 1; min-width: 180px;">
                        <label style="font-weight: 600; color: #1E5E2F; margin-bottom: 6px; display: block;">Student ID</label>
                        <input type="text" name="searchId" value="<%= searchId %>" class="form-control" placeholder="e.g. S001">
                    </div>
                </div>

                <div style="display: flex; gap: 10px; justify-content: flex-start; align-items: center; margin-top: 5px;">
                    <button type="submit" class="btn btn-primary">
                        <i class="fa fa-filter"></i> Filter Results
                    </button>
                    <a href="staff_requests.jsp" class="btn btn-danger" style="background: #64748b; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; height: 38px; padding: 0 16px;">
                        <i class="fa fa-undo" style="margin-right: 5px;"></i> Clear Filters
                    </a>
                </div>
            </form>
        </div>

        <!-- Stylized Data Grid Box -->
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Req ID</th>
                        <th>Student Name</th>
                        <th>Student ID</th>
                        <th>Reason for Request</th>
                        <th>Status</th>
                        <th>Administrative Actions</th>
                    </tr>
                </thead>
                <tbody>
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
                                String currentStatus = rs.getString("status");
                                
                                // Dynamic badge color based on status values
                                String badgeStyle = "background: #f1f5f9; color: #475569;";
                                if ("APPROVED".equals(currentStatus)) {
                                    badgeStyle = "background: #dcfce7; color: #15803d;";
                                } else if ("REJECTED".equals(currentStatus)) {
                                    badgeStyle = "background: #fee2e2; color: #b91c1c;";
                                } else if ("PENDING".equals(currentStatus)) {
                                    badgeStyle = "background: #fef9c3; color: #a16207;";
                                }
                    %>
                        <tr>
                            <td><strong><%= rs.getInt("id") %></strong></td>
                            <td><%= rs.getString("name") %></td>
                            <td><code><%= rs.getString("student_id") %></code></td>
                            <td><%= rs.getString("reason") %></td>
                            <td>
                                <span style="<%= badgeStyle %> padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold;">
                                    <%= currentStatus %>
                                </span>
                            </td>
                            <td>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <form action="VoucherServlet" method="post" style="display:inline-flex; gap: 5px; margin:0;">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="requestId" value="<%= rs.getInt("id") %>">
                                        <select name="status" class="form-control" style="padding: 4px 8px; font-size: 13px; width: auto; height: 32px;">
                                            <option value="APPROVED" <%= "APPROVED".equals(currentStatus) ? "selected" : "" %>>Approve</option>
                                            <option value="REJECTED" <%= "REJECTED".equals(currentStatus) ? "selected" : "" %>>Reject</option>
                                            <option value="PENDING" <%= "PENDING".equals(currentStatus) ? "selected" : "" %>>Pending</option>
                                        </select>
                                        <button type="submit" class="btn btn-primary" style="padding: 0 10px; font-size: 13px; height: 32px;">
                                            <i class="fa fa-save"></i> Update
                                        </button>
                                    </form>
                                    <a href="VoucherServlet?action=delete&id=<%= rs.getInt("id") %>" class="btn btn-danger" style="padding: 0 10px; font-size: 13px; height: 32px; text-decoration: none; display: inline-flex; align-items: center;" onclick="return confirm('Permanently remove this voucher request entry?');">
                                        <i class="fa fa-trash"></i> Delete
                                    </a>
                                </div>
                            </td>
                        </tr>
                    <%
                            }
                            if (!hasRows) {
                    %>
                            <tr>
                                <td colspan="6" style="text-align:center; color:#991b1b; padding: 20px; background: #fef2f2;">
                                    <i class="fa fa-folder-open" style="font-size: 24px; display: block; margin-bottom: 10px; color: #cca7a7;"></i>
                                    No voucher requests matched your active filtering parameters.
                                </td>
                            </tr>
                    <%
                            }
                        } catch (Exception e) { 
                            e.printStackTrace(); 
                            out.print("<tr><td colspan='6' style='color:#991b1b; text-align:center; background:#fef2f2;'>Operational exception caught: " + e.getMessage() + "</td></tr>");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (Exception e) {}
                            if (ps != null) try { ps.close(); } catch (Exception e) {}
                            if (con != null) try { con.close(); } catch (Exception e) {}
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
