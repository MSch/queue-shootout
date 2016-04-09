$pg.async_exec "DROP TABLE IF EXISTS queue_classic_jobs CASCADE"
$pg.async_exec "DROP FUNCTION IF EXISTS queue_classic_notify()"

# # Set up QueueClassic. There's unfortunately no clean way to set the
# # default_conn_adapter in v3.0.0rc.
QC.default_conn_adapter = QC::ConnAdapter.new($pg)
QC::Setup.create

JOB_COUNT.times do
  QC.enqueue "QCPerpetualJob.run"
end

module QCPerpetualJob
  class << self
    def run(*args)
      QC.enqueue "QCPerpetualJob.run"
    end
  end
end

QUEUES[:queue_classic] = {
  :setup => -> {
    QC.default_conn_adapter = QC::ConnAdapter.new($pg)
    QC.default_queue = QC::Queue.new(QC.queue)
    $worker = QC::Worker.new
  },
  :work => -> { $worker.work }
}
