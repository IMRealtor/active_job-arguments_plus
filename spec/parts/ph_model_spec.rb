require 'ph_model'
require 'spec_helper'

class SomeModel
  include PhModel

  attribute :foo
  attribute :bar
end

describe PhModel do
  let(:serialized) { [{ "_aj_ph_model" => { "type" => "SomeModel", "data" => { "foo" => "One", "bar" => 3 } } }] }

  let(:deserialized) { [SomeModel.build(foo: "One", bar: 3)] }

  it "serializes" do
    expect(ActiveJob::Arguments.serialize(deserialized)).to eq(serialized)
  end

  it "deserializes" do
    expect(ActiveJob::Arguments.deserialize(serialized)).to eq(deserialized)
  end
end
