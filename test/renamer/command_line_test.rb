require 'test_helper'

module Renamer
class Command_Line_Test < Minitest::Test

	def test_parse_argv
		base_res = { dir: Dir::pwd, editor: ENV['EDITOR'] || 'vim' }.freeze
		res = Command_Line.new.parse %W{}
		assert_equal(base_res, res)
		res = Command_Line.new.parse %W{testdir}
		assert_equal(base_res.dup.merge({ dir: 'testdir' }), res)

		res = Command_Line.new.parse %W{--dry}
		assert_equal(base_res.dup.merge({ dry: true }), res)
		res = Command_Line.new.parse %W{-d}
		assert_equal(base_res.dup.merge({ dry: true }), res)

		res = Command_Line.new.parse %W{--editor nano}
		assert_equal(base_res.dup.merge({ editor: 'nano' }), res)
		res = Command_Line.new.parse %W{-e nano}
		assert_equal(base_res.dup.merge({ editor: 'nano' }), res)

		assert_raises(RegexpError) do
			res = Command_Line.new.parse %W{--filter *.txt}
		end
		res = Command_Line.new.parse %W{--filter .*\\.txt}
		assert_equal(base_res.dup.merge({ filter: /.*\.txt/ }), res)
		res = Command_Line.new.parse %W{-f .*\\.txt }
		assert_equal(base_res.dup.merge({ filter: /.*\.txt/ }), res)

		res = Command_Line.new.parse %W{--version}
		assert_equal(base_res.dup.merge({ version: true }), res)

		res = Command_Line.new.parse %W{--recursive}
		assert_equal(base_res.dup.merge({ recursive: true }), res)
		res = Command_Line.new.parse %W{-r}
		assert_equal(base_res.dup.merge({ recursive: true }), res)

		res = Command_Line.new.parse %W{--verbose}
		assert_equal(base_res.dup.merge({ verbose: true }), res)
		res = Command_Line.new.parse %W{-V}
		assert_equal(base_res.dup.merge({ verbose: true }), res)

		res = Command_Line.new.parse %W{--verify}
		assert_equal(base_res.dup.merge({ verify: true }), res)
		res = Command_Line.new.parse %W{-v}
		assert_equal(base_res.dup.merge({ verify: true }), res)

		res = Command_Line.new.parse %W{--no-delete}
		assert_equal(base_res.dup.merge({ no_delete: true }), res)
		res = Command_Line.new.parse %W{-D}
		assert_equal(base_res.dup.merge({ no_delete: true }), res)

		res = Command_Line.new.parse %W{--keep-going}
		assert_equal(base_res.dup.merge({ keep_going: true }), res)
		res = Command_Line.new.parse %W{-k}
		assert_equal(base_res.dup.merge({ keep_going: true }), res)

		res = Command_Line.new.parse %W{--force}
		assert_equal(base_res.dup.merge({ force: true }), res)
		res = Command_Line.new.parse %W{-F}
		assert_equal(base_res.dup.merge({ force: true }), res)

		res = Command_Line.new.parse %W{-d -e vim testdir}
		assert_equal(base_res.dup.merge({ dry: true, editor: 'vim', dir: 'testdir'}), res)
		res = Command_Line.new.parse %W{-d testdir -e vim}
		assert_equal(base_res.dup.merge({ dry: true, editor: 'vim', dir: 'testdir'}), res)
	end

	def test_target_dir_exists
		Dir.mktmpdir do |d|
			Command_Line.new [d]
		end
	end

	def test_target_dir_doesnt_exists
		assert_raises(IOError) do
			Command_Line.new ['/tmp/this_dir_probably_does_not_exist']
		end
	end

end
end
