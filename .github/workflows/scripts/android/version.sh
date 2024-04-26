ARTIFACT_NAME=$1
VERSION_TYPE=$2
VERSION_NAME=${ARTIFACT_NAME^^}_VERSION

go_to_android_sdk_dir() {
  cd ../../../../android
}

# Function to extract current version from gradle.properties
get_current_version() {
  grep -E "^$VERSION_NAME=.*$" ./gradle.properties | cut -d'=' -f2
}

# Function to remove -SNAPSHOT from version string
strip_snapshot_suffix() {
  local version="$1"
  echo "${version%-SNAPSHOT}"
}

# Function to bump version based on type
bump_version() {
  local current_version=$(strip_snapshot_suffix "$1")  # Remove -SNAPSHOT before bumping
  local bump_type="$2"
  IFS="." read -r major minor patch <<< "$current_version"

  if [ "$bump_type" == "major" ]; then
    major=$((major + 1))
    minor=0
    patch=0
  elif [ "$bump_type" == "minor" ]; then
    minor=$((minor + 1))
    patch=0
  elif [ "$bump_type" == "patch" ]; then
    patch=$((patch))
  else
    echo "Invalid bump type: $bump_type"
    exit 1
  fi

  echo "$major.$minor.$patch"
}

go_to_android_sdk_dir

# Get current version based on sdkType
current_version=$(get_current_version "${VERSION_NAME}")

# Check if current version is found
if [ -z "$current_version" ]; then
  echo "Error: Could not find ${VERSION_NAME} in gradle.properties"
  exit 1
fi

# Bump version based on user selection
new_version=$(bump_version "$current_version" "$VERSION_TYPE")

# Update version in gradle.properties
echo "Updating $VERSION_NAME to: $new_version"
sed -i "s/$VERSION_NAME=.*/$VERSION_NAME=$new_version/" ./gradle.properties

# Set output variable for next steps
echo "NEW_VERSION=$new_version"
