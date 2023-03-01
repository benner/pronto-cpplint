# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'rspec'
require 'pronto/cpplint'

Dir.glob("#{Dir.pwd}/spec/support/**/*.rb").each { |file| require file }

# Cross-platform way of finding an executable in the $PATH.
#
#   which('ruby') #=> /usr/bin/ruby
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  nil
end

raise 'Please `pip install cpplint` or ensure cpplint is in your PATH' if which('cpplint').nil?

RSpec.configure do |c|
  c.include RepositoryHelper
end
