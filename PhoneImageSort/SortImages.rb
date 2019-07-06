require 'mp4info'
require 'exifr'
require 'date'

$errorDate = DateTime.new(1900,1,1)
$testRun = false

def buildDestinationPathByFilename(path, fileToMove, baseDestinationPath)
  indexOfYearInFilename = getIndexOfYearInFilename(fileToMove)
  if (indexOfYearInFilename == -1)
    return "ERROR"
  end
  fileYear = fileToMove[indexOfYearInFilename, 4]
  fileMonth = fileToMove[indexOfYearInFilename + 4, 2]
  filenameWithoutPath = fileToMove
  if (!fileYear.match(/^\d+$/) or !fileMonth.match(/^\d+$/))
    return "ERROR"
  end
  resultingPath = baseDestinationPath + fileYear + "/" + fileMonth + "/"
  FileUtils::mkdir_p resultingPath
  return resultingPath + filenameWithoutPath
end

def buildDestinationPathByExifData(path, fileToMove, baseDestinationPath)
  fileDate = Time.now
  puts "FileDate init:" + fileDate.strftime("%Y%m%d")
  if fileToMove.end_with? "jpg" or fileToMove.end_with? "jpeg"
    fileDate = getExifDateForJpg(path + fileToMove)
    puts "FileDate exif:" + fileDate.strftime("%Y%m%d")
  else
    if fileToMove.end_with? "mp4"
      #we can't get exif data from mp4 files
      return "ERROR"
    end
  end
  if (fileDate == $errorDate)
    return "ERROR"
  end
  fileYear = "%04d" % fileDate.year
  fileMonth = "%02d" % fileDate.month
  resultingPath = baseDestinationPath + fileYear + "/" + fileMonth + "/"
  FileUtils::mkdir_p resultingPath
  return resultingPath + fileToMove
end

def getExifDateForJpg(filename)
  require 'exifr/jpeg'
  puts "Getting EXIF data for: " + filename
  jpeg = EXIFR::JPEG.new(filename)
  if (jpeg.exif?)
    if (!jpeg.date_time.nil?)
      return jpeg.date_time
    else
      if (!jpeg.date_time_original.nil?)
        return jpeg.date_time_original
      else
        puts "ERROR: No exif date"
        return $errorDate
      end
    end
  else
    puts "ERROR: No exif data at all"
    return $errorDate
  end
end

def getDateFromMp4Filename(filenamem, indexOfYearInFilename)
  puts "MP4 Filename:" + filename
  puts "MP4 Edited Filename:" + File.basename(filename)
  puts "MP4 Stripped Filename:" + File.basename(filename)[(indexOfYearInFilename)..(indexOfYearInFilename+7)]
  return DateTime.strptime(File.basename(filename)[(indexOfYearInFilename)..(indexOfYearInFilename+7)], "%Y%m%d")
end

def getFiles(path)
  if (Dir.exists?(path))
    return Dir.entries(path).select {|entry| File.file? File.join(path,entry)}
  else
    return nil
  end
end

def getDirectories(path)
  if (Dir.exists?(path))
    return Dir.entries(path).select {|entry| File.directory? File.join(path,entry) and !(entry =='.' || entry == '..' || entry.start_with?(".")) }
  else
    return nil
  end
end

def shouldSkipFile(filename)
  return (filename.start_with?(".") or filename == "Thumbs.db" or getIndexOfYearInFilename(filename) == -1)
end

def copyFiles(files, fromPath, baseDestinationPath)
  if !files.nil?
    files.each { |file|
      next if shouldSkipFile(file)
      fullOriginationFilename = fromPath + file
      puts "Working on file:" + fullOriginationFilename
      destinationPath = buildDestinationPathByExifData(fromPath, file, baseDestinationPath)
      if (destinationPath == "ERROR")
        indexOfYearInFilename = getIndexOfYearInFilename(file)
        puts "Using filename for date for: %s with year index of %d" % [file, indexOfYearInFilename]
        destinationPath = buildDestinationPathByFilename(fromPath, file, baseDestinationPath)
      end
      puts "DestinationPath:" + destinationPath
      if (destinationPath == "ERROR")
        puts "Skipping " + fromPath
      else
        if ($testRun)
          puts "DOING NOTHING"
        else
          if (File.exists?(destinationPath))
            File.delete(fullOriginationFilename)
          else
            FileUtils::move(fullOriginationFilename, destinationPath)
          end
        end
      end
    }
  end
end

def processFolder(fromPath, baseDestinationPath)
  copyFiles(getFiles(fromPath), fromPath, baseDestinationPath)
  dirs = getDirectories(fromPath)
  if dirs.nil?
    dirs.each { |directory|
      puts "Working on directory:" + directory
      processFolder(directory, baseDestinationPath)
    }
  end
end

def getIndexOfYearInFilename(filename)
  case filename[0,3]
  when "IMG"
    return 4
  when "PHO"
    return 6
  when "VID"
    return filename.index("_") + 1
  else
    puts "UNRECOGNIZED FILE FORMAT: " + filename
    return -1
  end
end

def copyMariaFiles()
  baseDestinationImagePath = "D:/Pictures/"
  basePhoneImagePath = "D:/Pictures/From Maria\'s Phone/Android/"
  processFolder(basePhoneImagePath, baseDestinationImagePath)
  basePhoneImagePath = "D:/Pictures/From Maria\'s Phone/Android/.LiveShot/"
  processFolder(basePhoneImagePath, baseDestinationImagePath)
end

def copyBryanFiles()
  baseDestinationImagePath = "D:/Pictures/"
  basePhoneImagePath = "D:/Pictures/From Bryan Phone/"
  processFolder(basePhoneImagePath, baseDestinationImagePath)
  basePhoneImagePath = "D:/Pictures/From Bryan Phone/.LiveShot/"
  processFolder(basePhoneImagePath, baseDestinationImagePath)
end

copyBryanFiles()
#copyMariaFiles()
puts("Done!")
