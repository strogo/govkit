require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module GovKit::TransparencyData

  describe GovKit::TransparencyData do
    before(:all) do
      unless FakeWeb.allow_net_connect?
        base_uri = GovKit::TransparencyDataResource.base_uri.gsub(/\./, '\.')

        urls = [
          ['/contributions.json\?',                         'contributions.response'],
          ['/lobbying.json\?',                              'lobbyists_find_all.response'],
          ['/grants.json\?',                                'grants_find_all.response'],
          ['/entities.json\?apikey=&search=$',              'entities_search.response'],
          ['/entities.json\?apikey=&search=harry%20pelosi', 'entities_search_limit_0.response'],
          ['/entities.json\?apikey=&search=nancy%2Bpelosi', 'entities_search_limit_1.response']
        ]

        urls.each do |u|
          FakeWeb.register_uri(:get, %r|#{base_uri}#{u[0]}|, :response => File.join(FIXTURES_DIR, 'transparency_data', u[1]))
        end
      end
    end

    it "should have the base uri set properly" do
      [Contribution, Entity].each do |klass|
        klass.base_uri.should == 'http://transparencydata.com/api/1.0'
      end
    end
  end

  describe Contribution do 
    context "#search" do
      it "should find all contributions" do
        lambda do
          @contributions = Contribution.search
        end.should_not raise_error

        @contributions.length.should eql(FakeWeb.allow_net_connect? ? 1000 : 8)
        @contributions[0].contributor_city.should eql("ANCHORAGE")
      end
    end
  end
  
  describe Entity do 
    context "#search" do
      it 'should return an empty list when no elements found' do
        lambda do
          @entities = Entity.search( "harry pelosi" )
        end.should_not raise_error

        @entities.length.should eql(0)
      end
      it 'should return a list when one element found' do
        lambda do
          @entities = Entity.search( "nancy+pelosi" )
        end.should_not raise_error

        @entities.length.should eql(FakeWeb.allow_net_connect? ? 2 : 1)
      end
    end
  end
  
  describe LobbyingRecord do 
    context "#search" do
      it "should find all contributions" do
        lambda do
          @records = LobbyingRecord.search
        end.should_not raise_error

        @records.length.should eql(FakeWeb.allow_net_connect? ? 1000 : 5)
        @records[0].lobbyists[0].lobbyist_name.should eql('Dunn, Jennifer B')
      end
    end
  end

  describe Grant do 
    context "#search" do
      it "should find all contributions" do
        lambda do
          @records = Grant.search
        end.should_not raise_error

        @records.length.should eql(FakeWeb.allow_net_connect? ? 1000 : 3)
        @records[0].project_description.should eql('NATIONAL FLOOD INSURANCE PROGRAM')
      end
    end
  end
end

