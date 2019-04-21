require "pry"
class Dog
  
  attr_accessor :name, :breed, :id
  
  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
      SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    
    sql = <<-SQL
        DROP TABLE IF EXISTS dogs
      SQL
      
    DB[:conn].execute(sql)
  end
  
  def self.new_from_db(row)
    dog = Dog.new(id:row[0],
    name:row[1],
    breed:row[2])
  end
  
  def self.find_by_name(name)
    
    sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? LIMIT 1
      SQL
    
    DB[:conn].execute(sql, name).map do |row|
      new_from_db(row)
    end.first
    
  end
  
  def self.find_by_id(id)
    
    sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL
    dog = nil
    DB[:conn].execute(sql, id).map do |row|
      dog = new_from_db(row)
    end
    dog
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
      SQL
    row = DB[:conn].execute(sql, name, breed)
    
    dog = nil
    if !row.empty?
      dog = Dog.new(id:row[0][0], name:row[0][1],  breed:row[0][2])
    else
      dog = Dog.create(name:name, breed:breed)
    end
    dog
  end
  
  def update
    sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
     SQL
     
    DB[:conn].execute(sql, self.name, self.breed, self.id)
        
  end
  
  def save
    if self.id
      update
    else
      sql = <<-SQL
          INSERT INTO dogs (name, breed) VALUES (?,?)
        SQL
        
      DB[:conn].execute(sql, self.name, self.breed)
      sql = <<-SQL
          SELECT last_insert_rowid() FROM dogs
        SQL
        
      @id = DB[:conn].execute(sql)[0][0]
    end
    self
  end
  
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end
end