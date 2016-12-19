require 'rspec/core/rake_task'
require 'foodcritic'
require 'kitchen'

directory = File.expand_path(File.dirname(__FILE__))

desc 'Sets up knife, and vendors cookbooks'
task :setup_test_environment do
  File.open('knife.rb', 'w+') do |file|
    file.write <<-EOF
      log_level                :debug
      log_location             STDOUT
      cookbook_path            ['.', 'berks-cookbooks/' ]
    EOF
  end
  sh('berks vendor')
end

desc 'verifies version and changelog'
task :verify_version do
  def get_old_version
    f = `git show master:metadata.rb`
    f.each_line do |line|
      if line =~ /^version/
        _k, v = line.strip.split
        @old_version = v
      end
    end
    @old_version
  end

  def get_new_version
    f = File.read('metadata.rb')
    f.each_line do |line|
      if line =~ /^version/
        _k, v = line.strip.split
        @new_version = v
      end
    end
    @new_version
  end

  if `git rev-parse --abbrev-ref HEAD`.strip != 'master'
    old_version = get_old_version.tr('\'', '')
    new_version = get_new_version.tr('\'', '')
    puts "Verifying Metdata Version - Old:#{old_version}, New:#{new_version}"
    if get_old_version == get_new_version
      raise 'You need to increment version before test will pass'
    end

    puts "Verifying Changelog Contains Version #{new_version}"
    counter = 0
    f = File.read('CHANGELOG.md')
    f.each_line do |line|
      counter += 1 if line.match new_version
    end
    raise 'CHANGELOG update needed' if counter == 0
  end
end

desc 'runs cookstyle'
task cookstyle: [:setup_test_environment] do
  cmd = 'chef exec cookstyle -D --format offenses --display-cop-names'
  puts cmd
  sh(cmd)
end

desc 'runs foodcritic'
task :foodcritic do
  cmd = "chef exec foodcritic --epic-fail any #{directory}"
  puts cmd
  sh(cmd)
end

desc 'runs foodcritic linttask'
task :fc_new do
  FoodCritic::Rake::LintTask.new(:chef) do |t|
    t.options = {
      fail_tags: ['any']
    }
  end
end

desc 'runs rspec'
task :rspec do
  cmd = 'chef exec rspec --color --format documentation'
  puts cmd
  sh(cmd)
end

desc 'runs testkitchen'
task :kitchen do
  cmd = 'chef exec kitchen test --concurrency=2'
  puts cmd
  sh(cmd)
end

desc 'runs all tests except kitchen'
task except_kitchen: [:verify_version, :cookstyle, :foodcritic, :rspec] do
  puts 'running all tests except kitchen'
end

desc 'runs all tests'
task all: [:except_kitchen, :kitchen] do
  puts 'running all tests'
end
