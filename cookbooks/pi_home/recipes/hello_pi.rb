script 'hello_pi' do
  interpreter "bash"
  code <<-EOH
    echo "hello from raspberry! My hostname is $(hostname)"
    uname -a
  EOH
  flags "-x"
end
