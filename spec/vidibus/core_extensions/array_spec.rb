require 'ostruct'
require "spec_helper"

describe "Array" do
  describe "#flatten_once" do
    it "should return array" do
      array = ['go', 'for', 'it']
      expect(array.flatten_once).to eql(['go', 'for', 'it'])
    end

    it "should return a flattened array" do
      array = ['go', ['for', 'it']]
      expect(array.flatten_once).to eql(['go', 'for', 'it'])
    end

    it "should flatten first level only" do
      array = ['go', ['for', ['it']]]
      expect(array.flatten_once).to eql(['go', 'for', ['it']])
    end

    it "should accept array with mixed values" do
      array = ["go", [1,2], { :it => "dude" }]
      expect(array.flatten_once).to eql(["go", 1, 2, { :it => "dude" }])
    end
  end

  describe "#merge" do
    it "should merge [] with [1,2]" do
      expect([].merge([1,2])).to eql([1,2])
    end

    it "should merge [a] with [1,2]" do
      expect(['a'].merge([1,2])).to eql(['a',1,2])
    end

    it "should merge [1,'a'] with [1,2]" do
      expect([1,'a'].merge([1,2])).to eql([1,2,'a'])
    end

    it "should merge [1,'a'] with [3,1,2]" do
      expect([1,'a'].merge([3,1,2])).to eql([3,1,2,'a'])
    end

    it "should merge ['b',1,'a'] with [3,1,2]" do
      expect(['b',1,'a'].merge([3,1,2])).to eql(['b',3,1,2,'a'])
    end

    it "should merge [2,'b',1,'a'] with [3,1,2]" do
      expect([2,'b',1,'a'].merge([3,1,2])).to eql([2,'b',3,1,'a'])
    end

    it "should merge [2,'b',1,'a'] with [3,1,2,4]" do
      expect([2,'b',1,'a'].merge([3,1,2,4])).to eql([2,4,'b',3,1,'a'])
    end

    it "should merge [2,'b',1,'a'] with [5,3,6,7,1,2,4]" do
      expect([2,'b',1,'a'].merge([5,3,6,7,1,2,4])).to eql([2,4,'b',5,3,6,7,1,'a'])
    end

    context "with :strict option" do
      it "should merge [] with [1,2]" do
        array = [1,2]
        expect([].merge(array, :strict => true)).to eql([])
        expect(array).to eql([1,2])
      end

      it "should merge [1,'a'] with [3,1,2]" do
        array = [3,1,2]
        expect([1,'a'].merge(array, :strict => true)).to eql([3,1,2,'a'])
        expect(array).to be_empty
      end
    end
  end

  describe "#merge_nested" do
    it "should merge [[]] with [[1,2]]" do
      expect([[]].merge_nested([[1,2]])).to eql([[1,2]])
    end

    it "should merge [[]] with [[1],[2]]" do
      expect([[]].merge_nested([[1],[2]])).to eql([[1,2]])
    end

    it "should merge [[],[]] with [[1],[2]]" do
      expect([[],[]].merge_nested([[1],[2]])).to eql([[1],[2]])
    end

    it "should merge [[1],[]] with [[1],[2]]" do
      expect([[1],[]].merge_nested([[1],[2]])).to eql([[1],[2]])
    end

    it "should merge [[1],[2]] with [[1],[2]]" do
      expect([[1],[2]].merge_nested([[1],[2]])).to eql([[1],[2]])
    end

    it "should merge [[2],[1]] with [[1],[2]]" do
      expect([[2],[1]].merge_nested([[1],[2]])).to eql([[2],[1]])
    end

    it "should merge [[2]] with [[1],[2]]" do
      expect([[2]].merge_nested([[1],[2]])).to eql([[2,1]])
    end

    it "should merge [[2],[]] with [[1],[2]]" do
      expect([[2],[]].merge_nested([[1],[2]])).to eql([[2,1],[]])
    end

    it "should merge [[1,2,3]] with [[1,2],[3]]" do
      expect([[1,2,3]].merge_nested([[1,2],[3]])).to eql([[1,2,3]])
    end

    it "should merge [[1,2],[3]] with [[1],[2,3]]" do
      expect([[1,2],[3]].merge_nested([[1],[2,3]])).to eql([[1,2],[3]])
    end

    it "should keep source intact" do
      source = [[1,2]]
      [[1,2]].merge_nested(source)
      expect(source).to eql([[1,2]])
    end
  end

  describe "#flatten_with_boundaries" do
    it "should flatten [[1]]" do
      expect([[1]].flatten_with_boundaries).to eql(["__a0",1,"__a0"])
    end

    it "should flatten [[1],2,[3]]" do
      expect([[1],2,[3]].flatten_with_boundaries).to eql(["__a0",1,"__a0",2,"__a1",3,"__a1"])
    end

    it "should flatten [1,[2],3]" do
      expect([1,[2],3].flatten_with_boundaries).to eql([1,"__a0",2,"__a0",3])
    end

    it 'should flatten [1,[2],3,4,[["x"]]]' do
      expect([1,[2],3,4,[["x"]]].flatten_with_boundaries).to eql([1,"__a0",2,"__a0",3,4,"__a1",["x"],"__a1"])
    end

    it "should handle [1,2]" do
      expect([1,2].flatten_with_boundaries).to eql([1,2])
    end
  end

  describe "#convert_boundaries" do
    it 'should convert ["__a0",1,"__a0"]' do
      expect(["__a0",1,"__a0"].convert_boundaries).to eql([[1]])
    end

    it 'should convert ["__a0",1,"__a0",2,"__a1",3,"__a1"]' do
      expect(["__a0",1,"__a0",2,"__a1",3,"__a1"].convert_boundaries).to eql([[1],2,[3]])
    end

    it 'should convert [1,"__a0",2,"__a0",3]' do
      expect([1,"__a0",2,"__a0",3].convert_boundaries).to eql([1,[2],3])
    end

    it 'should convert [1,"__a0",2,"__a0",3,4,"__a1",["x"],"__a1"]' do
      expect([1,"__a0",2,"__a0",3,4,"__a1",["x"],"__a1"].convert_boundaries).to eql([1,[2],3,4,[["x"]]])
    end

    it "should convert [1,2]" do
      expect([1,2].convert_boundaries).to eql([1,2])
    end
  end

  describe "#sort_by_map" do
    it "should sort the list of hashes by given order of attribute values" do
      list = [{:n => "two"}, {:n => "one"}, {:n => "three"}]
      map = ["one", "two", "three"]
      expect(list.sort_by_map(map, :n)).to eql([{:n => "one"}, {:n => "two"}, {:n => "three"}])
    end

    it "should sort the list of objects by given order of attribute values" do
      list = []
      list << OpenStruct.new(:n => "two")
      list << OpenStruct.new(:n => "one")
      list << OpenStruct.new(:n => "three")
      map = ["one", "two", "three"]
      ordered = list.sort_by_map(map, :n)
      expect(ordered[0].n).to eql("one")
      expect(ordered[1].n).to eql("two")
      expect(ordered[2].n).to eql("three")
    end

    it "should sort the list of values by given order" do
      list = ["two", "one", "three"]
      map = ["one", "two", "three"]
      expect(list.sort_by_map(map)).to eql(["one", "two", "three"])
    end
  end

  describe "#delete_rec" do
    it "should remove a given item from self" do
      list = ["one", "two", ["one"]]
      expect(list.delete_rec("one")).to eql("one")
      expect(list).to eql(["two", []])
    end
  end
end
