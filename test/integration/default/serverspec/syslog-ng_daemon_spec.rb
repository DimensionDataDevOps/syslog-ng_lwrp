require 'serverspec'

# Required by serverspec
set :backend, :exec

describe "Syslog-ng Daemon" do

  it "is listening on port 514" do
    expect(port(514)).to be_listening
  end

  it "has a running service of syslog-ng" do
    expect(service("syslog-ng")).to be_running
  end

end
