# UniCareFood Portal (CSC584)

The **UniCareFood Portal** is a web-based platform designed to bridge the gap between food donors, staff administrators, and students in need. The system streamlines inventory tracking, donor distribution, and voucher/request management to optimize surplus food rescue and redistribution within university environments.

---

##  MVC Architecture Design

This project is built using the standard **Model-View-Controller (MVC)** architectural pattern to keep the codebase modular, maintainable, and highly organized:
*   **Model (Data Layer):** Represents the core application data and database connectivity rules. These are plain Java classes (POJOs) representing database tables and operations.
*   **View (Presentation Layer):** The user interface (UI) templates. These dynamic JSP files display formatted data to users and send raw input data back to the controllers.
*   **Controller (Business Logic Layer):** Web Servlets that capture user actions from the Views, communicate with the Models to fetch or update database entries, and route users to the appropriate View.

---

## Project Structure & Component Mapping

Here is how the files in this repository map directly to the **MVC** design pattern:

### 1. View (Presentation)
These files manage the user interface, routing inputs via HTML forms to their corresponding controller Servlets.
*   **Landing & Auth UI:** `index.jsp`, `register.jsp`, `public_register.jsp`, `student_register.jsp`, `staff_register.jsp`.
*   **Dashboards:** `dashboard.jsp`, `student_dashboard.jsp`, `profile.jsp`, `staff_profile.jsp`.
*   **Features:** `inventory.jsp`, `donor_inventory.jsp`, `edit_inventory.jsp`, `manage_users.jsp`, `manage_students.jsp`, `edit_user.jsp`.
*   **Assets & Partials:** `navbar.jsp`, `sidebar.jsp`, `style.css`.

### 2. Controller (Routing & Logic)
Located in `/WEB-INF/classes/controllers/`[cite: 1], these Servlets process incoming HTTP GET/POST requests.
*   **`AuthServlet.class`**: Coordinates login validations, registers active sessions, and handles logouts.
*   **`UserServlet.class`**: Routes user management actions (e.g., editing profile info, adding/deleting users).
*   **`InventoryServlet.class`**: Validates, stores, and updates physical food stock listings.
*   **`VoucherServlet.class`**: Manages the approval and redemption requests for food vouchers.

### 3. Model (Entities & Database Connection)
Located in `/WEB-INF/classes/models/`[cite: 1], these classes structure database entities and coordinate queries.
*   **`DBConnection.class`**: Manages database connection pools and configurations.
*   **`User.class`**: Encapsulates login credentials, roles (Admin, Staff, Student, Donor), and contact details.
*   **`InventoryItem.class`**: Holds attributes for food items like Name, Expiry Date, Quantity, and associated Donor details.

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
