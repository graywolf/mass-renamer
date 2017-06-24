require 'optparse'

module Renamer

	class Command_Line
		def initialize argv = ARGV
			opts = parse argv
			@driver = Driver.new opts
		end

		def rename!
			@driver.rename!
		end

		def parse argv
			opts = {}
			OptionParser.new do |opt|
				opt.banner = 'Usage: renamer [DIRECTORY] [OPTIONS]'
				opt.separator ''
				opt.separator 'DIRECTORY in which you want to rename. If not'
				opt.separator 'provided, `pwd` is used.'
				opt.separator ''
				opt.separator 'Editor to use is determined by this priority:'
				opt.separator '  --editor'
				opt.separator '  $EDITOR'
				opt.separator '  vim'
				opt.separator ''
				opt.separator 'Options:'

				opt.on('-h', '--help', 'Print usage') do
					puts opt
					exit
				end
				opt.on('-d', '--dry', 'Dry run') do
					opts[:dry] = true
				end
				opt.on('-r', '--recursive', 'Recurse into subdirectories') do
					opts[:recursive] = true
				end
				opt.on('-f', '--force', 'Don\'t ask if target exists') do
					opts[:force] = true
				end
				opt.on('-D', '--no-delete', 'Completely disables delete function') do
					opts[:no_delete] = true
				end
				opt.on('-v', '--verify', 'Ask for consent before doing each action') do
					opts[:verify] = true
				end
				opt.on('-k', '--keep-going', 'Keep going after failure') do
					opts[:keep_going] = true
				end
				opt.on('-V', '--verbose', 'Be verbose') do
					opts[:verbose] = true
				end
				opt.on('--version', 'Print version') do
					opts[:version] = true
				end
				opt.on('-e', '--editor EDITOR', 'Editor to use') do |editor|
					opts[:editor] = editor
				end
				opt.on('-f', '--filter REGEX', Regexp, 'Regex used to filter files') do |filter|
					opts[:filter] = filter
				end
			end.parse!(argv)
			opts[:dir] = argv[0] || Dir::pwd
			opts[:editor] ||= ENV['EDITOR'] || 'vim'
			opts
		end
	end

end
