input_file = ARGV[0]

if input_file.nil? || ARGV.include?('--help') || ARGV.include?('-h')
  puts <<HELP
Usage:
  gfm input_file.md [output_file] [--help, -h]

  input_file.md   The markdown file to be parsed with GitHub Flavored Markdown.

  output_file     Name of the output file to be generated. If no name is given,
                  input_file.html is used.

  --help, -h      Display this help message.
HELP
elsif input_file.end_with?(".md") && File.exists?(input_file)
  require 'html/pipeline'
  require 'httpclient'
  require 'linguist'

  pipeline = HTML::Pipeline.new [
    HTML::Pipeline::MarkdownFilter,
    HTML::Pipeline::TableOfContentsFilter,
    HTML::Pipeline::SanitizationFilter,
    HTML::Pipeline::ImageMaxWidthFilter,
    HTML::Pipeline::HttpsFilter,
    HTML::Pipeline::MentionFilter,
    HTML::Pipeline::SyntaxHighlightFilter
  ]

  stylesheet_tags = HTTPClient.new.get("https://github.com").body.split("\n").select do |line|
    line=~/https:.*github.*\.css/
  end.join

  output_file_name = ARGV[1].present? ? (ARGV[1].end_with?('.html') ? ARGV[1] : ARGV[1] + '.html') : nil
  output_file = File.open(output_file_name || ARGV[0].gsub('md', 'html'), 'w')

  html_opening_tags = "<html><head><title>#{ARGV[0]}</title>"
  body_tags = "</head><body><div id='readme' style='width:914px;margin:20px auto'><article class='markdown-body'>"
  body_content = pipeline.call(File.new(ARGV[0]).readlines.join)[:output].to_s
  html_closing_tags = '</article></div></body></html>'

  output_file.write(html_opening_tags + stylesheet_tags + body_tags + body_content + html_closing_tags)
else
  puts "Invalid markdown file #{ARGV[0]}"
end