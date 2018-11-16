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
        papers = Repository::For.klass(Entity::Paper).all
        view 'home', locals: { papers: papers }
      end

      routing.on 'find_paper' do
        routing.is do
          # POST /find_paper/
          routing.post do
            keyword = routing.params['paper_query'].downcase
            # need refactor
            # for now we only accept 1 parameter in the query
            # query format: keyword

            # Get paper from ms
            paper = MSPaper::PaperMapper
              .new(App.config.MS_TOKEN)
              .find_papers_by_keywords(keyword)

            view 'find_paper', locals: { find_paper: paper, keyword: keyword }
          end
        end

        routing.on String do |keyword|
          # GET /find_paper/keyword/paper_count
          routing.get do
            paper_title = RefEm::MSPaper::PaperMapper
              .new(App.config.MS_TOKEN)
              .find_papers_by_keywords(keyword)

            paper = Repository::For.klass(Entity::Paper)
              .find_papers_by_keywords(owner_name, project_name)

            view 'find_paper', locals: { find_paper: paper_title, keyword: keyword }
          end
        end
      end
      routing.on 'paper_content' do
        routing.on String, String do |keyword, id|
          routing.get do

            paper = Entity::Paper

            find_paper = MSPaper::PaperMapper
              .new(App.config.MS_TOKEN)
              .find_paper(id)

            find_paper.each do |p|
              paper = p if p.origin_id == id.to_i
            end

            # Add paper to database
            Repository::For.entity(paper).create(paper)

            paper_find_from_database = Repository::For.klass(Entity::Paper)
              .find_paper_content(id)

            view 'paper_content', locals: { paper_content: paper_find_from_database }
          end
        end
      end
    end
  end
end
