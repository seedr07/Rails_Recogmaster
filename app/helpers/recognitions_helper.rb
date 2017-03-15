module RecognitionsHelper

  def cache_key_for_stream_page
    "#{recognitions_cache_key}-stream"
  end

  def cache_key_for_res
    "#{recognitions_cache_key}-res"
  end

  def recognitions_cache_key
    count = current_user.company.recognitions.size
    max_updated_at = current_user.company.recognitions.maximum(:created_at).try(:utc).try(:to_s, :number)
    "#{current_user.company.domain}-#{current_user.id}-recognitions/all-#{count}-#{max_updated_at}-#{params[:page]}-#{@per_page_count}"
  end

  def message_label(setting = :message_is_required?)
    current_user.company.send(setting) ? t("dict.message") : "#{t('dict.message')} (#{t('dict.optional')})"
  end

  def recipients_label(recognition, opts={})
    recognition.recipients.map do |recipient|
      if opts[:exclude_link] || recipient.deleted?
        recipient.label
      else
        link_to recipient.label, recipient
      end
    end.to_sentence.html_safe
  end

  def recipients_avatars(recognition)
    recognition.flattened_recipients.map do |recipient|
      recipient_avatar(recipient)
    end.flatten.join.html_safe
  end

  def recipient_avatar(user)
    link_to(image_tag(user.avatar_small_thumb_url, style: "height: 45px", alt: user.full_name, title: user.full_name, class: "avatar"), user_path(user)) + " "
  end

  def recognition_approval_link(recognition, current_user)
    # raw("<div class='plus_one'>"+link_to("", recognition_plus_ones_path(recognition), method: :post, remote: true, class: "plus_one_link")+"</div>")
    if recognition.approved_by?(current_user)
      link_to(like_counter(recognition), recognition_approval_path(recognition.approval_for(current_user), recognition), method: :delete, remote: true, class: "approval_link approved", data:{sender: recognition.sender.email})
    else
      link_to(like_counter(recognition), recognition_approvals_path(recognition), method: :post, remote: true, class: "approval_link unapproved", data:{sender: recognition.sender.email})
    end
  end
    
  def recognition_approvers(recognition, limit=0)
    if !limit.nil? and limit > 0
      approval_set = recognition.approvals[0..limit-1]
      ending = (recognition.approvals.size > limit) ? " <a class='moreValidationNames' href="+recognition_path(recognition)+">...</a>" : ""
    else
      approval_set = recognition.approvals
      ending = ""
    end

    raw("<span id='recognition-approvers-#{recognition.id}'>"+
      approval_set.collect { |a| 
        link_to a.giver.full_name, user_path(a.giver) 
      }
      .join(", ")+
      ending+
      "</span>"
    )
  end

  def like_counter(recognition)
    if (recognition.approvals.size > 0) 
      "+"+recognition.approvals.size.to_s
    else
      "+"
    end
  end

  def recognition_message(recognition)
    if recognition.message != nil && recognition.message.length >= 290
      output = ''
      output << truncate(recognition.message, length: 290, omission: "")
      output << link_to("Read more", recognition_path(recognition), class: "read-more")
      simple_format(output)
    else
      simple_format(recognition.message)
    end
  end

  def kiosk_mode_url
    opts = {fullscreen: true}
    opts[:code] = @company.kiosk_mode_key if @company.kiosk_mode_key.present?
    
    recognitions_url(opts)
  end
end
