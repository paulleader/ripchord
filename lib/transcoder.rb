class Transcoder < ProcessThread

  def _process(job)
    @handbrake = Handbrake.new(@log)
    @handbrake.convert(@working_area.ripped_file(job.title), @working_area.converting_file(job.title), job.preset)
    @working_area.cleanup_rip(job.title)
  end

end