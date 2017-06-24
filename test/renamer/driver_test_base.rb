require 'test_helper'

module Renamer
class Driver_Test_Base < Minitest::Test

	include Free

	TEST_DATA = File.join(File.dirname(__FILE__), '..', 'data')

	def setup
		super
		@dir = Dir.mktmpdir
		@old_pwd = Dir.pwd
		FileUtils.copy_entry TEST_DATA, @dir
		Dir.chdir @dir
	end

	def teardown
		super
		Dir.chdir @old_pwd
		FileUtils.remove_entry @dir
	end

end
end
