require 'test_helper'

class TestLint < Test::Unit::TestCase
  def model
    Doc().new.to_model
  end
  include ActiveModel::Lint::Tests
end