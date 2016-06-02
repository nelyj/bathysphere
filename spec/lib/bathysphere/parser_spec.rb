require 'spec_helper'

module Bathysphere
  describe Parser do

    let(:file) { 'spec/fixtures/fruit.yml' }
    let(:parser) { Parser.new(file) }

    it { expect(parser).to respond_to :fetch }
    it { expect(parser).to respond_to :using }

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

    describe '#using' do

      let(:refinements_store) { double }

      it 'is chainable' do
        expect(parser.using(refinements_store)).to be_instance_of Parser
      end
    end

    context 'when both the :size and :color refinements are required' do

      let(:file) { 'spec/fixtures/fruit.yml' }

      context 'and #using(refinements_store)' do

        let(:refinements_store) { double }
        let(:parser) { Parser.new(file).using(refinements_store) }

        context 'when the refinements_store implements the :size and :color readers' do

          before(:each) do
            allow(refinements_store).to receive(:size).and_return(:large)
            allow(refinements_store).to receive(:color).and_return(:purple)
          end

          describe '#fetch' do

            it 'returns the property value as expected with no need of custom refinements' do
              expect(parser.fetch(:display_name)).to eq('Eggplant')
            end

          end
        end
      end
    end
  end
end
