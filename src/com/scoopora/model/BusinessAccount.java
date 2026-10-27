package com.scoopora.model;

public class BusinessAccount {
    private int id;
    private String contactName, email, password, phone;
    private String businessName, businessType, logoUrl;
    private String address, city, state, pincode;
    private String gstNumber, panNumber, website, description;
    private String deliveryAreas, deliveryTime;
    private String verificationStatus, verificationNotes;
    private boolean isActive;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getContactName() { return contactName; }
    public void setContactName(String v) { this.contactName = v; }
    public String getEmail() { return email; }
    public void setEmail(String v) { this.email = v; }
    public String getPassword() { return password; }
    public void setPassword(String v) { this.password = v; }
    public String getPhone() { return phone; }
    public void setPhone(String v) { this.phone = v; }
    public String getBusinessName() { return businessName; }
    public void setBusinessName(String v) { this.businessName = v; }
    public String getBusinessType() { return businessType; }
    public void setBusinessType(String v) { this.businessType = v; }
    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String v) { this.logoUrl = v; }
    public String getAddress() { return address; }
    public void setAddress(String v) { this.address = v; }
    public String getCity() { return city; }
    public void setCity(String v) { this.city = v; }
    public String getState() { return state; }
    public void setState(String v) { this.state = v; }
    public String getPincode() { return pincode; }
    public void setPincode(String v) { this.pincode = v; }
    public String getGstNumber() { return gstNumber; }
    public void setGstNumber(String v) { this.gstNumber = v; }
    public String getPanNumber() { return panNumber; }
    public void setPanNumber(String v) { this.panNumber = v; }
    public String getWebsite() { return website; }
    public void setWebsite(String v) { this.website = v; }
    public String getDescription() { return description; }
    public void setDescription(String v) { this.description = v; }
    public String getDeliveryAreas() { return deliveryAreas; }
    public void setDeliveryAreas(String v) { this.deliveryAreas = v; }
    public String getDeliveryTime() { return deliveryTime; }
    public void setDeliveryTime(String v) { this.deliveryTime = v; }
    public String getVerificationStatus() { return verificationStatus; }
    public void setVerificationStatus(String v) { this.verificationStatus = v; }
    public String getVerificationNotes() { return verificationNotes; }
    public void setVerificationNotes(String v) { this.verificationNotes = v; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean v) { this.isActive = v; }

    public boolean isVerified() { return "verified".equals(verificationStatus); }
}
