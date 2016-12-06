require 'rspec/core/rake_task'
require 'foodcritic'
require 'kitchen'

cookbook=File.foreach('metadata.rb').grep(/^name/).first.strip.split(' ').last.gsub(/'/,'')
directory=File.expand_path(File.dirname(__FILE__))

desc "Sets up knife, and vendors cookbooks"
task :setup_test_environment do
  File.open('knife.rb','w+') do |file|
    file.write <<-EOF
      log_level                :debug
      log_location             STDOUT
      cookbook_path            ['.', 'berks-cookbooks/' ]
    EOF
  end
  sh('berks vendor')
end

desc "verifies version and changelog"
task :verify_version do
  def get_old_version
    f=`git show master:metadata.rb`
    f.each_line do |line|
      if line.match(/version/)
        k,v=line.strip.split
        @old_version=v
      end
    end
    return @old_version
  end

  def get_new_version
    f=File.read('metadata.rb')
    f.each_line do |line|
      if line.match(/version/)
        k,v=line.strip.split
        @new_version = v
      end
    end
    return @new_version
  end

  if `git rev-parse --abbrev-ref HEAD`.strip != 'master'
    puts "Verifying Metdata Version"
    if get_old_version == get_new_version
      raise "You need to increment version before test will pass"
    end

    puts "Verifying Changelog"
    counter=0
    f=File.read('CHANGELOG.md')
    f.each_line do |line|
      if line.match get_new_version.tr('\'','')
        counter+=1
      end
    end
    if counter == 0
      raise "CHANGELOG update needed"
    end
  end
end

desc "runs knife cookbook test"
task :knife => [ :setup_test_environment ] do
  cmd = "bundle exec knife cookbook test #{cookbook} -c knife.rb"
  puts cmd
  sh(cmd)
end

desc "runs foodcritic"
task :foodcritic do
  cmd = "bundle exec foodcritic --epic-fail any --tags ~FC009 --tags ~FC064 --tags ~FC065 #{directory}"
  puts cmd
  sh(cmd)
end

desc "runs foodcritic linttask"
task :fc_new do
FoodCritic::Rake::LintTask.new(:chef) do |t|
  t.options = {
    fail_tags: ['any']
  }
end
end

desc "runs rspec"
task :rspec do
  cmd = "bundle exec rspec --color --format documentation"
  puts cmd
  sh(cmd)
end

desc "runs testkitchen"
task :kitchen do
  cmd = "bundle exec kitchen test --concurrency=2"
  puts cmd
  sh(cmd)
end

desc "runs all tests except kitchen"
task :except_kitchen => [ :verify_version, :knife, :foodcritic, :rspec ] do
  puts "running all tests except kitchen"
end

desc "runs all tests"
task :default => [ :except_kitchen, :kitchen ] do
  puts "running all tests"
end
