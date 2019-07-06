# Phone Image Sort

## Purpose
Sort images copied from phones to the appropriate folder based on dates.

## Use
```
ruby ./SortImages.rb
```

## Details
1. Exif data is used when present, otherwise the filename is inspected for a date.
1. When exif data is not present, files must have a prefix of one of a few different options such as IMG, VID, VIDEO, or PHOTO.
1. Files must have a date in the format of YYYYMMDD in the name after the prefix.
1. The source and the destination of the files are hard coded.
1. Run in "test" mode first validating the destination of the files in the output.
1. To run in "test" mode where logs are written but no files are modified, set $testRun to false. To move files, set $testRun to true.
