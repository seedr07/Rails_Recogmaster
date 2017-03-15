module Select2Helper
  def select2(value, attrs)
    page.execute_script(%Q($("#{attrs[:from]}").select2('val', '#{value}')))
  end
end