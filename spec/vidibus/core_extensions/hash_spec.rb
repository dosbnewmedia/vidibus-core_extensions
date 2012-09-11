# encoding: utf-8
require "spec_helper"

describe "Hash" do
  describe "#to_query" do
    it "should join params with '&'" do
      hash = {:some => "value", :another => "thing"}
      parts = hash.to_query.split("&")
      parts.sort.should eql(['another=thing', 'some=value'])
    end

    it "should return items as urlencoded string" do
      hash = {:another => "speciál"}
      hash.to_query.should eql("another=speci%C3%A1l")
    end

    it "should support multi-level hashes" do
      hash = {:some => {:nested => :thing}}
      hash.to_query.should eql("some%5Bnested%5D=thing")
    end

    it "should support a namespace" do
      hash = {:nested => :thing}
      hash.to_query(:some).should eql("some%5Bnested%5D=thing")
    end
  end

  describe "#only" do
    it "should return a copy of self but including only the given keys" do
      hash = {:name => "rodrigo", :age => 21}
      hash.only(:name).should eql({:name => "rodrigo"})
    end

    it "should work with array as parameter" do
      hash = {:name => "rodrigo", :age => 21}
      hash.only([:name, :something]).should eql({:name => "rodrigo"})
    end

    it "should work for nested hash" do
      hash = {:name => "rodrigo", :girlfriends => ["Anna", "Maria"]}
      hash.only(:name, :girlfriends).should eql({:name => "rodrigo", :girlfriends => ["Anna", "Maria"]})
    end
  end

  describe "#except" do
    it "should return a copy of self but including only the given keys" do
      hash = {:name => "rodrigo", :age => 21}
      hash.except(:name).should eql({:age => 21})
    end

    it "should work with array as parameter" do
      hash = {:name => "rodrigo", :age => 21}
      hash.except([:name, :something]).should eql({:age => 21})
    end

    it "should work for nested hash" do
      hash = {:name => "rodrigo", :girlfriends => ["Anna", "Maria"]}
      hash.except(:name).should eql({:girlfriends => ["Anna", "Maria"]})
    end
  end

  describe "#to_a_rec" do
    it "should return an array" do
      hash = {:some => "thing"}
      hash.to_a_rec.should eql([[:some, "thing"]])
    end

    it "should return an array from nested hashes" do
      hash = {:some => {:nested => {:is => ["really", "groovy"]}}}
      hash.to_a_rec.should eql([[:some, [[:nested, [[:is, ["really", "groovy"]]]]]]])
    end

    it "should return an array from hashes within arrays" do
      hash = {:some => [:nested, {:is => ["really", "groovy"]}]}
      hash.to_a_rec.should eql([[:some, [:nested, [[:is, ["really", "groovy"]]]]]])
    end
  end

  describe "#keys?" do
    let(:hash) { {:some => "say", :any => "thing"} }

    it "should return true if all keys are given in hash" do
      hash.keys?(:some, :any).should be_true
    end

    it "should return true if all keys are given in larger hash" do
      hash.keys?(:any).should be_true
    end

    it "should return false if any of the given key misses in hash" do
      hash.keys?(:any, :thing).should be_false
    end
  end

  describe ".build" do
    it "should return a hash" do
      Hash.build.should eql(Hash.new)
    end

    it "should accept a hash" do
      Hash.build({:do => :it}).should eql({:do => :it})
    end

    it "should accept an array" do
      Hash.build([:do, :it]).should eql({:do => :it})
    end

    it "should accept an array and flatten it once" do
      Hash.build([:do, [:it]]).should eql({:do => :it})
    end

    it "should not accept a multi-level array" do
      expect {Hash.build([:do, [:it, [:now]]])}.to raise_error(ArgumentError, "odd number of arguments for Hash")
    end
  end
end
