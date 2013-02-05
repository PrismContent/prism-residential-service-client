require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ResidentialService::OfficeHour do
  before :all do
    @account_id = 1
    clear_office_hours
  end

  after :all do
    clear_office_hours
  end

  before :each do
    @valid_attributes = {
      purpose:    'Breakfast at Stax Omega',
      recurrence: 'weekly',
      account_id: @account_id,
      ordinals:   '1',
      starting_on:  65.days.ago.to_date,
      starting_at:  8.hours.since(Time.now.beginning_of_day),
      ending_at:    9.hours.since(Time.now.beginning_of_day)
    }
  end

  describe '.new' do
    before :each do
      @office_hour = ResidentialService::OfficeHour.new @valid_attributes
    end

    subject{ @office_hour }

    it{should be_a_kind_of(ResidentialService::OfficeHour) }

    it "should set all the attributes based on the supplied hash" do
      @valid_attributes.each{|attr_id, val| @office_hour.send(attr_id).should eql val }
    end
  end

  describe '.create' do
    before :each do
      clear_office_hours
      @office_hour = ResidentialService::OfficeHour.create @valid_attributes
    end

    it "should return an instance of the OfficeHour" do
      @office_hour.should be_a_kind_of(ResidentialService::OfficeHour)
    end

    it "should persist the supplied attributes" do
      @valid_attributes.each{|attr_id, val| @office_hour.send(attr_id).should eql val }
    end

    it "should be assigned an id" do
      @office_hour.id.should_not be_blank
    end

    context "when a required parameter is missing" do
      before :each do
        @office_hour = ResidentialService::OfficeHour.create @valid_attributes.except(:purpose)
      end

      it "should still be new record" do
        @office_hour.should be_new_record
      end

      it "should have a collection of errors" do
        @office_hour.errors.should_not be_empty
      end
    end
  end

  describe '.find' do
    before :each do
      clear_office_hours
      @office_hour = ResidentialService::OfficeHour.create @valid_attributes
    end

    context "when supplied only the account_id" do
      it "should return an enumerable object" do
        office_hours = ResidentialService::OfficeHour.find( @office_hour.account_id )
        office_hours.should be_a_kind_of(Array)
      end

      it "should contain only OfficeHour objects" do
        office_hours = ResidentialService::OfficeHour.find( @office_hour.account_id )
        office_hours.all?{|office_hour| office_hour.is_a?(ResidentialService::OfficeHour)}.should eql true
      end
    end

    context "when supplied both account_id and office_hour_id" do
      context "and the OfficeHour exists" do
        it "should return an instance of OfficeHour" do
          office_hour = ResidentialService::OfficeHour.find( @office_hour.account_id, @office_hour.id )
          office_hour.should be_a_kind_of(ResidentialService::OfficeHour)
        end

        it "should have a starting_on attribute that is a Date" do
          office_hour = ResidentialService::OfficeHour.find( @office_hour.account_id, @office_hour.id )
          office_hour.starting_on.should be_a_kind_of(Date)
        end

        [:starting_at, :ending_at].each do |attr_id|
          it "should have a #{attr_id} attribute that is a Date" do
            office_hour = ResidentialService::OfficeHour.find( @office_hour.account_id, @office_hour.id )
            office_hour.send(attr_id).should be_a_kind_of(Time)
          end
        end

        it "should return all the persisted attributes" do
          @valid_attributes.each{|attr_id, val| @office_hour.send(attr_id).should eql val }
        end
      end

      context "and the OfficeHour does not exist" do
        it "should return nil" do
          office_hour = ResidentialService::OfficeHour.find( @office_hour.account_id, @office_hour.id+1 )
          office_hour.should be_nil
        end
      end
    end
  end

  describe '#save' do
    context "with a new record" do
      before :each do
        clear_office_hours
        @office_hour = ResidentialService::OfficeHour.new @valid_attributes
        @office_hour.should be_new_record
      end

      subject{ @office_hour.save }
    
      it{ should eql true }

      it "should set the id of the receiver to the value returned from the service" do
        @office_hour.save
        @office_hour.id.should_not be_blank
      end
    end

    context "with an existing record" do
      before :each do
        clear_office_hours
        @office_hour = ResidentialService::OfficeHour.create @valid_attributes
        @office_hour.should_not be_new_record

        @office_hour.purpose = @office_hour.purpose.reverse
      end

      subject{ @office_hour.save }
    
      it{ should eql true }

      it "should not assign a new id to the instance" do
        lambda{ @office_hour.save }.should_not change(@office_hour, :id)
      end
    end
  end

  describe '#new_record?' do
    subject{ @office_hour.new_record? }

    before :each do
      clear_office_hours
      @office_hour = ResidentialService::OfficeHour.new @valid_attributes
    end

    context "before save" do
      it{ should eql true }
    end

    context "after save" do
      before :each do
        @office_hour.save
      end

      it{ should eql false }
    end
  end

  describe '#destroy' do
    context 'with a new record' do
      before :each do
        @office_hour = ResidentialService::OfficeHour.new @valid_attributes
        @office_hour.should be_new_record
      end

      it "should be false" do
        @office_hour.destroy.should eql false
      end
    end

    context 'with a persisted record' do
      before :each do
        clear_office_hours
        @office_hour = ResidentialService::OfficeHour.create @valid_attributes
        @office_hour.should_not be_new_record
      end

      it "should be true" do
        @office_hour.destroy.should eql true
      end

      it "should remove the OfficeHour" do
        @office_hour.destroy
        ResidentialService::OfficeHour.find(@office_hour.account_id, @office_hour.id).should be_nil
      end
    end
  end

  describe '.delete_all' do
    before :all do
      @account_id = 1
      ResidentialService::OfficeHour.create account_id: @account_id, purpose: 'First', recurrence: 'weekly', ordinals: '5', starting_on: Date.yesterday, starting_at: Time.now
      ResidentialService::OfficeHour.create account_id: @account_id, purpose: 'Middle', recurrence: 'weekly', ordinals: '2', starting_on: Date.yesterday, starting_at: Time.now
      ResidentialService::OfficeHour.create account_id: @account_id, purpose: 'Last', recurrence: 'monthly', ordinals: '1,15', starting_on: Date.yesterday, starting_at: Time.now
    end

    subject{ OfficeHour.delete_all @account_id }
    context "when an account_id is not provided" do
      it{ lambda{ ResidentialService::OfficeHour.delete_all }.should raise_error }
    end

    context "when an account_id with one or more OfficeHours is provided" do
      before :each do
        ResidentialService::OfficeHour.find(@account_id).size.should_not be_zero
      end

      it "should delete all the OfficeHours on the supplied account_id" do
        ResidentialService::OfficeHour.delete_all @account_id
        ResidentialService::OfficeHour.find(@account_id).size.should be_zero
      end
    end
  end

  def clear_office_hours
    ResidentialService::OfficeHour.delete_all 1
  end
end
