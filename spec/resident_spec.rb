require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ResidentialService::Resident do
  before :all do
    clear_residents
  end

  after :all do
    clear_residents
  end

  before :each do
    @valid_attributes = {
      account_id:   1,
      first_name:   'Adam',
      last_name:    'Shirley',
      born_on:      '1970-01-17'.to_date,
      email:        'adam.shirley@prismcontent.com',
      spouse_name:  'LeGette Shirley'
    }
  end

  describe '.new' do
    before :each do
      @resident = ResidentialService::Resident.new @valid_attributes
    end

    subject{ @resident }

    it{should be_a_kind_of(ResidentialService::Resident) }

    it "should set all the attributes based on the supplied hash" do
      @valid_attributes.each{|attr_id, val| @resident.send(attr_id).should eql val }
    end
  end

  describe '.create' do
    before :each do
      clear_residents
      @resident = ResidentialService::Resident.create @valid_attributes
    end

    it "should return an instance of the Resident" do
      @resident.should be_a_kind_of(ResidentialService::Resident)
    end

    it "should persist the supplied attributes" do
      @valid_attributes.each{|attr_id, val| @resident.send(attr_id).should eql val }
    end

    it "should be assigned an id" do
      @resident.id.should_not be_blank
    end

    context "when a required parameter is missing" do
      before :each do
        @resident = ResidentialService::Resident.create @valid_attributes.except(:first_name)
      end

      it "should still be new record" do
        @resident.should be_new_record
      end

      it "should have a collection of errors" do
        @resident.errors.should_not be_empty
      end
    end
  end

  describe '.find' do
    before :each do
      clear_residents
      @resident = ResidentialService::Resident.create @valid_attributes
    end

    context "when supplied only the account_id" do
      it "should return an enumerable object" do
        residents = ResidentialService::Resident.find( @resident.account_id )
        residents.should be_a_kind_of(Array)
      end

      it "should contain only Resident objects" do
        residents = ResidentialService::Resident.find( @resident.account_id )
        residents.all?{|resident| resident.is_a?(ResidentialService::Resident)}.should eql true
      end
    end

    context "when supplied both account_id and resident_id" do
      context "and the Resident exists" do
        it "should return an instance of Resident" do
          resident = ResidentialService::Resident.find( @resident.account_id, @resident.id )
          resident.should be_a_kind_of(ResidentialService::Resident)
        end

        it "should return all the persisted attributes" do
          @valid_attributes.each{|attr_id, val| @resident.send(attr_id).should eql val }
        end
      end

      context "and the Resident does not exist" do
        it "should return nil" do
          resident = ResidentialService::Resident.find( @resident.account_id, @resident.id+1 )
          resident.should be_nil
        end
      end
    end
  end

  describe '#save' do
    context "with a new record" do
      before :each do
        clear_residents
        @resident = ResidentialService::Resident.new @valid_attributes
        @resident.should be_new_record
      end

      subject{ @resident.save }
    
      it{ should eql true }

      it "should set the id of the receiver to the value returned from the service" do
        @resident.save
        @resident.id.should_not be_blank
      end
    end

    context "with an existing record" do
      before :each do
        clear_residents
        @resident = ResidentialService::Resident.create @valid_attributes
        @resident.should_not be_new_record

        @resident.first_name = @resident.first_name.reverse
      end

      subject{ @resident.save }
    
      it{ should eql true }

      it "should not assign a new id to the instance" do
        lambda{ @resident.save }.should_not change(@resident, :id)
      end
    end
  end

  describe '#new_record?' do
    subject{ @resident.new_record? }

    before :each do
      clear_residents
      @resident = ResidentialService::Resident.new @valid_attributes
    end

    context "before save" do
      it{ should eql true }
    end

    context "after save" do
      before :each do
        @resident.save
      end

      it{ should eql false }
    end
  end

  describe '#destroy' do
    context 'with a new record' do
      before :each do
        @resident = ResidentialService::Resident.new @valid_attributes
        @resident.should be_new_record
      end

      it "should be false" do
        @resident.destroy.should eql false
      end
    end

    context 'with a persisted record' do
      before :each do
        clear_residents
        @resident = ResidentialService::Resident.create @valid_attributes
        @resident.should_not be_new_record
      end

      it "should be true" do
        @resident.destroy.should eql true
      end

      it "should remove the Resident" do
        @resident.destroy
        ResidentialService::Resident.find(@resident.account_id, @resident.id).should be_nil
      end
    end
  end

  def clear_residents
    ResidentialService::Resident.find(1).each{|resident| resident.destroy }
  end
end
