require "gpsd_client/version"

require "socket"
require "json"

module GpsdClient
  
  if ! ::IO.const_defined?(:EAGAINWaitReadable)
    class ::IO::EAGAINWaitReadable; end
  end

  class Gpsd
    attr_reader :host, :port

    @started = false

    def initialize(options = {})
        @host = options[:host] ||= '127.0.0.1'
        @port = options[:port] ||= 2947
    end

    def start
        if not @started
            begin
                @socket = TCPSocket.new(@host, @port)
                @socket.puts 'w+'
                line = JSON.parse @socket.gets rescue ''
                if line.is_a? Hash and line['class'] == 'VERSION'
                  @socket.puts '?WATCH={"enable":true};'
                  @started = true
                  flush_socket
                end

            rescue => ex
                puts 'Some error happen starting socket connection:'
                puts ex.message
                self.stop
            end
        end
        return @started
    end

    def started?
        @started
    end

    def stop
        return not_started_msg("Gpsd.stop") if not self.started?
        @socket.puts '?WATCH={"enable":false};'
        @socket.close unless @socket.closed?
        @started = false if @socket.closed?
        !self.started?
    end

    def get_position
        empty_hash =  {lat: nil, lon: nil, time: nil, speed: nil, altitude: nil }
        return empty_hash if not self.started?
        begin
            @socket.puts "?POLL;"
            retries = 0
            until retries == 10 do
                begin
                    lines = @socket.read_nonblock(4096).split("\r\n")
                rescue IO::WaitReadable, IO::EAGAINWaitReadable
                    retries += 1
                    sleep 0.1*retries
                end
            end
        rescue => ex
            puts "Error while reading Socket: #{ex.message}"
        end

        # Parse line, return empty string on fail
        # if parsed, extract ptv Hash from the JSON report polled
        lines.each do |line|
            line = JSON.parse(line) rescue ''
            if line.is_a? Hash and line['tpv'].is_a? Array
              #puts "debug >> #{line.to_json.to_s}"
              line = line['tpv'][0]
            end

            if line.is_a? Hash and line['class'] == 'TPV'
                # http://www.catb.org/gpsd/client-howto.html
                # mode 1 means no valid data
                # return "Lat: #{line['lat'].to_s}, Lon: #{line['lon'].to_s}" unless line['mode'] == 1
                flush_socket
                return {lat: line['lat'], lon: line['lon'], time: line['time'], speed: line['speed'], altitude: line['alt']} unless line['mode'] == 1
            end
            #puts "debug >> TPV not found polling on GPSd"
        end
        return empty_hash
    end

    private

    def not_started_msg( method = 'Gpsd' )
        puts "#{method}: No socket connection started"
        return nil
    end

    # Reads from socket until no more data is returned, the read data will be thrown away.
    # Params:
    # +socket+:: the socket to read from
    def flush_socket
        begin
            loop do
                @socket.read_nonblock(1024)
            end
        rescue IO::WaitReadable, IO::EAGAINWaitReadable
            true
        end
    end
  end
end
