require 'test_helper'

module MassRenamer
class Version_Test < Minitest::Test

  def test_that_it_has_a_version_number
    refute_nil ::MassRenamer::VERSION
  end

end
end
