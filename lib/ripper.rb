class Ripper < ProcessThread

  def _title(device = nil)
    DiscInfo.new(@log, device).title
  end

  def _process(job)
    job.title = _title(job.device)
    MakeMKV.new(@log, job.title, disc = job.device, @working_area.ripping_dir).rip
    @working_area.move_to_transcoding(job.title)
    @log.info "Moved to transcoding #{job}"
    `eject`
  end

end