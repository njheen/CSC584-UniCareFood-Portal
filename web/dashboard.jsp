<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || "STUDENT".equals(user.getRole())) { response.sendRedirect("index.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - UniCare Food Portal</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
            <h1>Welcome, <%= user.getName() %>
                <span style="font-size:16px; color:#64748b; font-weight:500;">(<%= user.getRole() %>)</span>
            </h1>
        </div>

        <!-- Notification Boxes -->
        <% if (request.getParameter("msg") != null) { %>
            <div class="alert alert-success">
                <i class="fa fa-check-circle"></i> <%= request.getParameter("msg") %>
            </div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger">
                <i class="fa fa-triangle-exclamation"></i> <%= request.getParameter("error") %>
            </div>
        <% } %>

        <!-- ===== QUICK ACTIONS ===== -->
        <% if ("ADMIN".equalsIgnoreCase(user.getRole())) { %>
        <div class="form-container" style="max-width:100%; margin-bottom:20px; display:flex; gap:12px; flex-wrap:wrap; align-items:center;">
            <strong style="color:#1E5E2F; margin-right:6px;"><i class="fa fa-user-shield"></i> Admin Tools:</strong>
            <a href="manage_users.jsp" class="btn btn-primary"><i class="fa fa-users-gear"></i> Manage All Users</a>
            <a href="staff_register.jsp" class="btn btn-primary"><i class="fa fa-user-plus"></i> Register New Staff</a>
        </div>
        <% } %>

        <% if ("STAFF".equals(user.getRole()) || "ADMIN".equals(user.getRole())) { %>
        <div class="form-container" style="max-width:100%; margin-bottom:30px; display:flex; gap:12px; flex-wrap:wrap;">
            <a href="inventory.jsp" class="btn btn-primary"><i class="fa fa-boxes-stacked"></i> Manage Inventory</a>
            <a href="staff_requests.jsp" class="btn btn-primary"><i class="fa fa-ticket"></i> Manage Voucher Requests</a>
            <a href="manage_students.jsp" class="btn btn-primary"><i class="fa fa-user-graduate"></i> Manage Students</a>
            <a href="staff_profile.jsp" class="btn btn-primary" style="background:#64748b;"><i class="fa fa-id-badge"></i> My Profile</a>
        </div>
        <% } %>

        <% if ("DONOR".equals(user.getRole())) { %>
        <div class="form-container" style="max-width:100%; margin-bottom:30px; display:flex; gap:12px; flex-wrap:wrap;">
            <a href="donor_inventory.jsp" class="btn btn-primary"><i class="fa fa-hand-holding-heart"></i> Manage My Donations</a>
            <a href="profile.jsp" class="btn btn-primary" style="background:#64748b;"><i class="fa fa-id-badge"></i> My Profile</a>
        </div>
        <% } %>

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

        <!-- ===== STATISTICS SECTION ===== -->
        <div class="table-container" style="margin-bottom:30px;">
            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px; margin-bottom:6px;">
                <h2 style="color:#1E5E2F; font-size:20px; margin:0;"><i class="fa fa-chart-line"></i> Food Bank Dashboard Overview</h2>
                <button type="button" class="btn btn-primary" onclick="location.reload();"><i class="fa fa-rotate"></i> Refresh Data</button>
            </div>
            <p style="color:#64748b; margin:10px 0 20px;">
                Current Semester: <strong style="color:#1E5E2F;"><%= currentSemester %></strong>
                &nbsp;|&nbsp;
                Requests this semester: <strong style="color:#1E5E2F;"><%= semesterRequests %></strong>
            </p>

            <!-- Stats Cards -->
            <div class="cards">
                <div class="card">
                    <div class="icon"><i class="fa fa-user"></i></div>
                    <h3>Donors</h3>
                    <h1><%= totalDonors %></h1>
                </div>
                <div class="card">
                    <div class="icon"><i class="fa fa-box"></i></div>
                    <h3>Food Categories</h3>
                    <h1><%= totalCategories %></h1>
                </div>
                <div class="card">
                    <div class="icon"><i class="fa fa-user-graduate"></i></div>
                    <h3>Registered Students</h3>
                    <h1><%= totalStudents %></h1>
                </div>
                <div class="card">
                    <div class="icon"><i class="fa fa-clipboard-list"></i></div>
                    <h3>Voucher Applicants</h3>
                    <h1><%= totalApplicants %></h1>
                </div>
                <div class="card">
                    <div class="icon"><i class="fa fa-circle-check"></i></div>
                    <h3>Approved Students</h3>
                    <h1><%= approvedApplicants %></h1>
                </div>
            </div>

            <!-- Charts -->
            <div class="chart-section">
                <div class="chart-box">
                    <h2 style="font-size:17px;"><i class="fa fa-utensils"></i> Inventory by Category</h2>
                    <canvas id="categoryChart"></canvas>
                </div>
                <div class="chart-box">
                    <h2 style="font-size:17px;"><i class="fa fa-ticket"></i> Voucher Application Status</h2>
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

            // Palette anchored to the site's green theme, with rotating accents
            var themeColors = ['#1E5E2F', '#2e7d32', '#4CAF50', '#81C784', '#A5D6A7', '#F1C40F', '#3498DB', '#9B59B6'];
            function getColors(count) {
                var colors = [];
                for (var i = 0; i < count; i++) {
                    colors.push(themeColors[i % themeColors.length]);
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
            var statusColors = ['#f1c40f', '#1E5E2F', '#991b1b'];

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

    </div>
</body>
</html>
