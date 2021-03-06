require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"

class FieldTest < Test::Unit::TestCase

  def setup
    @mappings = Clipper::Mappings.new
    @people = Clipper::Mappings::Mapping.new(@mappings, Class.new, "people")
    @addresses = Clipper::Mappings::Mapping.new(@mappings, Class.new, "addresses")
    @string_type = Clipper::Types::String.new(255)
  end

  def test_has_a_name_and_type
    field = Clipper::Mappings::Field.new(@people, "name", @string_type)
    assert_equal("name", field.name)
    assert_kind_of(Clipper::Types::String, field.type)
  end

  def test_only_accepts_defined_types
    assert_nothing_raised do
      Clipper::Mappings::Field.new(@people, "name", @string_type)
    end

    assert_nothing_raised do
      Clipper::Mappings::Field.new(@people, "name", @string_type)
    end

    assert_raise(ArgumentError) do
      Clipper::Mappings::Field.new(@people, "name", nil)
    end
  end

  def test_must_have_a_valid_name
    assert_nothing_raised do
      Clipper::Mappings::Field.new(@people, "name", @string_type)
    end

    assert_raise(ArgumentError) do
      Clipper::Mappings::Field.new(@people, "    ", @string_type)
    end

    assert_raise(ArgumentError) do
      Clipper::Mappings::Field.new(@people, nil, @string_type)
    end

    assert_raise(ArgumentError) do
      Clipper::Mappings::Field.new(@people, :name, @string_type)
    end

    assert_raise(ArgumentError) do
      Clipper::Mappings::Field.new(@people, Object.new, @string_type)
    end
  end

  def test_fields_from_different_mappings_are_not_equal
    people_id = @people.field("id", Clipper::Types::Integer.new)
    addresses_id = @addresses.field("id", Clipper::Types::Integer.new)

    assert_not_equal(people_id, addresses_id)
  end

  def test_field_generates_an_accessor_on_target
    zoos = Clipper::Mappings::Mapping.new(@mappings, Class.new, "zoos")
    zoos.field("name", Clipper::Types::String.new(200))
    zoo = zoos.target.new
    assert_respond_to(zoo, :name)
    assert_respond_to(zoo, :name=)
  end

  def test_field_get_raises_on_different_type_object
    zoos = Clipper::Mappings::Mapping.new(@mappings, Class.new, "zoos")
    name = zoos.field("name", @string_type)

    assert_raise(ArgumentError) { name.get(Class.new.new) }
  end

  def test_field_get_returns_instance_value
    zoos = Clipper::Mappings::Mapping.new(@mappings, Class.new, "zoos")
    name = zoos.field("name", @string_type)
    zoo = zoos.target.new

    zoo.name = "Dallas"
    assert_equal("Dallas", name.get(zoo))
  end

  def test_field_set_sets_instance_value
    zoos = Clipper::Mappings::Mapping.new(@mappings, Class.new, "zoos")
    name = zoos.field("name", @string_type)
    zoo = zoos.target.new

    name.set(zoo, "Dallas")
    assert_equal("Dallas", zoo.name)
  end

  def test_field_returns_scalar_default_value
    default_value = "Dallas"
    zoos = Clipper::Mappings::Mapping.new(@mappings, Class.new, "zoos")
    name = zoos.field("name", @string_type, default_value)

    zoo = zoos.target.new
    assert_equal("Dallas", zoo.name)

    zoo = zoos.target.new
    assert_equal("Dallas", name.get(zoo))
  end

  def test_field_returns_default_value_from_lambda
    default_value = lambda { "Dallas" }
    zoos = Clipper::Mappings::Mapping.new(@mappings, Class.new, "zoos")
    name = zoos.field("name", @string_type, default_value)
    objid = zoos.field("objid", Clipper::Types::Integer, lambda { |instance| instance.object_id } )

    zoo = zoos.target.new
    assert_equal("Dallas", zoo.name)
    assert_equal(zoo.object_id, zoo.objid)

    zoo = zoos.target.new
    assert_equal("Dallas", name.get(zoo))
    assert_equal(zoo.object_id, objid.get(zoo))
  end

end