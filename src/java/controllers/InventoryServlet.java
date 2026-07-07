package controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import models.DBConnection;
import models.User;

@WebServlet(name = "InventoryServlet", urlPatterns = {"/InventoryServlet"})
public class InventoryServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String action = request.getParameter("action");
    User user = (User) request.getSession().getAttribute("currentUser");
    String returnPage = "DONOR".equals(user.getRole()) ? "donor_inventory.jsp" : "inventory.jsp";
    
    Connection con = null; PreparedStatement ps = null;
    try {
        con = DBConnection.getConnection();
        if ("add".equals(action)) {
            String itemName = request.getParameter("itemName");
            String category = request.getParameter("category");
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String expiryDate = request.getParameter("expiryDate"); // format yyyy-MM-dd
            
            ps = con.prepareStatement("INSERT INTO Inventory (item_name, category, quantity, expiry_date, donor_email) VALUES (?, ?, ?, ?, ?)");
            ps.setString(1, itemName);
            ps.setString(2, category);
            ps.setInt(3, quantity);
            if (expiryDate != null && !expiryDate.isEmpty()) {
                ps.setDate(4, java.sql.Date.valueOf(expiryDate));
            } else {
                ps.setNull(4, java.sql.Types.DATE);
            }
            if ("DONOR".equals(user.getRole())) {
                ps.setString(5, user.getLoginId());
            } else {
                ps.setNull(5, java.sql.Types.VARCHAR);
            }
            ps.executeUpdate();
            
        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String itemName = request.getParameter("itemName");
            String category = request.getParameter("category");
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String expiryDate = request.getParameter("expiryDate");
            String donorEmail = request.getParameter("donorEmail");
            if (donorEmail != null && donorEmail.trim().isEmpty()) donorEmail = null;
            
            ps = con.prepareStatement(
                "UPDATE Inventory SET item_name=?, category=?, quantity=?, expiry_date=?, donor_email=? WHERE id=?"
            );
            ps.setString(1, itemName);
            ps.setString(2, category);
            ps.setInt(3, quantity);
            if (expiryDate != null && !expiryDate.isEmpty()) {
                ps.setDate(4, java.sql.Date.valueOf(expiryDate));
            } else {
                ps.setNull(4, java.sql.Types.DATE);
            }
            if (donorEmail != null) {
                ps.setString(5, donorEmail);
            } else {
                ps.setNull(5, java.sql.Types.VARCHAR);
            }
            ps.setInt(6, id);
            ps.executeUpdate();
        }
    } catch (SQLException e) { e.printStackTrace(); } 
    finally { if (ps != null) try { ps.close(); } catch(SQLException e){} if (con != null) try { con.close(); } catch(SQLException e){} }
    response.sendRedirect(returnPage);
}

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("currentUser");
        String returnPage = "DONOR".equals(user.getRole()) ? "donor_inventory.jsp" : "inventory.jsp";
        
        if ("delete".equals(request.getParameter("action"))) {
            Connection con = null; PreparedStatement ps = null;
            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement("DELETE FROM Inventory WHERE id=?");
                ps.setInt(1, Integer.parseInt(request.getParameter("id")));
                ps.executeUpdate();
            } catch (SQLException e) { e.printStackTrace(); }
            finally { if (ps != null) try { ps.close(); } catch(SQLException e){} if (con != null) try { con.close(); } catch(SQLException e){} }
            response.sendRedirect(returnPage);
        }
    }
}