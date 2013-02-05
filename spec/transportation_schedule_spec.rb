require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ResidentialService::TransportationSchedule do
  before :all do
    @account_id = 1
    clear_transportation_schedules
  end

  after :all do
    clear_transportation_schedules
  end

  before :each do
    @valid_attributes = {
      destination:    'Breakfast at Stax Omega',
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
      @transportation_schedule = ResidentialService::TransportationSchedule.new @valid_attributes
    end

    subject{ @transportation_schedule }

    it{should be_a_kind_of(ResidentialService::TransportationSchedule) }

    it "should set all the attributes based on the supplied hash" do
      @valid_attributes.each{|attr_id, val| @transportation_schedule.send(attr_id).should eql val }
    end
  end

  describe '.create' do
    before :each do
      clear_transportation_schedules
      @transportation_schedule = ResidentialService::TransportationSchedule.create @valid_attributes
    end

    it "should return an instance of the TransportationSchedule" do
      @transportation_schedule.should be_a_kind_of(ResidentialService::TransportationSchedule)
    end

    it "should persist the supplied attributes" do
      @valid_attributes.each{|attr_id, val| @transportation_schedule.send(attr_id).should eql val }
    end

    it "should be assigned an id" do
      @transportation_schedule.id.should_not be_blank
    end

    context "when a required parameter is missing" do
      before :each do
        @transportation_schedule = ResidentialService::TransportationSchedule.create @valid_attributes.except(:destination)
      end

      it "should still be new record" do
        @transportation_schedule.should be_new_record
      end

      it "should have a collection of errors" do
        @transportation_schedule.errors.should_not be_empty
      end
    end
  end

  describe '.find' do
    before :each do
      clear_transportation_schedules
      @transportation_schedule = ResidentialService::TransportationSchedule.create @valid_attributes
    end

    context "when supplied only the account_id" do
      it "should return an enumerable object" do
        transportation_schedules = ResidentialService::TransportationSchedule.find( @transportation_schedule.account_id )
        transportation_schedules.should be_a_kind_of(Array)
      end

      it "should contain only TransportationSchedule objects" do
        transportation_schedules = ResidentialService::TransportationSchedule.find( @transportation_schedule.account_id )
        transportation_schedules.all?{|transportation_schedule| transportation_schedule.is_a?(ResidentialService::TransportationSchedule)}.should eql true
      end
    end

    context "when supplied both account_id and transportation_schedule_id" do
      context "and the TransportationSchedule exists" do
        it "should return an instance of TransportationSchedule" do
          transportation_schedule = ResidentialService::TransportationSchedule.find( @transportation_schedule.account_id, @transportation_schedule.id )
          transportation_schedule.should be_a_kind_of(ResidentialService::TransportationSchedule)
        end

        it "should have a starting_on attribute that is a Date" do
          transportation_schedule = ResidentialService::TransportationSchedule.find( @transportation_schedule.account_id, @transportation_schedule.id )
          transportation_schedule.starting_on.should be_a_kind_of(Date)
        end

        [:starting_at, :ending_at].each do |attr_id|
          it "should have a #{attr_id} attribute that is a Date" do
            transportation_schedule = ResidentialService::TransportationSchedule.find( @transportation_schedule.account_id, @transportation_schedule.id )
            transportation_schedule.send(attr_id).should be_a_kind_of(Time)
          end
        end

        it "should return all the persisted attributes" do
          @valid_attributes.each{|attr_id, val| @transportation_schedule.send(attr_id).should eql val }
        end
      end

      context "and the TransportationSchedule does not exist" do
        it "should return nil" do
          transportation_schedule = ResidentialService::TransportationSchedule.find( @transportation_schedule.account_id, @transportation_schedule.id+1 )
          transportation_schedule.should be_nil
        end
      end
    end
  end

  describe '#save' do
    context "with a new record" do
      before :each do
        clear_transportation_schedules
        @transportation_schedule = ResidentialService::TransportationSchedule.new @valid_attributes
        @transportation_schedule.should be_new_record
      end

      subject{ @transportation_schedule.save }
    
      it{ should eql true }

      it "should set the id of the receiver to the value returned from the service" do
        @transportation_schedule.save
        @transportation_schedule.id.should_not be_blank
      end
    end

    context "with an existing record" do
      before :each do
        clear_transportation_schedules
        @transportation_schedule = ResidentialService::TransportationSchedule.create @valid_attributes
        @transportation_schedule.should_not be_new_record

        @transportation_schedule.destination = @transportation_schedule.destination.reverse
      end

      subject{ @transportation_schedule.save }
    
      it{ should eql true }

      it "should not assign a new id to the instance" do
        lambda{ @transportation_schedule.save }.should_not change(@transportation_schedule, :id)
      end
    end
  end

  describe '#new_record?' do
    subject{ @transportation_schedule.new_record? }

    before :each do
      clear_transportation_schedules
      @transportation_schedule = ResidentialService::TransportationSchedule.new @valid_attributes
    end

    context "before save" do
      it{ should eql true }
    end

    context "after save" do
      before :each do
        @transportation_schedule.save
      end

      it{ should eql false }
    end
  end

  describe '#destroy' do
    context 'with a new record' do
      before :each do
        @transportation_schedule = ResidentialService::TransportationSchedule.new @valid_attributes
        @transportation_schedule.should be_new_record
      end

      it "should be false" do
        @transportation_schedule.destroy.should eql false
      end
    end

    context 'with a persisted record' do
      before :each do
        clear_transportation_schedules
        @transportation_schedule = ResidentialService::TransportationSchedule.create @valid_attributes
        @transportation_schedule.should_not be_new_record
      end

      it "should be true" do
        @transportation_schedule.destroy.should eql true
      end

      it "should remove the TransportationSchedule" do
        @transportation_schedule.destroy
        ResidentialService::TransportationSchedule.find(@transportation_schedule.account_id, @transportation_schedule.id).should be_nil
      end
    end
  end

  describe '.delete_all' do
    before :all do
      @account_id = 1
      ResidentialService::TransportationSchedule.create account_id: @account_id, destination: 'First', recurrence: 'weekly', ordinals: '5', starting_on: Date.yesterday, starting_at: Time.now
      ResidentialService::TransportationSchedule.create account_id: @account_id, destination: 'Middle', recurrence: 'weekly', ordinals: '2', starting_on: Date.yesterday, starting_at: Time.now
      ResidentialService::TransportationSchedule.create account_id: @account_id, destination: 'Last', recurrence: 'monthly', ordinals: '1,15', starting_on: Date.yesterday, starting_at: Time.now
    end

    subject{ TransportationSchedule.delete_all @account_id }
    context "when an account_id is not provided" do
      it{ lambda{ ResidentialService::TransportationSchedule.delete_all }.should raise_error }
    end

    context "when an account_id with one or more TransportationSchedules is provided" do
      before :each do
        ResidentialService::TransportationSchedule.find(@account_id).size.should_not be_zero
      end

      it "should delete all the TransportationSchedules on the supplied account_id" do
        ResidentialService::TransportationSchedule.delete_all @account_id
        ResidentialService::TransportationSchedule.find(@account_id).size.should be_zero
      end
    end
  end

  def clear_transportation_schedules
    ResidentialService::TransportationSchedule.delete_all 1
  end
end
