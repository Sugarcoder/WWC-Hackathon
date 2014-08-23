module EventsHelper

  def event_button_group(event, from_page)
    html = ActiveSupport::SafeBuffer.new
    if user_signed_in?
      if event.user_status_editable?
        user_event_relationship = UsersEvents.find_by_event_id_and_user_id(event.id, current_user.id)
        #Stop Attending button
        if current_user.attending_event?(event, user_event_relationship)
          html += link_to 'Cancel', cancel_event_path(event, 'attend'), id: 'cancel_event', class: 'btn btn-danger' 
        end
        #Stop Waiting button
        if current_user.waiting_event?(event, user_event_relationship)
          html += link_to 'Stop Waiting', cancel_event_path(event, 'wait'), id: 'cancel_waiting', class: 'btn btn-danger'
        end
        #Attend button
        unless event.full? || current_user.attending_event?(event, user_event_relationship)
          html += link_to 'Attend Event', attend_event_path(event, 'attend'), id:'attend_event', class: 'btn btn-success'
        end
        #Waiting button
        if event.full? && !current_user.waiting_event?(event, user_event_relationship)
          html += link_to 'Waiting List', attend_event_path(event, 'wait'), id:'wait_event', class: 'btn btn-info'
        end

        #Attend recurring & Stop recurring
        if event.daily? || event.weekly?
          if current_user.attend_recurring_event?(event, user_event_relationship)
            html += link_to 'stop attend recurring', stop_attend_recurring_event_path(event), id: 'stop_attend_recurring', class: ['btn btn-danger', 'pull-left']
          else
            html += content_tag :button, 'Attend recurring', id:'attend_recurring', class: 'btn btn-primary pull-left', data: { placement: "right" }
            html += content_tag :div, 'Attend Recurring' ,id: 'popover-head', class: 'hide'
            html += content_tag :div, id: 'popover-content', class: 'hide' do
                      render partial: 'event_attend_recurring_form', locals: { event: event}
                    end
          end
        end
      end

      #Detail button
      if (can? :show, event) && from_page != 'detail_page'
        html += link_to 'Details', event_path(event), class: 'btn btn-primary'
      end
      #Edit & Destroy button
      if (can? :update, event) && (can? :destroy, event)
        html += link_to 'Edit', edit_event_path(event), class: 'btn btn-primary'
        html += link_to 'Destroy', event_path(event), method: 'delete', class: 'btn btn-danger'
      end

    else
      html  +=  content_tag :span, class: ['text-info', 'register-notice'] do 
                  ' You need to be a registered user to attend event :)'
                end
      # Log in button
      html += link_to "Log in", new_user_session_path(event_id: event.id), class: 'btn btn-primary'
      # Sign up buton
      html += link_to "Sign up", new_user_registration_path(event_id: event.id), class: 'btn btn-success'
    end
    html
  end


end
