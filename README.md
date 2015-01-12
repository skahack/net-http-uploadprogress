# net-http-uploadprogress.gem

Get the file uploading progress.

## Installation

    gem install net-http-uploadprogress

## Examples

```ruby
    require 'net/http/uploadprogress'

    # API style upload
    File.open('path/to.file', 'rb') do |io|
      http = Net::HTTP.new(host, port)
      req = Net::HTTP::Post.new('/')
      req.content_length = io.size
      req.body_stream = io
      Net::HTTP::UploadProgress.new(req) do |progress|
        puts "uploaded so far: #{ progress.upload_size }"
      end
      res = http.request(req)
    end

    # Form input type="file" style upload
    File.open('path/to.file', 'rb') do |io|
      http = Net::HTTP.new(host, port)
      req = Net::HTTP::Post.new('/')
      req.set_form({'file_form_field_name' => io}, 'multipart/form-data')
      Net::HTTP::UploadProgress.new(req) do |progress|
        puts "uploaded so far: #{ progress.upload_size }"
      end
      res = http.request(req)
    end
```
