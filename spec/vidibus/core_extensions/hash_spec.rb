# encoding: utf-8
require "spec_helper"

describe "Hash" do
  describe "#to_query" do
    it "should join params with '&'" do
      hash = {:some => "value", :another => "thing"}
      parts = hash.to_query.split("&")
      expect(parts.sort).to eql(['another=thing', 'some=value'])
    end

    it "should return items as urlencoded string" do
      hash = {:another => "speciál"}
      expect(hash.to_query).to eql("another=speci%C3%A1l")
    end

    it "should support multi-level hashes" do
      hash = {:some => {:nested => :thing}}
      expect(hash.to_query).to eql("some%5Bnested%5D=thing")
    end

    it "should support a namespace" do
      hash = {:nested => :thing}
      expect(hash.to_query(:some)).to eql("some%5Bnested%5D=thing")
    end
  end

  describe "#only" do
    it "should return a copy of self but including only the given keys" do
      hash = {:name => "rodrigo", :age => 21}
      expect(hash.only(:name)).to eql({:name => "rodrigo"})
    end

    it "should work with array as parameter" do
      hash = {:name => "rodrigo", :age => 21}
      expect(hash.only([:name, :something])).to eql({:name => "rodrigo"})
    end

    it "should work for nested hash" do
      hash = {:name => "rodrigo", :girlfriends => ["Anna", "Maria"]}
      expect(hash.only(:name, :girlfriends)).to eql({:name => "rodrigo", :girlfriends => ["Anna", "Maria"]})
    end
  end

  describe "#except" do
    it "should return a copy of self but including only the given keys" do
      hash = {:name => "rodrigo", :age => 21}
      expect(hash.except(:name)).to eql({:age => 21})
    end

    it "should work with array as parameter" do
      hash = {:name => "rodrigo", :age => 21}
      expect(hash.except([:name, :something])).to eql({:age => 21})
    end

    it "should work for nested hash" do
      hash = {:name => "rodrigo", :girlfriends => ["Anna", "Maria"]}
      expect(hash.except(:name)).to eql({:girlfriends => ["Anna", "Maria"]})
    end
  end

  describe "#to_a_rec" do
    it "should return an array" do
      hash = {:some => "thing"}
      expect(hash.to_a_rec).to eql([[:some, "thing"]])
    end

    it "should return an array from nested hashes" do
      hash = {:some => {:nested => {:is => ["really", "groovy"]}}}
      expect(hash.to_a_rec).to eql([[:some, [[:nested, [[:is, ["really", "groovy"]]]]]]])
    end

    it "should return an array from hashes within arrays" do
      hash = {:some => [:nested, {:is => ["really", "groovy"]}]}
      expect(hash.to_a_rec).to eql([[:some, [:nested, [[:is, ["really", "groovy"]]]]]])
    end
  end

  describe "#keys?" do
    let(:hash) { {:some => "say", :any => "thing"} }

    it "should return true if all keys are given in hash" do
      expect(hash.keys?(:some, :any)).to be_truthy
    end

    it "should return true if all keys are given in larger hash" do
      expect(hash.keys?(:any)).to be_truthy
    end

    it "should return false if any of the given key misses in hash" do
      expect(hash.keys?(:any, :thing)).to be_falsey
    end
  end

  describe ".build" do
    it "should return a hash" do
      expect(Hash.build).to eql(Hash.new)
    end

    it "should accept a hash" do
      expect(Hash.build({:do => :it})).to eql({:do => :it})
    end

    it "should accept an array" do
      expect(Hash.build([:do, :it])).to eql({:do => :it})
    end

    it "should accept an array and flatten it once" do
      expect(Hash.build([:do, [:it]])).to eql({:do => :it})
    end

    it "should not accept a multi-level array" do
      expect {Hash.build([:do, [:it, [:now]]])}.to raise_error(ArgumentError, "odd number of arguments for Hash")
    end
  end
end
