# Purpose:
# Rename files in <base path>/disc <#>/* to <base path> directory with ordered names.
# e.g. C:\basepath\disk ##\title##.mkv files to C:\basepath\Episode 0#.mkv
# To Use:
# <arg1>
# <arg1> == base path: base path should have as many

basePath = ARGV[0]
baseFilename = "Episode %02d.mkv"


def cleanBasePath(path)
  fixedPath = path
  if !fixedPath.end_with? "/"
    fixedPath += "/"
  end
  return fixedPath
end

def validPath(path)
  return Dir.exist?(path)
end

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

discPathParent = cleanBasePath(basePath)

if !validPath(discPathParent)
  puts 'ERROR - Invalid path: ' + discPathParent
  exit
end

directories    = getDirectories(discPathParent)
filesRenamed   = 1

directories.each { |directory|
  puts directory
  currentDirectory = discPathParent + directory + "/"
  filesInCurrentDirectory = getFiles(currentDirectory).count 
  workOnDirectory currentDirectory, discPathParent, baseFilename, filesRenamed
  filesRenamed += filesInCurrentDirectory
}

