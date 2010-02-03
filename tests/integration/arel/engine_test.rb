require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname.parent + "sample_models"

class Integration::EngineTest < Test::Unit::TestCase
  include Clipper::Session::Helper
  include Integration::SampleModels

  def setup
    repository = Clipper::open("default", "jdbc:hsqldb:mem:test")
    @engine = Clipper::Query::Arel::Engine.new(repository)
  end

  def teardown
    Clipper::close("default")
  end

  def test_requires_repository_instance
    assert_raise ArgumentError do
      Clipper::Query::Arel::Engine.new(Class.new.new)
    end
  end

  def test_implements_arel_required_methods
    assert @engine.respond_to?(:adapter_name)
    assert @engine.respond_to?(:quote_table_name)
    assert @engine.respond_to?(:quote_column_name)
    assert @engine.respond_to?(:quote)
  end
end