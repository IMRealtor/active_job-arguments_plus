require 'spec_helper'

describe Time do
  let(:serialized) { [{"_aj_time" => 1519328467}] }

  let(:deserialized) { [Time.at(1519328467)] }

  it "serializes" do
    expect(ActiveJob::Arguments.serialize(deserialized)).to eq(serialized)
  end

  it "deserializes" do
    expect(ActiveJob::Arguments.deserialize(serialized).first).to be_a(Time)
  end
end
