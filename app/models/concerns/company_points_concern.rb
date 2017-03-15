module CompanyPointsConcern
  extend ActiveSupport::Concern

  included do
    store :point_values, accessors: Report::User::DEFAULT_POINTS.keys, coder: JSON
    
    before_validation :initialize_point_values, :on => :create
    validates :point_values, presence: true

    Report::User::DEFAULT_POINTS.keys.each do |point_key|
      validates point_key, numericality: {only_integer: true, greater_than_or_equal_to: 0}
    end

    # Define accessors for each point value method
    # This method normalizes the output to integers
    # However, we need to account for the nil and alpha case("abc")
    # which when called .to_i on will return 0, which we don't want
    # Instead, we want to return the original value so we can have errors
    Report::User::DEFAULT_POINTS.keys.each do |accessor|
      define_method(accessor)  do
        value = super()

        if value != "0" && value.to_i == 0
          return value
        else
          return value.to_i
        end

      end
    end    
  end

  def initialize_point_values
    Report::User::DEFAULT_POINTS.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def update_point_values(params)
    params.each do |key, value|
      self.send("#{key}=", params[key])
    end
    result = self.save
    if result
      self.delay(queue: 'points').refresh_all_user_point_totals! 
    end
    
    return result
  end
      
end