#!/bin/bash

# This utility script can generate the conjur-env,
# placed in the buildpack/vendor directory,
# then fully package the buildpack for usage.
#
# The buildpack-packager expects all buildpack relevant files
# and folders to be housed in the top-level directory.
# To keep a logical divide between our `bin`, and the buildpack `bin`,
# we move the buildpack relevant files to a `pkg` folder before running
# buildpack-packager

cd "$(dirname $0)"

echo "Removing previous builds..."
rm -rf ./buildpack/conjur-env/vendor
rm -f "conjur_buildpack-v$(cat VERSION)"

echo "Building the conjur-env..."
./buildpack/conjur-env/build.sh

echo "Building the image for buildpack-packager..."
docker build -t packager -f Dockerfile.packager .

echo "Packaging the conjur-buildpack as a zip file..."
docker run --rm \
  -w /cyberark \
  -v $(pwd):/cyberark \
  packager \
  /bin/bash -c """
  # Create pkg folder that is the repository of the final artefacts
  mkdir /pkg
  # Copy the final artefacts to pkg
  cp manifest.yml CHANGELOG.md CONTRIBUTING.md LICENSE NOTICES.txt README.md VERSION /pkg
  cp -R ./buildpack/* /pkg
  # Run buildpack-packager in /pkg
  pushd /pkg
    buildpack-packager build -any-stack
  popd
  # Move any created zip files from /pkg to the working directory
  mv /pkg/*.zip .
  """