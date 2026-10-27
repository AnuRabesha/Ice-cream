package com.scoopora.model;

public class Review {
    private int id, userId, shopId, rating;
    private Integer orderId;
    private String comment, userName, shopName, createdAt;
    private String photoUrl, ownerReply, ownerReplyAt;
    private boolean isVerifiedPurchase, isReported, isEdited;

    public Review() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getShopId() { return shopId; }
    public void setShopId(int shopId) { this.shopId = shopId; }
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public String getOwnerReply() { return ownerReply; }
    public void setOwnerReply(String ownerReply) { this.ownerReply = ownerReply; }
    public String getOwnerReplyAt() { return ownerReplyAt; }
    public void setOwnerReplyAt(String ownerReplyAt) { this.ownerReplyAt = ownerReplyAt; }
    public boolean isVerifiedPurchase() { return isVerifiedPurchase; }
    public void setVerifiedPurchase(boolean v) { this.isVerifiedPurchase = v; }
    public boolean isReported() { return isReported; }
    public void setReported(boolean reported) { this.isReported = reported; }
    public boolean isEdited() { return isEdited; }
    public void setEdited(boolean edited) { this.isEdited = edited; }

    // Helper: first letter of name for avatar
    public String getAvatarLetter() {
        return (userName != null && !userName.isEmpty())
            ? String.valueOf(userName.charAt(0)).toUpperCase() : "?";
    }
}
