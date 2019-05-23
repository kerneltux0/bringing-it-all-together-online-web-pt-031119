require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(id:nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name,breed)
      VALUES (?,?)
    SQL

    grab_id = <<-SQL
      SELECT last_insert_rowid()
      FROM dogs
    SQL

    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute(grab_id)[0][0]
    self
  end

  def self.create(**data)
    dog = Dog.new(data)
    # binding.pry
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    dog_by_id = DB[:conn].execute(sql,id)[0]
    dog_obj = Dog.new(id:dog_by_id[0], name:dog_by_id[1], breed:dog_by_id[2])
    dog_obj
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1
    SQL

    dog_list = DB[:conn].execute(sql,name,breed)

    if !dog_list.empty?
      dog_info = dog_list[0]
      dog = new_from_db(dog_info)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog

  end

  def self.new_from_db(array)
    dog = Dog.new(id: array[0], name: array[1], breed: array[2])
    dog
  end

  def self.find_by_name(data)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    DB[:conn].execute(sql,data).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    update = "UPDATE dogs SET name = ?, breed = ? WHERE dogs.id = ?"
    DB[:conn].execute(update,self.name,self.breed,self.id)

  end
end