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
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        
        try {
            con = DBConnection.getConnection();
            
            // --- SMART LOGIN LOGIC ---
            if ("login".equals(action)) {
                String loginId = request.getParameter("loginId");
                String pass = request.getParameter("password");
                User loggedInUser = null;

                // 1. Check Students Table
                ps = con.prepareStatement("SELECT * FROM Students WHERE student_id=? AND password=?");
                ps.setString(1, loginId); ps.setString(2, pass);
                rs = ps.executeQuery();
                if (rs.next()) {
                    loggedInUser = new User();
                    loggedInUser.setLoginId(rs.getString("student_id"));
                    loggedInUser.setName(rs.getString("name"));
                    loggedInUser.setRole("STUDENT");
                }
                
                // 2. Check Donors Table if not found
                if (loggedInUser == null) {
                    ps = con.prepareStatement("SELECT * FROM Donors WHERE email=? AND password=?");
                    ps.setString(1, loginId); ps.setString(2, pass);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        loggedInUser = new User();
                        loggedInUser.setLoginId(rs.getString("email"));
                        loggedInUser.setName(rs.getString("name"));
                        loggedInUser.setRole("DONOR");
                    }
                }
                
                // 3. Check Staff Table if not found
                if (loggedInUser == null) {
                    ps = con.prepareStatement("SELECT * FROM Staff WHERE staff_id=? AND password=?");
                    ps.setString(1, loginId); ps.setString(2, pass);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        loggedInUser = new User();
                        loggedInUser.setLoginId(rs.getString("staff_id"));
                        loggedInUser.setName("Staff Member"); 
                        loggedInUser.setRole(rs.getString("role")); // STAFF or ADMIN
                    }
                }

                // Route the user
                if (loggedInUser != null) {
                    request.getSession().setAttribute("currentUser", loggedInUser);
                    if ("STUDENT".equals(loggedInUser.getRole())) {
                        response.sendRedirect("student_dashboard.jsp");
                    } else {
                        response.sendRedirect("dashboard.jsp");
                    }
                } else {
                    response.sendRedirect("index.jsp?error=Invalid Login Credentials");
                }
            } 
            
            // --- PUBLIC REGISTRATION LOGIC (STUDENTS & DONORS) ---
            else if ("publicRegister".equals(action)) {
                String role = request.getParameter("role");
                
                if ("STUDENT".equals(role)) {
                    ps = con.prepareStatement("INSERT INTO Students (student_id, name, email, phone_num, password) VALUES (?, ?, ?, ?, ?)");
                    ps.setString(1, request.getParameter("studentId"));
                    ps.setString(2, request.getParameter("name"));
                    ps.setString(3, request.getParameter("email"));
                    ps.setString(4, request.getParameter("phone"));
                    ps.setString(5, request.getParameter("password"));
                } else if ("DONOR".equals(role)) {
                    ps = con.prepareStatement("INSERT INTO Donors (email, name, phone_num, password) VALUES (?, ?, ?, ?)");
                    ps.setString(1, request.getParameter("email"));
                    ps.setString(2, request.getParameter("name"));
                    ps.setString(3, request.getParameter("phone"));
                    ps.setString(4, request.getParameter("password"));
                }
                ps.executeUpdate();
                response.sendRedirect("index.jsp?msg=Registration Success. Please Login.");
            }
            
            // --- INTERNAL REGISTRATION LOGIC (STAFF & ADMINS) ---
            else if ("staffRegister".equals(action)) {
                // Security check: Allow both STAFF and ADMIN
                User currentUser = (User) request.getSession().getAttribute("currentUser");
                if (currentUser != null && ("STAFF".equals(currentUser.getRole()) || "ADMIN".equals(currentUser.getRole()))) {
                    
                    String newRole = request.getParameter("role"); // "STAFF" or "ADMIN"
                    
                    ps = con.prepareStatement("INSERT INTO Staff (staff_id, role, password) VALUES (?, ?, ?)");
                    ps.setString(1, request.getParameter("staffId"));
                    ps.setString(2, newRole);
                    ps.setString(3, request.getParameter("password"));
                    
                    ps.executeUpdate();
                    response.sendRedirect("dashboard.jsp?msg=New " + newRole + " Account Created Successfully.");
                    
                } else {
                    response.sendRedirect("index.jsp?error=Unauthorized Access.");
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