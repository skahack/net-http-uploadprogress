# To run this test execute:
# $ bundle exec ruby spec/uploadprogress_spec.rb

require 'minitest/autorun'
require 'webrick'
require 'stringio'

require 'net/http/uploadprogress'

RUBY_IO_COPY_STREAM_BUFLEN = 16 * 1024
# See io.c
# static VALUE copy_stream_fallback_body(VALUE arg)
#   ...
#   const int buflen = 16*1024;
#   ...
# https://github.com/ruby/ruby/blob/trunk/io.c#L10414


server = WEBrick::HTTPServer.new({
  :BindAddress => '127.0.0.1',
  :Port        => 0,
  :Logger      => WEBrick::Log.new([], WEBrick::BasicLog::WARN),
  :AccessLog   => [],
  :ServerType  => Thread
})

server.mount_proc('/echo') do |req, res|
  res.body = req.body
end

server.mount_proc('/file') do |req, res|
  res.body = req.query['file']
end

server.start

describe 'Upload' do
  [{
    description: "smaller than buflen",
    content_length: RUBY_IO_COPY_STREAM_BUFLEN - 1,
    times_called: 1
  }, {
    description: "equal to buflen",
    content_length: RUBY_IO_COPY_STREAM_BUFLEN,
    times_called: 1
  }, {
    description: "larger than buflen",
    content_length: RUBY_IO_COPY_STREAM_BUFLEN + 1,
    times_called: 2
  }, {
    description: "exactly 2x larger than buflen",
    content_length: RUBY_IO_COPY_STREAM_BUFLEN * 2,
    times_called: 2
  }, {
    description: "more than 2x larger than buflen",
    content_length: RUBY_IO_COPY_STREAM_BUFLEN * 2 + 1,
    times_called: 3
  }].each do |upload|

    describe upload[:description] do
      http = Net::HTTP.new(server[:BindAddress], server[:Port])
      content = 'a' * upload[:content_length]
      req = Net::HTTP::Post.new('/echo')
      req.content_length = upload[:content_length]
      req.body_stream = StringIO.new(content)

      times_called = 0
      upload_size = 0

      Net::HTTP::UploadProgress.new(req) do |progress|
        times_called += 1
        upload_size += progress.upload_size - upload_size
      end

      res = http.request(req)

      it 'correctly transmits data to the server' do
        assert_equal(content, res.body)
      end

      it 'updates progress expected number of times' do
        assert_equal(upload[:times_called], times_called)
      end

      it 'updates progress with correct upload size' do
        assert_equal(upload[:content_length], upload_size)
      end
    end
  end

  describe 'file' do
    http = Net::HTTP.new(server[:BindAddress], server[:Port])
    req = Net::HTTP::Post.new('/file')

    content = 'hello'

    file = Tempfile.new('uploadprogress_spec')
    file.binmode
    file << content
    file.rewind

    req.set_form({'file' => file}, 'multipart/form-data', boundary: 'UfpmKZyktEWfuJidfSVW_Ss-HV5f-mbma0uQchAVbCJFxhKnYOcaTA')

    multipart_content = [
      '--UfpmKZyktEWfuJidfSVW_Ss-HV5f-mbma0uQchAVbCJFxhKnYOcaTA',
      'Content-Disposition: form-data; name="file"; filename="<filename>"',
      'Content-Type: application/octet-stream',
      '',
      'hello',
      '--UfpmKZyktEWfuJidfSVW_Ss-HV5f-mbma0uQchAVbCJFxhKnYOcaTA--',
      ''
    ].join("\r\n").sub('<filename>', File.basename(file.path))

    times_called = 0
    upload_size = 0

    Net::HTTP::UploadProgress.new(req) do |progress|
      times_called += 1
      upload_size += progress.upload_size - upload_size
    end

    res = http.request(req)

    file.close!

    it 'correctly transmits data to the server' do
      assert_equal(content, res.body)
    end

    it 'updates progress expected number of times' do
      assert_equal(1, times_called)
    end

    it 'updates progress with correct upload size' do
      assert_equal(multipart_content.length, upload_size)
    end
  end
end
