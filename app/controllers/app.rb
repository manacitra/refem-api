require 'roda'
require 'slim/include'

module RefEm
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css' # js: 'table_row.js'
    plugin :halt
    plugin :flash

    route do |routing|
      routing.assets # load CSS

      # GET /
      routing.root do
        papers = Repository::For.klass(Entity::Paper).all
        view 'home', locals: { papers: papers }
      end

      routing.on 'find_paper' do
        routing.is do
          # POST /find_paper/
          routing.post do
            # need refactor
            # for now we only accept 1 parameter in the query
            # query format: keyword
            # Redirect viewer to project page
            keyword = routing.params['paper_query'].downcase
            
            if keyword == '' || keyword == nil
              flash[:error] = 'Please enter the keyword!'
              routing.redirect '/'
            end

            routing.redirect "find_paper/#{keyword}"
          end

          # GET /find_paper/
          routing.get do
            flash[:error] = 'Please enter the keyword!'
            routing.redirect '/'
          end
        end

        routing.on String do |keyword|
            
          # Get paper from ms
          begin
            paper = MSPaper::PaperMapper
              .new(App.config.MS_TOKEN)
              .find_papers_by_keywords(keyword)

            if paper == []
              flash[:error] = 'Paper not found'
              routing.redirect '/'
            end
          rescue StandardError
            flash[:error] = 'Having trouble to get papers'
            routing.redirect '/'
          end

          viewable_papers = Views::PaperList.new(paper, keyword)

          view "find_paper", locals: { papers: viewable_papers, keyword: keyword }
        end
      end
      routing.on 'paper_content' do
        routing.on String, String do |keyword, id|
          routing.get do
            # Get paper from database instead of Microsoft Acadamic
            begin
              paper = Repository::For.klass(Entity::Paper)
                .find_paper_content(id)

              if paper.nil?
                # Get paper from Microsoft Acadamic
                begin
                  paper = Entity::Paper

                  find_paper = MSPaper::PaperMapper
                    .new(App.config.MS_TOKEN)
                    .find_paper(id)
                  # take the paper that user want to find
                  paper = find_paper[0]

                  if paper == []
                    flash[:error] = 'This paper has some errors, please find another one!'
                    routing.redirect "paper_count/#{keyword}/#{id}"
                  end
                rescue StandardError
                  flash[:error] = 'Having trouble to get the paper detail'
                  routing.redirect "paper_count/#{keyword}/#{id}"
                end

                # Add paper to database
                begin
                  Repository::For.entity(paper).create(paper)
                rescue StandardError => error
                  puts error.backtrace.join("\n")
                  flash[:error] = 'Having trouble accessing the database'
                end
              end
            rescue StandardError
              flash[:error] = 'Having trouble accessing the database'
              routing.redirect '/'
            end

            viewable_paper = Views::Paper.new(paper, keyword)

            view 'paper_content', locals: { paper: viewable_paper }
          end
        end
      end
    end
  end
end
