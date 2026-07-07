package controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import models.DBConnection;

@WebServlet(name = "InventoryServlet", urlPatterns = {"/InventoryServlet"})
public class InventoryServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        try (Connection con = DBConnection.getConnection()) {
            if ("add".equals(action)) {
                PreparedStatement ps = con.prepareStatement("INSERT INTO Inventory (item_name, category, quantity) VALUES (?, ?, ?)");
                ps.setString(1, request.getParameter("itemName"));
                ps.setString(2, request.getParameter("category"));
                ps.setInt(3, Integer.parseInt(request.getParameter("quantity")));
                ps.executeUpdate();
                
            } else if ("update".equals(action)) {
                PreparedStatement ps = con.prepareStatement("UPDATE Inventory SET item_name=?, category=?, quantity=? WHERE id=?");
                ps.setString(1, request.getParameter("itemName"));
                ps.setString(2, request.getParameter("category"));
                ps.setInt(3, Integer.parseInt(request.getParameter("quantity")));
                ps.setInt(4, Integer.parseInt(request.getParameter("id")));
                ps.executeUpdate();
            }
        } catch (SQLException e) { e.printStackTrace(); }
        
        response.sendRedirect("inventory.jsp");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("delete".equals(action)) {
            try (Connection con = DBConnection.getConnection()) {
                PreparedStatement ps = con.prepareStatement("DELETE FROM Inventory WHERE id=?");
                ps.setInt(1, Integer.parseInt(request.getParameter("id")));
                ps.executeUpdate();
            } catch (SQLException e) { e.printStackTrace(); }
            response.sendRedirect("inventory.jsp");
        }
    }
}