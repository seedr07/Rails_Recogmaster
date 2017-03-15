class FilesController < ApplicationController
  def firefox_extension
    send_file File.join(Rails.root, "/public/recognize.xpi"), 
      type: "application/x-xpinstall", disposition: :inline
  end
end