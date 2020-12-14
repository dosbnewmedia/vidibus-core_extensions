require "spec_helper"

describe "Object" do
  describe "#try!" do
    let(:dog) do
      Struct.new("Dog", :out) unless defined?(Struct::Dog)
      Struct::Dog.new(true)
    end

    it "should return defined method" do
      expect(dog.try!(:out)).to be_truthy
    end

    it "should return nil when calling undefined method" do
      expect(dog.try!(:food)).to be_nil
    end

    it "should re-raise exceptions" do
      allow(dog).to receive(:bark).and_raise("wuff")
      expect {
        dog.try!(:bark)
      }.to raise_exception("wuff")
    end
  end
end
