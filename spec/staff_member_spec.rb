require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ResidentialService::StaffMember do
  before :all do
    build_staff_positions
  end

  after :all do
    clear_staff_positions
  end

  before :each do
    clear_staff_members

    @valid_attributes = {
      account_id:   1,
      first_name:   'Adam',
      last_name:    'Shirley',
      staff_position_id: @president.id 
    }
  end

  after :each do
    clear_staff_members
  end

  describe '.new' do
    before :each do
      @staff_member = ResidentialService::StaffMember.new @valid_attributes
    end

    subject{ @staff_member }

    it{should be_a_kind_of(ResidentialService::StaffMember) }

    it "should set all the attributes based on the supplied hash" do
      @valid_attributes.each{|attr_id, val| @staff_member.send(attr_id).should eql val }
    end
  end

  describe '.create' do
    before :each do
      clear_staff_members
      @staff_member = ResidentialService::StaffMember.create @valid_attributes
    end

    it "should return an instance of the StaffMember" do
      @staff_member.should be_a_kind_of(ResidentialService::StaffMember)
    end

    it "should persist the supplied attributes" do
      @valid_attributes.each{|attr_id, val| @staff_member.send(attr_id).should eql val }
    end

    it "should be assigned an id" do
      @staff_member.id.should_not be_blank
    end

    it "should be assigned a position" do
      @staff_member.position.should_not be_blank
    end

    context "when a required parameter is missing" do
      before :each do
        @staff_member = ResidentialService::StaffMember.create @valid_attributes.except(:first_name)
      end

      it "should still be new record" do
        @staff_member.should be_new_record
      end

      it "should have a collection of errors" do
        @staff_member.errors.should_not be_empty
      end
    end
  end

  describe '.find' do
    before :each do
      clear_staff_members
      @staff_member = ResidentialService::StaffMember.create @valid_attributes
    end

    context "when supplied only the account_id" do
      it "should return an enumerable object" do
        staff_members = ResidentialService::StaffMember.find( @staff_member.account_id )
        staff_members.should be_a_kind_of(Array)
      end

      it "should contain only StaffMember objects" do
        staff_members = ResidentialService::StaffMember.find( @staff_member.account_id )
        staff_members.all?{|staff_member| staff_member.is_a?(ResidentialService::StaffMember)}.should eql true
      end
    end

    context "when supplied both account_id and staff_member_id" do
      context "and the StaffMember exists" do
        it "should return an instance of StaffMember" do
          staff_member = ResidentialService::StaffMember.find( @staff_member.account_id, @staff_member.id )
          staff_member.should be_a_kind_of(ResidentialService::StaffMember)
        end

        it "should return all the persisted attributes" do
          @valid_attributes.each{|attr_id, val| @staff_member.send(attr_id).should eql val }
        end
      end

      context "and the StaffMember does not exist" do
        it "should return nil" do
          staff_member = ResidentialService::StaffMember.find( @staff_member.account_id, @staff_member.id+1 )
          staff_member.should be_nil
        end
      end
    end
  end

  describe '#save' do
    context "with a new record" do
      before :each do
        clear_staff_members
        @staff_member = ResidentialService::StaffMember.new @valid_attributes
        @staff_member.should be_new_record
      end

      subject{ @staff_member.save }
    
      it{ should eql true }

      it "should set the id of the receiver to the value returned from the service" do
        @staff_member.save
        @staff_member.id.should_not be_blank
      end
    end

    context "with an existing record" do
      before :each do
        clear_staff_members
        @staff_member = ResidentialService::StaffMember.create @valid_attributes
        @staff_member.should_not be_new_record

        @staff_member.first_name = @staff_member.first_name.reverse
      end

      subject{ @staff_member.save }
    
      it{ should eql true }

      it "should not assign a new id to the instance" do
        lambda{ @staff_member.save }.should_not change(@staff_member, :id)
      end
    end
  end

  describe '#new_record?' do
    subject{ @staff_member.new_record? }

    before :each do
      clear_staff_members
      @staff_member = ResidentialService::StaffMember.new @valid_attributes
    end

    context "before save" do
      it{ should eql true }
    end

    context "after save" do
      before :each do
        @staff_member.save
      end

      it{ should eql false }
    end
  end

  describe '#destroy' do
    context 'with a new record' do
      before :each do
        @staff_member = ResidentialService::StaffMember.new @valid_attributes
        @staff_member.should be_new_record
      end

      it "should be false" do
        @staff_member.destroy.should eql false
      end
    end

    context 'with a persisted record' do
      before :each do
        clear_staff_members
        @staff_member = ResidentialService::StaffMember.create @valid_attributes
        @staff_member.should_not be_new_record
      end

      it "should be true" do
        @staff_member.destroy.should eql true
      end

      it "should remove the StaffMember" do
        @staff_member.destroy
        ResidentialService::StaffMember.find(@staff_member.account_id, @staff_member.id).should be_nil
      end
    end
  end

  describe '.delete_all' do
    before :each do
      @account_id = 1
      build_staff_positions
      ResidentialService::StaffMember.create @valid_attributes.merge( account_id: @account_id, first_name: 'First', staff_position_id: @secretary.id )
      ResidentialService::StaffMember.create @valid_attributes.merge( account_id: @account_id, staff_position_id: @secretary.id )
      ResidentialService::StaffMember.create @valid_attributes.merge( account_id: @account_id, first_name: 'Last',  staff_position_id: @secretary.id )
    end

    after :each do
      clear_staff_members
    end

    subject{ StaffMember.delete_all @account_id }
    context "when an account_id is not provided" do
      it{ lambda{ ResidentialService::StaffMember.delete_all }.should raise_error }
    end

    context "when an account_id with one or more StaffMembers is provided" do
      before :each do
        ResidentialService::StaffMember.find(@account_id).should_not be_empty
      end

      it "should delete all the StaffMembers on the supplied account_id" do
        ResidentialService::StaffMember.delete_all @account_id
        ResidentialService::StaffMember.find(@account_id).should be_empty
      end
    end
  end

  describe '#move' do
    context "when the StaffMember exists" do
      before :each do
        build_staff_positions
        clear_staff_members
        ResidentialService::StaffMember.create @valid_attributes.merge( first_name: 'First', staff_position_id: @secretary.id )
        @staff_position = ResidentialService::StaffMember.create @valid_attributes.merge( staff_position_id: @secretary.id )
        ResidentialService::StaffMember.create @valid_attributes.merge( first_name: 'Last',  staff_position_id: @secretary.id )
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
          @staff_position = ResidentialService::StaffMember.create @valid_attributes.merge(name: 'Dead Last', staff_position_id: @secretary.id)
        end

        it "should increment the position by one" do
          lambda{ @staff_position.move :top }.should change(@staff_position, :position).to(1)
        end
      end

      context 'with the direction bottom' do
        before :each do
          @staff_position = ResidentialService::StaffMember.find @staff_position.account_id, @staff_position.id-1
        end

        it "should increment the position by one" do
          expected_position = ResidentialService::StaffMember.find(@staff_position.account_id).size
          lambda{ @staff_position.move :bottom }.should change(@staff_position, :position).to(expected_position)
        end
      end
    end
  end

  def clear_staff_members
    ResidentialService::StaffMember.find(1).each{|staff_member| staff_member.destroy }
  end

  def build_staff_positions
    clear_staff_positions
    @president = ResidentialService::StaffPosition.create account_id: 1, name: 'President', sortable: false
    @vp = ResidentialService::StaffPosition.create account_id: 1, name: 'Vice President', sortable: true
    @secretary = ResidentialService::StaffPosition.create account_id: 1, name: 'Secretary', sortable: false
  end

  def clear_staff_positions
    ResidentialService::StaffPosition.delete_all 1
  end
end
