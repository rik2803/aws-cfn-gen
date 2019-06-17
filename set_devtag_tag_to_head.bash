export TAG=devtag
git tag -d ${TAG}
git push --delete origin refs/tags/${TAG}
git tag ${TAG}
git push --tags