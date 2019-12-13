sbt clean clean-files
find . -name target -type d -exec rm -rf '{}' \;
rm -rf target
rm -rf bin
