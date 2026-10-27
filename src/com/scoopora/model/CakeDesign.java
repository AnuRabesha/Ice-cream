package com.scoopora.model;

public class CakeDesign {
    private int id, layers, shopId;
    private String name, cakeType, description, baseFlavour;
    private String availableFlavours, availableSizes, availableShapes;
    private String availableColours, availableToppings, imageUrl;
    private double basePrice, price;
    private boolean supportsPhoto, isCustom, isFeatured;

    public CakeDesign() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getLayers() { return layers; }
    public void setLayers(int layers) { this.layers = layers; }
    public int getShopId() { return shopId; }
    public void setShopId(int shopId) { this.shopId = shopId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCakeType() { return cakeType; }
    public void setCakeType(String cakeType) { this.cakeType = cakeType; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getBaseFlavour() { return baseFlavour; }
    public void setBaseFlavour(String baseFlavour) { this.baseFlavour = baseFlavour; }
    public String getAvailableFlavours() { return availableFlavours; }
    public void setAvailableFlavours(String f) { this.availableFlavours = f; }
    public String getAvailableSizes() { return availableSizes; }
    public void setAvailableSizes(String s) { this.availableSizes = s; }
    public String getAvailableShapes() { return availableShapes; }
    public void setAvailableShapes(String s) { this.availableShapes = s; }
    public String getAvailableColours() { return availableColours; }
    public void setAvailableColours(String c) { this.availableColours = c; }
    public String getAvailableToppings() { return availableToppings; }
    public void setAvailableToppings(String t) { this.availableToppings = t; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public double getBasePrice() { return basePrice; }
    public void setBasePrice(double basePrice) { this.basePrice = basePrice; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public boolean isSupportsPhoto() { return supportsPhoto; }
    public void setSupportsPhoto(boolean supportsPhoto) { this.supportsPhoto = supportsPhoto; }
    public boolean isCustom() { return isCustom; }
    public void setCustom(boolean custom) { isCustom = custom; }
    public boolean isFeatured() { return isFeatured; }
    public void setFeatured(boolean featured) { isFeatured = featured; }

    // Helper: parse sizes string "0.5kg:500,1kg:850" into display
    public String getFirstSize() {
        if (availableSizes == null || availableSizes.isEmpty()) return "1kg";
        return availableSizes.split(",")[0].split(":")[0];
    }
}
