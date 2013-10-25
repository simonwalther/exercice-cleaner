
#!/usr/bin/env ruby

#######
# CREATOR : Walther Simon
# LAST RELEASED : 17 octobre 2013
# USE : fileutils
# UTILITY : destroy old file and empty folder
# ARGUMMENT : optional path, nb day old, type of file

#### LIB ####
require 'fileutils' #lib for remove directory

### CONST ###
SYSTEM_FILES = %w{ . .. .Ds_store }

normal_path  = ARGV[0].to_s
nb_day       = ARGV[1].to_i || 30
type         = ARGV[2].to_s
raise ArgumentError, 'you must give a path' if normal_path.empty?

actual_date  = Time.new
normal_path  = File.expand_path(normal_path)
raise ArgumentError, "this is the racine of your computer" if normal_path == '/'

files = Dir.glob(normal_path + "/**/*#{type}").reverse.reject{ |p| SYSTEM_FILES.include?(p) }
total_file = files.count

if total_file == 0
  puts "there is no file !"
  return exit(0)
end

files.each do |path|
  modification_date = File.mtime(path)
  difference = ((actual_date.year - modification_date.year)*365) + (actual_date.yday - modification_date.yday)
  if difference >= nb_day
    FileUtils.rm_rf(path)

  elsif File.directory?(path)

    if (Dir.entries(path).reject { |p| SYSTEM_FILES.include?(p) } ).count == 0
      FileUtils.rm_rf(path)
    end
  end
end

nb_file_after = (Dir.glob(normal_path + "/**/*#{type}").reverse.reject{ |p| SYSTEM_FILES.include?(p) }).count
nb_deleted_file =  total_file - nb_file_after
percentage_deleted = ((nb_deleted_file.to_f/total_file)*100).to_i

puts "number of deleted file : #{nb_deleted_file}"
puts "percentage of deleted file : #{percentage_deleted}%"
