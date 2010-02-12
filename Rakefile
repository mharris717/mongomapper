require 'rubygems'
require 'rake'
require 'jeweler'
require 'yard'
require 'yard/rake/yardoc_task'

Jeweler::Tasks.new do |gem|
  gem.name        = "mongo_mapper"
  gem.summary     = %Q{Awesome gem for modeling your domain and storing it in mongo}
  gem.email       = "nunemaker@gmail.com"
  gem.homepage    = "http://github.com/jnunemaker/mongomapper"
  gem.authors     = ["John Nunemaker"]
  
  gem.add_dependency('activesupport', '>= 2.3')
  gem.add_dependency('mongo', '0.18.3')
  gem.add_dependency('jnunemaker-validatable', '1.8.1')
  
  gem.add_development_dependency('jnunemaker-matchy', '0.4.0')
  gem.add_development_dependency('shoulda', '2.10.2')
  gem.add_development_dependency('timecop', '0.3.4')
  gem.add_development_dependency('mocha', '0.9.8')
end

Jeweler::GemcutterTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.ruby_opts << '-rubygems'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

namespace :test do
  Rake::TestTask.new(:units) do |test|
    test.libs << 'test'
    test.ruby_opts << '-rubygems'
    test.pattern = 'test/unit/**/test_*.rb'
    test.verbose = true
  end
  
  Rake::TestTask.new(:functionals) do |test|
    test.libs << 'test'
    test.ruby_opts << '-rubygems'
    test.pattern = 'test/functional/**/test_*.rb'
    test.verbose = true
  end
end

task :default  => :test
task :test     => :check_dependencies

YARD::Rake::YardocTask.new(:doc) do |t|
  t.options = ["--legacy"] if RUBY_VERSION < "1.9.0"
end

def ec(cmd)
  #puts cmd
  res = `#{cmd}`
  puts res
  res
end

class String
  def lpad(n)
    return self if length >= n
    pad = " " * (n - length)
    pad + self
  end
  def rpad(n)
    return self if length >= n
    pad = " " * (n - length)
    self + pad
  end
end

class Numeric
  def lpad(n)
    to_s.lpad(n)
  end
  def rpad(n)
    to_s.rpad(n)
  end
end
  
require 'mharris_ext'
class TestFileResult
  attr_accessor :tests, :assertions, :failures, :errors, :file
  include FromHash
  def initialize(ops)
    from_hash(ops)
    from_hash(result_hash)
  end
  fattr(:str) do
    ec("rake test TEST=#{file}")
  end
  fattr(:result_hash) do
    raise "no match #{str}" unless str =~ /(\d+) test.* (\d+) asserti.* (\d+) failur.* (\d+) error/
    {:tests => $1.to_i, :assertions => $2.to_i, :failures => $3.to_i, :errors => $4.to_i}
  end
  def basename
    File.basename(file)
  end
  def errors_and_failures
    errors + failures
  end
  def passed?
    errors_and_failures == 0
  end
  def to_s
    "#{file.rpad(50)} failures #{failures.lpad(2)} errors #{errors.lpad(2)}"
  end
end

class Object
  def present?
    to_s.strip != ''
  end
  def nil_unless_present
    present? ? self : nil
  end
end

module Enumerable
  def map_yield_arr_each_time(pr)
    res = []
    each_with_index do |x,i|
      res << yield(x)
      pr[res] unless i == size-1
    end
    res
  end
end

class TestResults
  fattr(:been_run) { false }
  fattr(:files) { Dir["test/**/test_*.rb"] }
  def current_file
    res = File.open("current_test_file.txt") { |f| f.read }.strip.nil_unless_present
  end
  def broken_files
    file_results.reject { |x| x.passed? }.map { |x| x.file }
  end
  def files_to_use
    if current_file
      files.select { |x| x =~ /#{current_file}/ }
    else
      been_run ? broken_files : files
    end
  end
  fattr(:file_results_hash) { {} }
  def latest_file_results
    files_to_use.map_yield_arr_each_time(lambda { |arr| print_results(arr) }) { |f| TestFileResult.new(:file => f) }
  end
  fattr(:file_results) do
    latest_file_results.each { |r| file_results_hash[r.file] = r }
    file_results_hash.values.sort_by { |x| x.errors_and_failures }
  end
  def all_passed?
    file_results.all? { |x| x.passed? }
  end
  def print_results(arr)
    arr.sort_by { |x| x.errors_and_failures }.each { |x| puts x.to_s }
  end
  def run_loop!
    loop do
      file_results!.each { |x| puts x.to_s }
      self.been_run = !all_passed? || current_file
    end
  end
end

task :each_unit do
  # results = Dir["test/unit/*.rb"].map { |f| TestResults.new(:file => f) }
  #   results.sort_by { |x| x.errors_and_failures }.each { |x| puts x.to_s }
  TestResults.new.run_loop!
end
