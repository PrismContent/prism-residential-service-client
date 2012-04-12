require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ResidentialService::Meal do
  before :each do
    midnight = Time.now

    @meal_type = ResidentialService::MealType.create({ 
      name:       'Breakfast',
      begins_at:  midnight,
      ends_at:    midnight + (2 * 60 * 60),
      account_id: 1
    })

    @meal_type.should_not be_new_record

    @meal_type_course = ResidentialService::MealTypeCourse.create({
      name:         'Entree',
      meal_type_id: @meal_type.id
    })

    @valid_attributes = {
      name:         'Hungry Boy Breakfast',
      description:  "Two eggs\nCountry Ham\nBiscuits\nGravy",
      starting_at:  midnight,
      ending_at:    midnight + (2 * 60 * 60),
      account_id:   1,
      meal_type_course_id: @meal_type_course.id
    }
  end

  describe '.new' do
    before :each do
      @meal = ResidentialService::Meal.new @valid_attributes
    end

    subject{ @meal }

    it{should be_a_kind_of(ResidentialService::Meal) }

    it "should set all the attributes based on the supplied hash" do
      @valid_attributes.each{|attr_id, val| @meal.send(attr_id).should eql val }
    end
  end

  describe '.create' do
    before :each do
      @meal = ResidentialService::Meal.create @valid_attributes
    end

    after :each do
      @meal.destroy
    end

    it "should return an instance of the MealType" do
      @meal.should be_a_kind_of(ResidentialService::Meal)
    end

    it "should persist the supplied attributes" do
      @valid_attributes.each{|attr_id, val| @meal.send(attr_id).should eql val }
    end

    it "should be assigned an id" do
      @meal.id.should_not be_blank
    end

    context "when a required parameter is missing" do
      before :each do
        @meal = ResidentialService::Meal.create @valid_attributes.except(:name)
      end

      it "should still be new record" do
        @meal.should be_new_record
      end

      it "should have a collection of errors" do
        @meal.errors.should_not be_empty
      end
    end

    context 'when starting_at and ending_at are omitted' do
      before :each do
        @meal = ResidentialService::Meal.create @valid_attributes.except(:starting_at, :ending_at).merge(:served_on=>Date.today)
      end
      
      {:starting_at => :begins_at, :ending_at => :ends_at}.each do |result_attr, source_attr|
        it "persisted instance should contain a #{result_attr} value" do
          @meal.send(result_attr).should_not be_nil
        end
      end

    end
  end

  describe '.find' do
    before :each do
      @meal = ResidentialService::Meal.create @valid_attributes
      @meal.should_not be_new_record
    end

    context "when supplied only the meal_type_id" do
      before :each do
        @meals = ResidentialService::Meal.find( @meal_type.id )
      end

      it "should return an enumerable object" do
        @meals.should be_a_kind_of(Array)
      end

      it "should contain only MealType objects" do
        @meals.all?{|meal_type| meal_type.is_a?(ResidentialService::Meal)}.should eql true
      end
    end

    context "when supplied both account_id and meal_id" do
      context "and the Meal exists" do
        before :each do
          @meal = ResidentialService::Meal.find( @meal.account_id, @meal.id )
        end

        it "should return an instance of MealType" do
          @meal.should be_a_kind_of(ResidentialService::Meal)
        end

        it "should return all the persisted attributes" do
          @valid_attributes.each{|attr_id, val| @meal.send(attr_id).should eql val }
        end
      end

      context "and the MealType does not exist" do
        before :each do
          @meal = ResidentialService::Meal.find( @meal.account_id, @meal.id+1 )
        end

        it "should return nil" do
          @meal.should be_nil
        end
      end
    end
  end

  describe '#save' do
    context "with a new record" do
      before :each do
        @meal = ResidentialService::Meal.new @valid_attributes
        @meal.should be_new_record
      end

      subject{ @meal.save }
    
      it{ should eql true }

      it "should set the id of the receiver to the value returned from the service" do
        @meal.save
        @meal.id.should_not be_blank
      end
    end

    context "with an existing record" do
      before :each do
        @meal = ResidentialService::Meal.create @valid_attributes
        @meal.should_not be_new_record

        @meal.name = @meal.name.reverse
      end

      subject{ @meal.save }
    
      it{ should eql true }

      it "should not assign a new id to the instance" do
        lambda{ @meal.save }.should_not change(@meal, :id)
      end
    end
  end

  describe '#new_record?' do
    subject{ @meal.new_record? }

    before :each do
      @meal = ResidentialService::Meal.new @valid_attributes
    end

    context "before save" do
      it{ should eql true }
    end

    context "after save" do
      before :each do
        @meal.save
      end

      it{ should eql false }
    end
  end

  describe '#destroy' do
    context 'with a new record' do
      before :each do
        @meal = ResidentialService::Meal.new @valid_attributes
        @meal.should be_new_record
      end

      it "should be false" do
        @meal.destroy.should eql false
      end
    end

    context 'with a persisted record' do
      before :each do
        @meal = ResidentialService::Meal.create @valid_attributes
        @meal.should_not be_new_record
      end

      it "should be true" do
        @meal.destroy.should eql true
      end

      it "should remove the Meal" do
        @meal.destroy

        ResidentialService::Meal.find(@meal.meal_type_course_id, @meal.id).should be_nil
      end
    end
  end

end

