require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'faker'

describe ResidentialService::ServiceTime do
  let(:valid_attributes){ { service_offering_id: service_offering_id, wday: wday, starting_at: starting_at, ending_at: 1.hour.since(starting_at), time_of_day: time_of_day } }
  let(:time_of_day){ 'Specific Time' }
  let(:service_offering_id){ 1 }
  let(:wday){ Time.now.wday }
  let(:starting_at){ Time.now }

  describe '.new' do
    subject{ ResidentialService::ServiceTime.new valid_attributes }

    it{ should be_a_kind_of(ResidentialService::ServiceTime) }

    it "should set all the attributes based on the supplied hash" do
      valid_attributes.each do |attr_id, val|
        subject.send(attr_id).should eql val
      end
    end
  end

  describe '.create' do
    subject{ @service_time ||= ResidentialService::ServiceTime.create valid_attributes }

    before :each do
      ResidentialService::ServiceTime.delete_all service_offering_id if service_offering_id
    end

    it{ should be_a_kind_of(ResidentialService::ServiceTime) }

    it "should set all the attributes based on the supplied hash" do
      valid_attributes.each do |attr_id, val|
        subject.send(attr_id).should eql val
      end
    end

    it "should be assigned an id" do
      subject.id.should_not be_blank
    end

    context "when a required parameter is missing" do
      let(:wday){ nil }

      it{ should be_new_record }

      it "should have a collection of errors" do
        subject.errors.should_not be_empty
      end
    end
  end

  describe '.find' do
    before :each do
      ResidentialService::ServiceTime.delete_all service_offering_id if service_offering_id
      @service_time = ResidentialService::ServiceTime.create valid_attributes
    end

    context "when supplied with only the service_offering_id" do
      subject{ ResidentialService::ServiceTime.find service_offering_id }

      it "should return an enumerable object" do
        should be_a_kind_of(Array)
      end

      it "should contain only ServiceTime objects" do
        subject.all?{|service| service.is_a?(ResidentialService::ServiceTime) }.should eql true
      end
    end

    context "when supplied with both service_offering_id and service_time_id" do
      subject{ ResidentialService::ServiceTime.find service_offering_id, service_time_id }

      context 'when the ServiceTime exists' do
        let(:service_time_id){ @service_time.id }

        it{ should be_a_kind_of(ResidentialService::ServiceTime) }

        it "should return all the persisted attributes" do
          valid_attributes.each do |attr_id, val|
            if attr_id.to_s =~ /_at$/
              subject.send(attr_id).should eql val.strftime('%FT%T%:z')
            else
              subject.send(attr_id).should eql val
            end
          end
        end
      end

      context "when the ServiceTime does not exist" do
        let(:service_time_id){ @service_time.id+100 }

        it{ should be_nil }
      end
    end
  end

  describe '#save' do
    subject{ service_time.save }

    before :each do
      ResidentialService::ServiceTime.delete_all service_offering_id if service_offering_id
    end

    context "with a new record" do
      let(:service_time){ResidentialService::ServiceTime.new valid_attributes}

      it{ should eql true }
      it "should set an id on the ServiceTime" do
        service_time.save
        service_time.id.should_not be_blank
      end
    end

    context "with an existing record" do
      let(:service_time){ResidentialService::ServiceTime.create valid_attributes}
      
      it{ should be true }

      it "should not change the id of the instance" do
        lambda{ service_time.save }.should_not change(service_time, :id)
      end
    end
  end

  describe "#new_record?" do
    subject{ service_time.new_record? }

    before :each do
      ResidentialService::ServiceTime.delete_all service_offering_id if service_offering_id
    end
    
    context "before save" do
      let(:service_time){ResidentialService::ServiceTime.new valid_attributes}
      it{ should eql true }
    end

    context "after save" do
      let(:service_time){ResidentialService::ServiceTime.create valid_attributes}
      it{ should eql false }
    end
  end

  describe '#destroy' do
    before :each do
      ResidentialService::ServiceTime.delete_all service_offering_id if service_offering_id
    end

    subject{ service_time.destroy }

    context "with a new record" do
      let(:service_time){ResidentialService::ServiceTime.new valid_attributes}
      it{ should eql false }
    end

    context "with a persisted record" do
      let(:service_time){ResidentialService::ServiceTime.create valid_attributes}
      it{ should eql true }

      it "should remove the ServiceTime" do
        service_time.destroy
        ResidentialService::ServiceTime.find(service_offering_id, service_time.id).should be_nil
      end
    end
  end

  describe '.delete_all' do
    subject{ ResidentialService::ServiceTime.delete_all service_offering_id }

    before :all do
      ResidentialService::ServiceTime.create valid_attributes
      ResidentialService::ServiceTime.create valid_attributes.merge(name: 'Thelma and Louise')
      ResidentialService::ServiceTime.create valid_attributes.merge(name: 'Sanford and Son')
    end

    context "when an service_offering_id is not provided" do
      it "should raise an error" do
        lambda{ ResidentialService::ServiceTime.delete_all }.should raise_error
      end
    end

    context "when an service_offering_id with one or more locations is provided" do
      before :each do
        ResidentialService::ServiceTime.find(service_offering_id).should_not be_empty
      end

      it "should delete all the ServiceTimes on the supplied service_offering_id" do
        ResidentialService::ServiceTime.delete_all service_offering_id 
        ResidentialService::ServiceTime.find(service_offering_id).should be_empty
      end
    end
  end
end
