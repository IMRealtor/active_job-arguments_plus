require 'spec_helper'

module SomeModule
end

module OtherModule
end

describe Module do
  let(:serialized) { [{ "_aj_module" => "SomeModule" }, { "_aj_module" => "OtherModule" }] }

  let(:deserialized) { [SomeModule, OtherModule] }

  it "serializes" do
    expect(ActiveJob::Arguments.serialize(deserialized)).to eq(serialized)
  end

  it "deserializes" do
    expect(ActiveJob::Arguments.deserialize(serialized)).to eq(deserialized)
  end
end
