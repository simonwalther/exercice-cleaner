
#!/usr/bin/env ruby

#######
# CREATOR : Walther Simon
# LAST RELEASED : 25 octobre 2013
# USE : fileutils
# UTILITY : destroy old file and empty folder
# ARGUMMENT : optional path, nb day old, type of file

#### LIB ####
require 'fileutils' #lib for remove directory
require 'slop' #lib for argumment
require 'highline/import' #lib for questions user

### CONST ###
SYSTEM_FILES = %w{ . .. .Ds_store }

opts = Slop.new(help: true) do
  banner 'Usage: ruby ./clean.rb -p ~/path/to/your/folder -d 30 -t .yourtype -v'

  on :p, :path=, 'the path', required: true
  on :d, :days=, 'the number of day old', argumment: :optional, as: Integer, default: 30, match: /^\d+$/
  on :t, :type=, 'the type', argumment: :optional
  on :xclude=, 'exclude type', argumment: :optional
  on :v, :verbose, 'Enable verbose mode'
  on :dry, 'Enable dry mode'
  on :confirmation, 'Enabe confirmation mode'
end

begin
  opts.parse
rescue Slop::InvalidArgumentError, Slop::MissingOptionError => e
  puts e
  puts opts
  exit 1
end

if opts.verbose? || opts.dry?
  puts "path : #{opts[:path]}"
  puts "days : #{opts[:days]}"
  puts "type : #{opts[:type]}"
  puts "exclude type : #{opts[:xclude]}"
  puts "verbose ? : #{opts.verbose?}"
  puts "dry ? : #{opts.dry?}"
  puts "confirmation ? : #{opts.confirmation?}"
  puts "missings : #{opts.missing.join(', ')}\n\n"
end

normal_path  = opts[:path]
nb_day       = opts[:days]
type         = opts[:type]
exclude_type = opts[:xclude]
confirmation = opts[:confirmation]

raise ArgumentError, 'you must give a path' if normal_path.empty?

actual_date  = Time.new
normal_path  = File.expand_path(normal_path)

raise ArgumentError, "this is the racine of your computer" if normal_path == '/'


files = (Dir.glob(normal_path + "/**/*#{type}").reverse.reject{ |p| SYSTEM_FILES.include?(p)}).reject{ |p| File.extname(p) == exclude_type}

total_file = files.count

if total_file == 0
  puts "there is no file !"
  exit 0
end

if opts.verbose? || opts.dry?
  puts "--- all file ---"
  puts "#{files.join("\n")}"
  puts "\n--- deleted file ---"
end

nb_deleted_file = 0

files.each do |path|
  modification_date = File.mtime(path)
  difference = ((actual_date.year - modification_date.year)*365) + (actual_date.yday - modification_date.yday)

  if difference >= nb_day
    if opts.verbose? || opts.dry?
      puts "#{path} : old file"
    end

    if opts.dry? == false
      if opts.confirmation? == true

        say("Do you want to delete #{path} ?")
        choose do |menu|
          menu.prompt = "==>"
          menu.choice :yes do FileUtils.rm_rf(path) end
          menu.choices :no do say("not delete") end
        end
      else
        FileUtils.rm_rf(path)
      end
    else
      nb_deleted_file += 1
    end
  elsif File.directory?(path)
    if (Dir.entries(path).reject { |p| SYSTEM_FILES.include?(p) } ).count == 0
      if opts.verbose? || opts.dry?
        puts "#{path} : empty directory"
      end

      if opts.dry? == false
        if opts.confirmation? == true

          say("Do you want to delete #{path} ?")
          choose do |menu|
            menu.choice :yes do FileUtils.rm_rf(path) end
            menu.choices :no do say("not delete") end
          end
        else
          FileUtils.rm_rf(path)
        end
      else
        nb_deleted_file += 1
      end
    end
  end
end

if opts.dry? == false
  nb_file_after = (Dir.glob(normal_path + "/**/*#{type}").reverse.reject{ |p| SYSTEM_FILES.include?(p) }).count
  nb_deleted_file =  total_file - nb_file_after
end

percentage_deleted = ((nb_deleted_file.to_f/total_file)*100).to_i

if opts.verbose? || opts.dry?
  puts "\n--- stats ---"
  puts "number of deleted file : #{nb_deleted_file}"
  puts "percentage of deleted file : #{percentage_deleted}%"
end
