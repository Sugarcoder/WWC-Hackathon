class Search
  
  class << self
    
    def search_user(str, user_role = nil)
      result = []
      user_roles_range = find_user_type(user_role)
      if str.is_id?
        user = User.find_by_id(str.to_i)
        result << user.email if user
      else
        terms = str.split(' ')
        if terms.length >= 2
          first_part = terms[0]
          second_part = terms[1..-1].join(' ')+ '%'
          users = User.where('(firstname = ? and lastname Like ?) or (lastname = ? and firstname Like ?)', first_part, second_part, first_part , second_part ).where('role IN (?)', user_roles_range).limit(limit)
        else
          term = str + '%'
          users = User.where('email Like (?) or firstname Like(?) or lastname Like(?)', term, term, term).where('role IN (?)', user_roles_range).limit(limit)
        end
        users.each { |user| result << user.email }
      end
      result
    end

    def limit
      15
    end

    def find_user_type(user_type)
      case user_type
      when 'normal_user'
        [0]
      when 'lead_rescuer'
        [1]
      when 'super_admin'
        [2]
      else
        [0, 1, 2]
      end
    end

  end
    
end

class String
  def is_id?
    self.to_i.to_s == self
  end
end