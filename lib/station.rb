class Station
  attr_reader :location, :id

  def initialize(attributes)
    @location = attributes['location']
    @id = attributes['id'].to_i
  end

  def save
    result = DB.exec("INSERT INTO stations (location) VALUES ('#{@location}')RETURNING id;")
    @id = result.first['id'].to_i
  end

  def ==(another_station)
    self.location == another_station.location && self.id == another_station.id
  end

  def create_stop(line_id)
    DB.exec("INSERT INTO stops (station_id, line_id) VALUES (#{self.id}, #{line_id});")
  end

  def self.lines_serving_station(station_id)
    line_objects = DB.exec("SELECT * FROM stops WHERE station_id = #{station_id};")
    lines_serving = []
    lines_ids_array = []
    line_objects.each do |object|
      lines_ids_array << object['line_id'].to_i
      results = DB.exec("SELECT * FROM lines WHERE id IN('#{lines_ids_array.join(',')}');")
      results.each do |result|
        lines_serving << Line.create(result)
      end
    end
    lines_serving
  end

  def self.create(attributes)
    new_location = Station.new(attributes)
    new_location.save
    new_location
  end

  def self.all
    results = DB.exec("SELECT * FROM stations;")
    stations = []
    results.each do |result|
      stations << Station.new(result)
    end
    stations
  end

  def self.update(station_id, new_location)
    DB.exec("UPDATE stations SET location = '#{new_location}' WHERE id = #{station_id};")
  end

  def self.delete(station_id)
    DB.exec("DELETE FROM stations WHERE id = #{station_id};")
  end
end

