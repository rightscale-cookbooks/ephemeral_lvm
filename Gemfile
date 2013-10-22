source 'https://rubygems.org'

# Berkshelf had some issues with latest version of Celluloid
# which required latest version of ridley which was causing problems.
# So locking ridley to '~> 1.5.0' here makes things work
#
gem 'ridley', '~> 1.5.0'
gem 'berkshelf'
gem 'thor-foodcritic'
gem 'thor-scmversion'

group :integration do
  gem 'test-kitchen', '~> 1.0.0.beta.3'
  gem 'kitchen-vagrant'
end

group :test do
  gem 'chefspec', '~> 1.3'
  gem 'strainer', '~> 3.0'
end
