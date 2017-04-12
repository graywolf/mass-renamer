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

	def test_gather_files_simple
		d = Driver.new({ dir: @dir })
		assert_equal(
			%W{folder1 folder2 folder3 file1 file2 file3}.sort,
			d.gather_files.sort
		)
	end

	def test_gather_files_simple_regexp
		d = Driver.new({ dir: @dir, filter: /file/ })
		assert_equal(
			%W{file1 file2 file3}.sort,
			d.gather_files.sort
		)
	end

	ALL_FILES = %W{
		file1
		file2
		file3
		folder1
		folder1/folder1_folder1
		folder1/folder1_folder1/folder1_folder1_file1
		folder1/folder1_folder1/folder1_folder1_file2
		folder1/folder1_folder1/folder1_folder1_file3
		folder1/folder1_folder1/folder1_folder1_folder1
		folder1/folder1_folder1/folder1_folder1_folder1/folder1_folder1_folder1_file1
		folder1/folder1_folder1/folder1_folder1_folder1/folder1_folder1_folder1_file2
		folder1/folder1_folder1/folder1_folder1_folder1/folder1_folder1_folder1_file3
		folder1/folder1_folder1/folder1_folder1_folder2
		folder1/folder1_folder1/folder1_folder1_folder2/folder1_folder1_folder2_file1
		folder1/folder1_folder1/folder1_folder1_folder2/folder1_folder1_folder2_file2
		folder1/folder1_folder1/folder1_folder1_folder2/folder1_folder1_folder2_file3
		folder1/folder1_folder2
		folder1/folder1_folder2/folder1_folder2_file1
		folder1/folder1_folder2/folder1_folder2_file2
		folder1/folder1_folder2/folder1_folder2_file3
		folder1/folder1_folder3
		folder1/folder1_folder3/folder1_folder3_folder1
		folder1/folder1_folder3/folder1_folder3_folder1/folder1_folder3_folder1_file1
		folder1/folder1_folder3/folder1_folder3_folder1/folder1_folder3_folder1_file2
		folder1/folder1_folder3/folder1_folder3_folder1/folder1_folder3_folder1_file3
		folder2
		folder2/folder2_folder1
		folder2/folder2_folder1/folder2_folder1_file1
		folder2/folder2_folder1/folder2_folder1_file2
		folder2/folder2_folder1/folder2_folder1_file3
		folder2/folder2_folder2
		folder2/folder2_folder2/folder2_folder2_file1
		folder2/folder2_folder2/folder2_folder2_file2
		folder2/folder2_folder2/folder2_folder2_file3
		folder2/folder2_folder3
		folder2/folder2_folder3/folder2_folder3_file1
		folder2/folder2_folder3/folder2_folder3_file2
		folder2/folder2_folder3/folder2_folder3_file3
		folder3
		folder3/folder3_file1
		folder3/folder3_file2
		folder3/folder3_file3
	}

	def test_gather_files_recursive
		d = Driver.new({ dir: @dir, recursive: true })
		assert_equal ALL_FILES.sort, d.gather_files.sort
	end

	def test_gather_files_recursive_regexp
		d = Driver.new({ dir: @dir, recursive: true, filter: /file1/ })
		assert_equal(
			ALL_FILES.select { |i| i[/file1/] }.sort,
			d.gather_files.sort
		)
	end

end
end
