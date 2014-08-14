class Participant < ActiveRecord::Base
  has_one :applicant
  has_many :tickets
  has_many :fest_participant_submissions
  has_many :fest_participant_role_types
  has_many :fests, :through => :fest_participant_role_types
  has_many :role_types, :through => :fest_participant_role_types
  has_many :submissions, :through => :fest_participant_submissions

  accepts_nested_attributes_for :applicant
  accepts_nested_attributes_for :role_types

  validates_uniqueness_of :lname, :scope => [:fname, :email]

  def name
    "#{lname}, #{fname}"
  end

  def tickets_count
    tickets.group(:ticket_type).count
  end

  def import(file)
    ImporterWootix.import(file.path)
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
