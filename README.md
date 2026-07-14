# UniCareFood Portal (CSC584)

The **UniCareFood Portal** is a web-based platform designed to bridge the gap between food donors, staff administrators, and students in need. The system streamlines inventory tracking, donor distribution, and voucher/request management to optimize surplus food rescue and redistribution within university environments.

---

##  Project Structure & What's in This Repository

This project is a classic Java EE (Enterprise Edition) application structured to run on a web server like GlassFish or Apache Tomcat. Here is a breakdown of the key files and directories:

### Web & Presentation Layer (`/build/web/` or `/web/`)
*   **`index.jsp`**: The main landing page of the portal.
*   **`dashboard.jsp` / `student_dashboard.jsp`**: Interactive landing views containing analytics and quick actions for Admins/Staff and Students.
*   **`inventory.jsp` / `donor_inventory.jsp` / `edit_inventory.jsp`**: Front-end screens to view, add, and update food stock details.
*   **`manage_users.jsp` / `manage_students.jsp` / `edit_user.jsp`**: Administrative screens to oversee platform users.
*   **`register.jsp` / `public_register.jsp` / `student_register.jsp` / `staff_register.jsp`**: Modular registration pages specialized by user roles.
*   **`profile.jsp` / `staff_profile.jsp`**: Dynamic dashboards for users to manage their credentials and active history.
*   **`navbar.jsp` / `sidebar.jsp` / `style.css`**: Core UI design system, layouts, and reusable navigational templates.

### Business Logic Controllers (`/WEB-INF/classes/controllers/`)
*   **`AuthServlet.class`**: Handles user login, authentication sessions, and secure logouts.
*   **`UserServlet.class`**: Coordinates CRUD operations on user registration and access privileges.
*   **`InventoryServlet.class`**: Manages backend operations for creating, updating, and removing food inventory items.
*   **`VoucherServlet.class`**: Controls the generation, claiming, and validation of food assistance vouchers.

### Database Connection & Models (`/WEB-INF/classes/models/`)
*   **`DBConnection.class`**: Manages the driver manager connection pool to your SQL database.
*   **`User.class`**: Represents system entity data (ID, name, email, role: Admin, Staff, Student, or Donor).
*   **`InventoryItem.class`**: Represents individual food inventory listings (Item Name, Expiry Date, Quantity, and Donor details).

---

## 🛠️ Required Models (Entities)

To keep the application working smoothly, make sure your backend classes match the logic expected by your controller Servlets. The primary data models are:

1.  **User Model**
    *   `userId` (Primary Key)
    *   `username` / `email`
    *   `password` (Hashed)
    *   `role` (e.g., `Admin`, `Staff`, `Student`, `Donor`)
    *   `profileDetails` (Phone, Department, Matric Number)

2.  **InventoryItem Model**
    *   `itemId` (Primary Key)
    *   `itemName`
    *   `category` (Perishable, Non-perishable, Packaged)
    *   `quantity`
    *   `expiryDate`
    *   `donorId` (Foreign Key referencing User)

3.  **Voucher / Request Model** (implied by `VoucherServlet`)
    *   `voucherId` (Primary key)
    *   `studentId` (Foreign Key referencing User)
    *   `itemId` / `bundleId` (Foreign Key referencing Inventory)
    *   `status` (Pending, Approved, Redeemed, Cancelled)

---

##  How to Setup the Database

The application comes pre-packaged with **Apache Derby** (`derby.jar` under `/WEB-INF/lib/`)[cite: 1] but can easily be configured for MySQL or PostgreSQL. 

Follow these steps to set up the database using Derby (or your preferred SQL engine):

### 1. Configure the Connection String
Locate and edit your `DBConnection.java` (or compiled class) to point to your local database server:
```java
// Example Derby / JDBC connection template
public class DBConnection {
    private static final String URL = "jdbc:derby://localhost:1527/UniCareFoodDB;create=true";
    private static final String USER = "app";
    private static final String PASSWORD = "app";

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
