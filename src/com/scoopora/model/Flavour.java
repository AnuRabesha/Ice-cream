package com.scoopora.model;

public class Flavour {
    private int id;
    private String name, description, category, imageUrl;
    private boolean isTrending;

    public Flavour() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public boolean isTrending() { return isTrending; }
    public void setTrending(boolean trending) { isTrending = trending; }
}
