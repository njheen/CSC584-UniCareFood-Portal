package controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import models.DBConnection;
import models.User;

@WebServlet(name = "UserServlet", urlPatterns = {"/UserServlet"})
public class UserServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        Connection con = null; PreparedStatement ps = null;
        
        try {
            con = DBConnection.getConnection();
            
            // --- ADMIN UPDATING USERS ---
            if ("update".equals(action)) {
                String role = request.getParameter("role");
                String id = request.getParameter("id"); 
                
                if ("STAFF".equals(role) || "ADMIN".equals(role)) {
                    ps = con.prepareStatement("UPDATE Staff SET role=?, password=? WHERE staff_id=?");
                    ps.setString(1, request.getParameter("newRole")); ps.setString(2, request.getParameter("password")); ps.setString(3, id);
                } else if ("DONOR".equals(role)) {
                    ps = con.prepareStatement("UPDATE Donors SET name=?, phone_num=?, password=? WHERE email=?");
                    ps.setString(1, request.getParameter("name")); ps.setString(2, request.getParameter("phone")); ps.setString(3, request.getParameter("password")); ps.setString(4, id);
                } else if ("STUDENT".equals(role)) {
                    ps = con.prepareStatement("UPDATE Students SET name=?, email=?, phone_num=?, password=? WHERE student_id=?");
                    ps.setString(1, request.getParameter("name")); ps.setString(2, request.getParameter("email")); ps.setString(3, request.getParameter("phone")); ps.setString(4, request.getParameter("password")); ps.setString(5, id);
                }
                if (ps != null) ps.executeUpdate();
                response.sendRedirect("manage_users.jsp?msg=User updated successfully.");
            }
            
            // --- USER UPDATING OWN PROFILE ---
            else if ("updateProfile".equals(action)) {
                User user = (User) request.getSession().getAttribute("currentUser");
                if ("DONOR".equals(user.getRole())) {
                    ps = con.prepareStatement("UPDATE Donors SET name=?, phone_num=?, password=? WHERE email=?");
                    ps.setString(1, request.getParameter("name")); ps.setString(2, request.getParameter("phone")); ps.setString(3, request.getParameter("password")); ps.setString(4, user.getLoginId());
                } else if ("STUDENT".equals(user.getRole())) {
                    ps = con.prepareStatement("UPDATE Students SET name=?, email=?, phone_num=?, password=? WHERE student_id=?");
                    ps.setString(1, request.getParameter("name")); ps.setString(2, request.getParameter("email")); ps.setString(3, request.getParameter("phone")); ps.setString(4, request.getParameter("password")); ps.setString(5, user.getLoginId());
                }
                if (ps != null) ps.executeUpdate();
                
                // Update session name
                user.setName(request.getParameter("name"));
                request.getSession().setAttribute("currentUser", user);
                response.sendRedirect("profile.jsp?msg=Profile Updated Successfully");
            }
            
        } catch (SQLException e) { e.printStackTrace(); } 
        finally { if (ps != null) try { ps.close(); } catch(SQLException e){} if (con != null) try { con.close(); } catch(SQLException e){} }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        Connection con = null; PreparedStatement ps = null;
        
        try {
            con = DBConnection.getConnection();
            
            // Delete logic (Works for both Admin deleting users, and Users deleting themselves)
            if ("delete".equals(action) || "deleteProfile".equals(action)) {
                String role = request.getParameter("role");
                String id = request.getParameter("id");
                
                if ("STUDENT".equals(role)) {
                    // 1. Delete their voucher requests first!
                    ps = con.prepareStatement("DELETE FROM VoucherRequests WHERE student_id=?");
                    ps.setString(1, id); ps.executeUpdate(); ps.close();
                    // 2. Delete the student
                    ps = con.prepareStatement("DELETE FROM Students WHERE student_id=?");
                } else if ("DONOR".equals(role)) {
                    // 1. Anonymize their donations!
                    ps = con.prepareStatement("UPDATE Inventory SET donor_email = NULL WHERE donor_email=?");
                    ps.setString(1, id); ps.executeUpdate(); ps.close();
                    // 2. Delete the donor
                    ps = con.prepareStatement("DELETE FROM Donors WHERE email=?");
                } else if ("STAFF".equals(role) || "ADMIN".equals(role)) {
                    ps = con.prepareStatement("DELETE FROM Staff WHERE staff_id=?");
                }
                
                if (ps != null) { ps.setString(1, id); ps.executeUpdate(); }
                
                // If they deleted themselves, log them out
                if ("deleteProfile".equals(action)) {
                    request.getSession().invalidate();
                    response.sendRedirect("index.jsp?msg=Your profile and associated data have been deleted.");
                    return;
                } else {
                    response.sendRedirect("manage_users.jsp?msg=User deleted successfully.");
                }
            }
        } catch (SQLException e) { e.printStackTrace(); } 
        finally { if (ps != null) try { ps.close(); } catch(SQLException e){} if (con != null) try { con.close(); } catch(SQLException e){} }
    }
}