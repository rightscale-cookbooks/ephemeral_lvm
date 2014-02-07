require 'chefspec'
require 'chefspec/berkshelf'

describe 'ephemeral_lvm::default' do
  let(:runner) { ChefSpec::Runner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'does not install xfsprogs by default' do
    expect(chef_run).to_not install_package('xfsprogs')
  end

  it 'installs xfsprogs when the filesystem is "xfs"' do
    runner.node.set['ephemeral_lvm']['filesystem'] = 'xfs'
    expect(chef_run).to install_package('xfsprogs')
  end
end
