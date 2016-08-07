class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    @name=name
    @breed=breed
    @id=id
  end

  def self.create_table
    sql= <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql= <<-SQL
    DROP TABLE IF EXISTS dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      sql2= <<-SQL
      SELECT id FROM dogs
      WHERE id=(SELECT MAX(id) FROM dogs);
      SQL

      self.id=DB[:conn].execute(sql2)[0][0]
    end
    self
  end

  def update
    sql=<<-SQL
    UPDATE dogs SET name=?, breed=? WHERE id=?;
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    doggo=Dog.new(name:name, breed:breed)
    doggo.save
    doggo
  end

  def self.find_by_id(id_number)
    sql=<<-SQL
      SELECT * FROM dogs
      WHERE id = #{id_number};
    SQL

    row=DB[:conn].execute(sql)[0]

    self.new_from_db(row)
  end

  def self.new_from_db(row)
    doggo=self.new(name:row[1], breed:row[2], id:row[0])
    doggo
  end

  def self.find_by_name(name)
    sql=<<-SQL
      SELECT * FROM dogs
      WHERE name = '#{name}';
    SQL
    row=DB[:conn].execute(sql)[0]
    self.new_from_db(row)
  end

  def self.find_by_name_and_breed(name:, breed:)
    sql=<<-SQL
      SELECT * FROM dogs
      WHERE name = '#{name}' AND breed='#{breed}';
    SQL

    if DB[:conn].execute(sql)==[]
      false
    else
      row=DB[:conn].execute(sql)[0]
      self.new_from_db(row)
    end
  end

  def self.find_or_create_by(name:, breed:)
    doggo=self.find_by_name_and_breed(name:name, breed:breed)
    if doggo == false
      self.create(name:name, breed:breed)
    else
      doggo
    end
  end

end
