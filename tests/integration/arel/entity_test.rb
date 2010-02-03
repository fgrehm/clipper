require "pathname"
require Pathname(__FILE__).dirname.parent.parent + "helper"
require Pathname(__FILE__).dirname.parent + "sample_models"

class Integration::EntityTest < Test::Unit::TestCase
  include Clipper::Session::Helper
  include Integration::SampleModels

  def setup
    Clipper::open("default", "jdbc:hsqldb:mem:test")
    load Pathname(__FILE__).dirname.parent + "sample_models_mapping.rb"

    Arel::Table.engine = Clipper::Query::Arel::Engine.new(orm.repository)
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

  def test_helper
    helper = Clipper::Query::Arel::Helper.new(@relation)

    assert_instance_of ::Arel::Attribute, helper.id
    assert_equal @relation[:id], helper.id
  end

  def test_where
    expected = "SELECT     \"zoos\".\"id\", \"zoos\".\"name\" FROM       \"zoos\""
    assert_equal expected, @relation.to_sql

    expected = "SELECT     \"zoos\".\"id\", \"zoos\".\"name\" FROM       \"zoos\" WHERE     \"zoos\".\"name\" = 'zoo name'"
    query = @relation.where(@relation[:name].eq('zoo name'))
    assert_equal expected, query.to_sql

    expected = "SELECT     \"zoos\".\"id\", \"zoos\".\"name\" FROM       \"zoos\" WHERE     \"zoos\".\"id\" = 1"
    query = @relation.where(@relation[:id].eq(1))
    assert_equal expected, query.to_sql

    expected = "SELECT     \"zoos\".\"id\", \"zoos\".\"name\" FROM       \"zoos\" WHERE     \"zoos\".\"id\" = \"zoos\".\"name\""
    query = @relation.where(@relation[:id].eq(@relation[:name]))
    assert_equal expected, query.to_sql
  end

  def test_reusing_relation
    expected = "SELECT     \"zoos\".\"id\", \"zoos\".\"name\" FROM       \"zoos\" WHERE     \"zoos\".\"name\" = 'zoo name' AND \"zoos\".\"id\" = 1 LIMIT     5 OFFSET    10"

    relation = @relation.where(@relation[:name].eq('zoo name'))
    relation = relation.where(relation[:id].eq(1))
    relation = relation.skip(10)
    relation = relation.take(5)

    assert_equal expected, relation.to_sql
  end
end