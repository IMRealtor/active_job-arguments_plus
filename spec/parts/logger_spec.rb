require 'spec_helper'

describe Logger do
  let(:serialized) { [{ "_aj_logger" => true }] }

  let(:deserialized) { [Logger.new(STDOUT)] }

  it "serializes" do
    expect(ActiveJob::Arguments.serialize(deserialized)).to eq(serialized)
  end

  it "deserializes" do
    expect(ActiveJob::Arguments.deserialize(serialized).first).to be_a(Logger)
  end
end
