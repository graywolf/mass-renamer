lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'renamer/version'

Gem::Specification.new do |s|
	# required
	s.name = 'mass_renamer'
	s.version = Renamer::VERSION
	s.summary = 'Rename multiple files with ease!'
	s.authors = 'Gray Wolf'
	s.files = Dir['lib/**/*.rb'] + Dir['bin/*']

	# recommended
	s.email = 'wolf@wolfsden.cz'
	s.homepage = 'https://github.com/graywolf/renamer'
	s.license = 'MIT'

	# optional
	s.bindir = 'bin'
	s.description = <<~EOF
		Tool for renaming multiple files at once with easy. By
		employing external editor of your choice, you can use
		all the power you editor offers.
	EOF
	s.executables << 'renamer'
	s.executables << 'mass_renamer'
end
