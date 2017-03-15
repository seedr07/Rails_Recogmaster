module BadgeHelper
  def with_sandboxed_badges    
    Badge.delete_all("company_id IS NOT NULL")
    yield
    Badge.delete_all("company_id IS NOT NULL")
  end
end