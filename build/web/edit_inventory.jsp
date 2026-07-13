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
    String donorEmail = ""; 
    String donorName = "";
    String expiryDateStr = "";

    try {
        con = DBConnection.getConnection();
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
            
            // --- Fetch expiry date ---
            java.sql.Date exp = rs.getDate("expiry_date");
            if (exp != null) expiryDateStr = exp.toString();
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
    <title>Edit Inventory - UniCare Food Portal</title>

    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <style>
        .form-container{
            max-width:750px;
        }

        .form-group{
            margin-bottom:18px;
        }

        .form-group label{
            display:block;
            margin-bottom:6px;
            font-weight:600;
            color:#334155;
        }

        .form-control{
            width:100%;
            padding:10px 12px;
            border:1px solid #cbd5e1;
            border-radius:8px;
            font-size:14px;
            box-sizing:border-box;
            transition:.2s;
        }

        .form-control:focus{
            outline:none;
            border-color:#1E5E2F;
            box-shadow:0 0 0 3px rgba(30,94,47,.15);
        }

        textarea.form-control{
            resize:vertical;
        }

        .small-text{
            color:#64748b;
            font-size:13px;
            margin-top:5px;
            display:block;
        }

        .button-group{
            display:flex;
            gap:12px;
            margin-top:30px;
        }

        #donorSelect{
            height:220px;
        }

        .readonly-box{
            background:#f1f5f9;
            color:#64748b;
        }

        .search-box{
            margin-bottom:10px;
        }
    </style>

    <script>
        function filterDonors() {
            var input = document.getElementById("donorSearch");
            var filter = input.value.toLowerCase();

            var select = document.getElementById("donorSelect");

            for (var i = 0; i < select.options.length; i++) {

                var txt = select.options[i].text.toLowerCase();

                if (txt.indexOf(filter) > -1) {
                    select.options[i].style.display = "";
                } else {
                    select.options[i].style.display = "none";
                }
            }
        }

        function selectDonor() {

            var select = document.getElementById("donorSelect");

            if(select.selectedIndex!=-1){

                document.getElementById("donorSearch").value =
                    select.options[select.selectedIndex].text;

                for(var i=0;i<select.options.length;i++){

                    if(i==select.selectedIndex)
                        select.options[i].style.display="";
                    else
                        select.options[i].style.display="none";

                }
            }
        }

        function resetFilter(){

            var select=document.getElementById("donorSelect");

            document.getElementById("donorSearch").value="";

            for(var i=0;i<select.options.length;i++){

                select.options[i].style.display="";

            }
        }
    </script>

</head>

<body>

<%@ include file="navbar.jsp" %>
<%@ include file="sidebar.jsp" %>

<div class="main-content">

    <div class="page-title">
        <h1>
            <i class="fa-solid fa-box"></i>
            Edit Inventory Item
        </h1>
    </div>

    <div style="margin-bottom:20px;">
        <a href="inventory.jsp"
           style="color:#1E5E2F;
                  text-decoration:none;
                  font-weight:600;
                  display:inline-flex;
                  align-items:center;
                  gap:6px;">

            <i class="fa fa-arrow-left"
               style="font-size:12px;"></i>

            Back to Inventory

        </a>
    </div>

    <div class="form-container">

        <form action="InventoryServlet" method="post">

            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%=itemId%>">

            <div class="form-group">

                <label>Item Name</label>

                <input
                    type="text"
                    class="form-control"
                    name="itemName"
                    value="<%=itemName%>"
                    required>

            </div>

            <div class="form-group">

                <label>Category</label>

                <input
                    type="text"
                    class="form-control"
                    name="category"
                    value="<%=category%>"
                    required>

            </div>

            <div class="form-group">

                <label>Quantity</label>

                <input
                    type="number"
                    class="form-control"
                    name="quantity"
                    value="<%=quantity%>"
                    min="1"
                    required>

            </div>

            <div class="form-group">

                <label>Expiry Date</label>

                <input
                    type="date"
                    class="form-control"
                    name="expiryDate"
                    value="<%=expiryDateStr%>">

                <span class="small-text">
                    Leave empty if the expiry date is unknown.
                </span>

            </div>

            <div class="form-group">

                <label>Donor</label>

                <div class="search-box">

                    <input
                        type="text"
                        id="donorSearch"
                        class="form-control"
                        placeholder="Search donor by name or email..."
                        onkeyup="filterDonors()"
                        onclick="resetFilter()">

                </div>

                <select
                    id="donorSelect"
                    name="donorEmail"
                    class="form-control"
                    onchange="selectDonor()"
                    size="8">

                    <option value="">
                        -- None (Anonymous) --
                    </option>

                    <%
                        Connection con2 = null;
                        PreparedStatement ps2 = null;
                        ResultSet rs2 = null;

                        try{

                            con2 = DBConnection.getConnection();

                            ps2 = con2.prepareStatement(
                                "SELECT email,name FROM Donors ORDER BY name");

                            rs2 = ps2.executeQuery();

                            while(rs2.next()){

                                String email = rs2.getString("email");
                                String name = rs2.getString("name");

                                boolean selected=email.equals(donorEmail);
                    %>

                    <option
                        value="<%=email%>"
                        <%=selected?"selected":""%>>

                        <%=name%> (<%=email%>)

                    </option>

                    <%
                            }

                        }catch(Exception e){

                            e.printStackTrace();

                        }finally{

                            if(rs2!=null) rs2.close();
                            if(ps2!=null) ps2.close();
                            if(con2!=null) con2.close();

                        }
                    %>

                </select>

                <span class="small-text">
                    Search for a donor, then select the desired record.
                </span>

            </div>

            <div class="button-group">

                <button
                    type="submit"
                    class="btn btn-primary"
                    style="flex:1;height:42px;">

                    <i class="fa-solid fa-floppy-disk"></i>

                    Update Item

                </button>

                <a
                    href="inventory.jsp"
                    class="btn btn-danger"
                    style="background:#64748b;
                           display:flex;
                           justify-content:center;
                           align-items:center;
                           text-decoration:none;
                           height:42px;
                           padding:0 20px;">

                    Cancel

                </a>

            </div>

        </form>

    </div>

</div>

</body>
</html>
