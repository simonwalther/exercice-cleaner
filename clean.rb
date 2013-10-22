
#!/usr/bin/env ruby

#######
# CREATOR : Walther Simon
# LAST RELEASED : 17 octobre 2013
# USE : fileutils
# UTILITY : destroy old file and empty folder
# ARGUMMENT : optional path, nb day old, type of file


require 'fileutils' #lib for remove directory
normal_path = nil
nb_day = 30
parmaters = 0
actual_date = Time.new
why_deleted = " "
type = nil
nb_deleted_file = 0

ARGV.each do|argumment|

  case parmaters
  when 0
    normal_path = argumment
  when 1
    nb_day = argumment.to_i
  when 2
    type = argumment.to_s
  end

  parmaters += 1
end

if(normal_path == nil || normal_path == "/" || normal_path == "./" || normal_path == "~/")
  puts "an error occured : #0 this is the racine of your computer"
else
  file = Dir.glob(normal_path + "/**/*#{type}").reverse
  no_system_file = %w{ . .. .DS_Store}
  total_file = file.size
  
  if(total_file == 0)
    puts "an error occured : #1 there is no file"
  else
    def remove_file(nb_file, why_deleted)
        puts "#{why_deleted}"
        FileUtils.rm_rf(nb_file)
    end

    file.each do |nb_file|
      modification_date = File.mtime(nb_file)
      difference = ((actual_date.year - modification_date.year)*365) + (actual_date.yday - modification_date.yday)
      is_directory = File.directory?(nb_file)

      if(difference >= nb_day)
        why_deleted = "[old file/directory]  "
        remove_file(nb_file, why_deleted)
        nb_deleted_file += 1
      elsif(is_directory == true) #vide sans compter les . .. ou .DS_Store
        if((Dir.entries(nb_file) - no_system_file).size == 0)
          why_deleted = "[empty directory]  "
          remove_file(nb_file, why_deleted)
          nb_deleted_file += 1
        end
      else
        puts "[not destroyed]  "
      end
    end

    percentage_deleted = ((nb_deleted_file.to_f/total_file)*100).to_i
    puts "\nnumber of deleted file : #{nb_deleted_file}"
    puts "percentage of deleted file : #{percentage_deleted}%"
  end
end