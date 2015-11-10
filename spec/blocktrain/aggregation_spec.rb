module Blocktrain
  describe Aggregation do

    it 'queries a group of signals' do
      subject = described_class.new(from: '2015-09-01 10:00:00Z', to: '2015-09-01 11:00:00Z', interval: '10m', signal: 'passenger_load')

      expect(subject.address_query).to eq('memoryAddress:2E64930W OR memoryAddress:2E64932W OR memoryAddress:2E64934W OR memoryAddress:2E64936W')
    end

    it 'queries a single signal' do
      subject = described_class.new(from: '2015-09-01 10:00:00Z', to: '2015-09-01 11:00:00Z', interval: '10m', signal: 'train_speed')

      expect(subject.address_query).to eq('memoryAddress:2E491EEW')
    end

    context 'with a subsignal specified' do

      it 'queries a subsignal' do
        subject = described_class.new(from: '2015-09-01 10:00:00Z', to: '2015-09-01 11:00:00Z', interval: '10m', signal: 'passenger_load', sub_signal: 'A')
        expect(subject.address_query).to eq('memoryAddress:2E64930W')
      end

      it 'queries a single signal' do
        subject = described_class.new(from: '2015-09-01 10:00:00Z', to: '2015-09-01 11:00:00Z', interval: '10m', signal: 'train_speed', sub_signal: 'bawbag')
        expect(subject.address_query).to eq('memoryAddress:2E491EEW')
      end

    end

  end
end
