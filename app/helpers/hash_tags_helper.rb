module HashTagsHelper
  def hash_tags_to_links(text)
    HashTag.split(text = text.dup).each do |tag|
      text.gsub!(/(\A|\s)##{tag}\b/, "\\1" + link_to("##{tag}", url_for(params.permit(params.keys).merge(hash_tag: HashTag.normalize(tag)))))
    end
    text.html_safe
  end

  def hash_tags_autocomplete_list
    HashTag.joins(:message).merge(Message.in_community(current_community)).order("name").pluck_name.join(",")
  end
end
