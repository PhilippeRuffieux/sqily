require "test_helper"

class HashTagTest < ActiveSupport::TestCase
  def test_split
    assert_equal([], HashTag.split(nil))
    assert_equal([], HashTag.split("")) # standard:disable Style/StringChars
    assert_equal([], HashTag.split("Test"))
    assert_equal(%w[one two], HashTag.split("Test #one#two"))
    assert_equal(%w[one two], HashTag.split("Test #one,#two"))
    assert_equal(%w[one two], HashTag.split("Test #one #two #---"))
    assert_equal(%w[one two], HashTag.split("Test #one #two # ---"))
    assert_equal(%w[one one_bis], HashTag.split("#one-test #one_bis"))
    assert_equal(%w[ÉTÉ pouët], HashTag.split("#ÉTÉ #pouët"))
  end

  def test_extract
    assert_equal(%w[ete pouet], HashTag.extract("#ÉTÉ #pouët"))
  end

  def test_index_record_attributes
    HashTag.delete_all
    message = messages(:alexis_to_base)
    assert_difference("message.hash_tags.count") { HashTag.index_record_attributes(message, [:text]) }
    assert_no_difference("message.hash_tags.count") { HashTag.index_record_attributes(message, [:text]) }
  end

  def test_scope_by_hash_tags
    HashTag.index_record_attributes(messages(:alexis_to_base), :text)
    assert_equal([messages(:alexis_to_base)], Message.by_hash_tags("HëlloWÖrld").to_a)
  end
end
