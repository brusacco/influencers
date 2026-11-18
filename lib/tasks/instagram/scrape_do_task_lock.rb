# frozen_string_literal: true

require 'tmpdir'

module InstagramScrapeDoTaskLock
  def self.acquire(task_name)
    lock = File.open(File.join(Dir.tmpdir, "influencers-#{task_name}.lock"), File::RDWR | File::CREAT, 0o644)
    return lock if lock.flock(File::LOCK_EX | File::LOCK_NB)

    lock.close
    nil
  end
end
