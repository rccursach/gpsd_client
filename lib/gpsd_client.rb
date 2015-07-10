require "gpsd_client/version"

require "socket"
require "json"

module GpsdClient

  class Gpsd
    attr_reader :host, :port

    @started = false

    def initialize(options = {})
        @host ||= options[:host] ||= "localhost"
        @port = options[:port] ||= 2947
    end

    def start
        if not @started
            begin
                @socket = TCPSocket.new(@host, @port)
                @socket.puts("w+")
                line = @socket.gets
                # puts "debug >> #{line[0...20]}"
                @started = true if line.start_with? '{"class":"VERSION"'
            rescue
                @started = false
            end
        end
        return @started
    end
    
    def started?
        @started
    end
    
    def stop
        return not_started_msg("Gpsd.stop") if not self.started?
        @socket.puts('?WATCH={"enable":false}')
    end
    
    def get_position
        reads = 0
        
        return not_started_msg("Gpsd.get_position") if not self.started?
        
        while reads < 7 do # Skip VERSION SKY WATCH or DEVICES response
            line = ""
            begin
                @socket.puts('?WATCH={"enable":true,"json":true}')
                line = @socket.gets
                #puts "debug >> #{line[0...20]}"
            rescue
                puts "Error writing Socket"
            end
        
            #puts line
            if line.start_with? '{"class":"TPV"'
                line = JSON.parse(line)
                # http://www.catb.org/gpsd/client-howto.html
                # mode 1 means no valid data
                # return "Lat: #{line['lat'].to_s}, Lon: #{line['lon'].to_s}" unless line['mode'] == 1
                return {lat: line['lat'], lon: line['lon'], time: line['time'], speed: line['speed'], altitude: line['alt']} unless line['mode'] == 1
            end
            
            reads = reads + 1
        
        end
        return {lat: nil, lon: nil, time: nil, speed: nil, altitude: nil } unless line['mode'] == 1
    end
    
    private
    
    def not_started_msg( method = "Gpsd" )
        puts "#{method}: Socket connection wasn't started"
        return nil
    end
    
  end
end
