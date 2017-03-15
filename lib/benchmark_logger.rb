module BenchmarkLogger
  def bmlog(label, opts={}, &block)
    if opts[:skip]
      block.call
    else
      Rails.logger.info "BM: #{label}: " + Benchmark.realtime(&block).to_s
    end
  end
end