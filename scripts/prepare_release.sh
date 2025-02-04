#!/bin/bash

# Build the frontend
cd frontend
npm install
npm run build

# Create a temporary directory for the release
mkdir -p release_artifacts

# Copy the build files
cp -r build/* release_artifacts/

# Create a zip file
zip -r frontend_build.zip release_artifacts/

# Clean up
rm -rf release_artifacts

echo "Created frontend_build.zip ready for upload to GitHub releases" 