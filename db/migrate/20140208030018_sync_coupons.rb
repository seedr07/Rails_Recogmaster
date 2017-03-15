class SyncCoupons < ActiveRecord::Migration
  def up
    Coupon.sync_with_stripe! rescue nil
  end

  def down
  end
end
