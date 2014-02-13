require 'sinatra'
require 'gmail'

class GmailBounce

	def initialize(username,password)
	@bad_mails=[]
	
	# Open a connection using your default smtp settings, could also define via YML or inline
	gmail = Gmail.connect!(username,password)
		
	    # Find everything from the Gmail mailer daemon (unread only)
	    emails = gmail.inbox.emails(:unread, :from => "mailer-daemon@googlemail.com", :subject => "Delivery Status Notification (Failure)")
	    #puts "Found #{emails.length} messages"
		
	    emails.each do |email|
		# Gmail sets a header "X-Failed-Recipients", with each email that failed
		
		if !email.header["X-Failed-Recipients"].blank?
		  bad_addresses = email.header["X-Failed-Recipients"].value.split(",")
		  bad_addresses.each do |bad_addr|
			@bad_mails << bad_addr
		  end # close emails form header
		  email.read! # Mark as read so we don't try to deal with it again next time
		end

	    end # next email		
	    gmail.logout # done!
	end

	def each
		@bad_mails.each { |i| yield "#{i}\n" }
	end	
end

get '/bounces/:username/:password' do
	GmailBounce.new(params[:username],params[:password])	
end

