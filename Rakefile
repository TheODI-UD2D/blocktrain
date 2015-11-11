require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'blocktrain'

require 'github_changelog_generator'
require 'erb'
require 'git'
require 'semver'

class GemPublisher
  def initialize
    @version = SemVer.parse(Blocktrain::VERSION)
    @g = Git.open('.')
  end

  def publish
    create_tag
    create_changelog
    bump_version
    push
  end

  def create_tag
    @g.add_tag(@version.to_s)
    @g.push('origin', 'master', tags: true)
  end

  def create_changelog
    ARGV[0] = "TheODI-UD2D"
    ARGV[1] = "blocktrain"
    GitHubChangelogGenerator::ChangelogGenerator.new.run
    @g.add 'CHANGELOG.md'
    @g.commit 'Update changelog'
  end

  def push
    @g.push('origin', 'master')
  end

  def bump_version
    @version.patch += 1
    @new_version = @version.format("%M.%m.%p%s%d")
    template = File.read('version.rb.erb')
    renderer = ERB.new(template)
    version_file = File.open File.join('lib', 'blocktrain', 'version.rb'), 'w'
    version_file.write renderer.result(binding)
    @g.add File.join('lib', 'blocktrain', 'version.rb')
    @g.commit 'Bump version'
  end
end

RSpec::Core::RakeTask.new

task :default => [:spec]

desc 'Write changelog, tag & release gem, bump version'
task :publish do
  GemPublisher.new.publish
end
