class Installer < ProcessThread

  def _process(job)
    @log.debug "Installer: Installing #{job.title} to #{job.destination_directory}"
    FileUtils.move(@working_area.converting_file(job.title), job.destination_directory)
    job.state = nil
  end

end