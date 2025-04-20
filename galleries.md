---
layout: page
permalink: /galleries/
---

<p>Welcome to my photography collection! Here you'll find various galleries showcasing my work from different shoots and adventures. Click on any gallery below to explore the full collection. You can find more on my Instagram linked in the bottom of the page. </p>

<div class="gallery-list">
  {% assign gallery_posts = site.posts | where_exp: "post", "post.layout == 'gallery'" %}
  {% for post in gallery_posts %}
    <div class="gallery-item-preview">
      <h2><a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></h2>
      <div class="gallery-preview-image">
        {% if post.cover_image %}
          {% assign cover_image = post.images | where: "full", post.cover_image | first %}
        {% else %}
          {% assign cover_image = post.images | first %}
        {% endif %}
        {% if cover_image %}
          <a href="{{ site.baseurl }}{{ post.url }}">
            <img src="{{ cover_image.thumbnail }}" alt="{{ cover_image.alt | default: cover_image.caption }}" />
          </a>
        {% endif %}
      </div>
      <p class="gallery-date">{{ post.date | date: "%B %d, %Y" }}</p>
    </div>
  {% endfor %}
</div>

<style>
.gallery-list {
  margin-top: 20px;
}

.gallery-item-preview {
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.gallery-preview-image {
  margin: 10px 0;
  max-width: 600px;
}

.gallery-preview-image img {
  width: 100%;
  height: auto;
  border-radius: 4px;
  transition: transform 0.2s ease;
  object-fit: cover;
}

.gallery-preview-image img:hover {
  transform: scale(1.02);
}

.gallery-date {
  color: #888;
  font-size: 14px;
}
</style> 