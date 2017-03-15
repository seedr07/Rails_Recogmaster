#DataReporter::Reporter.new("tmp/recognize_production_*.sql",Company.analytics_data).run
module DataReporter

  class Reporter
    attr_accessor :files, :data_source, :report
    def initialize(dataglob, data_source,datafile=nil)
      self.files = Dir.glob(dataglob)
      self.data_source = data_source
      self.report = Report.new(data_source, datafile)
      return self
    end

    def run
      files.each do |f|
        ts = self.class.timestamp(f)
        Timecop.freeze(Time.parse(ts))

        puts " ------------ "
        puts "Loading data from: #{ts}"

        if report.has_entry?(f)
          puts "skipping, already loaded"
          next
        end

        report.load_db!(f)

        puts "Crunching numbers..."
        report.populate!(f)

        puts "Writing data"
        report.write_out!
      end
    ensure 
      Timecop.return
    end

    def self.timestamp(f)
      f.match(/([0-9]+)/)[1]
    end
  end

  # DataSource must respond to:
  #   report_name (string) 
  #   report_data (simple key value hash)
  #   refresh! (callback on the datasource to say we've loaded data and its time to fetch or refetch data)
  class Report

    attr_accessor :datasource, :reportfile, :rows

    def initialize(datasource, reportfile=nil)
      self.datasource = datasource
      self.reportfile = reportfile.kind_of?(File) ? reportfile : File.open(report_path(datasource.report_name+".yaml"), "r+")
      self.load_yaml!
    end

    def series(series)
      lower_bound = Time.parse("September 1, 2013")
      data = rows.
      select {|filename, data| Time.parse(DataReporter::Reporter.timestamp(filename)) > lower_bound}.
      map do |filename, data|
        timestamp = Time.parse(DataReporter::Reporter.timestamp(filename)).to_i * 1000
        [timestamp, data[series]]
      end
      data.sort{|a,b| a[0] <=> b[0]}.to_s
    end

    def load_db!(filename)
      gzipped = filename.match(/\.sql.gz$/)
      if gzipped
        execcmd("gunzip #{filename}")
        filename = filename.gsub('.sql.gz', '.sql')
      end
      
      execcmd("bin/rake recognize:load_db file=#{filename}")

      if gzipped
        execcmd("gzip #{filename}")
      end

      ActiveRecord::Base.connection.tables.collect{|t| t.classify.constantize rescue nil}.reject(&:blank?).map{|k| k.reset_column_information rescue nil}

      self.datasource.refresh!      
    end

    def execcmd(cmd)
      puts "Executing: #{cmd}"
      `#{cmd}`
    end

    def report_path(filename)
      File.join(Rails.root, "reports", filename)
    end

    def load_yaml!
      yaml = YAML.load(self.reportfile)
      if yaml
        self.rows = yaml.inject({}){|hash, data| key,row = data;rr = ReportRow.new(row); hash[key] = row;hash}
      else
        self.rows = {}
      end
    end

    def populate!(key)
      rows[key] = ReportRow.new(self.datasource.report_data)
      return self
    end

    def write_out!
      self.reportfile.rewind
      self.reportfile.write(YAML::dump(rows))
      self.reportfile.flush
    end

    def has_entry?(filename)
      rows[filename].present?
    end
  end

  class ReportRow
    attr_accessor :data
    def initialize(data)
      self.data = data
    end

    def key
      data[:id]
    end

    def encode_with(coder)
      coder.represent_map nil, data
    end

    def to_yaml
      YAML::dump(self.data)
    end
  end
end

