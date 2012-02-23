require "rubygems"
require "thread"
require "librato/metrics"

require File.join(File.dirname(__FILE__), 'patches', 'float')

module Recognizer
  class Librato
    def initialize(thread_queue, options)
      unless thread_queue && options.is_a?(Hash)
        raise "You must provide a thread queue and options"
      end
      unless options[:librato][:email] && options[:librato][:api_key]
        raise "You must provide a Librato Metrics account email and API key"
      end
      ::Librato::Metrics.authenticate(options[:librato][:email], options[:librato][:api_key])
      librato = ::Librato::Metrics::Queue.new
      mutex = Mutex.new
      Thread.abort_on_exception = true
      Thread.new do
        loop do
          sleep(options[:librato][:flush_interval] || 10)
          unless librato.queued.empty?
            puts "Attempting to flush metrics to Librato"
            mutex.synchronize do
              librato.submit
            end
            puts "Successfully flushed metrics to Librato"
          end
        end
      end
      set_source = case options[:librato][:source]
      when String
        if options[:librato][:source].match("^/.*/$")
          Proc.new do
            source = "recognizer"
            metric.match(options[:librato][:source].delete("/")) do |matched|
              source = matched
              metric.gsub!("#{source}.", "")
            end
          end
        else
          Proc.new do
            source = options[:librato][:source]
          end
        end
      when Integer
        Proc.new do
          source = metric.split(".").slice(options[:librato][:source])
          metric.gsub!("#{source}.", "")
        end
      else
        Proc.new do
          source = "recognizer"
        end
      end
      Thread.new do
        loop do
          graphite_formated = thread_queue.pop
          begin
            metric, value, timestamp = graphite_formated.split(" ").inject([]) do |result, part|
              result << (result.empty? ? part.to_sym : Float(part).pretty)
              result
            end
            set_source.call
            mutex.synchronize do
              puts "Adding metric to queue: #{graphite_formated}"
              librato.add(metric => {:value => value, :measure_time => timestamp, :source => source})
            end
          rescue ArgumentError
            puts "Invalid metric: #{graphite_formated}"
          end
        end
      end
    end
  end
end
