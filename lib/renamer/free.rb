require 'pathname'
require 'tempfile'

module Renamer
	module Free

		def gather_files_impl dir, recursive
			children = dir.children false
			sort_files! children
			if recursive
				children.collect! do |c|
					filepath = dir + c
					if filepath.directory?
						[filepath, gather_files_impl(filepath, recursive)]
					else
						filepath
					end
				end.flatten!
			end
			children
		end

		def gather_files(dir, recursive: false, filter: nil)
			files = gather_files_impl Pathname.new(dir), recursive
			filter_files! files, filter if filter
			exclude_weird_filenames! files
			files
		end

		def filter_files! files, filter
			files.select! { |i| i.to_s[filter] } if filter
		end

		def exclude_weird_filenames! files
			files.reject! { |f| f = f.to_s; f.include?("\n") or f.start_with?(" ") }
		end

		def sort_files! files
			files.sort! do |a,b|
				if a.directory? and b.directory?
					a <=> b
				elsif a.directory?
					-1
				elsif b.directory?
					1
				else
					a <=> b
				end
			end
		end

		def generate_file_to_edit files
			res = ""
			files.each do |f|
				res << f.to_s << "\n\t" << f.to_s << "\n"
			end
			res
		end

		def parse_renames str
			lines = str.lines.map(&:chomp).reject { |l| l[/^\s*$/] }
			renames = []
			until lines.empty?
				filename = lines.shift
				targets = []
				while lines[0] and lines[0] =~ /^\s/
					targets << lines.shift.strip
				end
				renames << [filename, targets]
			end
			renames
		end

	end
end
