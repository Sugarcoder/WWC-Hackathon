require 'rails_helper'

RSpec.describe Event, :type => :model do

  describe "Validation when creating event" do
    
    it 'should has a title' do
      event = build(:event, title: "")
      event.valid?

      expect(event.errors[:title][0]).to eq "can't be blank"
    end

    it 'should has a starting time' do
      event = build(:event, starting_time: "")
      event.valid?

      expect(event.errors[:starting_time][0]).to eq "can't be blank"
    end

    it 'should has a ending time' do
      event = build(:event, ending_time: "")
      event.valid?

      expect(event.errors[:ending_time][0]).to eq "can't be blank"
    end

    it 'should has a leader id' do
      event = build(:event, leader_id: "")
      event.valid?

      expect(event.errors[:leader_id][0]).to eq "can't be blank"
    end

    it 'should has a slot' do
      event = build(:event, slot: "")
      event.valid?

      expect(event.errors[:slot][0]).to eq "can't be blank"
    end

    it 'should has a slot that is greater than 0' do
      event = build(:event, slot: 0)
      event.valid?

      expect(event.errors[:slot][0]).to eq "must be greater than 0"
    end

    it 'should has a starting time later than current time' do
      event = build(:event, starting_time: 1.minute.ago)
      event.valid?

      expect(event.errors[:base][0]).to eq "Event starting time can not be older than current time"
    end

    it 'should has a starting time before ending time' do
      event = build(:event, starting_time: Time.current + 2.minute, ending_time: Time.current + 1.minute)
      event.valid?

      expect(event.errors[:base][0]).to eq "Event starting time can not after ending time"
    end

    it 'should has a leader who is a confirmed user' do
      user = build_stubbed(:user)
      event = build(:event, leader_id: user.id)
      allow(event).to receive(:leader) { user }
      event.valid?

      expect(event.errors[:base][0]).to eq "Only confirmed user can be leader of an event"
    end

    it 'should has a leader who is an admin user' do
      user = build_stubbed(:user, :confirmed)
      event = build(:event, leader_id: user.id)
      allow(event).to receive(:leader) { user }
      event.valid?

      expect(event.errors[:base][0]).to eq "Normal user can not be leader of an event"
    end
  end

  describe "Event time formate" do
    before(:all) do
      @event = build_stubbed(:event, starting_time: Time.zone.local(2014,3,24,14,50,0), ending_time: Time.zone.local(2014,3,24,16,50,0) )
    end
    
    context "#starting_date" do
      it 'should returns event starting date with hour' do
        expect(@event.starting_date).to eq "03/24/2014  2:50 PM"
      end
    end

    context "#ending_date" do
      it 'should returns event starting date with hour' do
        expect(@event.ending_date).to eq "03/24/2014  4:50 PM"
      end
    end

    context "#starting hour" do
      it 'should returns starting hour' do
        expect(@event.starting_hour).to eq " 2:50 PM"
      end
    end

    context "#ending hour" do
      it 'should returns ending hour' do
        expect(@event.ending_hour).to eq " 4:50 PM"
      end
    end

    context "#starting_date_with_full_weekday_name" do
      it 'should returns starting date with full weekday name' do
        expect(@event.starting_date_with_full_weekday_name).to eq "Monday, March 24, 2014"
      end
    end

    context "#ending_date_with_full_weekday_name" do
      it 'should returns ending date with full weekday name' do
        expect(@event.ending_date_with_full_weekday_name).to eq "Monday, March 24, 2014"
      end
    end

  end

  describe "#waiting_list_slot" do
    it 'should be half of event slots if slots are even' do
      event = build(:event, slot: 4)
      expect(event.waiting_list_slot).to eq 2
    end

    it "should be half of event slots plus 1 if slots are odd" do
      event = build(:event, slot: 5)
      expect(event.waiting_list_slot).to eq 3
    end
  end

  describe "#full?" do
    it 'return true when event is full' do
      event = build(:event, slot: 2, attending_user_count: 2)
      expect(event.full?).to eq true
    end

    it 'return false when event is not full' do
      event = build(:event, slot: 1, attending_user_count: 0)
      expect(event.full?).to eq false
    end
  end

  describe "Create Event" do
    
    it 'should sign up leader after create' do
      event = create(:event, slot: 1)
      event.send(:sign_up_lead_rescuer)
      users_events = UsersEvents.find_by_user_id_and_event_id(event.leader_id, event.id)

      expect(users_events).to be
      expect(users_events.attending?).to eq true
    end

  end

  describe "Calculate Recurring Event Time" do
    before(:all) do
      @starting_time = Time.zone.local(2014, 10, 1, 14, 50, 0) # 2014.10.10 14:50:00
      @ending_time = Time.zone.local(2014, 10, 1, 16, 50, 0) # 2014.10.10 16:50:00
      
      @monthly_event = build_stubbed(:event, starting_time: @starting_time, ending_time: @ending_time, recurring_type: 3 )
    end

    context 'when daily events' do
      before(:all) {  @daily_event = build_stubbed(:event, starting_time: @starting_time, ending_time: @ending_time, recurring_type: 1 ) }
      # 10.1 - 10.10 weekdays 3, 4, 5, 6, 0, 1, 2, 3, 4, 5

      it 'return same starting & ending time with all week days' do
        selected_time = Event.calculate_recurring_time( @daily_event, "10/10/2014 06:20 PM", [0, 1, 2, 3, 4, 5, 6] )
        expect( selected_time.length ).to eq 9
        expect( selected_time.map{ |hash| hash[:starting_time].wday } ).to eq [4, 5, 6, 0, 1, 2, 3, 4, 5]
        expect( selected_time.map{ |hash| hash[:ending_time].wday } ).to eq [4, 5, 6, 0, 1, 2, 3, 4, 5]
        expect( selected_time.map{ |hash| hash[:starting_time].to_s(:time) }.count('14:50') ).to eq 9
        expect( selected_time.map{ |hash| hash[:ending_time].to_s(:time) }.count('16:50') ).to eq 9
      end

      it 'return same starting & ending time with selected days' do
        selected_time = Event.calculate_recurring_time( @daily_event, "10/10/2014 06:20 PM", [0, 2, 3] )
        expect( selected_time.length ).to eq 3
        expect( selected_time.map{ |hash| hash[:starting_time].wday } ).to eq [0, 2, 3]
        expect( selected_time.map{ |hash| hash[:ending_time].wday } ).to eq [0, 2, 3]
        expect( selected_time.map{ |hash| hash[:starting_time].to_s(:time) }.count('14:50') ).to eq 3
        expect( selected_time.map{ |hash| hash[:ending_time].to_s(:time) }.count('16:50') ).to eq 3
      end

      it 'does not return event start after recurring ending time' do
        selected_time = Event.calculate_recurring_time( @daily_event, "10/10/2014 10:20 AM", [5] )
        expect( selected_time.length ).to eq 1
        expect( selected_time.first[:starting_time].mday ).to eq 3
      end

    end

    context 'when weekly events' do
      before(:all) { @weekly_event = build_stubbed(:event, starting_time: @starting_time, ending_time: @ending_time, recurring_type: 2 ) }

      it 'return the weekyday that event start at' do
        selected_time = Event.calculate_recurring_time( @weekly_event, "10/31/2014 06:20 PM" )
        expect( selected_time.length ).to eq 4
        expect( selected_time.map{ |hash| hash[:starting_time].wday }.count(3) ).to eq 4
        expect( selected_time.map{ |hash| hash[:starting_time].to_s(:time) }.count('14:50') ).to eq 4
        expect( selected_time.map{ |hash| hash[:ending_time].to_s(:time) }.count('16:50') ).to eq 4
      end

    end

    context 'when monthly events' do
      before(:all) { @monthly_event = build_stubbed(:event, starting_time: @starting_time, ending_time: @ending_time, recurring_type: 3 ) }

      it 'return the month day that event start at' do
        selected_time = Event.calculate_recurring_time( @monthly_event, "12/31/2014 06:20 PM" )
        expect( selected_time.length ).to eq 2
        expect( selected_time.map{ |hash| hash[:starting_time].mday }.count(1) ).to eq 2
        expect( selected_time.map{ |hash| hash[:starting_time].to_s(:time) }.count('14:50') ).to eq 2
        expect( selected_time.map{ |hash| hash[:ending_time].to_s(:time) }.count('16:50') ).to eq 2
      end

      #November does not have 31 days
      it 'escape the month if that month does not have the day that event start at' do
        event = build_stubbed(:event, starting_time: Time.zone.local(2014, 10, 31, 14, 50, 0), ending_time: Time.zone.local(2014, 10, 31, 16, 50, 0), recurring_type: 3 )
        selected_time = Event.calculate_recurring_time( event, "12/31/2014 06:20 PM" )
        expect( selected_time.length ).to eq 1
        expect( selected_time.first[:starting_time].month ).to eq 12
      end

    end



  end

end
