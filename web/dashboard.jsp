<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || "STUDENT".equals(user.getRole())) { response.sendRedirect("index.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="style.css"> 
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
        }
        .stat-number {
            font-size: 2.2rem;
            font-weight: bold;
            color: #2c3e50;
        }
        .stat-label {
            font-size: 0.9rem;
            color: #6c757d;
            margin-top: 5px;
        }
        .chart-container {
            display: flex;
            flex-wrap: wrap;
            gap: 30px;
            margin: 20px 0;
            justify-content: center;
        }
        .chart-box {
            background: white;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            flex: 1 1 300px;
            max-width: 450px;
            min-width: 280px;
        }
        .chart-box h4 {
            text-align: center;
            margin-bottom: 10px;
            color: #34495e;
        }
        canvas {
            max-height: 300px;
            max-width: 100%;
        }
        .refresh-btn {
            background: #3498db;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            margin-bottom: 15px;
        }
        .refresh-btn:hover { background: #2980b9; }
    </style>
</head>
<body>
    
    
    <h2>Welcome, <%= user.getName() %> (<%= user.getRole() %>)</h2>
    
    <hr>
    <% if ("ADMIN".equalsIgnoreCase(user.getRole())) { %>
        <div style="background-color: #f0f0f0; padding: 10px; margin-bottom: 10px;">
            <strong>Admin Tools:</strong>
            <a href="manage_users.jsp">Manage All Users (Global)</a> | 
            <a href="staff_register.jsp">Register New Staff</a>
        </div>
    <% } %>

    <% if ("STAFF".equals(user.getRole()) || "ADMIN".equals(user.getRole())) { %>
        <a href="inventory.jsp">Manage Inventory</a> | 
        <a href="staff_requests.jsp">Manage Voucher Requests</a> | 
        <a href="manage_students.jsp">Manage Students</a> | 
        <a href="staff_profile.jsp">My Profile</a>
    <% } %>

    <% if ("DONOR".equals(user.getRole())) { %>
        <a href="donor_inventory.jsp">Manage My Donations</a> | 
        <a href="profile.jsp">My Profile</a>
    <% } %>

    <a href="AuthServlet?action=logout" style="color:red; float:right;">Logout</a>
    <hr>
    
    <%-- ===== STAFF/ADMIN DASHBOARD STATISTICS ===== --%>
    <% if ("STAFF".equals(user.getRole()) || "ADMIN".equals(user.getRole())) { 
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        int totalDonors = 0, totalCategories = 0, totalStudents = 0;
        int totalApplicants = 0, approvedApplicants = 0;
        try {
            con = DBConnection.getConnection();
            
            ps = con.prepareStatement("SELECT COUNT(*) FROM Donors");
            rs = ps.executeQuery();
            if (rs.next()) totalDonors = rs.getInt(1);
            rs.close(); ps.close();
            
            ps = con.prepareStatement("SELECT COUNT(DISTINCT category) FROM Inventory");
            rs = ps.executeQuery();
            if (rs.next()) totalCategories = rs.getInt(1);
            rs.close(); ps.close();
            
            ps = con.prepareStatement("SELECT COUNT(*) FROM Students");
            rs = ps.executeQuery();
            if (rs.next()) totalStudents = rs.getInt(1);
            rs.close(); ps.close();
            
            ps = con.prepareStatement("SELECT COUNT(DISTINCT student_id) FROM VoucherRequests");
            rs = ps.executeQuery();
            if (rs.next()) totalApplicants = rs.getInt(1);
            rs.close(); ps.close();
            
            ps = con.prepareStatement("SELECT COUNT(DISTINCT student_id) FROM VoucherRequests WHERE status = 'APPROVED'");
            rs = ps.executeQuery();
            if (rs.next()) approvedApplicants = rs.getInt(1);
            rs.close(); ps.close();
        } catch (Exception e) { e.printStackTrace(); } finally { if (con != null) try { con.close(); } catch(SQLException e){} }

        // ---- INVENTORY BY CATEGORY (Java 1.5 compatible) ----
        java.util.List<String> catList = new java.util.ArrayList<String>();
        java.util.List<Integer> qtyList = new java.util.ArrayList<Integer>();
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement("SELECT category, SUM(quantity) as total FROM Inventory GROUP BY category ORDER BY category");
            rs = ps.executeQuery();
            while (rs.next()) {
                catList.add(rs.getString("category"));
                qtyList.add(rs.getInt("total"));
            }
            rs.close(); ps.close();
        } catch (Exception e) { e.printStackTrace(); } finally { if (con != null) try { con.close(); } catch(SQLException e){} }
        
        // Convert Lists to arrays (Java 1.5 style)
        String[] categoryNames = new String[catList.size()];
        int[] categoryQuantities = new int[qtyList.size()];
        for (int i = 0; i < catList.size(); i++) {
            categoryNames[i] = catList.get(i);
            categoryQuantities[i] = qtyList.get(i);
        }

        // ---- VOUCHER STATUS DISTRIBUTION ----
        int[] statusCounts = new int[3]; // 0=PENDING, 1=APPROVED, 2=REJECTED
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement("SELECT status, COUNT(*) FROM VoucherRequests GROUP BY status");
            rs = ps.executeQuery();
            while (rs.next()) {
                String st = rs.getString(1);
                int cnt = rs.getInt(2);
                if ("PENDING".equalsIgnoreCase(st)) statusCounts[0] = cnt;
                else if ("APPROVED".equalsIgnoreCase(st)) statusCounts[1] = cnt;
                else if ("REJECTED".equalsIgnoreCase(st)) statusCounts[2] = cnt;
            }
            rs.close(); ps.close();
        } catch (Exception e) { e.printStackTrace(); } finally { if (con != null) try { con.close(); } catch(SQLException e){} }

        // ---- SEMESTER FILTER ----
        int month = java.util.Calendar.getInstance().get(java.util.Calendar.MONTH) + 1;
        String currentSemester = (month <= 6) ? "Semester 1" : "Semester 2";
        int semesterRequests = 0;
        try {
            con = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM VoucherRequests WHERE MONTH(request_date) BETWEEN ? AND ?";
            ps = con.prepareStatement(sql);
            if ("Semester 1".equals(currentSemester)) {
                ps.setInt(1, 1); ps.setInt(2, 6);
            } else {
                ps.setInt(1, 7); ps.setInt(2, 12);
            }
            rs = ps.executeQuery();
            if (rs.next()) semesterRequests = rs.getInt(1);
            rs.close(); ps.close();
        } catch (Exception e) { e.printStackTrace(); } finally { if (con != null) try { con.close(); } catch(SQLException e){} }
    %>
    <!-- STATISTICS SECTION -->
    <div style="background:#ecf0f1; padding:20px; border-radius:8px; margin-top:10px;">
        <h3>📊 Food Bank Dashboard Overview</h3>
        <p style="color:#7f8c8d;">Current Semester: <strong><%= currentSemester %></strong> &nbsp;|&nbsp; Requests this semester: <strong><%= semesterRequests %></strong></p>
        <button class="refresh-btn" onclick="location.reload();">⟳ Refresh Data</button>

        <!-- Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card"><div class="stat-number"><%= totalDonors %></div><div class="stat-label">👤 Donors</div></div>
            <div class="stat-card"><div class="stat-number"><%= totalCategories %></div><div class="stat-label">📦 Food Categories</div></div>
            <div class="stat-card"><div class="stat-number"><%= totalStudents %></div><div class="stat-label">🎓 Registered Students</div></div>
            <div class="stat-card"><div class="stat-number"><%= totalApplicants %></div><div class="stat-label">📝 Voucher Applicants</div></div>
            <div class="stat-card"><div class="stat-number"><%= approvedApplicants %></div><div class="stat-label">✅ Approved Students</div></div>
        </div>

        <!-- Charts -->
        <div class="chart-container">
            <div class="chart-box">
                <h4>🍽️ Inventory by Category</h4>
                <canvas id="categoryChart"></canvas>
            </div>
            <div class="chart-box">
                <h4>📋 Voucher Application Status</h4>
                <canvas id="voucherChart"></canvas>
            </div>
        </div>
    </div>

    <script>
        // ---- Donut Chart: Categories ----
        var catCtx = document.getElementById('categoryChart').getContext('2d');
        var categoryLabels = [
            <% for (String cat : categoryNames) { %>
                "<%= cat %>",
            <% } %>
        ];
        var categoryData = [
            <% for (int qty : categoryQuantities) { %>
                <%= qty %>,
            <% } %>
        ];
        function getColors(count) {
            var colors = [];
            for (var i = 0; i < count; i++) {
                var hue = (i * 360 / count) % 360;
                colors.push('hsl(' + hue + ', 70%, 60%)');
            }
            return colors;
        }
        var catColors = getColors(categoryLabels.length);

        new Chart(catCtx, {
            type: 'doughnut',
            data: {
                labels: categoryLabels,
                datasets: [{
                    data: categoryData,
                    backgroundColor: catColors,
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'right' }
                }
            }
        });

        // ---- Pie Chart: Voucher Status ----
        var voucherCtx = document.getElementById('voucherChart').getContext('2d');
        var statusLabels = ['Pending', 'Approved', 'Rejected'];
        var statusData = [
            <%= statusCounts[0] %>,
            <%= statusCounts[1] %>,
            <%= statusCounts[2] %>
        ];
        var statusColors = ['#f1c40f', '#2ecc71', '#e74c3c'];

        new Chart(voucherCtx, {
            type: 'pie',
            data: {
                labels: statusLabels,
                datasets: [{
                    data: statusData,
                    backgroundColor: statusColors,
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'right' }
                }
            }
        });
    </script>
    <% } // end if STAFF/ADMIN %>

</body>
</html>
