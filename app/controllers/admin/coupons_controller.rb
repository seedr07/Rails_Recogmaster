class Admin::CouponsController < Admin::BaseController

  def index
    @coupons = case params[:show]
    when "deleted"
      Coupon.only_deleted.order("id desc")
    when "expired"
      Coupon.scoped.order("id desc")
    when "all"
      Coupon.with_deleted.order("id desc")
    else
      Coupon.order("id desc").select{|c| c.valid_for_use?}
    end
  end

  def edit
    @coupon = Coupon.find(params[:id])
  end
  
  def update
    @coupon = Coupon.find(params[:id])
    @coupon.update_attributes!(params[:coupon])
    respond_with @coupon, location: admin_coupons_path
  end

  def sync
    Coupon.sync_with_stripe!
    respond_with Coupon.first, location: admin_coupons_path
  end
end