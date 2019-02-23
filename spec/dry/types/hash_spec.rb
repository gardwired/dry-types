RSpec.describe Dry::Types::Hash do
  subject(:type) { Dry::Types['hash'] }

  it_behaves_like Dry::Types::Definition
  it_behaves_like 'Dry::Types::Definition#meta'

  describe '#call' do
    it 'accepts any hash input' do
      expect(type.({})).to eql({})
      expect(type.(name: 'Jane')).to eql(name: 'Jane')
    end
  end

  describe '#with_type_transform' do
    it 'adds a type transformation for schemas' do
      optional_keys = type.with_type_transform { |key| key.required(false) }
      schema = optional_keys.schema(name: "strict.string", age: "strict.integer")
      expect(schema.(name: 'Jane')).to eql(name: 'Jane')
    end

    it 'accepts a proc' do
      fn = -> t { t.meta(omittable: true) }
      expect(subject.with_type_transform(fn)). to eql(subject.with_type_transform(&fn))
    end

    it 'passes in key type with name available' do
      optional_age = type.with_type_transform { |key| key.name == :age ? key.required(false) : key }
      schema = optional_age.schema(name: "strict.string", age: "strict.integer")
      expect(schema.(name: 'Jane')).to eql(name: 'Jane')
    end
  end

  describe '#map' do
    it 'builds a map type' do
      map = type.map('strict.string', 'strict.integer')

      expect(map.('foo' => 1)).to eql('foo' => 1)

      expect { map.('foo' => '2') }.to raise_error(Dry::Types::MapError)
    end
  end
end
