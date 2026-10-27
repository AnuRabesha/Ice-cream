package com.scoopora.model;

public class CustomCakeOrder {
    private int id, userId, shopId, cakeDesignId, quantity;
    private String cakeType, cakeName, selectedSize, selectedShape;
    private String selectedFlavour, selectedColour, selectedToppings;
    private String customMessage, photoReference, extraDecorations;
    private String deliveryDate, deliveryAddress, specialNotes;
    private String status, ownerNotes, createdAt;
    private double basePrice, finalPrice;

    public CustomCakeOrder() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getShopId() { return shopId; }
    public void setShopId(int shopId) { this.shopId = shopId; }
    public int getCakeDesignId() { return cakeDesignId; }
    public void setCakeDesignId(int cakeDesignId) { this.cakeDesignId = cakeDesignId; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public String getCakeType() { return cakeType; }
    public void setCakeType(String cakeType) { this.cakeType = cakeType; }
    public String getCakeName() { return cakeName; }
    public void setCakeName(String cakeName) { this.cakeName = cakeName; }
    public String getSelectedSize() { return selectedSize; }
    public void setSelectedSize(String selectedSize) { this.selectedSize = selectedSize; }
    public String getSelectedShape() { return selectedShape; }
    public void setSelectedShape(String selectedShape) { this.selectedShape = selectedShape; }
    public String getSelectedFlavour() { return selectedFlavour; }
    public void setSelectedFlavour(String selectedFlavour) { this.selectedFlavour = selectedFlavour; }
    public String getSelectedColour() { return selectedColour; }
    public void setSelectedColour(String selectedColour) { this.selectedColour = selectedColour; }
    public String getSelectedToppings() { return selectedToppings; }
    public void setSelectedToppings(String selectedToppings) { this.selectedToppings = selectedToppings; }
    public String getCustomMessage() { return customMessage; }
    public void setCustomMessage(String customMessage) { this.customMessage = customMessage; }
    public String getPhotoReference() { return photoReference; }
    public void setPhotoReference(String photoReference) { this.photoReference = photoReference; }
    public String getExtraDecorations() { return extraDecorations; }
    public void setExtraDecorations(String extraDecorations) { this.extraDecorations = extraDecorations; }
    public String getDeliveryDate() { return deliveryDate; }
    public void setDeliveryDate(String deliveryDate) { this.deliveryDate = deliveryDate; }
    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }
    public String getSpecialNotes() { return specialNotes; }
    public void setSpecialNotes(String specialNotes) { this.specialNotes = specialNotes; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getOwnerNotes() { return ownerNotes; }
    public void setOwnerNotes(String ownerNotes) { this.ownerNotes = ownerNotes; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public double getBasePrice() { return basePrice; }
    public void setBasePrice(double basePrice) { this.basePrice = basePrice; }
    public double getFinalPrice() { return finalPrice; }
    public void setFinalPrice(double finalPrice) { this.finalPrice = finalPrice; }
}
