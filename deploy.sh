#!/bin/bash
# Deploy vocab-quest to GitHub Pages
# Run this from the project folder after making changes on tweaks

echo "🚀 Deploying Vocab Quest to GitHub Pages..."

# Make sure we're starting from tweaks
git checkout tweaks

# Switch to gh-pages and merge in latest changes
git checkout gh-pages
git merge tweaks -m "Deploy latest changes from tweaks"

# Sync index.html (what GitHub Pages serves) with vocab-quest.html
cp vocab-quest.html index.html
git add index.html
git commit -m "Sync index.html with vocab-quest.html"

# Push to GitHub (triggers Pages rebuild)
git push origin gh-pages

# Switch back to tweaks for continued development
git checkout tweaks

echo ""
echo "✅ Deploy complete! Site will update in ~1 minute at:"
echo "   https://demerson-code.github.io/vocab-quest/"
