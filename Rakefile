require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "appraisal/task"

Appraisal::Task.new

KIND_BASIC_MODULE_GLOBS = [
  "test/kind/{basic/*_test,basic_test}.rb",
  "test/kind/enum_test.rb",
  "test/kind/presence_test.rb",
  "test/kind/dig_test.rb",
  "test/kind/try_test.rb",
  "test/kind/maybe_test.rb",
  "test/kind/immutable_attributes_test.rb",
  "test/kind/function_test.rb",
  "test/kind/action_test.rb",
  "test/kind/{functional/*_test,functional_test}.rb",
  "test/kind/either/*_test.rb",
  "test/kind/result/*_test.rb"
].freeze

def run_isolated_module(files, env: {})
  return if files.empty?

  loader = Gem.bin_path('rake', 'rake_test_loader.rb') rescue nil
  loader ||= File.join(Gem.loaded_specs['rake'].full_gem_path, 'lib/rake/rake_test_loader.rb')

  sh(env, FileUtils::RUBY, '-Ilib', '-Itest', loader, *files)
end

desc "Run each kind module in isolation (KIND_BASIC=t)"
task :test_basic_modules do
  KIND_BASIC_MODULE_GLOBS.each do |glob|
    run_isolated_module(Dir.glob(glob), env: { 'KIND_BASIC' => 't' })
  end

  run_isolated_module(Dir.glob('test/kind/strict_disabled_test.rb'), env: { 'KIND_STRICT' => 't' })
end

desc "Run the full test suite against every supported Rails version"
task :matrix do
  appraisals =
    if RUBY_VERSION < "3.1"
      %w[rails-6-0 rails-6-1 rails-7-0 rails-7-1]
    elsif RUBY_VERSION < "3.2"
      %w[rails-7-0 rails-7-1 rails-7-2]
    elsif RUBY_VERSION < "3.3"
      %w[rails-7-0 rails-7-1 rails-7-2 rails-8-0]
    elsif RUBY_VERSION < "3.4"
      %w[rails-7-0 rails-7-1 rails-7-2 rails-8-0 rails-8-1 rails-edge]
    elsif RUBY_VERSION < "4.0"
      %w[rails-7-2 rails-8-0 rails-8-1 rails-edge]
    else
      %w[rails-8-1 rails-edge]
    end

  # Default (no activemodel)
  sh "bundle exec rake test"

  # Per-module isolation runs
  Rake::Task[:test_basic_modules].invoke

  # Each activemodel appraisal
  appraisals.each do |appraisal|
    sh "bundle exec appraisal #{appraisal} rake test"
  end
end

task default: :test
