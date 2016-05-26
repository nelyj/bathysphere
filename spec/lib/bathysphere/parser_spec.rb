require 'spec_helper'

module Bathysphere
  describe Parser do

    let(:file) { 'spec/fixtures/fruit.yml' }
    let(:parser) { Parser.new(file) }

    it { expect(parser).to respond_to :fetch }

    describe '#fetch' do

      context 'when built from a valid YAML file' do

        context 'with deeply nested properties' do

          let(:file) { 'spec/fixtures/fruit.yml' }

          context 'when the property is available' do

            it 'returns its value' do
              expect(parser.fetch(:display_name, :large, :purple)).to eq 'Eggplant'
            end
          end

          context 'when the property is not available' do

            it 'raises KeyError and mentions the parsed file in the message' do
              expect{ parser.fetch(:weight, :large, :purple) }.to raise_error KeyError, Regexp.new(file)
            end
          end

          context 'when a property of the path is not available' do

            it 'raises KeyError and mentions the parsed file in the message' do
              expect{ parser.fetch(:weight, :tiny, :purple) }.to raise_error KeyError, Regexp.new(file)
            end
          end
        end

        context 'with deeply nested values but no :key' do

          let(:file) { 'spec/fixtures/deeply_nested_with_no_key.yml' }

          it 'treats the nested hash as the property value' do
            expect{ parser.fetch(:display_name, :large) }.not_to raise_error
            expect(parser.fetch(:display_name, :large)).to eq({ 'large' => 'kangaroo', 'medium' => 'wombat', 'small' => 'possum' })
          end
        end

        context 'with deeply nested properties, a :key but no :values' do

          let(:file) { 'spec/fixtures/deeply_nested_with_a_key_but_no_values.yml' }

          it 'raises KeyError and mentions the parsed file in the message' do
            expect{ parser.fetch(:display_name, :large) }.to raise_error KeyError, Regexp.new(file)
          end
        end

        context 'with no deeply nested properties' do

          let(:file) { 'spec/fixtures/simple.yml' }

          context 'when the property is available' do

            it 'returns its value (as Hash#fetch does)' do
              expect(parser.fetch(:display_name)).to eq 'Mountain'
            end
          end

          context 'when the property is not available' do

            it 'raises KeyError and mentions the parsed file in the message' do
              expect{ parser.fetch(:weight) }.to raise_error KeyError, Regexp.new(file)
            end
          end
        end
      end
    end
  end
end
