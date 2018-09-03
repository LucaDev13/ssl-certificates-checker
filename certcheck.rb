require "sslcheck"
require "rufus-scheduler"
require "time"
require "slack-notifier"
load "config.rb"


#schedule the certificate check every day at 9am UCT
scheduler = Rufus::Scheduler.new
    #example setting for test 
-      #scheduler.every '10s' do
-   #example setting for live 
-      #scheduler.cron '0 9 * * *' do

def ssl_check
    #performs the actual certificate check on the array of websites
    websites = @endpoints_list

    website =  websites.each   do |w|

    checker = SSLCheck::Check.new
    checker.check(w)
    puts  checker.peer_cert.to_h

    #checks the time before the expiry
     current_date = Time.now.iso8601.to_time
     cert_expiry_date = checker.peer_cert.not_after.to_time
     days_left = (cert_expiry_date - current_date) / 86400


    #slack notifier settings with slack webhook
    notifier = Slack::Notifier.new @slack_webhook

    #messages as slack attachments
        plus_60 = {
                              fallback: "*#{w}* will expire in over 60 days time. \n",
                              text: " *#{w}* will expire in over 60 days time. \n",
                              color: "#44bd32"
                            }
        eq_less_60 = {
                              fallback: "Expiry date is #{days_left.round} days from now on #{cert_expiry_date}.",
                              text: "Certificate check for *#{w}* : \n The certificate is valid. \n Expiry date is #{days_left.round} days from now on #{cert_expiry_date}. \n",
                              color: "#3498db"
            }
        eq_less_30 = {
                              fallback: "Expiry date is #{days_left.round} days from now on #{cert_expiry_date}.",
                              text: "Certificate check for *#{w}*: \n The certificate is valid. \n Expiry date is #{days_left.round} days from now on #{cert_expiry_date}.\n Please start scheduling certificate renewal.",
                              color: "#f0932b"
            }
        eq_less_10 = {
                             fallback: "Expiry date is #{days_left.round} days from now on #{cert_expiry_date}.",
                             text: "ATTENTION: Certificate check for *#{w}* : \n The certificate is valid. \n Expiry date is #{days_left.round} days days from now on #{cert_expiry_date}. Please act ASAP on the certificate renewal!  \n",
                             color: "#c0392b"
            }
    #logic to send out slack notification
     case
         when days_left <= 10
                 notifier.post attachments: [eq_less_10]
         
         when days_left <= 30
                 notifier.post attachments: [eq_less_30]
    
         when days_left <= 60
                 notifier.post attachments: [eq_less_60]
         
         else
                 notifier.post attachments: [plus_60]
                
     end

end

 end
 ssl_check
end
scheduler.join
# let the current thread join the scheduler thread
