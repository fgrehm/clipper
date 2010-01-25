require "pathname"
require Pathname(__FILE__).dirname.parent + "helper"
require Pathname(__FILE__).dirname + "sample_models"

class Integration::SessionTest < Test::Unit::TestCase

  include Clipper::Session::Helper
  include Integration::SampleModels

  def setup
    @model = Class.new do
      include Clipper::Model

      constrain("default")
    end

    Clipper::open("default", "jdbc:hsqldb:mem:test")
    load Pathname(__FILE__).dirname + "sample_models_mapping.rb"

    @schema = Clipper::Schema.new("default")
    @schema.create(City)
  end

  def teardown
    @schema.destroy(City)
    Clipper::close("default")
  end

  def test_map_returns_mapping
    session = Clipper::Session.new("default")

    assert_nothing_raised do
      session.map(@model, "people")
    end
  end

  def test_map_adds_mapping_to_mappings
    session = Clipper::Session.new("default")

    mapping = nil

    assert_nothing_raised do
      mapping = session.map(@model, "people")
    end

    assert_equal(mapping, session.mappings[@model])
  end

  def test_validate
    session = Clipper::Session.new("default")

    assert_nothing_raised do
      result = session.validate(@model.new)
      assert(result.is_a?(Clipper::Validations::ValidationResult))
    end
  end

  def test_map_type_adds_signature_to_repository_type_map
    session = Clipper::Session.new("default")
    datetime = string = nil
    session.map_type do |signature, types|
      signature.from [(datetime = types.date_time)]
      signature.to [(string = types.string)]
      signature.typecast_left lambda { }
      signature.typecast_right lambda { }
    end

    assert_nothing_raised do
      session.repository.class.type_map.match([datetime], [string])
    end
  end

  def test_session_save_should_return_session
    city = City.new('Dallas')
    assert_kind_of(Clipper::Session, orm.save(city))
  end

  def test_session_save_should_update_existing_data
    # Save a new instance
    city = City.new('Dallas')
    orm.save(city)

    # Get the newly saved instance, update it
    city = orm.get(City, city.id)
    city.name = "Frisco"
    orm.save(city)

    # Get the updated instance, test to make sure the update happened
    city = orm.get(City, city.id)
    assert_equal("Frisco", city.name)
  end

  def test_items_retrieved_by_get_should_be_stored
    city = City.new('Dallas')
    orm.save(city)

    assert(orm.stored?(orm.get(City, city.id)))
  end

  def test_items_retrieved_by_all_should_be_stored
    city = City.new('Dallas')
    orm.save(city)

    assert(orm.stored?(orm.all(City).first))
  end

  def test_items_retrieved_by_find_should_be_stored
    city = City.new('Dallas')
    orm.save(city)

    dallas_city = Clipper::Query::Condition.eq(orm.mappings[City][:name], "Dallas")

    assert(orm.stored?(orm.find(City, nil, dallas_city).first))
  end
end