Given /^I haven't made any RTSP requests$/ do
  RTSP::Client.configure { |config| config.log = false }
end

Given /^I have set up a stream$/ do
  @url = "rtsp://fake-rtsp-server/some_path"
  @client = RTSP::Client.new(@url) do |connection|
    connection.socket = @fake_server
    connection.timeout = 3
  end
  @client.setup @url
  @client.session_state.should == :ready
end

Given /^I have started (playing|recording) a stream$/ do |method|
  if method == "playing"
    @client.setup @url
    @client.play @url
  elsif method == "recording"
    @client.record @url
  end
  @client.session_state.should == method.to_sym
end

When /^I issue an "([^"]*)" request with "([^"]*)"$/ do |request_type, params|
  unless @client
    url = "rtsp://fake-rtsp-server/some_path"

    @client = RTSP::Client.new(url) do |connection|
      connection.socket = @fake_server
      connection.timeout = 3
    end
  end

  @initial_state = @client.session_state
  params = params.empty? ? {} : params

  if request_type == 'play'
    @client.setup(url)
    @client.play(params)
  else
    @client.send(request_type.to_sym, params)
  end
end

Then /^the state stays the same$/ do
  @client.session_state.should == @initial_state
end

Then /^the state changes to "([^"]*)"$/ do |new_state|
  @client.session_state.should == new_state.to_sym
end
