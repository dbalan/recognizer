# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "recognizer/version"

Gem::Specification.new do |s|
  s.name        = "recognizer"
  s.version     = Recognizer::VERSION
  s.authors     = ["Sean Porter"]
  s.email       = ["portertech@gmail.com"]
  s.homepage    = "https://github.com/portertech/recognizer"
  s.summary     = "A Graphite Carbon AMQP impostor, sending metrics to Librato Metrics."
  s.description = "A Graphite Carbon AMQP impostor, sending metrics to Librato Metrics."

  s.rubyforge_project = "recognizer"

  s.files         = Dir.glob("{bin,lib}/**/*") + %w[recognizer.gemspec README.org MIT-LICENSE.txt]
  s.executables   = Dir.glob("bin/**/*").map { |file| File.basename(file) }
  s.require_paths = ["lib"]

  s.add_dependency("json")
  s.add_dependency("mixlib-cli", ">= 1.1.0")
  s.add_dependency("bunny", "0.7.9")
  s.add_dependency("librato-metrics", "0.4.2")
end
