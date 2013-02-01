require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ResidentialService::StaffPosition do
  before :all do
    clear_staff_positions
  end

  after :all do
    clear_staff_positions
  end

  before :each do
    @valid_attributes = {
      name:       'President',
      sortable:   false,
      account_id: 1
    }
  end

  describe '.new' do
    before :each do
      @staff_position = ResidentialService::StaffPosition.new @valid_attributes
    end

    subject{ @staff_position }

    it{should be_a_kind_of(ResidentialService::StaffPosition) }

    it "should set all the attributes based on the supplied hash" do
      @valid_attributes.each{|attr_id, val| @staff_position.send(attr_id).should eql val }
    end
  end

  describe '.create' do
    before :each do
      clear_staff_positions
      @staff_position = ResidentialService::StaffPosition.create @valid_attributes
    end

    it "should return an instance of the StaffPosition" do
      @staff_position.should be_a_kind_of(ResidentialService::StaffPosition)
    end

    it "should persist the supplied attributes" do
      @valid_attributes.each{|attr_id, val| @staff_position.send(attr_id).should eql val }
    end

    it "should be assigned an id" do
      @staff_position.id.should_not be_blank
    end

    it "should be assigned a position in the list" do
      @staff_position.position.should_not be_blank
    end

    context "when a required parameter is missing" do
      before :each do
        @staff_position = ResidentialService::StaffPosition.create @valid_attributes.except(:name)
      end

      it "should still be new record" do
        @staff_position.should be_new_record
      end

      it "should have a collection of errors" do
        @staff_position.errors.should_not be_empty
      end
    end
  end

  describe '.find' do
    before :each do
      clear_staff_positions
      @staff_position = ResidentialService::StaffPosition.create @valid_attributes
    end

    context "when supplied only the account_id" do
      it "should return an enumerable object" do
        staff_positions = ResidentialService::StaffPosition.find( @staff_position.account_id )
        staff_positions.should be_a_kind_of(Array)
      end

      it "should contain only StaffPosition objects" do
        staff_positions = ResidentialService::StaffPosition.find( @staff_position.account_id )
        staff_positions.all?{|staff_position| staff_position.is_a?(ResidentialService::StaffPosition)}.should eql true
      end
    end

    context "when supplied both account_id and staff_position_id" do
      context "and the StaffPosition exists" do
        it "should return an instance of StaffPosition" do
          staff_position = ResidentialService::StaffPosition.find( @staff_position.account_id, @staff_position.id )
          staff_position.should be_a_kind_of(ResidentialService::StaffPosition)
        end

        it "should return all the persisted attributes" do
          @valid_attributes.each{|attr_id, val| @staff_position.send(attr_id).should eql val }
        end
      end

      context "and the StaffPosition does not exist" do
        it "should return nil" do
          staff_position = ResidentialService::StaffPosition.find( @staff_position.account_id, @staff_position.id+1 )
          staff_position.should be_nil
        end
      end
    end
  end

  describe '#save' do
    context "with a new record" do
      before :each do
        clear_staff_positions
        @staff_position = ResidentialService::StaffPosition.new @valid_attributes
        @staff_position.should be_new_record
      end

      subject{ @staff_position.save }
    
      it{ should eql true }

      it "should set the id of the receiver to the value returned from the service" do
        @staff_position.save
        @staff_position.id.should_not be_blank
      end
    end

    context "with an existing record" do
      before :each do
        clear_staff_positions
        @staff_position = ResidentialService::StaffPosition.create @valid_attributes
        @staff_position.should_not be_new_record

        @staff_position.name = @staff_position.name.reverse
      end

      subject{ @staff_position.save }
    
      it{ should eql true }

      it "should not assign a new id to the instance" do
        lambda{ @staff_position.save }.should_not change(@staff_position, :id)
      end
    end
  end

  describe '#new_record?' do
    subject{ @staff_position.new_record? }

    before :each do
      clear_staff_positions
      @staff_position = ResidentialService::StaffPosition.new @valid_attributes
    end

    context "before save" do
      it{ should eql true }
    end

    context "after save" do
      before :each do
        @staff_position.save
      end

      it{ should eql false }
    end
  end

  describe '#destroy' do
    context 'with a new record' do
      before :each do
        @staff_position = ResidentialService::StaffPosition.new @valid_attributes
        @staff_position.should be_new_record
      end

      it "should be false" do
        @staff_position.destroy.should eql false
      end
    end

    context 'with a persisted record' do
      before :each do
        clear_staff_positions
        @staff_position = ResidentialService::StaffPosition.create @valid_attributes
        @staff_position.should_not be_new_record
      end

      it "should be true" do
        @staff_position.destroy.should eql true
      end

      it "should remove the StaffPosition" do
        @staff_position.destroy
        ResidentialService::StaffPosition.find(@staff_position.account_id, @staff_position.id).should be_nil
      end
    end
  end

  describe '#move' do
    context "when the StaffPosition exists" do
      before :each do
        clear_staff_positions
        ResidentialService::StaffPosition.create @valid_attributes.merge(name: 'First', sortable: true)
        @staff_position = ResidentialService::StaffPosition.create @valid_attributes.merge(sortable: true)
        ResidentialService::StaffPosition.create @valid_attributes.merge(name: 'Last', sortable: true)
      end

      after :each do
        clear_staff_positions
      end

      context 'with the direction higher' do
        it "should decrement the position by one" do
          lambda{ @staff_position.move :higher }.should change(@staff_position, :position).by(-1)
        end
      end

      context 'with the direction lower' do
        it "should increment the position by one" do
          lambda{ @staff_position.move :lower }.should change(@staff_position, :position).by(1)
        end
      end

      context 'with the direction top' do
        before :each do
          @staff_position = ResidentialService::StaffPosition.create @valid_attributes.merge(name: 'Dead Last')
        end

        it "should increment the position by one" do
          lambda{ @staff_position.move :top }.should change(@staff_position, :position).to(1)
        end
      end

      context 'with the direction bottom' do
        before :each do
          @staff_position = ResidentialService::StaffPosition.find @staff_position.account_id, @staff_position.id-1
        end

        it "should increment the position by one" do
          expected_position = ResidentialService::StaffPosition.find(@staff_position.account_id).size
          lambda{ @staff_position.move :bottom }.should change(@staff_position, :position).to(expected_position)
        end
      end
    end
  end

  def clear_staff_positions
    ResidentialService::StaffPosition.find(1).each{|staff_position| staff_position.destroy }
  end
end
