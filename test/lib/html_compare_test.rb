require "test_helper"

class HtmlCompareTest < ActiveSupport::TestCase
  def test_merged_word_diff
    html1 = "<div>hello 1 2 3</div>"
    html2 = "<div>hello un deux trois</div>"
    result = "<div>hello <del>1 2 3</del><ins>un deux trois</ins></div>"
    assert_equal(result, HtmlCompare.preview(html1, html2))
  end

  def test_html_entities
    html1 = "<div>hello world&nbsp;</div>"
    html2 = "<div>hello world !</div>"
    result = "<div>hello world <ins>!</ins></div>"
    assert_equal(result, HtmlCompare.preview(html1, html2))
  end

  def test_deletion_by_word
    html1 = "<div>hello world test</div>"
    html2 = "<div>hello world</div>"
    result = "<div>hello world<del> test</del></div>"
    assert_equal(result, HtmlCompare.preview(html1, html2))
  end

  def test_addition_by_word
    html1 = "<div>hello world</div>"
    html2 = "<div>hello world test</div>"
    result = "<div>hello world<ins> test</ins></div>"
    assert_equal(result, HtmlCompare.preview(html1, html2))
  end

  def test_with_minus_sign
    html1 = "<div>- hello</div>"
    html2 = "<div>- world</div>"
    result = "<div>- <del>hello</del><ins>world</ins></div>"
    assert_equal(result, HtmlCompare.preview(html1, html2))
  end

  def test_with_plus_sign
    html1 = "<div>+ hello</div>"
    html2 = "<div>+ world</div>"
    result = "<div>+ <del>hello</del><ins>world</ins></div>"
    assert_equal(result, HtmlCompare.preview(html1, html2))
  end

  def test_preview
    html1 = "<div>- Ligne 1b<br><br>- Ligne 2<br><br>- Ligne 3b<br><br></div><ul><li>A</li><li>B</li><li>C</li></ul><div><br>- Ligne 4</div>"
    html2 = "<div>Ligne une<br>Ligne 2<br>Ligne 3 (trois)<br><br></div><ul><li>A</li><li>B</li><li>C</li><li>D</li></ul><div><br>- Ligne 4</div>"
    result = "<div><del>- </del>Ligne <del>1b</del><br><ins>une</ins><br><del>- </del>Ligne 2<br><br><del>- </del>Ligne <del>3b</del><ins>3 (trois)</ins><br><br></div><ul><li>A</li><li>B</li><li>C</li><li><ins>D</ins></li></ul><div><br>- Ligne 4</div>"
    assert_equal(result, HtmlCompare.preview(html1, html2))
  end

  def test_files
    html1 = '<div><strong>Lorem ipsum<br></strong><br></div><ul><li>Bla bla bla<a href="https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 1.odt" data-trix-attachment="{&quot;contentType&quot;:&quot;application/vnd.oasis.opendocument.text&quot;,&quot;filename&quot;:&quot;Test 1.odt&quot;,&quot;filesize&quot;:8170,&quot;href&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 1.odt&quot;,&quot;url&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 1.odt&quot;}" data-trix-content-type="application/vnd.oasis.opendocument.text"><figure class="attachment attachment-file odt"><figcaption class="caption">Test 1.odt <span class="size">7.98 KB</span></figcaption></figure></a></li></ul>'
    html2 = '<div><strong>Lorem ipsum<br></strong><br></div><ul><li>Bla bla bla<a href="https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 2.odt" data-trix-attachment="{&quot;contentType&quot;:&quot;application/vnd.oasis.opendocument.text&quot;,&quot;filename&quot;:&quot;Test 2.odt&quot;,&quot;filesize&quot;:8191,&quot;href&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 2.odt&quot;,&quot;url&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 2.odt&quot;}" data-trix-content-type="application/vnd.oasis.opendocument.text"><figure class="attachment attachment-file odt"><figcaption class="caption">Test 2.odt <span class="size">8 KB</span></figcaption></figure></a><a href="https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 1.odt" data-trix-attachment="{&quot;contentType&quot;:&quot;application/vnd.oasis.opendocument.text&quot;,&quot;filename&quot;:&quot;Test 1.odt&quot;,&quot;filesize&quot;:8170,&quot;href&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 1.odt&quot;,&quot;url&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 1.odt&quot;}" data-trix-content-type="application/vnd.oasis.opendocument.text"><figure class="attachment attachment-file odt"><figcaption class="caption">Test 1.odt <span class="size">7.98 KB</span></figcaption></figure></a><a href="https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 3.odt" data-trix-attachment="{&quot;contentType&quot;:&quot;application/vnd.oasis.opendocument.text&quot;,&quot;filename&quot;:&quot;Test 3.odt&quot;,&quot;filesize&quot;:8206,&quot;href&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 3.odt&quot;,&quot;url&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 3.odt&quot;}" data-trix-content-type="application/vnd.oasis.opendocument.text"><figure class="attachment attachment-file odt"><figcaption class="caption">Test 3.odt <span class="size">8.01 KB</span></figcaption></figure></a></li></ul>'
    result = '<div><strong>Lorem ipsum<br></strong><br></div><ul><li>Bla bla bla<a href="https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 2.odt" data-trix-attachment="{&quot;contentType&quot;:&quot;application/vnd.oasis.opendocument.text&quot;,&quot;filename&quot;:&quot;Test 2.odt&quot;,&quot;filesize&quot;:8191,&quot;href&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 2.odt&quot;,&quot;url&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 2.odt&quot;}" data-trix-content-type="application/vnd.oasis.opendocument.text"><figure class="attachment attachment-file odt"><figcaption class="caption"><ins>Test 2.odt </ins><span class="size"><ins>8 KB</ins></span></figcaption></figure></a><a href="https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 1.odt" data-trix-attachment="{&quot;contentType&quot;:&quot;application/vnd.oasis.opendocument.text&quot;,&quot;filename&quot;:&quot;Test 1.odt&quot;,&quot;filesize&quot;:8170,&quot;href&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 1.odt&quot;,&quot;url&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 1.odt&quot;}" data-trix-content-type="application/vnd.oasis.opendocument.text"><figure class="attachment attachment-file odt"><figcaption class="caption">Test 1.odt <span class="size">7.98 KB</span></figcaption></figure></a><a href="https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 3.odt" data-trix-attachment="{&quot;contentType&quot;:&quot;application/vnd.oasis.opendocument.text&quot;,&quot;filename&quot;:&quot;Test 3.odt&quot;,&quot;filesize&quot;:8206,&quot;href&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 3.odt&quot;,&quot;url&quot;:&quot;https://s3-eu-west-1.amazonaws.com/sqily/development/workspaces/3185/attachments/Test 3.odt&quot;}" data-trix-content-type="application/vnd.oasis.opendocument.text"><figure class="attachment attachment-file odt"><figcaption class="caption"><ins>Test 3.odt </ins><span class="size"><ins>8.01 KB</ins></span></figcaption></figure></a></li></ul>'
    assert_equal(result, HtmlCompare.preview(html1, html2))
  end
end
