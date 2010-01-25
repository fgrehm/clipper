require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class SyntaxTest < Test::Unit::TestCase

  def setup
    Clipper::open("default", "abstract://localhost/example")
    repository = Clipper::registrations["default"] 
    @syntax = Clipper::Syntax::Sql.new(repository)
    
    orm = Clipper::Session::Helper.orm('default')

    @zoos = orm.map(Class.new { include Clipper::Model }, 'zoos') do |zoos, type|
      zoos.property :id, Integer, type.serial
      zoos.property :city_id, Integer, type.integer

      zoos.key :id
    end

    @cities = orm.map(Class.new { include Clipper::Model }, 'cities') do |cities, type|
      cities.property :id, Integer, type.serial

      cities.key :id
    end
  end

  def test_basic_serializations
    assert_equal('"zoos"."id" = ?', @syntax.serialize([:eq, @zoos[:id], 1]))
    assert_equal('"zoos"."id" < ?', @syntax.serialize([:lt, @zoos[:id], 1]))
    assert_equal('"zoos"."id" > ?', @syntax.serialize([:gt, @zoos[:id], 1]))
  end

  def test_serializations_with_mappings
    assert_equal('"zoos"."city_id" = "cities"."id"', @syntax.serialize([:eq, @zoos[:city_id], @cities[:id]]))
  end

end