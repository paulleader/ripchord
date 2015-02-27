class Ripper < ProcessThread

  def _title(device = nil)
    DiscInfo.new(@logger, device).title
  end

  def _process(job)
    job.title = _title(job.device)
    MakeMKV.new(@logger, job.title, disc = job.device, @working_area.ripping_dir).rip
    @working_area.move_to_transcoding(job.title)
    @logger.info "Moved to transcoding #{job}"
  end

end