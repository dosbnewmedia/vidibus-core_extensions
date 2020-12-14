# encoding: utf-8
require "spec_helper"

describe "String" do
  describe "::LATIN_MAP" do
    it "should contain a Hash map" do
      expect(String::LATIN_MAP).to be_a(Hash)
    end
  end

  describe "#latinize" do
    it "should convert diacritics" do
      expect("ÀÁÂÃÄÅ Ç Ð ÈÉÊË ÌÍÎÏ Ñ ÒÓÔÕÖØ ÙÚÛÜ Ý àáâãäå ç èéêë ìíîï ñ òóôõöø ùúûü ý".latinize)
        .to eq("AAAAAEA C D EEEE IIII N OOOOOEO UUUUE Y aaaaaea c eeee iiii n oooooeo uuuue y")
    end

    it "should convert ligatures" do
      expect("Æ".latinize).to eql("AE")
      expect("ÆǼ æǽ Œ œ".latinize).to eq("AEAE aeae OE oe")
    end

    it "should keep some regular chars" do
      expect(".,|?!:;\"'=+-_".latinize).to eql(".,|?!:;\"'=+-_")
    end

    it "should replace exotic chars by whitespace" do
      expect("~÷≥≤˛`ˀð".latinize).to eql(" ")
    end

    it "should normalize white space" do
      expect("Hola señor, ¿cómo está?".latinize).to eql("Hola senor, como esta?")
    end
  end

  describe "#permalink" do
    it "should call #latinize" do
      string = "hey"
      allow(string).to receive(:latinize) { string }
      expect(string.permalink).to eql(string)
    end

    it "should return lower chars only" do
      expect("HeLlo".permalink).to eql("hello")
    end

    it "should turn whitespace into dashes" do
      expect("hey joe".permalink).to eql("hey-joe")
    end

    it "should turn special chars into dashes" do
      expect("hi~there".permalink).to eql("hi-there")
    end

    it "should not begin with dashes" do
      expect(">duh".permalink).to eql("duh")
    end

    it "should not end with dashes" do
      expect("hi!".permalink).to eql("hi")
    end

    it "should convert multiple adjacent special chars into a single dash" do
      expect("Hola señor, ¿cómo está?".permalink).to eql("hola-senor-como-esta")
    end
  end

  describe "#%" do
    it "should allow reqular printf behaviour" do
      string = "%s, %s" % ["Masao", "Mutoh"]
      expect(string).to eql("Masao, Mutoh")
    end

    it "should accept named arguments" do
      string = "%{firstname}, %{familyname}" % {:firstname => "Masao", :familyname => "Mutoh"}
      expect(string).to eql("Masao, Mutoh")
    end
  end

  describe "#snip" do
    it "should truncate string to given length while preserving words" do
      expect("O Brother, Where Art Thou?".snip(13)).to eql("O Brother, Where…")
    end

    it "should return whole string if it fits in given length" do
      expect("O Brother, Where Art Thou?".snip(100)).to eql("O Brother, Where Art Thou?")
    end

    it "should return whole string if it equals length" do
      expect("O Brother, Where Art Thou?".snip(26)).to eql("O Brother, Where Art Thou?")
    end

    it "should strip white space between words" do
      expect("O Brother,       Where Art Thou?".snip(11)).to eql("O Brother,…")
    end

    it "should strip trailing white space" do
      expect("O Brother, Where Art Thou? ".snip(26)).to eql("O Brother, Where Art Thou?")
    end

    it "should strip leading white space" do
      expect(" O Brother, Where Art Thou?".snip(26)).to eql("O Brother, Where Art Thou?")
    end

    it "should handle content with backets" do
      expect("O Brother (Or Sister), Where Art Thou?".snip(20)).to eql("O Brother (Or Sister…")
    end
  end

  describe "#strip_tags" do
    it "should remove all tags from string" do
      expect("<p>Think<br />different</p>".strip_tags).to eql("Thinkdifferent")
    end

    it "should even remove chars that aren't tags but look like ones" do
      expect("small < large > small".strip_tags).to eql("small  small")
    end
  end

  describe "#strip_tags!" do
    it "should strip tags on self" do
      string = "<p>Think<br />different</p>"
      string.strip_tags!
      expect(string).to eql("Thinkdifferent")
    end
  end

  describe "#with_params" do
    it "should return the current string unless params are given" do
      expect("http://vidibus.org".with_params).to eql("http://vidibus.org")
    end

    it "should return the current string if an empty hash is given" do
      expect("http://vidibus.org".with_params({})).to eql("http://vidibus.org")
    end

    it "should return the current string with params as query" do
      expect("http://vidibus.org".with_params(:awesome => "yes")).to eql("http://vidibus.org?awesome=yes")
    end

    it "should append params to existing query" do
      expect("http://vidibus.org?opensource=true".with_params(:awesome => "yes")).to eql("http://vidibus.org?opensource=true&awesome=yes")
    end
  end

  describe '#sortable' do
    it 'should not convert a string that contains just downcase letters' do
      expect('hello'.sortable).to eq('hello')
    end

    it 'should convert a string that contains upcase letters' do
      expect('Hello'.sortable).to eq('hello')
    end

    it 'should strip whitespace' do
      expect('hel lo'.sortable).to eq('hello')
    end

    it 'should strip tabs' do
      expect('hel lo'.sortable).to eq('hello')
    end

    it 'should convert a string containing just a number' do
      expect('123'.sortable).to eq('00000000000000000000123.000000')
    end

    it 'should convert a string containing one float' do
      expect('1.23'.sortable).to eq('00000000000000000000001.230000')
    end

    it 'should convert a string containing one float with comma' do
      skip 'Use Rails\' number formatting for that?'
      expect('1,23'.sortable).to eq('00000000000000000000001.230000')
    end

    it 'should convert a string containing one number with comma as thousands separator' do
      skip 'Use Rails\' number formatting for that?'
      expect('1,234'.sortable).to eq('00000000000000000001234.000000')
    end

    it 'should convert a string containing one number with dot as thousands separator' do
      skip 'Use Rails\' number formatting for that?'
      expect('1.234'.sortable).to eq('00000000000000000001234.000000')
    end

    it 'should convert a string containing one number followed by a dot' do
      expect('1.'.sortable).to eq('00000000000000000000001.000000.')
    end

    it 'should convert a string containing one number at the beginning' do
      expect('123a'.sortable).to eq('00000000000000000000123.000000a')
    end

    it 'should convert a string containing one number in the middle' do
      expect('A 123 b'.sortable).to eq('a00000000000000000000123.000000b')
    end

    it 'should convert a string containing one number at the end' do
      expect('A 123 b'.sortable).to eq('a00000000000000000000123.000000b')
    end

    it 'should convert a string containing several numbers in the middle' do
      expect('A 123 b 4'.sortable).to eq('a00000000000000000000123.000000b00000000000000000000004.000000')
    end
  end
end
