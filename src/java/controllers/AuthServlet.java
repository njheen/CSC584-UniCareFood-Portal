package controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import models.DBConnection;
import models.User;

@WebServlet(name = "AuthServlet", urlPatterns = {"/AuthServlet"})
public class AuthServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = DBConnection.getConnection();
            
            // Handles both Student and Donor public registration
            if ("publicRegister".equals(action)) {
                String role = request.getParameter("role"); // Will be "STUDENT" or "DONOR"
                String studentId = request.getParameter("studentId");
                
                // If it's a donor, student_id will be blank/null. 
                if ("DONOR".equals(role)) {
                    studentId = "N/A";
                }
                
                ps = con.prepareStatement("INSERT INTO Users (username, password, role, full_name, student_id, email, phone) VALUES (?, ?, ?, ?, ?, ?, ?)");
                ps.setString(1, user);
                ps.setString(2, pass);
                ps.setString(3, role);
                ps.setString(4, request.getParameter("fullName"));
                ps.setString(5, studentId);
                ps.setString(6, request.getParameter("email"));
                ps.setString(7, request.getParameter("phone"));
                ps.executeUpdate();
                response.sendRedirect("index.jsp?msg=Registration Success. Please Login.");
                
            } 
            // Handles internal Staff registration
            else if ("staffRegister".equals(action)) {
                // Double check session authorization
                User currentUser = (User) request.getSession().getAttribute("currentUser");
                if (currentUser != null && "STAFF".equals(currentUser.getRole())) {
                    ps = con.prepareStatement("INSERT INTO Users (username, password, role, full_name, student_id, email, phone) VALUES (?, ?, 'STAFF', ?, 'N/A', ?, ?)");
                    ps.setString(1, user);
                    ps.setString(2, pass);
                    ps.setString(3, request.getParameter("fullName"));
                    ps.setString(4, request.getParameter("email"));
                    ps.setString(5, request.getParameter("phone"));
                    ps.executeUpdate();
                    response.sendRedirect("dashboard.jsp?msg=New Staff Registered Successfully.");
                } else {
                    response.sendRedirect("index.jsp?error=Unauthorized Access.");
                }
                
            } 
            // Handles Login
            else if ("login".equals(action)) {
                ps = con.prepareStatement("SELECT * FROM Users WHERE username=? AND password=?");
                ps.setString(1, user);
                ps.setString(2, pass);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    User loggedInUser = new User();
                    loggedInUser.setId(rs.getInt("id"));
                    loggedInUser.setUsername(rs.getString("username"));
                    loggedInUser.setRole(rs.getString("role"));
                    loggedInUser.setFullName(rs.getString("full_name"));
                    
                    HttpSession session = request.getSession();
                    session.setAttribute("currentUser", loggedInUser);
                    
                    // Redirect based on role
                    if ("STUDENT".equals(loggedInUser.getRole())) {
                        response.sendRedirect("student_dashboard.jsp");
                    } else {
                        response.sendRedirect("dashboard.jsp"); // Staff and Donors go to main dashboard
                    }
                } else {
                    response.sendRedirect("index.jsp?error=Invalid Credentials");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=Database Error");
        } finally {
            if (rs != null) try { rs.close(); } catch(SQLException e) {}
            if (ps != null) try { ps.close(); } catch(SQLException e) {}
            if (con != null) try { con.close(); } catch(SQLException e) {}
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if ("logout".equals(request.getParameter("action"))) {
            HttpSession session = request.getSession(false);
            if (session != null) session.invalidate();
            response.sendRedirect("index.jsp?msg=Logged Out Successfully");
        }
    }
}