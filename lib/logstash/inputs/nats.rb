# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname
# Generate a repeating message.
#
# This plugin is intented only as an example.

class LogStash::Inputs::Nats < LogStash::Inputs::Base
  config_name "nats"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "json"

  # The message string to use in the event.
  config :message, :validate => :hash, :required => true ,:default => "Here we go"

  # Set how frequently messages should be sent.
  #
  # The default, `1`, means send a message every second.
  config :interval, :validate => :number, :default => 1

  # Define the target field for placing the received data. If this setting is omitted, the data will be stored at the root (top level) of the event.
  config :target, :validate => :string

  public
  def register
    #s = TCPSocket.new 'localhost', 2000
    @host = Socket.gethostname.force_encoding(Encoding::UTF_8)
    @logger.info("Registering http_poller Input", :type => @type,
                 :urls => @urls, :interval => @interval, :timeout => @timeout)
    puts @host
  end # def register

  def run(queue)
    Stud.interval(@interval) do
      event = LogStash::Event.new("message" => @message, "host" => @host)
      decorate(event)
      queue << event
    end # loop
  end # def run

end # class LogStash::Inputs::Example
