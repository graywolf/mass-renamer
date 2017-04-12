module Renamer

	class Driver

		def initialize opts
			@opts = opts
			validate_environment!
		end

		def rename!
			files = gather_files
		end

		def gather_files
			files = Dir.glob(@opts[:recursive] ? '**/*' : '*')
			files.select! { |i| i[@opts[:filter]] } if @opts[:filter]
			files
		end

		def validate_environment!
			raise IOError, "Directory does not exist." unless File.exist? @opts[:dir]
		end

	end
end
