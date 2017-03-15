# NOTE: changes here may affect RecognitionRecipientSerializer
class RecognitionSerializer < ActiveModel::Serializer
  include DateTimeHelper

  attributes :slug, :url, :html_link, :date, :badge, :sender, :points, :recipients, :reference_recipient, 
                    :sender_name, :sender_email, :reference_recipient_email, :reference_recipient_name,
                   :reference_recipient_teams, :message, :skills, :timestamp, :recognized_team

  def html_link
    ActionController::Base.helpers.link_to(recognition.slug, url, target: "_blank")
  end

  def url
    Rails.application.routes.url_helpers.recognition_url(recognition, host: Recognize::Application.config.host)
  end

  def timestamp
    recognition.created_at.to_f
  end

  def recognition
    object
  end

  def badge
    recognition.badge.short_name
  end

  def points
    reference_activity.present? ? reference_activity.amount : recognition.earned_points
  end

  def sender
    "#{recognition.sender.full_name} - #{recognition.sender.email}"
  end

  def sender_email
    recognition.sender.email
  end

  def sender_name
    recognition.sender.full_name
  end

  def recipients
    recognition.flattened_recipients.map{|r| recipient_name(r) }.join(", ")
  end

  def reference_activity
    recognition.reference_activity
  end

  def reference_recipient
    recipient_name(recognition.reference_recipient) if recognition.reference_recipient
  end

  def reference_recipient_name
    recognition.reference_recipient.full_name if reference_recipient
  end

  def reference_recipient_email
    recognition.reference_recipient.email if reference_recipient
  end

  def reference_recipient_teams
    recognition.reference_recipient.teams.map(&:name).join(", ") if reference_recipient
  end

  def date
    localize_datetime(recognition.created_at, :friendly_with_time)
  end

  def skills
    recognition.skills_as_tags
  end

  def recognized_team
    reference_activity.team_id.present? ? Team.with_deleted.find(reference_activity.team_id).name : "" if reference_activity
  end

  private
  def recipient_name(recipient)
    "#{recipient.full_name} - #{recipient.email}"
  end
end
