set -ev
if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  git clone https://github.com/$TRAVIS_REPO_SLUG.git $TRAVIS_REPO_SLUG
  cd $TRAVIS_REPO_SLUG
  git checkout master
  git checkout -qf $TRAVIS_COMMIT
fi
chef exec rake except_kitchen
