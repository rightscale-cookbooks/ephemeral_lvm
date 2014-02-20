require_relative '../libraries/helper'
require 'logger'

describe EphemeralLvm::Helper do
  describe "#fix_device_mapping" do
    it "returns the devices as is when there is no need for mapping" do
      expect(
        EphemeralLvm::Helper.fix_device_mapping(["/dev/sda", "/dev/sdb"], ["sda", "sdb"])
      ).to eq(["/dev/sda", "/dev/sdb"])
    end

    it "maps the devices correctly" do
      expect(
        EphemeralLvm::Helper.fix_device_mapping(["/dev/sda", "/dev/sdb"], ["xvda", "xvdb"])
      ).to eq(["/dev/xvda", "/dev/xvdb"])
    end

    it "returns the original device unmapped if the device is found" do
      expect(
        EphemeralLvm::Helper.fix_device_mapping(["/dev/sda", "/dev/sdb"], ["xvda", "sdb"])
      ).to eq(["/dev/xvda", "/dev/sdb"])
    end

    it "skips the devices that cannot be mapped" do
      stub_const("Chef::Log", Logger.new('/dev/null'))
      Chef::Log.should_receive(:warn).with("could not find ephemeral device: /dev/sdb").and_return("could not find ephemeral device: /dev/sdb")
     
      expect(
        EphemeralLvm::Helper.fix_device_mapping(["/dev/sda", "/dev/sdb"], ["xvda"])
      ).to eq(["/dev/xvda"])
    end

    it 'map devices with a numeric suffix' do
      expect(
        EphemeralLvm::Helper.fix_device_mapping(['/dev/sda2'], ['xvda2'])
      ).to eq(['/dev/xvda2'])
    end
  end
end
