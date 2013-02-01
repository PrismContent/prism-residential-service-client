require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ResidentialService::Location do
  before :all do
    clear_locations
  end

  after :all do
    clear_locations
  end

  before :each do
    @valid_attributes = {
      name:       'Breakfast',
      code:       'BRK',
      account_id: 1
    }
  end

  describe '.new' do
    before :each do
      @location = ResidentialService::Location.new @valid_attributes
    end

    subject{ @location }

    it{should be_a_kind_of(ResidentialService::Location) }

    it "should set all the attributes based on the supplied hash" do
      @valid_attributes.each{|attr_id, val| @location.send(attr_id).should eql val }
    end
  end

  describe '.create' do
    before :each do
      clear_locations
      @location = ResidentialService::Location.create @valid_attributes
    end

    it "should return an instance of the Location" do
      @location.should be_a_kind_of(ResidentialService::Location)
    end

    it "should persist the supplied attributes" do
      @valid_attributes.each{|attr_id, val| @location.send(attr_id).should eql val }
    end

    it "should be assigned an id" do
      @location.id.should_not be_blank
    end

    context "when a required parameter is missing" do
      before :each do
        @location = ResidentialService::Location.create @valid_attributes.except(:name)
      end

      it "should still be new record" do
        @location.should be_new_record
      end

      it "should have a collection of errors" do
        @location.errors.should_not be_empty
      end
    end
  end

  describe '.find' do
    before :each do
      clear_locations
      @location = ResidentialService::Location.create @valid_attributes
    end

    context "when supplied only the account_id" do
      it "should return an enumerable object" do
        locations = ResidentialService::Location.find( @location.account_id )
        locations.should be_a_kind_of(Array)
      end

      it "should contain only Location objects" do
        locations = ResidentialService::Location.find( @location.account_id )
        locations.all?{|location| location.is_a?(ResidentialService::Location)}.should eql true
      end
    end

    context "when supplied both account_id and location_id" do
      context "and the Location exists" do
        it "should return an instance of Location" do
          location = ResidentialService::Location.find( @location.account_id, @location.id )
          location.should be_a_kind_of(ResidentialService::Location)
        end

        it "should return all the persisted attributes" do
          @valid_attributes.each{|attr_id, val| @location.send(attr_id).should eql val }
        end
      end

      context "and the Location does not exist" do
        it "should return nil" do
          location = ResidentialService::Location.find( @location.account_id, @location.id+1 )
          location.should be_nil
        end
      end
    end
  end

  describe '#save' do
    context "with a new record" do
      before :each do
        clear_locations
        @location = ResidentialService::Location.new @valid_attributes
        @location.should be_new_record
      end

      subject{ @location.save }
    
      it{ should eql true }

      it "should set the id of the receiver to the value returned from the service" do
        @location.save
        @location.id.should_not be_blank
      end
    end

    context "with an existing record" do
      before :each do
        clear_locations
        @location = ResidentialService::Location.create @valid_attributes
        @location.should_not be_new_record

        @location.name = @location.name.reverse
      end

      subject{ @location.save }
    
      it{ should eql true }

      it "should not assign a new id to the instance" do
        lambda{ @location.save }.should_not change(@location, :id)
      end
    end
  end

  describe '#new_record?' do
    subject{ @location.new_record? }

    before :each do
      clear_locations
      @location = ResidentialService::Location.new @valid_attributes
    end

    context "before save" do
      it{ should eql true }
    end

    context "after save" do
      before :each do
        @location.save
      end

      it{ should eql false }
    end
  end

  describe '#destroy' do
    context 'with a new record' do
      before :each do
        @location = ResidentialService::Location.new @valid_attributes
        @location.should be_new_record
      end

      it "should be false" do
        @location.destroy.should eql false
      end
    end

    context 'with a persisted record' do
      before :each do
        clear_locations
        @location = ResidentialService::Location.create @valid_attributes
        @location.should_not be_new_record
      end

      it "should be true" do
        @location.destroy.should eql true
      end

      it "should remove the Location" do
        @location.destroy
        ResidentialService::Location.find(@location.account_id, @location.id).should be_nil
      end
    end
  end

  def clear_locations
    ResidentialService::Location.find(1).each{|location| location.destroy }
  end
end
