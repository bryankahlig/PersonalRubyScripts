basePath = "E:/My Movies Temp/The Red Green Show/"
seasonPath = "Season 5/"
baseFilename = "Episode %02d.mkv"

discPathParent = basePath + seasonPath

def getDirectories(path)
  return Dir.entries(path).select {|entry| File.directory? File.join(path,entry) and !(entry =='.' || entry == '..') }
end

def getFiles(path)
  return Dir.entries(path).select {|entry| File.file? File.join(path,entry)}
end

def workOnDirectory(pathOfFiles, pathToPlaceFiles, baseFilename, filesRenamed)
  files = getFiles pathOfFiles
  files.each { |file|
    oldFilename = pathOfFiles + file
    newFilename = pathToPlaceFiles + baseFilename % filesRenamed
    filesRenamed += 1
    puts "Old: " + oldFilename + " ==== NEW: " + newFilename
    File.rename(oldFilename, newFilename)
  }
end

directories = getDirectories discPathParent
filesRenamed = 1

directories.each { |directory|
  puts directory
  currentDirectory = discPathParent + directory + "/"
  filesInCurrentDirectory = getFiles(currentDirectory).count 
  workOnDirectory currentDirectory, discPathParent, baseFilename, filesRenamed
  filesRenamed += filesInCurrentDirectory
}

#workOnDirectory "E:/My Movies Temp/The Red Green Show/Season 3/", "E:/My Movies Temp/The Red Green Show/Season 3/", baseFilename
