require 'spec_helper'

describe Monadic::Validation do
  Person = Struct.new(:age, :gender, :sobriety, :name)

  it 'a projection of Success and Failure' do

    def validate(person)
      check_age = ->(age_expr) {
        age = age_expr.to_i
        case 
        when age <=  0; Failure('Age must be > 0')
        when age > 130; Failure('Age must be < 130')
        else Success(age)
        end
      }

      check_sobriety = ->(sobriety) {
        case sobriety
        when :sober, :tipsy; Success(sobriety)
        when :drunk        ; Failure('No drunks allowed')
        else Failure("Sobriety state '#{sobriety}' is not allowed")
        end 
      }

      check_gender = ->(gender) {
        gender == :male || gender == :female ? Success(gender) : Failure("Invalid gender #{gender}")
      }
        
      Validation() do
        check { check_age.(person.age);          }
        check { check_sobriety.(person.sobriety) }
        check { check_gender.(person.gender)     }
      end
    end

    failure = validate(Person.new(age = 's', gender = :male, sobriety = :drunk, name = 'test'))
    failure.should be_a Failure
    failure.success?.should be_false
    failure.failure?.should be_true
    failure.should == Failure(["Age must be > 0", "No drunks allowed"])

    success = validate(Person.new(age = 30, gender = :male, sobriety = :sober, name = 'test'))
    success.should be_a Success
    success.should == Success([30, :sober, :male])
  end
end
