module Jekyll
    module Plugins
      class HighlightCaption < Liquid::Block
        include Liquid::StandardFilters
  
        def initialize(tag_name, markup, tokens)
          super
          options = markup.split(" ")
          if options.length >= 1
            @lang = options[0]
            if options.length >= 2
              if options[1] == "linenos"
                @linenos = true
                @caption = get_caption(options, 2)
              else
                @caption = get_caption(options, 1)
              end
            end
          else
            raise SyntaxError, <<-eos
Syntax Error in tag 'highlight_cap' while parsing the following markup:

  #{markup}

Valid syntax: highlight_cap <lang> [linenos] [caption]
eos
          end
        end

        def render(context)
          prefix = context["highlighter_prefix"] || ""
          suffix = context["highlighter_suffix"] || ""
          code = super.to_s.gsub(%r!\A(\n|\r)+|(\n|\r)+\z!, "")
  
          output = render_rouge(code)
          rendered_output = add_code_tag(output)
          prefix + rendered_output + suffix
        end
  
        private
  
        def render_rouge(code)
          Jekyll::External.require_with_graceful_fail("rouge")
          formatter = Rouge::Formatters::HTML.new(
            :line_numbers => @linenos,
            :wrap         => false
          )
          lexer = Rouge::Lexer.find_fancy(@lang, code) || Rouge::Lexers::PlainText
          formatter.format(lexer.lex(code))
        end

        def get_caption(options, index)
          if index < options.length 
            caption = options[index..-1].join(' ').delete_prefix('"').delete_suffix('"')
            caption
          end
        end
  
        def add_code_tag(code)
          code_attributes = [
            "class=\"language-#{@lang.to_s.tr("+", "-")}\"",
            "data-lang=\"#{@lang}\""
          ].join(" ")
  
          res = "<figure class=\"highlight\">"
          res += "<pre><code #{code_attributes}>#{code.chomp}</code></pre>"
          if @caption
            res += "<figcaption class=\"caption\">#{@caption}</figcaption>" 
          end
          res += "</figure>"
          res
        end
      end
    end
  end
  
  Liquid::Template.register_tag("highlight_cap", Jekyll::Plugins::HighlightCaption)