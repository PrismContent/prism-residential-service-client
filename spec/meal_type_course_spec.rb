require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ResidentialService::MealTypeCourse do
  before :each do
    midnight = Time.now

    @meal_type = ResidentialService::MealType.create({ 
      name:       'Breakfast',
      begins_at:  midnight,
      ends_at:    midnight + (2 * 60 * 60),
      account_id: 1
    })

    @meal_type.should_not be_new_record

    @valid_attributes = {
      name:       'Appetizer',
      meal_type_id: @meal_type.id
    }
  end

  describe '.new' do
    before :each do
      @meal_type_course = ResidentialService::MealTypeCourse.new @valid_attributes
    end

    subject{ @meal_type_course }

    it{should be_a_kind_of(ResidentialService::MealTypeCourse) }

    it "should set all the attributes based on the supplied hash" do
      @valid_attributes.each{|attr_id, val| @meal_type_course.send(attr_id).should eql val }
    end
  end

  describe '.create' do
    before :each do
      @meal_type_course = ResidentialService::MealTypeCourse.create @valid_attributes
    end

    after :each do
      @meal_type_course.destroy
    end

    it "should return an instance of the MealType" do
      @meal_type_course.should be_a_kind_of(ResidentialService::MealTypeCourse)
    end

    it "should persist the supplied attributes" do
      @valid_attributes.each{|attr_id, val| @meal_type_course.send(attr_id).should eql val }
    end

    it "should be assigned an id" do
      @meal_type_course.id.should_not be_blank
    end

    context "when a required parameter is missing" do
      before :each do
        @meal_type_course = ResidentialService::MealTypeCourse.create @valid_attributes.except(:name)
      end

      it "should still be new record" do
        @meal_type_course.should be_new_record
      end

      it "should have a collection of errors" do
        @meal_type_course.errors.should_not be_empty
      end
    end
  end

  describe '.find' do
    before :each do
      @meal_type_course = ResidentialService::MealTypeCourse.create @valid_attributes
      @meal_type_course.should_not be_new_record
    end

    context "when supplied only the meal_type_id" do
      before :each do
        @meal_type_courses = ResidentialService::MealTypeCourse.find( @meal_type.id )
      end

      it "should return an enumerable object" do
        @meal_type_courses.should be_a_kind_of(Array)
      end

      it "should contain only MealType objects" do
        @meal_type_courses.all?{|meal_type| meal_type.is_a?(ResidentialService::MealTypeCourse)}.should eql true
      end
    end

    context "when supplied both account_id and meal_type_id" do
      context "and the MealType exists" do
        before :each do
          @meal_type_course = ResidentialService::MealTypeCourse.find( @meal_type_course.meal_type_id, @meal_type_course.id )
        end

        it "should return an instance of MealType" do
          @meal_type_course.should be_a_kind_of(ResidentialService::MealTypeCourse)
        end

        it "should return all the persisted attributes" do
          @valid_attributes.each{|attr_id, val| @meal_type_course.send(attr_id).should eql val }
        end
      end

      context "and the MealType does not exist" do
        before :each do
          @meal_type_course = ResidentialService::MealTypeCourse.find( @meal_type_course.meal_type_id, @meal_type_course.id+1 )
        end

        it "should return nil" do
          @meal_type_course.should be_nil
        end
      end
    end
  end

  describe '#save' do
    context "with a new record" do
      before :each do
        @meal_type_course = ResidentialService::MealTypeCourse.new @valid_attributes
        @meal_type_course.should be_new_record
      end

      subject{ @meal_type_course.save }
    
      it{ should eql true }

      it "should set the id of the receiver to the value returned from the service" do
        @meal_type_course.save
        @meal_type_course.id.should_not be_blank
      end
    end

    context "with an existing record" do
      before :each do
        @meal_type_course = ResidentialService::MealTypeCourse.create @valid_attributes
        @meal_type_course.should_not be_new_record

        @meal_type_course.name = @meal_type_course.name.reverse
      end

      subject{ @meal_type_course.save }
    
      it{ should eql true }

      it "should not assign a new id to the instance" do
        lambda{ @meal_type_course.save }.should_not change(@meal_type_course, :id)
      end
    end
  end

  describe '#new_record?' do
    subject{ @meal_type_course.new_record? }

    before :each do
      @meal_type_course = ResidentialService::MealTypeCourse.new @valid_attributes
    end

    context "before save" do
      it{ should eql true }
    end

    context "after save" do
      before :each do
        @meal_type_course.save
      end

      it{ should eql false }
    end
  end

  describe '#destroy' do
    context 'with a new record' do
      before :each do
        @meal_type_course = ResidentialService::MealTypeCourse.new @valid_attributes
        @meal_type_course.should be_new_record
      end

      it "should be false" do
        @meal_type_course.destroy.should eql false
      end
    end

    context 'with a persisted record' do
      before :each do
        @meal_type_course = ResidentialService::MealTypeCourse.create @valid_attributes
        @meal_type_course.should_not be_new_record
      end

      it "should be true" do
        @meal_type_course.destroy.should eql true
      end

      it "should remove the MealTypeCourse" do
        @meal_type_course.destroy

        ResidentialService::MealTypeCourse.find(@meal_type_course.meal_type_id, @meal_type_course.id).should be_nil
      end
    end
  end

  describe '.delete_all' do
    before :each do
      @meal_type_id = @valid_attributes[:meal_type_id]
      ResidentialService::MealTypeCourse.create @valid_attributes.merge( name: 'First' )
      ResidentialService::MealTypeCourse.create @valid_attributes.merge( name: 'Middle' )
      ResidentialService::MealTypeCourse.create @valid_attributes.merge( name: 'Last' )
    end

    after :each do
      if courses = ResidentialService::MealTypeCourse.find(@meal_type_id)
        courses.each{|course| course.destroy }
      end
    end

    subject{ MealTypeCourse.delete_all @account_id }
    context "when an account_id is not provided" do
      it{ lambda{ ResidentialService::MealTypeCourse.delete_all }.should raise_error }
    end

    context "when an account_id with one or more MealTypeCourses is provided" do
      before :each do
        ResidentialService::MealTypeCourse.find(@meal_type_id).should_not be_empty
      end

      it "should delete all the MealTypeCourses on the supplied meal_type_id" do
        ResidentialService::MealTypeCourse.delete_all @meal_type_id
        ResidentialService::MealTypeCourse.find(@meal_type_id).should be_empty
      end
    end
  end

  describe '#position' do
    it "should be generated at creation" do
      @meal_type_course = ResidentialService::MealTypeCourse.create @valid_attributes
      @meal_type_course.position.should_not be_nil
    end
  end

  describe '#move' do
    context "when the mealTypeCourse exists" do
      before :each do
        ResidentialService::MealTypeCourse.create @valid_attributes.merge(name: 'First')
        @meal_type_course = ResidentialService::MealTypeCourse.create @valid_attributes
        ResidentialService::MealTypeCourse.create @valid_attributes.merge(name: 'Last')
      end

      context 'with the direction higher' do
        it "should decrement the position by one" do
          lambda{ @meal_type_course.move :higher }.should change(@meal_type_course, :position).by(-1)
        end
      end

      context 'with the direction lower' do
        it "should increment the position by one" do
          lambda{ @meal_type_course.move :lower }.should change(@meal_type_course, :position).by(1)
        end
      end

      context 'with the direction top' do
        before :each do
          @meal_type_course = ResidentialService::MealTypeCourse.create @valid_attributes.merge(name: 'Dead Last')
        end

        it "should increment the position by one" do
          lambda{ @meal_type_course.move :top }.should change(@meal_type_course, :position).to(1)
        end
      end

      context 'with the direction bottom' do
        before :each do
          @meal_type_course = ResidentialService::MealTypeCourse.find @meal_type_course.meal_type_id, @meal_type_course.id-1
        end

        it "should increment the position by one" do
          expected_position = ResidentialService::MealTypeCourse.find(@meal_type_course.meal_type_id).size
          lambda{ @meal_type_course.move :bottom }.should change(@meal_type_course, :position).to(expected_position)
        end
      end
    end
  end
end
