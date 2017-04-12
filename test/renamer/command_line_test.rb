require 'test_helper'

module Renamer
class Command_Line_Test < Minitest::Test

	def test_parse_argv
		base_res = { dir: Dir::pwd, editor: ENV['EDITOR'] || 'vim' }.freeze
		res = Command_Line.parse %W{}
		assert_equal(base_res, res)
		res = Command_Line.parse %W{testdir}
		assert_equal(base_res.dup.merge({ dir: 'testdir' }), res)

		res = Command_Line.parse %W{--dry}
		assert_equal(base_res.dup.merge({ dry: true }), res)
		res = Command_Line.parse %W{-d}
		assert_equal(base_res.dup.merge({ dry: true }), res)

		res = Command_Line.parse %W{--editor nano}
		assert_equal(base_res.dup.merge({ editor: 'nano' }), res)
		res = Command_Line.parse %W{-e nano}
		assert_equal(base_res.dup.merge({ editor: 'nano' }), res)

		res = Command_Line.parse %W{--version}
		assert_equal(base_res.dup.merge({ version: true }), res)

		res = Command_Line.parse %W{--recursive}
		assert_equal(base_res.dup.merge({ recursive: true }), res)
		res = Command_Line.parse %W{-r}
		assert_equal(base_res.dup.merge({ recursive: true }), res)

		res = Command_Line.parse %W{--verbose}
		assert_equal(base_res.dup.merge({ verbose: true }), res)
		res = Command_Line.parse %W{-V}
		assert_equal(base_res.dup.merge({ verbose: true }), res)

		res = Command_Line.parse %W{--verify}
		assert_equal(base_res.dup.merge({ verify: true }), res)
		res = Command_Line.parse %W{-v}
		assert_equal(base_res.dup.merge({ verify: true }), res)

		res = Command_Line.parse %W{-d -e vim testdir}
		assert_equal(base_res.dup.merge({ dry: true, editor: 'vim', dir: 'testdir'}), res)
		res = Command_Line.parse %W{-d testdir -e vim}
		assert_equal(base_res.dup.merge({ dry: true, editor: 'vim', dir: 'testdir'}), res)

	end

end
end
