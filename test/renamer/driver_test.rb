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

class Driver_Test < Driver_Test_Base

	def test_target_dir_exists
		Driver.new({ dir: @dir })
	end

	def test_target_dir_doesnt_exists
		assert_raises(IOError) do
			Driver.new({ dir: 'this_dir_probably_does_not_exist' })
		end
	end

end

class Driver_Free_Test < Driver_Test_Base

	def test_gather_files_simple
		assert_equal(
			%W{folder1 folder2 folder3 file1 file2 file3}.map { |f| Pathname.new f },
			gather_files(?.)
		)
	end

	def test_gather_files_simple_regexp
		assert_equal(
			%W{file1 file2 file3}.map { |f| Pathname.new f },
			gather_files(?., filter: /file/)
		)
		assert_equal(
			%W{folder1 file1}.map { |f| Pathname.new f },
			gather_files(?., filter: /1/)
		)
	end

	ALL_FILES = %W{
		folder1
		folder1/folder1
		folder1/folder1/folder1
		folder1/folder1/folder1/file1
		folder1/folder1/folder1/file2
		folder1/folder1/folder1/file3
		folder1/folder1/folder2
		folder1/folder1/folder2/file1
		folder1/folder1/folder2/file2
		folder1/folder1/folder2/file3
		folder1/folder1/file1
		folder1/folder1/file2
		folder1/folder1/file3
		folder1/folder2
		folder1/folder2/file1
		folder1/folder2/file2
		folder1/folder2/file3
		folder1/folder3
		folder1/folder3/folder1
		folder1/folder3/folder1/file1
		folder1/folder3/folder1/file2
		folder1/folder3/folder1/file3
		folder2
		folder2/folder1
		folder2/folder1/file1
		folder2/folder1/file2
		folder2/folder1/file3
		folder2/folder2
		folder2/folder2/file1
		folder2/folder2/file2
		folder2/folder2/file3
		folder2/folder3
		folder2/folder3/file1
		folder2/folder3/file2
		folder2/folder3/file3
		folder3
		folder3/file1
		folder3/file2
		folder3/file3
		file1
		file2
		file3
	}.map { |f| Pathname.new f }

	def test_gather_files_recursive
		assert_equal ALL_FILES, gather_files(?., recursive: true)
	end

	ALL_FILE1 = %W{
		folder1/folder1/folder1/file1
		folder1/folder1/folder2/file1
		folder1/folder1/file1
		folder1/folder2/file1
		folder1/folder3/folder1/file1
		folder2/folder1/file1
		folder2/folder2/file1
		folder2/folder3/file1
		folder3/file1
		file1
	}.map { |f| Pathname.new f }

	def test_gather_files_recursive_regexp
		assert_equal(
			ALL_FILE1,
			gather_files(?., recursive: true, filter: /file1/)
		)
	end

	def test_exclude_weird_filename
		files = [
			"normal",
			"with new\n line",
			" starting with space",
			"also kinda normal"
		]
		exclude_weird_filenames! files
		assert_equal(["normal", "also kinda normal"], files)
	end

	def test_sort_files
		files = %W{file1 folder2 folder1 file3}.map { |f| Pathname.new f }
		expected = %W{folder1 folder2 file1 file3}.map { |f| Pathname.new f }
		sort_files! files
		assert_equal(expected, files)
	end

	def test_generate_file_to_edit
		files = %W{folder1/file1 file1 file2 file3}
		expected = <<~EOF
			folder1/file1
			\tfolder1/file1
			file1
			\tfile1
			file2
			\tfile2
			file3
			\tfile3
		EOF
		assert_equal(expected, generate_file_to_edit(files))
	end

	def test_parse_renames
		str = <<~EOF
			folder1/file1
			  folder1/file1
			file1
			  file1
			file2
			  file2
			file3
			  file3
		EOF
		expected = []
		%W{folder1/file1 file1 file2 file3}.each { |e| expected << [e, [e]] }
		assert_equal(expected, parse_renames(str))

		str = <<~EOF
			folder1/file1
			  folder1/file1
			  folder1/file2
			  tmpfile
			file1
				file2
			file3
			file2
				file3
			tmpfile
			  file1
		EOF
		expected = [
			['folder1/file1', %W{folder1/file1 folder1/file2 tmpfile}],
			['file1', %W{file2}],
			['file3', %W{}],
			['file2', %W{file3}],
			['tmpfile', %W{file1}],
		]
		assert_equal(expected, parse_renames(str))
	end

end
end
