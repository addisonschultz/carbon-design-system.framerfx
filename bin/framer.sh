#!/bin/bash

# source `dirname $0`/common.sh

CIRCLE_BUILD_NUM="1"
BRANCH_NAME="Framer-ComponentImporter-$CIRCLE_BUILD_NUM"
didImportComponents=false

# Checkout a new branch
hub checkout -b $BRANCH_NAME

# cd to Framer project directory
cd $FRAMER_PROJECT_PATH

# Check if a component importer configuration already exists
if [ ! -f importer.config.json ]; then
  # Run component importer for the first time
  component-importer init $LIBRARY_PACKAGE_NAME

  # Update flag to indicate if components were imported
  didImportComponents=true
else
  # Store yarn.lock files in memory
  previousYarnLock=$(cat temp/yarn.lock)
  newYarnLock=$(cat $FRAMER_PROJECT_PATH/yarn.lock)

  # Determine if there is dependency updates
  updatedDependencies=$(npx yarn-pkg-version-diff $LIBRARY_PACKAGE_NAME $previousYarnLock $newYarnLock)

  # Check if response of dependency updates script is empty
  if [ -z "$updatedDependencies" ]; then
    # Regenerate components
    component-importer generate

    # Update flag to indicate if components were imported
    didImportComponents=true
  fi
fi

# Check if components were imported and there were changes
if [["$didImportComponents" = true] && [ `git status --porcelain` ]]; then
  # Stage all files for commit
  hub add .

  # Commit imported components
  # @TODO - More descriptive commit message
  hub commit -m "Re-imported components due to dependency update"

  # Create pull request
  # @TODO - More descriptive PR message
  hub pull-request -m $BRANCH_NAME -p
else
  echo "No changes found after running component importer, skipping PR creation"
fi
