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
end