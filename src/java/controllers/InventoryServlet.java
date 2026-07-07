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
                ps = con.prepareStatement("INSERT INTO Inventory (item_name, category, quantity, donor_email) VALUES (?, ?, ?, ?)");
                ps.setString(1, request.getParameter("itemName"));
                ps.setString(2, request.getParameter("category"));
                ps.setInt(3, Integer.parseInt(request.getParameter("quantity")));
                
                // If a donor is adding it, link their email. Otherwise (Staff), leave NULL.
                if ("DONOR".equals(user.getRole())) {
                    ps.setString(4, user.getLoginId());
                } else {
                    ps.setNull(4, java.sql.Types.VARCHAR);
                }
                ps.executeUpdate();
                
            } else if ("update".equals(action)) {
                // Get all parameters
                String itemName = request.getParameter("itemName");
                String category = request.getParameter("category");
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                int id = Integer.parseInt(request.getParameter("id"));
                String donorEmail = request.getParameter("donorEmail");

                // If donorEmail is empty string, set to null (anonymous)
                if (donorEmail != null && donorEmail.trim().isEmpty()) {
                    donorEmail = null;
                }

                ps = con.prepareStatement(
                    "UPDATE Inventory SET item_name=?, category=?, quantity=?, donor_email=? WHERE id=?"
                );
                ps.setString(1, itemName);
                ps.setString(2, category);
                ps.setInt(3, quantity);
                if (donorEmail != null) {
                    ps.setString(4, donorEmail);
                } else {
                    ps.setNull(4, java.sql.Types.VARCHAR);
                }
                ps.setInt(5, id);
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