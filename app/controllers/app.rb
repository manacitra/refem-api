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
            query_param = routing.params['paper_query'].downcase
            # need refactor
            # paper count must be an integer, and limited to 10 papers
            # for now we only accept 2 parameters in the query
            # query format: keyword/paper count
            routing.halt 400 unless (query_param.split('/')[-1].to_i <= 10) &&
                                    (query_param.split('/').count == 2)
            keyword, count = query_param.split('/')

            # Get paper from ms
            paper = MSPaper::PaperMapper
              .new(App.config.MS_TOKEN)
              .find_full_paper(keyword, count)

            puts "papar length: #{paper.length}"

            # Add paper to database
            # paper.each {  |p|
            #   Repository::For.entity(p).create(p)
            # }
            
            # reference = MSPaper::ReferenceMapper
            #   .new(App.config.MS_TOKEN)
            #   .find_several(paper[0].ref_to_array)


            # # Add reference to database
            # reference.each {  |r|
            #   Repository::For.entity(r).create(r)
            # }
           
            # Redirect viewer to find_ page
            # routing.redirect "find_paper/#{keyword}/#{count}"
            view 'find_paper', locals: { find_paper: paper, keyword: keyword }
          end
        end

        routing.on String, String do |keyword, count|
          # GET /find_paper/keyword/paper_count
          routing.get do
            paper_title = RefEm::MSPaper::PaperMapper
              .new(App.config.MS_TOKEN)
              .find_full_paper(keyword, count)

            paper = Repository::For.klass(Entity::Paper)
              .find_full_paper(owner_name, project_name)
            
            #puts("!!!! #{paper_title.paper_doi}")

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

            find_citation = MSPaper::CitationMapper.new
            .find_data_by(paper.doi)

            paper.citations = find_citation

            # Add paper to database
            Repository::For.entity(paper).create(paper)

            paper_find_from_database = Repository::For.klass(Entity::Paper)
              .find_paper_content(id)


            view 'paper_content', locals: { paper_content: paper_find_from_database  }
          end
        end
      end
    end
  end
end
