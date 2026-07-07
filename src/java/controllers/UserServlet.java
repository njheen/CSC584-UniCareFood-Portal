package controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import models.DBConnection;

@WebServlet(name = "UserServlet", urlPatterns = {"/UserServlet"})
public class UserServlet extends HttpServlet {

    // Handles Updating the User
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("update".equals(action)) {
            Connection con = null;
            PreparedStatement ps = null;
            
            try {
                con = DBConnection.getConnection();
                
                String role = request.getParameter("role");
                String studentId = request.getParameter("studentId");
                
                // If role is changed to DONOR or STAFF, clear the student ID
                if (!"STUDENT".equals(role)) {
                    studentId = "N/A";
                }

                ps = con.prepareStatement("UPDATE Users SET username=?, role=?, full_name=?, student_id=?, email=?, phone=? WHERE id=?");
                ps.setString(1, request.getParameter("username"));
                ps.setString(2, role);
                ps.setString(3, request.getParameter("fullName"));
                ps.setString(4, studentId);
                ps.setString(5, request.getParameter("email"));
                ps.setString(6, request.getParameter("phone"));
                ps.setInt(7, Integer.parseInt(request.getParameter("id")));
                
                ps.executeUpdate();
                
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                if (con != null) try { con.close(); } catch (SQLException e) {}
            }
            response.sendRedirect("manage_users.jsp?msg=User updated successfully.");
        }
    }

    // Handles Deleting the User
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("delete".equals(action)) {
            Connection con = null;
            PreparedStatement ps = null;
            
            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement("DELETE FROM Users WHERE id=?");
                ps.setInt(1, Integer.parseInt(request.getParameter("id")));
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                if (con != null) try { con.close(); } catch (SQLException e) {}
            }
            response.sendRedirect("manage_users.jsp?msg=User deleted successfully.");
        }
    }
}