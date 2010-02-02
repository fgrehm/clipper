require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname.parent + "sample_models"

class Integration::EntityTest < Test::Unit::TestCase
  include Clipper::Session::Helper
  include Integration::SampleModels

  def setup
    Clipper::open("default", "jdbc:hsqldb:mem:test")
    load Pathname(__FILE__).dirname.parent + "sample_models_mapping.rb"

    @relation = Clipper::Query::Arel::Entity.new(orm.repository.mappings[Zoo])
  end

  def teardown
    Clipper::close("default")
  end

  def test_requires_a_mapping
    assert_raise ArgumentError do
      Clipper::Query::Arel::Entity.new(Class.new.new)
    end
  end

  def test_getting_field
    assert_instance_of ::Arel::Attribute, @relation[:id]
  end

  def test_respond_to_sql
    assert @relation.respond_to?(:to_sql)
  end

  def test_respond_to_where
    assert @relation.respond_to?(:where)
  end
end