require "spec_helper"

describe "Vidibus::CoreExtensions::Hash" do
  describe "#to_uri" do
    it "should join params with '&'" do
      hash = { :some => "value", :another => "thing" }
      hash.to_uri.should eql("some=value&another=thing")
    end
    
    it "should return items as urlencoded string" do
      hash = { :another => "speciál" }
      hash.to_uri.should eql("another=speci%C3%A1l")
    end
    
    it "should support multi-level hashes" do
      hash = { :some => { :nested => :thing } }
      hash.to_uri.should eql("some=[nested=thing]")
    end
  end
  
  describe "#only" do
    it "should return a copy of self but including only the given keys" do
      hash = { :name => "rodrigo", :age => 21 }
      hash.only(:name).should eql({ :name => "rodrigo" })
    end
    
    it "should work with array as parameter" do
      hash = { :name => "rodrigo", :age => 21 }
      hash.only([:name, :something]).should eql({ :name => "rodrigo" })
    end
    
    it "should work for nested hash" do
      hash = { :name => "rodrigo", :girlfriends => ["Anna", "Maria"] }
      hash.only(:name, :girlfriends).should eql({ :name => "rodrigo", :girlfriends => ["Anna", "Maria"] })
    end
  end
  
  describe "#except" do
    it "should return a copy of self but including only the given keys" do
      hash = { :name => "rodrigo", :age => 21 }
      hash.except(:name).should eql({ :age => 21 })
    end
    
    it "should work with array as parameter" do
      hash = { :name => "rodrigo", :age => 21 }
      hash.except([:name, :something]).should eql({ :age => 21 })
    end
    
    it "should work for nested hash" do
      hash = { :name => "rodrigo", :girlfriends => ["Anna", "Maria"] }
      hash.except(:name).should eql({ :girlfriends => ["Anna", "Maria"] })
    end
  end
end