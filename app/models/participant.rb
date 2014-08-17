class Participant < ActiveRecord::Base
  has_one :applicant
  has_many :tickets
  has_many :fest_participant_submissions
  has_many :fest_participant_role_types
  has_many :fests, :through => :fest_participant_role_types
  has_many :role_types, :through => :fest_participant_role_types
  has_many :submissions, :through => :fest_participant_submissions
  has_many :comments, as: :commentable

  accepts_nested_attributes_for :applicant
  accepts_nested_attributes_for :role_types

  validate :lname, :uniqueness => {scope: [:fname, :email], case_sensitive: false}

  def name
    "#{lname}, #{fname}"
  end

  def tickets_count
    tickets.group(:ticket_type).count
  end

  def import(file)
    ImporterWootix.import(file.path)
  end

  def total_tickets
    tickets.map {|t| t.qty.to_i}.reduce(:+)

  end

  def self.search(search)
    if search
      where("lname LIKE ?","%#{search}%")
    else
      all
    end
  end


  scope :customers, -> {includes(:role_types).where("role_types.name = 'customer'").references(:role_types)}
end
