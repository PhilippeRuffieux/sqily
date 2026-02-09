require "test_helper"

class AutoEmbedHelperTest < ActiveSupport::TestCase
  include AutoEmbedHelper

  def test_auto_embed_plain_text
    assert_equal("Test", auto_embed("Test"))
  end

  def test_auto_embed_link
    stubs(request: stub(host: "www.sqily.com"))
    assert_equal("foo: bar", auto_embed("foo: bar"))
    assert_equal('<a href="http://www.sqily.com" target="_blank">http://www.sqily.com</a>', auto_embed("http://www.sqily.com"))
    assert_equal('<a href="http://basesecrete.com" target="_blank" class="external-link">http://basesecrete.com</a>', auto_embed("http://basesecrete.com"))
  end

  def test_auto_embed_audio
    assert_equal('<audio controls="controls" class="audio-player"><source src="http://www.teamodoro.com/audio/stop.Ogg"/></audio>', auto_embed("http://www.teamodoro.com/audio/stop.Ogg"))
    assert_equal('<audio controls="controls" class="audio-player"><source src="http://www.teamodoro.com/audio/stop.Mp3"/></audio>', auto_embed("http://www.teamodoro.com/audio/stop.Mp3"))
  end

  def test_auto_embed_youtube
    assert_equal('<iframe width="560" height="315" src="https://www.youtube.com/embed/zWFhukWRp4o-_" frameborder="0" allowfullscreen></iframe>', auto_embed("https://youtu.be/zWFhukWRp4o-_"))
  end

  def test_auto_embed_vimeo
    assert_equal('<iframe src="https://player.vimeo.com/video/232614312" width="640" height="338" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>', auto_embed("https://vimeo.com/232614312"))
  end

  def test_auto_embed_dailymotion
    assert_equal('<iframe frameborder="0" width="480" height="270" src="//www.dailymotion.com/embed/video/x5zmfte" allowfullscreen></iframe>', auto_embed("http://dai.ly/x5zmfte"))
    assert_equal('<iframe frameborder="0" width="480" height="270" src="//www.dailymotion.com/embed/video/x5zmfte" allowfullscreen></iframe>', auto_embed("https://www.dailymotion.com/video/x5zmfte?collectionXid=x4zyqe"))
  end

  def test_auto_embed_solecast
    solecast_http = "http://www.scolcast.ch/podcast/services/67/podcast171/episode5734/2013-01-rebetez-2/export-x264.mp4"
    solecast_https = "https://www.scolcast.ch/podcast/services/67/podcast171/episode5734/2013-01-rebetez-2/export-x264.mp4"  # While Solecast does not handle SSL
    assert(auto_embed(solecast_http).include?(%(<iframe src="https://www.scolcast.ch/frameplay.php?url=#{solecast_https}" style="border:none;" width="550" height="350" allowfullscreen></iframe>)))
  end
end
