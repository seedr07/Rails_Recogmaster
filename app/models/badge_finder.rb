class BadgeFinder
  attr_accessor :company

  def self.find(company, name)
    new(company).find(name)
  end

  def initialize(company)
    @company = company
  end

  def find(name)
    badges.detect do |b|
      b.short_name.match(/#{name}/i)
    end
  end

  def badges
    company.company_badges
  end
  private
end