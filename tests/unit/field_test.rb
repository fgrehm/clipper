require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class FieldTest < Test::Unit::TestCase

  def setup
    @people = Wheels::Orm::Mappings::Mapping.new(Class.new, "people")
    @addresses = Wheels::Orm::Mappings::Mapping.new(Class.new, "addresses")
  end

  def test_has_a_name_and_type
    field = Wheels::Orm::Mappings::Field.new(@people, "name", String)
    assert_equal("name", field.name)
    assert_equal(Wheels::Orm::Types::String, field.type)
  end

  def test_only_accepts_defined_types
    assert_nothing_raised do
      Wheels::Orm::Mappings::Field.new(@people, "name", String)
    end

    assert_nothing_raised do
      Wheels::Orm::Mappings::Field.new(@people, "name", String)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Field.new(@people, "name", nil)
    end
  end

  def test_must_have_a_valid_name
    assert_nothing_raised do
      Wheels::Orm::Mappings::Field.new(@people, "name", String)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Field.new(@people, "    ", String)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Field.new(@people, nil ,String)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Field.new(@people, :name, String)
    end

    assert_raise(ArgumentError) do
      Wheels::Orm::Mappings::Field.new(@people, Object.new, String)
    end
  end

  def test_fields_from_different_mappings_are_not_equal
    people_id = @people.field("id", Integer)
    addresses_id = @addresses.field("id", Integer)

    assert_not_equal(people_id, addresses_id)
  end

  def test_field_generates_an_accessor_on_target
    zoos = Wheels::Orm::Mappings::Mapping.new(Class.new, "zoos")
    zoos.field("name", String)
    zoo = zoos.target.new
    assert_respond_to(zoo, :name)
    assert_respond_to(zoo, :name=)
  end

end