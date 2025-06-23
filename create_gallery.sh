#!/bin/bash

# Configuration
SCRIPT_DIR=$(dirname "$0")
DATE_FORMAT="%Y-%m-%d"
DEFAULT_GALLERY_DIR="images/gallery"

# Check for dependencies
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick not found. Please install it to proceed."
    echo "Try: sudo apt-get install imagemagick"
    exit 1
fi

# Display help message
show_help() {
    echo "Usage: $0 [options] gallery_name"
    echo
    echo "Creates a new gallery post and processes images."
    echo
    echo "Options:"
    echo "  -h, --help             Show this help message"
    echo "  -d, --dir DIRECTORY    Specify the image directory (default: $DEFAULT_GALLERY_DIR/gallery_name)"
    echo "  -t, --title TITLE      Specify the gallery title (default: gallery_name with spaces)"
    echo
    echo "Example:"
    echo "  $0 summer-vacation"
    echo "  $0 --title \"Summer Vacation 2023\" --dir images/vacation summer-vacation"
    exit 0
}

# Parse arguments
GALLERY_DIR=""
GALLERY_TITLE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -d|--dir)
            GALLERY_DIR="$2"
            shift 2
            ;;
        -t|--title)
            GALLERY_TITLE="$2"
            shift 2
            ;;
        *)
            if [[ -z "$GALLERY_NAME" ]]; then
                GALLERY_NAME="$1"
            else
                echo "Error: Unexpected argument: $1"
                show_help
            fi
            shift
            ;;
    esac
done

# Validate gallery name
if [[ -z "$GALLERY_NAME" ]]; then
    echo "Error: Gallery name is required."
    show_help
fi

# Set default values if not provided
if [[ -z "$GALLERY_TITLE" ]]; then
    GALLERY_TITLE=$(echo "$GALLERY_NAME" | tr '-' ' ' | sed -e 's/\b\(.\)/\u\1/g')
fi

if [[ -z "$GALLERY_DIR" ]]; then
    GALLERY_DIR="$DEFAULT_GALLERY_DIR/$GALLERY_NAME"
fi

# Create directory if it doesn't exist
if [[ ! -d "$GALLERY_DIR" ]]; then
    echo "Creating directory: $GALLERY_DIR"
    mkdir -p "$GALLERY_DIR"
fi

# Create the gallery post
TODAY=$(date +"$DATE_FORMAT")
POST_FILENAME="_posts/$TODAY-$GALLERY_NAME.md"

echo "Creating gallery post: $POST_FILENAME"

# Create initial post content
cat > "$POST_FILENAME" << EOF
---
layout: gallery
title: $GALLERY_TITLE
---

Welcome to my $GALLERY_TITLE gallery. Enjoy the photos!
EOF

echo "Initial post created. Please add some images to $GALLERY_DIR"
echo "Then run: bundle exec ruby gallery_helper.rb $GALLERY_DIR > gallery_output.txt"
echo "And copy the generated YAML from gallery_output.txt to the front matter in $POST_FILENAME"
echo
echo "IMPORTANT: Do not use Liquid template syntax (e.g., {{ site.baseurl }}) in the front matter."
echo "The paths should be standard URLs like '/images/gallery/image.jpg'"
echo
echo "Done! You can now run 'bundle exec jekyll serve' to view your site."

# Make the script executable
chmod +x $0 