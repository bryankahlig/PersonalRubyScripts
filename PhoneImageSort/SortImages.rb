require 'mp4info'
require 'exifr'
require 'date'

$errorDate = DateTime.new(1900,1,1)

def buildDestinationPathByFilename(path, fileToMove, baseDestinationPath, indexOfYearInFilename)
  fileYear = fileToMove[indexOfYearInFilename, 4]
  fileMonth = fileToMove[indexOfYearInFilename + 4, 2]
  filenameWithoutPath = fileToMove
  resultingPath = baseDestinationPath + fileYear + "/" + fileMonth + "/"
  FileUtils::mkdir_p resultingPath
  return resultingPath + filenameWithoutPath
end

#def buildDestinationPathByCreatedDate(path, fileToMove, baseDestinationPath)
#  fullFilename = path + fileToMove
#  fileDate = File.ctime(fullFilename)
#  fileYear = "%04d" % fileDate.year
#  fileMonth = "%02d" % fileDate.month
#  resultingPath = baseDestinationPath + fileYear + "/" + fileMonth + "/"
#  FileUtils::mkdir_p resultingPath
#  return resultingPath + fileToMove    
#end

def buildDestinationPathByExifData(path, fileToMove, baseDestinationPath)
  fileDate = Time.now
  puts "FileDate init:" + fileDate.strftime("%Y%m%d")
  if fileToMove.end_with? "jpg" or fileToMove.end_with? "jpeg"
    fileDate = getExifDateForJpg(path + fileToMove)
    puts "FileDate init:" + fileDate.strftime("%Y%m%d")
  else
    if fileToMove.end_with? "mp4"
      fileDate = getDateFromMp4Filename(path + fileToMove)
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

def getDateFromMp4Filename(filename)
  puts "MP4 Filename:" + filename
  puts "MP4 Edited Filename:" + File.basename(filename)
  puts "MP4 Stripped Filename:" + File.basename(filename)[4..11]
  return DateTime.strptime(File.basename(filename)[4..11], "%Y%m%d")
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
  return (filename.start_with?(".") or filename == "Thumbs.db")
end

def copyFiles(files)
  if !files.nil?
    files.each { |file|
      next if shouldSkipFile(file)
      fullOriginationFilename = fromPath + file
      puts "Working on file:" + fromPath + file
      #destinationPath = buildDestinationPathByFilename(fromPath, file, baseDestinationPath, indexOfYearInFilename)
      destinationPath = buildDestinationPathByExifData(fromPath, file, baseDestinationPath)
  #    destinationPath = buildDestinationPathByCreatedDate(fromPath, file, baseDestinationPath)
      puts "DestinationPath:" + destinationPath
      if (destinationPath == "ERROR")
        puts "Skipping " + fromPath
      else
        puts "DOING NOTHING"
        #FileUtils::copy_file(fullOriginationFilename, destinationPath)
      end
    }
  end
end

def processFolder(fromPath, baseDestinationPath, indexOfYearInFilename)
  copyFiles(getFiles(fromPath))
  dirs = getDirectories(fromPath)
  if dirs.nil?
    dirs.each { |directory|
      puts "Working on directory:" + directory
      processFolder(directory, baseDestinationPath, 4)
    }
  end
end

def copyMariaFiles()
  baseDestinationImagePath = "E:/Pictures/"
  basePhoneImagePath = "E:/Pictures/From Maria\'s Phone/Camera roll/"
  processFolder(basePhoneImagePath, baseDestinationImagePath, 3)
end

def copyBryanFiles()
  baseDestinationImagePath = "E:/Pictures/"
  basePhoneImagePath = "E:/Pictures/From Bryan Phone/Camera roll/Camera/"
  processFolder(basePhoneImagePath, baseDestinationImagePath, 4)
end

copyBryanFiles()

