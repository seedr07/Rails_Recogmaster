# In order to generate a semi-realistic looking graph behavior
# we use a sine function to generate periodic behavior(ups and downs).  In order to avoid
# a graph that is too regular, we introduce randomness at two levels:
# The delta between steps across the x-axis is random, but within a range(deltavariance)
# The wavelength of the sine function is varied by randomly incrementing the index we pass
# to the sine function(sine_index)
class Grapherator
  attr_accessor :yvalue, :range, :deltavariance, :sine_index, :wavelength, :i, :maxi, :data, :trend,
                         :periodmin, :periodmax, :direction

  def initialize(num_datapoints=100, opts={})
    # CONFIGURATION VARIABLES
    self.yvalue = opts[:yvalue] || 1                     # start value
    self.range = opts[:range] || 100                  # y-range
    self.deltavariance = 10                                 # allowable variance between changes
    self.sine_index, self.wavelength = 0, 0.33 #index into our sine function that determines whether we change direction or not
    self.i, self.maxi = 0, num_datapoints                               # our counter and its maximum
    self.data = {sine_index => yvalue}              # seed our data structure with its first value
    self.trend = :positive                                     # :negative, :none # do we want the graph to trend upwards, downwards or neither
    self.periodmin, self.periodmax = 0, 0         # vars to enforce trending
    self.direction = 1                                           # start in a positive direction, -1 for negative
  end

  def generate!
   # DO NOT EDIT BELOW THIS LINE
    while(i < maxi)

      olddirection = direction
      direction = Math.sin(sine_index).to_f
      direction = direction < 0 ? direction.floor : direction.ceil

      delta = rand(deltavariance) 
      self.yvalue += delta * direction

      if trend == :positive 
        self.yvalue = periodmin if self.yvalue < periodmin
        periodmin = self.yvalue if olddirection < direction
      elsif trend == :negative
        self.yvalue = periodmax if self.yvalue > periodmax
        periodmax = self.yvalue if olddirection > direction

      end

      data[sine_index] = self.yvalue
      self.sine_index += Math.sin(rand) # Math.sin(rand) will give random numbers from -1..1
      self.i += 1
    end
    return data.values
  end

  def googlecharts_code
    code = <<-CODE
    function drawVisualization() {
      // Create and populate the data table.
      var data = google.visualization.arrayToDataTable([
        ['x', 'Cats'],
        DATASTR
      ]);

      // Create and draw the visualization.
      new google.visualization.LineChart(document.getElementById('visualization')).
          draw(data, {curveType: "function",
                      width: 500, height: 400,
                      vAxis: {maxValue: 10}}
              );
    }
    CODE

    datastr = data.collect{|k,v|  "[#{k},#{v}]"}.join(",")
    code = code.gsub('DATASTR', datastr)
    puts code
  end
end