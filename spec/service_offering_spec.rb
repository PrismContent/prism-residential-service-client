require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'faker'

describe ResidentialService::ServiceOffering do
  let(:valid_attributes){ { account_id: account_id, name: name, service_type: service_type, description: Faker::Lorem.paragraph } }
  let(:account_id){ 1 }
  let(:name){ 'Driving Miss Daisy' }
  let(:service_type){ 'transportation' }

  describe '.new' do
    subject{ ResidentialService::ServiceOffering.new valid_attributes }

    it{ should be_a_kind_of(ResidentialService::ServiceOffering) }

    it "should set all the attributes based on the supplied hash" do
      valid_attributes.each do |attr_id, val|
        subject.send(attr_id).should eql val
      end
    end
  end

  describe '.create' do
    subject{ @service_offering ||= ResidentialService::ServiceOffering.create valid_attributes }

    before :each do
      ResidentialService::ServiceOffering.delete_all account_id if account_id
    end

    it{ should be_a_kind_of(ResidentialService::ServiceOffering) }

    it "should set all the attributes based on the supplied hash" do
      valid_attributes.each do |attr_id, val|
        subject.send(attr_id).should eql val
      end
    end

    it "should be assigned an id" do
      subject.id.should_not be_blank
    end

    context "when a required parameter is missing" do
      let(:name){ nil }

      it{ should be_new_record }

      it "should have a collection of errors" do
        subject.errors.should_not be_empty
      end
    end
  end

  describe '.find' do
    before :each do
      ResidentialService::ServiceOffering.delete_all account_id if account_id
      @service_offering = ResidentialService::ServiceOffering.create valid_attributes
    end

    context "when supplied with only the account_id" do
      subject{ ResidentialService::ServiceOffering.find account_id }

      it "should return an enumerable object" do
        should be_a_kind_of(Array)
      end

      it "should contain only ServiceOffering objects" do
        subject.all?{|service| service.is_a?(ResidentialService::ServiceOffering) }.should eql true
      end
    end

    context "when supplied with both account_id and service_offering_id" do
      subject{ ResidentialService::ServiceOffering.find account_id, service_offering_id }

      context 'when the ServiceOffering exists' do
        let(:service_offering_id){ @service_offering.id }

        it{ should be_a_kind_of(ResidentialService::ServiceOffering) }

        it "should return all the persisted attributes" do
          valid_attributes.each do |attr_id, val|
            subject.send(attr_id).should eql val
          end
        end
      end

      context "when the ServiceOffering does not exist" do
        let(:service_offering_id){ @service_offering.id+100 }

        it{ should be_nil }
      end
    end
  end

  describe '#save' do
    subject{ service_offering.save }

    before :each do
      ResidentialService::ServiceOffering.delete_all account_id if account_id
    end

    context "with a new record" do
      let(:service_offering){ResidentialService::ServiceOffering.new valid_attributes}

      it{ should eql true }
      it "should set an id on the ServiceOffering" do
        service_offering.save
        service_offering.id.should_not be_blank
      end
    end

    context "with an existing record" do
      let(:service_offering){ResidentialService::ServiceOffering.create valid_attributes}
      
      it{ should be true }

      it "should not change the id of the instance" do
        lambda{ service_offering.save }.should_not change(service_offering, :id)
      end

      context "after proof" do
        before(:each) do 
          service_offering.proof name: 'Zoo Trip'
          service_offering.name = 'Movies'
        end

        it "should change the state to 'edited'" do
          lambda{ service_offering.save }.should change(service_offering, :state).to('edited')
        end
      end
    end
  end

  describe "#proof" do
    subject{ service_offering.proof name: 'Doctor Visits' }

    before :each do
      ResidentialService::ServiceOffering.delete_all account_id if account_id
    end

    context "with a new record" do
      let(:service_offering){ResidentialService::ServiceOffering.new valid_attributes}

      it{ should eql false }
    end

    context "with an existing record" do
      let(:service_offering){ResidentialService::ServiceOffering.create valid_attributes}
      
      it{ should be true }

      it "should change the state to 'proofed'" do
        lambda{ service_offering.proof name: 'Doctor Visits' }.should change(service_offering, :state).to('proofed')
      end
    end
  end

  describe "#new_record?" do
    subject{ service_offering.new_record? }

    before :each do
      ResidentialService::ServiceOffering.delete_all account_id if account_id
    end
    
    context "before save" do
      let(:service_offering){ResidentialService::ServiceOffering.new valid_attributes}
      it{ should eql true }
    end

    context "after save" do
      let(:service_offering){ResidentialService::ServiceOffering.create valid_attributes}
      it{ should eql false }
    end
  end

  describe '#destroy' do
    before :each do
      ResidentialService::ServiceOffering.delete_all account_id if account_id
    end

    subject{ service_offering.destroy }

    context "with a new record" do
      let(:service_offering){ResidentialService::ServiceOffering.new valid_attributes}
      it{ should eql false }
    end

    context "with a persisted record" do
      let(:service_offering){ResidentialService::ServiceOffering.create valid_attributes}
      it{ should eql true }

      it "should remove the ServiceOffering" do
        service_offering.destroy
        ResidentialService::ServiceOffering.find(account_id, service_offering.id).should be_nil
      end
    end
  end

  describe '.delete_all' do
    subject{ ResidentialService::ServiceOffering.delete_all account_id }

    before :all do
      ResidentialService::ServiceOffering.create valid_attributes
      ResidentialService::ServiceOffering.create valid_attributes.merge(name: 'Thelma and Louise')
      ResidentialService::ServiceOffering.create valid_attributes.merge(name: 'Sanford and Son')
    end

    context "when an account_id is not provided" do
      it "should raise an error" do
        lambda{ ResidentialService::ServiceOffering.delete_all }.should raise_error
      end
    end

    context "when an account_id with one or more locations is provided" do
      before :each do
        ResidentialService::ServiceOffering.find(account_id).should_not be_empty
      end

      it "should delete all the ServiceOfferings on the supplied account_id" do
        ResidentialService::ServiceOffering.delete_all account_id 
        ResidentialService::ServiceOffering.find(account_id).should be_empty
      end
    end
  end
end
