class HtmlCompare
  TAG_REGEX = /(<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[\^'">\s]+))?)+\s*|\s*)\/?>)/

  def self.preview(html1, html2)
    format(DiffProcessor.call(html1, html2))
  end

  def self.format(tokens)
    tokens
      .map { |token| format_token(token) }
      .compact
      .join("")
      .delete("\n")
      .gsub("<del></del>", "")
      .gsub("</del><del>", "")
      .gsub("</ins><ins>", "")
      .gsub("<ins></ins>", "")
  end

  def self.format_token(token)
    if token.word? || token.space?
      token.value
    elsif token.deletion?
      tag?(token.value) ? token.value : "<del>#{token.value}</del>"
    elsif token.addition?
      tag?(token.value) ? token.value : "<ins>#{token.value}</ins>"
    end
  end

  def self.tag?(value)
    value =~ TAG_REGEX
  end

  class DiffToken
    attr_reader :value

    def empty?
      @value.empty?
    end

    def word?
      @type == :word
    end

    def space?
      @type == :space
    end

    def deletion?
      @type == :deletion
    end

    def addition?
      @type == :addition
    end

    def to_s
      "[#{@type}:#{@value}]"
    end

    def self.addition(value)
      DiffToken.new(value, :addition)
    end

    def self.deletion(value)
      DiffToken.new(value, :deletion)
    end

    def self.word(value)
      DiffToken.new(value, :word)
    end

    def initialize(value, type)
      @value = value
      @type = (type == :word && value.blank?) ? :space : type
    end
  end

  class DiffMerger
    def initialize
      reset!
    end

    def add_space(space)
      @staging.push(space)
    end

    def add_deletion(deletion)
      flush_staging_to_diffs!
      @deletions.push(deletion)
    end

    def add_addition(addition)
      flush_staging_to_diffs!
      @additions.push(addition)
    end

    def merge_in_progress?
      @deletions.present? || @additions.present?
    end

    def spaces_staged?
      @staging.present?
    end

    def finalize!
      deletions = @deletions.join("")
      merged_deletions = deletions.empty? ? nil : DiffToken.deletion(deletions)

      additions = @additions.join("")
      merged_additions = additions.empty? ? nil : DiffToken.addition(additions)

      staging = @staging.join("")
      merged_staging = staging.empty? ? nil : DiffToken.word(staging)
      reset!
      [merged_deletions, merged_additions, merged_staging].compact
    end

    def reset!
      @additions = []
      @deletions = []
      @staging = []
    end

    private

    def flush_staging_to_diffs!
      @additions += @staging if @additions.present?
      @deletions += @staging if @deletions.present?
      @staging = []
    end
  end

  class DiffProcessor
    def self.call(html1, html2)
      diff = Diffy::Diff.new(prepare_html(html1), prepare_html(html2)).to_s
      diff_tokens = tokenize_diff(diff)
      compact_diff(diff_tokens)
    end

    def self.prepare_html(html)
      split_on_html_tag(html)
        .map { |content_token| split_non_tag_content(content_token) }
        .join("\n")
        .concat("\n")
    end

    def self.split_on_html_tag(html)
      html
        .gsub(TAG_REGEX, "\n\\1\n")
        .split("\n")
        .select { |i| i != "" && i != "\n" }
    end

    def self.split_non_tag_content(content_token)
      return content_token if TAG_REGEX.match?(content_token)

      content_token.gsub("&nbsp;", " ").gsub(" ", "\n \n")
    end

    def self.tokenize_diff(diff)
      diff.each_line.map do |line|
        line = sanitize_line(line)
        case line[0]
        when "-"
          (line[1] == "<") ? DiffToken.word(extract_content(line)) : DiffToken.deletion(extract_content(line))
        when "+"
          (line[1] == "<") ? DiffToken.word(extract_content(line)) : DiffToken.addition(extract_content(line))
        else
          DiffToken.word(extract_content(line))
        end
      end
    end

    def self.sanitize_line(line)
      line.delete("\n")
    end

    def self.extract_content(line)
      line[1..]
    end

    def self.compact_diff(tokens)
      merger = DiffMerger.new

      merged_tokens = []

      tokens.each do |token|
        next if token.empty?

        if token.word?
          if merger.merge_in_progress?
            merged_diffs = merger.finalize!
            merged_tokens += merged_diffs
          end
          merged_tokens.push(token)
        elsif token.space?
          if merger.merge_in_progress?
            merger.add_space(token.value)
          else
            merged_tokens.push(token)
          end
        elsif token.deletion?
          merger.add_deletion(token.value)
        elsif token.addition?
          merger.add_addition(token.value)
        end
      end

      if merger.merge_in_progress?
        merged_diffs = merger.finalize!
        merged_tokens += merged_diffs
      end

      merged_tokens
    end
  end
end
