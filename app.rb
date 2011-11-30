require 'sinatra'
require 'active_support/all'

set :email_username, ENV['SENDGRID_USERNAME'] || 'app1796376@heroku.com'
set :email_password, ENV['SENDGRID_PASSWORD'] || '8nmbqqgb'
set :email_address,  'CIS Visa <help@cisvisa.com>'
set :email_service,  ENV['EMAIL_SERVICE'] || 'sendgrid.net'

def send_email(recipient, subject, body)
  require 'pony'
  Pony.mail(
    :from => settings.email_address,
    :to => recipient,
    :subject => subject,
    :body => body,
    :port => '587',
    :via => :smtp,
    :via_options => {
    :address              => 'smtp.' + settings.email_service,
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => settings.email_username,
    :password             => settings.email_password,
    :authentication       => :plain,
  })
end

def error_message(message)
  return <<EOF
<html>

<!-- START OF COMMON HEADERS -->
<head>
<title>Error - CIS Visa</title>

<!-- Meta Tags -->
<meta charset="utf-8">
<meta name="robots" content="index">
<meta name="generator" content="cisvisa.com">

<link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
<link rel="canonical" href="http://info.cisvisa.com/.../">

<link href="/stylesheets/main.css?1321247586" media="screen" rel="stylesheet" type="text/css">
<link href="/stylesheets/box.css?1321247586" media="screen" rel="stylesheet" type="text/css">
<link href="/stylesheets/tooltip.css?1321369275" media="screen" rel="stylesheet" type="text/css">
<script src="/javascripts/tooltip.js?1321369380" type="text/javascript"></script>

<!-- Google analytics -->
<script type="text/javascript" async="" src="http://www.google-analytics.com/ga.js"></script>
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-26261615-3']);
  _gaq.push(['setDomainName', '.cisvisa.com']);
  _gaq.push(['_trackPageview']);
 
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>

<script language="javascript"> 
function popUp(URL) {
  if (typeof popupId !== 'undefined') {
    eval("pagePopup" + popupId + ".close();");
  }
  popupId = (new Date()).getTime();
  eval("pagePopup" + popupId + " = window.open(URL, '" + popupId + "', 'toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=1,width=300,height=550,left = 835,top = 400');");
}

function toggle(arg) {
        var ele = document.getElementById("toggleText" + arg);
        var text = document.getElementById("displayText");
        if(ele.style.display == "block") {
                ele.style.display = "none";
                text.innerHTML = "Learn more...";
        }
        else {
                ele.style.display = "block";
                text.innerHTML = "Hide this text:";
        }
} 
</script>
</head>
<!-- END OF COMMON HEADERS -->

<body>
  <div id="container">
    <table cellspacing=10> 
      <tr><td>
          <a href="/"><img src="/images/banner-narrow.png"></a>
        </td>
      </tr>
    </table>
    <div class="pagewrap">
      <h1>Something went wrong...</h1>
      <p>#{message}</p>
      <p><a href="javascript:history.back()">Go back...</a></p>
    </div>
  </div>
</body>
</html>
EOF
end

def send_friend_email(sender, recipient)
  subject = "#{sender} asked us to tell you about CIS Visa"
  raise 'Error sending email' unless send_email(recipient, subject, [<<EOF])
Dear #{recipient},

#{sender} asked us to share CISVisa.com with you.

Whether you're a potential visitor or an immigrant to the 
United States of America, CIS Visa can help you find out 
what visas are right for you. We can also help you find 
trustworthy help to get your visa quickly.

Best wishes,

The CIS Visa Team
EOF
end

post '/feedback' do
  raise 'Error sending email' unless send_email('leads@cisvisa.com', 'User Feedback', [<<EOF])
Someone cares about you!

Name:   #{params[:name]}
Email:  #{params[:email]}
Hidden: #{params[:hidden]}
Feedback:
#{params[:feedback]}
EOF
  redirect "/#{params[:locale]}/mailsent.html"
end

post '/friends' do
  return error_message("Please supply a valid email address for yourself and at least one friend") unless params[:email].present? && params[:email1].present?
  friend  = (params[:name].present? ? params[:name] : params[:email])
  send_friend_email(friend, params[:email1])
  send_friend_email(friend, params[:email2]) if params[:email2].present?
  send_friend_email(friend, params[:email3]) if params[:email3].present?
  redirect "/#{params[:locale]}/mailsent.html"
end

post '/referral' do
  raise 'Error sending email' unless send_email('leads@cisvisa.com', 'New Lead', [<<EOF])
Well howdelydoodelydoo,

You've received a new lead.  Here's the lowdown:
Name:   #{params[:name]}
Email:  #{params[:email]}
Phone:  #{params[:phone]}
Langs:  #{params[:languages]}
Locale: #{params[:locale]}
Page:   #{params[:page]}
Info:  
#{params[:information]}
EOF
  redirect "/#{params[:locale]}/referralmade.html"
end
