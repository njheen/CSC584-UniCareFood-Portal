package controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import models.DBConnection;

@WebServlet(name = "UserServlet", urlPatterns = {"/UserServlet"})
public class UserServlet extends HttpServlet {

    // --- HANDLES UPDATING USERS ---
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("update".equals(action)) {
            String role = request.getParameter("role");
            String id = request.getParameter("id"); // The unchanging Primary Key
            
            Connection con = null; PreparedStatement ps = null;
            try {
                con = DBConnection.getConnection();
                
                if ("STAFF".equals(role) || "ADMIN".equals(role)) {
                    ps = con.prepareStatement("UPDATE Staff SET role=?, password=? WHERE staff_id=?");
                    ps.setString(1, request.getParameter("newRole"));
                    ps.setString(2, request.getParameter("password"));
                    ps.setString(3, id);
                } 
                else if ("DONOR".equals(role)) {
                    ps = con.prepareStatement("UPDATE Donors SET name=?, phone_num=?, password=? WHERE email=?");
                    ps.setString(1, request.getParameter("name"));
                    ps.setString(2, request.getParameter("phone"));
                    ps.setString(3, request.getParameter("password"));
                    ps.setString(4, id);
                } 
                else if ("STUDENT".equals(role)) {
                    ps = con.prepareStatement("UPDATE Students SET name=?, email=?, phone_num=?, password=? WHERE student_id=?");
                    ps.setString(1, request.getParameter("name"));
                    ps.setString(2, request.getParameter("email"));
                    ps.setString(3, request.getParameter("phone"));
                    ps.setString(4, request.getParameter("password"));
                    ps.setString(5, id);
                }
                
                if (ps != null) {
                    ps.executeUpdate();
                }
                
            } catch (SQLException e) { 
                e.printStackTrace(); 
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                if (con != null) try { con.close(); } catch (SQLException e) {}
            }
            response.sendRedirect("manage_users.jsp?msg=User updated successfully.");
        }
    }

    // --- HANDLES DELETING USERS ---
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            String role = request.getParameter("role");
            String id = request.getParameter("id");
            
            Connection con = null; PreparedStatement ps = null;
            try {
                con = DBConnection.getConnection();
                if ("STUDENT".equals(role)) {
                    ps = con.prepareStatement("DELETE FROM Students WHERE student_id=?");
                } else if ("DONOR".equals(role)) {
                    ps = con.prepareStatement("DELETE FROM Donors WHERE email=?");
                } else if ("STAFF".equals(role) || "ADMIN".equals(role)) {
                    ps = con.prepareStatement("DELETE FROM Staff WHERE staff_id=?");
                }
                
                if (ps != null) {
                    ps.setString(1, id);
                    ps.executeUpdate();
                }
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