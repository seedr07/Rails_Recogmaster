set = RecognitionApproval.pluck(:id, :giver_id, :recognition_id).group_by{|ra| "#{ra[1]}-#{ra[2]}"}.select{|k,v| v.length > 1}
puts "Found #{set.length} recognitions that have duplicate approvals"
ids = []
set.each do |key, duplicate_approvals|
  duplicate_approvals.shift
  ids << duplicate_approvals.map{|a| a[0]}
end

RecognitionApproval.where(id: ids).destroy_all