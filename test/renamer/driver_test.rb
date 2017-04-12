require 'test_helper'

module Renamer
class Driver_Test < Minitest::Test

	TEST_DATA = File.join(File.dirname(__FILE__), '..', 'data')

	def setup
		@dir = Dir.mktmpdir
		@old_pwd = Dir.pwd
		FileUtils.copy_entry TEST_DATA, @dir
		Dir.chdir @dir
	end

	def teardown
		Dir.chdir @old_pwd
		FileUtils.remove_entry @dir
	end

	def test_target_dir_exists
		Driver.new({ dir: @dir })
	end

	def test_target_dir_doesnt_exists
		assert_raises(IOError) do
			Driver.new({ dir: 'this_dir_probably_does_not_exist' })
		end
	end

end
end
