# frozen_string_literal: true
require_relative 'spec_helper'
require_relative '../libraries/helper'
require 'logger'

describe EphemeralLvm::Helper do
  describe '#fix_device_mapping' do
    it 'returns the devices as is when there is no need for mapping' do
      expect(
        EphemeralLvm::Helper.fix_device_mapping(['/dev/sda', '/dev/sdb'], %w(sda sdb))
      ).to eq(['/dev/sda', '/dev/sdb'])
    end

    it 'maps the devices correctly' do
      expect(
        EphemeralLvm::Helper.fix_device_mapping(['/dev/sda', '/dev/sdb'], %w(xvda xvdb))
      ).to eq(['/dev/xvda', '/dev/xvdb'])
    end

    it 'returns the original device unmapped if the device is found' do
      expect(
        EphemeralLvm::Helper.fix_device_mapping(['/dev/sda', '/dev/sdb'], %w(xvda sdb))
      ).to eq(['/dev/xvda', '/dev/sdb'])
    end

    it 'skips the devices that cannot be mapped' do
      stub_const('Chef::Log', Logger.new('/dev/null'))
      allow(Chef::Log).to receive(:warn).with('could not find ephemeral device: /dev/sdb').and_return([])

      expect(
        EphemeralLvm::Helper.fix_device_mapping(['/dev/sda', '/dev/sdb'], ['xvda'])
      ).to eq(['/dev/xvda'])
    end

    it 'map devices with a numeric suffix' do
      expect(
        EphemeralLvm::Helper.fix_device_mapping(['/dev/sda2'], ['xvda2'])
      ).to eq(['/dev/xvda2'])
    end
  end
end
