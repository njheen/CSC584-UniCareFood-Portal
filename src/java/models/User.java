package models;

public class User {
    // This will hold Student ID, Email (for Donors), or Staff ID
    private String loginId; 
    private String name;
    private String role;
    private String phone; // Nullable depending on table

    // Getters and Setters
    public String getLoginId() { return loginId; }
    public void setLoginId(String loginId) { this.loginId = loginId; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}