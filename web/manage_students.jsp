<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || (!"STAFF".equals(user.getRole()) && !"ADMIN".equals(user.getRole()))) { 
        response.sendRedirect("index.jsp"); return; 
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Students - UniCare Food Portal</title>
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
            <h1>Student Beneficiary Records</h1>
        </div>

        <!-- System Message Bar (Displays messages passed via request parameter) -->
        <% if (request.getParameter("msg") != null) { %>
            <div class="alert alert-success">
                <i class="fa fa-check-circle"></i> <%= request.getParameter("msg") %>
            </div>
        <% } %>

        <!-- Actions Bar -->
        <div style="margin-bottom: 20px;">
            <a href="student_register.jsp" class="btn btn-primary">
                <i class="fa fa-user-plus"></i> Register New Student
            </a>
        </div>

        <!-- Stylized Data Grid Container -->
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Student ID</th>
                        <th>Full Legal Name</th>
                        <th>Institutional Email</th>
                        <th>Contact Phone</th>
                        <th>Administrative Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Connection con = null;
                        Statement stmt = null;
                        ResultSet rs = null;
                        try {
                            con = DBConnection.getConnection();
                            stmt = con.createStatement();
                            rs = stmt.executeQuery("SELECT * FROM Students");
                            
                            boolean hasStudents = false;
                            while(rs.next()){
                                hasStudents = true;
                    %>
                        <tr>
                            <td><strong><%= rs.getString("student_id") %></strong></td>
                            <td><%= rs.getString("name") %></td>
                            <td><%= rs.getString("email") %></td>
                            <td><%= rs.getString("phone_num") %></td>
                            <td>
                                <a href="edit_user.jsp?id=<%= rs.getString("student_id") %>&role=STUDENT" class="btn btn-primary" style="padding: 6px 12px; font-size: 13px;">
                                    <i class="fa fa-edit"></i> Edit
                                </a>
                                <a href="UserServlet?action=delete&role=STUDENT&id=<%= rs.getString("student_id") %>" class="btn btn-danger" style="padding: 6px 12px; font-size: 13px;" onclick="return confirm('Are you sure you want to permanently delete this student record?');">
                                    <i class="fa fa-trash"></i> Delete
                                </a>
                            </td>
                        </tr>
                    <%      }
                            if (!hasStudents) { %>
                                <tr>
                                    <td colspan="5" style="text-align: center; color: #666; padding: 20px;">
                                        <i class="fa fa-user-slash" style="font-size: 24px; display: block; margin-bottom: 10px; color: #ccc;"></i>
                                        No students registered in the system database yet.
                                    </td>
                                </tr>
                    <%      }
                        } catch(Exception e) { 
                            e.printStackTrace(); 
                            out.print("<tr><td colspan='5' style='color:#991b1b; text-align:center; background:#fef2f2;'>Error processing query: " + e.getMessage() + "</td></tr>");
                        } finally {
                            if(rs != null) try { rs.close(); } catch(SQLException e) {}
                            if(stmt != null) try { stmt.close(); } catch(SQLException e) {}
                            if(con != null) try { con.close(); } catch(SQLException e) {}
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>
