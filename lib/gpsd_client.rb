require "gpsd_client/version"

require "socket"
require "json"

module GpsdClient

  class Gpsd
    attr_reader :host, :port

    @started = false

    def initialize(options = {})
        @host = options[:host] ||= 'localhost'
        @port = options[:port] ||= 2947
    end

    def start
        if not @started
            begin
                @socket = TCPSocket.new(@host, @port)
                @socket.puts 'w+'
                line = JSON.parse @socket.gets rescue ''
                if line.is_a? Hash and line['class'] == 'VERSION'
                  #@socket.puts '?WATCH={"enable":true,"json":true}' # disabled reporting, instead we are polling
                  @socket.puts '?WATCH={"enable":true};'
                  @started = true
                end

            rescue Exception => ex
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
        reads = 0
        empty_hash =  {lat: nil, lon: nil, time: nil, speed: nil, altitude: nil }
        return empty_hash if not self.started?
        
        while reads < 10 do # Skip VERSION SKY WATCH or DEVICES response
            line = ""
            begin
                @socket.puts '?WATCH={"enable":true};'
                sleep 0.1
                @socket.puts "?POLL;"
                line = @socket.gets
            rescue Exception => ex
                puts "Error while reading Socket: #{ex.message}"
            end
        
            # Parse line, return empty string on fail
            # if parsed, extract ptv Hash from the JSON report polled
            line = JSON.parse(line) rescue ''
            if line.is_a? Hash and line['tpv'].is_a? Array
              #puts "debug >> #{line.to_json.to_s}"
              line = line['tpv'][0]
            end

            if line.is_a? Hash and line['class'] == 'TPV'
                # http://www.catb.org/gpsd/client-howto.html
                # mode 1 means no valid data
                # return "Lat: #{line['lat'].to_s}, Lon: #{line['lon'].to_s}" unless line['mode'] == 1
                return {lat: line['lat'], lon: line['lon'], time: line['time'], speed: line['speed'], altitude: line['alt']} unless line['mode'] == 1
            end
            
            reads = reads + 1
        
        end
        #puts "debug >> TPV not found polling on GPSd"
        return empty_hash
    end
    
    private
    
    def not_started_msg( method = 'Gpsd' )
        puts "#{method}: No socket connection started"
        return nil
    end
    
  end
end
