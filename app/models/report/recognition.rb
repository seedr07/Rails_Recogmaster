# {
#   "draw"=>"1", 
#   "columns"=>
#     {"0"=>{"data"=>"created_at", "name"=>"", "searchable"=>"true", "orderable"=>"true", "search"=>{"value"=>"", "regex"=>"false"}}, 
#      "1"=>{"data"=>"sender", "name"=>"", "searchable"=>"true", "orderable"=>"true", "search"=>{"value"=>"", "regex"=>"false"}}, 
#      "2"=>{"data"=>"recipients", "name"=>"", "searchable"=>"true", "orderable"=>"true", "search"=>{"value"=>"", "regex"=>"false"}}, 
#      "3"=>{"data"=>"badge", "name"=>"", "searchable"=>"true", "orderable"=>"true", "search"=>{"value"=>"", "regex"=>"false"}}, 
#      "4"=>{"data"=>"message", "name"=>"", "searchable"=>"true", "orderable"=>"true", "search"=>{"value"=>"", "regex"=>"false"}}, 
#      "5"=>{"data"=>"skills", "name"=>"", "searchable"=>"true", "orderable"=>"true", "search"=>{"value"=>"", "regex"=>"false"}}}, 
#   "order"=>{
#     "0"=>{"column"=>"0", "dir"=>"asc"}}, 
#   "start"=>"0", 
#   "length"=>"10", 
#   "search"=>{"value"=>"", "regex"=>"false"}, "_"=>"1427837484094", "network"=>"recognizeapp.com"}
module Report
  class Recognition
    attr_reader :company, :from, :to, :opts, :page, :per_page

    def initialize(company, from=50.years.ago, to=Time.now, opts={})
      @company = company
      @from = parse_start_time(from)
      @to = parse_end_time(to)
      @per_page = opts[:length].to_i
      @opts = opts
      # @page = (opts[:start].to_i / opts[:length].to_i) + 1
    end

    def recognitions
      # if per_page == -1
        return query
      # else
        # query.paginate(page: page, per_page: per_page)
      # end
    end

    def recognition_count
      query.size
    end

    private
    def query
      @query ||= opts[:use_reference_recipients] ? point_activity_query : recognition_query
    end

    def recognition_query
      company.recognitions
        .includes(:badge, :sender, recognition_recipients: :user)
        .where("created_at >= ? AND created_at <= ?", from, to)
    end

    # its more efficient to query via point activities when trying to get a report with the recipients split out
    def point_activity_query

       set = PointActivity.includes(:user, recognition: [:badge, :sender, recognition_recipients: {user: :teams}])
         .where(company_id: company.id, activity_type: PointActivity::Type.recognition_recipient)
         .where("point_activities.created_at >= ? AND point_activities.created_at <= ?", from, to)

      new_set = set.map{ |pa| 
        pa.recognition.dup_for_reference.tap{ |r| 
          r.reference_recipient = pa.user
          r.reference_activity = pa
      }}
      return new_set
    end

    def parse_start_time(time)
      time.kind_of?(String) ? parse(time).at_midnight : time
    end

    def parse_end_time(time)
      time.kind_of?(String) ? (parse(time)+1.day).at_midnight : time    
    end    

    def parse(time)
      time.to_i == 0 ? Time.strptime(time, "%m/%d/%Y") : Time.at(time.to_i)
    end
  end
end
