require 'spec_helper'
require 'json'
gpsd = GpsdClient::Gpsd.new()

describe GpsdClient do
  it 'connects to GPSd socket' do
    expect(gpsd.start()).to eq(true)
  end

  it 'gets my position' do
    pos = gpsd.get_position
    puts pos.to_json.to_s
    expect(pos).to be_a Hash
  end

  it 'closes conection' do
    expect(gpsd.stop()).to eq(true)
  end
end

#gpsd.stop()

