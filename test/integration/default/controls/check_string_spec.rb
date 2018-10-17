control 'check_string' do
  describe os_env('tags') do
    its('content') { should_not eq '' }
    its('content') { should_not eq 'default_value' }
  end
end