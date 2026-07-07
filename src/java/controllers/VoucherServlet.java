package controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import models.DBConnection;
import models.User;

@WebServlet(name = "VoucherServlet", urlPatterns = {"/VoucherServlet"})
public class VoucherServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            con = DBConnection.getConnection();
            
            if ("requestVoucher".equals(action)) {
                User user = (User) request.getSession().getAttribute("currentUser");
                ps = con.prepareStatement("INSERT INTO VoucherRequests (user_id, reason) VALUES (?, ?)");
                ps.setInt(1, user.getId());
                ps.setString(2, request.getParameter("reason"));
                ps.executeUpdate();
                response.sendRedirect("student_dashboard.jsp?msg=Voucher requested successfully.");
                
            } else if ("updateStatus".equals(action)) {
                ps = con.prepareStatement("UPDATE VoucherRequests SET status=? WHERE id=?");
                ps.setString(1, request.getParameter("status"));
                ps.setInt(2, Integer.parseInt(request.getParameter("requestId")));
                ps.executeUpdate();
                response.sendRedirect("staff_requests.jsp?msg=Status updated.");
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        } finally {
            if (ps != null) try { ps.close(); } catch(SQLException e) {}
            if (con != null) try { con.close(); } catch(SQLException e) {}
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if ("delete".equals(request.getParameter("action"))) {
            Connection con = null;
            PreparedStatement ps = null;
            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement("DELETE FROM VoucherRequests WHERE id=?");
                ps.setInt(1, Integer.parseInt(request.getParameter("id")));
                ps.executeUpdate();
            } catch (SQLException e) { 
                e.printStackTrace(); 
            } finally {
                if (ps != null) try { ps.close(); } catch(SQLException e) {}
                if (con != null) try { con.close(); } catch(SQLException e) {}
            }
            response.sendRedirect("staff_requests.jsp?msg=Request deleted.");
        }
    }
}