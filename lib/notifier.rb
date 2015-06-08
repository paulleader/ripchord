class Notifier < ActionMailer::Base

  def ripped(job)
    @job = job
    mail(to: @job.notification_address, from: @job.notifications_from, subject: "Ripped: #{@job.title}") do |format|
      format.text
      format.html
    end
  end

  def converted(job)
    @job = job
    mail(to: @job.notification_address, from: @job.notifications_from, subject: "Converted: #{@job.title}") do |format|
      format.text
      format.html
    end
  end
  
  def installed(job)
    @job = job
    mail(to: @job.notification_address, from: @job.notifications_from, subject: "Installed: #{@job.title}") do |format|
      format.text
      format.html
    end
  end
  
  def failed(job, exception)
    @job = job
    @exception = exception
    mail(to: @job.notification_address, from: @job.notifications_from, subject: "Failed: #{@job.title}") do |format|
      format.text
      format.html
    end
  end
end