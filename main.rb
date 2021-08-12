require 'socket'
require 'json'
require 'uri'
require 'net/http'
require 'thwait'

Thread.abort_on_exception = true

class JsonFromUrl
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def call
    begin
      uri = URI(url)
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue StandardError => e
      []
    end
  end
end

TWITTER_URL = "https://takehome.io/twitter"
FACEBOOK_URL = "https://takehome.io/facebook"
INSTA_URL = "https://takehome.io/instagram"

server = TCPServer.new 3000

while session = server.accept
  session.print "HTTP/1.1 200\r\n"
  session.print "Content-Type: application/json\r\n"
  session.print "\r\n"

  threads = []

  threads << Thread.new(session) { |session| session.print "{ twitter: #{JsonFromUrl.new(TWITTER_URL).call}"}
  threads << Thread.new(session) { |session| session.print "{ facebook: #{JsonFromUrl.new(FACEBOOK_URL).call}"}
  threads << Thread.new(session) { |session| session.print "{ instagram: #{JsonFromUrl.new(INSTA_URL).call}"}

  session.print "{"
  ThreadsWait.all_waits(*threads)
  session.print "}"

  session.close
end
