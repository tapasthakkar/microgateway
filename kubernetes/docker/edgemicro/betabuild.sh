#!/bin/bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo DIR is $DIR

if [ $# -lt 1 ]; then
	echo "Usage: $0 <branch> [semantic-version] [gcp-project-id] [github-repo]"
	echo "Example: $0 for-3.3.9"
	echo "Example: $0 feat-auth 3.3.9"
        exit 1
fi

branch=$1
semver=$2
project_id=${3:-apigee-microgateway}
repo=${4:-apigee-internal/microgateway}

if [ -z "$semver" ]; then
  if [[ "$branch" =~ for-([0-9]+\.[0-9]+\.[0-9]+) ]]; then
    semver="${BASH_REMATCH[1]}"
    echo "Extracted version $semver from branch $branch"
  else
    echo "Error: Cannot extract version from branch '$branch'."
    echo "Please provide the semantic version as the second argument."
    exit 1
  fi
fi

# Using '|' as the sed delimiter eliminates the need to escape slashes in the repo path
sed -i.bak  "s| *edgemicro.*| ${repo}#$branch|g" installnode.sh

# Build with --platform linux/amd64 to ensure it runs correctly on general-purpose servers (x86_64) instead of ARM64
docker build --platform linux/amd64 --no-cache -t edgemicro-beta:$branch $DIR -f Dockerfile.beta

# Query existing tags to find the next beta number
echo "Querying existing tags for public-image-$semver-beta.*"
existing_tags=$(gcloud artifacts tags list --repository=edgemicro-beta --location=us-west1 --package=emg --project="$project_id" 2>/dev/null | grep -o "public-image-$semver-beta\.[0-9]\+")

max=0
for tag in $existing_tags; do
  if [[ "$tag" =~ public-image-$semver-beta\.([0-9]+) ]]; then
    n="${BASH_REMATCH[1]}"
    if (( n > max )); then
      max=$n
    fi
  fi
done

new_n=$((max + 1))
echo "Next beta number is $new_n"
new_tag="public-image-$semver-beta.$new_n"

# Tag and push the new image
docker tag edgemicro-beta:$branch us-west1-docker.pkg.dev/$project_id/edgemicro-beta/emg:$new_tag
docker push us-west1-docker.pkg.dev/$project_id/edgemicro-beta/emg:$new_tag

# Add deprecated tags to older images
for tag in $existing_tags; do
  if [[ "$tag" =~ public-image-$semver-beta\.([0-9]+) ]]; then
    n="${BASH_REMATCH[1]}"
    dep_tag="deprecated-public-image-$semver-beta.$n"
    
    echo "Adding tag $dep_tag to existing tag $tag"
    gcloud artifacts docker tags add "us-west1-docker.pkg.dev/$project_id/edgemicro-beta/emg:$tag" "us-west1-docker.pkg.dev/$project_id/edgemicro-beta/emg:$dep_tag"
  fi
done
rm installnode.sh
mv installnode.sh.bak installnode.sh

