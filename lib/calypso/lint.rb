require 'thor'
require_relative 'consts'

module Calypso

  class Lint < Thor

    desc 'check', 'Check code style violations'
    def check(dir = nil)
      dirs = dir ? [dir] : PROJECT_DIRS
      dirs.each do |d|
        puts "swiftlint lint --config #{LINT_CFG} --path #{d} 2> /dev/null"
        system "swiftlint lint --config #{LINT_CFG} --path #{d} 2> /dev/null"
      end
    end

    desc 'fix', 'Automatically fix possible code style violations'
    def fix(dir = nil)
      dirs = dir ? [dir] : PROJECT_DIRS
      dirs.each do |d|
        system "swiftlint autocorrect --config #{LINT_CFG} --path #{d} > /dev/null"
      end
    end

  end

end
