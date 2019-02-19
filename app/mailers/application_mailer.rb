class ApplicationMailer < ActionMailer::Base
  default from: '"AGMS Reputation System" <agmsrepsys@gmail.com>',
    bcc: 'agmsmith@ncf.ca'
  layout 'mailer'
end
