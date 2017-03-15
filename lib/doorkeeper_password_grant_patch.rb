module DoorkeeperPasswordGrantPatch
  def request
    resource_owner
    super
  end
end
class Doorkeeper::Request::Password
  def self.new(*args, &block)
    super.extend DoorkeeperPasswordGrantPatch
  end
end