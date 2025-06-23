#!/usr/bin/env ruby
require 'fileutils'
require 'mini_magick'
require 'yaml'

# Configuration
source_dir = ARGV[0] || 'images/gallery'
thumbnail_width = 300
thumbnail_suffix = '-thumb'
supported_formats = %w[.jpg .jpeg .png .gif]

unless File.directory?(source_dir)
  puts "Error: Directory '#{source_dir}' not found."
  puts "Usage: ruby gallery_helper.rb [source_directory]"
  exit 1
end

puts "Processing images in #{source_dir}..."

# Create Jekyll front matter structure for gallery images
gallery_data = { 'images' => [] }

# Process each image file
Dir.glob(File.join(source_dir, '*')).sort.each do |file|
  # Skip directories and non-image files
  next if File.directory?(file) || !supported_formats.include?(File.extname(file).downcase)
  # Skip thumbnails
  next if file.include?(thumbnail_suffix)
  
  begin
    filename = File.basename(file)
    basename = File.basename(file, '.*')
    extname = File.extname(file)
    
    thumbnail_name = "#{basename}#{thumbnail_suffix}#{extname}"
    thumbnail_path = File.join(source_dir, thumbnail_name)
    
    # Create thumbnail if it doesn't exist
    unless File.exist?(thumbnail_path)
      puts "Creating thumbnail for #{filename}..."
      image = MiniMagick::Image.open(file)
      image.resize "#{thumbnail_width}x#{thumbnail_width}>"
      image.write thumbnail_path
    end
    
    # Get image dimensions
    image_info = MiniMagick::Image.open(file)
    width = image_info.width
    height = image_info.height
    
    # Fix path to avoid double slashes
    clean_path = source_dir.chomp('/')
    
    # Add to gallery data - without Liquid tags
    image_data = {
      'full' => "/#{clean_path}/#{filename}",
      'thumbnail' => "/#{clean_path}/#{thumbnail_name}",
      'width' => width,
      'height' => height,
      'caption' => basename.gsub(/[-_]/, ' ').capitalize,
      'alt' => basename.gsub(/[-_]/, ' ').capitalize
    }
    
    gallery_data['images'] << image_data
    
    puts "Processed: #{filename} (#{width}x#{height})"
  rescue => e
    puts "Error processing #{file}: #{e.message}"
  end
end

# Print YAML front matter that can be used in Jekyll posts
puts "\n--- Jekyll Front Matter for Gallery ---"
yaml_output = "images:\n"
gallery_data['images'].each do |image|
  yaml_output += "  - full: #{image['full']}\n"
  yaml_output += "    thumbnail: #{image['thumbnail']}\n"
  yaml_output += "    width: #{image['width']}\n"
  yaml_output += "    height: #{image['height']}\n"
  yaml_output += "    caption: #{image['caption']}\n"
  yaml_output += "    alt: #{image['alt']}\n"
end

puts yaml_output
puts "--- End of Front Matter ---"

puts "\nProcessed #{gallery_data['images'].count} images."
puts "Thumbnails were created in #{source_dir}" 