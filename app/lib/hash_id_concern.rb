module HashIdConcern
  def recognize_hashid
    self.id.present? ? Recognize::Application.hasher.encode(self.id) : nil
  end
end