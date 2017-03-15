module MailHelper

  @@styles ||= {
    text: "font-family: Lato, Helvetica Neue, Arial, Sans serif; color: #333333; text-shadow: 0 1px 1px #FFF;",
    h1: "font-weight: 400;",
    h2: "font-size: 26px; line-height: 35px; font-weight: 200; margin: 0 0 25px 0;",
    h3: "font-size: 20px; line-height: 22px; font-weight: 400;",
    h4: "font-weight: 200;",
    h5: "font-weight: 400;",
    p: "font-size: 16px; line-height: 18px; font-family: Myrid Pro, Helvetica, Arial, Sans serif; margin: 0 0 15px 0;",

    clear: "<div style='clear: both; margin: -1px;height: 0;'></div>",

    button: "background-color:#1568A6;background-image:-webkit-linear-gradient(top,#237FC3,#1568A6);color:#FFF;border:1px solid, #6588AD;text-shadow:0 1px 0 rgba(136,136,136,0.71);font-size:15px;text-decoration:none;text-align:center;display:block;font-family:Lato, Helvetica Neue, Helvetica, Arial, sans-serif;line-height:15px;cursor:pointer;text-transform:none;margin:0 0 15px 0;padding:19px 26px; border-radius: 6px;",
    inline: "display:inline-block",

    a: "color: #1568A6; text-decoration: none;",

    hr: '<div style="height: 0px; border-top: 1px solid #d9dadd; border-bottom: 1px solid #fff;"></div>',

    hr_styles: "height: 0px; border-top: 1px solid #d9dadd; border-bottom: 1px solid #fff;",

    dllist: "text-align: center; margin: 0; float: left; margin-right: 7%;",

    dllistDD: "margin: 0; font-size: 50px; font-weight: 200;",

    dllistDT: "font-size:20px; font-weight: 200;",

    counter: "font-size:14px;line-height:14px;cursor:pointer;float:left;margin-right:10px;width:33px;height:12px;background-color:#6CC8FF;background-image:linear-gradient(top,#6CC8FF,#5CB8FF);color:#FFF!important;text-shadow:1px 1px 0 #3A97DE;text-decoration:none!important;box-shadow:inset 0 1px 0 rgba(28,85,184,0.52);border-radius:23px;text-align:center;padding:5px 0; text-shadow: none !important;",

    textSubtle: "color: #858585; font-size: 11px; line-height: 13px;",

    recognitionCard: "margin: 0 5%; width: 40%; min-width: 235px; float: left; position: relative; padding-bottom: 21px; margin-bottom: 20px;",
    
    title: "display: inline-block;",

    leaderboard: "list-style: none; margin: 0 auto 40px auto; max-width: 320px; padding: 0;",

    leaderboard_item: "padding: 10px; list-style: none; margin: 0;text-align: left;"
  }

  def mail_styles(*args)
    return @@styles.values_at(*args).join(" ").html_safe
  end

  # campaign is the name of the email
  # campaign_type is what type of email(eg Blast, Notifier, Reminder)
  def generate_mixpanel_email(user, campaign, campaign_type, custom_opts={})
    
    mixpanel_data = {
      event: "User opened #{campaign_type}", 
      properties: {
        distinct_id: user.email,
        # TODO: change this below logic to check network when we implement xcompany
        token: user.company_id == 1 ? "f6226718dca5c61a2ce1b3d6925ce6b5" : "26747720351902ef3610eb96971f064e",
        time: Time.now.to_i, 
        campaign_type: campaign_type,
        campaign: campaign
      }
    }.merge(custom_opts)

    data = Base64.encode64(mixpanel_data.to_json)
    
    return "<img src='http://api.mixpanel.com/track/?data=#{data}&ip=1&img=1' />".html_safe
  end

end