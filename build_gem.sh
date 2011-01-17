gem push `gem build codersdojo.gemspec | grep 'File:' | awk '{print $2}'`
mv codersdojo-*.gem deploy
