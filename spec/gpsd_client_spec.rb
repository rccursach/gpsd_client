require 'spec_helper'

gpsd = GpsdClient::Gpsd.new()

describe GpsdClient do
  it 'connects to GPSd socket' do
    expect(gpsd.start()).to eq(true)
  end

  it 'gets my position' do
    pos = gpsd.started? ? gpsd.get_position : nil
    puts "Position : #{pos.nil? ? 'nil' : pos.to_s}"
    if pos.is_a? Hash
      if pos[:lat].nil? then puts "Still waiting a fix from GPS." end
    end
    expect(pos).to be_a Hash
  end
end

gpsd.stop()

