require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ResidentialService::MealType do
  before :each do
    midnight = Time.now

    @valid_attributes = {
      name:       'Breakfast',
      begins_at:  midnight,
      ends_at:    midnight + (2 * 60 * 60),
      account_id: 1
    }
  end

  describe '.new' do
    before :each do
      @meal_type = ResidentialService::MealType.new @valid_attributes
    end

    subject{ @meal_type }

    it{should be_a_kind_of(ResidentialService::MealType) }

    it "should set all the attributes based on the supplied hash" do
      @valid_attributes.each{|attr_id, val| @meal_type.send(attr_id).should eql val }
    end
  end

  describe '.create' do
    before :each do
      @meal_type = ResidentialService::MealType.create @valid_attributes
    end

    it "should return an instance of the MealType" do
      @meal_type.should be_a_kind_of(ResidentialService::MealType)
    end

    it "should persist the supplied attributes" do
      @valid_attributes.each{|attr_id, val| @meal_type.send(attr_id).should eql val }
    end

    it "should be assigned an id" do
      @meal_type.id.should_not be_blank
    end

    context "when a required parameter is missing" do
      before :each do
        @meal_type = ResidentialService::MealType.create @valid_attributes.except(:name)
      end

      it "should still be new record" do
        @meal_type.should be_new_record
      end

      it "should have a collection of errors" do
        @meal_type.errors.should_not be_empty
      end
    end
  end

  describe '.find' do
    before :each do
      @meal_type = ResidentialService::MealType.create @valid_attributes
    end

    context "when supplied only the account_id" do
      it "should return an enumerable object" do
        meal_types = ResidentialService::MealType.find( @meal_type.account_id )
        meal_types.should be_a_kind_of(Array)
      end

      it "should contain only MealType objects" do
        meal_types = ResidentialService::MealType.find( @meal_type.account_id )
        meal_types.all?{|meal_type| meal_type.is_a?(ResidentialService::MealType)}.should eql true
      end
    end

    context "when supplied both account_id and meal_type_id" do
      context "and the MealType exists" do
        it "should return an instance of MealType" do
          meal_type = ResidentialService::MealType.find( @meal_type.account_id, @meal_type.id )
          meal_type.should be_a_kind_of(ResidentialService::MealType)
        end

        it "should return all the persisted attributes" do
          @valid_attributes.each{|attr_id, val| @meal_type.send(attr_id).should eql val }
        end
      end

      context "and the MealType does not exist" do
        it "should return nil" do
          meal_type = ResidentialService::MealType.find( @meal_type.account_id, @meal_type.id+1 )
          meal_type.should be_nil
        end
      end
    end
  end

  describe '#save' do
    context "with a new record" do
      before :each do
        @meal_type = ResidentialService::MealType.new @valid_attributes
        @meal_type.should be_new_record
      end

      subject{ @meal_type.save }
    
      it{ should eql true }

      it "should set the id of the receiver to the value returned from the service" do
        @meal_type.save
        @meal_type.id.should_not be_blank
      end
    end

    context "with an existing record" do
      before :each do
        @meal_type = ResidentialService::MealType.create @valid_attributes
        @meal_type.should_not be_new_record

        @meal_type.name = @meal_type.name.reverse
      end

      subject{ @meal_type.save }
    
      it{ should eql true }

      it "should not assign a new id to the instance" do
        lambda{ @meal_type.save }.should_not change(@meal_type, :id)
      end
    end
  end

  describe '#new_record?' do
    subject{ @meal_type.new_record? }

    before :each do
      @meal_type = ResidentialService::MealType.new @valid_attributes
    end

    context "before save" do
      it{ should eql true }
    end

    context "after save" do
      before :each do
        @meal_type.save
      end

      it{ should eql false }
    end
  end

  describe '#destroy' do
    context 'with a new record' do
      before :each do
        @meal_type = ResidentialService::MealType.new @valid_attributes
        @meal_type.should be_new_record
      end

      it "should be false" do
        @meal_type.destroy.should eql false
      end
    end

    context 'with a persisted record' do
      before :each do
        @meal_type = ResidentialService::MealType.create @valid_attributes
        @meal_type.should_not be_new_record
      end

      it "should be true" do
        @meal_type.destroy.should eql true
      end

      it "should remove the MealType" do
        @meal_type.destroy

        ResidentialService::MealType.find(@meal_type.account_id, @meal_type.id).should be_nil
      end
    end
  end
end
