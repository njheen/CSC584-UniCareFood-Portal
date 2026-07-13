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
<head>
    <title>Student Dashboard - UniCare Food Portal</title>
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
            <h1>Welcome, <%= user.getName() %></h1>
        </div>

        <!-- System Message Banner -->
        <% if (request.getParameter("msg") != null) { %>
            <div class="alert alert-success">
                <i class="fa fa-check-circle"></i> <%= request.getParameter("msg") %>
            </div>
        <% } %>

        <!-- Row Grid Layout: Balancing Voucher Request Form & Available Stock View -->
        <div style="display: flex; flex-wrap: wrap; gap: 30px; margin-bottom: 40px;">
            
            <!-- Column 1: Voucher Submission Application Card -->
            <div style="flex: 1; min-width: 300px;">
                <h2 style="color: #1E5E2F; font-size: 20px; margin-bottom: 15px;"><i class="fa fa-ticket-alt"></i> Request a Food Voucher</h2>
                <div class="form-container" style="max-width: 100%; padding: 20px; height: calc(100% - 40px);">
                    <form action="VoucherServlet" method="post">
                        <input type="hidden" name="action" value="requestVoucher">
                        
                        <div class="form-group">
                            <label style="font-weight: 600; color: #333; margin-bottom: 8px; display: block;">Justification / Reason for Request</label>
                            <textarea name="reason" class="form-control" rows="5" placeholder="Provide a brief explanation of your current financial or emergency needs to support this request..." required style="resize: vertical;"></textarea>
                        </div>
                        
                        <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 10px;">
                            <i class="fa fa-paper-plane"></i> Submit Request Application
                        </button>
                    </form>
                </div>
            </div>

            <!-- Column 2: Available Real-Time Food Stock Card -->
            <div style="flex: 1.5; min-width: 400px;">
                <h2 style="color: #1E5E2F; font-size: 20px; margin-bottom: 15px;"><i class="fa fa-boxes"></i> Available Pantry Stock Summary</h2>
                <div class="table-container" style="margin: 0; max-height: 295px; overflow-y: auto;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Item Name</th>
                                <th>Category Group</th>
                                <th>Quantity Available</th>
                                <th>Earliest Expiry</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection con = null; 
                                PreparedStatement ps = null; 
                                ResultSet rs = null;
                                boolean hasStock = false;
                                
                                try {
                                    con = DBConnection.getConnection();
                                    ps = con.prepareStatement(
                                        "SELECT item_name, category, SUM(quantity) as total_qty, MIN(expiry_date) as earliest_expiry " +
                                        "FROM Inventory GROUP BY item_name, category"
                                    );
                                    rs = ps.executeQuery();
                                    while(rs.next()) {
                                        hasStock = true;
                                        String expiry = rs.getDate("earliest_expiry") != null ? rs.getDate("earliest_expiry").toString() : "-";
                            %>
                                <tr>
                                    <td><strong><%= rs.getString("item_name") %></strong></td>
                                    <td><span style="background: #e2e8f0; color: #475569; padding: 2px 6px; border-radius: 4px; font-size: 12px;"><%= rs.getString("category") %></span></td>
                                    <td><span style="font-weight: bold; color: <%= rs.getInt("total_qty") > 5 ? "#15803d" : "#b91c1c" %>;"><%= rs.getInt("total_qty") %></span></td>
                                    <td><code><%= expiry %></code></td>
                                </tr>
                            <%      
                                    }
                                    if(!hasStock) {
                            %>
                                <tr>
                                    <td colspan="4" style="text-align: center; color: #94a3b8; padding: 20px;">No food items are currently compiled in the center inventory.</td>
                                </tr>
                            <%
                                    }
                                } catch(Exception e) { 
                                    e.printStackTrace(); 
                                } finally {
                                    if(rs != null) try { rs.close(); } catch(Exception e){}
                                    if(ps != null) try { ps.close(); } catch(Exception e){}
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>

        <!-- Section 3: Historical Voucher Tracking Log -->
        <h2 style="color: #1E5E2F; font-size: 20px; margin-bottom: 15px;"><i class="fa fa-history"></i> My Voucher Request History Logs</h2>
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 120px;">Request ID</th>
                        <th>Stated Reason</th>
                        <th style="width: 180px;">Application Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            ps = con.prepareStatement("SELECT * FROM VoucherRequests WHERE student_id = ? ORDER BY id DESC");
                            ps.setString(1, user.getLoginId());
                            rs = ps.executeQuery();
                            
                            boolean hasRequests = false;
                            while(rs.next()) {
                                hasRequests = true;
                                String status = rs.getString("status");
                                
                                // Dynamic CSS styling for badges based on voucher status entries
                                String badgeClass = "background: #f1f5f9; color: #475569;";
                                if ("APPROVED".equals(status)) {
                                    badgeClass = "background: #dcfce7; color: #15803d;";
                                } else if ("REJECTED".equals(status)) {
                                    badgeClass = "background: #fee2e2; color: #b91c1c;";
                                } else if ("PENDING".equals(status)) {
                                    badgeClass = "background: #fef9c3; color: #a16207;";
                                }
                    %>
                        <tr>
                            <td><code>#<%= rs.getInt("id") %></code></td>
                            <td><%= rs.getString("reason") %></td>
                            <td>
                                <span style="<%= badgeClass %> padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; display: inline-block;">
                                    <%= status %>
                                </span>
                            </td>
                        </tr>
                    <%      
                            }
                            if(!hasRequests) {
                    %>
                        <tr>
                            <td colspan="3" style="text-align: center; color: #94a3b8; padding: 30px;">
                                <i class="fa fa-receipt" style="font-size: 28px; display: block; margin-bottom: 10px; color: #cbd5e1;"></i>
                                You have not submitted any food voucher applications yet.
                            </td>
                        </tr>
                    <%
                            }
                        } catch(Exception e) { 
                            e.printStackTrace(); 
                        } finally {
                            if(rs != null) try { rs.close(); } catch(Exception e){}
                            if(ps != null) try { ps.close(); } catch(Exception e){}
                            if(con != null) try { con.close(); } catch(Exception e){}
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
