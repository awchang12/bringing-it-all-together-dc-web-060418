#COMPLETED BY ANTHONY AND AUGUST
require 'pry'
class Dog
    attr_accessor :name, :breed
    attr_reader :id
    
    def initialize(name:, breed:, id:nil)
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
            );
        SQL
        DB[:conn].execute(sql) 
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs;
        SQL
        
        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        self.new(name:row[1], breed:row[2], id:row[0])
    end

    def save
        
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed) VALUES (?, ?);
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end

    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name:name, breed:breed)
        new_dog.save
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?;
        SQL

        new_dog = DB[:conn].execute(sql, name)[0]
        self.new_from_db(new_dog)
    end

    def self.find_by_id(num)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?;
        SQL

        new_dog = DB[:conn].execute(sql, num)[0]
        self.new_from_db(new_dog)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(name:,breed:)
        sql = <<-SQL
          SELECT * FROM dogs WHERE name = ? AND breed = ?;
        SQL

        test_array = DB[:conn].execute(sql, name, breed)[0]

        if test_array == nil
            self.create(name: name, breed: breed)
        else
            self.new_from_db(test_array)
        end
    end

end