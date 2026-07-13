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

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String action = request.getParameter("action");
        String returnPage = "DONOR".equals(user.getRole()) ? "donor_inventory.jsp" : "inventory.jsp";
        String msg = null;

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnection.getConnection();

            if ("add".equals(action)) {
                String itemName = request.getParameter("itemName");
                String category = request.getParameter("category");
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                String expiryDate = request.getParameter("expiryDate");

                String sql = "INSERT INTO Inventory (item_name, category, quantity, expiry_date, donor_email) VALUES (?, ?, ?, ?, ?)";
                ps = con.prepareStatement(sql);
                ps.setString(1, itemName);
                ps.setString(2, category);
                ps.setInt(3, quantity);
                if (expiryDate != null && !expiryDate.isEmpty()) {
                    ps.setDate(4, Date.valueOf(expiryDate));
                } else {
                    ps.setNull(4, Types.DATE);
                }
                // Donors get their email; staff/admin can add without donor (set NULL)
                if ("DONOR".equals(user.getRole())) {
                    ps.setString(5, user.getLoginId());
                } else {
                    ps.setNull(5, Types.VARCHAR);
                }
                ps.executeUpdate();
                msg = "Item added successfully.";

            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String itemName = request.getParameter("itemName");
                String category = request.getParameter("category");
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                String expiryDate = request.getParameter("expiryDate");

                if ("DONOR".equals(user.getRole())) {
                    // Donor: update only their own item, never change donor_email
                    String sql = "UPDATE Inventory SET item_name=?, category=?, quantity=?, expiry_date=? WHERE id=? AND donor_email=?";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, itemName);
                    ps.setString(2, category);
                    ps.setInt(3, quantity);
                    if (expiryDate != null && !expiryDate.isEmpty()) {
                        ps.setDate(4, Date.valueOf(expiryDate));
                    } else {
                        ps.setNull(4, Types.DATE);
                    }
                    ps.setInt(5, id);
                    ps.setString(6, user.getLoginId());
                    int rows = ps.executeUpdate();
                    msg = (rows > 0) ? "Item updated successfully." : "Update failed – you may not own this item.";
                } else {
                    // Staff/Admin: update all fields, including donor_email
                    String donorEmail = request.getParameter("donorEmail");
                    String sql = "UPDATE Inventory SET item_name=?, category=?, quantity=?, expiry_date=?, donor_email=? WHERE id=?";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, itemName);
                    ps.setString(2, category);
                    ps.setInt(3, quantity);
                    if (expiryDate != null && !expiryDate.isEmpty()) {
                        ps.setDate(4, Date.valueOf(expiryDate));
                    } else {
                        ps.setNull(4, Types.DATE);
                    }
                    // If donorEmail is empty (the "None" option), set to NULL
                    if (donorEmail != null && !donorEmail.trim().isEmpty()) {
                        ps.setString(5, donorEmail);
                    } else {
                        ps.setNull(5, Types.VARCHAR);
                    }
                    ps.setInt(6, id);
                    int rows = ps.executeUpdate();
                    msg = (rows > 0) ? "Item updated successfully." : "Update failed – item not found.";
                }
            }
        } catch (NumberFormatException e) {
            msg = "Invalid number format for quantity or ID.";
        } catch (IllegalArgumentException e) {
            msg = "Invalid date format. Use yyyy-MM-dd.";
        } catch (SQLException e) {
            e.printStackTrace();
            msg = "Database error: " + e.getMessage();
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (con != null) try { con.close(); } catch (SQLException e) {}
        }

        // Store message and redirect
        session.setAttribute("inventoryMsg", msg);
        response.sendRedirect(returnPage);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String action = request.getParameter("action");
        String returnPage = "DONOR".equals(user.getRole()) ? "donor_inventory.jsp" : "inventory.jsp";
        String msg = null;

        if ("delete".equals(action)) {
            int id;
            try {
                id = Integer.parseInt(request.getParameter("id"));
            } catch (NumberFormatException e) {
                msg = "Invalid ID.";
                session.setAttribute("inventoryMsg", msg);
                response.sendRedirect(returnPage);
                return;
            }

            Connection con = null;
            PreparedStatement ps = null;
            try {
                con = DBConnection.getConnection();
                if ("DONOR".equals(user.getRole())) {
                    // Donor can only delete their own items
                    String sql = "DELETE FROM Inventory WHERE id=? AND donor_email=?";
                    ps = con.prepareStatement(sql);
                    ps.setInt(1, id);
                    ps.setString(2, user.getLoginId());
                } else {
                    // Staff/Admin can delete any item
                    String sql = "DELETE FROM Inventory WHERE id=?";
                    ps = con.prepareStatement(sql);
                    ps.setInt(1, id);
                }
                int rows = ps.executeUpdate();
                msg = (rows > 0) ? "Item deleted successfully." : "Delete failed – item not found or not owned.";
            } catch (SQLException e) {
                e.printStackTrace();
                msg = "Database error: " + e.getMessage();
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                if (con != null) try { con.close(); } catch (SQLException e) {}
            }
            session.setAttribute("inventoryMsg", msg);
        }
        response.sendRedirect(returnPage);
    }
}