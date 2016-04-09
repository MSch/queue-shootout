$pg.async_exec "DROP TABLE IF EXISTS que_jobs"

Que.connection = $pg
Que.migrate!

$pg.async_exec <<-SQL
  INSERT INTO que_jobs (job_class, priority)
  SELECT 'QuePerpetualJob', 1
  FROM generate_Series(1,#{JOB_COUNT}) AS i;
SQL

class QuePerpetualJob < Que::Job
  def run
    self.class.enqueue
  end
end

QUEUES[:que] = {
  :setup => -> { Que.connection = $pg },
  :work  => -> { Que::Job.work }
}
