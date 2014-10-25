require 'rubygems'
require 'mp4info'

image_file = ARGV.first
metadata = MP4Info.open("E:/Pictures/From Bryan Phone/Camera roll/Camera/VID_20140301_130553.mp4")

puts "Standard items".center(72)
puts "=" * 72
puts "                          File : #{image_file}"
puts

puts "Meta data information".center(72)
puts "=" * 72
#h = meta.exif.to_hash
#h.each_pair do |k,v|
#    puts "#{k.to_s.rjust(30)} : #{v}"
#end
