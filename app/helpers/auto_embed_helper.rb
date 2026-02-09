module AutoEmbedHelper
  def embed_youtube_id(video_id)
    %(<iframe width="560" height="315" src="https://www.youtube.com/embed/#{video_id}" frameborder="0" allowfullscreen></iframe>)
  end

  def embed_solcast_url(url)
    url = url.sub(/\Ahttp:/, "https:")
    %(<iframe src="https://www.scolcast.ch/frameplay.php?url=#{url}" style="border:none;" width="550" height="350" allowfullscreen></iframe>)
  end

  def embed_vimeo_id(video_id)
    %(<iframe src="https://player.vimeo.com/video/#{video_id}" width="640" height="338" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>)
  end

  def embed_dailymotion_id(video_id)
    %(<iframe frameborder="0" width="480" height="270" src="//www.dailymotion.com/embed/video/#{video_id}" allowfullscreen></iframe>)
  end

  def embed_link(url)
    if URI(url).host == request.host
      %(<a href="#{url}" target="_blank">#{url}</a>)
    else
      %(<a href="#{url}" target="_blank" class="external-link">#{url}</a>)
    end
  end

  def embed_video(url)
    %(<video width="320" height="240" controls="controls" class="video-player"><source src="#{url}"/></video>)
  end

  def embed_audio(url)
    %(<audio controls="controls" class="audio-player"><source src="#{url}"/></audio>)
  end

  def auto_embed(string)
    URI.extract(string = string.dup).each do |url|
      url.include?("://".freeze) ? string.gsub!(/(\A|\s|>)#{Regexp.escape(url)}/, '\1' + embed_url(url)) : url
    end
    string
  end

  def embed_url(url)
    if (data = url.match(/https?:\/\/youtu\.be\/([\w-]+)/) || url.match(/https?:\/\/www.youtube.com\/watch\?v=([\w-]+)/))
      embed_youtube_id(data[1])
    elsif (data = url.match(/https?:\/\/www.dailymotion.com\/video\/(\w+)/) || url.match(/https?:\/\/dai.ly\/(\w+)/))
      embed_dailymotion_id(data[1])
    elsif (data = url.match(/https?:\/\/vimeo.com\/(\d+)/))
      embed_vimeo_id(data[1])
    elsif (data = url.match(/https?:\/\/www\.scolcast\.ch\/podcast\/services\/([^\b]+)/))
      embed_solcast_url(data[0])
    elsif /\.mp4\Z/i.match?(url)
      embed_video(url)
    elsif url.match(/\.ogg\Z/i) || url.match(/\.mp3\Z/i)
      embed_audio(url)
    else
      embed_link(url)
    end
  end

  def urls_to_links(string)
    URI.extract(string = string.dup).each do |url|
      url.include?("://".freeze) ? string.gsub!(/(\A|\s|>)#{Regexp.escape(url)}/, '\1' + embed_link(url)) : url
    end
    string
  end
end
