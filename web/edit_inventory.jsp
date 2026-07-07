<%@page import="java.sql.*, models.DBConnection, models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || (!"STAFF".equals(user.getRole()) && !"ADMIN".equals(user.getRole()))) { 
        response.sendRedirect("index.jsp"); 
        return; 
    }

    String idParam = request.getParameter("id");
    if (idParam == null) {
        response.sendRedirect("inventory.jsp?error=No item selected");
        return;
    }
    int itemId = Integer.parseInt(idParam);

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String itemName = "", category = "";
    int quantity = 0;
    String donorEmail = ""; // may be null
    String donorName = "";

    try {
        con = DBConnection.getConnection();
        // Get item details including donor info
        ps = con.prepareStatement(
            "SELECT i.*, d.name as donor_name FROM Inventory i " +
            "LEFT JOIN Donors d ON i.donor_email = d.email WHERE i.id = ?"
        );
        ps.setInt(1, itemId);
        rs = ps.executeQuery();
        if (rs.next()) {
            itemName = rs.getString("item_name");
            category = rs.getString("category");
            quantity = rs.getInt("quantity");
            donorEmail = rs.getString("donor_email") != null ? rs.getString("donor_email") : "";
            donorName = rs.getString("donor_name") != null ? rs.getString("donor_name") : "None";
        } else {
            response.sendRedirect("inventory.jsp?error=Item not found");
            return;
        }
        rs.close();
        ps.close();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e){}
        if (ps != null) try { ps.close(); } catch(SQLException e){}
        if (con != null) try { con.close(); } catch(SQLException e){}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Inventory Item</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { max-width: 600px; margin: 0 auto; }
        label { display: inline-block; width: 120px; font-weight: bold; }
        input[type="text"], input[type="number"] { width: 250px; padding: 5px; }
        select { width: 260px; padding: 5px; }
        .search-box { margin: 10px 0; }
        .search-box input { width: 250px; padding: 5px; }
        .button-group { margin-top: 20px; }
        .btn { padding: 8px 20px; background: #4CAF50; color: white; border: none; cursor: pointer; }
        .btn:hover { background: #45a049; }
        .btn-cancel { background: #f44336; }
        .btn-cancel:hover { background: #da190b; }
        .error { color: red; }
        .success { color: green; }
    </style>
    <script>
        // Filter donor dropdown options based on search input
        function filterDonors() {
            var input = document.getElementById('donorSearch');
            var filter = input.value.toLowerCase();
            var select = document.getElementById('donorSelect');
            var options = select.options;

            for (var i = 0; i < options.length; i++) {
                var txt = options[i].text.toLowerCase();
                if (txt.indexOf(filter) > -1) {
                    options[i].style.display = '';
                } else {
                    options[i].style.display = 'none';
                }
            }
        }

        // When an option is selected, clear the search box and show the selection
        function selectDonor() {
            var select = document.getElementById('donorSelect');
            var input = document.getElementById('donorSearch');
            if (select.value) {
                var selectedText = select.options[select.selectedIndex].text;
                input.value = selectedText;
                // Hide all options except the selected one
                for (var i = 0; i < select.options.length; i++) {
                    if (i === select.selectedIndex) {
                        select.options[i].style.display = '';
                    } else {
                        select.options[i].style.display = 'none';
                    }
                }
            }
        }

        // Reset filter when user clicks on select
        function resetFilter() {
            var select = document.getElementById('donorSelect');
            for (var i = 0; i < select.options.length; i++) {
                select.options[i].style.display = '';
            }
            document.getElementById('donorSearch').value = '';
        }
    </script>
</head>
<body>
<div class="container">
    <h2>Edit Inventory Item</h2>
    <a href="inventory.jsp">← Back to Inventory</a>
    <hr>

    <form action="InventoryServlet" method="post">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="id" value="<%= itemId %>">

        <div>
            <label>Item Name:</label>
            <input type="text" name="itemName" value="<%= itemName %>" required>
        </div><br>

        <div>
            <label>Category:</label>
            <input type="text" name="category" value="<%= category %>" required>
        </div><br>

        <div>
            <label>Quantity:</label>
            <input type="number" name="quantity" value="<%= quantity %>" required min="1">
        </div><br>

        <div>
            <label>Donor:</label>
            <div style="display:inline-block;">
                <!-- Search input -->
                <div class="search-box">
                    <input type="text" id="donorSearch" placeholder="Search donor by name or email..." onkeyup="filterDonors()" onclick="resetFilter()">
                </div>
                <!-- Dropdown with all donors -->
                <select id="donorSelect" name="donorEmail" onchange="selectDonor()" size="8">
                    <option value="">-- None (Anonymous) --</option>
                    <%
                        // Fetch all donors for dropdown
                        Connection con2 = null;
                        PreparedStatement ps2 = null;
                        ResultSet rs2 = null;
                        try {
                            con2 = DBConnection.getConnection();
                            ps2 = con2.prepareStatement("SELECT email, name FROM Donors ORDER BY name");
                            rs2 = ps2.executeQuery();
                            while (rs2.next()) {
                                String email = rs2.getString("email");
                                String name = rs2.getString("name");
                                String display = name + " (" + email + ")";
                                boolean selected = email.equals(donorEmail);
                    %>
                        <option value="<%= email %>" <%= selected ? "selected" : "" %>><%= display %></option>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        } finally {
                            if (rs2 != null) try { rs2.close(); } catch(SQLException e){}
                            if (ps2 != null) try { ps2.close(); } catch(SQLException e){}
                            if (con2 != null) try { con2.close(); } catch(SQLException e){}
                        }
                    %>
                </select>
                <br><small>Type in the search box to filter donors, then click on the desired donor.</small>
            </div>
        </div><br>

        <div class="button-group">
            <button type="submit" class="btn">Update Item</button>
            <a href="inventory.jsp" class="btn btn-cancel">Cancel</a>
        </div>
    </form>
</div>
</body>
</html>