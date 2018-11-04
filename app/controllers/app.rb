require 'roda'
require 'slim'

module RefEm
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, path: 'app/views/assets',
                    css: 'style.css'#, js: 'table_row.js'
    plugin :halt

    route do |routing|
      routing.assets # load CSS

      # GET / 
      routing.root do
        papers = Repositories::For.klass(Entity::Project).all
        view 'home', locals: { papers: papers }
      end

      routing.on 'find_paper' do
        routing.is do
          # POST /find_paper/
          routing.post do
            query_param = routing.params['paper_query'].downcase
            # need refactor
            # paper count must be an integer, and limited to 10 papers
            # for now we only accept 2 parameters in the query
            # query format: keyword/paper count
            routing.halt 400 unless (query_param.split('/')[-1].to_i <= 10) &&
                                    (query_param.split('/').count == 2)
            keyword, paper_count = query_param.split('/')

            # Get paper from ms
            paper = MSPaper::PaperMapper
              .new(App.config.ms_TOKEN)
              .find(keywords, count)
            # Add paper to database
            Repository::For.entity(paper).create(paper)
            # Redirect viewer to find_ page
            routing.redirect "find_paper/#{keyword}/#{paper_count}"
          end
        end

        routing.on String, String do |keyword, paper_count|
          # GET /find_paper/keyword/paper_count
          routing.get do
            paper_title = RefEm::MSPaper::PaperMapper
              .new(MS_TOKEN)
              .find(keyword, paper_count)
            #puts("!!!! #{paper_title.paper_doi}")

            view 'find_paper', locals: { find_paper: paper_title }
          end
        end
      end
    end
  end
end
